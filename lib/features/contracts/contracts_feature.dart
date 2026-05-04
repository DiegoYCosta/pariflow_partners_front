part of '../../app/app.dart';

class _ContractsWorkspace extends StatefulWidget {
  const _ContractsWorkspace({
    required this.viewerProfile,
    required this.selectedIndex,
    required this.onSelectItem,
  });

  final _ViewerAccessProfile viewerProfile;
  final int selectedIndex;
  final ValueChanged<int> onSelectItem;

  @override
  State<_ContractsWorkspace> createState() => _ContractsWorkspaceState();
}

class _ContractsWorkspaceState extends State<_ContractsWorkspace> {
  final _EntityWorkspaceApiRepository _repository =
      _EntityWorkspaceApiRepository();
  final TextEditingController _searchController = TextEditingController();
  _EntityWorkspaceRuntimeData _runtimeData = _EntityWorkspaceRuntimeData.mock(
    _contractsWorkspaceData,
  );
  List<_EntitySelectOption> _contractTypes = const [];
  List<_EntitySelectOption> _contractModels = const [];
  List<_EntitySelectOption> _contractServices = const [];
  bool _catalogLoading = false;
  String? _catalogErrorMessage;

  @override
  void initState() {
    super.initState();
    _loadContracts();
    _loadCatalog();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContracts() async {
    setState(() {
      _runtimeData = _runtimeData.copyWith(isLoading: true);
    });

    try {
      final data = await _repository.loadContracts(
        search: _searchController.text,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _runtimeData = data;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _runtimeData = _EntityWorkspaceRuntimeData.mock(
          _contractsWorkspaceData,
          errorMessage: _entityWorkspaceRuntimeErrorMessage(error, 'Contracts'),
        );
      });
    }
  }

  Future<void> _loadCatalog() async {
    setState(() {
      _catalogLoading = true;
      _catalogErrorMessage = null;
    });

    try {
      final results = await Future.wait([
        _repository.loadContractTypes(),
        _repository.loadContractModels(),
        _repository.loadContractServices(),
      ]);
      if (!mounted) {
        return;
      }
      setState(() {
        _contractTypes = results[0];
        _contractModels = results[1];
        _contractServices = results[2];
        _catalogLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _catalogLoading = false;
        _catalogErrorMessage = _peopleMutationErrorMessage(error);
      });
    }
  }

