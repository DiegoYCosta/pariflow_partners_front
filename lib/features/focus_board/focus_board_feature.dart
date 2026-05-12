part of '../../app/app.dart';

class _FocusBoardPersistentController extends ChangeNotifier {
  _FocusBoardPersistentController({ApiClient? apiClient})
    : _repository = _PeopleApiRepository(apiClient: apiClient);

  final _PeopleApiRepository _repository;
  _PeopleRuntimeData _runtimeData = _PeopleRuntimeData.initial();
  Future<void>? _activeLoad;
  bool _requestedInitialLoad = false;
  String? _selectedPersonPublicId;

  _PeopleRuntimeData get runtimeData => _runtimeData;
  List<_EntityItem> get people => _runtimeData.data.items;

  _EntityItem? get selectedItem {
    if (people.isEmpty) {
      return null;
    }
    final selectedPublicId = _selectedPersonPublicId;
    if (selectedPublicId != null) {
      for (final item in people) {
        if (item.publicId == selectedPublicId) {
          return item;
        }
      }
    }
    return people.first;
  }

  Future<void> ensureLoaded() {
    if (_requestedInitialLoad) {
      return _activeLoad ?? Future<void>.value();
    }
    _requestedInitialLoad = true;
    return refresh();
  }

  Future<void> refresh() {
    if (_activeLoad != null) {
      return _activeLoad!;
    }

    _runtimeData = _runtimeData.copyWith(isLoading: true);
    notifyListeners();

    _activeLoad = _repository
        .loadWorkspaceData()
        .then((data) {
          _runtimeData = data;
          _normalizeSelection();
          notifyListeners();
        })
        .catchError((Object error) {
          _runtimeData = _PeopleRuntimeData.unavailable(
            message: _peopleRuntimeErrorMessage(error),
          );
          notifyListeners();
        })
        .whenComplete(() {
          _activeLoad = null;
        });

    return _activeLoad!;
  }

  void selectPerson(String publicId) {
    if (publicId.isEmpty || _selectedPersonPublicId == publicId) {
      return;
    }
    _selectedPersonPublicId = publicId;
    notifyListeners();
  }

  Future<void> createCalendarEntry(Map<String, dynamic> body) async {
    await _repository.createCalendarEntry(body);
    await refresh();
  }

  Future<void> cancelCalendarEntry(String publicId) async {
    await _repository.cancelCalendarEntry(publicId);
    await refresh();
  }

  void _normalizeSelection() {
    if (people.isEmpty) {
      _selectedPersonPublicId = null;
      return;
    }
    final selectedPublicId = _selectedPersonPublicId;
    if (selectedPublicId == null ||
        !people.any((item) => item.publicId == selectedPublicId)) {
      _selectedPersonPublicId = people.first.publicId;
    }
  }
}

class _PersistentFocusBoardDock extends StatefulWidget {
  const _PersistentFocusBoardDock({
    required this.controller,
    required this.viewerProfile,
    required this.detached,
    required this.onDetach,
  });

  final _FocusBoardPersistentController controller;
  final _ViewerAccessProfile viewerProfile;
  final bool detached;
  final VoidCallback onDetach;

  @override
  State<_PersistentFocusBoardDock> createState() =>
      _PersistentFocusBoardDockState();
}

class _PersistentFocusBoardDockState extends State<_PersistentFocusBoardDock> {
  @override
  void initState() {
    super.initState();
    widget.controller.ensureLoaded();
  }

  @override
  void didUpdateWidget(covariant _PersistentFocusBoardDock oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.controller.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.detached) {
      return const SizedBox.shrink();
    }

    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 760;
    final sideMargin = compact ? 10.0 : 18.0;
    final maxWidth = compact ? size.width - sideMargin * 2 : 410.0;
    final maxHeight = compact
        ? min(340.0, size.height - 92)
        : min(620.0, size.height - 92);

