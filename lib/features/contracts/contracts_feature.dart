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
      ]);
      if (!mounted) {
        return;
      }
      setState(() {
        _contractTypes = results[0];
        _contractModels = results[1];
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
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 1120;
            final catalog = _ContractCatalogPanel(
              types: _contractTypes,
              models: _contractModels,
              isLoading: _catalogLoading,
              onCreateType: _openCreateTypeDialog,
              onEditType: _openEditTypeDialog,
              onRemoveType: _removeType,
              onCreateModel: _openCreateModelDialog,
              onEditModel: _openEditModelDialog,
              onRemoveModel: _removeModel,
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
                children: [catalog, const SizedBox(height: 24), documents],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 6, child: catalog),
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
    required this.isLoading,
    required this.onCreateType,
    required this.onEditType,
    required this.onRemoveType,
    required this.onCreateModel,
    required this.onEditModel,
    required this.onRemoveModel,
  });

  final List<_EntitySelectOption> types;
  final List<_EntitySelectOption> models;
  final bool isLoading;
  final VoidCallback onCreateType;
  final ValueChanged<_EntitySelectOption> onEditType;
  final ValueChanged<_EntitySelectOption> onRemoveType;
  final VoidCallback onCreateModel;
  final ValueChanged<_EntitySelectOption> onEditModel;
  final ValueChanged<_EntitySelectOption> onRemoveModel;

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
  const _ContractCrudDialog({required this.lookups});

  final _ContractLookupData lookups;

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

  List<_EntitySelectOption> get _modelsForSelectedType => widget
      .lookups
      .contractModels
      .where((model) => model.parentPublicId == _contractTypePublicId)
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    _providerCompanyPublicId = widget.lookups.providerCompanies.first.publicId;
    _clientCompanyPublicId = widget.lookups.clientCompanies.first.publicId;
    _contractTypePublicId = widget.lookups.contractTypes.first.publicId;
    final models = _modelsForSelectedType;
    if (models.isNotEmpty) {
      _contractModelPublicId = models.first.publicId;
    }
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
      title: const Text('Novo contrato'),
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
        FilledButton(onPressed: _submit, child: const Text('Criar')),
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