  Future<void> _runMutation(
    Future<void> Function() action, {
    required String successMessage,
    bool reloadCatalog = false,
  }) async {
    try {
      setState(() {
        _runtimeData = _runtimeData.copyWith(isLoading: true);
      });
      await action();
      await _loadContracts();
      if (reloadCatalog) {
        await _loadCatalog();
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _runtimeData = _runtimeData.copyWith(isLoading: false);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_peopleMutationErrorMessage(error)),
          backgroundColor: _roseColor,
        ),
      );
    }
  }

  Future<bool> _confirmContractAction({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _openCreateTypeDialog() async {
    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _ContractTypeCrudDialog(),
    );

    if (body == null || !mounted) {
      return;
    }

    await _runMutation(
      () => _repository.createContractType(body),
      successMessage: 'Tipo de contrato criado na API.',
      reloadCatalog: true,
    );
  }

  Future<void> _openEditTypeDialog(_EntitySelectOption type) async {
    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ContractTypeCrudDialog(initial: type),
    );

    if (body == null || !mounted) {
      return;
    }

    await _runMutation(
      () => _repository.updateContractType(type.publicId, body),
      successMessage: 'Tipo de contrato atualizado na API.',
      reloadCatalog: true,
    );
  }

  Future<void> _removeType(_EntitySelectOption type) async {
    final confirmed = await _confirmContractAction(
      title: 'Inativar tipo',
      message:
          'O tipo sera inativado. O backend nao permite ficar sem ao menos um tipo ativo.',
      confirmLabel: 'Inativar',
    );

    if (!confirmed || !mounted) {
      return;
    }

    await _runMutation(
      () => _repository.removeContractType(type.publicId),
      successMessage: 'Tipo de contrato inativado.',
      reloadCatalog: true,
    );
  }

  Future<void> _openCreateModelDialog() async {
    if (_contractTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Crie um tipo de contrato antes.')),
      );
      return;
    }

    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ContractModelCrudDialog(types: _contractTypes),
    );

    if (body == null || !mounted) {
      return;
    }

    await _runMutation(
      () => _repository.createContractModel(body),
      successMessage: 'Modelo de contrato criado na API.',
      reloadCatalog: true,
    );
  }

  Future<void> _openEditModelDialog(_EntitySelectOption model) async {
    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) =>
          _ContractModelCrudDialog(types: _contractTypes, initial: model),
    );

    if (body == null || !mounted) {
      return;
    }

    await _runMutation(
      () => _repository.updateContractModel(model.publicId, body),
      successMessage: 'Modelo de contrato atualizado na API.',
      reloadCatalog: true,
    );
  }

  Future<void> _removeModel(_EntitySelectOption model) async {
    final confirmed = await _confirmContractAction(
      title: 'Inativar modelo',
      message:
          'O modelo sera inativado. Contratos existentes continuam apontando para o historico.',
      confirmLabel: 'Inativar',
    );

    if (!confirmed || !mounted) {
      return;
    }

    await _runMutation(
      () => _repository.removeContractModel(model.publicId),
      successMessage: 'Modelo de contrato inativado.',
      reloadCatalog: true,
    );
  }

  Future<void> _openCreateServiceDialog() async {
    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _ContractServiceCrudDialog(),
    );

    if (body == null || !mounted) {
      return;
    }

    await _runMutation(
      () => _repository.createContractService(body),
      successMessage: 'Servico criado na API.',
      reloadCatalog: true,
    );
  }

  Future<void> _openEditServiceDialog(_EntitySelectOption service) async {
    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ContractServiceCrudDialog(initial: service),
    );

    if (body == null || !mounted) {
      return;
    }

    await _runMutation(
      () => _repository.updateContractService(service.publicId, body),
      successMessage: 'Servico atualizado na API.',
      reloadCatalog: true,
    );
  }

  Future<void> _removeService(_EntitySelectOption service) async {
    final confirmed = await _confirmContractAction(
      title: 'Inativar servico',
      message:
          'O servico sera inativado. Postos existentes continuam preservados para historico.',
      confirmLabel: 'Inativar',
    );

    if (!confirmed || !mounted) {
      return;
    }

    await _runMutation(
      () => _repository.removeContractService(service.publicId),
      successMessage: 'Servico inativado.',
      reloadCatalog: true,
    );
  }

  Future<void> _openCreatePositionDialog(_EntityItem item) async {
    final activeServices = _contractServices
        .where((service) => service.status.toUpperCase() == 'ACTIVE')
        .toList(growable: false);

    if (activeServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Crie um servico ativo antes do posto.')),
      );
      return;
    }

    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) =>
          _ContractPositionCrudDialog(services: activeServices),
    );

    if (body == null || !mounted) {
      return;
    }

    await _runMutation(
      () => _repository.createContractPosition(item.publicId, body),
      successMessage: 'Posto criado no contrato.',
    );
  }

  Future<void> _openEditPositionDialog(_ContractPositionRecord position) async {
    final activeServices = _contractServices
        .where(
          (service) =>
              service.status.toUpperCase() == 'ACTIVE' ||
              service.publicId == position.servicePublicId,
        )
        .toList(growable: false);

    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ContractPositionCrudDialog(
        services: activeServices,
        initial: position,
      ),
    );

    if (body == null || !mounted) {
      return;
    }

    await _runMutation(
      () => _repository.updateContractPosition(position.publicId, body),
      successMessage: 'Posto atualizado.',
    );
  }

  Future<void> _removePosition(_ContractPositionRecord position) async {
    final confirmed = await _confirmContractAction(
      title: 'Inativar posto',
      message:
          'O posto sera inativado sem remover vinculos historicos de pessoas.',
      confirmLabel: 'Inativar',
    );

    if (!confirmed || !mounted) {
      return;
    }

    await _runMutation(
      () => _repository.removeContractPosition(position.publicId),
      successMessage: 'Posto inativado.',
    );
  }

  Future<void> _openCreateDocumentDialog(_EntityItem item) async {
    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _ContractDocumentCrudDialog(),
    );

    if (body == null || !mounted) {
      return;
    }

    await _runMutation(
      () => _repository.createContractDocument(item.publicId, body),
      successMessage: 'Documento/link anexado ao contrato.',
    );
  }

  Future<void> _openEditDocumentDialog(_AttachmentRecord document) async {
    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ContractDocumentCrudDialog(initial: document),
    );

    if (body == null || !mounted) {
      return;
    }

    await _runMutation(
      () => _repository.updateContractDocument(document.publicId, body),
      successMessage: 'Documento/link atualizado.',
    );
  }

  Future<void> _removeDocument(_AttachmentRecord document) async {
    final confirmed = await _confirmContractAction(
      title: 'Remover documento',
      message: 'O documento ou link sera removido logicamente do contrato.',
      confirmLabel: 'Remover',
    );

    if (!confirmed || !mounted) {
      return;
    }

    await _runMutation(
      () => _repository.removeContractDocument(document.publicId),
      successMessage: 'Documento/link removido.',
    );
  }

  Future<void> _openCreateContractDialog() async {
    late final _ContractLookupData lookups;
    try {
      lookups = await _repository.loadContractLookups();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_peopleMutationErrorMessage(error)),
          backgroundColor: _roseColor,
        ),
      );
      return;
    }

    if (lookups.providerCompanies.isEmpty || lookups.clientCompanies.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Crie ao menos uma prestadora e um cliente antes do contrato.',
          ),
        ),
      );
      return;
    }

    if (lookups.contractTypes.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Crie ao menos um tipo de contrato antes.'),
        ),
      );
      return;
    }

    if (!mounted) {
      return;
    }

    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ContractCrudDialog(lookups: lookups),
    );

    if (body == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    await _runMutation(
      () => _repository.createContract(body),
      successMessage: 'Contrato criado na API.',
    );
  }

  Future<void> _openEditContractDialog(_EntityItem item) async {
    final snapshot = item.contractSnapshot;
    if (snapshot == null) {
      _showEntityUnavailableAction(context);
      return;
    }

    late final _ContractLookupData lookups;
    try {
      lookups = await _repository.loadContractLookups();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_peopleMutationErrorMessage(error)),
          backgroundColor: _roseColor,
        ),
      );
      return;
    }

    if (!mounted) {
      return;
    }

    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) =>
          _ContractCrudDialog(lookups: lookups, initial: snapshot),
    );

    if (body == null || !mounted) {
      return;
    }

    await _runMutation(
      () => _repository.updateContract(item.publicId, body),
      successMessage: 'Contrato atualizado na API.',
    );
  }

  Future<void> _removeContract(_EntityItem item) async {
    final confirmed = await _confirmContractAction(
      title: 'Inativar contrato',
      message:
          'O contrato sera inativado sem apagar documentos, postos ou vinculos de pessoas.',
      confirmLabel: 'Inativar',
    );

    if (!confirmed || !mounted) {
      return;
    }

    await _runMutation(
      () => _repository.removeContract(item.publicId),
      successMessage: 'Contrato inativado.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _runtimeData.data;
    final safeIndex = data.items.isEmpty
        ? 0
        : min(max(widget.selectedIndex, 0), data.items.length - 1);
    final selectedItem = data.items.isEmpty ? null : data.items[safeIndex];

    return Column(
      children: [
        _EntityWorkspace(
          data: data,
          viewerProfile: widget.viewerProfile,
          selectedIndex: safeIndex,
          onSelectItem: widget.onSelectItem,
          sourceLabel: _runtimeData.sourceLabel,
          isLive: _runtimeData.isLive,
          isLoading: _runtimeData.isLoading || _catalogLoading,
          errorMessage: _runtimeData.errorMessage ?? _catalogErrorMessage,
          searchController: _searchController,
          onSubmitSearch: _loadContracts,
          onClearSearch: () {
            _searchController.clear();
            _loadContracts();
          },
          onRefresh: () {
            _loadContracts();
            _loadCatalog();
          },
          primaryActionLabel: 'Novo contrato',
          primaryActionIcon: Icons.description_outlined,
          onPrimaryAction: _openCreateContractDialog,
        ),
        const SizedBox(height: 24),
        _EntityCrudActionsPanel(
          item: selectedItem,
          title: 'Gestao do contrato',
          summary:
              'Edicao e inativacao preservam documentos, postos e vinculos de pessoas para auditoria.',
          editLabel: 'Editar contrato',
          removeLabel: 'Inativar contrato',
          isLoading: _runtimeData.isLoading || _catalogLoading,
          onEdit: selectedItem == null
              ? null
              : () => _openEditContractDialog(selectedItem),
          onRemove: selectedItem == null
              ? null
              : () => _removeContract(selectedItem),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 1120;
            final catalog = _ContractCatalogPanel(
              types: _contractTypes,
              models: _contractModels,
              services: _contractServices,
              isLoading: _catalogLoading,
              onCreateType: _openCreateTypeDialog,
              onEditType: _openEditTypeDialog,
              onRemoveType: _removeType,
              onCreateModel: _openCreateModelDialog,
              onEditModel: _openEditModelDialog,
              onRemoveModel: _removeModel,
              onCreateService: _openCreateServiceDialog,
              onEditService: _openEditServiceDialog,
              onRemoveService: _removeService,
            );
            final positions = _ContractPositionsPanel(
              item: selectedItem,
              onCreatePosition: selectedItem == null
                  ? null
                  : () => _openCreatePositionDialog(selectedItem),
              onEditPosition: _openEditPositionDialog,
              onRemovePosition: _removePosition,
            );
            final documents = _ContractDocumentsPanel(
              item: selectedItem,
              viewerProfile: widget.viewerProfile,
              onCreateDocument: selectedItem == null
                  ? null
                  : () => _openCreateDocumentDialog(selectedItem),
              onEditDocument: _openEditDocumentDialog,
              onRemoveDocument: _removeDocument,
            );

            if (stacked) {
              return Column(
                children: [
                  catalog,
                  const SizedBox(height: 24),
                  positions,
                  const SizedBox(height: 24),
                  documents,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: catalog),
                const SizedBox(width: 24),
                Expanded(flex: 6, child: positions),
                const SizedBox(width: 24),
                Expanded(flex: 5, child: documents),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ContractCatalogPanel extends StatelessWidget {
  const _ContractCatalogPanel({
    required this.types,
    required this.models,
    required this.services,
    required this.isLoading,
    required this.onCreateType,
    required this.onEditType,
    required this.onRemoveType,
    required this.onCreateModel,
    required this.onEditModel,
    required this.onRemoveModel,
    required this.onCreateService,
    required this.onEditService,
    required this.onRemoveService,
  });

  final List<_EntitySelectOption> types;
  final List<_EntitySelectOption> models;
  final List<_EntitySelectOption> services;
  final bool isLoading;
  final VoidCallback onCreateType;
  final ValueChanged<_EntitySelectOption> onEditType;
  final ValueChanged<_EntitySelectOption> onRemoveType;
  final VoidCallback onCreateModel;
  final ValueChanged<_EntitySelectOption> onEditModel;
  final ValueChanged<_EntitySelectOption> onRemoveModel;
  final VoidCallback onCreateService;
  final ValueChanged<_EntitySelectOption> onEditService;
  final ValueChanged<_EntitySelectOption> onRemoveService;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Tipos e modelos', style: theme.textTheme.titleLarge),
              _Tag(
                label: '${types.length} tipos',
                icon: Icons.category_outlined,
                color: _amberColor,
                background: _amberColor.withValues(alpha: 0.12),
              ),
              _Tag(
                label: '${models.length} modelos',
                icon: Icons.copy_all_outlined,
                color: _slateColor,
                background: _slateColor.withValues(alpha: 0.12),
              ),
              _Tag(
                label: '${services.length} servicos',
                icon: Icons.design_services_outlined,
                color: _tealColor,
                background: _tealColor.withValues(alpha: 0.12),
              ),
              if (isLoading)
                _Tag(
                  label: 'sincronizando catalogo',
                  icon: Icons.sync_rounded,
                  color: _tealColor,
                  background: _tealColor.withValues(alpha: 0.12),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tipos classificam contratos. Modelos como Limpeza 12x36 podem ser reutilizados por empresas diferentes sem criar relacao entre elas.',
            style: theme.textTheme.bodyMedium?.copyWith(color: _mutedColor),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: isLoading ? null : onCreateType,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Novo tipo'),
              ),
              OutlinedButton.icon(
                onPressed: isLoading ? null : onCreateModel,
                icon: const Icon(Icons.copy_all_outlined),
                label: const Text('Novo modelo'),
              ),
              OutlinedButton.icon(
                onPressed: isLoading ? null : onCreateService,
                icon: const Icon(Icons.design_services_outlined),
                label: const Text('Novo servico'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text('Tipos ativos', style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          if (types.isEmpty)
            Text(
              'Nenhum tipo carregado ainda.',
              style: theme.textTheme.bodyMedium?.copyWith(color: _mutedColor),
            )
          else
            for (final type in types)
              _ContractCatalogTile(
                option: type,
                icon: Icons.category_outlined,
                accent: _amberColor,
                onEdit: () => onEditType(type),
                onRemove: () => onRemoveType(type),
              ),
          const SizedBox(height: 16),
          Text('Modelos reutilizaveis', style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          if (models.isEmpty)
            Text(
              'Nenhum modelo carregado ainda.',
              style: theme.textTheme.bodyMedium?.copyWith(color: _mutedColor),
            )
          else
            for (final model in models)
              _ContractCatalogTile(
                option: model,
                icon: Icons.copy_all_outlined,
                accent: _slateColor,
                onEdit: () => onEditModel(model),
                onRemove: () => onRemoveModel(model),
              ),
          const SizedBox(height: 16),
          Text('Servicos para postos', style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          if (services.isEmpty)
            Text(
              'Nenhum servico carregado ainda.',
              style: theme.textTheme.bodyMedium?.copyWith(color: _mutedColor),
            )
          else
            for (final service in services)
              _ContractCatalogTile(
                option: service,
                icon: Icons.design_services_outlined,
                accent: _tealColor,
                onEdit: () => onEditService(service),
                onRemove: () => onRemoveService(service),
              ),
        ],
      ),
    );
  }
}

class _ContractCatalogTile extends StatelessWidget {
  const _ContractCatalogTile({
    required this.option,
    required this.icon,
    required this.accent,
    required this.onEdit,
    required this.onRemove,
  });

  final _EntitySelectOption option;
  final IconData icon;
  final Color accent;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final inactive = option.status.toUpperCase() == 'INACTIVE';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: inactive ? const Color(0xFFF7F1E7) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _lineColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: inactive ? _mutedColor : accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (option.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    option.description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  '${option.publicId} | ${option.status}',
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: _mutedColor),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Editar',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Inativar',
            onPressed: inactive ? null : onRemove,
            icon: const Icon(Icons.archive_outlined),
          ),
        ],
      ),
    );
  }
}

class _ContractPositionsPanel extends StatelessWidget {
  const _ContractPositionsPanel({
    required this.item,
    required this.onCreatePosition,
    required this.onEditPosition,
    required this.onRemovePosition,
  });

  final _EntityItem? item;
  final VoidCallback? onCreatePosition;
  final ValueChanged<_ContractPositionRecord> onEditPosition;
  final ValueChanged<_ContractPositionRecord> onRemovePosition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final positions =
        item?.contractPositions ?? const <_ContractPositionRecord>[];

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Postos do contrato', style: theme.textTheme.titleLarge),
              _Tag(
                label: '${positions.length} postos',
                icon: Icons.work_outline_rounded,
                color: _amberColor,
                background: _amberColor.withValues(alpha: 0.12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item == null
                ? 'Selecione um contrato para gerenciar postos e vagas.'
                : 'Postos alimentam People e Network a partir do contrato ${item!.publicId}.',
            style: theme.textTheme.bodyMedium?.copyWith(color: _mutedColor),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onCreatePosition,
            icon: const Icon(Icons.add_business_outlined),
            label: const Text('Novo posto'),
          ),
          const SizedBox(height: 18),
          if (positions.isEmpty)
            Text(
              'Nenhum posto carregado para este contrato.',
              style: theme.textTheme.bodyMedium?.copyWith(color: _mutedColor),
            )
          else
            for (final position in positions)
              _ContractPositionTile(
                position: position,
                onEdit: () => onEditPosition(position),
                onRemove: () => onRemovePosition(position),
              ),
        ],
      ),
    );
  }
}