    return Positioned(
      top: 66,
      right: sideMargin,
      child: Opacity(
        opacity: 0.15,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
          child: Material(
            color: Colors.transparent,
            elevation: 0,
            child: AnimatedBuilder(
              animation: widget.controller,
              builder: (context, _) {
                return _FocusBoardRuntimeFrame(
                  controller: widget.controller,
                  viewerProfile: widget.viewerProfile,
                  compact: true,
                  onDetach: widget.onDetach,
                  onRefresh: widget.controller.refresh,
                  onCreateReminder: _openCreateReminder,
                  onCancelReminder: _confirmCancelReminder,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openCreateReminder(_EntityItem item) async {
    final profile = item.personProfile;
    if (profile == null) {
      return;
    }

    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _CalendarEntryCrudDialog(
        personPublicId: item.publicId,
        personName: item.title,
        profile: profile,
      ),
    );

    if (body == null || !mounted) {
      return;
    }

    try {
      await widget.controller.createCalendarEntry(body);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lembrete criado na Focus Board.')),
      );
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
    }
  }

  Future<void> _confirmCancelReminder(_CalendarEntryRecord entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar lembrete'),
        content: const Text(
          'O item sera marcado como cancelado, preservando historico e auditoria.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancelar item'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await widget.controller.cancelCalendarEntry(entry.publicId);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item cancelado na Focus Board.')),
      );
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
    }
  }
}

class _FocusBoardDetachedWorkspace extends StatefulWidget {
  const _FocusBoardDetachedWorkspace({
    required this.controller,
    required this.viewerProfile,
    required this.onAttach,
  });

  final _FocusBoardPersistentController controller;
  final _ViewerAccessProfile viewerProfile;
  final VoidCallback onAttach;

  @override
  State<_FocusBoardDetachedWorkspace> createState() =>
      _FocusBoardDetachedWorkspaceState();
}

class _FocusBoardDetachedWorkspaceState
    extends State<_FocusBoardDetachedWorkspace> {
  @override
  void initState() {
    super.initState();
    widget.controller.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final width = MediaQuery.sizeOf(context).width;
        final showSelector = width >= 980;
        final people = widget.controller.people;
        final selected = widget.controller.selectedItem;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            width >= 1120 ? 28 : 16,
            24,
            width >= 1120 ? 28 : 16,
            width >= 1120 ? 24 : 96,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FocusBoardDetachedHeader(
                    sourceLabel: widget.controller.runtimeData.sourceLabel,
                    isLoading: widget.controller.runtimeData.isLoading,
                    onAttach: widget.onAttach,
                    onRefresh: widget.controller.refresh,
                  ),
                  const SizedBox(height: 18),
                  if (showSelector)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 330,
                          child: _FocusBoardPeopleSelector(
                            people: people,
                            selectedPublicId: selected?.publicId,
                            onSelected: widget.controller.selectPerson,
                          ),
                        ),
                        const SizedBox(width: 22),
                        Expanded(
                          child: _FocusBoardRuntimeFrame(
                            controller: widget.controller,
                            viewerProfile: widget.viewerProfile,
                            compact: false,
                            onDetach: widget.onAttach,
                            onRefresh: widget.controller.refresh,
                            detachedLabel: 'Acoplar',
                            onCreateReminder: _openCreateReminder,
                            onCancelReminder: _confirmCancelReminder,
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _FocusBoardPeopleSelector(
                      people: people,
                      selectedPublicId: selected?.publicId,
                      onSelected: widget.controller.selectPerson,
                    ),
                    const SizedBox(height: 18),
                    _FocusBoardRuntimeFrame(
                      controller: widget.controller,
                      viewerProfile: widget.viewerProfile,
                      compact: false,
                      onDetach: widget.onAttach,
                      onRefresh: widget.controller.refresh,
                      detachedLabel: 'Acoplar',
                      onCreateReminder: _openCreateReminder,
                      onCancelReminder: _confirmCancelReminder,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openCreateReminder(_EntityItem item) async {
    final profile = item.personProfile;
    if (profile == null) {
      return;
    }

    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _CalendarEntryCrudDialog(
        personPublicId: item.publicId,
        personName: item.title,
        profile: profile,
      ),
    );

    if (body == null || !mounted) {
      return;
    }

    try {
      await widget.controller.createCalendarEntry(body);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lembrete criado na Focus Board.')),
      );
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
    }
  }

  Future<void> _confirmCancelReminder(_CalendarEntryRecord entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar lembrete'),
        content: const Text(
          'O item sera marcado como cancelado, preservando historico e auditoria.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancelar item'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await widget.controller.cancelCalendarEntry(entry.publicId);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item cancelado na Focus Board.')),
      );
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
    }
  }
}

class _FocusBoardRuntimeFrame extends StatelessWidget {
  const _FocusBoardRuntimeFrame({
    required this.controller,
    required this.viewerProfile,
    required this.compact,
    required this.onDetach,
    required this.onRefresh,
    required this.onCreateReminder,
    required this.onCancelReminder,
    this.detachedLabel,
  });

  final _FocusBoardPersistentController controller;
  final _ViewerAccessProfile viewerProfile;
  final bool compact;
  final VoidCallback onDetach;
  final VoidCallback onRefresh;
  final ValueChanged<_EntityItem> onCreateReminder;
  final ValueChanged<_CalendarEntryRecord> onCancelReminder;
  final String? detachedLabel;

  @override
  Widget build(BuildContext context) {
    final runtime = controller.runtimeData;
    final item = controller.selectedItem;
    final profile = item?.personProfile;

    if (runtime.isLoading && item == null) {
      return _FocusBoardShellCard(
        compact: compact,
        child: const _FocusBoardLoadingState(),
      );
    }

    if (item == null || profile == null) {
      return _FocusBoardShellCard(
        compact: compact,
        child: _FocusBoardEmptyState(
          message:
              runtime.errorMessage ??
              'A Focus Board ainda nao recebeu colaboradores da API.',
          onRefresh: onRefresh,
        ),
      );
    }

    final notes = [...item.sensitiveNotes]
      ..sort((left, right) => left.sortOrder.compareTo(right.sortOrder));
    final sections = _buildSensitiveSections(notes);

    return _FocusBoardShellCard(
      compact: compact,
      child: SingleChildScrollView(
        child: _FocusBoardHubPanel(
          viewerProfile: viewerProfile,
          item: item,
          profile: profile,
          attachments: item.attachments,
          sections: sections,
          calendarEntries: profile.calendarEntries,
          onAddCalendarEntry: () => onCreateReminder(item),
          onCancelCalendarEntry: onCancelReminder,
          onDetach: onDetach,
          onRefresh: onRefresh,
          detachLabel: detachedLabel,
        ),
      ),
    );
  }
}

class _FocusBoardShellCard extends StatelessWidget {
  const _FocusBoardShellCard({required this.child, required this.compact});

  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(compact ? 18 : 24),
      child: child,
    );
  }
}

class _FocusBoardLoadingState extends StatelessWidget {
  const _FocusBoardLoadingState();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Carregando Focus Board...',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: _inkColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusBoardEmptyState extends StatelessWidget {
  const _FocusBoardEmptyState({required this.message, required this.onRefresh});

