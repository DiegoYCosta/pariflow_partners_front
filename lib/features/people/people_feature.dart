part of '../../app/app.dart';

class _PeopleWorkspace extends StatefulWidget {
  const _PeopleWorkspace({
    required this.viewerProfile,
    required this.selectedIndex,
    required this.onSelectItem,
    this.onFocusPersonChanged,
  });

  final _ViewerAccessProfile viewerProfile;
  final int selectedIndex;
  final ValueChanged<int> onSelectItem;
  final ValueChanged<String>? onFocusPersonChanged;

  @override
  State<_PeopleWorkspace> createState() => _PeopleWorkspaceState();
}

class _PeopleWorkspaceState extends State<_PeopleWorkspace> {
  final _PeopleApiRepository _repository = _PeopleApiRepository();
  late final TextEditingController _searchController;
  _PeopleRuntimeData _runtimeData = _PeopleRuntimeData.initial();
  String? _lastPublishedFocusPersonId;

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

  Future<void> _openEditVisualIdentityDialog(_EntityItem item) async {
    final changed = await _editVisualIdentityForItem(
      context: context,
      item: item,
      projectItems: _runtimeData.data.items,
    );
    if (changed && mounted) {
      await _loadPeopleData();
    }
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
    if (selectedItem != null &&
        _lastPublishedFocusPersonId != selectedItem.publicId) {
      _lastPublishedFocusPersonId = selectedItem.publicId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onFocusPersonChanged?.call(selectedItem.publicId);
        }
      });
    }
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
                        : () => _openEditVisualIdentityDialog(selectedItem),
                    icon: const Icon(Icons.palette_outlined),
                    label: const Text('Visual'),
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
              final wide = constraints.maxWidth >= 1320;
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
                        Expanded(flex: 5, child: sideColumn),
                      ],
                    ),
                    const SizedBox(height: 24),
                    linksPanel,
                  ],
                );
              }

              return Column(
                children: [
                  profilePanel,
                  const SizedBox(height: 24),
                  sideColumn,
                  const SizedBox(height: 24),
                  linksPanel,
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

class _FocusBoardHubPanel extends StatefulWidget {
  const _FocusBoardHubPanel({
    required this.viewerProfile,
    required this.item,
    required this.profile,
    required this.people,
    required this.notesController,
    required this.attachments,
    required this.sections,
    required this.calendarEntries,
    required this.docked,
    this.dockedFooterInitiallyCollapsed = false,
    required this.onAddCalendarEntry,
    required this.onCancelCalendarEntry,
    this.onDetach,
    this.onRefresh,
    this.detachLabel,
  });

  final _ViewerAccessProfile viewerProfile;
  final _EntityItem item;
  final _PersonProfileData profile;
  final List<_EntityItem> people;
  final _FocusBoardNotesController notesController;
  final List<_AttachmentRecord> attachments;
  final List<_SensitiveSectionGroup> sections;
  final List<_CalendarEntryRecord> calendarEntries;
  final bool docked;
  final bool dockedFooterInitiallyCollapsed;
  final ValueChanged<_FocusBoardTaskMode> onAddCalendarEntry;
  final ValueChanged<_CalendarEntryRecord> onCancelCalendarEntry;
  final VoidCallback? onDetach;
  final VoidCallback? onRefresh;
  final String? detachLabel;

  @override
  State<_FocusBoardHubPanel> createState() => _FocusBoardHubPanelState();
}

class _FocusBoardHubPanelState extends State<_FocusBoardHubPanel> {
  final Set<String> _selectedNoteIds = <String>{};
  bool _creatingQuickNote = false;
  bool _cardsHidden = false;
  String? _autofocusNoteId;
  String? _attentionNoteId;
  int _attentionPulse = 0;
  Timer? _attentionTimer;
  bool? _footerExpandedOverride;

  @override
  void initState() {
    super.initState();
    unawaited(widget.notesController.ensureLoaded());
  }

  @override
  void didUpdateWidget(covariant _FocusBoardHubPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notesController != widget.notesController) {
      unawaited(widget.notesController.ensureLoaded());
      _selectedNoteIds.clear();
    }
  }

  @override
  void dispose() {
    _attentionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photoAttachments = widget.attachments
        .where(_isImageAttachment)
        .take(4)
        .toList(growable: false);
    final documentAttachments = widget.attachments
        .where((attachment) => !_isImageAttachment(attachment))
        .take(4)
        .toList(growable: false);
    final visibleSensitiveNotes = [
      for (final section in widget.sections) ...section.notes,
    ].take(4).toList(growable: false);
    final upcomingEntries = widget.calendarEntries.where((entry) {
      final status = entry.status.toUpperCase();
      return status != 'CANCELED' && status != 'COMPLETED';
    }).toList()..sort((left, right) => left.startsAt.compareTo(right.startsAt));

    return AnimatedBuilder(
      animation: widget.notesController,
      builder: (context, _) {
        final boardNotes = widget.notesController.visibleNotes(
          widget.viewerProfile,
        );
        _selectedNoteIds.removeWhere(
          (id) => !boardNotes.any((note) => note.id == id),
        );

        if (widget.docked) {
          return _buildDocked(
            context,
            boardNotes: boardNotes,
            upcomingEntries: upcomingEntries,
          );
        }

        return _buildDetached(
          context,
          boardNotes: boardNotes,
          documentAttachments: documentAttachments,
          photoAttachments: photoAttachments,
          visibleSensitiveNotes: visibleSensitiveNotes,
        );
      },
    );
  }

  Widget _buildDocked(
    BuildContext context, {
    required List<_FocusBoardNote> boardNotes,
    required List<_CalendarEntryRecord> upcomingEntries,
  }) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: _paperColor),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : 720.0;
          final tightHeight = availableHeight < 640;
          final footerHeight = tightHeight
              ? (availableHeight * 0.30).clamp(132.0, 220.0).toDouble()
              : (availableHeight * 0.37).clamp(240.0, 360.0).toDouble();
          // Janela separada: calendario/compromissos/tarefas continuam
          // disponiveis para compatibilidade com futuras integracoes do
          // Focus Board, mas nascem recolhidos enquanto a API e avaliada.
          final footerExpanded =
              _footerExpandedOverride ?? !widget.dockedFooterInitiallyCollapsed;
          final effectiveFooterHeight = footerExpanded ? footerHeight : 38.0;
          final headerPadding = tightHeight
              ? const EdgeInsets.fromLTRB(8, 6, 8, 6)
              : const EdgeInsets.fromLTRB(10, 8, 10, 8);
          return Column(
            children: [
              Padding(
                padding: headerPadding,
                child: _buildHeader(context, compact: true),
              ),
              const Divider(height: 1, color: _lineColor),
              if (_selectedNoteIds.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                  child: _FocusBoardBulkBar(
                    selectedCount: _selectedNoteIds.length,
                    onClear: _clearSelection,
                    onComplete: _bulkComplete,
                    onTrash: _bulkTrash,
                  ),
                ),
              Expanded(child: _notesStage(boardNotes)),
              SizedBox(
                height: effectiveFooterHeight,
                child: footerExpanded
                    ? _footer(upcomingEntries)
                    : _collapsedFooterHandle(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetached(
    BuildContext context, {
    required List<_FocusBoardNote> boardNotes,
    required List<_AttachmentRecord> documentAttachments,
    required List<_AttachmentRecord> photoAttachments,
    required List<_SensitiveNoteTag> visibleSensitiveNotes,
  }) {
    return _Panel(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, compact: false),
          const SizedBox(height: 14),
          _HubAccessNotice(viewerProfile: widget.viewerProfile),
          const SizedBox(height: 14),
          if (_selectedNoteIds.isNotEmpty) ...[
            _FocusBoardBulkBar(
              selectedCount: _selectedNoteIds.length,
              onClear: _clearSelection,
              onComplete: _bulkComplete,
              onTrash: _bulkTrash,
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(height: 560, child: _notesStage(boardNotes)),
          const SizedBox(height: 10),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(top: 8),
              leading: const Icon(
                Icons.inventory_2_outlined,
                color: _deepTealColor,
              ),
              title: Text(
                'Contexto adicional',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: _inkColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              children: [
                _buildDetachedSupportSections(
                  documentAttachments: documentAttachments,
                  photoAttachments: photoAttachments,
                  visibleSensitiveNotes: visibleSensitiveNotes,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _notesStage(List<_FocusBoardNote> boardNotes) {
    return _FocusBoardNotesStage(
      notes: boardNotes,
      loading: widget.notesController.loading,
      selectedNoteIds: _selectedNoteIds,
      viewerProfile: widget.viewerProfile,
      cardsHidden: _cardsHidden,
      autofocusNoteId: _autofocusNoteId,
      attentionNoteId: _attentionNoteId,
      attentionPulse: _attentionPulse,
      onAddNote: _createSimpleNote,
      onTapNote: _handleNoteTap,
      onLongPressNote: _handleNoteLongPress,
      onToggleOwner: _toggleOwnerCompletion,
      onToggleAssignment: _toggleAssignmentCompletion,
      onUpdateText: _updateNoteText,
      onDiscardDraft: _discardDraft,
      onEditNote: _openEditNoteDialog,
      onTrashNote: _confirmMoveToTrash,
      onArchiveNote: _confirmMoveToArchive,
      onDeletePermanentlyNote: _confirmDeleteThreadSegmentPermanently,
      onRestoreNote: _restoreNote,
      onShowAudit: _showAudit,
      onReplicateNote: _replicateNote,
      onCloseNote: _closeNote,
    );
  }

  Widget _footer(List<_CalendarEntryRecord> upcomingEntries) {
    return _FocusBoardFixedFooter(
      calendarEntries: upcomingEntries,
      onAddCalendarEntry: widget.onAddCalendarEntry,
      onCancelCalendarEntry: widget.onCancelCalendarEntry,
    );
  }

  Widget _collapsedFooterHandle(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _lineColor)),
      ),
      child: Center(
        child: Tooltip(
          message: 'Mostrar calendario, compromissos e tarefas',
          child: InkWell(
            borderRadius: BorderRadius.circular(99),
            onTap: () => setState(() => _footerExpandedOverride = true),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 24,
                color: _mutedColor.withValues(alpha: 0.82),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, {required bool compact}) {
    if (compact) {
      return _buildCompactHeader(context);
    }

    final titleStyle = Theme.of(context).textTheme.headlineSmall;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _deepTealColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.dashboard_customize_outlined,
                color: _deepTealColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Focus Board',
                    style: titleStyle?.copyWith(
                      color: _inkColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.item.title} | ${widget.profile.roleTitle}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _mutedColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: _creatingQuickNote ? null : _createSimpleNote,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Nota'),
            ),
            IconButton.outlined(
              tooltip: 'Prioridades urgentes',
              onPressed: () => widget.notesController.setStatusFilter(
                _FocusBoardNoteStatusFilter.pending,
              ),
              icon: Badge.count(
                count: widget.notesController.urgentCount,
                isLabelVisible: widget.notesController.urgentCount > 0,
                backgroundColor: const Color(0xFFD81F2A),
                child: const Icon(Icons.priority_high_rounded),
              ),
            ),
            IconButton.outlined(
              tooltip: _cardsHidden
                  ? 'Mostrar cards de mensagens e compromissos'
                  : 'Ocultar cards de mensagens e compromissos',
              onPressed: () => setState(() => _cardsHidden = !_cardsHidden),
              icon: Icon(
                _cardsHidden
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
            _FocusBoardStatusFilterButton(controller: widget.notesController),
            IconButton.outlined(
              tooltip: widget.notesController.activeFilter.showTrash
                  ? 'Sair da lixeira de notas'
                  : 'Ver lixeira de notas (${widget.notesController.trashCount})',
              onPressed: _toggleTrashView,
              icon: Badge.count(
                count: widget.notesController.trashCount,
                isLabelVisible: widget.notesController.trashCount > 0,
                child: Icon(
                  Icons.recycling_rounded,
                  color: widget.notesController.activeFilter.showTrash
                      ? _tealColor
                      : null,
                ),
              ),
            ),
            IconButton.outlined(
              tooltip: widget.notesController.activeFilter.showArchive
                  ? 'Sair das notas arquivadas'
                  : 'Ver notas arquivadas (${widget.notesController.archiveCount})',
              onPressed: _toggleArchiveView,
              icon: Badge.count(
                count: widget.notesController.archiveCount,
                isLabelVisible: widget.notesController.archiveCount > 0,
                child: Icon(
                  Icons.archive_outlined,
                  color: widget.notesController.activeFilter.showArchive
                      ? _tealColor
                      : null,
                ),
              ),
            ),
            IconButton.outlined(
              tooltip: 'Filtros e perfis salvos',
              onPressed: _openFilterDialog,
              icon: const _FocusBoardEyeFilterIcon(),
            ),
            _FocusBoardSortButton(controller: widget.notesController),
            if (widget.onRefresh != null)
              IconButton(
                tooltip: 'Atualizar Focus Board',
                onPressed: widget.onRefresh,
                icon: const Icon(Icons.refresh_rounded),
              ),
            if (widget.onDetach != null)
              IconButton(
                tooltip: widget.detachLabel ?? 'Desacoplar Focus Board',
                onPressed: widget.onDetach,
                icon: Icon(
                  widget.detachLabel == null
                      ? Icons.open_in_full_rounded
                      : Icons.call_received_rounded,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactHeader(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilledButton.icon(
            onPressed: _creatingQuickNote ? null : _createSimpleNote,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Nota'),
          ),
          const SizedBox(width: 6),
          IconButton.outlined(
            tooltip: 'Prioridades urgentes',
            onPressed: () => widget.notesController.setStatusFilter(
              _FocusBoardNoteStatusFilter.pending,
            ),
            icon: Badge.count(
              count: widget.notesController.urgentCount,
              isLabelVisible: widget.notesController.urgentCount > 0,
              backgroundColor: const Color(0xFFD81F2A),
              child: const Icon(Icons.priority_high_rounded),
            ),
          ),
          IconButton.outlined(
            tooltip: _cardsHidden
                ? 'Mostrar cards de mensagens e compromissos'
                : 'Ocultar cards de mensagens e compromissos',
            onPressed: () => setState(() => _cardsHidden = !_cardsHidden),
            icon: Icon(
              _cardsHidden
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
          ),
          _FocusBoardStatusFilterButton(controller: widget.notesController),
          IconButton.outlined(
            tooltip: widget.notesController.activeFilter.showTrash
                ? 'Sair da lixeira de notas'
                : 'Ver lixeira de notas (${widget.notesController.trashCount})',
            onPressed: _toggleTrashView,
            icon: Badge.count(
              count: widget.notesController.trashCount,
              isLabelVisible: widget.notesController.trashCount > 0,
              child: Icon(
                Icons.recycling_rounded,
                color: widget.notesController.activeFilter.showTrash
                    ? _tealColor
                    : null,
              ),
            ),
          ),
          IconButton.outlined(
            tooltip: widget.notesController.activeFilter.showArchive
                ? 'Sair das notas arquivadas'
                : 'Ver notas arquivadas (${widget.notesController.archiveCount})',
            onPressed: _toggleArchiveView,
            icon: Badge.count(
              count: widget.notesController.archiveCount,
              isLabelVisible: widget.notesController.archiveCount > 0,
              child: Icon(
                Icons.archive_outlined,
                color: widget.notesController.activeFilter.showArchive
                    ? _tealColor
                    : null,
              ),
            ),
          ),
          IconButton.outlined(
            tooltip: 'Filtros e perfis salvos',
            onPressed: _openFilterDialog,
            icon: const _FocusBoardEyeFilterIcon(),
          ),
          _FocusBoardSortButton(controller: widget.notesController),
          if (widget.onRefresh != null)
            IconButton(
              tooltip: 'Atualizar Focus Board',
              onPressed: widget.onRefresh,
              icon: const Icon(Icons.refresh_rounded),
            ),
          if (widget.onDetach != null)
            IconButton(
              tooltip: widget.detachLabel ?? 'Desacoplar Focus Board',
              onPressed: widget.onDetach,
              icon: Icon(
                widget.detachLabel == null
                    ? Icons.open_in_full_rounded
                    : Icons.call_received_rounded,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetachedSupportSections({
    required List<_AttachmentRecord> documentAttachments,
    required List<_AttachmentRecord> photoAttachments,
    required List<_SensitiveNoteTag> visibleSensitiveNotes,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HubSectionHeader(
          icon: Icons.description_outlined,
          title: 'Documentos disponiveis',
          count: documentAttachments.length,
        ),
        const SizedBox(height: 10),
        if (documentAttachments.isEmpty)
          const _HubEmptyLine(
            icon: Icons.lock_outline_rounded,
            text: 'Sem documentos liberados para este perfil.',
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final attachment in documentAttachments)
                _HubAttachmentPreview(attachment: attachment),
            ],
          ),
        const SizedBox(height: 14),
        _HubSectionHeader(
          icon: Icons.photo_library_outlined,
          title: 'Fotos e imagens',
          count: photoAttachments.length,
        ),
        const SizedBox(height: 10),
        if (photoAttachments.isEmpty)
          const _HubEmptyLine(
            icon: Icons.image_not_supported_outlined,
            text: 'Sem imagens compartilhadas com este perfil.',
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final attachment in photoAttachments)
                _HubPhotoPreview(attachment: attachment),
            ],
          ),
        const SizedBox(height: 14),
        _HubSectionHeader(
          icon: Icons.psychology_alt_outlined,
          title: 'Detalhes contextuais',
          count: visibleSensitiveNotes.length,
        ),
        const SizedBox(height: 10),
        if (visibleSensitiveNotes.isEmpty)
          _HubEmptyLine(
            icon: widget.viewerProfile.canViewSensitive
                ? Icons.info_outline_rounded
                : Icons.visibility_off_outlined,
            text: widget.viewerProfile.canViewSensitive
                ? 'Sem detalhes contextuais liberados para esta ficha.'
                : 'Detalhes protegidos permanecem ocultos para este perfil.',
          )
        else
          for (final note in visibleSensitiveNotes) ...[
            _HubSensitiveNotePreview(note: note),
            const SizedBox(height: 8),
          ],
      ],
    );
  }

  void _handleNoteTap(_FocusBoardNote note) {
    if (_selectedNoteIds.isEmpty) {
      return;
    }
    setState(() {
      if (!_selectedNoteIds.add(note.id)) {
        _selectedNoteIds.remove(note.id);
      }
    });
  }

  void _handleNoteLongPress(_FocusBoardNote note) {
    setState(() {
      if (!_selectedNoteIds.add(note.id)) {
        _selectedNoteIds.remove(note.id);
      }
    });
  }

  void _clearSelection() {
    setState(_selectedNoteIds.clear);
  }

  Future<void> _createSimpleNote() async {
    if (_creatingQuickNote) {
      return;
    }
    final pendingDraft = _recentUntouchedQuickNote();
    if (pendingDraft != null) {
      FocusManager.instance.primaryFocus?.unfocus();
      await Future<void>.delayed(const Duration(milliseconds: 140));
      if (!mounted) {
        return;
      }
      final stillPendingDraft = _recentUntouchedQuickNote();
      if (stillPendingDraft != null) {
        _pulseExistingDraft(stillPendingDraft.id);
      }
      return;
    }
    setState(() => _creatingQuickNote = true);
    final note = await widget.notesController.createSimpleNote(
      viewerProfile: widget.viewerProfile,
    );
    if (mounted) {
      setState(() => _autofocusNoteId = note.id);
    }
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (mounted) {
      setState(() => _creatingQuickNote = false);
    }
  }

  _FocusBoardNote? _recentUntouchedQuickNote() {
    final now = DateTime.now();
    for (final note in widget.notesController.notes) {
      if (!note.isCreator(widget.viewerProfile) ||
          now.difference(note.createdAt) >=
              const Duration(milliseconds: 5500)) {
        continue;
      }
      if (_noteIsUntouchedQuickDraft(note)) {
        return note;
      }
    }
    return null;
  }

  bool _noteIsUntouchedQuickDraft(_FocusBoardNote note) {
    return note.isDraft &&
        note.title.trim() == 'Nova nota' &&
        note.description.trim().isEmpty &&
        note.lastEditedAt == null &&
        note.companyLabel.trim().isEmpty &&
        note.priority == _FocusBoardNotePriority.normal &&
        note.visibility == _FocusBoardNoteVisibility.private &&
        !note.completedByOwner &&
        !note.inTrash &&
        !note.hasAssignments;
  }

  void _pulseExistingDraft(String noteId) {
    _attentionTimer?.cancel();
    setState(() {
      _autofocusNoteId = noteId;
      _attentionNoteId = noteId;
      _attentionPulse += 1;
    });
    _attentionTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) {
        return;
      }
      setState(() {
        if (_attentionNoteId == noteId) {
          _attentionNoteId = null;
        }
      });
    });
  }

  Future<void> _openEditNoteDialog(_FocusBoardNote note) async {
    if (!note.isCreator(widget.viewerProfile)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Somente quem criou pode editar.')),
      );
      return;
    }
    final draft = await showDialog<_FocusBoardNoteDraft>(
      context: context,
      builder: (context) => _FocusBoardNoteDialog(
        assignmentOptions: _assignmentOptions(),
        initial: note,
        currentCompanyLabel: _currentCompanyLabel(),
      ),
    );
    if (draft == null) {
      return;
    }
    await widget.notesController.updateNote(
      id: note.id,
      draft: draft,
      viewerProfile: widget.viewerProfile,
    );
  }

  Future<void> _openFilterDialog() async {
    final result = await showDialog<_FocusBoardFilterDialogResult>(
      context: context,
      builder: (context) =>
          _FocusBoardFilterDialog(controller: widget.notesController),
    );
    if (result == null) {
      return;
    }
    if (result.reset) {
      await widget.notesController.resetFilters();
      return;
    }
    if (result.save) {
      await widget.notesController.saveFilterProfile(result.profile);
    } else {
      await widget.notesController.setActiveFilter(result.profile);
    }
  }

  Future<void> _toggleOwnerCompletion(_FocusBoardNote note) async {
    await widget.notesController.toggleOwnerCompletion(
      id: note.id,
      viewerProfile: widget.viewerProfile,
    );
  }

  Future<void> _toggleAssignmentCompletion(
    _FocusBoardNote note,
    _FocusBoardAssignment assignment,
  ) async {
    await widget.notesController.toggleAssignmentCompletion(
      noteId: note.id,
      assignmentId: assignment.id,
      viewerProfile: widget.viewerProfile,
    );
  }

  Future<_FocusBoardTextCommitResult> _updateNoteText(
    _FocusBoardNote note,
    String title,
    String description,
  ) async {
    final result = await widget.notesController.updateNoteText(
      id: note.id,
      title: title,
      description: description,
      viewerProfile: widget.viewerProfile,
    );
    if (!mounted) {
      return result;
    }
    switch (result) {
      case _FocusBoardTextCommitResult.draftSaved:
        _showFocusBoardSnack('Nota salva.');
        break;
      case _FocusBoardTextCommitResult.textUpdated:
        _showFocusBoardSnack('Nota atualizada.');
        break;
      case _FocusBoardTextCommitResult.none:
        break;
    }
    return result;
  }

  Future<void> _discardDraft(_FocusBoardNote note) async {
    final removed = await widget.notesController.discardDraft(
      id: note.id,
      viewerProfile: widget.viewerProfile,
    );
    if (!mounted || removed == null) {
      return;
    }
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Nota vazia descartada.'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () {
            unawaited(widget.notesController.restoreDiscardedDraft(removed));
          },
        ),
      ),
    );
  }

  void _showFocusBoardSnack(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _confirmMoveToTrash(_FocusBoardNote note) async {
    final warning = _trashWarningFor(note);
    if (warning != null) {
      final movesRootThread = !widget.notesController.isRootNote(note.id);
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            movesRootThread
                ? 'Mover encadeamento para lixeira?'
                : 'Mover nota para lixeira?',
          ),
          content: Text(warning),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Voltar'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.recycling_rounded, size: 18),
              label: const Text('Mover'),
            ),
          ],
        ),
      );
      if (confirmed != true) {
        return;
      }
    }
    await widget.notesController.moveToTrash(
      id: note.id,
      viewerProfile: widget.viewerProfile,
    );
  }

  Future<void> _confirmMoveToArchive(_FocusBoardNote note) async {
    final scopeWarning = _threadScopeWarningFor(note, 'arquivar');
    final pendingWarning = _threadPendingWarningFor(note, includeSingle: true);
    final warnings = <String>[];
    if (scopeWarning != null) {
      warnings.add(scopeWarning);
    }
    if (pendingWarning != null) {
      warnings.add(pendingWarning);
    }
    if (warnings.isNotEmpty) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            widget.notesController.isRootNote(note.id)
                ? 'Arquivar nota?'
                : 'Arquivar encadeamento?',
          ),
          content: Text(
            'Antes de mover para os arquivados, confirme se deseja continuar: ${warnings.join('; ')}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Voltar'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.archive_outlined, size: 18),
              label: const Text('Arquivar'),
            ),
          ],
        ),
      );
      if (confirmed != true) {
        return;
      }
    }
    await widget.notesController.moveToArchive(
      id: note.id,
      viewerProfile: widget.viewerProfile,
    );
  }

  String? _trashWarningFor(_FocusBoardNote note) {
    final linked = widget.notesController.fullThreadNotes(note.id);
    final pendingAssignments = linked
        .expand((entry) => entry.assignments)
        .where((assignment) => !assignment.completed)
        .map((assignment) => assignment.label)
        .toList(growable: false);
    final hasUserContent = linked.any(
      (entry) =>
          !entry.isComplete &&
          ((entry.title.trim().isNotEmpty &&
                  entry.title.trim() != 'Nova nota') ||
              entry.description.trim().isNotEmpty),
    );
    final warnings = <String>[];
    final scopeWarning = _threadScopeWarningFor(note, 'mover para a lixeira');
    if (scopeWarning != null) {
      warnings.add(scopeWarning);
    }
    if (hasUserContent) {
      warnings.add('ha conteudo vinculado ainda sem check de concluido');
    }
    if (pendingAssignments.isNotEmpty) {
      warnings.add(
        'ha replicas pendentes para: ${pendingAssignments.take(4).join(', ')}',
      );
    }
    final threadWarning = _threadPendingWarningFor(note, includeSingle: false);
    if (threadWarning != null) {
      warnings.add(threadWarning);
    }
    if (warnings.isEmpty) {
      return null;
    }
    return 'Antes de mover para a lixeira, confirme se deseja continuar: ${warnings.join('; ')}.';
  }

  String? _threadScopeWarningFor(_FocusBoardNote note, String actionLabel) {
    final linked = widget.notesController.fullThreadNotes(note.id);
    if (linked.isEmpty || linked.first.id == note.id) {
      return null;
    }
    final root = linked.first;
    final replies = linked.length - 1;
    return 'voce selecionou uma resposta; $actionLabel vai afetar a nota principal "${root.title}" e $replies resposta(s) vinculada(s)';
  }

  String? _threadPendingWarningFor(
    _FocusBoardNote note, {
    required bool includeSingle,
  }) {
    final linked = widget.notesController.fullThreadNotes(note.id);
    final pendingCount = linked.where((entry) => !entry.isComplete).length;
    if (pendingCount == 0 || (!includeSingle && linked.length <= 1)) {
      return null;
    }
    if (linked.length <= 1) {
      return 'a nota ainda esta sem check de concluido';
    }
    return 'o encadeamento vinculado tem ${linked.length} notas e $pendingCount ainda estao sem check de concluido';
  }

  Future<void> _confirmDeleteThreadSegmentPermanently(
    _FocusBoardNote note,
  ) async {
    if (widget.notesController.isRootNote(note.id)) {
      _showFocusBoardSnack(
        'Use a nota principal para mover o encadeamento para a lixeira.',
      );
      return;
    }
    final linked = widget.notesController.threadNotes(note.id);
    if (linked.isEmpty) {
      return;
    }
    final pendingCount = linked.where((entry) => !entry.isComplete).length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir resposta permanentemente?'),
        content: Text(
          'Esta acao remove ${linked.length} item(ns) deste trecho do encadeamento sem enviar para a lixeira.'
          '${pendingCount > 0 ? ' Ha $pendingCount item(ns) sem check de concluido.' : ''} Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Voltar'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.delete_forever_rounded, size: 18),
            label: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await widget.notesController.deleteThreadSegmentPermanently(
      id: note.id,
      viewerProfile: widget.viewerProfile,
    );
  }

  Future<void> _restoreNote(_FocusBoardNote note) async {
    if (note.inArchive && !note.inTrash) {
      await widget.notesController.restoreFromArchive(
        id: note.id,
        viewerProfile: widget.viewerProfile,
      );
      return;
    }
    await widget.notesController.restoreFromTrash(
      id: note.id,
      viewerProfile: widget.viewerProfile,
    );
  }

  Future<void> _closeNote(_FocusBoardNote note) async {
    final scopeWarning = _threadScopeWarningFor(note, 'encerrar');
    final pendingWarning = _threadPendingWarningFor(note, includeSingle: false);
    final warnings = <String>[];
    if (scopeWarning != null) {
      warnings.add(scopeWarning);
    }
    if (pendingWarning != null) {
      warnings.add(pendingWarning);
    }
    if (warnings.isNotEmpty) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Encerrar encadeamento?'),
          content: Text(
            'Esta acao marca a nota e suas respostas como concluidas. ${warnings.join('; ')}. Deseja continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Voltar'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
              label: const Text('Encerrar'),
            ),
          ],
        ),
      );
      if (confirmed != true) {
        return;
      }
    }
    await widget.notesController.closeNote(
      id: note.id,
      viewerProfile: widget.viewerProfile,
    );
  }

  Future<void> _replicateNote(_FocusBoardNote note) async {
    await widget.notesController.replicateNote(
      id: note.id,
      viewerProfile: widget.viewerProfile,
    );
  }

  Future<void> _bulkComplete() async {
    final ids = _selectedNoteIds.toList(growable: false);
    await widget.notesController.completeMany(
      ids: ids,
      viewerProfile: widget.viewerProfile,
    );
    _clearSelection();
  }

  Future<void> _bulkTrash() async {
    final notes = widget.notesController.notes
        .where((note) => _selectedNoteIds.contains(note.id))
        .toList(growable: false);
    final warnings = [
      for (final note in notes)
        if (_trashWarningFor(note) != null)
          '${note.title}: ${_trashWarningFor(note)!}',
    ];
    if (warnings.isNotEmpty) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Mover selecao para lixeira?'),
          content: Text(
            'A selecao contem pendencias:\n\n${warnings.take(4).join('\n\n')}\n\nDeseja continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Voltar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Mover selecao'),
            ),
          ],
        ),
      );
      if (confirmed != true) {
        return;
      }
    }
    await widget.notesController.moveManyToTrash(
      ids: _selectedNoteIds,
      viewerProfile: widget.viewerProfile,
    );
    _clearSelection();
  }

  Future<void> _toggleTrashView() async {
    final active = widget.notesController.activeFilter;
    final showTrash = !active.showTrash;
    await widget.notesController.setActiveFilter(
      active.copyWith(
        id: showTrash ? 'trash-view' : 'generic',
        name: showTrash ? 'Lixeira' : 'Perfil generico',
        showTrash: showTrash,
        showArchive: false,
      ),
    );
  }

  Future<void> _toggleArchiveView() async {
    final active = widget.notesController.activeFilter;
    final showArchive = !active.showArchive;
    await widget.notesController.setActiveFilter(
      active.copyWith(
        id: showArchive ? 'archive-view' : 'generic',
        name: showArchive ? 'Arquivadas' : 'Perfil generico',
        showTrash: false,
        showArchive: showArchive,
      ),
    );
  }

  Future<void> _showAudit(_FocusBoardNote note) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _FocusBoardAuditDialog(note: note),
    );
  }

  String _currentCompanyLabel() {
    final current = widget.profile.employmentLinks
        .where((link) => link.isCurrent)
        .firstOrNull;
    if (current != null && current.companyName.trim().isNotEmpty) {
      return current.companyName.trim();
    }
    return widget.profile.employmentLinks.isEmpty
        ? ''
        : widget.profile.employmentLinks.first.companyName.trim();
  }

  List<_FocusBoardAssignmentOption> _assignmentOptions() {
    final optionsByKey = <String, _FocusBoardAssignmentOption>{};
    for (final person in widget.people) {
      if (person.publicId.trim().isEmpty) {
        continue;
      }
      final profile = person.personProfile;
      optionsByKey['person:${person.publicId}'] = _FocusBoardAssignmentOption(
        type: _FocusBoardAssignmentType.person,
        id: person.publicId,
        label: person.title,
        subtitle: [
          if (profile?.roleTitle.trim().isNotEmpty == true) profile!.roleTitle,
          if (profile?.teamLabel.trim().isNotEmpty == true) profile!.teamLabel,
        ].join(' | '),
      );
      for (final link
          in profile?.employmentLinks ?? const <_EmploymentLinkRecord>[]) {
        final companyName = link.companyName.trim();
        if (companyName.isNotEmpty) {
          final id = companyName.toLowerCase();
          optionsByKey['company:$id'] = _FocusBoardAssignmentOption(
            type: _FocusBoardAssignmentType.company,
            id: id,
            label: companyName,
            subtitle: 'Empresa vinculada via API',
          );
        }
        final contractKey = link.contractPublicId.trim().isNotEmpty
            ? link.contractPublicId.trim()
            : link.contractLabel.trim();
        if (contractKey.isNotEmpty) {
          final id = contractKey.toLowerCase();
          optionsByKey['contract:$id'] = _FocusBoardAssignmentOption(
            type: _FocusBoardAssignmentType.contract,
            id: id,
            label: link.contractLabel.trim().isEmpty
                ? contractKey
                : link.contractLabel.trim(),
            subtitle: companyName.isEmpty
                ? 'Contrato vinculado via API'
                : 'Contrato | $companyName',
          );
        }
      }
    }
    for (final group in widget.viewerProfile.groups) {
      optionsByKey['group:${group.key}'] = _FocusBoardAssignmentOption(
        type: _FocusBoardAssignmentType.group,
        id: group.key,
        label: group.label,
        subtitle: 'Grupo do perfil autenticado',
      );
    }
    final options = optionsByKey.values.toList(growable: false)
      ..sort((left, right) {
        final typeCompare = left.type.index.compareTo(right.type.index);
        if (typeCompare != 0) {
          return typeCompare;
        }
        return left.label.toLowerCase().compareTo(right.label.toLowerCase());
      });
    return options;
  }
}