class _ContractPositionTile extends StatelessWidget {
  const _ContractPositionTile({
    required this.position,
    required this.onEdit,
    required this.onRemove,
  });

  final _ContractPositionRecord position;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _entityStatusColor(position.status);
    final inactive = position.status.toUpperCase() == 'INACTIVE';
    final meta = [
      if (position.location.isNotEmpty) position.location,
      if (position.shift.isNotEmpty) position.shift,
      if (position.schedule.isNotEmpty) position.schedule,
    ];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: inactive ? const Color(0xFFF7F1E7) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _lineColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.work_outline_rounded, color: statusColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(position.name, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      position.serviceName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _mutedColor,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Editar posto',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Inativar posto',
                onPressed: inactive ? null : onRemove,
                icon: const Icon(Icons.archive_outlined),
              ),
            ],
          ),
          if (meta.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              meta.join(' | '),
              style: theme.textTheme.bodyMedium?.copyWith(color: _mutedColor),
            ),
          ],
          if (position.requirements.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(position.requirements, style: theme.textTheme.bodyMedium),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Tag(
                label: _entityStatusLabel(position.status),
                icon: Icons.verified_outlined,
                color: statusColor,
                background: statusColor.withValues(alpha: 0.12),
              ),
              _Tag(
                label: position.publicId,
                icon: Icons.tag_outlined,
                color: _slateColor,
                background: _slateColor.withValues(alpha: 0.12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContractDocumentsPanel extends StatelessWidget {
  const _ContractDocumentsPanel({
    required this.item,
    required this.viewerProfile,
    required this.onCreateDocument,
    required this.onEditDocument,
    required this.onRemoveDocument,
  });

  final _EntityItem? item;
  final _ViewerAccessProfile viewerProfile;
  final VoidCallback? onCreateDocument;
  final ValueChanged<_AttachmentRecord> onEditDocument;
  final ValueChanged<_AttachmentRecord> onRemoveDocument;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleDocuments =
        item?.attachments
            .where(
              (document) => document.accessPolicy.canViewerRead(viewerProfile),
            )
            .toList() ??
        const <_AttachmentRecord>[];

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Documentos do contrato', style: theme.textTheme.titleLarge),
              _Tag(
                label: '${visibleDocuments.length} anexos/links',
                icon: Icons.attach_file_rounded,
                color: _tealColor,
                background: _tealColor.withValues(alpha: 0.12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item == null
                ? 'Selecione um contrato para anexar arquivos, links ou referencias fisicas.'
                : 'Contrato selecionado: ${item!.publicId}',
            style: theme.textTheme.bodyMedium?.copyWith(color: _mutedColor),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onCreateDocument,
            icon: const Icon(Icons.attach_file_rounded),
            label: const Text('Anexar documento/link'),
          ),
          const SizedBox(height: 18),
          if (visibleDocuments.isEmpty)
            Text(
              'Nenhum documento carregado para este contrato.',
              style: theme.textTheme.bodyMedium?.copyWith(color: _mutedColor),
            )
          else
            for (final document in visibleDocuments)
              _ContractDocumentTile(
                document: document,
                onEdit: () => onEditDocument(document),
                onRemove: () => onRemoveDocument(document),
              ),
        ],
      ),
    );
  }
}