  final String message;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _deepTealColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.dashboard_customize_outlined,
                  color: _deepTealColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Focus Board',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                tooltip: 'Atualizar',
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _mutedColor,
              height: 1.3,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusBoardDetachedHeader extends StatelessWidget {
  const _FocusBoardDetachedHeader({
    required this.sourceLabel,
    required this.isLoading,
    required this.onAttach,
    required this.onRefresh,
  });

  final String sourceLabel;
  final bool isLoading;
  final VoidCallback onAttach;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _deepTealColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.dashboard_customize_outlined,
              color: _deepTealColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
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
                  'Painel desacoplado compartilhando o mesmo estado do dock | $sourceLabel',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _mutedColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Atualizar',
            onPressed: isLoading ? null : onRefresh,
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: onAttach,
            icon: const Icon(Icons.call_received_rounded, size: 18),
            label: const Text('Acoplar'),
          ),
        ],
      ),
    );
  }
}

class _FocusBoardPeopleSelector extends StatelessWidget {
  const _FocusBoardPeopleSelector({
    required this.people,
    required this.selectedPublicId,
    required this.onSelected,
  });

  final List<_EntityItem> people;
  final String? selectedPublicId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Colaboradores',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: _inkColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          if (people.isEmpty)
            const _HubEmptyLine(
              icon: Icons.people_outline_rounded,
              text: 'Nenhum colaborador carregado para selecionar.',
            )
          else
            for (final item in people.take(12)) ...[
              _FocusBoardPersonOption(
                item: item,
                selected: item.publicId == selectedPublicId,
                onTap: () => onSelected(item.publicId),
              ),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }
}

class _FocusBoardPersonOption extends StatelessWidget {
  const _FocusBoardPersonOption({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _EntityItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected
              ? _tealColor.withValues(alpha: 0.10)
              : const Color(0xFFF8FAFB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? _tealColor.withValues(alpha: 0.28) : _lineColor,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: item.color.withValues(alpha: 0.13),
              child: Icon(item.icon, size: 18, color: item.color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _inkColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
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
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: _tealColor,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
