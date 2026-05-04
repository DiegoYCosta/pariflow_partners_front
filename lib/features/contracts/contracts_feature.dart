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

  @override
  void initState() {
    super.initState();
    _loadContracts();
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

  Future<void> _runMutation(
    Future<void> Function() action, {
    required String successMessage,
  }) async {
    try {
      setState(() {
        _runtimeData = _runtimeData.copyWith(isLoading: true);
      });
      await action();
      await _loadContracts();
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
      onSubmitSearch: _loadContracts,
      onClearSearch: () {
        _searchController.clear();
        _loadContracts();
      },
      onRefresh: _loadContracts,
      primaryActionLabel: 'Novo contrato',
      primaryActionIcon: Icons.description_outlined,
      onPrimaryAction: _openCreateContractDialog,
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
  String _status = 'ACTIVE';

  @override
  void initState() {
    super.initState();
    _providerCompanyPublicId = widget.lookups.providerCompanies.first.publicId;
    _clientCompanyPublicId = widget.lookups.clientCompanies.first.publicId;
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
        'startsAt': _dateInputToIso(_startsAt.text),
        'endsAt': _dateInputToIso(_endsAt.text),
        'status': _status,
        'notes': _notes.text,
      }),
    );
  }
}