class _ContractDocumentTile extends StatelessWidget {
  const _ContractDocumentTile({
    required this.document,
    required this.onEdit,
    required this.onRemove,
  });

  final _AttachmentRecord document;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _lineColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                document.classification.icon,
                color: document.classification.color,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(document.title, style: theme.textTheme.titleMedium),
              ),
              IconButton(
                tooltip: 'Editar documento',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Remover documento',
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            document.summary,
            style: theme.textTheme.bodyMedium?.copyWith(color: _mutedColor),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Tag(
                label: document.classification.label,
                icon: document.classification.icon,
                color: document.classification.color,
                background: document.classification.color.withValues(
                  alpha: 0.12,
                ),
              ),
              _Tag(
                label: document.updatedAtLabel,
                icon: Icons.update_outlined,
                color: _slateColor,
                background: _slateColor.withValues(alpha: 0.12),
              ),
              if (document.externalLink.isNotEmpty)
                _Tag(
                  label: 'link externo',
                  icon: Icons.link_rounded,
                  color: _tealColor,
                  background: _tealColor.withValues(alpha: 0.12),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContractCrudDialog extends StatefulWidget {
  const _ContractCrudDialog({required this.lookups, this.initial});

  final _ContractLookupData lookups;
  final _ContractCrudSnapshot? initial;

  @override
  State<_ContractCrudDialog> createState() => _ContractCrudDialogState();
}

class _ContractCrudDialogState extends State<_ContractCrudDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _startsAt = TextEditingController(
    text: _todayInputDate(),
  );
  final TextEditingController _endsAt = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  late String _providerCompanyPublicId;
  late String _clientCompanyPublicId;
  late String _contractTypePublicId;
  String _contractModelPublicId = '';
  String _status = 'ACTIVE';

  bool get _editing => widget.initial != null;

  List<_EntitySelectOption> get _modelsForSelectedType => widget
      .lookups
      .contractModels
      .where((model) => model.parentPublicId == _contractTypePublicId)
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _providerCompanyPublicId =
        initial?.providerCompanyPublicId.isNotEmpty == true
        ? initial!.providerCompanyPublicId
        : widget.lookups.providerCompanies.first.publicId;
    _clientCompanyPublicId = initial?.clientCompanyPublicId.isNotEmpty == true
        ? initial!.clientCompanyPublicId
        : widget.lookups.clientCompanies.first.publicId;
    _contractTypePublicId = initial?.contractTypePublicId.isNotEmpty == true
        ? initial!.contractTypePublicId
        : widget.lookups.contractTypes.first.publicId;
    final models = _modelsForSelectedType;
    if (initial?.contractModelPublicId.isNotEmpty == true &&
        models.any(
          (model) => model.publicId == initial!.contractModelPublicId,
        )) {
      _contractModelPublicId = initial!.contractModelPublicId;
    } else if (models.isNotEmpty) {
      _contractModelPublicId = models.first.publicId;
    }
    _startsAt.text = initial?.startsAtInput ?? _todayInputDate();
    _endsAt.text = initial?.endsAtInput ?? '';
    _status = initial?.status.isNotEmpty == true ? initial!.status : 'ACTIVE';
    _notes.text = initial?.notes ?? '';
  }

  @override
  void dispose() {
    _startsAt.dispose();
    _endsAt.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_editing ? 'Editar contrato' : 'Novo contrato'),
      content: SizedBox(
        width: min(MediaQuery.sizeOf(context).width - 48, 680),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogDropdown(
                  label: 'Prestadora',
                  value: _providerCompanyPublicId,
                  icon: Icons.apartment_outlined,
                  values: [
                    for (final option in widget.lookups.providerCompanies)
                      option.publicId,
                  ],
                  labels: {
                    for (final option in widget.lookups.providerCompanies)
                      option.publicId: option.label,
                  },
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _providerCompanyPublicId = value);
                    }
                  },
                ),
                _dialogDropdown(
                  label: 'Cliente',
                  value: _clientCompanyPublicId,
                  icon: Icons.business_outlined,
                  values: [
                    for (final option in widget.lookups.clientCompanies)
                      option.publicId,
                  ],
                  labels: {
                    for (final option in widget.lookups.clientCompanies)
                      option.publicId: option.label,
                  },
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _clientCompanyPublicId = value);
                    }
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: _dialogDropdown(
                        label: 'Tipo',
                        value: _contractTypePublicId,
                        icon: Icons.category_outlined,
                        values: [
                          for (final option in widget.lookups.contractTypes)
                            option.publicId,
                        ],
                        labels: {
                          for (final option in widget.lookups.contractTypes)
                            option.publicId: option.label,
                        },
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _contractTypePublicId = value;
                              final models = _modelsForSelectedType;
                              _contractModelPublicId = models.isEmpty
                                  ? ''
                                  : models.first.publicId;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _OptionalEntityDropdown(
                        label: 'Modelo',
                        value: _contractModelPublicId,
                        icon: Icons.copy_all_outlined,
                        options: _modelsForSelectedType,
                        emptyLabel: 'Sem modelo',
                        onChanged: (value) {
                          setState(() => _contractModelPublicId = value);
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _dialogTextField(
                        controller: _startsAt,
                        label: 'Inicio',
                        icon: Icons.calendar_today_outlined,
                        required: true,
                        hintText: 'yyyy-mm-dd',
                        dateLike: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dialogTextField(
                        controller: _endsAt,
                        label: 'Fim',
                        icon: Icons.event_available_outlined,
                        hintText: 'yyyy-mm-dd',
                        dateLike: true,
                      ),
                    ),
                  ],
                ),
                _dialogDropdown(
                  label: 'Status',
                  value: _status,
                  icon: Icons.verified_outlined,
                  values: const ['ACTIVE', 'DRAFT', 'SUSPENDED', 'EXPIRED'],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _status = value);
                    }
                  },
                ),
                _dialogTextField(
                  controller: _notes,
                  label: 'Notas',
                  icon: Icons.notes_outlined,
                  minLines: 3,
                  maxLines: 5,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(_editing ? 'Salvar' : 'Criar'),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      _cleanMutationBody({
        'providerCompanyPublicId': _providerCompanyPublicId,
        'clientCompanyPublicId': _clientCompanyPublicId,
        'contractTypePublicId': _contractTypePublicId,
        'contractModelPublicId': _contractModelPublicId,
        'startsAt': _dateInputToIso(_startsAt.text),
        'endsAt': _dateInputToIso(_endsAt.text),
        'status': _status,
        'notes': _notes.text,
      }),
    );
  }
}