// ignore: unused_element
class _LegacyFocusBoardHubPanel extends StatelessWidget {
  // ignore: unused_element_parameter
  const _LegacyFocusBoardHubPanel({
    required this.viewerProfile,
    required this.item,
    required this.profile,
    required this.attachments,
    required this.sections,
    required this.calendarEntries,
    required this.onAddCalendarEntry,
    required this.onCancelCalendarEntry,
    // ignore: unused_element_parameter
    this.onDetach,
    // ignore: unused_element_parameter
    this.onRefresh,
    // ignore: unused_element_parameter
    this.detachLabel,
  });

  final _ViewerAccessProfile viewerProfile;
  final _EntityItem item;
  final _PersonProfileData profile;
  final List<_AttachmentRecord> attachments;
  final List<_SensitiveSectionGroup> sections;
  final List<_CalendarEntryRecord> calendarEntries;
  final VoidCallback onAddCalendarEntry;
  final ValueChanged<_CalendarEntryRecord> onCancelCalendarEntry;
  final VoidCallback? onDetach;
  final VoidCallback? onRefresh;
  final String? detachLabel;

  @override
  Widget build(BuildContext context) {
    final photoAttachments = attachments
        .where(_isImageAttachment)
        .take(4)
        .toList(growable: false);
    final documentAttachments = attachments
        .where((attachment) => !_isImageAttachment(attachment))
        .take(4)
        .toList(growable: false);
    final visibleNotes = [
      for (final section in sections) ...section.notes,
    ].take(4).toList(growable: false);
    final upcomingEntries = calendarEntries.where((entry) {
      final status = entry.status.toUpperCase();
      return status != 'CANCELED' && status != 'COMPLETED';
    }).toList()..sort((left, right) => left.startsAt.compareTo(right.startsAt));

    return _Panel(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _deepTealColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.dashboard_customize_outlined,
                  color: _deepTealColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Focus Board',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Lembre-se que pode haver itens não disponíveis para serem vistos por seu usuário: ${item.title} | ${profile.roleTitle}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _mutedColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: onAddCalendarEntry,
                icon: const Icon(Icons.add_alert_outlined, size: 18),
                label: const Text('Lembrete'),
              ),
              if (onRefresh != null) ...[
                const SizedBox(width: 6),
                IconButton(
                  tooltip: 'Atualizar Focus Board',
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
              if (onDetach != null) ...[
                const SizedBox(width: 2),
                IconButton(
                  tooltip: detachLabel ?? 'Desacoplar Focus Board',
                  onPressed: onDetach,
                  icon: Icon(
                    detachLabel == null
                        ? Icons.open_in_full_rounded
                        : Icons.call_received_rounded,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          _HubAccessNotice(viewerProfile: viewerProfile),
          const SizedBox(height: 16),
          _HubSectionHeader(
            icon: Icons.notification_important_outlined,
            title: 'Lembretes e compromissos',
            count: upcomingEntries.length,
          ),
          const SizedBox(height: 10),
          if (upcomingEntries.isEmpty)
            const _HubEmptyLine(
              icon: Icons.event_available_outlined,
              text: 'Nenhum lembrete ou compromisso registrado neste recorte.',
            )
          else
            for (final entry in upcomingEntries.take(4)) ...[
              _HubReminderTile(
                entry: entry,
                onCancel: entry.canCancel
                    ? () => onCancelCalendarEntry(entry)
                    : null,
              ),
              const SizedBox(height: 8),
            ],
          const SizedBox(height: 14),
          _HubSectionHeader(
            icon: Icons.description_outlined,
            title: 'Documentos disponíveis',
            count: documentAttachments.length,
          ),
          const SizedBox(height: 10),
          if (documentAttachments.isEmpty)
            const _HubEmptyLine(
              icon: Icons.lock_outline_rounded,
              text: 'Sem documentos liberados para este perfil.',
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final attachment in documentAttachments)
                  _HubAttachmentPreview(attachment: attachment),
              ],
            ),
          const SizedBox(height: 14),
          _HubSectionHeader(
            icon: Icons.photo_library_outlined,
            title: 'Fotos e imagens',
            count: photoAttachments.length,
          ),
          const SizedBox(height: 10),
          if (photoAttachments.isEmpty)
            const _HubEmptyLine(
              icon: Icons.image_not_supported_outlined,
              text: 'Sem imagens compartilhadas com este perfil.',
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final attachment in photoAttachments)
                  _HubPhotoPreview(attachment: attachment),
              ],
            ),
          const SizedBox(height: 14),
          _HubSectionHeader(
            icon: Icons.psychology_alt_outlined,
            title: 'Detalhes contextuais',
            count: visibleNotes.length,
          ),
          const SizedBox(height: 10),
          if (visibleNotes.isEmpty)
            _HubEmptyLine(
              icon: viewerProfile.canViewSensitive
                  ? Icons.info_outline_rounded
                  : Icons.visibility_off_outlined,
              text: viewerProfile.canViewSensitive
                  ? 'Sem detalhes contextuais liberados para esta ficha.'
                  : 'Detalhes protegidos permanecem ocultos para este perfil.',
            )
          else
            for (final note in visibleNotes) ...[
              _HubSensitiveNotePreview(note: note),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }
}

class _FocusBoardNotesStage extends StatelessWidget {
  const _FocusBoardNotesStage({
    required this.notes,
    required this.loading,
    required this.selectedNoteIds,
    required this.viewerProfile,
    required this.cardsHidden,
    required this.autofocusNoteId,
    required this.attentionNoteId,
    required this.attentionPulse,
    required this.onAddNote,
    required this.onTapNote,
    required this.onLongPressNote,
    required this.onToggleOwner,
    required this.onToggleAssignment,
    required this.onUpdateText,
    required this.onDiscardDraft,
    required this.onEditNote,
    required this.onTrashNote,
    required this.onArchiveNote,
    required this.onDeletePermanentlyNote,
    required this.onRestoreNote,
    required this.onShowAudit,
    required this.onReplicateNote,
    required this.onCloseNote,
  });

  final List<_FocusBoardNote> notes;
  final bool loading;
  final Set<String> selectedNoteIds;
  final _ViewerAccessProfile viewerProfile;
  final bool cardsHidden;
  final String? autofocusNoteId;
  final String? attentionNoteId;
  final int attentionPulse;
  final VoidCallback onAddNote;
  final ValueChanged<_FocusBoardNote> onTapNote;
  final ValueChanged<_FocusBoardNote> onLongPressNote;
  final ValueChanged<_FocusBoardNote> onToggleOwner;
  final void Function(_FocusBoardNote, _FocusBoardAssignment)
  onToggleAssignment;
  final Future<_FocusBoardTextCommitResult> Function(
    _FocusBoardNote,
    String,
    String,
  )
  onUpdateText;
  final Future<void> Function(_FocusBoardNote) onDiscardDraft;
  final ValueChanged<_FocusBoardNote> onEditNote;
  final Future<void> Function(_FocusBoardNote) onTrashNote;
  final Future<void> Function(_FocusBoardNote) onArchiveNote;
  final Future<void> Function(_FocusBoardNote) onDeletePermanentlyNote;
  final Future<void> Function(_FocusBoardNote) onRestoreNote;
  final ValueChanged<_FocusBoardNote> onShowAudit;
  final Future<void> Function(_FocusBoardNote) onReplicateNote;
  final Future<void> Function(_FocusBoardNote) onCloseNote;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const _FocusBoardPaperCanvas(
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.6),
          ),
        ),
      );
    }

    if (cardsHidden) {
      return const _FocusBoardCardsHiddenState();
    }

    if (notes.isEmpty) {
      return _FocusBoardPaperCanvas(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.sticky_note_2_outlined,
                  color: _mutedColor,
                  size: 30,
                ),
                const SizedBox(height: 8),
                Text(
                  'Nenhuma nota neste filtro.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: _inkColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: onAddNote,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Criar nota'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final notesById = {for (final note in notes) note.id: note};
    int depthFor(_FocusBoardNote note) {
      var depth = 0;
      var current = note;
      final visited = <String>{note.id};
      while (current.parentNoteId.isNotEmpty && depth < 2) {
        final parent = notesById[current.parentNoteId];
        if (parent == null || !visited.add(parent.id)) {
          break;
        }
        depth += 1;
        current = parent;
      }
      return depth;
    }

    _FocusBoardNote rootFor(_FocusBoardNote note) {
      var current = note;
      final visited = <String>{note.id};
      while (current.parentNoteId.isNotEmpty) {
        final parent = notesById[current.parentNoteId];
        if (parent == null || !visited.add(parent.id)) {
          break;
        }
        current = parent;
      }
      return current;
    }

    return _FocusBoardPaperCanvas(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(14, 18, 14, 22),
        itemCount: notes.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final note = notes[index];
          final threadDepth = depthFor(note);
          final rootNote = rootFor(note);
          final tile = _FocusBoardNoteTile(
            key: ValueKey(note.id),
            note: note,
            viewerProfile: viewerProfile,
            threadDepth: threadDepth,
            grandchildMaxLength: threadDepth >= 2 ? 15 : null,
            autofocusTitle: note.id == autofocusNoteId,
            attentionPulse: note.id == attentionNoteId ? attentionPulse : 0,
            selected: selectedNoteIds.contains(note.id),
            selectionMode: selectedNoteIds.isNotEmpty,
            onTap: () => onTapNote(note),
            onLongPress: () => onLongPressNote(note),
            onToggleOwner: () => onToggleOwner(note),
            onToggleAssignment: (assignment) =>
                onToggleAssignment(note, assignment),
            onUpdateText: (title, description) =>
                onUpdateText(note, title, description),
            onDiscardDraft: () => onDiscardDraft(note),
            onEdit: note.isCreator(viewerProfile) && !note.isClosed
                ? () => onEditNote(note)
                : null,
            onTrash: () => onTrashNote(note),
            onArchive: !note.inTrash && !note.inArchive
                ? () => onArchiveNote(note)
                : null,
            onDeletePermanently:
                threadDepth > 0 && note.isCreator(viewerProfile)
                ? () => onDeletePermanentlyNote(note)
                : null,
            onRestore: note.inTrash || note.inArchive
                ? () => onRestoreNote(note)
                : null,
            onShowAudit: () => onShowAudit(note),
            onReplicate:
                note.replicasEnabled && !note.isClosed && threadDepth < 2
                ? () => onReplicateNote(note)
                : null,
            onClose: rootNote.isCreator(viewerProfile) && !rootNote.isClosed
                ? () => onCloseNote(note)
                : null,
          );
          final swipeable =
              threadDepth == 0 &&
              !note.inTrash &&
              !note.inArchive &&
              selectedNoteIds.isEmpty;
          final child = swipeable
              ? Dismissible(
                  key: ValueKey('swipe-${note.id}'),
                  direction: DismissDirection.horizontal,
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      await onTrashNote(note);
                    } else if (direction == DismissDirection.endToStart) {
                      await onArchiveNote(note);
                    }
                    return false;
                  },
                  background: const _FocusBoardSwipeBackground(
                    icon: Icons.recycling_rounded,
                    label: 'Lixeira',
                    alignment: Alignment.centerLeft,
                    color: Color(0xFFD81F2A),
                  ),
                  secondaryBackground: const _FocusBoardSwipeBackground(
                    icon: Icons.archive_outlined,
                    label: 'Arquivar',
                    alignment: Alignment.centerRight,
                    color: _deepTealColor,
                  ),
                  child: tile,
                )
              : tile;
          return Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: threadDepth * 16.0),
              child: FractionallySizedBox(
                widthFactor: switch (threadDepth) {
                  0 => 0.96,
                  1 => 0.88,
                  _ => 0.80,
                },
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FocusBoardPaperCanvas extends StatelessWidget {
  const _FocusBoardPaperCanvas({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFFCFBF7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _lineColor),
      ),
      child: CustomPaint(
        painter: const _FocusBoardPaperPainter(),
        child: child,
      ),
    );
  }
}

