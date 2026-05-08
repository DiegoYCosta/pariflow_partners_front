part of '../../app/app.dart';

class _PeopleWorkspace extends StatefulWidget {
  const _PeopleWorkspace({
    required this.viewerProfile,
    required this.selectedIndex,
    required this.onSelectItem,
  });

  final _ViewerAccessProfile viewerProfile;
  final int selectedIndex;
  final ValueChanged<int> onSelectItem;

  @override
  State<_PeopleWorkspace> createState() => _PeopleWorkspaceState();
}

class _PeopleWorkspaceState extends State<_PeopleWorkspace> {
  final _PeopleApiRepository _repository = _PeopleApiRepository();
  late final TextEditingController _searchController;
  _PeopleRuntimeData _runtimeData = _PeopleRuntimeData.initial();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadPeopleData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPeopleData() async {
    setState(() {
      _runtimeData = _runtimeData.copyWith(isLoading: true);
    });

    try {
      final data = await _repository.loadWorkspaceData();
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
        _runtimeData = _PeopleRuntimeData.unavailable(
          message: _peopleRuntimeErrorMessage(error),
        );
      });
    }
  }

  Future<void> _runPeopleMutation(
    Future<void> Function() action, {
    required String successMessage,
  }) async {
    try {
      setState(() {
        _runtimeData = _runtimeData.copyWith(isLoading: true);
      });
      await action();
      await _loadPeopleData();
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

  Future<void> _openCreatePersonDialog() async {
    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _PersonCrudDialog(),
    );

    if (body == null) {
      return;
    }

    await _runPeopleMutation(
      () => _repository.createPerson(body),
      successMessage: 'Pessoa criada na API.',
    );
  }

  Future<void> _openEditPersonDialog(_EntityItem item) async {
    final snapshot = item.personProfile?.crudSnapshot;
    if (snapshot == null) {
      _showUnavailableAction();
      return;
    }

    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _PersonCrudDialog(initial: snapshot),
    );

    if (body == null) {
      return;
    }

    await _runPeopleMutation(
      () => _repository.updatePerson(item.publicId, body),
      successMessage: 'Pessoa atualizada na API.',
    );
  }

  Future<void> _removePerson(_EntityItem item) async {
    final confirmed = await _confirmAction(
      title: 'Remover pessoa',
      message:
          'A remocao so sera aceita se a pessoa nao tiver vinculos, ocorrencias ou tags.',
      confirmLabel: 'Remover',
    );

    if (!confirmed) {
      return;
    }

    await _runPeopleMutation(
      () => _repository.removePerson(item.publicId),
      successMessage: 'Pessoa removida da API.',
    );
  }

  Future<void> _openCreateEmploymentLinkDialog(_EntityItem item) async {
    if (!_runtimeData.isLive) {
      _showUnavailableAction();
      return;
    }

    late final _EmploymentLinkLookupData lookups;
    try {
      lookups = await _repository.loadEmploymentLinkLookups();
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

    final hasUsableContract = lookups.contracts.any(
      (contract) => contract.positions.isNotEmpty,
    );
    if (lookups.providerCompanies.isEmpty ||
        lookups.contracts.isEmpty ||
        !hasUsableContract) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cadastre ao menos uma prestadora, um contrato e um posto antes de vincular contrato a pessoa.',
          ),
        ),
      );
      return;
    }

    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _EmploymentLinkCrudDialog(
        personPublicId: item.publicId,
        lookups: lookups,
      ),
    );

    if (body == null) {
      return;
    }

    await _runPeopleMutation(
      () => _repository.createEmploymentLink(body),
      successMessage: 'Contrato vinculado a pessoa na API.',
    );
  }

  Future<void> _openCreateOccurrenceDialog(_EntityItem item) async {
    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) =>
          _OccurrenceCrudDialog(personPublicId: item.publicId),
    );

    if (body == null) {
      return;
    }

    await _runPeopleMutation(
      () => _repository.createOccurrence(body),
      successMessage: 'Ocorrencia criada na API.',
    );
  }

  Future<void> _openEditOccurrenceDialog(
    _EntityItem item,
    _OccurrenceRecord occurrence,
  ) async {
    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _OccurrenceCrudDialog(
        personPublicId: item.publicId,
        initial: occurrence,
      ),
    );

    if (body == null) {
      return;
    }

    await _runPeopleMutation(
      () => _repository.updateOccurrence(occurrence.publicId, body),
      successMessage: 'Ocorrencia atualizada na API.',
    );
  }

  Future<void> _removeOccurrence(_OccurrenceRecord occurrence) async {
    final confirmed = await _confirmAction(
      title: 'Remover ocorrencia',
      message:
          'A ocorrencia sera marcada como removida, preservando auditoria.',
      confirmLabel: 'Remover',
    );

    if (!confirmed) {
      return;
    }

    await _runPeopleMutation(
      () => _repository.removeOccurrence(occurrence.publicId),
      successMessage: 'Ocorrencia removida logicamente.',
    );
  }

  Future<void> _openCreateAttachmentDialog(_PersonProfileData profile) async {
    final session = _runtimeData.session;
    if (session == null || session.userPublicId.isEmpty) {
      _showUnavailableAction();
      return;
    }

    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AttachmentCrudDialog(
        occurrences: profile.occurrences,
        ownerUserPublicId: session.userPublicId,
        allowedGroupKeys: session.audienceGroups,
      ),
    );

    if (body == null) {
      return;
    }

    await _runPeopleMutation(
      () => _repository.createAttachment(body),
      successMessage: 'Anexo registrado na API.',
    );
  }

  Future<void> _openEditAttachmentDialog(_AttachmentRecord attachment) async {
    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AttachmentCrudDialog.edit(initial: attachment),
    );

    if (body == null) {
      return;
    }

    await _runPeopleMutation(
      () => _repository.updateAttachment(attachment.publicId, body),
      successMessage: 'Anexo atualizado na API.',
    );
  }

  Future<void> _removeAttachment(_AttachmentRecord attachment) async {
    final confirmed = await _confirmAction(
      title: 'Remover anexo',
      message:
          'O anexo sera removido logicamente e deixara de aparecer na ficha.',
      confirmLabel: 'Remover',
    );

    if (!confirmed) {
      return;
    }

    await _runPeopleMutation(
      () => _repository.removeAttachment(attachment.publicId),
      successMessage: 'Anexo removido logicamente.',
    );
  }

  Future<bool> _confirmAction({
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

  void _showUnavailableAction() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Acao disponivel apenas com dados reais da API.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _runtimeData.data;
    final visibleItems = _filterPeopleItems(data.items);
    final fallbackIndex = data.items.isEmpty
        ? -1
        : min(max(widget.selectedIndex, 0), data.items.length - 1);
    final preferredItem = fallbackIndex < 0 ? null : data.items[fallbackIndex];
    final selectedItem = visibleItems.isEmpty
        ? null
        : visibleItems.contains(preferredItem)
        ? preferredItem
        : visibleItems.first;
    final selectedOriginalIndex = selectedItem == null
        ? null
        : data.items.indexOf(selectedItem);
    final profile = selectedItem?.personProfile;
    final visibleAttachments = selectedItem == null
        ? <_AttachmentRecord>[]
        : selectedItem.attachments
              .where(
                (attachment) =>
                    attachment.accessPolicy.canViewerRead(widget.viewerProfile),
              )
              .toList();
    final visibleNotes = selectedItem == null
        ? <_SensitiveNoteTag>[]
        : ([...selectedItem.sensitiveNotes]
            ..retainWhere(
              (note) => note.accessPolicy.canViewerRead(widget.viewerProfile),
            )
            ..sort((left, right) => left.sortOrder.compareTo(right.sortOrder)));
    final sensitiveSections = _buildSensitiveSections(visibleNotes);

    return Column(
      children: [
        _Panel(
          padding: const EdgeInsets.all(24),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 18,
            spacing: 18,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'People',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Ficha individual baseada em identidade, employment links, sensitive information e attachments, sem quebrar o envelope atual de acesso e compartilhamento.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: _mutedColor),
                    ),
                    const SizedBox(height: 18),
                    _ContextSearchField(
                      controller: _searchController,
                      hintText: data.searchHint,
                      accent: _tealColor,
                      enabled: !_runtimeData.isLoading,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => setState(() {}),
                      onClear: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      onSearch: () => setState(() {}),
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: DropdownButtonFormField<int>(
                  initialValue: selectedOriginalIndex,
                  decoration: InputDecoration(
                    labelText: 'Employee record',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: _lineColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: _lineColor),
                    ),
                  ),
                  items: [
                    for (final item in visibleItems)
                      DropdownMenuItem<int>(
                        value: data.items.indexOf(item),
                        child: Text(
                          '${item.title} - ${item.publicId}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      widget.onSelectItem(value);
                    }
                  },
                ),
              ),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: _runtimeData.isLoading
                        ? null
                        : _openCreatePersonDialog,
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: const Text('Nova pessoa'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _runtimeData.isLoading || selectedItem == null
                        ? null
                        : () => _openEditPersonDialog(selectedItem),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _runtimeData.isLoading || selectedItem == null
                        ? null
                        : () => _removePerson(selectedItem),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Remover'),
                  ),
                  IconButton.outlined(
                    tooltip: 'Sincronizar People',
                    onPressed: _runtimeData.isLoading ? null : _loadPeopleData,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (selectedItem != null && profile != null) ...[
                    _Tag(
                      label: selectedItem.publicId,
                      icon: Icons.badge_outlined,
                      color: _slateColor,
                      background: _slateColor.withValues(alpha: 0.12),
                    ),
                    _Tag(
                      label: profile.statusLabel,
                      icon: Icons.circle,
                      color: profile.statusColor,
                      background: profile.statusColor.withValues(alpha: 0.12),
                    ),
                    _Tag(
                      label:
                          '${profile.employmentLinks.length} employment links',
                      icon: Icons.link_rounded,
                      color: _tealColor,
                      background: _tealColor.withValues(alpha: 0.12),
                    ),
                  ],
                  _Tag(
                    label: '${visibleNotes.length} sensitive tags visible',
                    icon: widget.viewerProfile.canViewSensitive
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: _amberColor,
                    background: _amberColor.withValues(alpha: 0.12),
                  ),
                  _Tag(
                    label: '${visibleAttachments.length} attachments visible',
                    icon: Icons.attach_file_rounded,
                    color: _roseColor,
                    background: _roseColor.withValues(alpha: 0.12),
                  ),
                  _Tag(
                    label: _runtimeData.sourceLabel,
                    icon: _runtimeData.isLoading
                        ? Icons.sync_rounded
                        : _runtimeData.isLive
                        ? Icons.cloud_done_outlined
                        : Icons.storage_outlined,
                    color: _runtimeData.isLive ? _tealColor : _slateColor,
                    background: (_runtimeData.isLive ? _tealColor : _slateColor)
                        .withValues(alpha: 0.12),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_runtimeData.errorMessage != null) ...[
          const SizedBox(height: 12),
          _PeopleRuntimeNotice(
            message: _runtimeData.errorMessage!,
            onRetry: _loadPeopleData,
          ),
        ],
        if (selectedItem == null || profile == null) ...[
          const SizedBox(height: 24),
          const _Panel(child: _EntityEmptyState()),
        ] else ...[
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 1540;
              final medium = constraints.maxWidth >= 1120;
              final profilePanel = _PeopleProfilePanel(
                item: selectedItem,
                profile: profile,
              );
              final linksPanel = _EmploymentLinksPanel(
                profile: profile,
                onAddLink: _runtimeData.isLoading
                    ? null
                    : () => _openCreateEmploymentLinkDialog(selectedItem),
              );
              final sideColumn = _PeopleSideColumn(
                viewerProfile: widget.viewerProfile,
                item: selectedItem,
                profile: profile,
                sections: sensitiveSections,
                attachments: visibleAttachments,
                onAddOccurrence: () =>
                    _openCreateOccurrenceDialog(selectedItem),
                onEditOccurrence: (occurrence) =>
                    _openEditOccurrenceDialog(selectedItem, occurrence),
                onRemoveOccurrence: _removeOccurrence,
                onAddAttachment: () => _openCreateAttachmentDialog(profile),
                onEditAttachment: _openEditAttachmentDialog,
                onRemoveAttachment: _removeAttachment,
              );

              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: profilePanel),
                    const SizedBox(width: 24),
                    Expanded(flex: 6, child: linksPanel),
                    const SizedBox(width: 24),
                    Expanded(flex: 3, child: sideColumn),
                  ],
                );
              }

              if (medium) {
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: profilePanel),
                        const SizedBox(width: 24),
                        Expanded(flex: 7, child: linksPanel),
                      ],
                    ),
                    const SizedBox(height: 24),
                    sideColumn,
                  ],
                );
              }

              return Column(
                children: [
                  profilePanel,
                  const SizedBox(height: 24),
                  linksPanel,
                  const SizedBox(height: 24),
                  sideColumn,
                ],
              );
            },
          ),
        ],
      ],
    );
  }

  List<_EntityItem> _filterPeopleItems(List<_EntityItem> items) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return items;
    }

    return items
        .where((item) {
          final profile = item.personProfile;
          final haystack = [
            item.publicId,
            item.title,
            item.subtitle,
            item.meta,
            item.status,
            profile?.roleTitle,
            profile?.managerName,
            profile?.managerRole,
            profile?.teamLabel,
            profile?.departmentLabel,
            profile?.timelineSummary,
            profile?.crudSnapshot?.email,
            profile?.crudSnapshot?.cpf,
            profile?.crudSnapshot?.phone,
            for (final field
                in profile?.profileFields ?? const <_PersonInfoField>[])
              field.value,
            for (final link
                in profile?.employmentLinks ?? const <_EmploymentLinkRecord>[])
              '${link.contractLabel} ${link.contractPublicId} ${link.companyName}',
          ].whereType<String>().join(' ').toLowerCase();

          return haystack.contains(query);
        })
        .toList(growable: false);
  }
}