class _ContractTypeCrudDialog extends StatefulWidget {
  const _ContractTypeCrudDialog({this.initial});

  final _EntitySelectOption? initial;

  @override
  State<_ContractTypeCrudDialog> createState() =>
      _ContractTypeCrudDialogState();
}

class _ContractTypeCrudDialogState extends State<_ContractTypeCrudDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late String _status;

  bool get _editing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _name = TextEditingController(text: initial?.label ?? '');
    _description = TextEditingController(text: initial?.description ?? '');
    _status = initial?.status.isNotEmpty == true ? initial!.status : 'ACTIVE';
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_editing ? 'Editar tipo' : 'Novo tipo'),
      content: SizedBox(
        width: min(MediaQuery.sizeOf(context).width - 48, 560),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogTextField(
                controller: _name,
                label: 'Nome do tipo',
                icon: Icons.category_outlined,
                required: true,
              ),
              _dialogDropdown(
                label: 'Status',
                value: _status,
                icon: Icons.verified_outlined,
                values: const ['ACTIVE', 'INACTIVE'],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _status = value);
                  }
                },
              ),
              _dialogTextField(
                controller: _description,
                label: 'Descricao',
                icon: Icons.notes_outlined,
                minLines: 3,
                maxLines: 5,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(_editing ? 'Salvar' : 'Criar'),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      _cleanMutationBody({
        'name': _name.text,
        'description': _description.text,
        'status': _status,
      }),
    );
  }
}