class _FocusBoardPaperPainter extends CustomPainter {
  const _FocusBoardPaperPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = _lineColor.withValues(alpha: 0.36)
      ..strokeWidth = 1;
    for (var y = 28.0; y < size.height; y += 24.0) {
      canvas.drawLine(Offset(16, y), Offset(size.width - 16, y), linePaint);
    }
    final marginPaint = Paint()
      ..color = _tealColor.withValues(alpha: 0.10)
      ..strokeWidth = 1.2;
    canvas.drawLine(const Offset(44, 0), Offset(44, size.height), marginPaint);
  }

  @override
  bool shouldRepaint(covariant _FocusBoardPaperPainter oldDelegate) => false;
}

class _FocusBoardCardsHiddenState extends StatelessWidget {
  const _FocusBoardCardsHiddenState();

  @override
  Widget build(BuildContext context) {
    return _FocusBoardPaperCanvas(
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(18),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _lineColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.visibility_off_outlined, color: _mutedColor),
              const SizedBox(width: 8),
              Text(
                'Cards ocultos',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: _mutedColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FocusBoardSwipeBackground extends StatelessWidget {
  const _FocusBoardSwipeBackground({
    required this.icon,
    required this.label,
    required this.alignment,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Alignment alignment;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final alignLeft = alignment == Alignment.centerLeft;
    return Container(
      alignment: alignment,
      padding: EdgeInsets.only(
        left: alignLeft ? 18 : 0,
        right: alignLeft ? 0 : 18,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alignLeft) Icon(icon, color: color),
          if (alignLeft) const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (!alignLeft) const SizedBox(width: 6),
          if (!alignLeft) Icon(icon, color: color),
        ],
      ),
    );
  }
}

class _FocusBoardNoteTile extends StatefulWidget {
  const _FocusBoardNoteTile({
    super.key,
    required this.note,
    required this.viewerProfile,
    required this.threadDepth,
    required this.grandchildMaxLength,
    required this.autofocusTitle,
    required this.attentionPulse,
    required this.selected,
    required this.selectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.onToggleOwner,
    required this.onToggleAssignment,
    required this.onUpdateText,
    required this.onDiscardDraft,
    required this.onTrash,
    required this.onShowAudit,
    this.onEdit,
    this.onArchive,
    this.onDeletePermanently,
    this.onRestore,
    this.onReplicate,
    this.onClose,
  });

  final _FocusBoardNote note;
  final _ViewerAccessProfile viewerProfile;
  final int threadDepth;
  final int? grandchildMaxLength;
  final bool autofocusTitle;
  final int attentionPulse;
  final bool selected;
  final bool selectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onToggleOwner;
  final ValueChanged<_FocusBoardAssignment> onToggleAssignment;
  final Future<_FocusBoardTextCommitResult> Function(
    String title,
    String description,
  )
  onUpdateText;
  final Future<void> Function() onDiscardDraft;
  final VoidCallback? onEdit;
  final Future<void> Function() onTrash;
  final Future<void> Function()? onArchive;
  final Future<void> Function()? onDeletePermanently;
  final Future<void> Function()? onRestore;
  final VoidCallback onShowAudit;
  final Future<void> Function()? onReplicate;
  final Future<void> Function()? onClose;

  @override
  State<_FocusBoardNoteTile> createState() => _FocusBoardNoteTileState();
}

class _FocusBoardNoteTileState extends State<_FocusBoardNoteTile>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final FocusNode _titleFocusNode;
  late final FocusNode _descriptionFocusNode;
  late final AnimationController _attentionController;
  bool _hovered = false;
  bool _dirty = false;
  bool _savingEdit = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _descriptionController = TextEditingController(
      text: widget.note.description,
    );
    _titleFocusNode = FocusNode()..addListener(_commitWhenFocusLeaves);
    _descriptionFocusNode = FocusNode()..addListener(_commitWhenFocusLeaves);
    _attentionController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..addListener(() {
            if (mounted) {
              setState(() {});
            }
          });
    if (widget.autofocusTitle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_canEditInline(widget.note)) {
          return;
        }
        _titleFocusNode.requestFocus();
        _titleController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _titleController.text.length,
        );
      });
    }
  }

  @override
  void didUpdateWidget(covariant _FocusBoardNoteTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.attentionPulse > 0 &&
        widget.attentionPulse != oldWidget.attentionPulse) {
      _attentionController.forward(from: 0);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_canEditInline(widget.note)) {
          return;
        }
        _titleFocusNode.requestFocus();
        _titleController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _titleController.text.length,
        );
      });
    }
    if (oldWidget.note.id != widget.note.id) {
      _titleController.text = widget.note.title;
      _descriptionController.text = widget.note.description;
      _dirty = false;
      return;
    }
    if (!_dirty &&
        !_titleFocusNode.hasFocus &&
        _titleController.text != widget.note.title) {
      _titleController.text = widget.note.title;
    }
    if (!_dirty &&
        !_descriptionFocusNode.hasFocus &&
        _descriptionController.text != widget.note.description) {
      _descriptionController.text = widget.note.description;
    }
  }

  @override
  void dispose() {
    _titleFocusNode.removeListener(_commitWhenFocusLeaves);
    _descriptionFocusNode.removeListener(_commitWhenFocusLeaves);
    _attentionController.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final note = widget.note;
    final priorityColor = note.priority.color;
    final state = note.completionState;
    final attentionValue = _attentionController.value;
    final attentionActive =
        attentionValue > 0 && attentionValue < 1 && widget.attentionPulse > 0;
    final attentionGlow = attentionActive
        ? sin(attentionValue * pi).abs()
        : 0.0;
    final attentionPan = attentionActive
        ? sin(attentionValue * pi * 9) * (1 - attentionValue) * 3
        : 0.0;
    final baseColor = widget.selected
        ? _deepTealColor.withValues(alpha: 0.08)
        : Colors.white;
    final checkButtonSize = switch (widget.threadDepth) {
      0 => 40.0,
      1 => 34.0,
      _ => 30.0,
    };
    final checkIconSize = switch (widget.threadDepth) {
      0 => 24.0,
      1 => 20.0,
      _ => 17.0,
    };
    return Transform.translate(
      offset: Offset(attentionPan, 0),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: InkWell(
          onTap: widget.selectionMode ? widget.onTap : null,
          onLongPress: widget.onLongPress,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: attentionActive ? null : baseColor,
              gradient: attentionActive
                  ? LinearGradient(
                      begin: Alignment(-1 + attentionValue * 2, -0.6),
                      end: Alignment(1 + attentionValue * 2, 0.8),
                      colors: [
                        baseColor,
                        _amberColor.withValues(alpha: 0.20 * attentionGlow),
                        _tealColor.withValues(alpha: 0.16 * attentionGlow),
                        baseColor,
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.selected
                    ? _deepTealColor
                    : attentionActive
                    ? _amberColor.withValues(alpha: 0.44)
                    : priorityColor.withValues(alpha: 0.22),
              ),
              boxShadow: [
                BoxShadow(
                  color: attentionActive
                      ? _amberColor.withValues(alpha: 0.12 * attentionGlow)
                      : _inkColor.withValues(alpha: 0.05),
                  blurRadius: attentionActive ? 24 : 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FocusBoardPriorityBadge(priority: note.priority),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _editableTitle(context, note),
                          if (note.description.trim().isNotEmpty ||
                              _canEditInline(note)) ...[
                            const SizedBox(height: 4),
                            _editableDescription(context, note),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (_dirty)
                      IconButton.filledTonal(
                        tooltip: 'Salvar edicao',
                        onPressed: _savingEdit
                            ? null
                            : () => unawaited(_saveEdits()),
                        icon: const Icon(Icons.check_rounded),
                      ),
                    SizedBox.square(
                      dimension: checkButtonSize,
                      child: IconButton(
                        tooltip: note.completedByOwner
                            ? 'Marcar como pendente'
                            : 'Marcar como concluido',
                        onPressed: note.isClosed ? null : widget.onToggleOwner,
                        iconSize: checkIconSize,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints.tight(
                          Size.square(checkButtonSize),
                        ),
                        icon: Icon(
                          note.completedByOwner
                              ? Icons.check_circle_rounded
                              : Icons.check_circle_outline_rounded,
                          color: note.completedByOwner
                              ? _tealColor
                              : _mutedColor,
                        ),
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: _hovered || widget.selectionMode ? 1 : 0.28,
                      duration: const Duration(milliseconds: 120),
                      child: _FocusBoardNoteMenu(
                        note: note,
                        onEdit: widget.onEdit,
                        onTrash: () => unawaited(widget.onTrash()),
                        onArchive: widget.onArchive == null
                            ? null
                            : () => unawaited(widget.onArchive!()),
                        onDeletePermanently: widget.onDeletePermanently == null
                            ? null
                            : () => unawaited(widget.onDeletePermanently!()),
                        onRestore: widget.onRestore == null
                            ? null
                            : () => unawaited(widget.onRestore!()),
                        onShowAudit: widget.onShowAudit,
                        onReplicate: widget.onReplicate == null
                            ? null
                            : () => unawaited(widget.onReplicate!()),
                        onClose: widget.onClose == null
                            ? null
                            : () => unawaited(widget.onClose!()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _FocusBoardMiniChip(
                      icon: Icons.event_outlined,
                      label: _focusBoardShortDateLabel(note.dueAt),
                      color: _slateColor,
                    ),
                    _FocusBoardMiniChip(
                      icon: Icons.circle,
                      label: state.label,
                      color: state.color,
                    ),
                    if (_hovered || widget.selectionMode)
                      _FocusBoardMiniChip(
                        icon:
                            note.visibility == _FocusBoardNoteVisibility.private
                            ? Icons.lock_outline_rounded
                            : Icons.visibility_outlined,
                        label: note.visibility.label,
                        color: _mutedColor,
                      ),
                    if (note.isClosed)
                      _FocusBoardMiniChip(
                        icon: Icons.lock_clock_outlined,
                        label: 'Encerrada',
                        color: _tealColor,
                      ),
                    if ((_hovered || widget.selectionMode) &&
                        note.companyLabel.trim().isNotEmpty)
                      _FocusBoardMiniChip(
                        icon: Icons.apartment_rounded,
                        label: note.companyLabel,
                        color: _slateColor,
                      ),
                    if (note.hasAssignments)
                      _FocusBoardMiniChip(
                        icon: Icons.eco_outlined,
                        label:
                            '${note.completedAssignmentCount}/${note.assignments.length}',
                        color: _tealColor,
                      ),
                    if (note.hasMultipleAssignments &&
                        note.viewerAssigned(widget.viewerProfile))
                      _FocusBoardMiniChip(
                        icon: Icons.assignment_outlined,
                        label: 'voce junto',
                        color: _deepTealColor,
                      ),
                  ],
                ),
                if (note.assignments.isNotEmpty &&
                    (_hovered || widget.selectionMode)) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final assignment in note.assignments)
                        FilterChip(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          label: Text(
                            '${assignment.label} (${assignment.type.label})',
                            overflow: TextOverflow.ellipsis,
                          ),
                          selected: assignment.completed,
                          onSelected: note.isClosed || !note.replicasEnabled
                              ? null
                              : (_) => widget.onToggleAssignment(assignment),
                          avatar: Icon(
                            assignment.completed
                                ? Icons.check_rounded
                                : Icons.eco_outlined,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  _noteMetaLabel(note),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: _mutedColor,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _editableTitle(BuildContext context, _FocusBoardNote note) {
    final textDecoration = note.isComplete ? TextDecoration.lineThrough : null;
    final style = Theme.of(context).textTheme.titleSmall?.copyWith(
      color: _inkColor,
      fontWeight: FontWeight.w900,
      decoration: textDecoration,
      decorationThickness: 2,
    );
    if (!_canEditInline(note)) {
      return Text(
        note.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }
    return Tooltip(
      message: 'Digite o conteudo da nota aqui.',
      child: TextField(
        controller: _titleController,
        focusNode: _titleFocusNode,
        maxLines: 1,
        maxLength: widget.grandchildMaxLength,
        buildCounter: widget.grandchildMaxLength == null
            ? null
            : _hideTextFieldCounter,
        textInputAction: TextInputAction.done,
        onChanged: _handleTextChanged,
        onSubmitted: (_) => unawaited(_saveEdits()),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: widget.autofocusTitle
              ? 'Digite o conteudo da nota aqui'
              : null,
          contentPadding: EdgeInsets.zero,
        ),
        style: style,
      ),
    );
  }

  Widget _editableDescription(BuildContext context, _FocusBoardNote note) {
    final textDecoration = note.isComplete ? TextDecoration.lineThrough : null;
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: _inkColor,
      height: 1.25,
      fontWeight: FontWeight.w600,
      decoration: textDecoration,
      decorationThickness: 1.8,
    );
    if (!_canEditInline(note)) {
      return Text(
        note.description,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }
    return Tooltip(
      message: 'Digite o conteúdo aqui.',
      child: TextField(
        controller: _descriptionController,
        focusNode: _descriptionFocusNode,
        minLines: 1,
        maxLines: 3,
        maxLength: widget.grandchildMaxLength,
        buildCounter: widget.grandchildMaxLength == null
            ? null
            : _hideTextFieldCounter,
        textInputAction: TextInputAction.done,
        onChanged: _handleTextChanged,
        onSubmitted: (_) => unawaited(_saveEdits()),
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: 'Adicionar texto',
          contentPadding: EdgeInsets.zero,
        ),
        style: style,
      ),
    );
  }

  bool _canEditInline(_FocusBoardNote note) {
    return !widget.selectionMode &&
        note.isCreator(widget.viewerProfile) &&
        !note.isClosed;
  }

  Widget? _hideTextFieldCounter(
    BuildContext context, {
    required int currentLength,
    required bool isFocused,
    required int? maxLength,
  }) {
    return null;
  }

  void _commitWhenFocusLeaves() {
    if (_titleFocusNode.hasFocus ||
        _descriptionFocusNode.hasFocus ||
        _savingEdit) {
      return;
    }
    Future<void>.delayed(const Duration(milliseconds: 90), () {
      if (!mounted ||
          _titleFocusNode.hasFocus ||
          _descriptionFocusNode.hasFocus ||
          _savingEdit) {
        return;
      }
      if (widget.note.isDraft && _draftTextIsEmpty) {
        unawaited(_discardDraft());
        return;
      }
      if (_dirty) {
        unawaited(_saveEdits(unfocus: false));
      }
    });
  }

  void _handleTextChanged(String _) {
    final dirty =
        _titleController.text != widget.note.title ||
        _descriptionController.text != widget.note.description;
    if (dirty != _dirty) {
      setState(() => _dirty = dirty);
    }
  }

  bool get _draftTextIsEmpty {
    return _focusBoardIsEmptyDraftText(
      _titleController.text,
      _descriptionController.text,
    );
  }

  Future<void> _saveEdits({bool unfocus = true}) async {
    if (_savingEdit) {
      return;
    }
    if (widget.note.isDraft && _draftTextIsEmpty) {
      await _discardDraft();
      return;
    }
    if (!_dirty && !widget.note.isDraft) {
      return;
    }
    setState(() => _savingEdit = true);
    try {
      await widget.onUpdateText(
        _boundedText(_titleController.text),
        _boundedText(_descriptionController.text),
      );
      if (!mounted) {
        return;
      }
      setState(() => _dirty = false);
      if (unfocus) {
        _titleFocusNode.unfocus();
        _descriptionFocusNode.unfocus();
      }
    } finally {
      if (mounted) {
        setState(() => _savingEdit = false);
      }
    }
  }

  Future<void> _discardDraft() async {
    if (_savingEdit) {
      return;
    }
    setState(() => _savingEdit = true);
    try {
      await widget.onDiscardDraft();
      if (mounted) {
        setState(() => _dirty = false);
      }
    } finally {
      if (mounted) {
        setState(() => _savingEdit = false);
      }
    }
  }

  String _boundedText(String value) {
    final maxLength = widget.grandchildMaxLength;
    if (maxLength == null || value.length <= maxLength) {
      return value;
    }
    return value.substring(0, maxLength);
  }

  String _noteMetaLabel(_FocusBoardNote note) {
    final created =
        '${note.createdByName} criou em ${_focusBoardShortDateTimeLabel(note.createdAt)}';
    final edited = note.lastEditedAt == null
        ? ''
        : ' | editado em ${_focusBoardShortDateTimeLabel(note.lastEditedAt!)}';
    final closed = note.closedAt == null
        ? ''
        : ' | encerrado em ${_focusBoardShortDateTimeLabel(note.closedAt!)}';
    return '$created$edited$closed';
  }
}

class _FocusBoardNoteMenu extends StatelessWidget {
  const _FocusBoardNoteMenu({
    required this.note,
    required this.onTrash,
    required this.onShowAudit,
    this.onEdit,
    this.onArchive,
    this.onDeletePermanently,
    this.onRestore,
    this.onReplicate,
    this.onClose,
  });

  final _FocusBoardNote note;
  final VoidCallback? onEdit;
  final VoidCallback onTrash;
  final VoidCallback? onArchive;
  final VoidCallback? onDeletePermanently;
  final VoidCallback? onRestore;
  final VoidCallback onShowAudit;
  final VoidCallback? onReplicate;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Editar e configurar nota',
      icon: const Icon(Icons.more_vert_rounded),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
          case 'trash':
            onTrash();
          case 'archive':
            onArchive?.call();
          case 'deletePermanently':
            onDeletePermanently?.call();
          case 'restore':
            onRestore?.call();
          case 'audit':
            onShowAudit();
          case 'replicate':
            onReplicate?.call();
          case 'close':
            onClose?.call();
        }
      },
      itemBuilder: (context) => [
        if (onEdit != null)
          const PopupMenuItem(value: 'edit', child: Text('Editar definicoes')),
        if (onReplicate != null)
          const PopupMenuItem(value: 'replicate', child: Text('Replicar nota')),
        if (onClose != null)
          const PopupMenuItem(value: 'close', child: Text('Encerrar')),
        if (onArchive != null)
          const PopupMenuItem(value: 'archive', child: Text('Arquivar')),
        if (onDeletePermanently != null)
          const PopupMenuItem(
            value: 'deletePermanently',
            child: Text('Excluir resposta permanente'),
          ),
        if (onRestore != null)
          PopupMenuItem(
            value: 'restore',
            child: Text(note.inArchive ? 'Desarquivar' : 'Restaurar'),
          )
        else
          const PopupMenuItem(
            value: 'trash',
            child: Text('Mover para lixeira'),
          ),
        const PopupMenuItem(value: 'audit', child: Text('Auditoria')),
      ],
    );
  }
}

class _FocusBoardPriorityBadge extends StatelessWidget {
  const _FocusBoardPriorityBadge({required this.priority});

  final _FocusBoardNotePriority priority;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: priority.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(priority.icon, color: priority.color, size: 23),
    );
  }
}

class _FocusBoardMiniChip extends StatelessWidget {
  const _FocusBoardMiniChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusBoardFixedFooter extends StatelessWidget {
  const _FocusBoardFixedFooter({
    required this.calendarEntries,
    required this.onAddCalendarEntry,
    required this.onCancelCalendarEntry,
  });

  final List<_CalendarEntryRecord> calendarEntries;
  final ValueChanged<_FocusBoardTaskMode> onAddCalendarEntry;
  final ValueChanged<_CalendarEntryRecord> onCancelCalendarEntry;

  @override
  Widget build(BuildContext context) {
    bool isActiveEntry(_CalendarEntryRecord entry) {
      final status = entry.status.toUpperCase();
      return status != 'CANCELED' &&
          status != 'COMPLETED' &&
          status != 'DISMISSED';
    }

    final calendarPreview =
        calendarEntries
            .where((entry) => isActiveEntry(entry) && !entry.isFocusBoardTask)
            .toList(growable: false)
          ..sort((left, right) => left.startsAt.compareTo(right.startsAt));
    final taskEntries =
        calendarEntries
            .where((entry) => isActiveEntry(entry) && entry.isFocusBoardTask)
            .toList(growable: false)
          ..sort((left, right) => left.startsAt.compareTo(right.startsAt));
    final calendarPreviewItems = calendarPreview
        .take(4)
        .toList(growable: false);
    final taskPreview = taskEntries.take(3).toList(growable: false);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _lineColor)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FocusBoardCalendarFooterSection(
              entries: calendarPreviewItems,
              onCancelCalendarEntry: onCancelCalendarEntry,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _lineColor),
              ),
              child: Column(
                children: [
                  _FocusBoardTaskFooterHeader(
                    count: taskEntries.length,
                    onAdd: () =>
                        onAddCalendarEntry(_FocusBoardTaskMode.reminder),
                  ),
                  const SizedBox(height: 8),
                  if (taskPreview.isEmpty)
                    const _FocusBoardFooterEmpty(
                      icon: Icons.task_alt_rounded,
                      text: 'Nenhuma tarefa, alarme ou timer agendado.',
                    )
                  else
                    for (final entry in taskPreview) ...[
                      _FocusBoardTaskFooterRow(
                        entry: entry,
                        onCancel: entry.canCancel
                            ? () => onCancelCalendarEntry(entry)
                            : null,
                      ),
                      if (entry != taskPreview.last) const SizedBox(height: 6),
                    ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            _FocusBoardTaskActionBar(onSelect: onAddCalendarEntry),
          ],
        ),
      ),
    );
  }
}