class _PeopleRuntimeNotice extends StatelessWidget {
  const _PeopleRuntimeNotice({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: _Panel(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: _amberColor,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Tentar novamente'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PeopleProfilePanel extends StatelessWidget {
  const _PeopleProfilePanel({required this.item, required this.profile});

  final _EntityItem item;
  final _PersonProfileData profile;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert_rounded),
              color: _mutedColor,
            ),
          ),
          Center(
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    item.color.withValues(alpha: 0.30),
                    const Color(0xFFE7EDF1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: item.color.withValues(alpha: 0.28),
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _initialsFor(item.title),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: 54,
                  letterSpacing: -2.2,
                  color: _inkColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            item.title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontSize: 42,
              letterSpacing: -1.8,
              height: 1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            profile.roleTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: item.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: profile.statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 12, color: profile.statusColor),
                const SizedBox(width: 10),
                Text(
                  profile.statusLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: profile.statusColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: _lineColor),
          const SizedBox(height: 18),
          for (final field in profile.profileFields) ...[
            _ProfileFieldRow(field: field),
            const SizedBox(height: 18),
          ],
          const SizedBox(height: 8),
          const Divider(color: _lineColor),
          const SizedBox(height: 24),
          Text('Manager', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: _slateColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _initialsFor(profile.managerName),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.managerName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.managerRole,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _PeopleMetaBlock(
                  icon: Icons.groups_outlined,
                  label: 'Team',
                  value: profile.teamLabel,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _PeopleMetaBlock(
                  icon: Icons.domain_outlined,
                  label: 'Department',
                  value: profile.departmentLabel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileFieldRow extends StatelessWidget {
  const _ProfileFieldRow({required this.field});

  final _PersonInfoField field;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(field.icon, color: _mutedColor, size: 24),
        const SizedBox(width: 14),
        SizedBox(
          width: 128,
          child: Text(
            field.label,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: _mutedColor),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            field.value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}

class _PeopleMetaBlock extends StatelessWidget {
  const _PeopleMetaBlock({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _lineColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _mutedColor),
          const SizedBox(height: 12),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: _mutedColor),
          ),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _EmploymentLinksPanel extends StatefulWidget {
  const _EmploymentLinksPanel({required this.profile, required this.onAddLink});

  final _PersonProfileData profile;
  final VoidCallback? onAddLink;

  @override
  State<_EmploymentLinksPanel> createState() => _EmploymentLinksPanelState();
}

class _EmploymentLinksPanelState extends State<_EmploymentLinksPanel> {
  bool _showFullHistory = false;

  @override
  Widget build(BuildContext context) {
    final links = widget.profile.employmentLinks;
    final canCollapse = links.length > 3;
    final visibleLinks = canCollapse && !_showFullHistory
        ? links.take(3).toList()
        : links;

    return _Panel(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 16,
            spacing: 16,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.link_rounded, size: 34, color: _slateColor),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Employment Links',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(fontSize: 32),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.profile.timelineSummary,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: _mutedColor),
                      ),
                    ],
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: widget.onAddLink,
                icon: const Icon(Icons.add_link_rounded),
                label: const Text('Vincular contrato'),
              ),
            ],
          ),
          const SizedBox(height: 28),
          for (final entry in visibleLinks.indexed) ...[
            _EmploymentTimelineEntry(
              record: entry.$2,
              isLast: entry.$1 == visibleLinks.length - 1,
            ),
            const SizedBox(height: 18),
          ],
          if (canCollapse)
            Align(
              alignment: Alignment.center,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _showFullHistory = !_showFullHistory;
                  });
                },
                icon: Icon(
                  _showFullHistory
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                ),
                label: Text(
                  _showFullHistory
                      ? 'Hide Earlier History'
                      : 'Show Earlier History',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmploymentTimelineEntry extends StatelessWidget {
  const _EmploymentTimelineEntry({required this.record, required this.isLast});

  final _EmploymentLinkRecord record;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 128,
          child: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Text(
              record.periodLabel,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: record.isCurrent ? _tealColor : _mutedColor,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 44,
          child: Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: record.isCurrent
                      ? record.accent.withValues(alpha: 0.14)
                      : Colors.white,
                  border: Border.all(
                    color: record.isCurrent ? record.accent : _lineColor,
                    width: 3,
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 170,
                  color: record.isCurrent
                      ? record.accent.withValues(alpha: 0.55)
                      : _lineColor,
                ),
            ],
          ),
        ),
        const SizedBox(width: 18),
        Expanded(child: _EmploymentLinkCard(record: record)),
      ],
    );
  }
}