class _ContractModelCrudDialog extends StatefulWidget {
  const _ContractModelCrudDialog({required this.types, this.initial});

  final List<_EntitySelectOption> types;
  final _EntitySelectOption? initial;

  @override
  State<_ContractModelCrudDialog> createState() =>
      _ContractModelCrudDialogState();
}

class _ContractModelCrudDialogState extends State<_ContractModelCrudDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _defaultSchedule;
  late final TextEditingController _description;
  late String _contractTypePublicId;
  late String _status;

  bool get _editing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _name = TextEditingController(text: initial?.label ?? '');
    _defaultSchedule = TextEditingController(text: initial?.description ?? '');
    _description = TextEditingController();
    _contractTypePublicId = initial?.parentPublicId.isNotEmpty == true
        ? initial!.parentPublicId
        : widget.types.first.publicId;
    _status = initial?.status.isNotEmpty == true ? initial!.status : 'ACTIVE';
  }

  @override
  void dispose() {
    _name.dispose();
    _defaultSchedule.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_editing ? 'Editar modelo' : 'Novo modelo'),
      content: SizedBox(
        width: min(MediaQuery.sizeOf(context).width - 48, 620),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogDropdown(
                  label: 'Tipo',
                  value: _contractTypePublicId,
                  icon: Icons.category_outlined,
                  values: [for (final type in widget.types) type.publicId],
                  labels: {
                    for (final type in widget.types) type.publicId: type.label,
                  },
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _contractTypePublicId = value);
                    }
                  },
                ),
                _dialogTextField(
                  controller: _name,
                  label: 'Nome do modelo',
                  icon: Icons.copy_all_outlined,
                  required: true,
                ),
                _dialogTextField(
                  controller: _defaultSchedule,
                  label: 'Escala padrao',
                  icon: Icons.schedule_outlined,
                ),
                _dialogDropdown(
                  label: 'Status',
                  value: _status,
                  icon: Icons.verified_outlined,
                  values: const ['ACTIVE', 'INACTIVE'],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _status = value);
                    }
                  },
                ),
                _dialogTextField(
                  controller: _description,
                  label: 'Descricao',
                  icon: Icons.notes_outlined,
                  minLines: 3,
                  maxLines: 5,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(_editing ? 'Salvar' : 'Criar'),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      _cleanMutationBody({
        'contractTypePublicId': _contractTypePublicId,
        'name': _name.text,
        'defaultSchedule': _defaultSchedule.text,
        'description': _description.text,
        'status': _status,
      }),
    );
  }
}

