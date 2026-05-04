part of '../../app/app.dart';

class _ClientCompaniesWorkspace extends StatefulWidget {
  const _ClientCompaniesWorkspace({
    required this.viewerProfile,
    required this.selectedIndex,
    required this.onSelectItem,
  });

  final _ViewerAccessProfile viewerProfile;
  final int selectedIndex;
  final ValueChanged<int> onSelectItem;

  @override
  State<_ClientCompaniesWorkspace> createState() =>
      _ClientCompaniesWorkspaceState();
}

class _ClientCompaniesWorkspaceState extends State<_ClientCompaniesWorkspace> {
  final _EntityWorkspaceApiRepository _repository =
      _EntityWorkspaceApiRepository();
  final TextEditingController _searchController = TextEditingController();
  _EntityWorkspaceRuntimeData _runtimeData = _EntityWorkspaceRuntimeData.mock(
    _clientCompaniesWorkspaceData,
  );

  @override
  void initState() {
    super.initState();
    _loadClientCompanies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClientCompanies() async {
    setState(() {
      _runtimeData = _runtimeData.copyWith(isLoading: true);
    });

    try {
      final data = await _repository.loadClientCompanies(
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
          _clientCompaniesWorkspaceData,
          errorMessage: _entityWorkspaceRuntimeErrorMessage(error, 'Clients'),
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
      await _loadClientCompanies();
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

  Future<void> _openCreateClientDialog() async {
    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _ClientCompanyCrudDialog(),
    );

    if (body == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    await _runMutation(
      () => _repository.createClientCompany(body),
      successMessage: 'Cliente criado na API.',
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
      onSubmitSearch: _loadClientCompanies,
      onClearSearch: () {
        _searchController.clear();
        _loadClientCompanies();
      },
      onRefresh: _loadClientCompanies,
      primaryActionLabel: 'Novo cliente',
      primaryActionIcon: Icons.business_outlined,
      onPrimaryAction: _openCreateClientDialog,
    );
  }
}

class _ClientCompanyCrudDialog extends StatefulWidget {
  const _ClientCompanyCrudDialog();

  @override
  State<_ClientCompanyCrudDialog> createState() =>
      _ClientCompanyCrudDialogState();
}

class _ClientCompanyCrudDialogState extends State<_ClientCompanyCrudDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _document = TextEditingController();
  final TextEditingController _contactName = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _state = TextEditingController();
  String _clientType = 'CONDOMINIO';
  String _status = 'ACTIVE';

  @override
  void dispose() {
    _name.dispose();
    _document.dispose();
    _contactName.dispose();
    _city.dispose();
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo cliente'),
      content: SizedBox(
        width: min(MediaQuery.sizeOf(context).width - 48, 620),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogTextField(
                  controller: _name,
                  label: 'Nome do cliente',
                  icon: Icons.business_outlined,
                  required: true,
                ),
                _dialogTextField(
                  controller: _document,
                  label: 'Documento',
                  icon: Icons.badge_outlined,
                ),
                Row(
                  children: [
                    Expanded(
                      child: _dialogDropdown(
                        label: 'Tipo',
                        value: _clientType,
                        icon: Icons.category_outlined,
                        values: const [
                          'CONDOMINIO',
                          'CORPORATE',
                          'RETAIL',
                          'INDUSTRIAL',
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _clientType = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dialogDropdown(
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
                    ),
                  ],
                ),
                _dialogTextField(
                  controller: _contactName,
                  label: 'Contato principal',
                  icon: Icons.person_outline_rounded,
                ),
                Row(
                  children: [
                    Expanded(
                      child: _dialogTextField(
                        controller: _city,
                        label: 'Cidade',
                        icon: Icons.location_city_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dialogTextField(
                        controller: _state,
                        label: 'UF',
                        icon: Icons.map_outlined,
                      ),
                    ),
                  ],
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

    final address = <String, String>{
      if (_city.text.trim().isNotEmpty) 'city': _city.text.trim(),
      if (_state.text.trim().isNotEmpty) 'state': _state.text.trim(),
    };

    Navigator.of(context).pop(
      _cleanMutationBody({
        'name': _name.text,
        'document': _document.text,
        'clientType': _clientType,
        if (address.isNotEmpty) 'addressJson': address,
        'contactName': _contactName.text,
        'status': _status,
      }),
    );
  }
}