class _EmploymentLinkCard extends StatelessWidget {
  const _EmploymentLinkCard({required this.record});

  final _EmploymentLinkRecord record;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _lineColor),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: record.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(22),
                ),
                alignment: Alignment.center,
                child: Text(
                  record.brandMonogram,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: record.accent,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.companyName,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(fontSize: 26),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        Text(
                          record.roleTitle,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        if (record.linkStatusLabel.isNotEmpty)
                          _Tag(
                            label: record.linkStatusLabel,
                            icon: record.linkStatusLabel == 'encerrado'
                                ? Icons.event_busy_outlined
                                : record.linkStatusLabel == 'vencido'
                                ? Icons.warning_amber_rounded
                                : Icons.verified_outlined,
                            color: record.accent,
                            background: record.accent.withValues(alpha: 0.12),
                          ),
                        if (record.contractPublicId.isNotEmpty)
                          _Tag(
                            label: record.contractPublicId,
                            icon: Icons.description_outlined,
                            color: _slateColor,
                            background: _slateColor.withValues(alpha: 0.12),
                          ),
                        if (record.isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _tealColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Current',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: _tealColor),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('View Details'),
                  ),
                  const SizedBox(height: 12),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _mutedColor,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: _lineColor),
          const SizedBox(height: 16),
          Wrap(
            spacing: 26,
            runSpacing: 14,
            children: [
              _EmploymentMetaLine(
                icon: Icons.calendar_month_outlined,
                value: record.fullDateLabel,
              ),
              if (record.contractLabel.isNotEmpty)
                _EmploymentMetaLine(
                  icon: Icons.description_outlined,
                  value: record.contractLabel,
                ),
              if (record.contractStatusLabel.isNotEmpty)
                _EmploymentMetaLine(
                  icon: Icons.fact_check_outlined,
                  value: 'Contrato ${record.contractStatusLabel}',
                ),
              _EmploymentMetaLine(
                icon: Icons.location_on_outlined,
                value: record.locationLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmploymentMetaLine extends StatelessWidget {
  const _EmploymentMetaLine({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _mutedColor, size: 24),
        const SizedBox(width: 12),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: _mutedColor),
        ),
      ],
    );
  }
}