class _ContractServiceCrudDialog extends StatefulWidget {
  const _ContractServiceCrudDialog({this.initial});

  final _EntitySelectOption? initial;

  @override
  State<_ContractServiceCrudDialog> createState() =>
      _ContractServiceCrudDialogState();
}

class _ContractServiceCrudDialogState
    extends State<_ContractServiceCrudDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _category;
  late final TextEditingController _description;
  late bool _isActive;

  bool get _editing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _name = TextEditingController(text: initial?.label ?? '');
    _category = TextEditingController(text: initial?.parentPublicId ?? '');
    _description = TextEditingController(text: initial?.description ?? '');
    _isActive = initial?.status.toUpperCase() != 'INACTIVE';
  }

  @override
  void dispose() {
    _name.dispose();
    _category.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_editing ? 'Editar servico' : 'Novo servico'),
      content: SizedBox(
        width: min(MediaQuery.sizeOf(context).width - 48, 580),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogTextField(
                  controller: _name,
                  label: 'Nome do servico',
                  icon: Icons.design_services_outlined,
                  required: true,
                ),
                _dialogTextField(
                  controller: _category,
                  label: 'Categoria',
                  icon: Icons.category_outlined,
                ),
                _dialogTextField(
                  controller: _description,
                  label: 'Descricao',
                  icon: Icons.notes_outlined,
                  minLines: 3,
                  maxLines: 5,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                  title: const Text('Servico ativo'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(_editing ? 'Salvar' : 'Criar'),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      _cleanMutationBody({
        'name': _name.text,
        'category': _category.text,
        'description': _description.text,
        'isActive': _isActive,
      }),
    );
  }
}

class _ContractPositionCrudDialog extends StatefulWidget {
  const _ContractPositionCrudDialog({required this.services, this.initial});

  final List<_EntitySelectOption> services;
  final _ContractPositionRecord? initial;

  @override
  State<_ContractPositionCrudDialog> createState() =>
      _ContractPositionCrudDialogState();
}