class _FocusBoardTaskFooterHeader extends StatelessWidget {
  const _FocusBoardTaskFooterHeader({required this.count, required this.onAdd});

  final int count;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle_outline_rounded, color: _tealColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'TAREFAS ($count)',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: _deepTealColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Adicionar'),
          style: OutlinedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            foregroundColor: _deepTealColor,
            side: const BorderSide(color: _tealColor),
          ),
        ),
      ],
    );
  }
}

class _FocusBoardTaskActionBar extends StatelessWidget {
  const _FocusBoardTaskActionBar({required this.onSelect});

  final ValueChanged<_FocusBoardTaskMode> onSelect;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          for (final mode in _FocusBoardTaskMode.values) ...[
            Expanded(
              child: _FocusBoardTaskActionButton(
                mode: mode,
                onPressed: () => onSelect(mode),
              ),
            ),
            if (mode != _FocusBoardTaskMode.values.last)
              const VerticalDivider(width: 1, color: _lineColor),
          ],
        ],
      ),
    );
  }
}

class _FocusBoardTaskActionButton extends StatelessWidget {
  const _FocusBoardTaskActionButton({
    required this.mode,
    required this.onPressed,
  });

  final _FocusBoardTaskMode mode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Criar ${mode.label.toLowerCase()} com notificacoes externas',
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(mode.icon, color: _deepTealColor, size: 26),
              const SizedBox(height: 3),
              Text(
                mode.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: _deepTealColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FocusBoardCalendarFooterSection extends StatelessWidget {
  const _FocusBoardCalendarFooterSection({
    required this.entries,
    required this.onCancelCalendarEntry,
  });

  final List<_CalendarEntryRecord> entries;
  final ValueChanged<_CalendarEntryRecord> onCancelCalendarEntry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _lineColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.event_available_outlined,
                color: _deepTealColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'COMPROMISSOS DO CALENDARIO',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: _deepTealColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (entries.isEmpty)
            const _FocusBoardFooterEmpty(
              icon: Icons.event_available_outlined,
              text: 'Sem compromissos de calendario ativos.',
            )
          else
            for (final entry in entries) ...[
              _FocusBoardCalendarFooterRow(
                entry: entry,
                onCancel: entry.canCancel
                    ? () => onCancelCalendarEntry(entry)
                    : null,
              ),
              if (entry != entries.last) const SizedBox(height: 6),
            ],
        ],
      ),
    );
  }
}