class _PeopleSideColumn extends StatelessWidget {
  const _PeopleSideColumn({
    required this.viewerProfile,
    required this.item,
    required this.profile,
    required this.sections,
    required this.attachments,
    required this.onAddOccurrence,
    required this.onEditOccurrence,
    required this.onRemoveOccurrence,
    required this.onAddAttachment,
    required this.onEditAttachment,
    required this.onRemoveAttachment,
  });

  final _ViewerAccessProfile viewerProfile;
  final _EntityItem item;
  final _PersonProfileData profile;
  final List<_SensitiveSectionGroup> sections;
  final List<_AttachmentRecord> attachments;
  final VoidCallback onAddOccurrence;
  final ValueChanged<_OccurrenceRecord> onEditOccurrence;
  final ValueChanged<_OccurrenceRecord> onRemoveOccurrence;
  final VoidCallback onAddAttachment;
  final ValueChanged<_AttachmentRecord> onEditAttachment;
  final ValueChanged<_AttachmentRecord> onRemoveAttachment;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _OccurrencesPanel(
          occurrences: profile.occurrences,
          onAdd: onAddOccurrence,
          onEdit: onEditOccurrence,
          onRemove: onRemoveOccurrence,
        ),
        const SizedBox(height: 18),
        _SensitiveInformationPanel(
          viewerProfile: viewerProfile,
          sections: sections,
        ),
        const SizedBox(height: 18),
        _AttachmentsPanel(
          viewerProfile: viewerProfile,
          item: item,
          attachments: attachments,
          occurrences: profile.occurrences,
          onAdd: onAddAttachment,
          onEdit: onEditAttachment,
          onRemove: onRemoveAttachment,
        ),
      ],
    );
  }
}

class _OccurrencesPanel extends StatelessWidget {
  const _OccurrencesPanel({
    required this.occurrences,
    required this.onAdd,
    required this.onEdit,
    required this.onRemove,
  });

  final List<_OccurrenceRecord> occurrences;
  final VoidCallback onAdd;
  final ValueChanged<_OccurrenceRecord> onEdit;
  final ValueChanged<_OccurrenceRecord> onRemove;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.event_note_outlined,
                color: _slateColor,
                size: 30,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Ocorrencias',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              OutlinedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Nova'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: _lineColor),
          if (occurrences.isEmpty) ...[
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFB),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _lineColor),
              ),
              child: Text(
                'Nenhuma ocorrencia registrada para esta pessoa.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
              ),
            ),
          ] else ...[
            const SizedBox(height: 4),
            for (final occurrence in occurrences) ...[
              _OccurrenceRow(
                occurrence: occurrence,
                onEdit: () => onEdit(occurrence),
                onRemove: () => onRemove(occurrence),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }
}

class _OccurrenceRow extends StatelessWidget {
  const _OccurrenceRow({
    required this.occurrence,
    required this.onEdit,
    required this.onRemove,
  });

  final _OccurrenceRecord occurrence;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final color = switch (occurrence.nature.toUpperCase()) {
      'POSITIVE' => _tealColor,
      'NEGATIVE' => _roseColor,
      _ => _amberColor,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _lineColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.timeline_rounded, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  occurrence.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  '${occurrence.type} | ${occurrence.severityLevel} | ${occurrence.occurredAtLabel}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
                ),
                if (occurrence.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    occurrence.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Editar ocorrencia',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Remover ocorrencia',
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
    );
  }
}

class _SensitiveInformationPanel extends StatelessWidget {
  const _SensitiveInformationPanel({
    required this.viewerProfile,
    required this.sections,
  });

  final _ViewerAccessProfile viewerProfile;
  final List<_SensitiveSectionGroup> sections;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: _slateColor, size: 30),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Sensitive Information',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Icon(
                viewerProfile.canViewSensitive
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: _mutedColor,
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: _lineColor),
          if (!viewerProfile.canViewSensitive || sections.isEmpty) ...[
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBF5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _lineColor),
              ),
              child: Text(
                viewerProfile.canViewSensitive
                    ? 'Nao ha tags sensiveis compartilhadas com este perfil para esta ficha.'
                    : 'Entrada publica ou perfil sem compartilhamento ativo. O front continua ocultando o conteudo protegido que a API nao liberar.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
              ),
            ),
          ] else ...[
            const SizedBox(height: 6),
            for (final section in sections)
              Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  splashColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: 14),
                  leading: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: section.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(
                    section.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final note in section.notes)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: section.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              note.label,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: section.color),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _AttachmentsPanel extends StatelessWidget {
  const _AttachmentsPanel({
    required this.viewerProfile,
    required this.item,
    required this.attachments,
    required this.occurrences,
    required this.onAdd,
    required this.onEdit,
    required this.onRemove,
  });

  final _ViewerAccessProfile viewerProfile;
  final _EntityItem item;
  final List<_AttachmentRecord> attachments;
  final List<_OccurrenceRecord> occurrences;
  final VoidCallback onAdd;
  final ValueChanged<_AttachmentRecord> onEdit;
  final ValueChanged<_AttachmentRecord> onRemove;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.attach_file_rounded,
                color: _slateColor,
                size: 30,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Attachments',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              OutlinedButton.icon(
                onPressed: occurrences.isEmpty ? null : onAdd,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Novo'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: _lineColor),
          if (attachments.isEmpty) ...[
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFB),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _lineColor),
              ),
              child: Text(
                viewerProfile.canViewSensitive
                    ? 'Nenhum anexo compartilhado com este perfil para ${item.title}.'
                    : 'Sem login ou sem compartilhamento ativo: anexos protegidos permanecem ocultos.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
              ),
            ),
          ] else ...[
            const SizedBox(height: 4),
            for (final attachment in attachments) ...[
              _AttachmentRow(
                attachment: attachment,
                onEdit: attachment.canEdit ? () => onEdit(attachment) : null,
                onRemove: attachment.canDelete
                    ? () => onRemove(attachment)
                    : null,
              ),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }
}