class _ContractPositionCrudDialogState
    extends State<_ContractPositionCrudDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _location;
  late final TextEditingController _shift;
  late final TextEditingController _schedule;
  late final TextEditingController _requirements;
  late String _servicePublicId;
  late String _status;

  bool get _editing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _name = TextEditingController(text: initial?.name ?? '');
    _location = TextEditingController(text: initial?.location ?? '');
    _shift = TextEditingController(text: initial?.shift ?? '');
    _schedule = TextEditingController(text: initial?.schedule ?? '');
    _requirements = TextEditingController(text: initial?.requirements ?? '');
    _servicePublicId = initial?.servicePublicId.isNotEmpty == true
        ? initial!.servicePublicId
        : widget.services.first.publicId;
    _status = initial?.status.isNotEmpty == true ? initial!.status : 'ACTIVE';
  }

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _shift.dispose();
    _schedule.dispose();
    _requirements.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_editing ? 'Editar posto' : 'Novo posto'),
      content: SizedBox(
        width: min(MediaQuery.sizeOf(context).width - 48, 640),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogDropdown(
                  label: 'Servico',
                  value: _servicePublicId,
                  icon: Icons.design_services_outlined,
                  values: [
                    for (final service in widget.services) service.publicId,
                  ],
                  labels: {
                    for (final service in widget.services)
                      service.publicId: service.label,
                  },
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _servicePublicId = value);
                    }
                  },
                ),
                _dialogTextField(
                  controller: _name,
                  label: 'Nome do posto',
                  icon: Icons.work_outline_rounded,
                  required: true,
                ),
                Row(
                  children: [
                    Expanded(
                      child: _dialogTextField(
                        controller: _location,
                        label: 'Local',
                        icon: Icons.location_on_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dialogTextField(
                        controller: _shift,
                        label: 'Turno',
                        icon: Icons.access_time_outlined,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _dialogTextField(
                        controller: _schedule,
                        label: 'Escala',
                        icon: Icons.schedule_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dialogDropdown(
                        label: 'Status',
                        value: _status,
                        icon: Icons.verified_outlined,
                        values: const ['ACTIVE', 'INACTIVE', 'SUSPENDED'],
                        labels: const {
                          'ACTIVE': 'Ativo',
                          'INACTIVE': 'Inativo',
                          'SUSPENDED': 'Suspenso',
                        },
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _status = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                _dialogTextField(
                  controller: _requirements,
                  label: 'Requisitos',
                  icon: Icons.rule_folder_outlined,
                  minLines: 3,
                  maxLines: 5,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(_editing ? 'Salvar' : 'Criar'),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      _cleanMutationBody({
        'servicePublicId': _servicePublicId,
        'name': _name.text,
        'location': _location.text,
        'shift': _shift.text,
        'schedule': _schedule.text,
        'requirements': _requirements.text,
        'status': _status,
      }),
    );
  }
}

class _ContractDocumentCrudDialog extends StatefulWidget {
  const _ContractDocumentCrudDialog({this.initial});

  final _AttachmentRecord? initial;

  @override
  State<_ContractDocumentCrudDialog> createState() =>
      _ContractDocumentCrudDialogState();
}

class _ContractDocumentCrudDialogState
    extends State<_ContractDocumentCrudDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _fileName;
  late final TextEditingController _mimeType;
  late final TextEditingController _externalLink;
  late final TextEditingController _physicalLocation;
  late final TextEditingController _notes;
  late String _classification;

  bool get _editing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _title = TextEditingController(text: initial?.title ?? '');
    _fileName = TextEditingController();
    _mimeType = TextEditingController(text: initial?.mimeType ?? '');
    _externalLink = TextEditingController(text: initial?.externalLink ?? '');
    _physicalLocation = TextEditingController(
      text: initial?.physicalLocation ?? '',
    );
    _notes = TextEditingController(text: initial?.summary ?? '');
    _classification = _attachmentClassificationApiValue(
      initial?.classification ?? _AttachmentClassification.formalDocument,
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _fileName.dispose();
    _mimeType.dispose();
    _externalLink.dispose();
    _physicalLocation.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_editing ? 'Editar documento/link' : 'Anexar documento/link'),
      content: SizedBox(
        width: min(MediaQuery.sizeOf(context).width - 48, 640),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogTextField(
                  controller: _title,
                  label: 'Titulo',
                  icon: Icons.description_outlined,
                  required: true,
                ),
                _dialogDropdown(
                  label: 'Classificacao',
                  value: _classification,
                  icon: Icons.lock_outline_rounded,
                  values: const [
                    'FORMAL_DOCUMENT',
                    'SENSITIVE_ATTACHMENT',
                    'SUPPORTING_REFERENCE',
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _classification = value);
                    }
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: _dialogTextField(
                        controller: _fileName,
                        label: 'Arquivo',
                        icon: Icons.insert_drive_file_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dialogTextField(
                        controller: _mimeType,
                        label: 'MIME',
                        icon: Icons.code_rounded,
                      ),
                    ),
                  ],
                ),
                _dialogTextField(
                  controller: _externalLink,
                  label: 'Link externo',
                  icon: Icons.link_rounded,
                ),
                _dialogTextField(
                  controller: _physicalLocation,
                  label: 'Local fisico',
                  icon: Icons.inventory_2_outlined,
                ),
                _dialogTextField(
                  controller: _notes,
                  label: 'Notas',
                  icon: Icons.notes_outlined,
                  minLines: 3,
                  maxLines: 5,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(_editing ? 'Salvar' : 'Anexar'),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fileName.text.trim().isEmpty &&
        _externalLink.text.trim().isEmpty &&
        _physicalLocation.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe arquivo, link externo ou local fisico.'),
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      _cleanMutationBody({
        'title': _title.text,
        'classification': _classification,
        'fileName': _fileName.text,
        'mimeType': _mimeType.text,
        'externalLink': _externalLink.text,
        'physicalLocation': _physicalLocation.text,
        'notes': _notes.text,
      }),
    );
  }
}

class _OptionalEntityDropdown extends StatelessWidget {
  const _OptionalEntityDropdown({
    required this.label,
    required this.value,
    required this.icon,
    required this.options,
    required this.emptyLabel,
    required this.onChanged,
  });

  final String label;
  final String value;
  final IconData icon;
  final List<_EntitySelectOption> options;
  final String emptyLabel;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final values = ['', ...options.map((option) => option.publicId)];
    final selectedValue = values.contains(value) ? value : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        items: [
          DropdownMenuItem<String>(value: '', child: Text(emptyLabel)),
          for (final option in options)
            DropdownMenuItem<String>(
              value: option.publicId,
              child: Text(option.label, overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
      ),
    );
  }
}
