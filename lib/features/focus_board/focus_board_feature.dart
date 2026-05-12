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
    required this.visible,
    required this.resizeAxis,
    required this.extent,
    required this.panelExtent,
    required this.onExtentChanged,
    required this.onToggleVisibility,
    required this.onDetach,
    required this.onAttach,
  });

  final _FocusBoardPersistentController controller;
  final _ViewerAccessProfile viewerProfile;
  final bool detached;
  final bool visible;
  final Axis resizeAxis;
  final double extent;
  final double panelExtent;
  final ValueChanged<double> onExtentChanged;
  final VoidCallback onToggleVisibility;
  final VoidCallback onDetach;
  final VoidCallback onAttach;

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
    final sideDock = widget.resizeAxis == Axis.horizontal;
    final compact = sideDock ? widget.extent < 430 : true;
    final board = _focusBoardSlotContent(compact);

    return SizedBox(
      width: sideDock ? widget.extent : double.infinity,
      height: sideDock ? double.infinity : widget.extent,
      child: Align(
        alignment: sideDock ? Alignment.topCenter : Alignment.center,
        child: SizedBox(
          width: sideDock ? widget.extent : double.infinity,
          height: sideDock ? widget.panelExtent : widget.extent,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _paperColor.withValues(alpha: 0.94),
              border: Border(
                left: sideDock
                    ? const BorderSide(color: _lineColor)
                    : BorderSide.none,
                top: sideDock
                    ? BorderSide.none
                    : const BorderSide(color: _lineColor),
              ),
              boxShadow: [
                BoxShadow(
                  color: _inkColor.withValues(alpha: 0.08),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: sideDock
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _FocusBoardResizeHandle(
                        axis: widget.resizeAxis,
                        onDragDelta: (delta) => widget.onExtentChanged(
                          widget.extent - delta.delta.dx,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 12, 14, 14),
                          child: board,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _FocusBoardResizeHandle(
                        axis: widget.resizeAxis,
                        onDragDelta: (delta) => widget.onExtentChanged(
                          widget.extent - delta.delta.dy,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                          child: board,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _focusBoardSlotContent(bool compact) {
    if (widget.detached) {
      return _FocusBoardSlotPlaceholder(
        icon: Icons.open_in_new_rounded,
        title: 'Focus Board destacada',
        message:
            'O slot permanece reservado. Arraste a janela para ca ou use Acoplar.',
        primaryLabel: 'Acoplar',
        primaryIcon: Icons.call_received_rounded,
        onPrimary: widget.onAttach,
        onToolbarDetach: widget.onAttach,
        onToolbarAttach: widget.onAttach,
        detached: true,
        visible: widget.visible,
        onToggleVisibility: widget.onToggleVisibility,
      );
    }

    if (!widget.visible) {
      return _FocusBoardSlotPlaceholder(
        icon: Icons.visibility_off_outlined,
        title: 'Focus Board oculta',
        message:
            'O conteudo deste slot esta oculto, mas o espaco continua reservado.',
        primaryLabel: 'Mostrar',
        primaryIcon: Icons.visibility_outlined,
        onPrimary: widget.onToggleVisibility,
        onToolbarDetach: widget.onDetach,
        onToolbarAttach: widget.onAttach,
        detached: false,
        visible: widget.visible,
        onToggleVisibility: widget.onToggleVisibility,
      );
    }

    return Column(
      children: [
        _FocusBoardSlotToolbar(
          visible: widget.visible,
          detached: widget.detached,
          onToggleVisibility: widget.onToggleVisibility,
          onDetach: widget.onDetach,
          onAttach: widget.onAttach,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Material(
            color: Colors.transparent,
            elevation: 0,
            child: AnimatedBuilder(
              animation: widget.controller,
              builder: (context, _) {
                return _FocusBoardRuntimeFrame(
                  controller: widget.controller,
                  viewerProfile: widget.viewerProfile,
                  compact: compact,
                  onDetach: widget.onDetach,
                  onRefresh: widget.controller.refresh,
                  onCreateReminder: _openCreateReminder,
                  onCancelReminder: _confirmCancelReminder,
                );
              },
            ),
          ),
        ),
      ],
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

class _FocusBoardSlotToolbar extends StatelessWidget {
  const _FocusBoardSlotToolbar({
    required this.visible,
    required this.detached,
    required this.onToggleVisibility,
    required this.onDetach,
    required this.onAttach,
  });

  final bool visible;
  final bool detached;
  final VoidCallback onToggleVisibility;
  final VoidCallback onDetach;
  final VoidCallback onAttach;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Row(
        children: [
          const Icon(
            Icons.dashboard_customize_outlined,
            color: _deepTealColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Focus Board',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: _inkColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            tooltip: visible ? 'Ocultar slot' : 'Mostrar slot',
            onPressed: onToggleVisibility,
            icon: Icon(
              visible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 18,
            ),
          ),
          IconButton(
            tooltip: detached ? 'Acoplar Focus Board' : 'Destacar Focus Board',
            onPressed: detached ? onAttach : onDetach,
            icon: Icon(
              detached
                  ? Icons.call_received_rounded
                  : Icons.open_in_full_rounded,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusBoardSlotPlaceholder extends StatelessWidget {
  const _FocusBoardSlotPlaceholder({
    required this.icon,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.primaryIcon,
    required this.onPrimary,
    required this.onToolbarDetach,
    required this.onToolbarAttach,
    required this.detached,
    required this.visible,
    required this.onToggleVisibility,
  });

  final IconData icon;
  final String title;
  final String message;
  final String primaryLabel;
  final IconData primaryIcon;
  final VoidCallback onPrimary;
  final VoidCallback onToolbarDetach;
  final VoidCallback onToolbarAttach;
  final bool detached;
  final bool visible;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FocusBoardSlotToolbar(
          visible: visible,
          detached: detached,
          onToggleVisibility: onToggleVisibility,
          onDetach: onToolbarDetach,
          onAttach: onToolbarAttach,
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _deepTealColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: _deepTealColor, size: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _inkColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _mutedColor,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: onPrimary,
                    icon: Icon(primaryIcon, size: 18),
                    label: Text(primaryLabel),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FocusBoardResizeHandle extends StatelessWidget {
  const _FocusBoardResizeHandle({
    required this.axis,
    required this.onDragDelta,
  });

  final Axis axis;
  final ValueChanged<DragUpdateDetails> onDragDelta;

  @override
  Widget build(BuildContext context) {
    final horizontal = axis == Axis.horizontal;
    return MouseRegion(
      cursor: horizontal
          ? SystemMouseCursors.resizeColumn
          : SystemMouseCursors.resizeRow,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: horizontal ? onDragDelta : null,
        onVerticalDragUpdate: horizontal ? null : onDragDelta,
        child: SizedBox(
          width: horizontal ? 12 : double.infinity,
          height: horizontal ? double.infinity : 12,
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _mutedColor.withValues(alpha: 0.42),
                borderRadius: BorderRadius.circular(99),
              ),
              child: SizedBox(
                width: horizontal ? 3 : 54,
                height: horizontal ? 54 : 3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FocusBoardFloatingWindow extends StatelessWidget {
  const _FocusBoardFloatingWindow({
    required this.controller,
    required this.viewerProfile,
    required this.maximized,
    required this.onMove,
    required this.onMoveEnd,
    required this.onResize,
    required this.onToggleMaximized,
    required this.onAttach,
  });

  final _FocusBoardPersistentController controller;
  final _ViewerAccessProfile viewerProfile;
  final bool maximized;
  final ValueChanged<Offset> onMove;
  final VoidCallback onMoveEnd;
  final ValueChanged<Offset> onResize;
  final VoidCallback onToggleMaximized;
  final VoidCallback onAttach;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 18,
      borderRadius: BorderRadius.circular(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _paperColor,
            border: Border.all(color: _lineColor),
            boxShadow: [
              BoxShadow(
                color: _inkColor.withValues(alpha: 0.18),
                blurRadius: 32,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.move,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (details) => onMove(details.delta),
                  onPanEnd: (_) => onMoveEnd(),
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    color: const Color(0xFFF7FAF8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.drag_indicator_rounded,
                          color: _mutedColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.dashboard_customize_outlined,
                          color: _deepTealColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Focus Board',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: _inkColor,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        IconButton(
                          tooltip: maximized ? 'Restaurar' : 'Maximizar',
                          onPressed: onToggleMaximized,
                          icon: Icon(
                            maximized
                                ? Icons.fullscreen_exit_rounded
                                : Icons.fullscreen_rounded,
                            size: 18,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Acoplar no slot',
                          onPressed: onAttach,
                          icon: const Icon(
                            Icons.call_received_rounded,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _FocusBoardDetachedWorkspace(
                  controller: controller,
                  viewerProfile: viewerProfile,
                  onAttach: onAttach,
                  showHeader: false,
                ),
              ),
              if (!maximized)
                Align(
                  alignment: Alignment.bottomRight,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeDownRight,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanUpdate: (details) => onResize(details.delta),
                      child: const SizedBox(
                        width: 24,
                        height: 18,
                        child: Icon(
                          Icons.drag_handle_rounded,
                          color: _mutedColor,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FocusBoardDetachedWorkspace extends StatefulWidget {
  const _FocusBoardDetachedWorkspace({
    required this.controller,
    required this.viewerProfile,
    required this.onAttach,
    this.showHeader = true,
  });

  final _FocusBoardPersistentController controller;
  final _ViewerAccessProfile viewerProfile;
  final VoidCallback onAttach;
  final bool showHeader;

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
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.sizeOf(context).width;
            final showSelector = width >= 980;
            final runtimeMaxWidth = showSelector ? 760.0 : double.infinity;
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
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.showHeader) ...[
                        _FocusBoardDetachedHeader(
                          sourceLabel:
                              widget.controller.runtimeData.sourceLabel,
                          isLoading: widget.controller.runtimeData.isLoading,
                          onAttach: widget.onAttach,
                          onRefresh: widget.controller.refresh,
                        ),
                        const SizedBox(height: 18),
                      ],
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
                            Flexible(
                              fit: FlexFit.loose,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: runtimeMaxWidth,
                                ),
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
        child: const _FocusBoardResponsiveViewport(
          compact: true,
          child: _FocusBoardLoadingState(),
        ),
      );
    }

    if (item == null || profile == null) {
      return _FocusBoardShellCard(
        compact: compact,
        child: _FocusBoardResponsiveViewport(
          compact: compact,
          child: _FocusBoardEmptyState(
            message:
                runtime.errorMessage ??
                'A Focus Board ainda nao recebeu colaboradores da API.',
            onRefresh: onRefresh,
          ),
        ),
      );
    }

    final notes = [...item.sensitiveNotes]
      ..sort((left, right) => left.sortOrder.compareTo(right.sortOrder));
    final sections = _buildSensitiveSections(notes);

    return _FocusBoardShellCard(
      compact: compact,
      child: _FocusBoardResponsiveViewport(
        compact: compact,
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

class _FocusBoardResponsiveViewport extends StatelessWidget {
  const _FocusBoardResponsiveViewport({
    required this.compact,
    required this.child,
  });

  final bool compact;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : (compact ? 380.0 : 680.0);
        final availableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : double.infinity;
        final effectiveCompact = compact || availableWidth < 520;
        final designWidth = effectiveCompact ? 380.0 : 680.0;
        final preferredHeight = effectiveCompact ? 560.0 : 680.0;
        final widthScale = availableWidth / designWidth;
        final heightScale = availableHeight.isFinite
            ? availableHeight / preferredHeight
            : 1.0;
        final scale = min(
          1.0,
          min(widthScale, heightScale),
        ).clamp(0.72, 1.0).toDouble();

        return ClipRect(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Align(
              alignment: Alignment.topLeft,
              widthFactor: scale,
              heightFactor: scale,
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.topLeft,
                child: SizedBox(width: designWidth, child: child),
              ),
            ),
          ),
        );
      },
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
                  'Focus Board | $sourceLabel',
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