class _AttachmentRow extends StatelessWidget {
  const _AttachmentRow({
    required this.attachment,
    required this.onEdit,
    required this.onRemove,
  });

  final _AttachmentRecord attachment;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final icon = _attachmentIconFor(attachment.title);
    final iconColor = _attachmentColorFor(attachment);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _lineColor),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  '${attachment.updatedAtLabel} - ${attachment.status}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                attachment.canDownload
                    ? Icons.download_rounded
                    : Icons.lock_outline_rounded,
                color: _mutedColor,
              ),
              IconButton(
                tooltip: 'Editar anexo',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Remover anexo',
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PersonCrudDialog extends StatefulWidget {
  const _PersonCrudDialog({this.initial});

  final _PersonCrudSnapshot? initial;

  @override
  State<_PersonCrudDialog> createState() => _PersonCrudDialogState();
}

class _PersonCrudDialogState extends State<_PersonCrudDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _cpf;
  late final TextEditingController _rg;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _birthDate;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _name = TextEditingController(text: initial?.name ?? '');
    _cpf = TextEditingController(text: initial?.cpf ?? '');
    _rg = TextEditingController(text: initial?.rg ?? '');
    _email = TextEditingController(text: initial?.email ?? '');
    _phone = TextEditingController(text: initial?.phone ?? '');
    _birthDate = TextEditingController(text: initial?.birthDateInput ?? '');
    _notes = TextEditingController(text: initial?.notes ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _cpf.dispose();
    _rg.dispose();
    _email.dispose();
    _phone.dispose();
    _birthDate.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.initial != null;

    return AlertDialog(
      title: Text(editing ? 'Editar pessoa' : 'Nova pessoa'),
      content: SizedBox(
        width: min(MediaQuery.sizeOf(context).width - 48, 560),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogTextField(
                  controller: _name,
                  label: 'Nome',
                  icon: Icons.person_outline_rounded,
                  required: true,
                ),
                _dialogTextField(
                  controller: _cpf,
                  label: 'CPF',
                  icon: Icons.badge_outlined,
                ),
                _dialogTextField(
                  controller: _rg,
                  label: 'RG',
                  icon: Icons.assignment_ind_outlined,
                ),
                _dialogTextField(
                  controller: _email,
                  label: 'Email',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                _dialogTextField(
                  controller: _phone,
                  label: 'Telefone',
                  icon: Icons.call_outlined,
                  keyboardType: TextInputType.phone,
                ),
                _dialogTextField(
                  controller: _birthDate,
                  label: 'Nascimento',
                  icon: Icons.cake_outlined,
                  hintText: 'yyyy-mm-dd',
                  dateLike: true,
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
          child: Text(editing ? 'Salvar' : 'Criar'),
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
        'cpf': _cpf.text,
        'rg': _rg.text,
        'email': _email.text,
        'phone': _phone.text,
        'birthDate': _dateInputToIso(_birthDate.text),
        'notes': _notes.text,
      }),
    );
  }
}

class _EmploymentLinkCrudDialog extends StatefulWidget {
  const _EmploymentLinkCrudDialog({
    required this.personPublicId,
    required this.lookups,
  });

  final String personPublicId;
  final _EmploymentLinkLookupData lookups;

  @override
  State<_EmploymentLinkCrudDialog> createState() =>
      _EmploymentLinkCrudDialogState();
}

class _EmploymentLinkCrudDialogState extends State<_EmploymentLinkCrudDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _type;
  late final TextEditingController _startsAt;
  late final TextEditingController _endsAt;
  late String _providerCompanyPublicId;
  late String _contractPublicId;
  late String _positionPublicId;
  late String _status;

  @override
  void initState() {
    super.initState();
    final initialContract = _firstUsableContract();
    _providerCompanyPublicId =
        initialContract?.providerCompanyPublicId ??
        (widget.lookups.providerCompanies.isEmpty
            ? ''
            : widget.lookups.providerCompanies.first.publicId);
    _contractPublicId = initialContract?.publicId ?? '';
    _positionPublicId = initialContract?.positions.isEmpty == false
        ? initialContract!.positions.first.publicId
        : '';
    _status = 'ACTIVE';
    _type = TextEditingController(text: 'CLT');
    _startsAt = TextEditingController(text: _todayInputDate());
    _endsAt = TextEditingController();
  }

  @override
  void dispose() {
    _type.dispose();
    _startsAt.dispose();
    _endsAt.dispose();
    super.dispose();
  }

  _EmploymentContractOption? _firstUsableContract() {
    for (final contract in widget.lookups.contracts) {
      if (contract.providerCompanyPublicId.isNotEmpty &&
          contract.positions.isNotEmpty) {
        return contract;
      }
    }
    for (final contract in widget.lookups.contracts) {
      if (contract.positions.isNotEmpty) {
        return contract;
      }
    }
    return widget.lookups.contracts.isEmpty
        ? null
        : widget.lookups.contracts.first;
  }

  List<_EmploymentContractOption> get _contractsForProvider {
    return widget.lookups.contracts
        .where(
          (contract) =>
              contract.providerCompanyPublicId == _providerCompanyPublicId,
        )
        .toList(growable: false);
  }

  _EmploymentContractOption? get _selectedContract {
    for (final contract in _contractsForProvider) {
      if (contract.publicId == _contractPublicId) {
        return contract;
      }
    }
    return null;
  }

  List<_EmploymentPositionOption> get _positionsForSelectedContract {
    return _selectedContract?.positions ?? const [];
  }

  @override
  Widget build(BuildContext context) {
    final contracts = _contractsForProvider;
    final positions = _positionsForSelectedContract;
    final providerValues = widget.lookups.providerCompanies
        .map((company) => company.publicId)
        .where((publicId) => publicId.isNotEmpty)
        .toList(growable: false);
    final providerLabels = {
      for (final company in widget.lookups.providerCompanies)
        company.publicId: company.label,
    };
    final contractValues = contracts
        .map((contract) => contract.publicId)
        .where((publicId) => publicId.isNotEmpty)
        .toList(growable: false);
    final contractLabels = {
      for (final contract in contracts)
        contract.publicId: '${contract.label} | ${contract.clientLabel}',
    };
    final positionValues = positions
        .map((position) => position.publicId)
        .where((publicId) => publicId.isNotEmpty)
        .toList(growable: false);
    final positionLabels = {
      for (final position in positions) position.publicId: position.label,
    };

    return AlertDialog(
      title: const Text('Vincular contrato'),
      content: SizedBox(
        width: min(MediaQuery.sizeOf(context).width - 48, 620),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogDropdown(
                  fieldKey: const ValueKey('employment-provider'),
                  label: 'Prestadora',
                  value: _providerCompanyPublicId,
                  icon: Icons.business_outlined,
                  values: providerValues,
                  labels: providerLabels,
                  onChanged: _selectProvider,
                ),
                _dialogDropdown(
                  fieldKey: ValueKey(
                    'employment-contract-$_providerCompanyPublicId',
                  ),
                  label: 'Contrato',
                  value: _contractPublicId,
                  icon: Icons.description_outlined,
                  values: contractValues,
                  labels: contractLabels,
                  onChanged: _selectContract,
                ),
                _dialogDropdown(
                  fieldKey: ValueKey('employment-position-$_contractPublicId'),
                  label: 'Posto',
                  value: _positionPublicId,
                  icon: Icons.work_outline_rounded,
                  values: positionValues,
                  labels: positionLabels,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _positionPublicId = value);
                    }
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: _dialogTextField(
                        controller: _type,
                        label: 'Tipo do vinculo',
                        icon: Icons.badge_outlined,
                        required: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dialogDropdown(
                        label: 'Status',
                        value: _status,
                        icon: Icons.verified_outlined,
                        values: const [
                          'ACTIVE',
                          'DISMISSED',
                          'PENDING',
                          'SUSPENDED',
                          'BLOCKED',
                        ],
                        labels: const {
                          'ACTIVE': 'Ativo',
                          'DISMISSED': 'Encerrado',
                          'PENDING': 'Pendente',
                          'SUSPENDED': 'Suspenso',
                          'BLOCKED': 'Bloqueado',
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
                Row(
                  children: [
                    Expanded(
                      child: _dialogTextField(
                        controller: _startsAt,
                        label: 'Inicio',
                        icon: Icons.calendar_month_outlined,
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
        FilledButton(onPressed: _submit, child: const Text('Vincular')),
      ],
    );
  }

  void _selectProvider(String? value) {
    if (value == null) {
      return;
    }

    final contracts = widget.lookups.contracts
        .where((contract) => contract.providerCompanyPublicId == value)
        .toList(growable: false);
    _EmploymentContractOption? contract;
    for (final item in contracts) {
      if (item.positions.isNotEmpty) {
        contract = item;
        break;
      }
    }
    contract ??= contracts.isEmpty ? null : contracts.first;

    setState(() {
      _providerCompanyPublicId = value;
      _contractPublicId = contract?.publicId ?? '';
      _positionPublicId = contract?.positions.isEmpty == false
          ? contract!.positions.first.publicId
          : '';
    });
  }

  void _selectContract(String? value) {
    if (value == null) {
      return;
    }

    _EmploymentContractOption? contract;
    for (final item in _contractsForProvider) {
      if (item.publicId == value) {
        contract = item;
        break;
      }
    }

    setState(() {
      _contractPublicId = value;
      _positionPublicId = contract?.positions.isEmpty == false
          ? contract!.positions.first.publicId
          : '';
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final startsAt = DateTime.tryParse(_startsAt.text.trim());
    final endsAt = DateTime.tryParse(_endsAt.text.trim());
    if (startsAt == null) {
      return;
    }
    if (endsAt != null && endsAt.isBefore(startsAt)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A data final nao pode ser anterior ao inicio.'),
        ),
      );
      return;
    }
    if (_status == 'DISMISSED' && endsAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe a data final para vinculo encerrado.'),
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      _cleanMutationBody({
        'personPublicId': widget.personPublicId,
        'providerCompanyPublicId': _providerCompanyPublicId,
        'contractPublicId': _contractPublicId,
        'positionPublicId': _positionPublicId,
        'type': _type.text,
        'status': _status,
        'startsAt': _dateInputToIso(_startsAt.text),
        'endsAt': _dateInputToIso(_endsAt.text),
      }),
    );
  }
}

class _OccurrenceCrudDialog extends StatefulWidget {
  const _OccurrenceCrudDialog({required this.personPublicId, this.initial});

  final String personPublicId;
  final _OccurrenceRecord? initial;

  @override
  State<_OccurrenceCrudDialog> createState() => _OccurrenceCrudDialogState();
}

class _OccurrenceCrudDialogState extends State<_OccurrenceCrudDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _type;
  late final TextEditingController _scope;
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _occurredAt;
  late final TextEditingController _severityLevel;
  late String _nature;
  late String _visibility;
  late bool _showInExecutivePanel;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _type = TextEditingController(text: initial?.type ?? 'REGISTRO');
    _scope = TextEditingController(text: initial?.scope ?? 'people-dossie');
    _title = TextEditingController(text: initial?.title ?? '');
    _description = TextEditingController(text: initial?.description ?? '');
    _occurredAt = TextEditingController(
      text: initial?.occurredAtInput ?? _todayInputDate(),
    );
    _severityLevel = TextEditingController(
      text: initial?.severityLevel ?? 'LOW',
    );
    _nature = initial?.nature ?? 'NEUTRAL';
    _visibility = initial?.visibility ?? 'INTERNAL';
    _showInExecutivePanel = initial?.showInExecutivePanel ?? false;
  }

  @override
  void dispose() {
    _type.dispose();
    _scope.dispose();
    _title.dispose();
    _description.dispose();
    _occurredAt.dispose();
    _severityLevel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.initial != null;

    return AlertDialog(
      title: Text(editing ? 'Editar ocorrencia' : 'Nova ocorrencia'),
      content: SizedBox(
        width: min(MediaQuery.sizeOf(context).width - 48, 600),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogTextField(
                  controller: _title,
                  label: 'Titulo',
                  icon: Icons.title_rounded,
                  required: true,
                ),
                _dialogTextField(
                  controller: _description,
                  label: 'Descricao',
                  icon: Icons.notes_outlined,
                  required: true,
                  minLines: 3,
                  maxLines: 5,
                ),
                Row(
                  children: [
                    Expanded(
                      child: _dialogTextField(
                        controller: _type,
                        label: 'Tipo',
                        icon: Icons.category_outlined,
                        required: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dialogTextField(
                        controller: _scope,
                        label: 'Escopo',
                        icon: Icons.account_tree_outlined,
                        required: true,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _dialogTextField(
                        controller: _occurredAt,
                        label: 'Data',
                        icon: Icons.calendar_month_outlined,
                        required: true,
                        hintText: 'yyyy-mm-dd',
                        dateLike: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dialogTextField(
                        controller: _severityLevel,
                        label: 'Severidade',
                        icon: Icons.priority_high_rounded,
                        required: true,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _dialogDropdown(
                        label: 'Natureza',
                        value: _nature,
                        icon: Icons.timeline_rounded,
                        values: const ['POSITIVE', 'NEUTRAL', 'NEGATIVE'],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _nature = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dialogDropdown(
                        label: 'Visibilidade',
                        value: _visibility,
                        icon: Icons.visibility_outlined,
                        values: const ['INTERNAL', 'SENSITIVE', 'CRITICAL'],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _visibility = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _showInExecutivePanel,
                  onChanged: (value) {
                    setState(() => _showInExecutivePanel = value);
                  },
                  title: const Text('Painel executivo'),
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
          child: Text(editing ? 'Salvar' : 'Criar'),
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
        'personPublicId': widget.personPublicId,
        'type': _type.text,
        'scope': _scope.text,
        'nature': _nature,
        'title': _title.text,
        'description': _description.text,
        'occurredAt': _dateInputToIso(_occurredAt.text),
        'severityLevel': _severityLevel.text,
        'visibility': _visibility,
        'showInExecutivePanel': _showInExecutivePanel,
      }),
    );
  }
}

class _AttachmentCrudDialog extends StatefulWidget {
  const _AttachmentCrudDialog({
    required this.occurrences,
    required this.ownerUserPublicId,
    required this.allowedGroupKeys,
  }) : initial = null;

  const _AttachmentCrudDialog.edit({required this.initial})
    : occurrences = const [],
      ownerUserPublicId = '',
      allowedGroupKeys = const [];

  final List<_OccurrenceRecord> occurrences;
  final String ownerUserPublicId;
  final List<String> allowedGroupKeys;
  final _AttachmentRecord? initial;

  @override
  State<_AttachmentCrudDialog> createState() => _AttachmentCrudDialogState();
}

class _AttachmentCrudDialogState extends State<_AttachmentCrudDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fileName;
  late final TextEditingController _displayScope;
  late final TextEditingController _mimeType;
  late final TextEditingController _externalLink;
  late final TextEditingController _physicalLocation;
  late String _classification;
  late String _occurrencePublicId;

  bool get _editing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _fileName = TextEditingController(text: initial?.title ?? '');
    _displayScope = TextEditingController(
      text: initial?.displayScope ?? 'dossie-rh',
    );
    _mimeType = TextEditingController(text: initial?.mimeType ?? '');
    _externalLink = TextEditingController(text: initial?.externalLink ?? '');
    _physicalLocation = TextEditingController(
      text: initial?.physicalLocation ?? '',
    );
    _classification = _attachmentClassificationApiValue(
      initial?.classification ?? _AttachmentClassification.supportingReference,
    );
    _occurrencePublicId =
        initial?.occurrencePublicId ??
        (widget.occurrences.isEmpty ? '' : widget.occurrences.first.publicId);
  }

  @override
  void dispose() {
    _fileName.dispose();
    _displayScope.dispose();
    _mimeType.dispose();
    _externalLink.dispose();
    _physicalLocation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_editing ? 'Editar anexo' : 'Novo anexo'),
      content: SizedBox(
        width: min(MediaQuery.sizeOf(context).width - 48, 580),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_editing)
                  _dialogDropdown(
                    label: 'Ocorrencia',
                    value: _occurrencePublicId,
                    icon: Icons.event_note_outlined,
                    values: [
                      for (final occurrence in widget.occurrences)
                        occurrence.publicId,
                    ],
                    labels: {
                      for (final occurrence in widget.occurrences)
                        occurrence.publicId: occurrence.title,
                    },
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _occurrencePublicId = value);
                      }
                    },
                  ),
                _dialogTextField(
                  controller: _fileName,
                  label: 'Arquivo',
                  icon: Icons.insert_drive_file_outlined,
                  required: true,
                ),
                _dialogTextField(
                  controller: _displayScope,
                  label: 'Escopo',
                  icon: Icons.account_tree_outlined,
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
                _dialogTextField(
                  controller: _mimeType,
                  label: 'MIME',
                  icon: Icons.code_rounded,
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

    final baseBody = <String, Object?>{
      'displayScope': _displayScope.text,
      'classification': _classification,
      'fileName': _fileName.text,
      'mimeType': _mimeType.text,
      'externalLink': _externalLink.text,
      'physicalLocation': _physicalLocation.text,
      'visibleInContext': true,
    };

    if (!_editing) {
      baseBody.addAll({
        'occurrencePublicId': _occurrencePublicId,
        'ownerUserPublicId': widget.ownerUserPublicId,
        'allowedGroupKeys': widget.allowedGroupKeys,
      });
    }

    Navigator.of(context).pop(_cleanMutationBody(baseBody));
  }
}

List<_SensitiveSectionGroup> _buildSensitiveSections(
  List<_SensitiveNoteTag> notes,
) {
  final groups = <String, _SensitiveSectionGroup>{};

  for (final note in notes) {
    final title = switch (note.classification) {
      _SensitiveNoteClassification.behavioralSignal => 'Behavioral',
      _SensitiveNoteClassification.familyContext ||
      _SensitiveNoteClassification.personalContext ||
      _SensitiveNoteClassification.routineContext => 'Personal Context',
      _SensitiveNoteClassification.trainingOrSkill => 'Career & Skills',
      _SensitiveNoteClassification.operationalRisk => 'Operational Risk',
    };

    final color = switch (note.classification) {
      _SensitiveNoteClassification.behavioralSignal => const Color(0xFF4CAF50),
      _SensitiveNoteClassification.familyContext ||
      _SensitiveNoteClassification.personalContext ||
      _SensitiveNoteClassification.routineContext => const Color(0xFFF2A33A),
      _SensitiveNoteClassification.trainingOrSkill => const Color(0xFF8B6BD8),
      _SensitiveNoteClassification.operationalRisk => const Color(0xFF5E8DEE),
    };

    final existing = groups[title];
    if (existing == null) {
      groups[title] = _SensitiveSectionGroup(
        title: title,
        color: color,
        notes: [note],
      );
      continue;
    }

    groups[title] = _SensitiveSectionGroup(
      title: existing.title,
      color: existing.color,
      notes: [...existing.notes, note],
    );
  }

  final ordered = groups.values.toList()
    ..sort((left, right) => left.title.compareTo(right.title));
  return ordered;
}

IconData _attachmentIconFor(String title) {
  final lower = title.toLowerCase();
  if (lower.endsWith('.pdf')) {
    return Icons.picture_as_pdf_outlined;
  }
  if (lower.endsWith('.xlsx') ||
      lower.endsWith('.xls') ||
      lower.endsWith('.csv')) {
    return Icons.table_chart_outlined;
  }
  if (lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.png') ||
      lower.endsWith('.webp')) {
    return Icons.image_outlined;
  }
  return Icons.insert_drive_file_outlined;
}

Color _attachmentColorFor(_AttachmentRecord attachment) {
  final lower = attachment.title.toLowerCase();
  if (lower.endsWith('.pdf')) {
    return const Color(0xFFE8503A);
  }
  if (lower.endsWith('.xlsx') ||
      lower.endsWith('.xls') ||
      lower.endsWith('.csv')) {
    return const Color(0xFF2E9C4A);
  }
  return attachment.classification.color;
}

Widget _dialogTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  bool required = false,
  bool dateLike = false,
  String? hintText,
  int minLines = 1,
  int maxLines = 1,
  TextInputType? keyboardType,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (required && text.isEmpty) {
          return 'Campo obrigatorio';
        }
        if (dateLike && text.isNotEmpty && !_isValidInputDate(text)) {
          return 'Use yyyy-mm-dd';
        }
        return null;
      },
    ),
  );
}

Widget _dialogDropdown({
  Key? fieldKey,
  required String label,
  required String value,
  required IconData icon,
  required List<String> values,
  required ValueChanged<String?> onChanged,
  Map<String, String> labels = const {},
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DropdownButtonFormField<String>(
      key: fieldKey,
      initialValue: values.contains(value)
          ? value
          : values.isEmpty
          ? null
          : values.first,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      items: [
        for (final item in values)
          DropdownMenuItem<String>(
            value: item,
            child: Text(labels[item] ?? item, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: values.isEmpty ? null : onChanged,
      validator: (value) =>
          value == null || value.isEmpty ? 'Campo obrigatorio' : null,
    ),
  );
}

Map<String, dynamic> _cleanMutationBody(Map<String, Object?> raw) {
  final body = <String, dynamic>{};

  for (final entry in raw.entries) {
    final value = entry.value;
    if (value == null) {
      continue;
    }
    if (value is String) {
      final text = value.trim();
      if (text.isNotEmpty) {
        body[entry.key] = text;
      }
      continue;
    }
    if (value is List && value.isEmpty) {
      continue;
    }
    body[entry.key] = value;
  }

  return body;
}

String? _dateInputToIso(String value) {
  final text = value.trim();
  if (text.isEmpty) {
    return null;
  }
  final date = DateTime.tryParse(text);
  if (date == null) {
    return null;
  }
  return DateTime.utc(date.year, date.month, date.day).toIso8601String();
}

bool _isValidInputDate(String value) {
  final match = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value.trim());
  return match && DateTime.tryParse(value.trim()) != null;
}

String _todayInputDate() {
  final now = DateTime.now();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return '${now.year}-$month-$day';
}

String _attachmentClassificationApiValue(
  _AttachmentClassification classification,
) {
  return switch (classification) {
    _AttachmentClassification.formalDocument => 'FORMAL_DOCUMENT',
    _AttachmentClassification.sensitiveAttachment => 'SENSITIVE_ATTACHMENT',
    _AttachmentClassification.supportingReference => 'SUPPORTING_REFERENCE',
  };
}

String _peopleMutationErrorMessage(Object error) {
  if (error is ApiException) {
    return 'Falha na API (${error.code}): ${error.message}';
  }
  return 'Nao foi possivel concluir a operacao.';
}

class _SensitiveSectionGroup {
  const _SensitiveSectionGroup({
    required this.title,
    required this.color,
    required this.notes,
  });

  final String title;
  final Color color;
  final List<_SensitiveNoteTag> notes;
}

class _PersonProfileData {
  const _PersonProfileData({
    required this.roleTitle,
    required this.statusLabel,
    required this.statusColor,
    required this.profileFields,
    required this.managerName,
    required this.managerRole,
    required this.teamLabel,
    required this.departmentLabel,
    required this.timelineSummary,
    required this.employmentLinks,
    this.crudSnapshot,
    this.occurrences = const [],
  });

  final String roleTitle;
  final String statusLabel;
  final Color statusColor;
  final List<_PersonInfoField> profileFields;
  final String managerName;
  final String managerRole;
  final String teamLabel;
  final String departmentLabel;
  final String timelineSummary;
  final List<_EmploymentLinkRecord> employmentLinks;
  final _PersonCrudSnapshot? crudSnapshot;
  final List<_OccurrenceRecord> occurrences;
}

class _PersonCrudSnapshot {
  const _PersonCrudSnapshot({
    required this.publicId,
    required this.name,
    required this.cpf,
    required this.rg,
    required this.email,
    required this.phone,
    required this.birthDateInput,
    required this.notes,
  });

  final String publicId;
  final String name;
  final String cpf;
  final String rg;
  final String email;
  final String phone;
  final String birthDateInput;
  final String notes;
}

class _OccurrenceRecord {
  const _OccurrenceRecord({
    required this.publicId,
    required this.type,
    required this.scope,
    required this.nature,
    required this.title,
    required this.description,
    required this.occurredAtInput,
    required this.occurredAtLabel,
    required this.severityLevel,
    required this.visibility,
    required this.status,
    required this.attachmentCount,
    this.showInExecutivePanel = false,
  });

  final String publicId;
  final String type;
  final String scope;
  final String nature;
  final String title;
  final String description;
  final String occurredAtInput;
  final String occurredAtLabel;
  final String severityLevel;
  final String visibility;
  final String status;
  final int attachmentCount;
  final bool showInExecutivePanel;
}

class _PersonInfoField {
  const _PersonInfoField({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _EmploymentLinkRecord {
  const _EmploymentLinkRecord({
    required this.periodLabel,
    required this.companyName,
    required this.roleTitle,
    required this.fullDateLabel,
    required this.locationLabel,
    required this.brandMonogram,
    required this.accent,
    this.contractLabel = '',
    this.contractPublicId = '',
    this.contractStatusLabel = '',
    this.linkStatusLabel = '',
    this.isCurrent = false,
  });

  final String periodLabel;
  final String companyName;
  final String roleTitle;
  final String fullDateLabel;
  final String locationLabel;
  final String brandMonogram;
  final Color accent;
  final String contractLabel;
  final String contractPublicId;
  final String contractStatusLabel;
  final String linkStatusLabel;
  final bool isCurrent;
}
