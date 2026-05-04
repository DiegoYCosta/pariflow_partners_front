part of '../../app/app.dart';

class _CompaniesWorkspace extends StatefulWidget {
  const _CompaniesWorkspace({
    required this.viewerProfile,
    required this.selectedIndex,
    required this.onSelectItem,
  });

  final _ViewerAccessProfile viewerProfile;
  final int selectedIndex;
  final ValueChanged<int> onSelectItem;

  @override
  State<_CompaniesWorkspace> createState() => _CompaniesWorkspaceState();
}

class _CompaniesWorkspaceState extends State<_CompaniesWorkspace> {
  final _EntityWorkspaceApiRepository _repository =
      _EntityWorkspaceApiRepository();
  final TextEditingController _searchController = TextEditingController();
  _EntityWorkspaceRuntimeData _runtimeData = _EntityWorkspaceRuntimeData.mock(
    _companiesWorkspaceData,
  );

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCompanies() async {
    setState(() {
      _runtimeData = _runtimeData.copyWith(isLoading: true);
    });

    try {
      final data = await _repository.loadProviderCompanies(
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
          _companiesWorkspaceData,
          errorMessage: _entityWorkspaceRuntimeErrorMessage(error, 'Companies'),
        );
      });
    }
  }

  Future<void> _runMutation(
    Future<void> Function() action, {
    required String successMessage,
  }) async {
    try {
      setState(() {
        _runtimeData = _runtimeData.copyWith(isLoading: true);
      });
      await action();
      await _loadCompanies();
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

  Future<void> _openCreateCompanyDialog() async {
    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _ProviderCompanyCrudDialog(),
    );

    if (body == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    await _runMutation(
      () => _repository.createProviderCompany(body),
      successMessage: 'Empresa prestadora criada na API.',
    );
  }

  Future<void> _openEditCompanyDialog(_EntityItem item) async {
    final snapshot = item.providerCompanySnapshot;
    if (snapshot == null) {
      _showEntityUnavailableAction(context);
      return;
    }

    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ProviderCompanyCrudDialog(initial: snapshot),
    );

    if (body == null || !mounted) {
      return;
    }

    await _runMutation(
      () => _repository.updateProviderCompany(item.publicId, body),
      successMessage: 'Empresa prestadora atualizada na API.',
    );
  }

  Future<void> _removeCompany(_EntityItem item) async {
    final confirmed = await _confirmEntityAction(
      context: context,
      title: 'Inativar prestadora',
      message:
          'A prestadora sera inativada sem apagar contratos, vinculos ou historico.',
      confirmLabel: 'Inativar',
    );

    if (!confirmed || !mounted) {
      return;
    }

    await _runMutation(
      () => _repository.removeProviderCompany(item.publicId),
      successMessage: 'Empresa prestadora inativada.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _runtimeData.data;
    final selectedItem = data.items.isEmpty
        ? null
        : data.items[min(max(widget.selectedIndex, 0), data.items.length - 1)];

    return Column(
      children: [
        _EntityWorkspace(
          data: data,
          viewerProfile: widget.viewerProfile,
          selectedIndex: widget.selectedIndex,
          onSelectItem: widget.onSelectItem,
          sourceLabel: _runtimeData.sourceLabel,
          isLive: _runtimeData.isLive,
          isLoading: _runtimeData.isLoading,
          errorMessage: _runtimeData.errorMessage,
          searchController: _searchController,
          onSubmitSearch: _loadCompanies,
          onClearSearch: () {
            _searchController.clear();
            _loadCompanies();
          },
          onRefresh: _loadCompanies,
          primaryActionLabel: 'Nova prestadora',
          primaryActionIcon: Icons.apartment_outlined,
          onPrimaryAction: _openCreateCompanyDialog,
        ),
        const SizedBox(height: 24),
        _EntityCrudActionsPanel(
          item: selectedItem,
          title: 'Gestao da prestadora',
          summary:
              'Edicao e inativacao preservam historico para contratos, People e Network.',
          editLabel: 'Editar prestadora',
          removeLabel: 'Inativar prestadora',
          isLoading: _runtimeData.isLoading,
          onEdit: selectedItem == null
              ? null
              : () => _openEditCompanyDialog(selectedItem),
          onRemove: selectedItem == null
              ? null
              : () => _removeCompany(selectedItem),
        ),
      ],
    );
  }
}

class _ProviderCompanyCrudDialog extends StatefulWidget {
  const _ProviderCompanyCrudDialog({this.initial});

  final _ProviderCompanyCrudSnapshot? initial;

  @override
  State<_ProviderCompanyCrudDialog> createState() =>
      _ProviderCompanyCrudDialogState();
}

class _ProviderCompanyCrudDialogState
    extends State<_ProviderCompanyCrudDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _legalName = TextEditingController();
  final TextEditingController _tradeName = TextEditingController();
  final TextEditingController _document = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  String _status = 'ACTIVE';

  bool get _editing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _legalName.text = initial.legalName;
      _tradeName.text = initial.tradeName;
      _document.text = initial.document;
      _email.text = initial.email;
      _phone.text = initial.phone;
      _notes.text = initial.notes;
      _status = initial.status.isEmpty ? 'ACTIVE' : initial.status;
    }
  }

  @override
  void dispose() {
    _legalName.dispose();
    _tradeName.dispose();
    _document.dispose();
    _email.dispose();
    _phone.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_editing ? 'Editar prestadora' : 'Nova prestadora'),
      content: SizedBox(
        width: min(MediaQuery.sizeOf(context).width - 48, 620),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogTextField(
                  controller: _legalName,
                  label: 'Razao social',
                  icon: Icons.apartment_outlined,
                  required: true,
                ),
                _dialogTextField(
                  controller: _tradeName,
                  label: 'Nome fantasia',
                  icon: Icons.storefront_outlined,
                ),
                _dialogTextField(
                  controller: _document,
                  label: 'Documento',
                  icon: Icons.badge_outlined,
                  required: true,
                ),
                _dialogDropdown(
                  label: 'Status',
                  value: _status,
                  icon: Icons.verified_outlined,
                  values: const ['ACTIVE', 'INACTIVE', 'SUSPENDED'],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _status = value);
                    }
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: _dialogTextField(
                        controller: _email,
                        label: 'Email',
                        icon: Icons.mail_outline_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dialogTextField(
                        controller: _phone,
                        label: 'Telefone',
                        icon: Icons.call_outlined,
                      ),
                    ),
                  ],
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

    final contacts = <String, String>{
      if (_email.text.trim().isNotEmpty) 'email': _email.text.trim(),
      if (_phone.text.trim().isNotEmpty) 'phone': _phone.text.trim(),
    };

    Navigator.of(context).pop(
      _cleanMutationBody({
        'legalName': _legalName.text,
        'tradeName': _tradeName.text,
        'document': _document.text,
        'status': _status,
        if (contacts.isNotEmpty) 'contactsJson': contacts,
        'notes': _notes.text,
      }),
    );
  }
}

class _EntityCrudActionsPanel extends StatelessWidget {
  const _EntityCrudActionsPanel({
    required this.item,
    required this.title,
    required this.summary,
    required this.editLabel,
    required this.removeLabel,
    required this.isLoading,
    required this.onEdit,
    required this.onRemove,
  });

  final _EntityItem? item;
  final String title;
  final String summary;
  final String editLabel;
  final String removeLabel;
  final bool isLoading;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _Panel(
      padding: const EdgeInsets.all(22),
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(title, style: theme.textTheme.titleLarge),
                    if (item != null)
                      _Tag(
                        label: item!.publicId,
                        icon: Icons.tag_outlined,
                        color: _slateColor,
                        background: _slateColor.withValues(alpha: 0.12),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item == null ? 'Selecione um registro para editar.' : summary,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _mutedColor,
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: isLoading ? null : onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: Text(editLabel),
              ),
              OutlinedButton.icon(
                onPressed: isLoading ? null : onRemove,
                icon: const Icon(Icons.archive_outlined),
                label: Text(removeLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<bool> _confirmEntityAction({
  required BuildContext context,
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

void _showEntityUnavailableAction(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Acao disponivel apenas com dados reais da API.'),
    ),
  );
}