class _FocusBoardBulkBar extends StatelessWidget {
  const _FocusBoardBulkBar({
    required this.selectedCount,
    required this.onClear,
    required this.onComplete,
    required this.onTrash,
  });

  final int selectedCount;
  final VoidCallback onClear;
  final VoidCallback onComplete;
  final VoidCallback onTrash;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _deepTealColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _deepTealColor.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$selectedCount selecionada(s)',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: _deepTealColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Concluir selecao',
            onPressed: onComplete,
            icon: const Icon(Icons.check_circle_outline_rounded),
          ),
          IconButton(
            tooltip: 'Mover selecao para lixeira',
            onPressed: onTrash,
            icon: const Icon(Icons.recycling_rounded),
          ),
          IconButton(
            tooltip: 'Limpar selecao',
            onPressed: onClear,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}

class _FocusBoardCalendarFooterRow extends StatelessWidget {
  const _FocusBoardCalendarFooterRow({required this.entry, this.onCancel});

  final _CalendarEntryRecord entry;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final color = switch (entry.priority.toUpperCase()) {
      'CRITICAL' => const Color(0xFFD81F2A),
      'HIGH' => const Color(0xFFE9A100),
      _ => _tealColor,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _lineColor),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_month_outlined, color: color, size: 20),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: _inkColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${entry.startsAtLabel} | ${entry.kindLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: _mutedColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Acoes do compromisso',
            onPressed: onCancel,
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
    );
  }
}

