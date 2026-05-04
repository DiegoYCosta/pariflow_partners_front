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

  @override
  Widget build(BuildContext context) {
    return _EntityWorkspace(
      data: _runtimeData.data,
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
    );
  }
}

class _ProviderCompanyCrudDialog extends StatefulWidget {
  const _ProviderCompanyCrudDialog();

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
      title: const Text('Nova prestadora'),
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
        FilledButton(onPressed: _submit, child: const Text('Criar')),
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