class _FocusBoardTaskFooterRow extends StatelessWidget {
  const _FocusBoardTaskFooterRow({required this.entry, this.onCancel});

  final _CalendarEntryRecord entry;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final color = switch (entry.priority.toUpperCase()) {
      'CRITICAL' => const Color(0xFFD81F2A),
      'HIGH' => const Color(0xFFE9A100),
      _ => _tealColor,
    };
    final priorityIcon = switch (entry.priority.toUpperCase()) {
      'CRITICAL' => Icons.priority_high_rounded,
      'HIGH' => Icons.star_rounded,
      _ => entry.taskMode.icon,
    };
    final priorityBadge = switch (entry.priority.toUpperCase()) {
      'CRITICAL' => 'URGENTE',
      'HIGH' => 'IMPORTANTE',
      _ => '',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _lineColor),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(priorityIcon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: _inkColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (entry.description.trim().isNotEmpty)
                  Text(
                    entry.description.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: _mutedColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                Text(
                  entry.notificationChannelsLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: _deepTealColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (priorityBadge.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                priorityBadge,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 9,
                ),
              ),
            ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                color: _mutedColor,
                size: 17,
              ),
              const SizedBox(width: 4),
              Text(
                _focusBoardShortDateLabel(entry.startsAt),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: _inkColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            tooltip: 'Acoes da tarefa',
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              if (value == 'cancel' && onCancel != null) {
                onCancel!();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: onCancel != null,
                value: 'cancel',
                child: const Text('Cancelar item'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FocusBoardFooterEmpty extends StatelessWidget {
  const _FocusBoardFooterEmpty({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _lineColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: _mutedColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _mutedColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusBoardStatusFilterButton extends StatelessWidget {
  const _FocusBoardStatusFilterButton({required this.controller});

  final _FocusBoardNotesController controller;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_FocusBoardNoteStatusFilter>(
      tooltip: 'Filtrar por conclusao',
      icon: const Icon(Icons.check_circle_outline_rounded),
      onSelected: (filter) => controller.setStatusFilter(filter),
      itemBuilder: (context) => [
        for (final filter in _FocusBoardNoteStatusFilter.values)
          PopupMenuItem(value: filter, child: Text(filter.label)),
      ],
    );
  }
}

class _FocusBoardSortButton extends StatelessWidget {
  const _FocusBoardSortButton({required this.controller});

  final _FocusBoardNotesController controller;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_FocusBoardNoteSort>(
      tooltip: 'Organizar notas',
      icon: const Icon(Icons.sort_rounded),
      onSelected: (sort) => controller.setSort(sort),
      itemBuilder: (context) => [
        for (final sort in _FocusBoardNoteSort.values)
          PopupMenuItem(value: sort, child: Text(sort.label)),
      ],
    );
  }
}

class _FocusBoardEyeFilterIcon extends StatelessWidget {
  const _FocusBoardEyeFilterIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 24,
      height: 24,
      child: Stack(
        children: [
          Positioned(
            left: 1,
            bottom: 2,
            child: Icon(Icons.visibility_outlined, size: 19),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Icon(Icons.filter_alt_outlined, size: 14),
          ),
        ],
      ),
    );
  }
}

class _FocusBoardAssignmentOption {
  const _FocusBoardAssignmentOption({
    required this.type,
    required this.id,
    required this.label,
    required this.subtitle,
  });

  final _FocusBoardAssignmentType type;
  final String id;
  final String label;
  final String subtitle;

  String get key => '${type.key}:$id';

  _FocusBoardAssignment toAssignment() {
    return _FocusBoardAssignment(type: type, id: id, label: label);
  }
}

class _FocusBoardNoteDialog extends StatefulWidget {
  const _FocusBoardNoteDialog({
    required this.assignmentOptions,
    required this.currentCompanyLabel,
    this.initial,
  });

  final List<_FocusBoardAssignmentOption> assignmentOptions;
  final String currentCompanyLabel;
  final _FocusBoardNote? initial;

  @override
  State<_FocusBoardNoteDialog> createState() => _FocusBoardNoteDialogState();
}

class _FocusBoardNoteDialogState extends State<_FocusBoardNoteDialog> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  late DateTime _dueAt;
  late _FocusBoardNotePriority _priority;
  late _FocusBoardNoteVisibility _visibility;
  late bool _replicasEnabled;
  late _FocusBoardReplicaMode _replicaMode;
  late String _companyLabel;
  late Set<String> _selectedAssignmentKeys;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _title = TextEditingController(text: initial?.title ?? 'Nova nota');
    _description = TextEditingController(text: initial?.description ?? '');
    _companyLabel = initial?.companyLabel.trim().isNotEmpty == true
        ? initial!.companyLabel.trim()
        : widget.currentCompanyLabel.trim();
    _dueAt = initial?.dueAt ?? DateTime.now().add(const Duration(days: 7));
    _priority = initial?.priority ?? _FocusBoardNotePriority.normal;
    _visibility = initial?.visibility ?? _FocusBoardNoteVisibility.private;
    _replicasEnabled = initial?.replicasEnabled ?? true;
    _replicaMode = initial?.replicaMode ?? _FocusBoardReplicaMode.ownerOnly;
    _selectedAssignmentKeys = {
      for (final assignment in initial?.assignments ?? const [])
        '${assignment.type.key}:${assignment.id}',
    };
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final companyOptions =
        <String>{
          if (_companyLabel.isNotEmpty) _companyLabel,
          if (widget.currentCompanyLabel.trim().isNotEmpty)
            widget.currentCompanyLabel.trim(),
          for (final option in widget.assignmentOptions)
            if (option.type == _FocusBoardAssignmentType.company)
              option.label.trim(),
        }.where((label) => label.isNotEmpty).toList(growable: false)..sort(
          (left, right) => left.toLowerCase().compareTo(right.toLowerCase()),
        );
    return AlertDialog(
      title: Text(widget.initial == null ? 'Nova nota' : 'Editar nota'),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _title,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Titulo'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _description,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Texto'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<_FocusBoardNotePriority>(
                initialValue: _priority,
                decoration: const InputDecoration(labelText: 'Prioridade'),
                items: [
                  for (final priority in _FocusBoardNotePriority.values)
                    DropdownMenuItem(
                      value: priority,
                      child: Text(priority.label),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _priority = value);
                  }
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<_FocusBoardNoteVisibility>(
                initialValue: _visibility,
                decoration: const InputDecoration(labelText: 'Visibilidade'),
                items: [
                  for (final visibility in _FocusBoardNoteVisibility.values)
                    DropdownMenuItem(
                      value: visibility,
                      child: Text(visibility.label),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _visibility = value);
                  }
                },
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _replicasEnabled,
                title: const Text('Permitir replicas'),
                onChanged: (value) => setState(() => _replicasEnabled = value),
              ),
              DropdownButtonFormField<_FocusBoardReplicaMode>(
                initialValue: _replicaMode,
                decoration: const InputDecoration(labelText: 'Conclusao'),
                items: [
                  for (final mode in _FocusBoardReplicaMode.values)
                    DropdownMenuItem(value: mode, child: Text(mode.label)),
                ],
                onChanged: _replicasEnabled
                    ? (value) {
                        if (value != null) {
                          setState(() => _replicaMode = value);
                        }
                      }
                    : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Prazo'),
                      child: Text(_focusBoardShortDateLabel(_dueAt)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.outlined(
                    tooltip: 'Selecionar prazo',
                    onPressed: _pickDueDate,
                    icon: const Icon(Icons.calendar_month_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _companyLabel.isEmpty ? '' : _companyLabel,
                decoration: const InputDecoration(
                  labelText: 'Empresa vinculada',
                ),
                items: [
                  const DropdownMenuItem(value: '', child: Text('Sem empresa')),
                  for (final label in companyOptions)
                    DropdownMenuItem(value: label, child: Text(label)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _companyLabel = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Acesso e preenchimento',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              _FocusBoardAssignmentPicker(
                options: widget.assignmentOptions,
                selectedKeys: _selectedAssignmentKeys,
                onChanged: (keys) {
                  setState(() {
                    _selectedAssignmentKeys = keys;
                    if (_selectedAssignmentKeys.isNotEmpty) {
                      _visibility = _FocusBoardNoteVisibility.shared;
                    }
                  });
                },
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
        FilledButton(onPressed: _submit, child: const Text('Salvar')),
      ],
    );
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueAt,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dueAt = picked);
    }
  }

  void _submit() {
    final assignments = <_FocusBoardAssignment>[];
    final existingByKey = <String, _FocusBoardAssignment>{
      for (final assignment
          in widget.initial?.assignments ?? const <_FocusBoardAssignment>[])
        '${assignment.type.key}:${assignment.id}': assignment,
    };
    for (final option in widget.assignmentOptions) {
      if (!_selectedAssignmentKeys.contains(option.key)) {
        continue;
      }
      assignments.add(
        _assignmentPreservingState(existingByKey, option.toAssignment()),
      );
    }
    Navigator.of(context).pop(
      _FocusBoardNoteDraft(
        title: _title.text,
        description: _description.text,
        priority: _priority,
        dueAt: _dueAt,
        companyLabel: _companyLabel,
        assignments: assignments,
        visibility: _visibility,
        replicasEnabled: _replicasEnabled,
        replicaMode: _replicasEnabled
            ? _replicaMode
            : _FocusBoardReplicaMode.ownerOnly,
      ),
    );
  }

  _FocusBoardAssignment _assignmentPreservingState(
    Map<String, _FocusBoardAssignment> existingByKey,
    _FocusBoardAssignment next,
  ) {
    return existingByKey['${next.type.key}:${next.id}'] ?? next;
  }
}

class _FocusBoardAssignmentPicker extends StatefulWidget {
  const _FocusBoardAssignmentPicker({
    required this.options,
    required this.selectedKeys,
    required this.onChanged,
  });

  final List<_FocusBoardAssignmentOption> options;
  final Set<String> selectedKeys;
  final ValueChanged<Set<String>> onChanged;

  @override
  State<_FocusBoardAssignmentPicker> createState() =>
      _FocusBoardAssignmentPickerState();
}

class _FocusBoardAssignmentPickerState
    extends State<_FocusBoardAssignmentPicker> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final filtered = [
      for (final option in widget.options)
        if (query.isEmpty ||
            option.label.toLowerCase().contains(query) ||
            option.subtitle.toLowerCase().contains(query) ||
            option.type.label.toLowerCase().contains(query))
          option,
    ];
    final people = filtered
        .where((option) => option.type == _FocusBoardAssignmentType.person)
        .toList(growable: false);
    final companies = filtered
        .where((option) => option.type == _FocusBoardAssignmentType.company)
        .toList(growable: false);
    final contracts = filtered
        .where((option) => option.type == _FocusBoardAssignmentType.contract)
        .toList(growable: false);
    final groups = filtered
        .where((option) => option.type == _FocusBoardAssignmentType.group)
        .toList(growable: false);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _lineColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                isDense: true,
                prefixIcon: Icon(Icons.search_rounded),
                labelText: 'Buscar dados disponiveis',
              ),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: widget.options.isEmpty
                ? const _HubEmptyLine(
                    icon: Icons.cloud_off_outlined,
                    text: 'Nenhum vinculo da API disponivel para selecionar.',
                  )
                : ListView(
                    shrinkWrap: true,
                    children: [
                      _assignmentGroup('Pessoas', people),
                      _assignmentGroup('Empresas', companies),
                      _assignmentGroup('Contratos', contracts),
                      _assignmentGroup('Grupos', groups),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _assignmentGroup(
    String title,
    List<_FocusBoardAssignmentOption> options,
  ) {
    if (options.isEmpty) {
      return const SizedBox.shrink();
    }
    return ExpansionTile(
      initiallyExpanded: title == 'Pessoas',
      tilePadding: const EdgeInsets.symmetric(horizontal: 12),
      childrenPadding: EdgeInsets.zero,
      title: Text(
        '$title (${options.length})',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      children: [
        for (final option in options)
          CheckboxListTile(
            dense: true,
            value: widget.selectedKeys.contains(option.key),
            title: Text(option.label),
            subtitle: option.subtitle.trim().isEmpty
                ? Text(option.type.label)
                : Text(option.subtitle),
            onChanged: (checked) {
              final next = {...widget.selectedKeys};
              if (checked == true) {
                next.add(option.key);
              } else {
                next.remove(option.key);
              }
              widget.onChanged(next);
            },
          ),
      ],
    );
  }
}

class _FocusBoardFilterDialogResult {
  const _FocusBoardFilterDialogResult({
    required this.profile,
    this.save = false,
    this.reset = false,
  });

  final _FocusBoardFilterProfile profile;
  final bool save;
  final bool reset;
}

class _FocusBoardFilterDialog extends StatefulWidget {
  const _FocusBoardFilterDialog({required this.controller});

  final _FocusBoardNotesController controller;

  @override
  State<_FocusBoardFilterDialog> createState() =>
      _FocusBoardFilterDialogState();
}

class _FocusBoardFilterDialogState extends State<_FocusBoardFilterDialog> {
  late final TextEditingController _name;
  late final TextEditingController _creatorIds;
  late final TextEditingController _assignments;
  late final TextEditingController _companies;
  late bool _showTrash;
  late bool _showArchive;
  String _profileId = 'generic';

  @override
  void initState() {
    super.initState();
    final profile = widget.controller.activeFilter;
    _profileId = profile.id;
    _name = TextEditingController(text: profile.name);
    _creatorIds = TextEditingController(
      text: profile.excludedCreatorIds.join(', '),
    );
    _assignments = TextEditingController(
      text: profile.excludedAssignmentLabels.join(', '),
    );
    _companies = TextEditingController(
      text: profile.excludedCompanyLabels.join(', '),
    );
    _showTrash = profile.showTrash;
    _showArchive = profile.showArchive;
  }

  @override
  void dispose() {
    _name.dispose();
    _creatorIds.dispose();
    _assignments.dispose();
    _companies.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filtros do Focus Board'),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.controller.savedFilterProfiles.isNotEmpty) ...[
                Text(
                  'Perfis salvos',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final profile in widget.controller.savedFilterProfiles)
                      ChoiceChip(
                        label: Text(profile.name),
                        selected: profile.id == _profileId,
                        onSelected: (_) =>
                            setState(() => _loadProfile(profile)),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
              ],
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nome do perfil'),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _showTrash,
                onChanged: (value) => setState(() {
                  _showTrash = value;
                  if (value) {
                    _showArchive = false;
                  }
                }),
                title: const Text('Visualizar lixeira'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _showArchive,
                onChanged: (value) => setState(() {
                  _showArchive = value;
                  if (value) {
                    _showTrash = false;
                  }
                }),
                title: const Text('Visualizar arquivadas'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _creatorIds,
                decoration: const InputDecoration(
                  labelText: 'Excluir IDs de criadores (virgula)',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _assignments,
                decoration: const InputDecoration(
                  labelText: 'Excluir pessoas/grupos/empresas preenchiveis',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _companies,
                decoration: const InputDecoration(
                  labelText: 'Excluir empresas vinculadas',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'O perfil generico continua disponivel; ate 4 perfis podem ser salvos para consulta rapida.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _mutedColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(
            const _FocusBoardFilterDialogResult(
              profile: _FocusBoardFilterProfile.generic,
              reset: true,
            ),
          ),
          child: const Text('Perfil generico'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        OutlinedButton(
          onPressed: () => Navigator.of(
            context,
          ).pop(_FocusBoardFilterDialogResult(profile: _profileFromFields())),
          child: const Text('Aplicar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            _FocusBoardFilterDialogResult(
              profile: _profileFromFields(saveAsNew: true),
              save: true,
            ),
          ),
          child: const Text('Salvar perfil'),
        ),
      ],
    );
  }

  void _loadProfile(_FocusBoardFilterProfile profile) {
    _profileId = profile.id;
    _name.text = profile.name;
    _creatorIds.text = profile.excludedCreatorIds.join(', ');
    _assignments.text = profile.excludedAssignmentLabels.join(', ');
    _companies.text = profile.excludedCompanyLabels.join(', ');
    _showTrash = profile.showTrash;
    _showArchive = profile.showArchive;
  }

  _FocusBoardFilterProfile _profileFromFields({bool saveAsNew = false}) {
    return _FocusBoardFilterProfile(
      id: saveAsNew || _profileId == 'generic'
          ? 'filter-${DateTime.now().microsecondsSinceEpoch}'
          : _profileId,
      name: _name.text.trim().isEmpty ? 'Perfil salvo' : _name.text.trim(),
      excludedCreatorIds: _splitFilterText(_creatorIds.text),
      excludedAssignmentLabels: _splitFilterText(_assignments.text),
      excludedCompanyLabels: _splitFilterText(_companies.text),
      showTrash: _showTrash,
      showArchive: _showArchive,
    );
  }

  List<String> _splitFilterText(String value) {
    return value
        .split(',')
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }
}

class _FocusBoardAuditDialog extends StatelessWidget {
  const _FocusBoardAuditDialog({required this.note});

  final _FocusBoardNote note;

  @override
  Widget build(BuildContext context) {
    final entries = [...note.audit]
      ..sort((left, right) => right.at.compareTo(left.at));
    return AlertDialog(
      title: const Text('Auditoria da nota'),
      content: SizedBox(
        width: 620,
        child: entries.isEmpty
            ? const Text('Sem registros de auditoria.')
            : ListView.separated(
                shrinkWrap: true,
                itemCount: entries.length,
                separatorBuilder: (_, _) => const Divider(color: _lineColor),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return ListTile(
                    leading: const Icon(Icons.history_rounded),
                    title: Text('${entry.action} por ${entry.actorName}'),
                    subtitle: Text(
                      '${_focusBoardShortDateTimeLabel(entry.at)}\n${entry.details}',
                    ),
                  );
                },
              ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}

class _HubAccessNotice extends StatelessWidget {
  const _HubAccessNotice({required this.viewerProfile});

  final _ViewerAccessProfile viewerProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _tealColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: _tealColor.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Icon(viewerProfile.icon, color: _deepTealColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Previews respeitam a ACL do backend; conteudo nao autorizado nao entra neste hub.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _deepTealColor,
                height: 1.25,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HubSectionHeader extends StatelessWidget {
  const _HubSectionHeader({
    required this.icon,
    required this.title,
    required this.count,
  });

  final IconData icon;
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _slateColor, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: _inkColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        _Tag(
          label: '$count',
          icon: Icons.circle,
          color: _tealColor,
          background: _tealColor.withValues(alpha: 0.10),
        ),
      ],
    );
  }
}

class _HubReminderTile extends StatelessWidget {
  const _HubReminderTile({required this.entry, required this.onCancel});

  final _CalendarEntryRecord entry;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final color = switch (entry.priority.toUpperCase()) {
      'CRITICAL' => _roseColor,
      'HIGH' => _amberColor,
      _ => _tealColor,
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.alarm_outlined, color: color, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: _inkColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.startsAtLabel} | ${entry.statusLabel}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _mutedColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.notificationPolicyLabel}: ${entry.notificationScheduledAtLabel} | ${entry.notificationChannelsLabel}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _deepTealColor,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Cancelar lembrete',
            onPressed: onCancel,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}

class _HubAttachmentPreview extends StatelessWidget {
  const _HubAttachmentPreview({required this.attachment});

  final _AttachmentRecord attachment;

  @override
  Widget build(BuildContext context) {
    final color = _attachmentColorFor(attachment);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 132, maxWidth: 178),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_attachmentIconFor(attachment.title), color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              attachment.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _inkColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              attachment.updatedAtLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: _mutedColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HubPhotoPreview extends StatelessWidget {
  const _HubPhotoPreview({required this.attachment});

  final _AttachmentRecord attachment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
      height: 74,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _tealColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _tealColor.withValues(alpha: 0.18)),
      ),
      child: Icon(
        _attachmentIconFor(attachment.title),
        color: _tealColor,
        size: 26,
      ),
    );
  }
}

class _HubSensitiveNotePreview extends StatelessWidget {
  const _HubSensitiveNotePreview({required this.note});

  final _SensitiveNoteTag note;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: note.color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: note.color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(note.classification.icon, color: note.color, size: 19),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _inkColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  note.note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _mutedColor,
                    height: 1.24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HubEmptyLine extends StatelessWidget {
  const _HubEmptyLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _lineColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: _mutedColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _mutedColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
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
  late final TextEditingController _zipCode;
  late final TextEditingController _street;
  late final TextEditingController _number;
  late final TextEditingController _district;
  late final TextEditingController _city;
  late final TextEditingController _state;
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
    _zipCode = TextEditingController(text: initial?.zipCode ?? '');
    _street = TextEditingController(text: initial?.street ?? '');
    _number = TextEditingController(text: initial?.number ?? '');
    _district = TextEditingController(text: initial?.district ?? '');
    _city = TextEditingController(text: initial?.city ?? '');
    _state = TextEditingController(text: initial?.state ?? '');
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
    _zipCode.dispose();
    _street.dispose();
    _number.dispose();
    _district.dispose();
    _city.dispose();
    _state.dispose();
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
                Row(
                  children: [
                    Expanded(
                      child: _dialogTextField(
                        controller: _zipCode,
                        label: 'CEP',
                        icon: Icons.markunread_mailbox_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dialogTextField(
                        controller: _state,
                        label: 'Estado',
                        icon: Icons.flag_outlined,
                      ),
                    ),
                  ],
                ),
                _dialogTextField(
                  controller: _city,
                  label: 'Cidade',
                  icon: Icons.location_city_outlined,
                ),
                Row(
                  children: [
                    Expanded(
                      child: _dialogTextField(
                        controller: _street,
                        label: 'Logradouro',
                        icon: Icons.signpost_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dialogTextField(
                        controller: _number,
                        label: 'Numero',
                        icon: Icons.tag_outlined,
                      ),
                    ),
                  ],
                ),
                _dialogTextField(
                  controller: _district,
                  label: 'Bairro',
                  icon: Icons.map_outlined,
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
        'addressJson': _addressJson(),
        'notes': _notes.text,
      }),
    );
  }

  Map<String, String>? _addressJson() {
    final address = <String, String>{};
    void put(String key, String value) {
      final text = value.trim();
      if (text.isNotEmpty) {
        address[key] = key == 'state' ? text.toUpperCase() : text;
      }
    }

    put('zipCode', _zipCode.text);
    put('street', _street.text);
    put('number', _number.text);
    put('district', _district.text);
    put('city', _city.text);
    put('state', _state.text);
    return address.isEmpty ? null : address;
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

class _CalendarEntryCrudDialog extends StatefulWidget {
  const _CalendarEntryCrudDialog({
    required this.personPublicId,
    required this.personName,
    required this.profile,
    this.mode = _FocusBoardTaskMode.reminder,
  });

  final String personPublicId;
  final String personName;
  final _PersonProfileData profile;
  final _FocusBoardTaskMode mode;

  @override
  State<_CalendarEntryCrudDialog> createState() =>
      _CalendarEntryCrudDialogState();
}

class _CalendarEntryCrudDialogState extends State<_CalendarEntryCrudDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _startsAt;
  late final TextEditingController _notificationTime;
  late final TextEditingController _offsetBusinessDays;
  late final TextEditingController _holidayRegionCode;
  late final TextEditingController _appliesToStateCode;
  late final TextEditingController _appliesToCityName;
  late String _kind;
  late String _priority;
  late String _notificationPolicy;
  late Set<String> _channels;

  @override
  void initState() {
    super.initState();
    final defaultTarget = switch (widget.mode) {
      _FocusBoardTaskMode.timer => DateTime.now().add(
        const Duration(minutes: 30),
      ),
      _FocusBoardTaskMode.alarm => DateTime.now().add(const Duration(hours: 1)),
      _FocusBoardTaskMode.reminder => DateTime.now().add(
        const Duration(days: 7),
      ),
    };
    _kind = widget.mode.kind;
    _priority = widget.mode.defaultPriority;
    _notificationPolicy = widget.mode.defaultNotificationPolicy;
    _channels = {'IN_APP', 'EMAIL', 'WHATSAPP', 'SMS'};
    _title = TextEditingController(text: widget.mode.defaultTitle);
    _description = TextEditingController(text: widget.mode.defaultDescription);
    _startsAt = TextEditingController(text: _inputDateFor(defaultTarget));
    _notificationTime = TextEditingController(
      text:
          '${defaultTarget.hour.toString().padLeft(2, '0')}:'
          '${defaultTarget.minute.toString().padLeft(2, '0')}',
    );
    _offsetBusinessDays = TextEditingController(text: '2');
    _holidayRegionCode = TextEditingController(text: 'BR-SP-CAMPINAS');
    _appliesToStateCode = TextEditingController(text: 'SP');
    _appliesToCityName = TextEditingController(text: 'Campinas');
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _startsAt.dispose();
    _notificationTime.dispose();
    _offsetBusinessDays.dispose();
    _holidayRegionCode.dispose();
    _appliesToStateCode.dispose();
    _appliesToCityName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.mode.dialogTitle),
      content: SizedBox(
        width: min(MediaQuery.sizeOf(context).width - 48, 640),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: _tealColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _tealColor.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_pin_circle_outlined,
                        color: _deepTealColor,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${widget.personName} | ${widget.profile.roleTitle}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: _deepTealColor,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                _dialogTextField(
                  controller: _title,
                  label: 'Titulo',
                  icon: Icons.title_outlined,
                  required: true,
                ),
                _dialogTextField(
                  controller: _description,
                  label: 'Descricao',
                  icon: Icons.notes_outlined,
                  minLines: 3,
                  maxLines: 5,
                ),
                Row(
                  children: [
                    Expanded(child: _datePickerField(context)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dialogTextField(
                        controller: _notificationTime,
                        label: 'Hora da notificacao',
                        icon: Icons.schedule_outlined,
                        hintText: '09:00',
                        keyboardType: TextInputType.datetime,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _dialogTextField(
                        controller: _holidayRegionCode,
                        label: 'Regiao aplicavel',
                        icon: Icons.travel_explore_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dialogTextField(
                        controller: _appliesToStateCode,
                        label: 'Estado',
                        icon: Icons.flag_outlined,
                      ),
                    ),
                  ],
                ),
                _dialogTextField(
                  controller: _appliesToCityName,
                  label: 'Cidade aplicavel',
                  icon: Icons.location_on_outlined,
                ),
                Row(
                  children: [
                    Expanded(
                      child: _dialogDropdown(
                        label: 'Tipo',
                        value: _kind,
                        icon: Icons.event_note_outlined,
                        values: const ['REMINDER', 'APPOINTMENT'],
                        labels: const {
                          'REMINDER': 'Lembrete',
                          'APPOINTMENT': 'Compromisso',
                        },
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _kind = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dialogDropdown(
                        label: 'Prioridade',
                        value: _priority,
                        icon: Icons.flag_outlined,
                        values: const ['LOW', 'NORMAL', 'HIGH', 'CRITICAL'],
                        labels: const {
                          'LOW': 'Baixa',
                          'NORMAL': 'Normal',
                          'HIGH': 'Alta',
                          'CRITICAL': 'Critica',
                        },
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _priority = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                _dialogDropdown(
                  label: 'Politica de notificacao',
                  value: _notificationPolicy,
                  icon: Icons.alarm_outlined,
                  values: const [
                    'ON_DUE_DATE',
                    'ONE_BUSINESS_DAY_BEFORE',
                    'SAME_DAY_OR_PREVIOUS_BUSINESS_DAY',
                    'CUSTOM_BUSINESS_DAYS_BEFORE',
                  ],
                  labels: const {
                    'ON_DUE_DATE': 'No dia',
                    'ONE_BUSINESS_DAY_BEFORE': '1 dia util antes',
                    'SAME_DAY_OR_PREVIOUS_BUSINESS_DAY':
                        'No dia ou util anterior',
                    'CUSTOM_BUSINESS_DAYS_BEFORE': 'Dias uteis antes',
                  },
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _notificationPolicy = value);
                    }
                  },
                ),
                if (_notificationPolicy == 'CUSTOM_BUSINESS_DAYS_BEFORE')
                  _dialogTextField(
                    controller: _offsetBusinessDays,
                    label: 'Dias uteis antes',
                    icon: Icons.work_history_outlined,
                    required: true,
                    keyboardType: TextInputType.number,
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 8),
                  child: Text(
                    'Canais',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: _inkColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _channelChip('IN_APP', 'No app', Icons.notifications_none),
                    _channelChip('EMAIL', 'Email', Icons.mail_outline),
                    _channelChip('WHATSAPP', 'WhatsApp', Icons.chat_outlined),
                    _channelChip('SMS', 'SMS', Icons.sms_outlined),
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

  Widget _datePickerField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _startsAt,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Data alvo',
          prefixIcon: const Icon(Icons.event_outlined),
          suffixIcon: IconButton(
            tooltip: 'Selecionar data',
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: _pickDate,
          ),
          border: const OutlineInputBorder(),
        ),
        onTap: _pickDate,
        validator: (value) {
          final text = value?.trim() ?? '';
          if (text.isEmpty) {
            return 'Campo obrigatorio';
          }
          if (!_isValidInputDate(text)) {
            return 'Use yyyy-mm-dd';
          }
          return null;
        },
      ),
    );
  }

  Widget _channelChip(String value, String label, IconData icon) {
    final selected = _channels.contains(value);
    return FilterChip(
      selected: selected,
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onSelected: (checked) {
        setState(() {
          if (checked) {
            _channels.add(value);
          } else {
            _channels.remove(value);
          }
        });
      },
    );
  }

  Future<void> _pickDate() async {
    final current = DateTime.tryParse(_startsAt.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035, 12, 31),
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _startsAt.text = _inputDateFor(picked);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_isValidTimeInput(_notificationTime.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe a hora no formato HH:mm.')),
      );
      return;
    }

    final offset = int.tryParse(_offsetBusinessDays.text.trim()) ?? 0;
    if (_notificationPolicy == 'CUSTOM_BUSINESS_DAYS_BEFORE' &&
        (offset < 1 || offset > 30)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Use de 1 a 30 dias uteis.')),
      );
      return;
    }

    final normalizedChannels = _channels.isEmpty ? {'IN_APP'} : _channels;
    final notificationOffsetBusinessDays = switch (_notificationPolicy) {
      'ONE_BUSINESS_DAY_BEFORE' => 1,
      'CUSTOM_BUSINESS_DAYS_BEFORE' => offset,
      _ => 0,
    };

    Navigator.of(context).pop(
      _cleanMutationBody({
        'personPublicId': widget.personPublicId,
        'kind': _kind,
        'category': widget.mode.category,
        'title': _title.text,
        'description': _description.text,
        'startsAt': _startsAt.text,
        'isAllDay': true,
        'priority': _priority,
        'holidayRegionCode': _holidayRegionCode.text.toUpperCase(),
        'appliesToRegionCode': _holidayRegionCode.text.toUpperCase(),
        'appliesToStateCode': _appliesToStateCode.text.toUpperCase(),
        'appliesToCityName': _appliesToCityName.text,
        'notificationPolicy': _notificationPolicy,
        'notificationOffsetBusinessDays': notificationOffsetBusinessDays,
        'notificationTime': _notificationTime.text,
        'notificationChannels': normalizedChannels.toList(growable: false),
      }),
    );
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

bool _isImageAttachment(_AttachmentRecord attachment) {
  final lowerTitle = attachment.title.toLowerCase();
  final lowerMime = attachment.mimeType.toLowerCase();
  return lowerMime.startsWith('image/') ||
      lowerTitle.endsWith('.jpg') ||
      lowerTitle.endsWith('.jpeg') ||
      lowerTitle.endsWith('.png') ||
      lowerTitle.endsWith('.webp');
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
  return _inputDateFor(DateTime.now());
}

String _inputDateFor(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

bool _isValidTimeInput(String value) {
  return RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(value.trim());
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
    this.calendarEntries = const [],
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
  final List<_CalendarEntryRecord> calendarEntries;
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
    required this.zipCode,
    required this.street,
    required this.number,
    required this.district,
    required this.city,
    required this.state,
    required this.notes,
  });

  final String publicId;
  final String name;
  final String cpf;
  final String rg;
  final String email;
  final String phone;
  final String birthDateInput;
  final String zipCode;
  final String street;
  final String number;
  final String district;
  final String city;
  final String state;
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

class _CalendarEntryRecord {
  const _CalendarEntryRecord({
    required this.publicId,
    required this.kind,
    required this.kindLabel,
    required this.status,
    required this.statusLabel,
    required this.priority,
    required this.priorityLabel,
    required this.category,
    required this.title,
    required this.description,
    required this.startsAt,
    required this.startsAtLabel,
    required this.notificationPolicy,
    required this.notificationPolicyLabel,
    required this.notificationScheduledAt,
    required this.notificationScheduledAtLabel,
    required this.notificationChannelsLabel,
    required this.canEdit,
    required this.canCancel,
  });

  final String publicId;
  final String kind;
  final String kindLabel;
  final String status;
  final String statusLabel;
  final String priority;
  final String priorityLabel;
  final String category;
  final String title;
  final String description;
  final DateTime startsAt;
  final String startsAtLabel;
  final String notificationPolicy;
  final String notificationPolicyLabel;
  final DateTime? notificationScheduledAt;
  final String notificationScheduledAtLabel;
  final String notificationChannelsLabel;
  final bool canEdit;
  final bool canCancel;

  bool get isFocusBoardTask => category.toUpperCase().startsWith('TASK_');

  _FocusBoardTaskMode get taskMode {
    final normalized = category.toUpperCase();
    if (normalized.contains('TIMER')) {
      return _FocusBoardTaskMode.timer;
    }
    if (normalized.contains('ALARM')) {
      return _FocusBoardTaskMode.alarm;
    }
    return _FocusBoardTaskMode.reminder;
  }
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
