part of '../../../app/app.dart';

class _NetworkWorkspace extends StatelessWidget {
  const _NetworkWorkspace({
    required this.title,
    required this.subtitle,
    required this.filters,
    required this.showAdvancedFilters,
    required this.selectedNodeId,
    required this.hoveredNodeId,
    required this.compact,
    required this.onFiltersChanged,
    required this.onToggleAdvancedFilters,
    required this.onSelectNode,
    required this.onHoverNode,
    required this.onOpenEmployeeProfile,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String subtitle;
  final _NetworkFilterState filters;
  final bool showAdvancedFilters;
  final String selectedNodeId;
  final String? hoveredNodeId;
  final bool compact;
  final ValueChanged<_NetworkFilterState> onFiltersChanged;
  final VoidCallback onToggleAdvancedFilters;
  final ValueChanged<String> onSelectNode;
  final ValueChanged<String?> onHoverNode;
  final ValueChanged<String> onOpenEmployeeProfile;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _Panel(
        padding: const EdgeInsets.all(28),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 960;
            final content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Tag(
                  label: 'dados locais desativados',
                  icon: Icons.pause_circle_outline_rounded,
                  color: _amberColor,
                  background: _amberColor.withValues(alpha: 0.12),
                ),
                const SizedBox(height: 18),
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: _mutedColor),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _Tag(
                      label: 'dados reais exigidos',
                      icon: Icons.cloud_done_outlined,
                      color: _tealColor,
                      background: _tealColor.withValues(alpha: 0.12),
                    ),
                    _Tag(
                      label: 'sem dados locais',
                      icon: Icons.block_rounded,
                      color: _slateColor,
                      background: _slateColor.withValues(alpha: 0.12),
                    ),
                  ],
                ),
              ],
            );

            final action = FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.open_in_full_rounded),
              label: Text(actionLabel),
            );

            if (stacked) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [content, const SizedBox(height: 22), action],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: content),
                const SizedBox(width: 24),
                action,
              ],
            );
          },
        ),
      );
    }

    return _RelationalNetworkWorkspaceBody(
      selectedNodeId: selectedNodeId,
      onSelectNode: onSelectNode,
      onOpenEmployeeProfile: onOpenEmployeeProfile,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}

enum _NetworkWorkspaceMode {
  timeline(
    label: 'Timeline',
    icon: Icons.timeline_outlined,
    tooltip: 'Visualizar contratos, postos e alocacoes no tempo',
  ),
  current(
    label: 'Atual',
    icon: Icons.account_tree_outlined,
    tooltip: 'Visualizar a hierarquia ativa na data de referencia',
  ),
  relational(
    label: 'Relacional',
    icon: Icons.hub_outlined,
    tooltip: 'Manter o grafo relacional atual',
  );

  const _NetworkWorkspaceMode({
    required this.label,
    required this.icon,
    required this.tooltip,
  });

  final String label;
  final IconData icon;
  final String tooltip;
}

enum _NetworkTimelineSelectionKind { contract, position, collaborator, event }

class _NetworkTimelineSelection {
  const _NetworkTimelineSelection({required this.kind, required this.publicId});

  final _NetworkTimelineSelectionKind kind;
  final String publicId;

  String get signature => '${kind.name}:$publicId';
}

class _RelationalNetworkWorkspaceBody extends StatefulWidget {
  const _RelationalNetworkWorkspaceBody({
    required this.selectedNodeId,
    required this.onSelectNode,
    required this.onOpenEmployeeProfile,
    required this.actionLabel,
    required this.onAction,
  });

  final String selectedNodeId;
  final ValueChanged<String> onSelectNode;
  final ValueChanged<String> onOpenEmployeeProfile;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  State<_RelationalNetworkWorkspaceBody> createState() =>
      _RelationalNetworkWorkspaceBodyState();
}

class _RelationalNetworkWorkspaceBodyState
    extends State<_RelationalNetworkWorkspaceBody> {
  static const double _minCanvasZoom = 0.65;
  static const double _maxCanvasZoom = 1.85;

  final _NetworkApiRepository _repository = _NetworkApiRepository();
  late final TextEditingController _searchController;
  final TransformationController _canvasController = TransformationController();
  _NetworkRuntimeData _runtimeData = _NetworkRuntimeData.initial();
  _NetworkTimelineRuntimeData _timelineRuntimeData =
      _NetworkTimelineRuntimeData.initial();
  late String _periodPreset;
  late Set<String> _selectedRootIds;
  late Set<String> _selectedClientIds;
  late Set<String> _contractStatuses;
  late Set<String> _employeeStatuses;
  late Set<String> _selectedDepartments;
  late Set<String> _selectedPositions;
  late bool _includeHistorical;
  late bool _includeIndirect;
  bool _includeTimelineMoves = true;
  bool _includeTimelineOperationalEvents = true;
  DateTimeRange? _timelineDateRange;
  _NetworkTenurePreset? _selectedTenurePreset;
  RangeValues? _customTenureYears;
  _NetworkHireDateRange? _hireDateRange;
  _NetworkReportPreset? _reportPreset;
  bool _attentionOnly = false;
  bool _clusterEmployees = true;
  bool _showFilters = false;
  bool _showDetailPanel = true;
  _NetworkWorkspaceMode _workspaceMode = _NetworkWorkspaceMode.relational;
  _NetworkTimelineSelection? _timelineSelection;
  double _zoom = 1.0;
  Size _canvasViewportSize = Size.zero;
  _NetworkGraphLane? _selectedLaneForDetails;
  String? _drillDownNodeId;
  final Set<_NetworkGraphLane> _hiddenLanes = {};
  final Set<_NetworkGraphLane> _activeOnlyLanes = {};
  final List<_NetworkHistoryEntry> _history = [];
  int _historyIndex = -1;
  bool _restoringHistory = false;

  _NetworkGraphPayload get _payload => _runtimeData.payload;

  List<_VisualIdentityLegendEntry> _networkVisualLegendEntries(
    List<_NetworkGraphNode> nodes,
  ) {
    final counts = <_NetworkGraphLane, int>{
      for (final lane in _payload.lanes) lane: 0,
    };
    for (final node in nodes) {
      counts[node.lane] = (counts[node.lane] ?? 0) + 1;
    }

    return [
      for (final lane in _payload.lanes)
        _VisualIdentityLegendEntry(
          identity: _visualIdentityForNetworkLane(lane),
          label: _laneLabel(lane),
          count: counts[lane] ?? 0,
          selected: _selectedLaneForDetails == lane,
          showMarker: false,
          useIdentityColor: false,
          onTap: () {
            setState(() {
              _selectedLaneForDetails = _selectedLaneForDetails == lane
                  ? null
                  : lane;
              _showDetailPanel = true;
            });
          },
        ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: _payload.filters.search);
    _applyPayloadDefaults(_payload);
    WidgetsBinding.instance.addPostFrameCallback((_) => _pushHistoryState());
    _loadNetworkGraph(resetFilters: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _canvasController.dispose();
    super.dispose();
  }

  void _setPeriodPreset(String preset) {
    setState(() {
      _periodPreset = preset;
      _timelineDateRange = null;
      if (preset == '6m') {
        _includeHistorical = false;
      } else if (preset == '1y') {
        _includeHistorical = true;
      }
    });
    _pushHistoryState();
  }

  Future<void> _loadNetworkGraph({bool resetFilters = false}) async {
    setState(() {
      _runtimeData = _runtimeData.copyWith(isLoading: true);
      _timelineRuntimeData = _timelineRuntimeData.copyWith(isLoading: true);
    });

    try {
      final payload = await _repository.loadGraph(
        periodPreset: _periodPreset,
        rootCompanyPublicIds: _selectedRootIds,
        clientCompanyPublicIds: _selectedClientIds,
        contractStatuses: _contractStatuses,
        employeeStatuses: _employeeStatuses,
        includeHistorical: _includeHistorical,
        includeIndirect: _includeIndirect,
        search: _remoteNetworkSearchText(_searchController.text),
        focusPublicId: widget.selectedNodeId,
      );

      if (!mounted) {
        return;
      }

      late final _NetworkTimelineRuntimeData nextTimelineRuntimeData;
      try {
        final timelinePayload = await _repository.loadTimeline(
          periodPreset: _periodPreset,
          customPeriod: _timelineDateRange,
          rootCompanyPublicIds: _selectedRootIds,
          clientCompanyPublicIds: _selectedClientIds,
          contractStatuses: _contractStatuses,
          employeeStatuses: _employeeStatuses,
          includeHistorical: _includeHistorical,
          includeMoves: _includeTimelineMoves,
          includeOperationalEvents: _includeTimelineOperationalEvents,
          search: _remoteNetworkSearchText(_searchController.text),
          focusCompanyPublicId: _timelineFocusCompanyPublicId(payload),
          focusCompanyType: _timelineFocusCompanyType(payload),
        );
        nextTimelineRuntimeData = _NetworkTimelineRuntimeData.live(
          timelinePayload,
        );
      } catch (timelineError) {
        nextTimelineRuntimeData = _NetworkTimelineRuntimeData.unavailable(
          message: _networkTimelineRuntimeErrorMessage(timelineError),
        );
      }

      final nextRuntimeData = payload.nodes.isEmpty
          ? _NetworkRuntimeData.empty(
              message:
                  'API conectada, mas o grafo nao retornou nos para este recorte. Nenhum dado mock foi carregado.',
            )
          : _NetworkRuntimeData.live(payload);

      setState(() {
        _runtimeData = nextRuntimeData;
        _timelineRuntimeData = nextTimelineRuntimeData;
        if (resetFilters) {
          _searchController.text = payload.filters.search;
          _applyPayloadDefaults(payload);
        }
      });
      _pushHistoryState();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _runtimeData = _NetworkRuntimeData.unavailable(
          message: _networkRuntimeErrorMessage(error),
        );
        _timelineRuntimeData = _NetworkTimelineRuntimeData.unavailable(
          message: _networkTimelineRuntimeErrorMessage(error),
        );
        if (resetFilters) {
          _searchController.text = _payload.filters.search;
          _applyPayloadDefaults(_payload);
        }
      });
      _pushHistoryState();
    }
  }

  String _timelineFocusCompanyPublicId(_NetworkGraphPayload payload) {
    final selectedNode = payload.nodeByPublicId(widget.selectedNodeId);

    if (selectedNode == null) {
      return '';
    }

    return switch (selectedNode.lane) {
      _NetworkGraphLane.rootCompany => selectedNode.publicId,
      _NetworkGraphLane.clientCompany => selectedNode.publicId,
      _ => '',
    };
  }

  String _timelineFocusCompanyType(_NetworkGraphPayload payload) {
    final selectedNode = payload.nodeByPublicId(widget.selectedNodeId);

    return switch (selectedNode?.lane) {
      _NetworkGraphLane.rootCompany => 'provider_company',
      _NetworkGraphLane.clientCompany => 'client_company',
      _ => '',
    };
  }

  void _applyPayloadDefaults(_NetworkGraphPayload payload) {
    _periodPreset = payload.filters.applied.periodPreset;
    _selectedRootIds = {...payload.filters.applied.rootCompanyPublicIds};
    _selectedClientIds = {...payload.filters.applied.clientCompanyPublicIds};
    _contractStatuses = {...payload.filters.applied.contractStatuses};
    _employeeStatuses = {...payload.filters.applied.employeeStatuses};
    _selectedDepartments = {};
    _selectedPositions = {};
    _includeHistorical = payload.filters.applied.includeHistorical;
    _includeIndirect = payload.filters.applied.includeIndirect;
    _includeTimelineMoves = true;
    _includeTimelineOperationalEvents = true;
    _timelineDateRange = null;
    _selectedTenurePreset = null;
    _customTenureYears = null;
    _hireDateRange = null;
    _reportPreset = null;
    _attentionOnly = false;
    _clusterEmployees = true;
    _selectedLaneForDetails = null;
    _drillDownNodeId = null;
    _timelineSelection = null;
    _hiddenLanes.clear();
    _activeOnlyLanes.clear();
  }

  void _adjustZoom(double delta) {
    _setCanvasScale(
      _zoom + delta,
      focalPoint: _canvasViewportSize == Size.zero
          ? null
          : Offset(
              _canvasViewportSize.width / 2,
              _canvasViewportSize.height / 2,
            ),
    );
  }

  void _resetViewport() {
    setState(() {
      _canvasController.value = Matrix4.identity();
      _zoom = 1.0;
    });
    _pushHistoryState();
  }

  void _setCanvasScale(double scale, {Offset? focalPoint}) {
    final nextScale = scale.clamp(_minCanvasZoom, _maxCanvasZoom).toDouble();
    final viewportFocalPoint =
        focalPoint ??
        Offset(_canvasViewportSize.width / 2, _canvasViewportSize.height / 2);
    final sceneFocalPoint = _canvasController.toScene(viewportFocalPoint);
    final matrix = Matrix4.identity()
      ..translateByDouble(
        viewportFocalPoint.dx - (sceneFocalPoint.dx * nextScale),
        viewportFocalPoint.dy - (sceneFocalPoint.dy * nextScale),
        0,
        1,
      )
      ..scaleByDouble(nextScale, nextScale, 1, 1);

    setState(() {
      _canvasController.value = matrix;
      _zoom = nextScale;
    });
    _pushHistoryState();
  }

  void _syncZoomFromCanvas({bool force = false}) {
    final nextZoom = _canvasController.value
        .getMaxScaleOnAxis()
        .clamp(_minCanvasZoom, _maxCanvasZoom)
        .toDouble();
    if (!force && (nextZoom - _zoom).abs() < 0.005) {
      return;
    }
    setState(() {
      _zoom = nextZoom;
    });
  }

  void _centerCanvasOn(Rect rect, Size viewportSize) {
    final nextScale = max(_zoom, 1.0);
    final matrix = Matrix4.identity()
      ..translateByDouble(
        (viewportSize.width / 2) - (rect.center.dx * nextScale),
        (viewportSize.height / 2) - (rect.center.dy * nextScale),
        0,
        1,
      )
      ..scaleByDouble(nextScale, nextScale, 1, 1);

    setState(() {
      _canvasViewportSize = viewportSize;
      _canvasController.value = matrix;
      _zoom = nextScale;
    });
    _pushHistoryState();
  }

  void _restoreFilters() {
    setState(() {
      _searchController.text = _payload.filters.search;
      _applyPayloadDefaults(_payload);
    });
    _pushHistoryState();
  }

  void _toggleDepartmentFacet(String value) {
    setState(() {
      _toggleInSet(_selectedDepartments, value);
      _selectedLaneForDetails = null;
    });
    _pushHistoryState();
  }

  void _togglePositionFacet(String value) {
    setState(() {
      _toggleInSet(_selectedPositions, value);
      _selectedLaneForDetails = null;
    });
    _pushHistoryState();
  }

  void _toggleCompanyFacet(_NetworkCompanyFacetValue value) {
    setState(() {
      switch (value.type) {
        case _NetworkCompanyFacetType.root:
          _toggleInSet(_selectedRootIds, value.publicId);
          break;
        case _NetworkCompanyFacetType.client:
          _toggleInSet(_selectedClientIds, value.publicId);
          break;
      }
      _selectedLaneForDetails = null;
    });
    _pushHistoryState();
  }

  void _toggleStatusFacet(_NetworkStatusFacetValue value) {
    setState(() {
      switch (value.type) {
        case _NetworkStatusFacetType.contract:
          _toggleInSet(_contractStatuses, value.status);
          break;
        case _NetworkStatusFacetType.employee:
          _toggleInSet(_employeeStatuses, value.status);
          break;
      }
      _selectedLaneForDetails = null;
    });
    _pushHistoryState();
  }

  void _applyTenurePreset(_NetworkTenurePreset? preset) {
    setState(() {
      _selectedTenurePreset = preset;
      _customTenureYears = null;
      _selectedLaneForDetails = null;
    });
    _pushHistoryState();
  }

  void _applyCustomTenure(RangeValues? range) {
    setState(() {
      _customTenureYears = range;
      _selectedTenurePreset = null;
      _selectedLaneForDetails = null;
    });
    _pushHistoryState();
  }

  void _applyHireDateRange(_NetworkHireDateRange? range) {
    setState(() {
      _hireDateRange = range;
      _selectedLaneForDetails = null;
    });
    _pushHistoryState();
  }

  void _applyTimelineDateRange(DateTimeRange? range) {
    setState(() {
      _timelineDateRange = range;
      _timelineSelection = null;
    });
    _pushHistoryState();
  }

  Future<void> _openTimelineDateRangePicker() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initialRange =
        _timelineDateRange ??
        DateTimeRange(start: _addMonths(today, -12), end: today);
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1970),
      lastDate: DateTime(today.year + 5, 12, 31),
      initialDateRange: initialRange,
      helpText: 'Intervalo da timeline',
      saveText: 'Aplicar',
    );

    if (range != null) {
      _applyTimelineDateRange(
        DateTimeRange(
          start: DateTime(range.start.year, range.start.month, range.start.day),
          end: DateTime(range.end.year, range.end.month, range.end.day),
        ),
      );
    }
  }

  void _applyReportPreset(_NetworkReportPreset? preset) {
    setState(() {
      _reportPreset = preset;
      _selectedLaneForDetails = null;
    });
    _pushHistoryState();
  }

  void _toggleClusterEmployees() {
    setState(() {
      _clusterEmployees = !_clusterEmployees;
    });
    _pushHistoryState();
  }

  void _clearAnalysisFilters() {
    setState(() {
      _searchController.clear();
      _selectedRootIds.clear();
      _selectedClientIds.clear();
      _contractStatuses = {..._payload.filters.available.contractStatuses};
      _employeeStatuses = {..._payload.filters.available.employeeStatuses};
      _selectedDepartments.clear();
      _selectedPositions.clear();
      _selectedTenurePreset = null;
      _customTenureYears = null;
      _hireDateRange = null;
      _timelineDateRange = null;
      _includeTimelineMoves = true;
      _includeTimelineOperationalEvents = true;
      _reportPreset = null;
      _attentionOnly = false;
      _drillDownNodeId = null;
      _selectedLaneForDetails = null;
    });
    _pushHistoryState();
  }

  void _focusNodeNeighborhood(String publicId) {
    setState(() {
      _drillDownNodeId = _drillDownNodeId == publicId ? null : publicId;
      _selectedLaneForDetails = null;
      _showDetailPanel = true;
    });
    widget.onSelectNode(publicId);
    _pushHistoryState(selectedNodeId: publicId);
  }

  void _pushHistoryState({String? selectedNodeId}) {
    if (_restoringHistory || !mounted) {
      return;
    }
    final entry = _NetworkHistoryEntry.capture(
      search: _searchController.text,
      selectedNodeId: selectedNodeId ?? widget.selectedNodeId,
      matrix: _canvasController.value,
      zoom: _zoom,
      periodPreset: _periodPreset,
      selectedRootIds: _selectedRootIds,
      selectedClientIds: _selectedClientIds,
      contractStatuses: _contractStatuses,
      employeeStatuses: _employeeStatuses,
      selectedDepartments: _selectedDepartments,
      selectedPositions: _selectedPositions,
      includeHistorical: _includeHistorical,
      includeIndirect: _includeIndirect,
      includeTimelineMoves: _includeTimelineMoves,
      includeTimelineOperationalEvents: _includeTimelineOperationalEvents,
      timelineDateRange: _timelineDateRange,
      selectedTenurePreset: _selectedTenurePreset,
      customTenureYears: _customTenureYears,
      hireDateRange: _hireDateRange,
      reportPreset: _reportPreset,
      attentionOnly: _attentionOnly,
      clusterEmployees: _clusterEmployees,
      drillDownNodeId: _drillDownNodeId,
      workspaceMode: _workspaceMode,
      hiddenLanes: _hiddenLanes,
      activeOnlyLanes: _activeOnlyLanes,
    );

    if (_historyIndex >= 0 &&
        _historyIndex < _history.length &&
        _history[_historyIndex].signature == entry.signature) {
      return;
    }

    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }
    _history.add(entry);
    if (_history.length > 40) {
      _history.removeAt(0);
    }
    _historyIndex = _history.length - 1;
  }

  bool get _canGoBack => _historyIndex > 0;

  bool get _canGoForward =>
      _historyIndex >= 0 && _historyIndex < _history.length - 1;

  void _goHistory(int delta) {
    final nextIndex = _historyIndex + delta;
    if (nextIndex < 0 || nextIndex >= _history.length) {
      return;
    }
    final entry = _history[nextIndex];
    _restoringHistory = true;
    setState(() {
      _historyIndex = nextIndex;
      _searchController.text = entry.search;
      _canvasController.value = Matrix4.copy(entry.matrix);
      _zoom = entry.zoom;
      _periodPreset = entry.periodPreset;
      _selectedRootIds = {...entry.selectedRootIds};
      _selectedClientIds = {...entry.selectedClientIds};
      _contractStatuses = {...entry.contractStatuses};
      _employeeStatuses = {...entry.employeeStatuses};
      _selectedDepartments = {...entry.selectedDepartments};
      _selectedPositions = {...entry.selectedPositions};
      _includeHistorical = entry.includeHistorical;
      _includeIndirect = entry.includeIndirect;
      _includeTimelineMoves = entry.includeTimelineMoves;
      _includeTimelineOperationalEvents =
          entry.includeTimelineOperationalEvents;
      _timelineDateRange = entry.timelineDateRange;
      _selectedTenurePreset = entry.selectedTenurePreset;
      _customTenureYears = entry.customTenureYears;
      _hireDateRange = entry.hireDateRange;
      _reportPreset = entry.reportPreset;
      _attentionOnly = entry.attentionOnly;
      _clusterEmployees = entry.clusterEmployees;
      _drillDownNodeId = entry.drillDownNodeId;
      _workspaceMode = entry.workspaceMode;
      _hiddenLanes
        ..clear()
        ..addAll(entry.hiddenLanes);
      _activeOnlyLanes
        ..clear()
        ..addAll(entry.activeOnlyLanes);
      _selectedLaneForDetails = null;
    });
    _restoringHistory = false;
    widget.onSelectNode(entry.selectedNodeId);
  }

  Future<void> _openCustomTenureDialog() async {
    final initial = _customTenureYears ?? const RangeValues(0, 10);
    final range = await showDialog<RangeValues>(
      context: context,
      builder: (context) => _NetworkTenureRangeDialog(initialRange: initial),
    );
    if (range != null) {
      _applyCustomTenure(range);
    }
  }

  Future<void> _openHireDateRangeDialog() async {
    final range = await showDialog<_NetworkHireDateRange>(
      context: context,
      builder: (context) =>
          _NetworkHireDateRangeDialog(initialRange: _hireDateRange),
    );
    if (range != null) {
      _applyHireDateRange(range);
    }
  }

  Future<void> _openManagementReport(
    _NetworkManagementReportDefinition definition,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _NetworkManagementReportDialog(
        payload: _payload,
        definition: definition,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final view = _filteredView();
    final selectedNode = view.selectedNodeFor(widget.selectedNodeId);
    final searchQuery = _NetworkSearchQuery.parse(_searchController.text);
    final insightData = _RelationalInsightData.fromPayload(
      payload: _payload,
      view: view,
    );
    final viewportHeight = MediaQuery.sizeOf(context).height;
    final workspaceHeight = max(760.0, viewportHeight - 54);

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1180;
        final graphSection = _buildGraphSection(
          context,
          compact: !wide,
          view: view,
          selectedNode: _selectedLaneForDetails == null ? selectedNode : null,
          detailPanelCollapsed: !_showDetailPanel,
          onReopenDetailPanel: () {
            setState(() {
              _showDetailPanel = true;
            });
          },
          selectedLaneForDetails: _selectedLaneForDetails,
          hiddenLanes: _hiddenLanes,
          activeOnlyLanes: _activeOnlyLanes,
          onSelectLane: (lane) {
            setState(() {
              _selectedLaneForDetails = lane;
              _showDetailPanel = true;
            });
          },
        );
        final detailPanel = _buildDetailPanel(
          context,
          selectedNode: selectedNode,
        );
        final timelineSection = _NetworkTimelineCanvasSection(
          payload: _timelineRuntimeData.payload,
          runtimeData: _timelineRuntimeData,
          controller: _canvasController,
          selectedItem: _timelineSelection,
          onViewportChanged: (size) {
            _canvasViewportSize = size;
          },
          onInteractionUpdate: () => _syncZoomFromCanvas(force: true),
          onInteractionEnd: () {
            _syncZoomFromCanvas(force: true);
            _pushHistoryState();
          },
          onSelectItem: (selection) {
            setState(() {
              _timelineSelection = selection;
              _showDetailPanel = true;
            });
          },
          onRetry: () => _loadNetworkGraph(resetFilters: true),
        );
        final timelineDetailPanel = _NetworkTimelineDetailPanel(
          payload: _timelineRuntimeData.payload,
          selectedItem: _timelineSelection,
          onSelectItem: (selection) {
            setState(() {
              _timelineSelection = selection;
            });
          },
          onClose: () {
            setState(() {
              _showDetailPanel = false;
            });
          },
        );
        final currentSection = _NetworkCurrentSnapshotSection(
          runtimeData: _timelineRuntimeData,
          onRetry: () => _loadNetworkGraph(resetFilters: true),
        );

        return SizedBox(
          height: workspaceHeight,
          child: DecoratedBox(
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              children: [
                _RelationalNetworkHeader(
                  searchController: _searchController,
                  zoom: _zoom,
                  periodPresets: _payload.filters.available.periodPresets,
                  selectedPeriodPreset: _periodPreset,
                  showFilters: _showFilters,
                  sourceLabel: _runtimeData.sourceLabel,
                  isLive: _runtimeData.isLive,
                  isLoading: _runtimeData.isLoading,
                  onSearchChanged: () => setState(() {}),
                  onClearSearch: () {
                    setState(() {
                      _searchController.clear();
                    });
                  },
                  onZoomOut: () => _adjustZoom(-0.05),
                  onZoomIn: () => _adjustZoom(0.05),
                  onResetViewport: _resetViewport,
                  onPeriodChanged: _setPeriodPreset,
                  onRefresh: () => _loadNetworkGraph(),
                  onToggleFilters: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 0),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _NetworkModeSwitcher(
                        selectedMode: _workspaceMode,
                        onChanged: (mode) {
                          setState(() {
                            _workspaceMode = mode;
                            _selectedLaneForDetails = null;
                          });
                          _pushHistoryState();
                        },
                      ),
                      _NetworkManagementMenuBar(
                        onOpenReport: _openManagementReport,
                      ),
                    ],
                  ),
                ),
                if (_workspaceMode == _NetworkWorkspaceMode.relational) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 10, 28, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _VisualIdentityLegend(
                        entries: _networkVisualLegendEntries(view.nodes),
                        dense: true,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 10, 28, 0),
                    child: _RelationalInsightBar(
                      data: insightData,
                      query: searchQuery,
                      selectedRootIds: _selectedRootIds,
                      selectedClientIds: _selectedClientIds,
                      contractStatuses: _contractStatuses,
                      employeeStatuses: _employeeStatuses,
                      selectedDepartments: _selectedDepartments,
                      selectedPositions: _selectedPositions,
                      selectedTenurePreset: _selectedTenurePreset,
                      customTenureYears: _customTenureYears,
                      hireDateRange: _hireDateRange,
                      reportPreset: _reportPreset,
                      attentionOnly: _attentionOnly,
                      clusterEmployees: _clusterEmployees,
                      focusedNode: _drillDownNodeId == null
                          ? null
                          : _payload.nodeByPublicId(_drillDownNodeId!),
                      onToggleCompany: _toggleCompanyFacet,
                      onToggleStatus: _toggleStatusFacet,
                      onToggleDepartment: _toggleDepartmentFacet,
                      onTogglePosition: _togglePositionFacet,
                      onTenurePreset: _applyTenurePreset,
                      onCustomTenure: _openCustomTenureDialog,
                      onHireDateRange: _applyHireDateRange,
                      onCustomHireDateRange: _openHireDateRangeDialog,
                      onReportPreset: _applyReportPreset,
                      onToggleAttention: () {
                        setState(() {
                          _attentionOnly = !_attentionOnly;
                          _selectedLaneForDetails = null;
                        });
                        _pushHistoryState();
                      },
                      onToggleCluster: _toggleClusterEmployees,
                      onClearCompany: (value) {
                        setState(() {
                          switch (value.type) {
                            case _NetworkCompanyFacetType.root:
                              _selectedRootIds.remove(value.publicId);
                              break;
                            case _NetworkCompanyFacetType.client:
                              _selectedClientIds.remove(value.publicId);
                              break;
                          }
                        });
                        _pushHistoryState();
                      },
                      onClearStatus: (value) {
                        setState(() {
                          switch (value.type) {
                            case _NetworkStatusFacetType.contract:
                              _contractStatuses.remove(value.status);
                              break;
                            case _NetworkStatusFacetType.employee:
                              _employeeStatuses.remove(value.status);
                              break;
                          }
                        });
                        _pushHistoryState();
                      },
                      onClearDepartment: (value) {
                        setState(() {
                          _selectedDepartments.remove(value);
                        });
                        _pushHistoryState();
                      },
                      onClearPosition: (value) {
                        setState(() {
                          _selectedPositions.remove(value);
                        });
                        _pushHistoryState();
                      },
                      onClearSearch: () {
                        setState(() {
                          _searchController.clear();
                        });
                        _pushHistoryState();
                      },
                      onClearFocus: () {
                        setState(() {
                          _drillDownNodeId = null;
                        });
                        _pushHistoryState();
                      },
                      onClearAll: _clearAnalysisFilters,
                    ),
                  ),
                ],
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 220),
                  crossFadeState: _showFilters
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 18, 28, 0),
                    child: _RelationalFilterPanel(
                      payload: _payload,
                      selectedRootIds: _selectedRootIds,
                      selectedClientIds: _selectedClientIds,
                      contractStatuses: _contractStatuses,
                      employeeStatuses: _employeeStatuses,
                      includeHistorical: _includeHistorical,
                      includeIndirect: _includeIndirect,
                      includeTimelineMoves: _includeTimelineMoves,
                      includeTimelineOperationalEvents:
                          _includeTimelineOperationalEvents,
                      timelineDateRange: _timelineDateRange,
                      onToggleRoot: (publicId) {
                        setState(() {
                          _toggleInSet(_selectedRootIds, publicId);
                        });
                        _pushHistoryState();
                      },
                      onToggleClient: (publicId) {
                        setState(() {
                          _toggleInSet(_selectedClientIds, publicId);
                        });
                        _pushHistoryState();
                      },
                      onToggleContractStatus: (value) {
                        setState(() {
                          _toggleInSet(_contractStatuses, value);
                        });
                        _pushHistoryState();
                      },
                      onToggleEmployeeStatus: (value) {
                        setState(() {
                          _toggleInSet(_employeeStatuses, value);
                        });
                        _pushHistoryState();
                      },
                      onToggleHistorical: (value) {
                        setState(() {
                          _includeHistorical = value;
                        });
                        _pushHistoryState();
                      },
                      onToggleIndirect: (value) {
                        setState(() {
                          _includeIndirect = value;
                        });
                        _pushHistoryState();
                      },
                      onToggleTimelineMoves: (value) {
                        setState(() {
                          _includeTimelineMoves = value;
                          _timelineSelection = null;
                        });
                        _pushHistoryState();
                      },
                      onToggleTimelineOperationalEvents: (value) {
                        setState(() {
                          _includeTimelineOperationalEvents = value;
                          _timelineSelection = null;
                        });
                        _pushHistoryState();
                      },
                      onPickTimelineRange: _openTimelineDateRangePicker,
                      onClearTimelineRange: () => _applyTimelineDateRange(null),
                      onRestore: _restoreFilters,
                    ),
                  ),
                  secondChild: const SizedBox.shrink(),
                ),
                if (_workspaceMode == _NetworkWorkspaceMode.relational &&
                    _runtimeData.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 14, 28, 0),
                    child: _NetworkRuntimeNotice(
                      message: _runtimeData.errorMessage!,
                      onRetry: () => _loadNetworkGraph(resetFilters: true),
                    ),
                  ),
                if (_workspaceMode != _NetworkWorkspaceMode.relational)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 14, 28, 0),
                    child: _NetworkTimelineOverview(
                      payload: _timelineRuntimeData.payload,
                      sourceLabel: _timelineRuntimeData.sourceLabel,
                      isLoading: _timelineRuntimeData.isLoading,
                      errorMessage: _timelineRuntimeData.errorMessage,
                    ),
                  ),
                Expanded(
                  child: switch (_workspaceMode) {
                    _NetworkWorkspaceMode.relational =>
                      wide
                          ? Row(
                              children: [
                                Expanded(child: graphSection),
                                if (_showDetailPanel)
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      minWidth: 320,
                                      maxWidth: 380,
                                    ),
                                    child: detailPanel,
                                  ),
                              ],
                            )
                          : SingleChildScrollView(
                              child: Column(
                                children: [
                                  SizedBox(height: 720, child: graphSection),
                                  if (_showDetailPanel) detailPanel,
                                ],
                              ),
                            ),
                    _NetworkWorkspaceMode.timeline =>
                      wide
                          ? Row(
                              children: [
                                Expanded(child: timelineSection),
                                if (_showDetailPanel)
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      minWidth: 320,
                                      maxWidth: 390,
                                    ),
                                    child: timelineDetailPanel,
                                  ),
                              ],
                            )
                          : SingleChildScrollView(
                              child: Column(
                                children: [
                                  SizedBox(height: 720, child: timelineSection),
                                  if (_showDetailPanel) timelineDetailPanel,
                                ],
                              ),
                            ),
                    _NetworkWorkspaceMode.current => currentSection,
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGraphSection(
    BuildContext context, {
    required bool compact,
    required _RelationalNetworkView view,
    required _NetworkGraphNode? selectedNode,
    required bool detailPanelCollapsed,
    required VoidCallback onReopenDetailPanel,
    required _NetworkGraphLane? selectedLaneForDetails,
    required Set<_NetworkGraphLane> hiddenLanes,
    required Set<_NetworkGraphLane> activeOnlyLanes,
    required ValueChanged<_NetworkGraphLane> onSelectLane,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (view.nodes.isEmpty) {
          return SizedBox(
            height: max(460, constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.filter_alt_off_outlined,
                    size: 44,
                    color: _slateColor,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Nenhum no ficou visivel com esse recorte.',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Revise a busca ou restaure os filtros para voltar ao layout completo.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: _mutedColor),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.tonalIcon(
                    onPressed: _restoreFilters,
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: const Text('Restaurar filtros'),
                  ),
                ],
              ),
            ),
          );
        }

        final compactCanvas = compact || constraints.maxWidth < 980;
        final canvasAreaHeight = max(560.0, constraints.maxHeight);
        final cardWidth = compactCanvas ? 176.0 : 216.0;
        final cardHeight = compactCanvas ? 86.0 : 92.0;
        final laneIntervals = max(1, _payload.lanes.length - 1).toDouble();
        final laneSpacing = max(
          104.0,
          min(156.0, (canvasAreaHeight - 44 - cardHeight - 42) / laneIntervals),
        );
        final layout = _RelationalCanvasLayout.compute(
          canvasWidth: max(constraints.maxWidth, 760),
          laneRailWidth: compactCanvas ? 118 : 146,
          topPadding: 34,
          laneSpacing: laneSpacing,
          horizontalPadding: compactCanvas ? 18 : 26,
          cardWidth: cardWidth,
          cardHeight: cardHeight,
          payload: _payload,
          nodes: view.nodes,
          collapsedLanes: hiddenLanes,
        );
        final scaledHeight = canvasAreaHeight;
        final graphViewportWidth = max(
          1.0,
          constraints.maxWidth - layout.laneRailWidth,
        );
        final graphViewportSize = Size(graphViewportWidth, scaledHeight);
        _canvasViewportSize = graphViewportSize;

        final connectedIds = selectedNode == null
            ? <String>{}
            : {
                selectedNode.publicId,
                for (final edge in view.edges)
                  if (edge.fromPublicId == selectedNode.publicId ||
                      edge.toPublicId == selectedNode.publicId) ...{
                    edge.fromPublicId,
                    edge.toPublicId,
                  },
              };
        final focusedNode = _drillDownNodeId == null
            ? null
            : _payload.nodeByPublicId(_drillDownNodeId!);

        return SizedBox(
          height: scaledHeight,
          child: Stack(
            children: [
              Positioned.fill(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: layout.laneRailWidth,
                      child: _RelationalLaneRail(
                        lanes: _payload.lanes,
                        laneTops: layout.laneTops,
                        cardHeight: layout.cardHeight,
                        selectedLane: selectedLaneForDetails,
                        hiddenLanes: hiddenLanes,
                        activeOnlyLanes: activeOnlyLanes,
                        onSelectLane: onSelectLane,
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.zero,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ColoredBox(color: Colors.white),
                            ),
                            Positioned.fill(
                              child: MouseRegion(
                                cursor: SystemMouseCursors.grab,
                                child: InteractiveViewer(
                                  transformationController: _canvasController,
                                  constrained: false,
                                  boundaryMargin: const EdgeInsets.all(720),
                                  minScale: _minCanvasZoom,
                                  maxScale: _maxCanvasZoom,
                                  scaleFactor: 180,
                                  trackpadScrollCausesScale: true,
                                  panEnabled: true,
                                  scaleEnabled: true,
                                  clipBehavior: Clip.none,
                                  onInteractionUpdate: (_) =>
                                      _syncZoomFromCanvas(),
                                  onInteractionEnd: (_) {
                                    _syncZoomFromCanvas();
                                    _pushHistoryState();
                                  },
                                  child: SizedBox(
                                    width: layout.contentWidth,
                                    height: layout.canvasHeight,
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned.fill(
                                          child: CustomPaint(
                                            painter:
                                                _RelationalNetworkEdgePainter(
                                                  payload: _payload,
                                                  nodes: view.nodes,
                                                  edges: view.edges,
                                                  positions: layout.positions,
                                                  selectedNodeId:
                                                      selectedNode?.publicId,
                                                ),
                                          ),
                                        ),
                                        for (final node in view.nodes)
                                          if (layout.positions[node.publicId]
                                              case final rect?)
                                            Positioned.fromRect(
                                              rect: rect,
                                              child: _RelationalNetworkNodeCard(
                                                node: node,
                                                selected:
                                                    selectedNode?.publicId ==
                                                    node.publicId,
                                                connected: connectedIds
                                                    .contains(node.publicId),
                                                onTap: () {
                                                  setState(() {
                                                    _selectedLaneForDetails =
                                                        null;
                                                    _showDetailPanel = true;
                                                  });
                                                  widget.onSelectNode(
                                                    node.publicId,
                                                  );
                                                  _pushHistoryState(
                                                    selectedNodeId:
                                                        node.publicId,
                                                  );
                                                },
                                                onDoubleTap: () =>
                                                    _focusNodeNeighborhood(
                                                      node.publicId,
                                                    ),
                                              ),
                                            ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (focusedNode != null)
                Positioned(
                  left: layout.laneRailWidth + 18,
                  top: 14,
                  child: _RelationalFocusCrumb(
                    node: focusedNode,
                    onClear: () {
                      setState(() {
                        _drillDownNodeId = null;
                      });
                    },
                  ),
                ),
              Positioned(
                left: layout.laneRailWidth + 18,
                bottom: 18,
                child: _RelationalViewportDock(
                  canGoBack: _canGoBack,
                  canGoForward: _canGoForward,
                  onBackTap: () => _goHistory(-1),
                  onForwardTap: () => _goHistory(1),
                  onCenterTap: () {
                    final selectedRect = selectedNode == null
                        ? null
                        : layout.positions[selectedNode.publicId];
                    if (selectedRect != null) {
                      _centerCanvasOn(selectedRect, graphViewportSize);
                    }
                  },
                  onResetTap: _resetViewport,
                ),
              ),
              if (detailPanelCollapsed)
                Positioned(
                  right: 24,
                  bottom: 24,
                  child: _RelationalCollapsedDetailDock(
                    label: selectedLaneForDetails == null
                        ? selectedNode?.displayName
                        : _laneLabel(selectedLaneForDetails),
                    onTap: onReopenDetailPanel,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailPanel(
    BuildContext context, {
    required _NetworkGraphNode? selectedNode,
  }) {
    if (!_showDetailPanel) {
      return const SizedBox.shrink();
    }

    if (_selectedLaneForDetails case final lane?) {
      return _RelationalLaneDetailPanel(
        lane: lane,
        nodes: _payload.nodes.where((node) => node.lane == lane).toList(),
        filterTargetNodes: _payload.nodes
            .where((node) => node.lane == _filterTargetLaneFor(lane))
            .toList(),
        hideInactive: _activeOnlyLanes.contains(lane),
        hideLayer: _hiddenLanes.contains(lane),
        onClose: () {
          setState(() {
            _showDetailPanel = false;
          });
        },
        onToggleHideInactive: (value) {
          setState(() {
            if (value) {
              _activeOnlyLanes.add(lane);
            } else {
              _activeOnlyLanes.remove(lane);
            }
          });
        },
        onToggleHideLayer: (value) {
          setState(() {
            if (value) {
              _hiddenLanes.add(lane);
            } else {
              _hiddenLanes.remove(lane);
            }
          });
        },
      );
    }

    if (selectedNode == null) {
      return _Panel(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          height: 280,
          child: Center(
            child: Text(
              'Selecione um no para ver o detalhe.',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
      );
    }

    return _RelationalNetworkDetailPanel(
      node: selectedNode,
      onClose: () {
        setState(() {
          _showDetailPanel = false;
        });
      },
      onSelectNode: widget.onSelectNode,
      onOpenEmployeeProfile: widget.onOpenEmployeeProfile,
    );
  }

  _RelationalNetworkView _filteredView() {
    final allowedNodes = <_NetworkGraphNode>[];
    final companyScopeActive =
        _selectedRootIds.isNotEmpty || _selectedClientIds.isNotEmpty;
    final companyScopeIds = <String>{};
    for (final rootId in _selectedRootIds) {
      companyScopeIds.addAll(
        _expandedNetworkContextIds(
          seedIds: {rootId},
          edges: _payload.edges,
          maxDepth: 4,
        ),
      );
    }
    for (final clientId in _selectedClientIds) {
      companyScopeIds.addAll(
        _expandedNetworkContextIds(
          seedIds: {clientId},
          edges: _payload.edges,
          maxDepth: 3,
        ),
      );
    }

    for (final node in _payload.nodes) {
      if (companyScopeActive && !companyScopeIds.contains(node.publicId)) {
        continue;
      }

      if (node.lane == _NetworkGraphLane.contract &&
          !_contractStatuses.contains(node.status)) {
        continue;
      }

      if (node.lane == _NetworkGraphLane.employee &&
          !_employeeStatuses.contains(node.status)) {
        continue;
      }

      if (_activeOnlyLanes.any(
            (lane) => _filterTargetLaneFor(lane) == node.lane,
          ) &&
          !_isActiveStatus(node.status)) {
        continue;
      }

      allowedNodes.add(node);
    }

    final allowedIds = allowedNodes.map((node) => node.publicId).toSet();
    final hiddenNodeIds = {
      for (final node in allowedNodes)
        if (_hiddenLanes.contains(node.lane)) node.publicId,
    };
    final visibleNodes = allowedNodes
        .where((node) => !_hiddenLanes.contains(node.lane))
        .toList();
    final visibleAllowedIds = visibleNodes.map((node) => node.publicId).toSet();
    final filteredEdges = _payload.edges.where((edge) {
      if (!allowedIds.contains(edge.fromPublicId) ||
          !allowedIds.contains(edge.toPublicId)) {
        return false;
      }

      if (!_includeHistorical &&
          edge.relationshipState == _NetworkGraphRelationshipState.historical) {
        return false;
      }

      if (!_includeIndirect &&
          edge.relationshipState == _NetworkGraphRelationshipState.indirect) {
        return false;
      }

      return true;
    }).toList();
    final bridgedEdges =
        _bridgeHiddenNodeEdges(
          edges: filteredEdges,
          hiddenNodeIds: hiddenNodeIds,
          allowedIds: allowedIds,
        ).where((edge) {
          return visibleAllowedIds.contains(edge.fromPublicId) &&
              visibleAllowedIds.contains(edge.toPublicId);
        }).toList();

    final query = _NetworkSearchQuery.parse(_searchController.text);
    final hasAnalysisFilters =
        !query.isEmpty ||
        _selectedDepartments.isNotEmpty ||
        _selectedPositions.isNotEmpty ||
        _selectedTenurePreset != null ||
        _customTenureYears != null ||
        _hireDateRange != null ||
        _reportPreset != null ||
        _attentionOnly;

    var visibleIds = visibleAllowedIds;

    if (hasAnalysisFilters) {
      final matchedIds = visibleNodes
          .where((node) {
            if (!query.matches(node)) {
              return false;
            }
            if (_selectedDepartments.isNotEmpty &&
                !_selectedDepartments.any(
                  (department) =>
                      _facetValueMatches(_nodeDepartment(node), department),
                )) {
              return false;
            }
            if (_selectedPositions.isNotEmpty &&
                !_selectedPositions.any(
                  (position) =>
                      _facetValueMatches(_nodePosition(node), position),
                )) {
              return false;
            }
            if (_attentionOnly && !_nodeNeedsAttention(node)) {
              return false;
            }
            if (!_matchesTenureFilters(
              node,
              preset: _selectedTenurePreset,
              customRange: _customTenureYears,
            )) {
              return false;
            }
            if (_hireDateRange != null &&
                !_hireDateRange!.matches(_nodeStartDate(node))) {
              return false;
            }
            if (_reportPreset != null && !_reportPreset!.matches(node)) {
              return false;
            }
            return true;
          })
          .map((node) => node.publicId)
          .toSet();

      visibleIds = _expandedNetworkContextIds(
        seedIds: matchedIds,
        edges: bridgedEdges,
        maxDepth: 4,
      ).intersection(visibleAllowedIds);
    }

    if (_drillDownNodeId case final focusId?
        when visibleAllowedIds.contains(focusId)) {
      final focusNode = _payload.nodeByPublicId(focusId);
      final focusIds = _expandedNetworkContextIds(
        seedIds: {focusId},
        edges: bridgedEdges,
        maxDepth: _drillDepthFor(focusNode),
      ).intersection(visibleAllowedIds);
      visibleIds = visibleIds.intersection(focusIds);
    }

    final nodes = visibleNodes
        .where((node) => visibleIds.contains(node.publicId))
        .toList();
    final edges = bridgedEdges
        .where(
          (edge) =>
              visibleIds.contains(edge.fromPublicId) &&
              visibleIds.contains(edge.toPublicId),
        )
        .toList();
    final clustered = _shouldClusterEmployees(nodes)
        ? _clusterEmployeeNodes(
            nodes: nodes,
            edges: edges,
            selectedNodeId: widget.selectedNodeId,
          )
        : _RelationalClusterResult(nodes: nodes, edges: edges);

    return _RelationalNetworkView(
      nodes: clustered.nodes,
      edges: clustered.edges,
      payload: _payload,
    );
  }

  bool _shouldClusterEmployees(List<_NetworkGraphNode> nodes) {
    if (!_clusterEmployees ||
        _drillDownNodeId != null ||
        _attentionOnly ||
        _zoom > 0.88) {
      return false;
    }
    return nodes
            .where((node) => node.lane == _NetworkGraphLane.employee)
            .length >=
        8;
  }
}

class _NetworkModeSwitcher extends StatelessWidget {
  const _NetworkModeSwitcher({
    required this.selectedMode,
    required this.onChanged,
  });

  final _NetworkWorkspaceMode selectedMode;
  final ValueChanged<_NetworkWorkspaceMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<_NetworkWorkspaceMode>(
      segments: [
        for (final mode in _NetworkWorkspaceMode.values)
          ButtonSegment<_NetworkWorkspaceMode>(
            value: mode,
            icon: Icon(mode.icon, size: 18),
            label: Text(mode.label),
            tooltip: mode.tooltip,
          ),
      ],
      selected: {selectedMode},
      showSelectedIcon: false,
      onSelectionChanged: (selection) {
        if (selection.isNotEmpty) {
          onChanged(selection.first);
        }
      },
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        textStyle: WidgetStatePropertyAll(
          Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _NetworkTimelineCanvasSection extends StatefulWidget {
  const _NetworkTimelineCanvasSection({
    required this.payload,
    required this.runtimeData,
    required this.controller,
    required this.selectedItem,
    required this.onViewportChanged,
    required this.onInteractionUpdate,
    required this.onInteractionEnd,
    required this.onSelectItem,
    required this.onRetry,
  });

  final _NetworkTimelinePayload payload;
  final _NetworkTimelineRuntimeData runtimeData;
  final TransformationController controller;
  final _NetworkTimelineSelection? selectedItem;
  final ValueChanged<Size> onViewportChanged;
  final VoidCallback onInteractionUpdate;
  final VoidCallback onInteractionEnd;
  final ValueChanged<_NetworkTimelineSelection?> onSelectItem;
  final VoidCallback onRetry;

  @override
  State<_NetworkTimelineCanvasSection> createState() =>
      _NetworkTimelineCanvasSectionState();
}

class _NetworkTimelineCanvasSectionState
    extends State<_NetworkTimelineCanvasSection> {
  _NetworkTimelinePayload? _cachedLayoutPayload;
  double? _cachedLayoutViewportWidth;
  _NetworkTimelineCanvasLayout? _cachedLayout;

  _NetworkTimelineCanvasLayout _layoutFor(
    _NetworkTimelinePayload payload,
    double viewportWidth,
  ) {
    final cachedLayout = _cachedLayout;
    if (cachedLayout != null &&
        identical(_cachedLayoutPayload, payload) &&
        _cachedLayoutViewportWidth == viewportWidth) {
      return cachedLayout;
    }

    final layout = _NetworkTimelineCanvasLayout.compute(
      payload: payload,
      viewportWidth: viewportWidth,
    );
    _cachedLayoutPayload = payload;
    _cachedLayoutViewportWidth = viewportWidth;
    _cachedLayout = layout;
    return layout;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.runtimeData.isLoading &&
        !widget.runtimeData.isLive &&
        widget.runtimeData.errorMessage != null) {
      return _NetworkTimelineStateNotice(
        icon: Icons.cloud_off_outlined,
        title: 'Timeline indisponivel',
        message: widget.runtimeData.errorMessage!,
        actionLabel: 'Tentar novamente',
        onAction: widget.onRetry,
      );
    }

    final hasTimelineData =
        widget.payload.contracts.isNotEmpty ||
        widget.payload.collaborators.isNotEmpty ||
        widget.payload.events.isNotEmpty;
    if (!widget.runtimeData.isLoading && !hasTimelineData) {
      return const _NetworkTimelineStateNotice(
        icon: Icons.timeline_outlined,
        title: 'Sem dados de timeline',
        message:
            'O endpoint retornou um payload valido, mas sem contratos, colaboradores ou eventos para este recorte.',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportHeight = constraints.maxHeight.isFinite
            ? max(560.0, constraints.maxHeight)
            : 640.0;
        final viewportSize = Size(max(1, constraints.maxWidth), viewportHeight);
        widget.onViewportChanged(viewportSize);

        final layout = _layoutFor(widget.payload, viewportSize.width);
        final visibleSceneRect = _visibleTimelineSceneRect(
          widget.controller.value,
          viewportSize,
          Size(layout.sceneWidth, layout.sceneHeight),
        );

        return SizedBox(
          height: viewportHeight,
          child: DecoratedBox(
            decoration: const BoxDecoration(color: Colors.white),
            child: Stack(
              children: [
                Positioned.fill(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.grab,
                    child: InteractiveViewer(
                      transformationController: widget.controller,
                      constrained: false,
                      boundaryMargin: const EdgeInsets.all(620),
                      minScale:
                          _RelationalNetworkWorkspaceBodyState._minCanvasZoom,
                      maxScale:
                          _RelationalNetworkWorkspaceBodyState._maxCanvasZoom,
                      scaleFactor: 180,
                      trackpadScrollCausesScale: true,
                      panEnabled: true,
                      scaleEnabled: true,
                      clipBehavior: Clip.none,
                      onInteractionUpdate: (_) => widget.onInteractionUpdate(),
                      onInteractionEnd: (_) => widget.onInteractionEnd(),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapUp: (details) {
                          widget.onSelectItem(
                            layout.hitTest(details.localPosition),
                          );
                        },
                        child: RepaintBoundary(
                          child: CustomPaint(
                            size: Size(layout.sceneWidth, layout.sceneHeight),
                            painter: _NetworkTimelineCanvasPainter(
                              payload: widget.payload,
                              layout: layout,
                              selectedItem: widget.selectedItem,
                              visibleSceneRect: visibleSceneRect,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  bottom: 18,
                  child: _RelationalViewportDock(
                    canGoBack: false,
                    canGoForward: false,
                    onBackTap: () {},
                    onForwardTap: () {},
                    onCenterTap: () {
                      widget.controller.value = Matrix4.identity();
                      widget.onInteractionEnd();
                    },
                    onResetTap: () {
                      widget.controller.value = Matrix4.identity();
                      widget.onInteractionEnd();
                    },
                  ),
                ),
                if (widget.runtimeData.isLoading)
                  const Positioned(
                    right: 24,
                    top: 20,
                    child: SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NetworkTimelineStateNotice extends StatelessWidget {
  const _NetworkTimelineStateNotice({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 44, color: _slateColor),
              const SizedBox(height: 14),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: _mutedColor),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 18),
                FilledButton.tonalIcon(
                  onPressed: onAction,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NetworkTimelineCanvasLayout {
  const _NetworkTimelineCanvasLayout({
    required this.periodStart,
    required this.periodEnd,
    required this.leftRailWidth,
    required this.axisWidth,
    required this.sceneWidth,
    required this.sceneHeight,
    required this.contractRects,
    required this.positionRects,
    required this.allocationRects,
    required this.eventRects,
    required this.rowLabels,
    required this.monthTicks,
  });

  factory _NetworkTimelineCanvasLayout.compute({
    required _NetworkTimelinePayload payload,
    required double viewportWidth,
  }) {
    final fallbackEnd = DateTime.now();
    final parsedStart = _parseNetworkDate(payload.period.from);
    final parsedEnd = _parseNetworkDate(payload.period.to);
    final periodEnd = parsedEnd ?? fallbackEnd;
    final periodStart =
        parsedStart ?? DateTime(periodEnd.year - 1, periodEnd.month, 1);
    final safeEnd = periodEnd.isAfter(periodStart)
        ? periodEnd
        : _addMonths(periodStart, 12);
    final monthSpan = max(1, _monthSpan(periodStart, safeEnd));
    final leftRailWidth = viewportWidth < 920 ? 180.0 : 220.0;
    final axisWidth = max(viewportWidth - leftRailWidth - 80, monthSpan * 92.0);
    final sceneWidth = leftRailWidth + axisWidth + 82;

    final contractRects = <String, Rect>{};
    final positionRects = <String, Rect>{};
    final allocationRects = <String, Rect>{};
    final eventRects = <String, Rect>{};
    final rowLabels = <_NetworkTimelineRowLabel>[];
    var cursorY = 70.0;

    void addSection(String label, IconData icon) {
      rowLabels.add(
        _NetworkTimelineRowLabel(
          label: label,
          icon: icon,
          top: cursorY,
          section: true,
        ),
      );
      cursorY += 34;
    }

    Rect rangeRect(
      String? startsAt,
      String? endsAt,
      double top,
      double height,
    ) {
      final startDate = _parseNetworkDate(startsAt ?? '') ?? periodStart;
      final endDate = _parseNetworkDate(endsAt ?? '') ?? safeEnd;
      final left = _xForDate(
        startDate,
        periodStart: periodStart,
        periodEnd: safeEnd,
        leftRailWidth: leftRailWidth,
        axisWidth: axisWidth,
      );
      final right = _xForDate(
        endDate,
        periodStart: periodStart,
        periodEnd: safeEnd,
        leftRailWidth: leftRailWidth,
        axisWidth: axisWidth,
      );
      final clampedLeft = left.clamp(leftRailWidth, leftRailWidth + axisWidth);
      final clampedRight = right.clamp(
        leftRailWidth,
        leftRailWidth + axisWidth,
      );
      final width = max(24.0, clampedRight - clampedLeft);
      return Rect.fromLTWH(clampedLeft.toDouble(), top, width, height);
    }

    addSection('Contratos', Icons.description_outlined);
    for (final contract in payload.contracts) {
      final top = cursorY;
      rowLabels.add(
        _NetworkTimelineRowLabel(
          label: contract.displayName.isEmpty
              ? contract.publicId
              : contract.displayName,
          icon: Icons.description_outlined,
          top: top,
        ),
      );
      contractRects[contract.publicId] = rangeRect(
        contract.startsAt,
        contract.endsAt,
        top + 5,
        32,
      );
      cursorY += 46;
    }

    addSection('Postos', Icons.work_outline_rounded);
    for (final contract in payload.contracts) {
      for (final position in contract.positions) {
        final top = cursorY;
        rowLabels.add(
          _NetworkTimelineRowLabel(
            label: position.displayName.isEmpty
                ? position.publicId
                : position.displayName,
            icon: Icons.work_outline_rounded,
            top: top,
          ),
        );
        positionRects[position.publicId] = rangeRect(
          position.startsAt,
          position.endsAt,
          top + 6,
          26,
        );
        cursorY += 40;
      }
    }

    addSection('Colaboradores', Icons.badge_outlined);
    for (final collaborator in payload.collaborators) {
      final top = cursorY;
      rowLabels.add(
        _NetworkTimelineRowLabel(
          label: collaborator.personName.isEmpty
              ? collaborator.personPublicId
              : collaborator.personName,
          icon: Icons.badge_outlined,
          top: top,
        ),
      );
      for (final segment in collaborator.segments) {
        allocationRects[segment.employmentLinkPublicId] = rangeRect(
          segment.startsAt,
          segment.endsAt,
          top + 7,
          22,
        );
      }
      cursorY += 36;
    }

    addSection('Eventos', Icons.event_note_outlined);
    final eventTop = cursorY + 16;
    for (final event in payload.events) {
      final date = _parseNetworkDate(event.occurredAt ?? '');
      final x = _xForDate(
        date ?? periodStart,
        periodStart: periodStart,
        periodEnd: safeEnd,
        leftRailWidth: leftRailWidth,
        axisWidth: axisWidth,
      );
      eventRects[event.publicId] = Rect.fromCenter(
        center: Offset(x, eventTop),
        width: 26,
        height: 26,
      );
    }
    cursorY += 74;

    return _NetworkTimelineCanvasLayout(
      periodStart: periodStart,
      periodEnd: safeEnd,
      leftRailWidth: leftRailWidth,
      axisWidth: axisWidth,
      sceneWidth: sceneWidth,
      sceneHeight: max(cursorY + 32, 560),
      contractRects: contractRects,
      positionRects: positionRects,
      allocationRects: allocationRects,
      eventRects: eventRects,
      rowLabels: rowLabels,
      monthTicks: _timelineMonthTicks(
        periodStart,
        safeEnd,
        leftRailWidth: leftRailWidth,
        axisWidth: axisWidth,
      ),
    );
  }

  final DateTime periodStart;
  final DateTime periodEnd;
  final double leftRailWidth;
  final double axisWidth;
  final double sceneWidth;
  final double sceneHeight;
  final Map<String, Rect> contractRects;
  final Map<String, Rect> positionRects;
  final Map<String, Rect> allocationRects;
  final Map<String, Rect> eventRects;
  final List<_NetworkTimelineRowLabel> rowLabels;
  final List<_NetworkTimelineMonthTick> monthTicks;

  _NetworkTimelineSelection? hitTest(Offset point) {
    for (final entry in eventRects.entries.toList().reversed) {
      if (entry.value.inflate(8).contains(point)) {
        return _NetworkTimelineSelection(
          kind: _NetworkTimelineSelectionKind.event,
          publicId: entry.key,
        );
      }
    }
    for (final entry in allocationRects.entries.toList().reversed) {
      if (entry.value.inflate(4).contains(point)) {
        return _NetworkTimelineSelection(
          kind: _NetworkTimelineSelectionKind.collaborator,
          publicId: entry.key,
        );
      }
    }
    for (final entry in positionRects.entries.toList().reversed) {
      if (entry.value.contains(point)) {
        return _NetworkTimelineSelection(
          kind: _NetworkTimelineSelectionKind.position,
          publicId: entry.key,
        );
      }
    }
    for (final entry in contractRects.entries.toList().reversed) {
      if (entry.value.contains(point)) {
        return _NetworkTimelineSelection(
          kind: _NetworkTimelineSelectionKind.contract,
          publicId: entry.key,
        );
      }
    }
    return null;
  }
}

class _NetworkTimelineRowLabel {
  const _NetworkTimelineRowLabel({
    required this.label,
    required this.icon,
    required this.top,
    this.section = false,
  });

  final String label;
  final IconData icon;
  final double top;
  final bool section;
}

class _NetworkTimelineMonthTick {
  const _NetworkTimelineMonthTick({required this.date, required this.x});

  final DateTime date;
  final double x;
}

class _NetworkTimelineCanvasPainter extends CustomPainter {
  const _NetworkTimelineCanvasPainter({
    required this.payload,
    required this.layout,
    required this.selectedItem,
    required this.visibleSceneRect,
  });

  final _NetworkTimelinePayload payload;
  final _NetworkTimelineCanvasLayout layout;
  final _NetworkTimelineSelection? selectedItem;
  final Rect visibleSceneRect;

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, background);
    _paintTimelineGrid(canvas, size);
    _paintRowLabels(canvas);
    _paintContracts(canvas);
    _paintPositions(canvas);
    _paintAllocations(canvas);
    _paintStructuredMoveConnections(canvas);
    _paintEvents(canvas);
  }

  void _paintTimelineGrid(Canvas canvas, Size size) {
    final railPaint = Paint()..color = const Color(0xFFF8FAF9);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, layout.leftRailWidth, size.height),
      railPaint,
    );

    final headerPaint = Paint()..color = const Color(0xFFFBF8F2);
    canvas.drawRect(
      Rect.fromLTWH(layout.leftRailWidth, 0, layout.axisWidth, 52),
      headerPaint,
    );

    final linePaint = Paint()
      ..color = _lineColor
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(layout.leftRailWidth, 0),
      Offset(layout.leftRailWidth, size.height),
      linePaint,
    );
    canvas.drawLine(const Offset(0, 52), Offset(size.width, 52), linePaint);

    for (var i = 0; i < layout.monthTicks.length; i++) {
      final tick = layout.monthTicks[i];
      if (tick.x < visibleSceneRect.left - 80 ||
          tick.x > visibleSceneRect.right + 80) {
        continue;
      }
      final major = tick.date.month == 1 || i == 0;
      final paint = Paint()
        ..color = major ? _lineColor : _lineColor.withValues(alpha: 0.45)
        ..strokeWidth = major ? 1.2 : 1;
      canvas.drawLine(Offset(tick.x, 0), Offset(tick.x, size.height), paint);
      if (major || i.isEven) {
        _paintText(
          canvas,
          _timelineMonthLabel(tick.date, showYear: major),
          Offset(tick.x + 6, major ? 11 : 18),
          maxWidth: 78,
          style: TextStyle(
            color: major ? _inkColor : _mutedColor,
            fontSize: major ? 12 : 11,
            fontWeight: FontWeight.w800,
          ),
        );
      }
    }
  }

  void _paintRowLabels(Canvas canvas) {
    for (final row in layout.rowLabels) {
      if (row.top < visibleSceneRect.top - 48 ||
          row.top > visibleSceneRect.bottom + 48) {
        continue;
      }
      if (row.section) {
        final paint = Paint()..color = _deepTealColor.withValues(alpha: 0.05);
        canvas.drawRect(
          Rect.fromLTWH(0, row.top, layout.sceneWidth, 30),
          paint,
        );
        _paintIcon(canvas, row.icon, Offset(16, row.top + 7), _deepTealColor);
        _paintText(
          canvas,
          row.label,
          Offset(42, row.top + 6),
          maxWidth: layout.leftRailWidth - 52,
          style: const TextStyle(
            color: _deepTealColor,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        );
        continue;
      }

      _paintIcon(canvas, row.icon, Offset(18, row.top + 12), _slateColor);
      _paintText(
        canvas,
        row.label,
        Offset(44, row.top + 9),
        maxWidth: layout.leftRailWidth - 56,
        style: const TextStyle(
          color: _inkColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      );
    }
  }

  void _paintContracts(Canvas canvas) {
    for (final contract in payload.contracts) {
      final rect = layout.contractRects[contract.publicId];
      if (rect == null) {
        continue;
      }
      if (!_shouldPaintRect(rect)) {
        continue;
      }
      _paintBar(
        canvas,
        rect,
        color: _timelineStatusColor(contract.status),
        label: contract.clientCompanyName.isEmpty
            ? contract.displayName
            : contract.clientCompanyName,
        selected: _isSelected(
          _NetworkTimelineSelectionKind.contract,
          contract.publicId,
        ),
      );
    }
  }

  void _paintPositions(Canvas canvas) {
    for (final contract in payload.contracts) {
      for (final position in contract.positions) {
        final rect = layout.positionRects[position.publicId];
        if (rect == null) {
          continue;
        }
        if (!_shouldPaintRect(rect)) {
          continue;
        }
        _paintBar(
          canvas,
          rect,
          color: _timelineStatusColor(position.status),
          label: position.serviceName.isEmpty
              ? position.displayName
              : position.serviceName,
          selected: _isSelected(
            _NetworkTimelineSelectionKind.position,
            position.publicId,
          ),
          compact: true,
        );
      }
    }
  }

  void _paintAllocations(Canvas canvas) {
    for (final collaborator in payload.collaborators) {
      for (final segment in collaborator.segments) {
        final rect = layout.allocationRects[segment.employmentLinkPublicId];
        if (rect == null) {
          continue;
        }
        if (!_shouldPaintRect(rect)) {
          continue;
        }
        _paintBar(
          canvas,
          rect,
          color: _timelineStatusColor(segment.status),
          label: collaborator.personName,
          selected: _isSelected(
            _NetworkTimelineSelectionKind.collaborator,
            segment.employmentLinkPublicId,
          ),
          compact: true,
        );
      }
    }
  }

  void _paintEvents(Canvas canvas) {
    for (final event in payload.events) {
      final rect = layout.eventRects[event.publicId];
      if (rect == null) {
        continue;
      }
      if (!_shouldPaintRect(rect.inflate(18))) {
        continue;
      }
      final color = _timelineEventColor(event.eventType);
      final selected = _isSelected(
        _NetworkTimelineSelectionKind.event,
        event.publicId,
      );
      final path = Path()
        ..moveTo(rect.center.dx, rect.top)
        ..lineTo(rect.right, rect.center.dy)
        ..lineTo(rect.center.dx, rect.bottom)
        ..lineTo(rect.left, rect.center.dy)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = selected ? color : color.withValues(alpha: 0.88)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = selected ? _inkColor : Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = selected ? 2.4 : 1.4,
      );
      if (event.eventType == 'move' && !event.hasStructuredMove) {
        canvas.drawCircle(
          rect.topRight + const Offset(-1, 1),
          4,
          Paint()..color = _amberColor,
        );
      }
    }
  }

  void _paintStructuredMoveConnections(Canvas canvas) {
    final paint = Paint()
      ..color = _deepTealColor.withValues(alpha: 0.34)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    for (final event in payload.events) {
      if (event.eventType != 'move' || !event.hasStructuredMove) {
        continue;
      }
      final originRect = layout.positionRects[event.originPositionPublicId];
      final destinationRect =
          layout.positionRects[event.destinationPositionPublicId];
      final eventRect = layout.eventRects[event.publicId];
      if (originRect == null || destinationRect == null || eventRect == null) {
        continue;
      }

      final bounds = _boundsForPoints([
        originRect.center,
        eventRect.center,
        destinationRect.center,
      ]).inflate(36);
      if (!_shouldPaintRect(bounds)) {
        continue;
      }

      final path = Path()
        ..moveTo(originRect.center.dx, originRect.center.dy)
        ..quadraticBezierTo(
          eventRect.center.dx,
          eventRect.center.dy,
          destinationRect.center.dx,
          destinationRect.center.dy,
        );
      canvas.drawPath(path, paint);
      canvas.drawCircle(
        originRect.center,
        3,
        paint..style = PaintingStyle.fill,
      );
      paint.style = PaintingStyle.stroke;
      canvas.drawCircle(
        destinationRect.center,
        3,
        paint..style = PaintingStyle.fill,
      );
      paint.style = PaintingStyle.stroke;
    }
  }

  void _paintBar(
    Canvas canvas,
    Rect rect, {
    required Color color,
    required String label,
    required bool selected,
    bool compact = false,
  }) {
    final radius = Radius.circular(compact ? 7 : 9);
    final fill = Paint()
      ..color = selected
          ? color.withValues(alpha: 0.22)
          : color.withValues(alpha: 0.14);
    final border = Paint()
      ..color = selected ? _inkColor : color.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = selected ? 2.2 : 1.2;
    final rrect = RRect.fromRectAndRadius(rect, radius);
    canvas.drawRRect(rrect, fill);
    canvas.drawRRect(rrect, border);
    _paintText(
      canvas,
      label,
      Offset(rect.left + 10, rect.top + (compact ? 5 : 7)),
      maxWidth: max(12.0, rect.width - 18),
      style: TextStyle(
        color: _inkColor,
        fontSize: compact ? 11 : 12,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  bool _isSelected(_NetworkTimelineSelectionKind kind, String publicId) {
    return selectedItem?.kind == kind && selectedItem?.publicId == publicId;
  }

  bool _shouldPaintRect(Rect rect) {
    return rect.overlaps(visibleSceneRect);
  }

  @override
  bool shouldRepaint(covariant _NetworkTimelineCanvasPainter oldDelegate) {
    return oldDelegate.payload != payload ||
        oldDelegate.layout != layout ||
        oldDelegate.selectedItem?.signature != selectedItem?.signature ||
        oldDelegate.visibleSceneRect != visibleSceneRect;
  }
}

class _NetworkTimelineDetailPanel extends StatelessWidget {
  const _NetworkTimelineDetailPanel({
    required this.payload,
    required this.selectedItem,
    required this.onSelectItem,
    required this.onClose,
  });

  final _NetworkTimelinePayload payload;
  final _NetworkTimelineSelection? selectedItem;
  final ValueChanged<_NetworkTimelineSelection> onSelectItem;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final selection = selectedItem;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFCF7),
        border: Border(left: BorderSide(color: _lineColor)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _timelineDetailTitle(selection, payload),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  tooltip: 'Fechar detalhes',
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (selection == null)
              _NetworkTimelineSummaryDetails(
                payload: payload,
                onSelectItem: onSelectItem,
              )
            else
              _NetworkTimelineSelectedDetails(
                payload: payload,
                selectedItem: selection,
                onSelectItem: onSelectItem,
              ),
          ],
        ),
      ),
    );
  }
}

class _NetworkTimelineSummaryDetails extends StatelessWidget {
  const _NetworkTimelineSummaryDetails({
    required this.payload,
    required this.onSelectItem,
  });

  final _NetworkTimelinePayload payload;
  final ValueChanged<_NetworkTimelineSelection> onSelectItem;

  @override
  Widget build(BuildContext context) {
    final recentEvents = payload.events.reversed.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _RelationalMetricPill(
              icon: Icons.description_outlined,
              label: '${payload.contracts.length} contratos',
            ),
            _RelationalMetricPill(
              icon: Icons.badge_outlined,
              label: '${payload.collaborators.length} colaboradores',
            ),
            _RelationalMetricPill(
              icon: Icons.event_note_outlined,
              label: '${payload.events.length} eventos',
            ),
          ],
        ),
        if (payload.warnings.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text('Warnings', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final warning in payload.warnings.take(4))
            _NetworkTimelineWarningTile(warning: warning),
        ],
        if (recentEvents.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(
            'Eventos recentes',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final event in recentEvents)
            _NetworkTimelineEventTile(
              event: event,
              onTap: () => onSelectItem(
                _NetworkTimelineSelection(
                  kind: _NetworkTimelineSelectionKind.event,
                  publicId: event.publicId,
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _NetworkTimelineSelectedDetails extends StatelessWidget {
  const _NetworkTimelineSelectedDetails({
    required this.payload,
    required this.selectedItem,
    required this.onSelectItem,
  });

  final _NetworkTimelinePayload payload;
  final _NetworkTimelineSelection selectedItem;
  final ValueChanged<_NetworkTimelineSelection> onSelectItem;

  @override
  Widget build(BuildContext context) {
    return switch (selectedItem.kind) {
      _NetworkTimelineSelectionKind.contract => _contractDetails(context),
      _NetworkTimelineSelectionKind.position => _positionDetails(context),
      _NetworkTimelineSelectionKind.collaborator => _collaboratorDetails(
        context,
      ),
      _NetworkTimelineSelectionKind.event => _eventDetails(context),
    };
  }

  Widget _contractDetails(BuildContext context) {
    final contract = payload.contractByPublicId(selectedItem.publicId);
    if (contract == null) {
      return const _NetworkTimelineMissingSelection();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _NetworkTimelineStatusHeader(
          icon: Icons.description_outlined,
          title: contract.displayName,
          status: contract.status,
        ),
        _NetworkTimelineField(
          label: 'Prestadora',
          value: contract.providerCompanyName,
        ),
        _NetworkTimelineField(
          label: 'Cliente',
          value: contract.clientCompanyName,
        ),
        _NetworkTimelineField(label: 'Inicio', value: contract.startsAt ?? '-'),
        _NetworkTimelineField(label: 'Fim', value: contract.endsAt ?? 'Aberto'),
        const SizedBox(height: 16),
        Text('Postos', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final position in contract.positions)
          _NetworkTimelineLinkTile(
            icon: Icons.work_outline_rounded,
            title: position.displayName,
            subtitle: position.status,
            onTap: () => onSelectItem(
              _NetworkTimelineSelection(
                kind: _NetworkTimelineSelectionKind.position,
                publicId: position.publicId,
              ),
            ),
          ),
      ],
    );
  }

  Widget _positionDetails(BuildContext context) {
    final position = payload.positionByPublicId(selectedItem.publicId);
    if (position == null) {
      return const _NetworkTimelineMissingSelection();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _NetworkTimelineStatusHeader(
          icon: Icons.work_outline_rounded,
          title: position.displayName,
          status: position.status,
        ),
        _NetworkTimelineField(label: 'Servico', value: position.serviceName),
        _NetworkTimelineField(label: 'Local', value: position.location),
        _NetworkTimelineField(label: 'Escala', value: position.schedule),
        _NetworkTimelineField(label: 'Turno', value: position.shift),
        _NetworkTimelineField(
          label: 'Origem das datas',
          value: position.dateSource,
        ),
        const SizedBox(height: 16),
        Text('Alocacoes', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final allocation in position.allocations)
          _NetworkTimelineLinkTile(
            icon: Icons.badge_outlined,
            title: allocation.personName,
            subtitle: '${allocation.status} | ${allocation.startsAt ?? '-'}',
            onTap: () => onSelectItem(
              _NetworkTimelineSelection(
                kind: _NetworkTimelineSelectionKind.collaborator,
                publicId: allocation.employmentLinkPublicId,
              ),
            ),
          ),
      ],
    );
  }

  Widget _collaboratorDetails(BuildContext context) {
    final segment = _timelineSegmentByEmploymentLink(
      payload,
      selectedItem.publicId,
    );
    final collaborator = segment == null
        ? null
        : _timelineCollaboratorBySegment(payload, segment);
    if (segment == null || collaborator == null) {
      return const _NetworkTimelineMissingSelection();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _NetworkTimelineStatusHeader(
          icon: Icons.badge_outlined,
          title: collaborator.personName,
          status: segment.status,
        ),
        _NetworkTimelineField(label: 'Inicio', value: segment.startsAt ?? '-'),
        _NetworkTimelineField(label: 'Fim', value: segment.endsAt ?? 'Aberto'),
        _NetworkTimelineField(
          label: 'Contrato',
          value: segment.contractPublicId,
        ),
        _NetworkTimelineField(label: 'Posto', value: segment.positionPublicId),
        if (collaborator.events.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Eventos', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final event in collaborator.events)
            _NetworkTimelineEventTile(
              event: event,
              onTap: () => onSelectItem(
                _NetworkTimelineSelection(
                  kind: _NetworkTimelineSelectionKind.event,
                  publicId: event.publicId,
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _eventDetails(BuildContext context) {
    final event = payload.eventByPublicId(selectedItem.publicId);
    if (event == null) {
      return const _NetworkTimelineMissingSelection();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _NetworkTimelineStatusHeader(
          icon: _timelineEventIcon(event.eventType),
          title: event.label,
          status: event.eventType,
        ),
        _NetworkTimelineField(label: 'Data', value: event.occurredAt ?? '-'),
        _NetworkTimelineField(label: 'Origem', value: event.source),
        if (event.notes != null)
          _NetworkTimelineField(label: 'Notas', value: event.notes!),
        if (event.eventType == 'move' && !event.hasStructuredMove)
          const _NetworkTimelineInlineWarning(
            message:
                'Movimento sem ids estruturados. O evento fica narrativo e nao gera conexao entre postos.',
          ),
        for (final entity in event.linkedEntities)
          _NetworkTimelineField(
            label: _titleCase(entity.entityType),
            value: entity.labelSnapshot,
          ),
      ],
    );
  }
}

class _NetworkTimelineStatusHeader extends StatelessWidget {
  const _NetworkTimelineStatusHeader({
    required this.icon,
    required this.title,
    required this.status,
  });

  final IconData icon;
  final String title;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _timelineStatusColor(status).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _timelineStatusColor(status).withValues(alpha: 0.24),
            ),
          ),
          child: Icon(icon, color: _timelineStatusColor(status), size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.isEmpty ? 'Sem titulo' : title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                _titleCase(status),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _mutedColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NetworkTimelineField extends StatelessWidget {
  const _NetworkTimelineField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final displayValue = value.trim().isEmpty ? '-' : value;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: _mutedColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            displayValue,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _inkColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkTimelineLinkTile extends StatelessWidget {
  const _NetworkTimelineLinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minLeadingWidth: 26,
      leading: Icon(icon, color: _slateColor),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _NetworkTimelineEventTile extends StatelessWidget {
  const _NetworkTimelineEventTile({required this.event, required this.onTap});

  final _NetworkTimelineEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _NetworkTimelineLinkTile(
      icon: _timelineEventIcon(event.eventType),
      title: event.label.isEmpty ? event.eventType : event.label,
      subtitle: event.occurredAt ?? event.source,
      onTap: onTap,
    );
  }
}

class _NetworkTimelineWarningTile extends StatelessWidget {
  const _NetworkTimelineWarningTile({required this.warning});

  final _NetworkTimelineWarning warning;

  @override
  Widget build(BuildContext context) {
    return _NetworkTimelineInlineWarning(message: warning.message);
  }
}

class _NetworkTimelineInlineWarning extends StatelessWidget {
  const _NetworkTimelineInlineWarning({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _amberColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _amberColor.withValues(alpha: 0.24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: _amberColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _inkColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkTimelineMissingSelection extends StatelessWidget {
  const _NetworkTimelineMissingSelection();

  @override
  Widget build(BuildContext context) {
    return Text(
      'O item selecionado nao existe mais no recorte atual.',
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
    );
  }
}

class _NetworkCurrentSnapshotSection extends StatelessWidget {
  const _NetworkCurrentSnapshotSection({
    required this.runtimeData,
    required this.onRetry,
  });

  final _NetworkTimelineRuntimeData runtimeData;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (!runtimeData.isLoading &&
        !runtimeData.isLive &&
        runtimeData.errorMessage != null) {
      return _NetworkTimelineStateNotice(
        icon: Icons.cloud_off_outlined,
        title: 'Estado atual indisponivel',
        message: runtimeData.errorMessage!,
        actionLabel: 'Tentar novamente',
        onAction: onRetry,
      );
    }

    final snapshot = runtimeData.payload.currentSnapshot;
    if (!runtimeData.isLoading && snapshot.contracts.isEmpty) {
      return const _NetworkTimelineStateNotice(
        icon: Icons.account_tree_outlined,
        title: 'Sem estado atual',
        message:
            'O payload da timeline nao retornou contratos ativos para a data de referencia.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 18, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _RelationalMetricPill(
                icon: Icons.description_outlined,
                label: '${snapshot.contractsCount} contratos ativos',
              ),
              _RelationalMetricPill(
                icon: Icons.work_outline_rounded,
                label: '${snapshot.positionsCount} postos ativos',
              ),
              _RelationalMetricPill(
                icon: Icons.badge_outlined,
                label: '${snapshot.collaboratorsCount} colaboradores ativos',
              ),
            ],
          ),
          const SizedBox(height: 18),
          for (final contract in snapshot.contracts)
            _NetworkCurrentContractBlock(
              snapshot: snapshot,
              contract: contract,
            ),
        ],
      ),
    );
  }
}

class _NetworkCurrentContractBlock extends StatelessWidget {
  const _NetworkCurrentContractBlock({
    required this.snapshot,
    required this.contract,
  });

  final _NetworkTimelineCurrentSnapshot snapshot;
  final _NetworkTimelineSnapshotContract contract;

  @override
  Widget build(BuildContext context) {
    final positions = snapshot.positionsForContract(contract.publicId);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _lineColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: _timelineStatusColor(contract.status),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  contract.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              _Tag(
                label: _titleCase(contract.status),
                color: _timelineStatusColor(contract.status),
                background: _timelineStatusColor(
                  contract.status,
                ).withValues(alpha: 0.10),
                icon: Icons.circle,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _RelationalMetricPill(
                icon: Icons.work_outline_rounded,
                label: '${contract.activePositions} postos',
              ),
              _RelationalMetricPill(
                icon: Icons.badge_outlined,
                label: '${contract.activeCollaborators} colaboradores',
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final position in positions)
            _NetworkCurrentPositionRow(snapshot: snapshot, position: position),
        ],
      ),
    );
  }
}

class _NetworkCurrentPositionRow extends StatelessWidget {
  const _NetworkCurrentPositionRow({
    required this.snapshot,
    required this.position,
  });

  final _NetworkTimelineCurrentSnapshot snapshot;
  final _NetworkTimelineSnapshotPosition position;

  @override
  Widget build(BuildContext context) {
    final collaborators = snapshot.collaboratorsForPosition(position.publicId);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _lineColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.work_outline_rounded, color: _slateColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  position.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '${position.activeCollaborators}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: _mutedColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          if (collaborators.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final collaborator in collaborators)
                  _Tag(
                    label: collaborator.personName,
                    color: _deepTealColor,
                    background: _deepTealColor.withValues(alpha: 0.08),
                    icon: Icons.badge_outlined,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _NetworkTimelineOverview extends StatelessWidget {
  const _NetworkTimelineOverview({
    required this.payload,
    required this.sourceLabel,
    required this.isLoading,
    required this.errorMessage,
  });

  final _NetworkTimelinePayload payload;
  final String sourceLabel;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final recentEvents = payload.events.reversed.take(4).toList();
    final focusLabel = payload.focus.displayName;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFCFA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _lineColor),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 900;
            final header = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.timeline_outlined,
                      color: _deepTealColor,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        focusLabel == null
                            ? 'Linha do tempo relacional'
                            : 'Linha do tempo: $focusLabel',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: _inkColor,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    if (isLoading)
                      const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _RelationalMetricPill(
                      icon: Icons.event_note_outlined,
                      label: '${payload.events.length} eventos',
                    ),
                    _RelationalMetricPill(
                      icon: Icons.description_outlined,
                      label:
                          '${payload.currentSnapshot.contractsCount} contratos ativos',
                    ),
                    _RelationalMetricPill(
                      icon: Icons.work_outline_rounded,
                      label:
                          '${payload.currentSnapshot.positionsCount} postos ativos',
                    ),
                    _RelationalMetricPill(
                      icon: Icons.badge_outlined,
                      label:
                          '${payload.currentSnapshot.collaboratorsCount} colaboradores ativos',
                    ),
                    if (payload.warnings.isNotEmpty)
                      _RelationalMetricPill(
                        icon: Icons.warning_amber_rounded,
                        label: '${payload.warnings.length} alertas',
                      ),
                  ],
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    errorMessage!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _roseColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  Text(
                    '$sourceLabel | ${payload.period.from} a ${payload.period.to}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _mutedColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            );
            final events = recentEvents.isEmpty
                ? Text(
                    'Sem eventos no recorte atual.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _mutedColor,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : Column(
                    children: [
                      for (final event in recentEvents)
                        _NetworkTimelineEventRow(event: event),
                    ],
                  );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [header, const SizedBox(height: 14), events],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 420, child: header),
                const SizedBox(width: 18),
                Expanded(child: events),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NetworkTimelineEventRow extends StatelessWidget {
  const _NetworkTimelineEventRow({required this.event});

  final _NetworkTimelineEvent event;

  @override
  Widget build(BuildContext context) {
    final secondary = event.linkedEntities.isEmpty
        ? event.source
        : event.linkedEntities.first.labelSnapshot;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _tealColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _tealColor.withValues(alpha: 0.20)),
            ),
            child: Icon(
              _timelineEventIcon(event.eventType),
              color: _deepTealColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _inkColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  secondary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _mutedColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            event.occurredAt ?? '',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: _slateColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

IconData _timelineEventIcon(String eventType) {
  return switch (eventType) {
    'admission' => Icons.login_rounded,
    'move' => Icons.swap_horiz_rounded,
    'dismissal' => Icons.logout_rounded,
    'calendar_entry' => Icons.event_available_outlined,
    'timeline_record' => Icons.edit_note_outlined,
    _ => Icons.timeline_outlined,
  };
}

class _NetworkRuntimeNotice extends StatelessWidget {
  const _NetworkRuntimeNotice({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _lineColor),
            boxShadow: [
              BoxShadow(
                color: _slateColor.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
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

List<_NetworkFacetOption> _networkFacetOptions(Map<String, int> counts) {
  final options = [
    for (final entry in counts.entries)
      _NetworkFacetOption(
        value: entry.key,
        label: entry.key,
        count: entry.value,
      ),
  ];
  options.sort((left, right) {
    final byCount = right.count.compareTo(left.count);
    if (byCount != 0) {
      return byCount;
    }
    return left.label.toLowerCase().compareTo(right.label.toLowerCase());
  });
  return options;
}

String _remoteNetworkSearchText(String input) {
  return _NetworkSearchQuery.parse(input).freeText;
}

enum _NetworkTenurePreset { upToOne, oneToThree, threeToFive, fivePlus }

extension on _NetworkTenurePreset {
  String get label => switch (this) {
    _NetworkTenurePreset.upToOne => 'Ate 1 ano',
    _NetworkTenurePreset.oneToThree => '1 a 3 anos',
    _NetworkTenurePreset.threeToFive => '3 a 5 anos',
    _NetworkTenurePreset.fivePlus => '5 anos ou mais',
  };

  bool matches(double years) {
    return switch (this) {
      _NetworkTenurePreset.upToOne => years <= 1,
      _NetworkTenurePreset.oneToThree => years >= 1 && years <= 3,
      _NetworkTenurePreset.threeToFive => years >= 3 && years <= 5,
      _NetworkTenurePreset.fivePlus => years >= 5,
    };
  }
}

enum _NetworkReportPreset {
  activeEmployees,
  admissionProcess,
  attentionEmployees,
  recentHires,
  dismissedEmployees,
  endedContracts,
}

extension on _NetworkReportPreset {
  String get label => switch (this) {
    _NetworkReportPreset.activeEmployees => 'Colaboradores ativos',
    _NetworkReportPreset.admissionProcess => 'Em processo admissional',
    _NetworkReportPreset.attentionEmployees => 'Colaboradores com atencao',
    _NetworkReportPreset.recentHires => 'Contratados recentes',
    _NetworkReportPreset.dismissedEmployees => 'Desligados ou historicos',
    _NetworkReportPreset.endedContracts => 'Contratos/posicoes encerrados',
  };

  IconData get icon => switch (this) {
    _NetworkReportPreset.activeEmployees => Icons.badge_outlined,
    _NetworkReportPreset.admissionProcess => Icons.how_to_reg_outlined,
    _NetworkReportPreset.attentionEmployees => Icons.warning_amber_rounded,
    _NetworkReportPreset.recentHires => Icons.event_available_outlined,
    _NetworkReportPreset.dismissedEmployees =>
      Icons.history_toggle_off_outlined,
    _NetworkReportPreset.endedContracts => Icons.description_outlined,
  };

  bool matches(_NetworkGraphNode node) {
    return switch (this) {
      _NetworkReportPreset.activeEmployees =>
        node.lane == _NetworkGraphLane.employee && _isActiveStatus(node.status),
      _NetworkReportPreset.admissionProcess =>
        node.lane == _NetworkGraphLane.employee &&
            _nodeHasAdmissionSignal(node),
      _NetworkReportPreset.attentionEmployees =>
        node.lane == _NetworkGraphLane.employee && _nodeNeedsAttention(node),
      _NetworkReportPreset.recentHires =>
        node.lane == _NetworkGraphLane.employee &&
            ((_nodeTenureYears(node) ?? 999) <= 1),
      _NetworkReportPreset.dismissedEmployees =>
        node.lane == _NetworkGraphLane.employee &&
            !_isActiveStatus(node.status),
      _NetworkReportPreset.endedContracts =>
        (node.lane == _NetworkGraphLane.contract ||
                node.lane == _NetworkGraphLane.position) &&
            !_isActiveStatus(node.status),
    };
  }
}

enum _NetworkManagementReportType {
  networkSummary,
  activeEmployees,
  admissionProcess,
  hiredByPeriod,
  historicalEmployees,
  contractsAndPositions,
  attentionAndCompliance,
  distributionByPosition,
  distributionByDepartment,
  distributionByStatus,
  companyQuery,
  hirePeriodQuery,
}

class _NetworkManagementReportDefinition {
  const _NetworkManagementReportDefinition(this.type);

  final _NetworkManagementReportType type;

  String get menuLabel => type.menuLabel;
  String get title => type.title;
  String get subtitle => type.subtitle;
  IconData get icon => type.icon;
  bool get chart => type.chart;
}

extension on _NetworkManagementReportType {
  String get menuLabel => switch (this) {
    _NetworkManagementReportType.networkSummary => 'Resumo da malha',
    _NetworkManagementReportType.activeEmployees => 'Quadro ativo',
    _NetworkManagementReportType.admissionProcess => 'Em processo admissional',
    _NetworkManagementReportType.hiredByPeriod => 'Contratados por periodo',
    _NetworkManagementReportType.historicalEmployees =>
      'Desligados e historicos',
    _NetworkManagementReportType.contractsAndPositions =>
      'Contratos e posicoes',
    _NetworkManagementReportType.attentionAndCompliance =>
      'Pendencias e atencao',
    _NetworkManagementReportType.distributionByPosition => 'Por cargo',
    _NetworkManagementReportType.distributionByDepartment => 'Por departamento',
    _NetworkManagementReportType.distributionByStatus => 'Por status',
    _NetworkManagementReportType.companyQuery => 'Consulta por empresa',
    _NetworkManagementReportType.hirePeriodQuery => 'Consulta por admissao',
  };

  String get title => switch (this) {
    _NetworkManagementReportType.networkSummary =>
      'Resumo gerencial da Network',
    _NetworkManagementReportType.activeEmployees => 'Relatorio de quadro ativo',
    _NetworkManagementReportType.admissionProcess => 'Relatorio admissional',
    _NetworkManagementReportType.hiredByPeriod =>
      'Relatorio de contratacoes por periodo',
    _NetworkManagementReportType.historicalEmployees =>
      'Relatorio de desligados e historicos',
    _NetworkManagementReportType.contractsAndPositions =>
      'Relatorio de contratos e posicoes',
    _NetworkManagementReportType.attentionAndCompliance =>
      'Relatorio de atencao e compliance',
    _NetworkManagementReportType.distributionByPosition =>
      'Grafico de distribuicao por cargo',
    _NetworkManagementReportType.distributionByDepartment =>
      'Grafico de distribuicao por departamento',
    _NetworkManagementReportType.distributionByStatus =>
      'Grafico de distribuicao por status',
    _NetworkManagementReportType.companyQuery => 'Consulta por empresa',
    _NetworkManagementReportType.hirePeriodQuery =>
      'Consulta por periodo de admissao',
  };

  String get subtitle => switch (this) {
    _NetworkManagementReportType.networkSummary =>
      'Visao consolidada por camada, status e pontos de atencao.',
    _NetworkManagementReportType.activeEmployees =>
      'Colaboradores ativos, com filtros proprios de empresa, cargo e tempo.',
    _NetworkManagementReportType.admissionProcess =>
      'Colaboradores com sinais de admissao, onboarding ou pre-admissao.',
    _NetworkManagementReportType.hiredByPeriod =>
      'Colaboradores com data de inicio dentro do periodo escolhido.',
    _NetworkManagementReportType.historicalEmployees =>
      'Colaboradores que aparecem como desligados ou historicos.',
    _NetworkManagementReportType.contractsAndPositions =>
      'Contratos e posicoes por status, empresa e contexto operacional.',
    _NetworkManagementReportType.attentionAndCompliance =>
      'Itens com alerta, pendencia documental ou status nao ativo.',
    _NetworkManagementReportType.distributionByPosition =>
      'Contagem de colaboradores agrupada por cargo.',
    _NetworkManagementReportType.distributionByDepartment =>
      'Contagem de colaboradores agrupada por departamento.',
    _NetworkManagementReportType.distributionByStatus =>
      'Contagem agrupada por status operacional.',
    _NetworkManagementReportType.companyQuery =>
      'Consulta transversal de colaboradores, contratos e posicoes por empresa.',
    _NetworkManagementReportType.hirePeriodQuery =>
      'Consulta focada em colaboradores contratados entre datas.',
  };

  IconData get icon => switch (this) {
    _NetworkManagementReportType.networkSummary =>
      Icons.dashboard_customize_outlined,
    _NetworkManagementReportType.activeEmployees => Icons.badge_outlined,
    _NetworkManagementReportType.admissionProcess => Icons.how_to_reg_outlined,
    _NetworkManagementReportType.hiredByPeriod =>
      Icons.event_available_outlined,
    _NetworkManagementReportType.historicalEmployees =>
      Icons.history_toggle_off_outlined,
    _NetworkManagementReportType.contractsAndPositions =>
      Icons.description_outlined,
    _NetworkManagementReportType.attentionAndCompliance =>
      Icons.warning_amber_rounded,
    _NetworkManagementReportType.distributionByPosition =>
      Icons.work_outline_rounded,
    _NetworkManagementReportType.distributionByDepartment =>
      Icons.apartment_outlined,
    _NetworkManagementReportType.distributionByStatus => Icons.rule_rounded,
    _NetworkManagementReportType.companyQuery => Icons.business_outlined,
    _NetworkManagementReportType.hirePeriodQuery =>
      Icons.calendar_month_outlined,
  };

  bool get chart => switch (this) {
    _NetworkManagementReportType.distributionByPosition ||
    _NetworkManagementReportType.distributionByDepartment ||
    _NetworkManagementReportType.distributionByStatus ||
    _NetworkManagementReportType.networkSummary => true,
    _ => false,
  };
}

class _NetworkHireDateRange {
  const _NetworkHireDateRange({required this.label, this.start, this.end});

  factory _NetworkHireDateRange.preset(String key) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return switch (key) {
      'last6m' => _NetworkHireDateRange(
        label: 'Contratados nos ultimos 6 meses',
        start: _addMonths(today, -6),
        end: today,
      ),
      'last12m' => _NetworkHireDateRange(
        label: 'Contratados nos ultimos 12 meses',
        start: _addMonths(today, -12),
        end: today,
      ),
      'thisYear' => _NetworkHireDateRange(
        label: 'Contratados neste ano',
        start: DateTime(today.year),
        end: today,
      ),
      _ => const _NetworkHireDateRange(label: 'Contratacao personalizada'),
    };
  }

  final String label;
  final DateTime? start;
  final DateTime? end;

  bool matches(DateTime? date) {
    if (date == null) {
      return false;
    }
    if (start != null && date.isBefore(start!)) {
      return false;
    }
    if (end != null && date.isAfter(end!)) {
      return false;
    }
    return true;
  }

  String get signature =>
      '${start?.toIso8601String() ?? ''}|${end?.toIso8601String() ?? ''}';
}

class _NetworkHistoryEntry {
  const _NetworkHistoryEntry({
    required this.search,
    required this.selectedNodeId,
    required this.matrix,
    required this.zoom,
    required this.periodPreset,
    required this.selectedRootIds,
    required this.selectedClientIds,
    required this.contractStatuses,
    required this.employeeStatuses,
    required this.selectedDepartments,
    required this.selectedPositions,
    required this.includeHistorical,
    required this.includeIndirect,
    required this.includeTimelineMoves,
    required this.includeTimelineOperationalEvents,
    required this.timelineDateRange,
    required this.selectedTenurePreset,
    required this.customTenureYears,
    required this.hireDateRange,
    required this.reportPreset,
    required this.attentionOnly,
    required this.clusterEmployees,
    required this.drillDownNodeId,
    required this.workspaceMode,
    required this.hiddenLanes,
    required this.activeOnlyLanes,
  });

  factory _NetworkHistoryEntry.capture({
    required String search,
    required String selectedNodeId,
    required Matrix4 matrix,
    required double zoom,
    required String periodPreset,
    required Set<String> selectedRootIds,
    required Set<String> selectedClientIds,
    required Set<String> contractStatuses,
    required Set<String> employeeStatuses,
    required Set<String> selectedDepartments,
    required Set<String> selectedPositions,
    required bool includeHistorical,
    required bool includeIndirect,
    required bool includeTimelineMoves,
    required bool includeTimelineOperationalEvents,
    required DateTimeRange? timelineDateRange,
    required _NetworkTenurePreset? selectedTenurePreset,
    required RangeValues? customTenureYears,
    required _NetworkHireDateRange? hireDateRange,
    required _NetworkReportPreset? reportPreset,
    required bool attentionOnly,
    required bool clusterEmployees,
    required String? drillDownNodeId,
    required _NetworkWorkspaceMode workspaceMode,
    required Set<_NetworkGraphLane> hiddenLanes,
    required Set<_NetworkGraphLane> activeOnlyLanes,
  }) {
    return _NetworkHistoryEntry(
      search: search,
      selectedNodeId: selectedNodeId,
      matrix: Matrix4.copy(matrix),
      zoom: zoom,
      periodPreset: periodPreset,
      selectedRootIds: {...selectedRootIds},
      selectedClientIds: {...selectedClientIds},
      contractStatuses: {...contractStatuses},
      employeeStatuses: {...employeeStatuses},
      selectedDepartments: {...selectedDepartments},
      selectedPositions: {...selectedPositions},
      includeHistorical: includeHistorical,
      includeIndirect: includeIndirect,
      includeTimelineMoves: includeTimelineMoves,
      includeTimelineOperationalEvents: includeTimelineOperationalEvents,
      timelineDateRange: timelineDateRange == null
          ? null
          : DateTimeRange(
              start: timelineDateRange.start,
              end: timelineDateRange.end,
            ),
      selectedTenurePreset: selectedTenurePreset,
      customTenureYears: customTenureYears,
      hireDateRange: hireDateRange,
      reportPreset: reportPreset,
      attentionOnly: attentionOnly,
      clusterEmployees: clusterEmployees,
      drillDownNodeId: drillDownNodeId,
      workspaceMode: workspaceMode,
      hiddenLanes: {...hiddenLanes},
      activeOnlyLanes: {...activeOnlyLanes},
    );
  }

  final String search;
  final String selectedNodeId;
  final Matrix4 matrix;
  final double zoom;
  final String periodPreset;
  final Set<String> selectedRootIds;
  final Set<String> selectedClientIds;
  final Set<String> contractStatuses;
  final Set<String> employeeStatuses;
  final Set<String> selectedDepartments;
  final Set<String> selectedPositions;
  final bool includeHistorical;
  final bool includeIndirect;
  final bool includeTimelineMoves;
  final bool includeTimelineOperationalEvents;
  final DateTimeRange? timelineDateRange;
  final _NetworkTenurePreset? selectedTenurePreset;
  final RangeValues? customTenureYears;
  final _NetworkHireDateRange? hireDateRange;
  final _NetworkReportPreset? reportPreset;
  final bool attentionOnly;
  final bool clusterEmployees;
  final String? drillDownNodeId;
  final _NetworkWorkspaceMode workspaceMode;
  final Set<_NetworkGraphLane> hiddenLanes;
  final Set<_NetworkGraphLane> activeOnlyLanes;

  String get signature => [
    search,
    selectedNodeId,
    zoom.toStringAsFixed(2),
    periodPreset,
    _sortedSignature(selectedRootIds),
    _sortedSignature(selectedClientIds),
    _sortedSignature(contractStatuses),
    _sortedSignature(employeeStatuses),
    _sortedSignature(selectedDepartments),
    _sortedSignature(selectedPositions),
    includeHistorical,
    includeIndirect,
    includeTimelineMoves,
    includeTimelineOperationalEvents,
    timelineDateRange == null
        ? ''
        : '${_formatNetworkDateInput(timelineDateRange!.start)}-${_formatNetworkDateInput(timelineDateRange!.end)}',
    selectedTenurePreset?.name,
    customTenureYears == null
        ? ''
        : '${customTenureYears!.start}-${customTenureYears!.end}',
    hireDateRange?.signature,
    reportPreset?.name,
    attentionOnly,
    clusterEmployees,
    drillDownNodeId,
    workspaceMode.name,
    _sortedSignature(hiddenLanes.map((lane) => lane.name).toSet()),
    _sortedSignature(activeOnlyLanes.map((lane) => lane.name).toSet()),
  ].join('|');
}

class _NetworkSearchQuery {
  const _NetworkSearchQuery({required this.freeText, required this.facets});

  factory _NetworkSearchQuery.parse(String input) {
    final facets = <String, Set<String>>{};
    final source = input.trim();
    if (source.isEmpty) {
      return const _NetworkSearchQuery(freeText: '', facets: {});
    }

    final pattern = RegExp(
      r'([A-Za-z_]+)\s*:\s*([^:]+?)(?=\s+[A-Za-z_]+\s*:|$)',
      caseSensitive: false,
    );
    final buffer = StringBuffer();
    var cursor = 0;

    for (final match in pattern.allMatches(source)) {
      if (match.start > cursor) {
        buffer.write(' ${source.substring(cursor, match.start)} ');
      }
      final rawKey = match.group(1) ?? '';
      final rawValues = match.group(2) ?? '';
      final key = _normalizeNetworkText(rawKey);
      final values = rawValues
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty);
      for (final value in values) {
        facets.putIfAbsent(key, () => <String>{}).add(value);
      }
      cursor = match.end;
    }

    if (cursor < source.length) {
      buffer.write(' ${source.substring(cursor)} ');
    }

    return _NetworkSearchQuery(
      freeText: buffer.toString().trim().replaceAll(RegExp(r'\s+'), ' '),
      facets: facets,
    );
  }

  final String freeText;
  final Map<String, Set<String>> facets;

  bool get isEmpty => freeText.isEmpty && facets.isEmpty;

  List<String> get activeLabels {
    final labels = <String>[];
    if (freeText.isNotEmpty) {
      labels.add('Busca: $freeText');
    }
    for (final entry in facets.entries) {
      labels.add('${_searchFacetLabel(entry.key)}: ${entry.value.join(', ')}');
    }
    return labels;
  }

  bool matches(_NetworkGraphNode node) {
    if (isEmpty) {
      return true;
    }
    for (final entry in facets.entries) {
      if (!_matchesNetworkFacet(node, entry.key, entry.value)) {
        return false;
      }
    }
    if (freeText.isEmpty) {
      return true;
    }
    return _nodeSearchHaystack(node).contains(_normalizeNetworkText(freeText));
  }
}

bool _matchesNetworkFacet(
  _NetworkGraphNode node,
  String key,
  Set<String> values,
) {
  final normalizedKey = _normalizeNetworkText(key);
  return switch (normalizedKey) {
    'status' => values.any(
      (value) =>
          _facetValueMatches(node.status, value) ||
          _facetValueMatches(
            '${node.detailSnapshot.extras['statusLabel']}',
            value,
          ),
    ),
    'tipo' || 'camada' || 'lane' => values.any(
      (value) =>
          _facetValueMatches(_laneLabel(node.lane), value) ||
          _facetValueMatches(node.nodeType.name, value),
    ),
    'cargo' || 'posicao' || 'position' => values.any(
      (value) => _facetValueMatches(_nodePosition(node), value),
    ),
    'departamento' || 'setor' || 'department' => values.any(
      (value) => _facetValueMatches(_nodeDepartment(node), value),
    ),
    'tempo' || 'servico' || 'tenure' => values.any(
      (value) => _matchesYearsExpression(_nodeTenureYears(node), value),
    ),
    'contratado' || 'admissao' || 'inicio' || 'hire' => values.any(
      (value) => _matchesDateExpression(_nodeStartDate(node), value),
    ),
    'alerta' || 'alertas' || 'atencao' => values.any((value) {
      final normalized = _normalizeNetworkText(value);
      final wantsAttention =
          normalized == 'sim' ||
          normalized == 'true' ||
          normalized == '1' ||
          normalized == 'com' ||
          normalized == 'atencao';
      final rejectsAttention =
          normalized == 'nao' ||
          normalized == 'false' ||
          normalized == '0' ||
          normalized == 'sem';
      if (wantsAttention) {
        return _nodeNeedsAttention(node);
      }
      if (rejectsAttention) {
        return !_nodeNeedsAttention(node);
      }
      return _normalizeNetworkText(
        _nodeAttentionLabel(node),
      ).contains(normalized);
    }),
    _ => values.any(
      (value) =>
          _nodeSearchHaystack(node).contains(_normalizeNetworkText(value)),
    ),
  };
}

String _searchFacetLabel(String key) {
  return switch (_normalizeNetworkText(key)) {
    'cargo' || 'posicao' || 'position' => 'Cargo',
    'departamento' || 'setor' || 'department' => 'Departamento',
    'status' => 'Status',
    'tipo' || 'camada' || 'lane' => 'Tipo',
    'tempo' || 'servico' || 'tenure' => 'Tempo',
    'contratado' || 'admissao' || 'inicio' || 'hire' => 'Admissao',
    'alerta' || 'alertas' || 'atencao' => 'Atencao',
    _ => key,
  };
}

String _nodeSearchHaystack(_NetworkGraphNode node) {
  const searchableExtraKeys = {
    'statusLabel',
    'department',
    'manager',
    'clientCompany',
    'contract',
    'position',
    'location',
    'scale',
    'schedule',
    'service',
    'shift',
    'contractStatus',
    'startDate',
  };
  final parts = <String>[
    node.displayName,
    node.subtitle,
    node.status,
    _laneLabel(node.lane),
    node.nodeType.name,
    node.detailSnapshot.summary,
    ...node.badges,
    ...node.detailSnapshot.rootCompanies,
    ...node.detailSnapshot.clientCompanies,
  ];
  for (final entry in node.detailSnapshot.extras.entries) {
    if (searchableExtraKeys.contains(entry.key) && entry.value != null) {
      parts.add('${entry.value}');
    }
  }
  return _normalizeNetworkText(parts.join(' '));
}

String? _nodeDepartment(_NetworkGraphNode node) {
  final value = node.detailSnapshot.extras['department'];
  if (value == null) {
    return null;
  }
  final text = '$value'.trim();
  return text.isEmpty || text == '-' ? null : text;
}

String? _nodePosition(_NetworkGraphNode node) {
  if (node.lane == _NetworkGraphLane.position) {
    return node.displayName;
  }
  final value = node.detailSnapshot.extras['position'];
  if (value != null) {
    final text = '$value'.trim();
    return text.isEmpty || text == '-' ? null : text;
  }
  if (node.lane == _NetworkGraphLane.employee) {
    final subtitle = node.subtitle.trim();
    return subtitle.isEmpty || subtitle == '-' ? null : subtitle;
  }
  return null;
}

DateTime? _nodeStartDate(_NetworkGraphNode node) {
  final value = node.detailSnapshot.extras['startDate'];
  if (value == null) {
    return null;
  }
  return _parseNetworkDate('$value');
}

double? _nodeTenureYears(_NetworkGraphNode node) {
  final start = _nodeStartDate(node);
  if (start == null) {
    return null;
  }
  final now = DateTime.now();
  if (start.isAfter(now)) {
    return 0;
  }
  return now.difference(start).inDays / 365.25;
}

bool _matchesTenureFilters(
  _NetworkGraphNode node, {
  required _NetworkTenurePreset? preset,
  required RangeValues? customRange,
}) {
  if (preset == null && customRange == null) {
    return true;
  }
  if (node.lane != _NetworkGraphLane.employee) {
    return false;
  }
  final years = _nodeTenureYears(node);
  if (years == null) {
    return false;
  }
  if (preset != null) {
    return preset.matches(years);
  }
  if (customRange != null) {
    return years >= customRange.start && years <= customRange.end;
  }
  return true;
}

bool _nodeHasAdmissionSignal(_NetworkGraphNode node) {
  final text = _nodeSearchHaystack(node);
  return text.contains('admiss') ||
      text.contains('onboarding') ||
      text.contains('pre admissao') ||
      text.contains('pre-admissao') ||
      text.contains('processo admissional');
}

DateTime? _parseNetworkDate(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed == '-') {
    return null;
  }
  final iso = DateTime.tryParse(trimmed);
  if (iso != null) {
    return DateTime(iso.year, iso.month, iso.day);
  }

  final slash = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$').firstMatch(trimmed);
  if (slash != null) {
    final day = int.tryParse(slash.group(1)!);
    final month = int.tryParse(slash.group(2)!);
    final year = int.tryParse(slash.group(3)!);
    if (day != null && month != null && year != null) {
      return DateTime(year, month, day);
    }
  }

  final text = RegExp(
    r'^([A-Za-z]{3,9})\s+(\d{1,2}),\s*(\d{4})$',
  ).firstMatch(trimmed);
  if (text != null) {
    final month = _monthNumber(text.group(1)!);
    final day = int.tryParse(text.group(2)!);
    final year = int.tryParse(text.group(3)!);
    if (month != null && day != null && year != null) {
      return DateTime(year, month, day);
    }
  }

  return null;
}

int? _monthNumber(String value) {
  return switch (_normalizeNetworkText(
    value,
  ).substring(0, min(3, value.length))) {
    'jan' => 1,
    'feb' || 'fev' => 2,
    'mar' => 3,
    'apr' || 'abr' => 4,
    'may' || 'mai' => 5,
    'jun' => 6,
    'jul' => 7,
    'aug' || 'ago' => 8,
    'sep' || 'set' => 9,
    'oct' || 'out' => 10,
    'nov' => 11,
    'dec' || 'dez' => 12,
    _ => null,
  };
}

DateTime _addMonths(DateTime date, int months) {
  final rawMonth = date.month + months;
  final year = date.year + ((rawMonth - 1) ~/ 12);
  final month = ((rawMonth - 1) % 12) + 1;
  final lastDay = DateTime(year, month + 1, 0).day;
  return DateTime(year, month, min(date.day, lastDay));
}

String _formatNetworkDateInput(DateTime? date) {
  if (date == null) {
    return '';
  }
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

String _timelineRangeFilterLabel(DateTimeRange? range) {
  if (range == null) {
    return 'Intervalo customizado';
  }
  return '${_formatNetworkDateInput(range.start)} a ${_formatNetworkDateInput(range.end)}';
}

bool _allStatusesSelected(List<String> available, Set<String> selected) {
  return available.every(selected.contains);
}

String _sortedSignature(Iterable<String> values) {
  final sorted = values.toList()..sort();
  return sorted.join(',');
}

String _tenureFilterLabel(
  _NetworkTenurePreset? preset,
  RangeValues? customRange,
) {
  if (preset != null) {
    return 'Tempo: ${preset.label}';
  }
  if (customRange != null) {
    return 'Tempo: ${customRange.start.round()} a ${customRange.end.round()} anos';
  }
  return 'Tempo de servico';
}

bool _facetValueMatches(String? candidate, String value) {
  if (candidate == null || candidate.trim().isEmpty) {
    return false;
  }
  final left = _normalizeNetworkText(candidate);
  final right = _normalizeNetworkText(value);
  return left.contains(right) || right.contains(left);
}

bool _matchesYearsExpression(double? years, String expression) {
  if (years == null) {
    return false;
  }
  final normalized = _normalizeNetworkText(expression).replaceAll('anos', '');
  final range = RegExp(
    r'(\d+(?:\.\d+)?)\s*(?:\.\.|-|a)\s*(\d+(?:\.\d+)?)',
  ).firstMatch(normalized);
  if (range != null) {
    final start = double.tryParse(range.group(1)!);
    final end = double.tryParse(range.group(2)!);
    if (start != null && end != null) {
      return years >= min(start, end) && years <= max(start, end);
    }
  }
  final minimum = RegExp(
    r'(?:>=|mais de|acima de)\s*(\d+)',
  ).firstMatch(normalized);
  if (minimum != null) {
    final value = double.tryParse(minimum.group(1)!);
    return value != null && years >= value;
  }
  final maximum = RegExp(
    r'(?:<=|ate|abaixo de)\s*(\d+)',
  ).firstMatch(normalized);
  if (maximum != null) {
    final value = double.tryParse(maximum.group(1)!);
    return value != null && years <= value;
  }
  final exact = double.tryParse(normalized.trim());
  return exact != null && years.round() == exact.round();
}

bool _matchesDateExpression(DateTime? date, String expression) {
  if (date == null) {
    return false;
  }
  final parts = expression.split('..');
  if (parts.length == 2) {
    return _NetworkHireDateRange(
      label: expression,
      start: _parseNetworkDate(parts.first),
      end: _parseNetworkDate(parts.last),
    ).matches(date);
  }
  final single = _parseNetworkDate(expression);
  if (single == null) {
    return false;
  }
  return date.year == single.year &&
      date.month == single.month &&
      date.day == single.day;
}

bool _nodeNeedsAttention(_NetworkGraphNode node) {
  if (_nodeHasWarningSignal(node)) {
    return true;
  }
  if (node.lane == _NetworkGraphLane.contract ||
      node.lane == _NetworkGraphLane.position ||
      node.lane == _NetworkGraphLane.employee) {
    return !_isActiveStatus(node.status);
  }
  return false;
}

bool _nodeHasWarningSignal(_NetworkGraphNode node) {
  const warningKeys = {
    'hasWarnings',
    'hasWarning',
    'hasAlerts',
    'warning',
    'warnings',
    'warningsCount',
    'alertsCount',
    'attentionCount',
    'pendingDocuments',
  };
  for (final entry in node.detailSnapshot.extras.entries) {
    if (warningKeys.contains(entry.key) && _isTruthyNetworkValue(entry.value)) {
      return true;
    }
  }
  final badgeText = _normalizeNetworkText(node.badges.join(' '));
  return badgeText.contains('warning') ||
      badgeText.contains('alert') ||
      badgeText.contains('advertencia') ||
      badgeText.contains('pendente') ||
      badgeText.contains('risco');
}

bool _isTruthyNetworkValue(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value > 0;
  }
  if (value is String) {
    final normalized = _normalizeNetworkText(value);
    return normalized == 'true' ||
        normalized == 'sim' ||
        normalized == 'yes' ||
        normalized == '1' ||
        normalized == 'warning' ||
        normalized == 'alert';
  }
  if (value is Iterable) {
    return value.isNotEmpty;
  }
  return false;
}

String _nodeAttentionLabel(_NetworkGraphNode node) {
  if (_nodeHasWarningSignal(node)) {
    return 'Possui sinal de alerta no payload';
  }
  if (!_isActiveStatus(node.status)) {
    return 'Status nao ativo: ${_titleCase(node.status)}';
  }
  return 'Sem alerta operacional';
}

Set<String> _expandedNetworkContextIds({
  required Set<String> seedIds,
  required List<_NetworkGraphEdge> edges,
  required int maxDepth,
}) {
  if (seedIds.isEmpty || maxDepth < 0) {
    return seedIds;
  }

  final result = {...seedIds};
  var frontier = {...seedIds};

  for (var depth = 0; depth < maxDepth; depth++) {
    final next = <String>{};
    for (final edge in edges) {
      if (frontier.contains(edge.fromPublicId) &&
          !result.contains(edge.toPublicId)) {
        next.add(edge.toPublicId);
      }
      if (frontier.contains(edge.toPublicId) &&
          !result.contains(edge.fromPublicId)) {
        next.add(edge.fromPublicId);
      }
    }
    if (next.isEmpty) {
      break;
    }
    result.addAll(next);
    frontier = next;
  }

  return result;
}

class _RelationalClusterResult {
  const _RelationalClusterResult({required this.nodes, required this.edges});

  final List<_NetworkGraphNode> nodes;
  final List<_NetworkGraphEdge> edges;
}

_RelationalClusterResult _clusterEmployeeNodes({
  required List<_NetworkGraphNode> nodes,
  required List<_NetworkGraphEdge> edges,
  required String selectedNodeId,
}) {
  final employees = nodes
      .where((node) => node.lane == _NetworkGraphLane.employee)
      .toList();
  if (employees.length < 8) {
    return _RelationalClusterResult(nodes: nodes, edges: edges);
  }

  final groups = <String, List<_NetworkGraphNode>>{};
  for (final employee in employees) {
    if (employee.publicId == selectedNodeId) {
      continue;
    }
    final key = _nodePosition(employee) ?? employee.subtitle;
    groups.putIfAbsent(key, () => <_NetworkGraphNode>[]).add(employee);
  }

  final clusteredIds = <String, String>{};
  final clusterNodes = <_NetworkGraphNode>[];

  for (final entry in groups.entries) {
    if (entry.value.length < 3) {
      continue;
    }
    final clusterId = 'cluster_employee_${_safeNetworkId(entry.key)}';
    for (final node in entry.value) {
      clusteredIds[node.publicId] = clusterId;
    }
    final activeCount = entry.value
        .where((node) => _isActiveStatus(node.status))
        .length;
    clusterNodes.add(
      _NetworkGraphNode(
        publicId: clusterId,
        nodeType: _NetworkGraphNodeType.employee,
        lane: _NetworkGraphLane.employee,
        displayName: '${entry.value.length} ${entry.key}',
        subtitle: '$activeCount ativos no agrupamento',
        status: activeCount == entry.value.length ? 'active' : 'mixed',
        badges: ['agrupamento', '${entry.value.length} colaboradores'],
        detailSnapshot: _NetworkDetailSnapshot(
          kind: 'employee_cluster',
          summary:
              'Agrupamento visual por cargo para reduzir poluicao na visao macro.',
          activeEmployees: activeCount,
          historicalEmployees: entry.value.length - activeCount,
          cta: _NetworkDetailCta(
            label: 'Abrir agrupamento',
            targetPublicId: clusterId,
          ),
          extras: {'position': entry.key, 'statusLabel': 'Cluster'},
        ),
      ),
    );
  }

  if (clusteredIds.isEmpty) {
    return _RelationalClusterResult(nodes: nodes, edges: edges);
  }

  final nextNodes = [
    for (final node in nodes)
      if (!clusteredIds.containsKey(node.publicId)) node,
    ...clusterNodes,
  ];
  final emitted = <String>{};
  final nextEdges = <_NetworkGraphEdge>[];

  for (final edge in edges) {
    final from = clusteredIds[edge.fromPublicId] ?? edge.fromPublicId;
    final to = clusteredIds[edge.toPublicId] ?? edge.toPublicId;
    if (from == to) {
      continue;
    }
    final key = '$from|$to|${edge.relationshipState.name}';
    if (!emitted.add(key)) {
      continue;
    }
    nextEdges.add(
      _NetworkGraphEdge(
        publicId: 'cluster_${edge.publicId}_${from}_$to',
        fromPublicId: from,
        toPublicId: to,
        relationshipKind: edge.relationshipKind,
        relationshipState: edge.relationshipState,
        periodStart: edge.periodStart,
        periodEnd: edge.periodEnd,
        metadataLabel: edge.metadataLabel,
      ),
    );
  }

  return _RelationalClusterResult(nodes: nextNodes, edges: nextEdges);
}

String _safeNetworkId(String value) {
  final normalized = _normalizeNetworkText(
    value,
  ).replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'_+'), '_');
  return normalized.isEmpty ? 'sem_cargo' : normalized;
}

int _drillDepthFor(_NetworkGraphNode? node) {
  return switch (node?.lane) {
    _NetworkGraphLane.rootCompany => 4,
    _NetworkGraphLane.clientCompany => 3,
    _NetworkGraphLane.contract => 2,
    _NetworkGraphLane.position => 1,
    _NetworkGraphLane.employee => 1,
    null => 3,
  };
}

String _normalizeNetworkText(String value) {
  return value
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('à', 'a')
      .replaceAll('â', 'a')
      .replaceAll('ã', 'a')
      .replaceAll('ä', 'a')
      .replaceAll('é', 'e')
      .replaceAll('è', 'e')
      .replaceAll('ê', 'e')
      .replaceAll('ë', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ì', 'i')
      .replaceAll('î', 'i')
      .replaceAll('ï', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ò', 'o')
      .replaceAll('ô', 'o')
      .replaceAll('õ', 'o')
      .replaceAll('ö', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ù', 'u')
      .replaceAll('û', 'u')
      .replaceAll('ü', 'u')
      .replaceAll('ç', 'c')
      .trim();
}

List<_NetworkGraphEdge> _bridgeHiddenNodeEdges({
  required List<_NetworkGraphEdge> edges,
  required Set<String> hiddenNodeIds,
  required Set<String> allowedIds,
}) {
  final hiddenIds = hiddenNodeIds.intersection(allowedIds);
  if (hiddenIds.isEmpty) {
    return edges;
  }

  final outgoing = <String, List<_NetworkGraphEdge>>{};
  for (final edge in edges) {
    outgoing.putIfAbsent(edge.fromPublicId, () => []).add(edge);
  }

  final result = <_NetworkGraphEdge>[];
  final emitted = <String>{};

  void emit(_NetworkGraphEdge edge) {
    final key =
        '${edge.fromPublicId}|${edge.toPublicId}|${edge.relationshipState.name}';
    if (emitted.add(key)) {
      result.add(edge);
    }
  }

  void walk({
    required String sourceId,
    required String currentId,
    required _NetworkGraphRelationshipState state,
    required String seedPublicId,
    Set<String> visited = const {},
  }) {
    if (!allowedIds.contains(currentId) || sourceId == currentId) {
      return;
    }

    if (!hiddenIds.contains(currentId)) {
      emit(
        _NetworkGraphEdge(
          publicId: 'bridge_${seedPublicId}_${sourceId}_$currentId',
          fromPublicId: sourceId,
          toPublicId: currentId,
          relationshipKind: 'hidden_node_bridge',
          relationshipState: state,
          periodStart: null,
          periodEnd: null,
          metadataLabel: 'hidden node bridge',
        ),
      );
      return;
    }

    if (visited.contains(currentId)) {
      return;
    }
    final nextVisited = {...visited, currentId};
    for (final nextEdge in outgoing[currentId] ?? const <_NetworkGraphEdge>[]) {
      walk(
        sourceId: sourceId,
        currentId: nextEdge.toPublicId,
        state: _mergeRelationshipState(state, nextEdge.relationshipState),
        seedPublicId: seedPublicId,
        visited: nextVisited,
      );
    }
  }

  for (final edge in edges) {
    if (hiddenIds.contains(edge.fromPublicId)) {
      continue;
    }
    if (!hiddenIds.contains(edge.toPublicId)) {
      emit(edge);
      continue;
    }
    walk(
      sourceId: edge.fromPublicId,
      currentId: edge.toPublicId,
      state: edge.relationshipState,
      seedPublicId: edge.publicId,
    );
  }

  return result;
}

_NetworkGraphRelationshipState _mergeRelationshipState(
  _NetworkGraphRelationshipState first,
  _NetworkGraphRelationshipState second,
) {
  if (first == _NetworkGraphRelationshipState.indirect ||
      second == _NetworkGraphRelationshipState.indirect) {
    return _NetworkGraphRelationshipState.indirect;
  }
  if (first == _NetworkGraphRelationshipState.historical ||
      second == _NetworkGraphRelationshipState.historical) {
    return _NetworkGraphRelationshipState.historical;
  }
  return _NetworkGraphRelationshipState.active;
}

bool _isActiveStatus(String status) {
  return status == 'active';
}

String _inactiveFilterLabelFor(_NetworkGraphLane lane) {
  return switch (lane) {
    _NetworkGraphLane.rootCompany => 'Ocultar clientes inativos',
    _NetworkGraphLane.clientCompany => 'Ocultar contratos encerrados',
    _NetworkGraphLane.contract => 'Ocultar posicoes encerradas',
    _NetworkGraphLane.position => 'Ocultar colaboradores desligados',
    _NetworkGraphLane.employee => 'Ocultar vinculos encerrados',
  };
}

_NetworkGraphLane _filterTargetLaneFor(_NetworkGraphLane lane) {
  return switch (lane) {
    _NetworkGraphLane.rootCompany => _NetworkGraphLane.clientCompany,
    _NetworkGraphLane.clientCompany => _NetworkGraphLane.contract,
    _NetworkGraphLane.contract => _NetworkGraphLane.position,
    _NetworkGraphLane.position => _NetworkGraphLane.employee,
    _NetworkGraphLane.employee => _NetworkGraphLane.employee,
  };
}

String _inactiveCountLabelFor(_NetworkGraphLane lane) {
  return switch (lane) {
    _NetworkGraphLane.rootCompany => 'Grupos inativos',
    _NetworkGraphLane.clientCompany => 'Clientes inativos',
    _NetworkGraphLane.contract => 'Contratos encerrados',
    _NetworkGraphLane.position => 'Posicoes encerradas',
    _NetworkGraphLane.employee => 'Colaboradores desligados',
  };
}

class _RelationalNetworkView {
  const _RelationalNetworkView({
    required this.nodes,
    required this.edges,
    required this.payload,
  });

  final List<_NetworkGraphNode> nodes;
  final List<_NetworkGraphEdge> edges;
  final _NetworkGraphPayload payload;

  _NetworkGraphNode? selectedNodeFor(String selectedNodeId) {
    for (final node in nodes) {
      if (node.publicId == selectedNodeId) {
        return node;
      }
    }

    if (payload.focus.selectedNodePublicId case final selected?) {
      for (final node in nodes) {
        if (node.publicId == selected) {
          return node;
        }
      }
    }

    return nodes.isEmpty ? null : nodes.first;
  }
}

class _RelationalCanvasLayout {
  const _RelationalCanvasLayout({
    required this.laneRailWidth,
    required this.contentWidth,
    required this.canvasHeight,
    required this.cardWidth,
    required this.cardHeight,
    required this.positions,
    required this.laneTops,
  });

  final double laneRailWidth;
  final double contentWidth;
  final double canvasHeight;
  final double cardWidth;
  final double cardHeight;
  final Map<String, Rect> positions;
  final Map<_NetworkGraphLane, double> laneTops;

  static _RelationalCanvasLayout compute({
    required double canvasWidth,
    required double laneRailWidth,
    required double topPadding,
    required double laneSpacing,
    required double horizontalPadding,
    required double cardWidth,
    required double cardHeight,
    required _NetworkGraphPayload payload,
    required List<_NetworkGraphNode> nodes,
    required Set<_NetworkGraphLane> collapsedLanes,
  }) {
    final availableWidth = max(1.0, canvasWidth - laneRailWidth);
    final maxLaneCount = payload.lanes.fold<int>(0, (count, lane) {
      final laneCount = nodes.where((node) => node.lane == lane).length;
      return max(count, laneCount);
    });
    final preferredGap = cardWidth <= 180 ? 44.0 : 72.0;
    final preferredRowWidth =
        (maxLaneCount.toDouble() * cardWidth) +
        (max(0, maxLaneCount - 1).toDouble() * preferredGap) +
        (horizontalPadding * 2);
    final contentWidth = max(availableWidth, preferredRowWidth);
    final positions = <String, Rect>{};
    final laneTops = <_NetworkGraphLane, double>{};
    var top = topPadding;
    _NetworkGraphLane? previousLane;

    for (final lane in payload.lanes) {
      final laneNodes = nodes.where((node) => node.lane == lane).toList();
      if (previousLane != null) {
        final previousCollapsed = collapsedLanes.contains(previousLane);
        top += laneSpacing * (previousCollapsed ? 0.78 : 1.0);
      }
      laneTops[lane] = top;

      if (laneNodes.isNotEmpty) {
        final usableWidth = contentWidth - (horizontalPadding * 2);
        final totalCardWidth = laneNodes.length * cardWidth;
        final gap = laneNodes.length == 1
            ? 0.0
            : max(
                18.0,
                (usableWidth - totalCardWidth) / (laneNodes.length - 1),
              );
        final occupiedWidth =
            totalCardWidth + (gap * max(0, laneNodes.length - 1));
        final startX =
            horizontalPadding + max(0.0, (usableWidth - occupiedWidth) / 2);

        for (var index = 0; index < laneNodes.length; index++) {
          final node = laneNodes[index];
          final x = startX + (index * (cardWidth + gap));
          positions[node.publicId] = Rect.fromLTWH(
            x,
            top,
            cardWidth,
            cardHeight,
          );
        }
      }

      previousLane = lane;
    }

    final canvasHeight =
        (laneTops.values.isEmpty ? topPadding : laneTops.values.reduce(max)) +
        cardHeight +
        72;

    return _RelationalCanvasLayout(
      laneRailWidth: laneRailWidth,
      contentWidth: contentWidth,
      canvasHeight: canvasHeight,
      cardWidth: cardWidth,
      cardHeight: cardHeight,
      positions: positions,
      laneTops: laneTops,
    );
  }
}

class _RelationalNetworkHeader extends StatelessWidget {
  const _RelationalNetworkHeader({
    required this.searchController,
    required this.zoom,
    required this.periodPresets,
    required this.selectedPeriodPreset,
    required this.showFilters,
    required this.sourceLabel,
    required this.isLive,
    required this.isLoading,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onZoomOut,
    required this.onZoomIn,
    required this.onResetViewport,
    required this.onPeriodChanged,
    required this.onRefresh,
    required this.onToggleFilters,
  });

  final TextEditingController searchController;
  final double zoom;
  final List<String> periodPresets;
  final String selectedPeriodPreset;
  final bool showFilters;
  final String sourceLabel;
  final bool isLive;
  final bool isLoading;
  final VoidCallback onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onZoomOut;
  final VoidCallback onZoomIn;
  final VoidCallback onResetViewport;
  final ValueChanged<String> onPeriodChanged;
  final VoidCallback onRefresh;
  final VoidCallback onToggleFilters;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 1120;
        final titleBlock = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _RelationalNetworkMark(),
            const SizedBox(width: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Network',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 24,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Mapa relacional e analise operacional',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _mutedColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        final search = _ContextSearchField(
          controller: searchController,
          hintText: 'Buscar ou use cargo:, departamento:, status:, tipo:',
          accent: _tealColor,
          enabled: !isLoading,
          maxWidth: double.infinity,
          onChanged: (_) => onSearchChanged(),
          onSubmitted: (_) => onSearchChanged(),
          onClear: onClearSearch,
          onSearch: onSearchChanged,
        );

        final controls = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const _RelationalInlineLegend(),
              Container(
                width: 1,
                height: 30,
                margin: const EdgeInsets.symmetric(horizontal: 14),
                color: _lineColor,
              ),
              _RelationalControlCard(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: isLoading ? null : onRefresh,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    child: Row(
                      children: [
                        if (isLoading)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          )
                        else
                          Icon(
                            isLive
                                ? Icons.cloud_done_outlined
                                : Icons.storage_outlined,
                            color: isLive ? _tealColor : _slateColor,
                            size: 22,
                          ),
                        const SizedBox(width: 10),
                        Text(
                          sourceLabel,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: isLive ? _tealColor : _mutedColor,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _RelationalControlCard(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _RelationalIconButton(
                      icon: Icons.remove_rounded,
                      onTap: onZoomOut,
                    ),
                    SizedBox(
                      width: 72,
                      child: Center(
                        child: Text(
                          '${(zoom * 100).round()}%',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(color: _mutedColor),
                        ),
                      ),
                    ),
                    _RelationalIconButton(
                      icon: Icons.add_rounded,
                      onTap: onZoomIn,
                    ),
                    Container(width: 1, height: 40, color: _lineColor),
                    _RelationalIconButton(
                      icon: Icons.fit_screen_outlined,
                      onTap: onResetViewport,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Periodo',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: _mutedColor),
              ),
              const SizedBox(width: 10),
              _RelationalControlCard(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final preset in periodPresets)
                      _RelationalPeriodChip(
                        label: preset,
                        selected: preset == selectedPeriodPreset,
                        onTap: () => onPeriodChanged(preset),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _RelationalControlCard(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: onToggleFilters,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 15,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          showFilters
                              ? Icons.filter_alt_rounded
                              : Icons.filter_alt_outlined,
                          color: _inkColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Filtros',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

        return Container(
          height: compact ? 132 : 84,
          padding: EdgeInsets.symmetric(horizontal: compact ? 18 : 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE9E6DF))),
          ),
          child: compact
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        titleBlock,
                        const SizedBox(width: 16),
                        Expanded(child: search),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(alignment: Alignment.centerLeft, child: controls),
                  ],
                )
              : Row(
                  children: [
                    titleBlock,
                    Container(
                      width: 1,
                      height: 42,
                      margin: const EdgeInsets.symmetric(horizontal: 18),
                      color: _lineColor,
                    ),
                    Expanded(flex: 4, child: search),
                    const SizedBox(width: 18),
                    Expanded(
                      flex: 5,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: controls,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _RelationalInsightData {
  const _RelationalInsightData({
    required this.totalNodes,
    required this.visibleNodes,
    required this.visibleEdges,
    required this.attentionCount,
    required this.rootCompanies,
    required this.clientCompanies,
    required this.contractStatuses,
    required this.employeeStatuses,
    required this.departments,
    required this.positions,
  });

  factory _RelationalInsightData.fromPayload({
    required _NetworkGraphPayload payload,
    required _RelationalNetworkView view,
  }) {
    final departmentCounts = <String, int>{};
    final positionCounts = <String, int>{};
    final rootCounts = <String, int>{};
    final clientCounts = <String, int>{};

    for (final node in payload.nodes) {
      if (node.lane == _NetworkGraphLane.rootCompany) {
        rootCounts[node.publicId] = _expandedNetworkContextIds(
          seedIds: {node.publicId},
          edges: payload.edges,
          maxDepth: 4,
        ).length;
      }
      if (node.lane == _NetworkGraphLane.clientCompany) {
        clientCounts[node.publicId] = _expandedNetworkContextIds(
          seedIds: {node.publicId},
          edges: payload.edges,
          maxDepth: 3,
        ).length;
      }
      if (node.lane != _NetworkGraphLane.employee &&
          node.lane != _NetworkGraphLane.position) {
        continue;
      }
      if (_nodeDepartment(node) case final department?
          when department.trim().isNotEmpty) {
        departmentCounts[department] = (departmentCounts[department] ?? 0) + 1;
      }
      if (_nodePosition(node) case final position?
          when position.trim().isNotEmpty) {
        positionCounts[position] = (positionCounts[position] ?? 0) + 1;
      }
    }

    return _RelationalInsightData(
      totalNodes: payload.nodes.length,
      visibleNodes: view.nodes.length,
      visibleEdges: view.edges.length,
      attentionCount: payload.nodes.where(_nodeNeedsAttention).length,
      rootCompanies: [
        for (final option in payload.filters.available.rootCompanies)
          _NetworkCompanyFacet(
            value: _NetworkCompanyFacetValue.root(option.publicId),
            label: option.label,
            count: rootCounts[option.publicId] ?? 0,
          ),
      ],
      clientCompanies: [
        for (final option in payload.filters.available.clientCompanies)
          _NetworkCompanyFacet(
            value: _NetworkCompanyFacetValue.client(option.publicId),
            label: option.label,
            count: clientCounts[option.publicId] ?? 0,
          ),
      ],
      contractStatuses: payload.filters.available.contractStatuses,
      employeeStatuses: payload.filters.available.employeeStatuses,
      departments: _networkFacetOptions(departmentCounts),
      positions: _networkFacetOptions(positionCounts),
    );
  }

  final int totalNodes;
  final int visibleNodes;
  final int visibleEdges;
  final int attentionCount;
  final List<_NetworkCompanyFacet> rootCompanies;
  final List<_NetworkCompanyFacet> clientCompanies;
  final List<String> contractStatuses;
  final List<String> employeeStatuses;
  final List<_NetworkFacetOption> departments;
  final List<_NetworkFacetOption> positions;

  String labelForCompany(_NetworkCompanyFacetValue value) {
    final options = value.type == _NetworkCompanyFacetType.root
        ? rootCompanies
        : clientCompanies;
    for (final option in options) {
      if (option.value == value) {
        return option.label;
      }
    }
    return value.publicId;
  }
}

class _NetworkFacetOption {
  const _NetworkFacetOption({
    required this.value,
    required this.label,
    required this.count,
  });

  final String value;
  final String label;
  final int count;
}

class _NetworkCompanyFacet {
  const _NetworkCompanyFacet({
    required this.value,
    required this.label,
    required this.count,
  });

  final _NetworkCompanyFacetValue value;
  final String label;
  final int count;
}

enum _NetworkCompanyFacetType { root, client }

class _NetworkCompanyFacetValue {
  const _NetworkCompanyFacetValue._(this.type, this.publicId);

  factory _NetworkCompanyFacetValue.root(String publicId) =>
      _NetworkCompanyFacetValue._(_NetworkCompanyFacetType.root, publicId);

  factory _NetworkCompanyFacetValue.client(String publicId) =>
      _NetworkCompanyFacetValue._(_NetworkCompanyFacetType.client, publicId);

  final _NetworkCompanyFacetType type;
  final String publicId;

  @override
  bool operator ==(Object other) {
    return other is _NetworkCompanyFacetValue &&
        other.type == type &&
        other.publicId == publicId;
  }

  @override
  int get hashCode => Object.hash(type, publicId);
}

enum _NetworkStatusFacetType { contract, employee }

class _NetworkStatusFacetValue {
  const _NetworkStatusFacetValue._(this.type, this.status);

  factory _NetworkStatusFacetValue.contract(String status) =>
      _NetworkStatusFacetValue._(_NetworkStatusFacetType.contract, status);

  factory _NetworkStatusFacetValue.employee(String status) =>
      _NetworkStatusFacetValue._(_NetworkStatusFacetType.employee, status);

  final _NetworkStatusFacetType type;
  final String status;

  @override
  bool operator ==(Object other) {
    return other is _NetworkStatusFacetValue &&
        other.type == type &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(type, status);
}

class _NetworkManagementMenuBar extends StatelessWidget {
  const _NetworkManagementMenuBar({required this.onOpenReport});

  final ValueChanged<_NetworkManagementReportDefinition> onOpenReport;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: const BoxDecoration(
        color: Color(0xFFF6F8FA),
        border: Border(
          top: BorderSide(color: _lineColor),
          bottom: BorderSide(color: _lineColor),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _NetworkManagementMenuButton(
              label: 'Network',
              sections: const [
                _NetworkManagementMenuSection(
                  label: 'Visao',
                  reports: [
                    _NetworkManagementReportDefinition(
                      _NetworkManagementReportType.networkSummary,
                    ),
                  ],
                ),
              ],
              onOpenReport: onOpenReport,
            ),
            _NetworkManagementMenuButton(
              label: 'Consultas',
              sections: const [
                _NetworkManagementMenuSection(
                  label: 'Consulta operacional',
                  reports: [
                    _NetworkManagementReportDefinition(
                      _NetworkManagementReportType.companyQuery,
                    ),
                    _NetworkManagementReportDefinition(
                      _NetworkManagementReportType.hirePeriodQuery,
                    ),
                  ],
                ),
              ],
              onOpenReport: onOpenReport,
            ),
            _NetworkManagementMenuButton(
              label: 'Relatorios',
              sections: const [
                _NetworkManagementMenuSection(
                  label: 'Funcionarios',
                  reports: [
                    _NetworkManagementReportDefinition(
                      _NetworkManagementReportType.activeEmployees,
                    ),
                    _NetworkManagementReportDefinition(
                      _NetworkManagementReportType.admissionProcess,
                    ),
                    _NetworkManagementReportDefinition(
                      _NetworkManagementReportType.hiredByPeriod,
                    ),
                    _NetworkManagementReportDefinition(
                      _NetworkManagementReportType.historicalEmployees,
                    ),
                  ],
                ),
                _NetworkManagementMenuSection(
                  label: 'Contratos',
                  reports: [
                    _NetworkManagementReportDefinition(
                      _NetworkManagementReportType.contractsAndPositions,
                    ),
                  ],
                ),
                _NetworkManagementMenuSection(
                  label: 'Atencao e compliance',
                  reports: [
                    _NetworkManagementReportDefinition(
                      _NetworkManagementReportType.attentionAndCompliance,
                    ),
                  ],
                ),
              ],
              onOpenReport: onOpenReport,
            ),
            _NetworkManagementMenuButton(
              label: 'Graficos',
              sections: const [
                _NetworkManagementMenuSection(
                  label: 'Distribuicoes',
                  reports: [
                    _NetworkManagementReportDefinition(
                      _NetworkManagementReportType.distributionByPosition,
                    ),
                    _NetworkManagementReportDefinition(
                      _NetworkManagementReportType.distributionByDepartment,
                    ),
                    _NetworkManagementReportDefinition(
                      _NetworkManagementReportType.distributionByStatus,
                    ),
                  ],
                ),
              ],
              onOpenReport: onOpenReport,
            ),
            _NetworkManagementMenuButton(
              label: 'Auditoria',
              sections: const [
                _NetworkManagementMenuSection(
                  label: 'Controles',
                  reports: [
                    _NetworkManagementReportDefinition(
                      _NetworkManagementReportType.attentionAndCompliance,
                    ),
                    _NetworkManagementReportDefinition(
                      _NetworkManagementReportType.networkSummary,
                    ),
                  ],
                ),
              ],
              onOpenReport: onOpenReport,
            ),
          ],
        ),
      ),
    );
  }
}

class _NetworkManagementMenuSection {
  const _NetworkManagementMenuSection({
    required this.label,
    required this.reports,
  });

  final String label;
  final List<_NetworkManagementReportDefinition> reports;
}

class _NetworkManagementMenuButton extends StatelessWidget {
  const _NetworkManagementMenuButton({
    required this.label,
    required this.sections,
    required this.onOpenReport,
  });

  final String label;
  final List<_NetworkManagementMenuSection> sections;
  final ValueChanged<_NetworkManagementReportDefinition> onOpenReport;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_NetworkManagementReportDefinition>(
      tooltip: label,
      offset: const Offset(0, 30),
      onSelected: onOpenReport,
      itemBuilder: _buildItems,
      child: _NetworkClassicMenuLabel(label: label),
    );
  }

  List<PopupMenuEntry<_NetworkManagementReportDefinition>> _buildItems(
    BuildContext context,
  ) {
    final entries = <PopupMenuEntry<_NetworkManagementReportDefinition>>[];
    for (var index = 0; index < sections.length; index++) {
      final section = sections[index];
      if (index > 0) {
        entries.add(const PopupMenuDivider());
      }
      entries.add(
        PopupMenuItem<_NetworkManagementReportDefinition>(
          enabled: false,
          height: 30,
          child: Text(
            section.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: _mutedColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
      for (final report in section.reports) {
        entries.add(
          PopupMenuItem<_NetworkManagementReportDefinition>(
            value: report,
            child: Row(
              children: [
                Icon(report.icon, color: _slateColor, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(report.menuLabel)),
              ],
            ),
          ),
        );
      }
    }
    return entries;
  }
}

class _NetworkClassicMenuLabel extends StatelessWidget {
  const _NetworkClassicMenuLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: _inkColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _NetworkReportFacetData {
  const _NetworkReportFacetData({
    required this.rootCompanies,
    required this.clientCompanies,
    required this.departments,
    required this.positions,
  });

  factory _NetworkReportFacetData.fromPayload(_NetworkGraphPayload payload) {
    final departmentCounts = <String, int>{};
    final positionCounts = <String, int>{};
    final rootCounts = <String, int>{};
    final clientCounts = <String, int>{};

    for (final node in payload.nodes) {
      if (node.lane == _NetworkGraphLane.rootCompany) {
        rootCounts[node.publicId] = _expandedNetworkContextIds(
          seedIds: {node.publicId},
          edges: payload.edges,
          maxDepth: 4,
        ).length;
      }
      if (node.lane == _NetworkGraphLane.clientCompany) {
        clientCounts[node.publicId] = _expandedNetworkContextIds(
          seedIds: {node.publicId},
          edges: payload.edges,
          maxDepth: 3,
        ).length;
      }
      if (_nodeDepartment(node) case final department?
          when department.trim().isNotEmpty) {
        departmentCounts[department] = (departmentCounts[department] ?? 0) + 1;
      }
      if (_nodePosition(node) case final position?
          when position.trim().isNotEmpty) {
        positionCounts[position] = (positionCounts[position] ?? 0) + 1;
      }
    }

    return _NetworkReportFacetData(
      rootCompanies: [
        for (final option in payload.filters.available.rootCompanies)
          _NetworkCompanyFacet(
            value: _NetworkCompanyFacetValue.root(option.publicId),
            label: option.label,
            count: rootCounts[option.publicId] ?? 0,
          ),
      ],
      clientCompanies: [
        for (final option in payload.filters.available.clientCompanies)
          _NetworkCompanyFacet(
            value: _NetworkCompanyFacetValue.client(option.publicId),
            label: option.label,
            count: clientCounts[option.publicId] ?? 0,
          ),
      ],
      departments: _networkFacetOptions(departmentCounts),
      positions: _networkFacetOptions(positionCounts),
    );
  }

  final List<_NetworkCompanyFacet> rootCompanies;
  final List<_NetworkCompanyFacet> clientCompanies;
  final List<_NetworkFacetOption> departments;
  final List<_NetworkFacetOption> positions;

  String labelForCompany(_NetworkCompanyFacetValue value) {
    final options = value.type == _NetworkCompanyFacetType.root
        ? rootCompanies
        : clientCompanies;
    for (final option in options) {
      if (option.value == value) {
        return option.label;
      }
    }
    return value.publicId;
  }
}

class _NetworkManagementReportDialog extends StatefulWidget {
  const _NetworkManagementReportDialog({
    required this.payload,
    required this.definition,
  });

  final _NetworkGraphPayload payload;
  final _NetworkManagementReportDefinition definition;

  @override
  State<_NetworkManagementReportDialog> createState() =>
      _NetworkManagementReportDialogState();
}

class _NetworkManagementReportDialogState
    extends State<_NetworkManagementReportDialog> {
  late final _NetworkReportFacetData _facetData;
  late Set<String> _selectedRootIds;
  late Set<String> _selectedClientIds;
  late Set<String> _employeeStatuses;
  late Set<String> _contractStatuses;
  late Set<String> _departments;
  late Set<String> _positions;
  _NetworkTenurePreset? _selectedTenurePreset;
  RangeValues? _customTenureYears;
  _NetworkHireDateRange? _hireDateRange;
  bool _attentionOnly = false;

  @override
  void initState() {
    super.initState();
    _facetData = _NetworkReportFacetData.fromPayload(widget.payload);
    _resetLocalFilters();
  }

  void _resetLocalFilters() {
    _selectedRootIds = {};
    _selectedClientIds = {};
    _employeeStatuses = {...widget.payload.filters.available.employeeStatuses};
    _contractStatuses = {...widget.payload.filters.available.contractStatuses};
    _departments = {};
    _positions = {};
    _selectedTenurePreset = null;
    _customTenureYears = null;
    _hireDateRange = switch (widget.definition.type) {
      _NetworkManagementReportType.hiredByPeriod ||
      _NetworkManagementReportType.hirePeriodQuery =>
        _NetworkHireDateRange.preset('last12m'),
      _ => null,
    };
    _attentionOnly = false;
  }

  Future<void> _openCustomTenureDialog() async {
    final initial = _customTenureYears ?? const RangeValues(0, 10);
    final range = await showDialog<RangeValues>(
      context: context,
      builder: (context) => _NetworkTenureRangeDialog(initialRange: initial),
    );
    if (range == null || !mounted) {
      return;
    }
    setState(() {
      _customTenureYears = range;
      _selectedTenurePreset = null;
    });
  }

  Future<void> _openHireDateRangeDialog() async {
    final range = await showDialog<_NetworkHireDateRange>(
      context: context,
      builder: (context) =>
          _NetworkHireDateRangeDialog(initialRange: _hireDateRange),
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _hireDateRange = range;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final results = _reportNodes();
    final chartGroups = widget.definition.chart
        ? _chartGroupsFor(results)
        : const <String, int>{};

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(24, 22, 18, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      title: Row(
        children: [
          Icon(widget.definition.icon, color: _tealColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.definition.title),
                const SizedBox(height: 4),
                Text(
                  widget.definition.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _mutedColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Fechar',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
      content: SizedBox(
        width: min(size.width * 0.86, 940),
        height: min(size.height * 0.78, 700),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterBar(),
            const SizedBox(height: 14),
            _NetworkReportResultSummary(
              count: results.length,
              label: widget.definition.chart ? 'grupos calculados' : 'itens',
              secondary: widget.definition.chart
                  ? '${chartGroups.length} categorias'
                  : 'preview local',
            ),
            const SizedBox(height: 12),
            Expanded(
              child: widget.definition.chart
                  ? _NetworkReportChartView(groups: chartGroups)
                  : _NetworkReportTable(nodes: results),
            ),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            setState(_resetLocalFilters);
          },
          icon: const Icon(Icons.restart_alt_rounded, size: 18),
          label: const Text('Restaurar filtros'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.check_rounded, size: 18),
          label: const Text('Concluir'),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _lineColor),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _companyFilterButton(),
          _statusFilterButton(),
          _facetFilterButton(
            icon: Icons.apartment_outlined,
            label: 'Departamento',
            options: _facetData.departments,
            selectedValues: _departments,
          ),
          _facetFilterButton(
            icon: Icons.work_outline_rounded,
            label: 'Cargo',
            options: _facetData.positions,
            selectedValues: _positions,
          ),
          _timeFilterButton(),
          _RelationalFacetToggle(
            icon: Icons.warning_amber_rounded,
            label: 'Atencao',
            selected: _attentionOnly,
            onTap: () {
              setState(() {
                _attentionOnly = !_attentionOnly;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _companyFilterButton() {
    final selectedCount = _selectedRootIds.length + _selectedClientIds.length;
    return PopupMenuButton<String>(
      tooltip: 'Empresas',
      onSelected: (value) {
        final separator = value.indexOf(':');
        if (separator < 0) {
          return;
        }
        final type = value.substring(0, separator);
        final publicId = value.substring(separator + 1);
        setState(() {
          if (type == 'root') {
            _toggleInSet(_selectedRootIds, publicId);
          } else {
            _toggleInSet(_selectedClientIds, publicId);
          }
        });
      },
      itemBuilder: (context) => [
        const PopupMenuItem<String>(enabled: false, child: Text('Grupos')),
        for (final option in _facetData.rootCompanies.take(10))
          _reportCompanyMenuItem(
            value: 'root:${option.value.publicId}',
            label: option.label,
            count: option.count,
            selected: _selectedRootIds.contains(option.value.publicId),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(enabled: false, child: Text('Clientes')),
        for (final option in _facetData.clientCompanies.take(14))
          _reportCompanyMenuItem(
            value: 'client:${option.value.publicId}',
            label: option.label,
            count: option.count,
            selected: _selectedClientIds.contains(option.value.publicId),
          ),
      ],
      child: _RelationalMenuPill(
        icon: Icons.business_outlined,
        label: selectedCount == 0 ? 'Empresas' : 'Empresas ($selectedCount)',
        selected: selectedCount > 0,
      ),
    );
  }

  PopupMenuItem<String> _reportCompanyMenuItem({
    required String value,
    required String label,
    required int count,
    required bool selected,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            selected ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: selected ? _tealColor : _mutedColor,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          Text('$count'),
        ],
      ),
    );
  }

  Widget _statusFilterButton() {
    final contractStatuses = widget.payload.filters.available.contractStatuses;
    final employeeStatuses = widget.payload.filters.available.employeeStatuses;
    final changed =
        !_allStatusesSelected(contractStatuses, _contractStatuses) ||
        !_allStatusesSelected(employeeStatuses, _employeeStatuses);
    return PopupMenuButton<String>(
      tooltip: 'Status',
      onSelected: (value) {
        final separator = value.indexOf(':');
        if (separator < 0) {
          return;
        }
        final type = value.substring(0, separator);
        final status = value.substring(separator + 1);
        setState(() {
          if (type == 'employee') {
            _toggleInSet(_employeeStatuses, status);
          } else {
            _toggleInSet(_contractStatuses, status);
          }
        });
      },
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          enabled: false,
          child: Text('Colaboradores'),
        ),
        for (final status in employeeStatuses)
          _reportStatusMenuItem(
            value: 'employee:$status',
            label: _titleCase(status),
            selected: _employeeStatuses.contains(status),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(enabled: false, child: Text('Contratos')),
        for (final status in contractStatuses)
          _reportStatusMenuItem(
            value: 'contract:$status',
            label: _titleCase(status),
            selected: _contractStatuses.contains(status),
          ),
      ],
      child: _RelationalMenuPill(
        icon: Icons.rule_rounded,
        label: 'Status',
        selected: changed,
      ),
    );
  }

  PopupMenuItem<String> _reportStatusMenuItem({
    required String value,
    required String label,
    required bool selected,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            selected ? Icons.check_circle_rounded : Icons.block_rounded,
            color: selected ? _tealColor : _roseColor,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }

  Widget _facetFilterButton({
    required IconData icon,
    required String label,
    required List<_NetworkFacetOption> options,
    required Set<String> selectedValues,
  }) {
    return PopupMenuButton<String>(
      tooltip: label,
      enabled: options.isNotEmpty,
      onSelected: (value) {
        setState(() {
          _toggleInSet(selectedValues, value);
        });
      },
      itemBuilder: (context) {
        if (options.isEmpty) {
          return const [
            PopupMenuItem<String>(
              enabled: false,
              child: Text('Sem opcoes disponiveis'),
            ),
          ];
        }
        return [
          for (final option in options.take(18))
            PopupMenuItem<String>(
              value: option.value,
              child: Row(
                children: [
                  Icon(
                    selectedValues.contains(option.value)
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    color: selectedValues.contains(option.value)
                        ? _tealColor
                        : _mutedColor,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(option.label)),
                  const SizedBox(width: 12),
                  Text('${option.count}'),
                ],
              ),
            ),
        ];
      },
      child: _RelationalMenuPill(
        icon: icon,
        label: selectedValues.isEmpty
            ? label
            : '$label (${selectedValues.length})',
        selected: selectedValues.isNotEmpty,
      ),
    );
  }

  Widget _timeFilterButton() {
    final selected =
        _selectedTenurePreset != null ||
        _customTenureYears != null ||
        _hireDateRange != null;
    return PopupMenuButton<String>(
      tooltip: 'Tempo e admissao',
      onSelected: (value) {
        if (value == 'clear') {
          setState(() {
            _selectedTenurePreset = null;
            _customTenureYears = null;
            _hireDateRange = null;
          });
          return;
        }
        if (value == 'custom_tenure') {
          _openCustomTenureDialog();
          return;
        }
        if (value == 'custom_hire') {
          _openHireDateRangeDialog();
          return;
        }
        if (value.startsWith('hire:')) {
          setState(() {
            _hireDateRange = _NetworkHireDateRange.preset(value.substring(5));
          });
          return;
        }
        for (final preset in _NetworkTenurePreset.values) {
          if (value == preset.name) {
            setState(() {
              _selectedTenurePreset = preset;
              _customTenureYears = null;
            });
            return;
          }
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          enabled: false,
          child: Text('Tempo de servico'),
        ),
        for (final preset in _NetworkTenurePreset.values)
          PopupMenuItem<String>(value: preset.name, child: Text(preset.label)),
        const PopupMenuItem<String>(
          value: 'custom_tenure',
          child: Text('Definir anos exatos...'),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(enabled: false, child: Text('Admissao')),
        const PopupMenuItem<String>(
          value: 'hire:last6m',
          child: Text('Contratados nos ultimos 6 meses'),
        ),
        const PopupMenuItem<String>(
          value: 'hire:last12m',
          child: Text('Contratados nos ultimos 12 meses'),
        ),
        const PopupMenuItem<String>(
          value: 'hire:thisYear',
          child: Text('Contratados neste ano'),
        ),
        const PopupMenuItem<String>(
          value: 'custom_hire',
          child: Text('Contratado entre datas...'),
        ),
        if (selected) const PopupMenuDivider(),
        if (selected)
          const PopupMenuItem<String>(
            value: 'clear',
            child: Text('Limpar tempo/admissao'),
          ),
      ],
      child: _RelationalMenuPill(
        icon: Icons.timelapse_outlined,
        label: 'Tempo',
        selected: selected,
      ),
    );
  }

  List<_NetworkGraphNode> _reportNodes() {
    final scopeIds = _companyScopeIds();
    final nodes = [
      for (final node in widget.payload.nodes)
        if (_matchesReportBase(node) &&
            _matchesCompanyScope(node, scopeIds) &&
            _matchesStatusScope(node) &&
            _matchesFacetScope(node) &&
            _matchesTimeScope(node) &&
            (!_attentionOnly || _nodeNeedsAttention(node)))
          node,
    ];
    nodes.sort(_compareReportNodes);
    return nodes;
  }

  Set<String>? _companyScopeIds() {
    if (_selectedRootIds.isEmpty && _selectedClientIds.isEmpty) {
      return null;
    }
    final ids = <String>{};
    for (final rootId in _selectedRootIds) {
      ids.addAll(
        _expandedNetworkContextIds(
          seedIds: {rootId},
          edges: widget.payload.edges,
          maxDepth: 4,
        ),
      );
    }
    for (final clientId in _selectedClientIds) {
      ids.addAll(
        _expandedNetworkContextIds(
          seedIds: {clientId},
          edges: widget.payload.edges,
          maxDepth: 3,
        ),
      );
    }
    return ids;
  }

  bool _matchesCompanyScope(_NetworkGraphNode node, Set<String>? scopeIds) {
    return scopeIds == null || scopeIds.contains(node.publicId);
  }

  bool _matchesReportBase(_NetworkGraphNode node) {
    return switch (widget.definition.type) {
      _NetworkManagementReportType.networkSummary => true,
      _NetworkManagementReportType.activeEmployees =>
        node.lane == _NetworkGraphLane.employee && _isActiveStatus(node.status),
      _NetworkManagementReportType.admissionProcess =>
        node.lane == _NetworkGraphLane.employee &&
            (_nodeHasAdmissionSignal(node) ||
                _facetValueMatches(node.status, 'admissional')),
      _NetworkManagementReportType.hiredByPeriod =>
        node.lane == _NetworkGraphLane.employee && _nodeStartDate(node) != null,
      _NetworkManagementReportType.historicalEmployees =>
        node.lane == _NetworkGraphLane.employee &&
            !_isActiveStatus(node.status),
      _NetworkManagementReportType.contractsAndPositions =>
        node.lane == _NetworkGraphLane.contract ||
            node.lane == _NetworkGraphLane.position,
      _NetworkManagementReportType.attentionAndCompliance =>
        _nodeNeedsAttention(node),
      _NetworkManagementReportType.distributionByPosition =>
        node.lane == _NetworkGraphLane.employee,
      _NetworkManagementReportType.distributionByDepartment =>
        node.lane == _NetworkGraphLane.employee ||
            node.lane == _NetworkGraphLane.position,
      _NetworkManagementReportType.distributionByStatus =>
        node.lane == _NetworkGraphLane.employee ||
            node.lane == _NetworkGraphLane.contract ||
            node.lane == _NetworkGraphLane.position,
      _NetworkManagementReportType.companyQuery => true,
      _NetworkManagementReportType.hirePeriodQuery =>
        node.lane == _NetworkGraphLane.employee && _nodeStartDate(node) != null,
    };
  }

  bool _matchesStatusScope(_NetworkGraphNode node) {
    if (node.lane == _NetworkGraphLane.employee) {
      final available = widget.payload.filters.available.employeeStatuses;
      if (available.isEmpty) {
        return true;
      }
      return _employeeStatuses.contains(node.status);
    }
    if (node.lane == _NetworkGraphLane.contract ||
        node.lane == _NetworkGraphLane.position) {
      final available = widget.payload.filters.available.contractStatuses;
      if (available.isEmpty) {
        return true;
      }
      return _contractStatuses.contains(node.status) ||
          (node.detailSnapshot.contractStatus != null &&
              _contractStatuses.contains(node.detailSnapshot.contractStatus));
    }
    return true;
  }

  bool _matchesFacetScope(_NetworkGraphNode node) {
    if (_departments.isNotEmpty &&
        !_departments.any(
          (department) => _facetValueMatches(_nodeDepartment(node), department),
        )) {
      return false;
    }
    if (_positions.isNotEmpty &&
        !_positions.any(
          (position) => _facetValueMatches(_nodePosition(node), position),
        )) {
      return false;
    }
    return true;
  }

  bool _matchesTimeScope(_NetworkGraphNode node) {
    if (!_matchesTenureFilters(
      node,
      preset: _selectedTenurePreset,
      customRange: _customTenureYears,
    )) {
      return false;
    }
    if (_hireDateRange != null) {
      return node.lane == _NetworkGraphLane.employee &&
          _hireDateRange!.matches(_nodeStartDate(node));
    }
    return true;
  }

  Map<String, int> _chartGroupsFor(List<_NetworkGraphNode> nodes) {
    final groups = <String, int>{};
    for (final node in nodes) {
      final label = switch (widget.definition.type) {
        _NetworkManagementReportType.networkSummary => _laneLabel(node.lane),
        _NetworkManagementReportType.distributionByPosition =>
          _nodePosition(node) ?? 'Sem cargo',
        _NetworkManagementReportType.distributionByDepartment =>
          _nodeDepartment(node) ?? 'Sem departamento',
        _NetworkManagementReportType.distributionByStatus => _reportStatusLabel(
          node,
        ),
        _ => _laneLabel(node.lane),
      };
      groups[label] = (groups[label] ?? 0) + 1;
    }
    return groups;
  }
}

class _NetworkReportResultSummary extends StatelessWidget {
  const _NetworkReportResultSummary({
    required this.count,
    required this.label,
    required this.secondary,
  });

  final int count;
  final String label;
  final String secondary;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _RelationalMetricPill(
          icon: Icons.summarize_outlined,
          label: '$count $label',
        ),
        _RelationalMetricPill(
          icon: Icons.manage_search_outlined,
          label: secondary,
        ),
      ],
    );
  }
}

class _NetworkReportTable extends StatelessWidget {
  const _NetworkReportTable({required this.nodes});

  final List<_NetworkGraphNode> nodes;

  @override
  Widget build(BuildContext context) {
    final visible = nodes.take(80).toList();
    if (visible.isEmpty) {
      return const _NetworkReportEmptyState();
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _lineColor),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: visible.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: _lineColor),
              itemBuilder: (context, index) =>
                  _NetworkReportTableRow(node: visible[index]),
            ),
          ),
          if (nodes.length > visible.length)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: _lineColor)),
              ),
              child: Text(
                'Mostrando 80 de ${nodes.length} itens.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

class _NetworkReportTableRow extends StatelessWidget {
  const _NetworkReportTableRow({required this.node});

  final _NetworkGraphNode node;

  @override
  Widget build(BuildContext context) {
    final visualIdentity = _visualIdentityForNetworkNode(node);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _EntityMarker(
            identity: visualIdentity,
            size: 38,
            semanticLabel: '${visualIdentity.typeLabel}: ${node.displayName}',
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        node.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _NetworkReportStatusTag(label: _reportStatusLabel(node)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _reportNodeLine(node),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _mutedColor,
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

class _NetworkReportStatusTag extends StatelessWidget {
  const _NetworkReportStatusTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _tealColor.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _tealColor.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: _deepTealColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _NetworkReportChartView extends StatelessWidget {
  const _NetworkReportChartView({required this.groups});

  final Map<String, int> groups;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return const _NetworkReportEmptyState();
    }
    final entries = groups.entries.toList()
      ..sort((left, right) {
        final byCount = right.value.compareTo(left.value);
        if (byCount != 0) {
          return byCount;
        }
        return left.key.toLowerCase().compareTo(right.key.toLowerCase());
      });
    final maxCount = entries.first.value;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _lineColor),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(14),
        itemCount: entries.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final entry = entries[index];
          final factor = maxCount == 0 ? 0.0 : entry.value / maxCount;
          return _NetworkReportChartBar(
            label: entry.key,
            count: entry.value,
            factor: factor,
          );
        },
      ),
    );
  }
}

class _NetworkReportChartBar extends StatelessWidget {
  const _NetworkReportChartBar({
    required this.label,
    required this.count,
    required this.factor,
  });

  final String label;
  final int count;
  final double factor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;
        final labelWidget = SizedBox(
          width: compact ? double.infinity : 210,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _inkColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        );
        final barWidget = Expanded(
          child: Stack(
            children: [
              Container(
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4F6),
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              FractionallySizedBox(
                widthFactor: factor.clamp(0.04, 1.0),
                child: Container(
                  height: 28,
                  decoration: BoxDecoration(
                    color: _tealColor.withValues(alpha: 0.74),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Text(
                      '$count',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: _inkColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              labelWidget,
              const SizedBox(height: 6),
              Row(children: [barWidget]),
            ],
          );
        }

        return Row(
          children: [labelWidget, const SizedBox(width: 14), barWidget],
        );
      },
    );
  }
}

class _NetworkReportEmptyState extends StatelessWidget {
  const _NetworkReportEmptyState();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _lineColor),
      ),
      child: Center(
        child: Text(
          'Nenhum item encontrado para estes filtros.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: _mutedColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

int _compareReportNodes(_NetworkGraphNode left, _NetworkGraphNode right) {
  final byLane = _reportLaneOrder(
    left.lane,
  ).compareTo(_reportLaneOrder(right.lane));
  if (byLane != 0) {
    return byLane;
  }
  return left.displayName.toLowerCase().compareTo(
    right.displayName.toLowerCase(),
  );
}

int _reportLaneOrder(_NetworkGraphLane lane) {
  return switch (lane) {
    _NetworkGraphLane.rootCompany => 0,
    _NetworkGraphLane.clientCompany => 1,
    _NetworkGraphLane.contract => 2,
    _NetworkGraphLane.position => 3,
    _NetworkGraphLane.employee => 4,
  };
}

String _reportStatusLabel(_NetworkGraphNode node) {
  final raw =
      node.detailSnapshot.extras['statusLabel'] ??
      node.detailSnapshot.contractStatus ??
      node.status;
  return _titleCase('$raw');
}

String _reportNodeLine(_NetworkGraphNode node) {
  final parts = <String>[
    _laneLabel(node.lane),
    if (node.subtitle.trim().isNotEmpty) node.subtitle,
    if (_nodeDepartment(node) case final department?) 'Depto. $department',
    if (_nodePosition(node) case final position?) 'Cargo $position',
    if (node.detailSnapshot.extras['clientCompany'] case final company?)
      'Empresa $company',
    if (node.detailSnapshot.extras['startDate'] case final start?)
      'Inicio $start',
    if (_nodeNeedsAttention(node)) _nodeAttentionLabel(node),
  ];
  return parts.join(' | ');
}

class _RelationalInsightBar extends StatelessWidget {
  const _RelationalInsightBar({
    required this.data,
    required this.query,
    required this.selectedRootIds,
    required this.selectedClientIds,
    required this.contractStatuses,
    required this.employeeStatuses,
    required this.selectedDepartments,
    required this.selectedPositions,
    required this.selectedTenurePreset,
    required this.customTenureYears,
    required this.hireDateRange,
    required this.reportPreset,
    required this.attentionOnly,
    required this.clusterEmployees,
    required this.focusedNode,
    required this.onToggleCompany,
    required this.onToggleStatus,
    required this.onToggleDepartment,
    required this.onTogglePosition,
    required this.onTenurePreset,
    required this.onCustomTenure,
    required this.onHireDateRange,
    required this.onCustomHireDateRange,
    required this.onReportPreset,
    required this.onToggleAttention,
    required this.onToggleCluster,
    required this.onClearCompany,
    required this.onClearStatus,
    required this.onClearDepartment,
    required this.onClearPosition,
    required this.onClearSearch,
    required this.onClearFocus,
    required this.onClearAll,
  });

  final _RelationalInsightData data;
  final _NetworkSearchQuery query;
  final Set<String> selectedRootIds;
  final Set<String> selectedClientIds;
  final Set<String> contractStatuses;
  final Set<String> employeeStatuses;
  final Set<String> selectedDepartments;
  final Set<String> selectedPositions;
  final _NetworkTenurePreset? selectedTenurePreset;
  final RangeValues? customTenureYears;
  final _NetworkHireDateRange? hireDateRange;
  final _NetworkReportPreset? reportPreset;
  final bool attentionOnly;
  final bool clusterEmployees;
  final _NetworkGraphNode? focusedNode;
  final ValueChanged<_NetworkCompanyFacetValue> onToggleCompany;
  final ValueChanged<_NetworkStatusFacetValue> onToggleStatus;
  final ValueChanged<String> onToggleDepartment;
  final ValueChanged<String> onTogglePosition;
  final ValueChanged<_NetworkTenurePreset?> onTenurePreset;
  final VoidCallback onCustomTenure;
  final ValueChanged<_NetworkHireDateRange?> onHireDateRange;
  final VoidCallback onCustomHireDateRange;
  final ValueChanged<_NetworkReportPreset?> onReportPreset;
  final VoidCallback onToggleAttention;
  final VoidCallback onToggleCluster;
  final ValueChanged<_NetworkCompanyFacetValue> onClearCompany;
  final ValueChanged<_NetworkStatusFacetValue> onClearStatus;
  final ValueChanged<String> onClearDepartment;
  final ValueChanged<String> onClearPosition;
  final VoidCallback onClearSearch;
  final VoidCallback onClearFocus;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    final active =
        !query.isEmpty ||
        selectedDepartments.isNotEmpty ||
        selectedPositions.isNotEmpty ||
        selectedRootIds.isNotEmpty ||
        selectedClientIds.isNotEmpty ||
        !_allStatusesSelected(data.contractStatuses, contractStatuses) ||
        !_allStatusesSelected(data.employeeStatuses, employeeStatuses) ||
        selectedTenurePreset != null ||
        customTenureYears != null ||
        hireDateRange != null ||
        reportPreset != null ||
        attentionOnly ||
        focusedNode != null;
    final selectedCompanies = {
      for (final id in selectedRootIds) _NetworkCompanyFacetValue.root(id),
      for (final id in selectedClientIds) _NetworkCompanyFacetValue.client(id),
    };
    final selectedStatuses = {
      for (final status in data.contractStatuses)
        if (!contractStatuses.contains(status))
          _NetworkStatusFacetValue.contract(status),
      for (final status in data.employeeStatuses)
        if (!employeeStatuses.contains(status))
          _NetworkStatusFacetValue.employee(status),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _lineColor),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _RelationalMetricPill(
            icon: Icons.account_tree_outlined,
            label: '${data.visibleNodes}/${data.totalNodes} nos',
          ),
          _RelationalMetricPill(
            icon: Icons.route_outlined,
            label: '${data.visibleEdges} relacoes',
          ),
          _RelationalFacetToggle(
            icon: Icons.warning_amber_rounded,
            label: 'Atencao (${data.attentionCount})',
            selected: attentionOnly,
            onTap: onToggleAttention,
          ),
          _RelationalCompanyMenuButton(
            rootCompanies: data.rootCompanies,
            clientCompanies: data.clientCompanies,
            selectedRootIds: selectedRootIds,
            selectedClientIds: selectedClientIds,
            onSelected: onToggleCompany,
          ),
          _RelationalStatusMenuButton(
            contractStatuses: data.contractStatuses,
            employeeStatuses: data.employeeStatuses,
            selectedContractStatuses: contractStatuses,
            selectedEmployeeStatuses: employeeStatuses,
            onSelected: onToggleStatus,
          ),
          _RelationalFacetMenuButton(
            icon: Icons.apartment_outlined,
            label: 'Departamento',
            options: data.departments,
            selectedValues: selectedDepartments,
            onSelected: onToggleDepartment,
          ),
          _RelationalFacetMenuButton(
            icon: Icons.work_outline_rounded,
            label: 'Cargo',
            options: data.positions,
            selectedValues: selectedPositions,
            onSelected: onTogglePosition,
          ),
          _RelationalTenureMenuButton(
            selectedPreset: selectedTenurePreset,
            customRange: customTenureYears,
            hireDateRange: hireDateRange,
            onPreset: onTenurePreset,
            onCustomTenure: onCustomTenure,
            onHireDateRange: onHireDateRange,
            onCustomHireDateRange: onCustomHireDateRange,
          ),
          _RelationalReportMenuButton(
            selectedPreset: reportPreset,
            onSelected: onReportPreset,
          ),
          _RelationalFacetToggle(
            icon: Icons.hub_outlined,
            label: 'Agrupar',
            selected: clusterEmployees,
            onTap: onToggleCluster,
          ),
          if (focusedNode case final node?)
            _RelationalActiveFacetChip(
              label: 'Foco: ${node.displayName}',
              icon: Icons.center_focus_strong_rounded,
              onDeleted: onClearFocus,
            ),
          for (final label in query.activeLabels)
            _RelationalActiveFacetChip(
              label: label,
              icon: Icons.search_rounded,
              onDeleted: onClearSearch,
            ),
          for (final company in selectedCompanies)
            _RelationalActiveFacetChip(
              label:
                  '${company.type == _NetworkCompanyFacetType.root ? 'Grupo' : 'Cliente'}: ${data.labelForCompany(company)}',
              icon: Icons.business_outlined,
              onDeleted: () => onClearCompany(company),
            ),
          for (final status in selectedStatuses)
            _RelationalActiveFacetChip(
              label:
                  '${status.type == _NetworkStatusFacetType.contract ? 'Contrato' : 'Colaborador'} sem ${_titleCase(status.status)}',
              icon: Icons.rule_rounded,
              onDeleted: () => onClearStatus(status),
            ),
          for (final department in selectedDepartments)
            _RelationalActiveFacetChip(
              label: 'Departamento: $department',
              icon: Icons.apartment_outlined,
              onDeleted: () => onClearDepartment(department),
            ),
          for (final position in selectedPositions)
            _RelationalActiveFacetChip(
              label: 'Cargo: $position',
              icon: Icons.work_outline_rounded,
              onDeleted: () => onClearPosition(position),
            ),
          if (selectedTenurePreset != null || customTenureYears != null)
            _RelationalActiveFacetChip(
              label: _tenureFilterLabel(
                selectedTenurePreset,
                customTenureYears,
              ),
              icon: Icons.timelapse_outlined,
              onDeleted: () => onTenurePreset(null),
            ),
          if (hireDateRange != null)
            _RelationalActiveFacetChip(
              label: hireDateRange!.label,
              icon: Icons.event_available_outlined,
              onDeleted: () => onHireDateRange(null),
            ),
          if (reportPreset != null)
            _RelationalActiveFacetChip(
              label: 'Relatorio: ${reportPreset!.label}',
              icon: Icons.summarize_outlined,
              onDeleted: () => onReportPreset(null),
            ),
          if (attentionOnly)
            _RelationalActiveFacetChip(
              label: 'Somente atencao',
              icon: Icons.warning_amber_rounded,
              onDeleted: onToggleAttention,
            ),
          if (active)
            TextButton.icon(
              onPressed: onClearAll,
              icon: const Icon(Icons.close_rounded, size: 18),
              label: const Text('Limpar analise'),
            ),
        ],
      ),
    );
  }
}

class _RelationalMetricPill extends StatelessWidget {
  const _RelationalMetricPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _lineColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _slateColor, size: 17),
          const SizedBox(width: 7),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _mutedColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RelationalFacetToggle extends StatelessWidget {
  const _RelationalFacetToggle({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? _roseColor : _slateColor;
    return Material(
      color: selected ? color.withValues(alpha: 0.12) : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? color.withValues(alpha: 0.55) : _lineColor,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 17),
              const SizedBox(width: 7),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: selected ? color : _inkColor,
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

class _RelationalCompanyMenuButton extends StatelessWidget {
  const _RelationalCompanyMenuButton({
    required this.rootCompanies,
    required this.clientCompanies,
    required this.selectedRootIds,
    required this.selectedClientIds,
    required this.onSelected,
  });

  final List<_NetworkCompanyFacet> rootCompanies;
  final List<_NetworkCompanyFacet> clientCompanies;
  final Set<String> selectedRootIds;
  final Set<String> selectedClientIds;
  final ValueChanged<_NetworkCompanyFacetValue> onSelected;

  @override
  Widget build(BuildContext context) {
    final selectedCount = selectedRootIds.length + selectedClientIds.length;
    return PopupMenuButton<_NetworkCompanyFacetValue>(
      tooltip: 'Empresas',
      onSelected: onSelected,
      itemBuilder: (context) => [
        const PopupMenuItem<_NetworkCompanyFacetValue>(
          enabled: false,
          child: Text('Grupos'),
        ),
        for (final option in rootCompanies.take(8))
          _companyMenuItem(
            option,
            selectedRootIds.contains(option.value.publicId),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem<_NetworkCompanyFacetValue>(
          enabled: false,
          child: Text('Clientes'),
        ),
        for (final option in clientCompanies.take(12))
          _companyMenuItem(
            option,
            selectedClientIds.contains(option.value.publicId),
          ),
      ],
      child: _RelationalMenuPill(
        icon: Icons.business_outlined,
        label: selectedCount == 0 ? 'Empresas' : 'Empresas ($selectedCount)',
        selected: selectedCount > 0,
      ),
    );
  }

  PopupMenuItem<_NetworkCompanyFacetValue> _companyMenuItem(
    _NetworkCompanyFacet option,
    bool selected,
  ) {
    return PopupMenuItem<_NetworkCompanyFacetValue>(
      value: option.value,
      child: Row(
        children: [
          Icon(
            selected ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: selected ? _tealColor : _mutedColor,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(option.label)),
          const SizedBox(width: 12),
          Text('${option.count}'),
        ],
      ),
    );
  }
}

class _RelationalStatusMenuButton extends StatelessWidget {
  const _RelationalStatusMenuButton({
    required this.contractStatuses,
    required this.employeeStatuses,
    required this.selectedContractStatuses,
    required this.selectedEmployeeStatuses,
    required this.onSelected,
  });

  final List<String> contractStatuses;
  final List<String> employeeStatuses;
  final Set<String> selectedContractStatuses;
  final Set<String> selectedEmployeeStatuses;
  final ValueChanged<_NetworkStatusFacetValue> onSelected;

  @override
  Widget build(BuildContext context) {
    final changed =
        !_allStatusesSelected(contractStatuses, selectedContractStatuses) ||
        !_allStatusesSelected(employeeStatuses, selectedEmployeeStatuses);
    return PopupMenuButton<_NetworkStatusFacetValue>(
      tooltip: 'Status',
      onSelected: onSelected,
      itemBuilder: (context) => [
        const PopupMenuItem<_NetworkStatusFacetValue>(
          enabled: false,
          child: Text('Contratos'),
        ),
        for (final status in contractStatuses)
          _statusMenuItem(
            _NetworkStatusFacetValue.contract(status),
            selectedContractStatuses.contains(status),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem<_NetworkStatusFacetValue>(
          enabled: false,
          child: Text('Colaboradores'),
        ),
        for (final status in employeeStatuses)
          _statusMenuItem(
            _NetworkStatusFacetValue.employee(status),
            selectedEmployeeStatuses.contains(status),
          ),
      ],
      child: _RelationalMenuPill(
        icon: Icons.rule_rounded,
        label: 'Status',
        selected: changed,
      ),
    );
  }

  PopupMenuItem<_NetworkStatusFacetValue> _statusMenuItem(
    _NetworkStatusFacetValue value,
    bool selected,
  ) {
    return PopupMenuItem<_NetworkStatusFacetValue>(
      value: value,
      child: Row(
        children: [
          Icon(
            selected ? Icons.check_circle_rounded : Icons.block_rounded,
            color: selected ? _tealColor : _roseColor,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(_titleCase(value.status)),
        ],
      ),
    );
  }
}

class _RelationalTenureMenuButton extends StatelessWidget {
  const _RelationalTenureMenuButton({
    required this.selectedPreset,
    required this.customRange,
    required this.hireDateRange,
    required this.onPreset,
    required this.onCustomTenure,
    required this.onHireDateRange,
    required this.onCustomHireDateRange,
  });

  final _NetworkTenurePreset? selectedPreset;
  final RangeValues? customRange;
  final _NetworkHireDateRange? hireDateRange;
  final ValueChanged<_NetworkTenurePreset?> onPreset;
  final VoidCallback onCustomTenure;
  final ValueChanged<_NetworkHireDateRange?> onHireDateRange;
  final VoidCallback onCustomHireDateRange;

  @override
  Widget build(BuildContext context) {
    final selected =
        selectedPreset != null || customRange != null || hireDateRange != null;
    return PopupMenuButton<String>(
      tooltip: 'Tempo e admissao',
      onSelected: (value) {
        if (value == 'clear') {
          onPreset(null);
          onHireDateRange(null);
          return;
        }
        if (value == 'custom_tenure') {
          onCustomTenure();
          return;
        }
        if (value == 'custom_hire') {
          onCustomHireDateRange();
          return;
        }
        if (value.startsWith('hire:')) {
          onHireDateRange(_NetworkHireDateRange.preset(value.substring(5)));
          return;
        }
        for (final preset in _NetworkTenurePreset.values) {
          if (value == preset.name) {
            onPreset(preset);
            return;
          }
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          enabled: false,
          child: Text('Tempo de servico'),
        ),
        for (final preset in _NetworkTenurePreset.values)
          PopupMenuItem<String>(value: preset.name, child: Text(preset.label)),
        const PopupMenuItem<String>(
          value: 'custom_tenure',
          child: Text('Definir anos exatos...'),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(enabled: false, child: Text('Contratacao')),
        const PopupMenuItem<String>(
          value: 'hire:last6m',
          child: Text('Contratados nos ultimos 6 meses'),
        ),
        const PopupMenuItem<String>(
          value: 'hire:last12m',
          child: Text('Contratados nos ultimos 12 meses'),
        ),
        const PopupMenuItem<String>(
          value: 'hire:thisYear',
          child: Text('Contratados neste ano'),
        ),
        const PopupMenuItem<String>(
          value: 'custom_hire',
          child: Text('Contratado entre datas...'),
        ),
        if (selected) const PopupMenuDivider(),
        if (selected)
          const PopupMenuItem<String>(
            value: 'clear',
            child: Text('Limpar tempo/admissao'),
          ),
      ],
      child: _RelationalMenuPill(
        icon: Icons.timelapse_outlined,
        label: 'Tempo',
        selected: selected,
      ),
    );
  }
}

class _RelationalReportMenuButton extends StatelessWidget {
  const _RelationalReportMenuButton({
    required this.selectedPreset,
    required this.onSelected,
  });

  final _NetworkReportPreset? selectedPreset;
  final ValueChanged<_NetworkReportPreset?> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Relatorios',
      onSelected: (value) {
        if (value == 'clear') {
          onSelected(null);
          return;
        }
        for (final preset in _NetworkReportPreset.values) {
          if (value == preset.name) {
            onSelected(preset);
            return;
          }
        }
      },
      itemBuilder: (context) => [
        for (final preset in _NetworkReportPreset.values)
          PopupMenuItem<String>(
            value: preset.name,
            child: Row(
              children: [
                Icon(preset.icon, color: _slateColor, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(preset.label)),
              ],
            ),
          ),
        if (selectedPreset != null) const PopupMenuDivider(),
        if (selectedPreset != null)
          const PopupMenuItem<String>(
            value: 'clear',
            child: Text('Limpar relatorio'),
          ),
      ],
      child: _RelationalMenuPill(
        icon: Icons.summarize_outlined,
        label: selectedPreset == null ? 'Relatorios' : 'Relatorio ativo',
        selected: selectedPreset != null,
      ),
    );
  }
}

class _RelationalMenuPill extends StatelessWidget {
  const _RelationalMenuPill({
    required this.icon,
    required this.label,
    required this.selected,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? _tealColor : _slateColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? color.withValues(alpha: 0.10) : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selected ? color.withValues(alpha: 0.45) : _lineColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 7),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: selected ? color : _inkColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded, color: color, size: 18),
        ],
      ),
    );
  }
}

class _RelationalFacetMenuButton extends StatelessWidget {
  const _RelationalFacetMenuButton({
    required this.icon,
    required this.label,
    required this.options,
    required this.selectedValues,
    required this.onSelected,
  });

  final IconData icon;
  final String label;
  final List<_NetworkFacetOption> options;
  final Set<String> selectedValues;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = selectedValues.isNotEmpty;
    final color = selected ? _tealColor : _slateColor;
    return PopupMenuButton<String>(
      tooltip: label,
      enabled: options.isNotEmpty,
      onSelected: onSelected,
      itemBuilder: (context) {
        if (options.isEmpty) {
          return [
            const PopupMenuItem<String>(
              enabled: false,
              child: Text('Sem opcoes disponiveis'),
            ),
          ];
        }
        return [
          for (final option in options.take(14))
            PopupMenuItem<String>(
              value: option.value,
              child: Row(
                children: [
                  Icon(
                    selectedValues.contains(option.value)
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    color: selectedValues.contains(option.value)
                        ? _tealColor
                        : _mutedColor,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(option.label)),
                  const SizedBox(width: 12),
                  Text(
                    '${option.count}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _mutedColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
        ];
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.10) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.45) : _lineColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 17),
            const SizedBox(width: 7),
            Text(
              selected ? '$label (${selectedValues.length})' : label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: selected ? color : _inkColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}

class _RelationalActiveFacetChip extends StatelessWidget {
  const _RelationalActiveFacetChip({
    required this.label,
    required this.icon,
    required this.onDeleted,
  });

  final String label;
  final IconData icon;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      avatar: Icon(icon, size: 17, color: _tealColor),
      label: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 260),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      onDeleted: onDeleted,
      deleteIcon: const Icon(Icons.close_rounded, size: 17),
      backgroundColor: _tealColor.withValues(alpha: 0.10),
      side: BorderSide(color: _tealColor.withValues(alpha: 0.26)),
      labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: _deepTealColor,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _RelationalInlineLegend extends StatelessWidget {
  const _RelationalInlineLegend();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        _RelationalInlineLegendItem(color: _tealColor, label: 'Ativa'),
        SizedBox(width: 12),
        _RelationalInlineLegendItem(color: _amberColor, label: 'Historica'),
        SizedBox(width: 12),
        _RelationalInlineLegendItem(
          color: Color(0xFF8C8C92),
          label: 'Indireta',
          dashed: true,
        ),
      ],
    );
  }
}

class _RelationalInlineLegendItem extends StatelessWidget {
  const _RelationalInlineLegendItem({
    required this.color,
    required this.label,
    this.dashed = false,
  });

  final Color color;
  final String label;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 26,
          height: 10,
          child: CustomPaint(
            painter: _RelationalLegendLinePainter(color: color, dashed: dashed),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: _mutedColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _RelationalFocusCrumb extends StatelessWidget {
  const _RelationalFocusCrumb({required this.node, required this.onClear});

  final _NetworkGraphNode node;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final laneColor = _laneColor(node.lane);
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: laneColor.withValues(alpha: 0.32)),
        boxShadow: [
          BoxShadow(
            color: _deepTealColor.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.center_focus_strong_rounded, color: laneColor, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Network > ${node.displayName}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _inkColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            onPressed: onClear,
            tooltip: 'Sair do foco',
            icon: const Icon(Icons.close_rounded, size: 18),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _NetworkTenureRangeDialog extends StatefulWidget {
  const _NetworkTenureRangeDialog({required this.initialRange});

  final RangeValues initialRange;

  @override
  State<_NetworkTenureRangeDialog> createState() =>
      _NetworkTenureRangeDialogState();
}

class _NetworkTenureRangeDialogState extends State<_NetworkTenureRangeDialog> {
  late RangeValues _range;

  @override
  void initState() {
    super.initState();
    _range = widget.initialRange;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tempo de servico'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_range.start.round()} a ${_range.end.round()} anos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            RangeSlider(
              values: _range,
              min: 0,
              max: 20,
              divisions: 20,
              labels: RangeLabels(
                '${_range.start.round()} a',
                '${_range.end.round()} a',
              ),
              onChanged: (value) {
                setState(() {
                  _range = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_range),
          child: const Text('Aplicar'),
        ),
      ],
    );
  }
}

class _NetworkHireDateRangeDialog extends StatefulWidget {
  const _NetworkHireDateRangeDialog({required this.initialRange});

  final _NetworkHireDateRange? initialRange;

  @override
  State<_NetworkHireDateRangeDialog> createState() =>
      _NetworkHireDateRangeDialogState();
}

class _NetworkHireDateRangeDialogState
    extends State<_NetworkHireDateRangeDialog> {
  late final TextEditingController _start;
  late final TextEditingController _end;

  @override
  void initState() {
    super.initState();
    _start = TextEditingController(
      text: _formatNetworkDateInput(widget.initialRange?.start),
    );
    _end = TextEditingController(
      text: _formatNetworkDateInput(widget.initialRange?.end),
    );
  }

  @override
  void dispose() {
    _start.dispose();
    _end.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Contratado entre datas'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _start,
              decoration: const InputDecoration(
                labelText: 'Inicio',
                hintText: '2024-01-01',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _end,
              decoration: const InputDecoration(
                labelText: 'Fim',
                hintText: '2024-12-31',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final start = _parseNetworkDate(_start.text);
            final end = _parseNetworkDate(_end.text);
            if (start == null && end == null) {
              Navigator.of(context).pop();
              return;
            }
            Navigator.of(context).pop(
              _NetworkHireDateRange(
                label:
                    'Contratado entre ${_start.text.trim()} e ${_end.text.trim()}',
                start: start,
                end: end,
              ),
            );
          },
          child: const Text('Aplicar'),
        ),
      ],
    );
  }
}

class _RelationalNetworkMark extends StatelessWidget {
  const _RelationalNetworkMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: CustomPaint(painter: _RelationalNetworkMarkPainter()),
    );
  }
}

class _RelationalNetworkMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _tealColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final points = [
      Offset(size.width * 0.50, size.height * 0.08),
      Offset(size.width * 0.88, size.height * 0.50),
      Offset(size.width * 0.50, size.height * 0.92),
      Offset(size.width * 0.12, size.height * 0.50),
    ];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
    for (final point in points) {
      canvas.drawCircle(point, 5, Paint()..color = Colors.white);
      canvas.drawCircle(point, 5, paint);
    }
    canvas.drawCircle(
      Offset(size.width * 0.50, size.height * 0.50),
      5,
      Paint()..color = _tealColor,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RelationalLegendLinePainter extends CustomPainter {
  const _RelationalLegendLinePainter({
    required this.color,
    required this.dashed,
  });

  final Color color;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    if (!dashed) {
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        paint,
      );
      return;
    }
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(min(x + 8, size.width), size.height / 2),
        paint,
      );
      x += 14;
    }
  }

  @override
  bool shouldRepaint(covariant _RelationalLegendLinePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.dashed != dashed;
  }
}

class _RelationalControlCard extends StatelessWidget {
  const _RelationalControlCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _lineColor),
        boxShadow: [
          BoxShadow(
            color: _deepTealColor.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _RelationalIconButton extends StatelessWidget {
  const _RelationalIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Icon(icon, color: _inkColor, size: 24),
      ),
    );
  }
}

class _RelationalPeriodChip extends StatelessWidget {
  const _RelationalPeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? _tealColor : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: selected ? Colors.white : _inkColor,
          ),
        ),
      ),
    );
  }
}

class _RelationalFilterPanel extends StatelessWidget {
  const _RelationalFilterPanel({
    required this.payload,
    required this.selectedRootIds,
    required this.selectedClientIds,
    required this.contractStatuses,
    required this.employeeStatuses,
    required this.includeHistorical,
    required this.includeIndirect,
    required this.includeTimelineMoves,
    required this.includeTimelineOperationalEvents,
    required this.timelineDateRange,
    required this.onToggleRoot,
    required this.onToggleClient,
    required this.onToggleContractStatus,
    required this.onToggleEmployeeStatus,
    required this.onToggleHistorical,
    required this.onToggleIndirect,
    required this.onToggleTimelineMoves,
    required this.onToggleTimelineOperationalEvents,
    required this.onPickTimelineRange,
    required this.onClearTimelineRange,
    required this.onRestore,
  });

  final _NetworkGraphPayload payload;
  final Set<String> selectedRootIds;
  final Set<String> selectedClientIds;
  final Set<String> contractStatuses;
  final Set<String> employeeStatuses;
  final bool includeHistorical;
  final bool includeIndirect;
  final bool includeTimelineMoves;
  final bool includeTimelineOperationalEvents;
  final DateTimeRange? timelineDateRange;
  final ValueChanged<String> onToggleRoot;
  final ValueChanged<String> onToggleClient;
  final ValueChanged<String> onToggleContractStatus;
  final ValueChanged<String> onToggleEmployeeStatus;
  final ValueChanged<bool> onToggleHistorical;
  final ValueChanged<bool> onToggleIndirect;
  final ValueChanged<bool> onToggleTimelineMoves;
  final ValueChanged<bool> onToggleTimelineOperationalEvents;
  final VoidCallback onPickTimelineRange;
  final VoidCallback onClearTimelineRange;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8F2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _lineColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 12,
            spacing: 12,
            children: [
              Text(
                'Filtros disponiveis',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton.icon(
                onPressed: onRestore,
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Restaurar'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _RelationalFilterGroup(
            title: 'Grupos',
            children: [
              for (final option in payload.filters.available.rootCompanies)
                _RelationalFilterChip(
                  label: option.label,
                  selected: selectedRootIds.contains(option.publicId),
                  onTap: () => onToggleRoot(option.publicId),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _RelationalFilterGroup(
            title: 'Clientes',
            children: [
              for (final option in payload.filters.available.clientCompanies)
                _RelationalFilterChip(
                  label: option.label,
                  selected: selectedClientIds.contains(option.publicId),
                  onTap: () => onToggleClient(option.publicId),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _RelationalFilterGroup(
            title: 'Status de contratos',
            children: [
              for (final option in payload.filters.available.contractStatuses)
                _RelationalFilterChip(
                  label: _titleCase(option),
                  selected: contractStatuses.contains(option),
                  onTap: () => onToggleContractStatus(option),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _RelationalFilterGroup(
            title: 'Status de colaboradores',
            children: [
              for (final option in payload.filters.available.employeeStatuses)
                _RelationalFilterChip(
                  label: _titleCase(option),
                  selected: employeeStatuses.contains(option),
                  onTap: () => onToggleEmployeeStatus(option),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilterChip(
                label: const Text('Mostrar relacoes historicas'),
                selected: includeHistorical,
                onSelected: onToggleHistorical,
              ),
              FilterChip(
                label: const Text('Mostrar relacoes indiretas'),
                selected: includeIndirect,
                onSelected: onToggleIndirect,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _RelationalFilterGroup(
            title: 'Timeline',
            children: [
              FilterChip(
                label: Text(_timelineRangeFilterLabel(timelineDateRange)),
                selected: timelineDateRange != null,
                avatar: const Icon(Icons.date_range_outlined, size: 18),
                onSelected: (_) => onPickTimelineRange(),
              ),
              if (timelineDateRange != null)
                ActionChip(
                  avatar: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Limpar intervalo'),
                  onPressed: onClearTimelineRange,
                ),
              FilterChip(
                label: const Text('Movimentacoes'),
                selected: includeTimelineMoves,
                onSelected: onToggleTimelineMoves,
              ),
              FilterChip(
                label: const Text('Eventos operacionais'),
                selected: includeTimelineOperationalEvents,
                onSelected: onToggleTimelineOperationalEvents,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RelationalFilterGroup extends StatelessWidget {
  const _RelationalFilterGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Wrap(spacing: 10, runSpacing: 10, children: children),
      ],
    );
  }
}

class _RelationalFilterChip extends StatelessWidget {
  const _RelationalFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _RelationalLaneRail extends StatelessWidget {
  const _RelationalLaneRail({
    required this.lanes,
    required this.laneTops,
    required this.cardHeight,
    required this.selectedLane,
    required this.hiddenLanes,
    required this.activeOnlyLanes,
    required this.onSelectLane,
  });

  final List<_NetworkGraphLane> lanes;
  final Map<_NetworkGraphLane, double> laneTops;
  final double cardHeight;
  final _NetworkGraphLane? selectedLane;
  final Set<_NetworkGraphLane> hiddenLanes;
  final Set<_NetworkGraphLane> activeOnlyLanes;
  final ValueChanged<_NetworkGraphLane> onSelectLane;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (final lane in lanes)
          if (laneTops[lane] case final top?)
            Positioned(
              top: top,
              left: 0,
              width: hiddenLanes.contains(lane) ? 96 : 126,
              child: SizedBox(
                height: hiddenLanes.contains(lane)
                    ? 82
                    : max(118.0, cardHeight),
                child: _RelationalLaneButton(
                  lane: lane,
                  selected: selectedLane == lane,
                  hidden: hiddenLanes.contains(lane),
                  filterActive: activeOnlyLanes.contains(lane),
                  onTap: () => onSelectLane(lane),
                ),
              ),
            ),
        if (laneTops.length > 1)
          Positioned(
            top: (laneTops[lanes.first] ?? 0) + 62,
            left: 25,
            bottom: 60,
            child: CustomPaint(
              size: const Size(2, 760),
              painter: _RelationalLaneGuidePainter(),
            ),
          ),
      ],
    );
  }
}

class _RelationalLaneButton extends StatelessWidget {
  const _RelationalLaneButton({
    required this.lane,
    required this.selected,
    required this.hidden,
    required this.filterActive,
    required this.onTap,
  });

  final _NetworkGraphLane lane;
  final bool selected;
  final bool hidden;
  final bool filterActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected && !hidden ? _tealColor : _mutedColor;
    final visualIdentity = _visualIdentityForNetworkLane(lane);
    final iconHeight = hidden ? 34.0 : 52.0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashColor: color.withValues(alpha: 0.10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.fromLTRB(0, 0, hidden ? 2 : 6, 0),
          decoration: const BoxDecoration(color: Colors.transparent),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 52,
                    height: iconHeight,
                    decoration: BoxDecoration(
                      color: selected && !hidden
                          ? color.withValues(alpha: 0.07)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(hidden ? 13 : 16),
                      border: Border.all(
                        color: color.withValues(
                          alpha: selected && !hidden ? 0.72 : 0.36,
                        ),
                      ),
                    ),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _EntityMarker(
                              identity: visualIdentity,
                              size: 15,
                              semanticLabel:
                                  '${visualIdentity.typeLabel}: ${_laneLabel(lane)}',
                            ),
                            const SizedBox(width: 3),
                            Text(
                              _laneNumber(lane),
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(color: color),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (hidden)
                    Positioned(
                      right: -8,
                      bottom: -8,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: color.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Icon(
                          Icons.visibility_off_outlined,
                          color: color,
                          size: 15,
                        ),
                      ),
                    ),
                  if (filterActive)
                    Positioned(
                      top: -3,
                      right: -4,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _roseColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: hidden ? 6 : 8),
              Text(
                _laneLabel(lane),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    (hidden
                            ? Theme.of(context).textTheme.bodyMedium
                            : Theme.of(context).textTheme.titleMedium)
                        ?.copyWith(
                          color: hidden ? color.withValues(alpha: 0.62) : color,
                          fontWeight: selected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          height: 1.05,
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RelationalLaneGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _lineColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    const dashHeight = 9.0;
    const gap = 8.0;
    var y = 0.0;
    while (y < size.height) {
      canvas.drawLine(
        Offset.zero.translate(0, y),
        Offset(0, y + dashHeight),
        paint,
      );
      y += dashHeight + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RelationalNetworkNodeCard extends StatelessWidget {
  const _RelationalNetworkNodeCard({
    required this.node,
    required this.selected,
    required this.connected,
    required this.onTap,
    required this.onDoubleTap,
  });

  final _NetworkGraphNode node;
  final bool selected;
  final bool connected;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;

  @override
  Widget build(BuildContext context) {
    final laneColor = _laneColor(node.lane);
    final emphasis = selected
        ? laneColor
        : connected
        ? laneColor.withValues(alpha: 0.28)
        : _lineColor;
    final shadowColor = selected
        ? laneColor.withValues(alpha: 0.18)
        : _deepTealColor.withValues(alpha: 0.05);
    final needsAttention = _nodeNeedsAttention(node);

    return InkWell(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? laneColor.withValues(alpha: 0.10)
              : laneColor.withValues(alpha: 0.055),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: emphasis, width: selected ? 2.0 : 1.0),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: selected ? 22 : 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            _RelationalNodeAvatar(node: node),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    node.displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: node.lane == _NetworkGraphLane.employee
                          ? 16
                          : 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    node.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
                  ),
                ],
              ),
            ),
            if (needsAttention) ...[
              const SizedBox(width: 8),
              Tooltip(
                message: _nodeAttentionLabel(node),
                child: Icon(
                  _nodeHasWarningSignal(node)
                      ? Icons.warning_amber_rounded
                      : Icons.history_toggle_off_rounded,
                  color: _nodeHasWarningSignal(node) ? _roseColor : _amberColor,
                  size: 20,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RelationalNodeAvatar extends StatelessWidget {
  const _RelationalNodeAvatar({required this.node});

  final _NetworkGraphNode node;

  @override
  Widget build(BuildContext context) {
    final visualIdentity = _visualIdentityForNetworkNode(node);
    if (node.lane == _NetworkGraphLane.employee) {
      return Stack(
        alignment: Alignment.center,
        children: [
          _EntityMarker(
            identity: visualIdentity,
            size: 50,
            semanticLabel: '${visualIdentity.typeLabel}: ${node.displayName}',
          ),
          Text(
            _initialsFor(node.displayName),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      );
    }

    return _EntityMarker(
      identity: visualIdentity,
      size: 50,
      semanticLabel: '${visualIdentity.typeLabel}: ${node.displayName}',
    );
  }
}

class _RelationalCollapsedDetailDock extends StatelessWidget {
  const _RelationalCollapsedDetailDock({
    required this.label,
    required this.onTap,
  });

  final String? label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final displayLabel = label ?? 'Detalhe recolhido';
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 260,
          padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _lineColor),
            boxShadow: [
              BoxShadow(
                color: _deepTealColor.withValues(alpha: 0.08),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _tealColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: _tealColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalhe recolhido',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _mutedColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RelationalViewportDock extends StatelessWidget {
  const _RelationalViewportDock({
    required this.canGoBack,
    required this.canGoForward,
    required this.onBackTap,
    required this.onForwardTap,
    required this.onCenterTap,
    required this.onResetTap,
  });

  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback onBackTap;
  final VoidCallback onForwardTap;
  final VoidCallback onCenterTap;
  final VoidCallback onResetTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RelationalDockButton(
          icon: Icons.arrow_back_rounded,
          enabled: canGoBack,
          onTap: onBackTap,
        ),
        const SizedBox(height: 10),
        _RelationalDockButton(
          icon: Icons.arrow_forward_rounded,
          enabled: canGoForward,
          onTap: onForwardTap,
        ),
        const SizedBox(height: 10),
        _RelationalDockButton(
          icon: Icons.gps_fixed_rounded,
          onTap: onCenterTap,
        ),
        const SizedBox(height: 10),
        _RelationalDockButton(
          icon: Icons.fit_screen_outlined,
          onTap: onResetTap,
        ),
      ],
    );
  }
}

class _RelationalDockButton extends StatelessWidget {
  const _RelationalDockButton({
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: 54,
          height: 54,
          child: Icon(icon, color: enabled ? _inkColor : _mutedColor),
        ),
      ),
    );
  }
}

class _RelationalNetworkEdgePainter extends CustomPainter {
  const _RelationalNetworkEdgePainter({
    required this.payload,
    required this.nodes,
    required this.edges,
    required this.positions,
    required this.selectedNodeId,
  });

  final _NetworkGraphPayload payload;
  final List<_NetworkGraphNode> nodes;
  final List<_NetworkGraphEdge> edges;
  final Map<String, Rect> positions;
  final String? selectedNodeId;

  @override
  void paint(Canvas canvas, Size size) {
    final nodeMap = {for (final node in nodes) node.publicId: node};
    for (final edge in edges) {
      final fromRect = positions[edge.fromPublicId];
      final toRect = positions[edge.toPublicId];
      final fromNode = nodeMap[edge.fromPublicId];
      final toNode = nodeMap[edge.toPublicId];
      if (fromRect == null ||
          toRect == null ||
          fromNode == null ||
          toNode == null) {
        continue;
      }

      final highlight =
          selectedNodeId != null &&
          (selectedNodeId == edge.fromPublicId ||
              selectedNodeId == edge.toPublicId);
      final path = _edgePath(fromNode, toNode, fromRect, toRect);
      final color = _edgeColor(
        edge.relationshipState,
      ).withValues(alpha: highlight ? 0.96 : 0.72);
      final strokeWidth = highlight ? 3.4 : 2.2;

      if (edge.relationshipState == _NetworkGraphRelationshipState.indirect) {
        _drawDashedPath(canvas, path, color: color, strokeWidth: strokeWidth);
        continue;
      }

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, paint);
    }
  }

  Path _edgePath(
    _NetworkGraphNode fromNode,
    _NetworkGraphNode toNode,
    Rect fromRect,
    Rect toRect,
  ) {
    final fromLaneIndex = payload.lanes.indexOf(fromNode.lane);
    final toLaneIndex = payload.lanes.indexOf(toNode.lane);
    final path = Path();

    if (fromLaneIndex == toLaneIndex) {
      final left = fromRect.center.dx <= toRect.center.dx ? fromRect : toRect;
      final right = left == fromRect ? toRect : fromRect;
      path.moveTo(left.right, left.center.dy);
      path.cubicTo(
        left.right + 44,
        left.center.dy,
        right.left - 44,
        right.center.dy,
        right.left,
        right.center.dy,
      );
      return path;
    }

    final upperRect = fromLaneIndex < toLaneIndex ? fromRect : toRect;
    final lowerRect = upperRect == fromRect ? toRect : fromRect;
    final start = Offset(upperRect.center.dx, upperRect.bottom - 2);
    final end = Offset(lowerRect.center.dx, lowerRect.top + 2);
    final distance = (end.dy - start.dy).abs();
    final controlDelta = max(54.0, distance * 0.44);

    path.moveTo(start.dx, start.dy);
    path.cubicTo(
      start.dx,
      start.dy + controlDelta,
      end.dx,
      end.dy - controlDelta,
      end.dx,
      end.dy,
    );
    return path;
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path, {
    required Color color,
    required double strokeWidth,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      const dash = 12.0;
      const gap = 10.0;
      while (distance < metric.length) {
        final next = min(distance + dash, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RelationalNetworkEdgePainter oldDelegate) {
    return oldDelegate.edges != edges ||
        oldDelegate.nodes != nodes ||
        oldDelegate.positions != positions ||
        oldDelegate.selectedNodeId != selectedNodeId;
  }
}

class _RelationalLaneDetailPanel extends StatelessWidget {
  const _RelationalLaneDetailPanel({
    required this.lane,
    required this.nodes,
    required this.filterTargetNodes,
    required this.hideInactive,
    required this.hideLayer,
    required this.onClose,
    required this.onToggleHideInactive,
    required this.onToggleHideLayer,
  });

  final _NetworkGraphLane lane;
  final List<_NetworkGraphNode> nodes;
  final List<_NetworkGraphNode> filterTargetNodes;
  final bool hideInactive;
  final bool hideLayer;
  final VoidCallback onClose;
  final ValueChanged<bool> onToggleHideInactive;
  final ValueChanged<bool> onToggleHideLayer;

  @override
  Widget build(BuildContext context) {
    final laneColor = _laneColor(lane);
    final activeCount = filterTargetNodes
        .where((node) => _isActiveStatus(node.status))
        .length;
    final inactiveCount = max(0, filterTargetNodes.length - activeCount);
    final fields = [
      _RelationalDetailField(
        icon: Icons.layers_outlined,
        label: 'Itens na camada',
        value: '${nodes.length}',
      ),
      _RelationalDetailField(
        icon: Icons.check_circle_outline_rounded,
        label: 'Ativos no recorte',
        value: '$activeCount',
        accent: _tealColor,
      ),
      _RelationalDetailField(
        icon: Icons.history_toggle_off_outlined,
        label: _inactiveCountLabelFor(lane),
        value: '$inactiveCount',
        accent: inactiveCount == 0 ? null : _amberColor,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 22, 22),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _lineColor),
          boxShadow: [
            BoxShadow(
              color: _deepTealColor.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _laneLabel(lane),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 24,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  tooltip: 'Recolher painel',
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: laneColor.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                    border: Border.all(color: laneColor, width: 2),
                  ),
                  child: Icon(_iconForLane(lane), color: laneColor, size: 42),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    'Controles da camada',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: laneColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _RelationalContextFilterSection(
              inactiveLabel: _inactiveFilterLabelFor(lane),
              hiddenLabel: 'Ocultar esta camada',
              hideInactiveLocal: hideInactive,
              hideLayer: hideLayer,
              onToggleHideInactiveLocal: onToggleHideInactive,
              onToggleHideLayer: onToggleHideLayer,
            ),
            const SizedBox(height: 20),
            for (var index = 0; index < fields.length; index++)
              _RelationalDetailRow(field: fields[index]),
          ],
        ),
      ),
    );
  }
}

class _RelationalNetworkDetailPanel extends StatelessWidget {
  const _RelationalNetworkDetailPanel({
    required this.node,
    required this.onClose,
    required this.onSelectNode,
    required this.onOpenEmployeeProfile,
  });

  final _NetworkGraphNode node;
  final VoidCallback onClose;
  final ValueChanged<String> onSelectNode;
  final ValueChanged<String> onOpenEmployeeProfile;

  @override
  Widget build(BuildContext context) {
    final laneColor = _laneColor(node.lane);
    final visualIdentity = _visualIdentityForNetworkNode(node);
    final fields = _detailFieldsFor(node);
    final cta = node.detailSnapshot.cta;
    final employeeNode = node.lane == _NetworkGraphLane.employee;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 22, 22),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boundedHeight =
              constraints.hasBoundedHeight && constraints.maxHeight.isFinite;
          final fieldRows = ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: !boundedHeight,
            physics: boundedHeight
                ? const BouncingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return _RelationalDetailRow(field: fields[index]);
            },
            separatorBuilder: (context, index) => const SizedBox(height: 0),
            itemCount: fields.length,
          );
          final ctaTarget = cta?.targetPublicId ?? node.publicId;
          final ctaLabel = employeeNode ? 'Ver perfil completo' : cta?.label;

          return Container(
            constraints: boundedHeight
                ? const BoxConstraints()
                : const BoxConstraints(minHeight: 560),
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _lineColor),
              boxShadow: [
                BoxShadow(
                  color: _deepTealColor.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _detailTitleFor(node),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontSize: 24, letterSpacing: -0.4),
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      tooltip: 'Recolher painel',
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 32,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        _EntityMarker(
                          identity: visualIdentity,
                          size: 112,
                          selected: true,
                          semanticLabel:
                              '${visualIdentity.typeLabel}: ${node.displayName}',
                        ),
                        if (node.lane == _NetworkGraphLane.employee)
                          Text(
                            _initialsFor(node.displayName),
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            node.displayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontSize: 25, letterSpacing: -0.7),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            node.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: laneColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                if (boundedHeight) Expanded(child: fieldRows) else fieldRows,
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: ctaLabel == null
                        ? null
                        : () {
                            if (employeeNode) {
                              onOpenEmployeeProfile(ctaTarget);
                              return;
                            }
                            onSelectNode(ctaTarget);
                          },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(58),
                      foregroundColor: laneColor,
                      side: BorderSide(
                        color: laneColor.withValues(alpha: 0.48),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: Theme.of(context).textTheme.titleMedium,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            ctaLabel ?? 'Ver detalhes',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, size: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<_RelationalDetailField> _detailFieldsFor(_NetworkGraphNode node) {
    final snapshot = node.detailSnapshot;
    final extras = snapshot.extras;
    final fields = <_RelationalDetailField>[];

    switch (node.lane) {
      case _NetworkGraphLane.employee:
        fields.addAll([
          _RelationalDetailField(
            icon: Icons.badge_outlined,
            label: 'ID do colaborador',
            value: '${extras['employeeId'] ?? node.publicId}',
          ),
          _RelationalDetailField(
            icon: Icons.mail_outline_rounded,
            label: 'Email',
            value: '${extras['email'] ?? '-'}',
          ),
          _RelationalDetailField(
            icon: Icons.phone_outlined,
            label: 'Telefone',
            value: '${extras['phone'] ?? '-'}',
          ),
          _RelationalDetailField(
            icon: Icons.apartment_outlined,
            label: 'Departamento',
            value: '${extras['department'] ?? '-'}',
          ),
          _RelationalDetailField(
            icon: Icons.manage_accounts_outlined,
            label: 'Gestor',
            value: '${extras['manager'] ?? '-'}',
          ),
          _RelationalDetailField(
            icon: Icons.business_outlined,
            label: 'Cliente',
            value: '${extras['clientCompany'] ?? '-'}',
          ),
          _RelationalDetailField(
            icon: Icons.description_outlined,
            label: 'Contrato',
            value: '${extras['contract'] ?? '-'}',
          ),
          _RelationalDetailField(
            icon: Icons.work_outline_rounded,
            label: 'Posicao',
            value: '${extras['position'] ?? node.subtitle}',
          ),
          _RelationalDetailField(
            icon: Icons.timelapse_outlined,
            label: 'Status',
            value: '${extras['statusLabel'] ?? _titleCase(node.status)}',
            accent: _isActiveStatus(node.status) ? _tealColor : _amberColor,
          ),
          _RelationalDetailField(
            icon: Icons.calendar_today_outlined,
            label: 'Inicio',
            value: '${extras['startDate'] ?? '-'}',
          ),
          _RelationalDetailField(
            icon: Icons.location_on_outlined,
            label: 'Local',
            value: '${extras['location'] ?? '-'}',
          ),
        ]);
        break;
      case _NetworkGraphLane.position:
        fields.addAll([
          _RelationalDetailField(
            icon: Icons.description_outlined,
            label: 'Contrato',
            value: '${extras['contract'] ?? '-'}',
          ),
          _RelationalDetailField(
            icon: Icons.schedule_outlined,
            label: 'Escala',
            value: '${extras['scale'] ?? extras['schedule'] ?? '-'}',
          ),
          _RelationalDetailField(
            icon: Icons.wb_sunny_outlined,
            label: 'Turno',
            value: '${extras['shift'] ?? '-'}',
          ),
          _RelationalDetailField(
            icon: Icons.group_outlined,
            label: 'Colaboradores ativos',
            value: '${snapshot.activeEmployees ?? 0}',
          ),
          if (snapshot.historicalEmployees != null)
            _RelationalDetailField(
              icon: Icons.history_toggle_off_outlined,
              label: 'Historico de colaboradores',
              value: '${snapshot.historicalEmployees}',
            ),
          _RelationalDetailField(
            icon: Icons.timelapse_outlined,
            label: 'Status',
            value: '${extras['statusLabel'] ?? _titleCase(node.status)}',
            accent: _isActiveStatus(node.status) ? _tealColor : _amberColor,
          ),
          _RelationalDetailField(
            icon: Icons.location_on_outlined,
            label: 'Local',
            value: '${extras['location'] ?? '-'}',
          ),
        ]);
        break;
      case _NetworkGraphLane.contract:
        fields.addAll([
          _RelationalDetailField(
            icon: Icons.flag_outlined,
            label: 'Status do contrato',
            value: snapshot.contractStatus == null
                ? _titleCase(node.status)
                : _titleCase(snapshot.contractStatus!),
            accent: snapshot.contractStatus == 'active'
                ? _tealColor
                : _amberColor,
          ),
          _RelationalDetailField(
            icon: Icons.business_outlined,
            label: 'Clientes',
            value: snapshot.clientCompanies.isEmpty
                ? '-'
                : snapshot.clientCompanies.join(', '),
          ),
          _RelationalDetailField(
            icon: Icons.group_outlined,
            label: 'Colaboradores ativos',
            value: '${snapshot.activeEmployees ?? 0}',
          ),
          if (snapshot.historicalEmployees != null)
            _RelationalDetailField(
              icon: Icons.history_toggle_off_outlined,
              label: 'Historico de colaboradores',
              value: '${snapshot.historicalEmployees}',
            ),
        ]);
        break;
      case _NetworkGraphLane.clientCompany:
        fields.addAll([
          _RelationalDetailField(
            icon: Icons.account_tree_outlined,
            label: 'Grupos',
            value: snapshot.rootCompanies.isEmpty
                ? '-'
                : snapshot.rootCompanies.join(', '),
          ),
          _RelationalDetailField(
            icon: Icons.description_outlined,
            label: 'Contratos ativos',
            value: '${snapshot.activeContracts ?? 0}',
          ),
          _RelationalDetailField(
            icon: Icons.badge_outlined,
            label: 'Colaboradores ativos',
            value: '${snapshot.activeEmployees ?? 0}',
          ),
          if (snapshot.indirectConnections != null)
            _RelationalDetailField(
              icon: Icons.route_outlined,
              label: 'Conexoes indiretas',
              value: '${snapshot.indirectConnections}',
            ),
        ]);
        break;
      case _NetworkGraphLane.rootCompany:
        fields.addAll([
          _RelationalDetailField(
            icon: Icons.business_outlined,
            label: 'Clientes ativos',
            value: '${snapshot.activeClientCompanies ?? 0}',
          ),
          _RelationalDetailField(
            icon: Icons.description_outlined,
            label: 'Contratos ativos',
            value: '${snapshot.activeContracts ?? 0}',
          ),
          _RelationalDetailField(
            icon: Icons.badge_outlined,
            label: 'Colaboradores ativos',
            value: '${snapshot.activeEmployees ?? 0}',
          ),
          if (snapshot.historicalEmployees != null)
            _RelationalDetailField(
              icon: Icons.history_toggle_off_outlined,
              label: 'Historico de colaboradores',
              value: '${snapshot.historicalEmployees}',
            ),
        ]);
        break;
    }

    return fields;
  }
}

class _RelationalContextFilterSection extends StatelessWidget {
  const _RelationalContextFilterSection({
    required this.inactiveLabel,
    required this.hiddenLabel,
    required this.hideInactiveLocal,
    required this.hideLayer,
    required this.onToggleHideInactiveLocal,
    required this.onToggleHideLayer,
  });

  final String inactiveLabel;
  final String hiddenLabel;
  final bool hideInactiveLocal;
  final bool hideLayer;
  final ValueChanged<bool> onToggleHideInactiveLocal;
  final ValueChanged<bool> onToggleHideLayer;

  @override
  Widget build(BuildContext context) {
    final hasActiveFilter = hideInactiveLocal || hideLayer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasActiveFilter
              ? _roseColor.withValues(alpha: 0.34)
              : _lineColor,
        ),
      ),
      child: Column(
        children: [
          _RelationalContextFilterRow(
            icon: Icons.filter_alt_outlined,
            label: inactiveLabel,
            value: hideInactiveLocal,
            onChanged: onToggleHideInactiveLocal,
            highlight: hideInactiveLocal,
          ),
          const Divider(height: 16, color: _lineColor),
          _RelationalContextFilterRow(
            icon: hideLayer
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            label: hiddenLabel,
            value: hideLayer,
            onChanged: onToggleHideLayer,
            highlight: hideLayer,
          ),
        ],
      ),
    );
  }
}

class _RelationalContextFilterRow extends StatelessWidget {
  const _RelationalContextFilterRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.highlight,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, color: highlight ? _roseColor : _slateColor, size: 23),
            if (highlight)
              Positioned(
                top: -3,
                right: -4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: _roseColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _inkColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Switch.adaptive(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _RelationalDetailField {
  const _RelationalDetailField({
    required this.icon,
    required this.label,
    required this.value,
    this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? accent;
}

class _RelationalDetailRow extends StatelessWidget {
  const _RelationalDetailRow({required this.field});

  final _RelationalDetailField field;

  @override
  Widget build(BuildContext context) {
    final accent = field.accent;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _lineColor)),
      ),
      child: Row(
        children: [
          Icon(field.icon, color: _slateColor, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              field.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: _inkColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: DecoratedBox(
                decoration: accent == null
                    ? const BoxDecoration()
                    : BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: accent == null ? 0 : 14,
                    vertical: accent == null ? 0 : 8,
                  ),
                  child: Text(
                    field.value,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: accent,
                      fontWeight: accent == null
                          ? FontWeight.w500
                          : FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _toggleInSet(Set<String> values, String value) {
  if (values.contains(value)) {
    values.remove(value);
    return;
  }
  values.add(value);
}

IconData _iconForLane(_NetworkGraphLane lane) {
  return switch (lane) {
    _NetworkGraphLane.rootCompany => Icons.apartment_outlined,
    _NetworkGraphLane.clientCompany => Icons.business_outlined,
    _NetworkGraphLane.contract => Icons.description_outlined,
    _NetworkGraphLane.position => Icons.work_outline_rounded,
    _NetworkGraphLane.employee => Icons.person_outline_rounded,
  };
}

String _laneLabel(_NetworkGraphLane lane) {
  return switch (lane) {
    _NetworkGraphLane.rootCompany => 'Grupos',
    _NetworkGraphLane.clientCompany => 'Clientes',
    _NetworkGraphLane.contract => 'Contratos',
    _NetworkGraphLane.position => 'Posicoes',
    _NetworkGraphLane.employee => 'Colaboradores',
  };
}

String _laneNumber(_NetworkGraphLane lane) {
  return switch (lane) {
    _NetworkGraphLane.rootCompany => '01',
    _NetworkGraphLane.clientCompany => '02',
    _NetworkGraphLane.contract => '03',
    _NetworkGraphLane.position => '04',
    _NetworkGraphLane.employee => '05',
  };
}

Color _laneColor(_NetworkGraphLane lane) {
  return switch (lane) {
    _NetworkGraphLane.rootCompany => const Color(0xFF2A5F86),
    _NetworkGraphLane.clientCompany => const Color(0xFF4A7F58),
    _NetworkGraphLane.contract => const Color(0xFF7B57D1),
    _NetworkGraphLane.position => const Color(0xFFC07A15),
    _NetworkGraphLane.employee => const Color(0xFFD18A17),
  };
}

Color _edgeColor(_NetworkGraphRelationshipState state) {
  return switch (state) {
    _NetworkGraphRelationshipState.active => _tealColor,
    _NetworkGraphRelationshipState.historical => _amberColor,
    _NetworkGraphRelationshipState.indirect => const Color(0xFF8C8C92),
  };
}

String _detailTitleFor(_NetworkGraphNode node) {
  return switch (node.lane) {
    _NetworkGraphLane.rootCompany => 'Detalhes do grupo',
    _NetworkGraphLane.clientCompany => 'Detalhes do cliente',
    _NetworkGraphLane.contract => 'Detalhes do contrato',
    _NetworkGraphLane.position => 'Detalhes da posicao',
    _NetworkGraphLane.employee => 'Detalhes do colaborador',
  };
}

Rect _visibleTimelineSceneRect(
  Matrix4 matrix,
  Size viewportSize,
  Size sceneSize,
) {
  try {
    final inverse = Matrix4.inverted(matrix);
    final topLeft = MatrixUtils.transformPoint(inverse, Offset.zero);
    final bottomRight = MatrixUtils.transformPoint(
      inverse,
      Offset(viewportSize.width, viewportSize.height),
    );
    final sceneBounds = Offset.zero & sceneSize;
    return Rect.fromPoints(
      topLeft,
      bottomRight,
    ).inflate(120).intersect(sceneBounds);
  } catch (_) {
    return Offset.zero & sceneSize;
  }
}

Rect _boundsForPoints(List<Offset> points) {
  if (points.isEmpty) {
    return Rect.zero;
  }
  var left = points.first.dx;
  var right = points.first.dx;
  var top = points.first.dy;
  var bottom = points.first.dy;
  for (final point in points.skip(1)) {
    left = min(left, point.dx);
    right = max(right, point.dx);
    top = min(top, point.dy);
    bottom = max(bottom, point.dy);
  }
  return Rect.fromLTRB(left, top, right, bottom);
}

@visibleForTesting
Map<String, Object?> debugNetworkTimelineCullingSummary(
  Map<String, dynamic> map, {
  double viewportWidth = 1366,
  double visibleLeft = 0,
  double visibleTop = 0,
  double visibleWidth = 1366,
  double visibleHeight = 900,
}) {
  final payload = _NetworkTimelinePayload.fromMap(map);
  final layout = _NetworkTimelineCanvasLayout.compute(
    payload: payload,
    viewportWidth: viewportWidth,
  );
  final visibleSceneRect = _clampedTimelineRect(
    Rect.fromLTWH(visibleLeft, visibleTop, visibleWidth, visibleHeight),
    Size(layout.sceneWidth, layout.sceneHeight),
  );

  final totalPositions = payload.contracts.fold<int>(
    0,
    (total, contract) => total + contract.positions.length,
  );
  final totalAllocations = payload.contracts.fold<int>(
    0,
    (total, contract) =>
        total +
        contract.positions.fold<int>(
          0,
          (positionTotal, position) =>
              positionTotal + position.allocations.length,
        ),
  );
  final totalStructuredMoves = payload.events.where((event) {
    return event.eventType == 'move' && event.hasStructuredMove;
  }).length;

  bool isVisible(Rect rect) => rect.overlaps(visibleSceneRect);

  var visibleStructuredMoves = 0;
  for (final event in payload.events) {
    if (event.eventType != 'move' || !event.hasStructuredMove) {
      continue;
    }
    final originRect = layout.positionRects[event.originPositionPublicId];
    final destinationRect =
        layout.positionRects[event.destinationPositionPublicId];
    final eventRect = layout.eventRects[event.publicId];
    if (originRect == null || destinationRect == null || eventRect == null) {
      continue;
    }
    final bounds = _boundsForPoints([
      originRect.center,
      eventRect.center,
      destinationRect.center,
    ]).inflate(36);
    if (isVisible(bounds)) {
      visibleStructuredMoves++;
    }
  }

  return {
    'sceneWidth': layout.sceneWidth,
    'sceneHeight': layout.sceneHeight,
    'totalContracts': payload.contracts.length,
    'totalPositions': totalPositions,
    'totalAllocations': totalAllocations,
    'totalEvents': payload.events.length,
    'totalStructuredMoves': totalStructuredMoves,
    'visibleContracts': layout.contractRects.values.where(isVisible).length,
    'visiblePositions': layout.positionRects.values.where(isVisible).length,
    'visibleAllocations': layout.allocationRects.values.where(isVisible).length,
    'visibleEvents': layout.eventRects.values
        .where((rect) => isVisible(rect.inflate(18)))
        .length,
    'visibleStructuredMoves': visibleStructuredMoves,
    'visibleRowLabels': layout.rowLabels.where((row) {
      return row.top >= visibleSceneRect.top - 48 &&
          row.top <= visibleSceneRect.bottom + 48;
    }).length,
    'visibleMonthTicks': layout.monthTicks.where((tick) {
      return tick.x >= visibleSceneRect.left - 80 &&
          tick.x <= visibleSceneRect.right + 80;
    }).length,
  };
}

Rect _clampedTimelineRect(Rect rect, Size sceneSize) {
  final scene = Offset.zero & sceneSize;
  final left = rect.left.clamp(scene.left, scene.right).toDouble();
  final top = rect.top.clamp(scene.top, scene.bottom).toDouble();
  final right = rect.right.clamp(scene.left, scene.right).toDouble();
  final bottom = rect.bottom.clamp(scene.top, scene.bottom).toDouble();

  if (right <= left || bottom <= top) {
    return Rect.fromLTWH(left, top, 0, 0);
  }
  return Rect.fromLTRB(left, top, right, bottom);
}

int _monthSpan(DateTime start, DateTime end) {
  return ((end.year - start.year) * 12) + end.month - start.month + 1;
}

double _xForDate(
  DateTime date, {
  required DateTime periodStart,
  required DateTime periodEnd,
  required double leftRailWidth,
  required double axisWidth,
}) {
  final totalDays = max(1, periodEnd.difference(periodStart).inDays);
  final clamped = date.isBefore(periodStart)
      ? periodStart
      : date.isAfter(periodEnd)
      ? periodEnd
      : date;
  final dayOffset = clamped.difference(periodStart).inDays;
  return leftRailWidth + (dayOffset / totalDays) * axisWidth;
}

List<_NetworkTimelineMonthTick> _timelineMonthTicks(
  DateTime start,
  DateTime end, {
  required double leftRailWidth,
  required double axisWidth,
}) {
  final first = DateTime(start.year, start.month);
  final ticks = <_NetworkTimelineMonthTick>[];
  var cursor = first;
  while (!cursor.isAfter(end)) {
    ticks.add(
      _NetworkTimelineMonthTick(
        date: cursor,
        x: _xForDate(
          cursor,
          periodStart: start,
          periodEnd: end,
          leftRailWidth: leftRailWidth,
          axisWidth: axisWidth,
        ),
      ),
    );
    cursor = _addMonths(cursor, 1);
  }
  return ticks;
}

String _timelineMonthLabel(DateTime date, {required bool showYear}) {
  final month = switch (date.month) {
    1 => 'Jan',
    2 => 'Fev',
    3 => 'Mar',
    4 => 'Abr',
    5 => 'Mai',
    6 => 'Jun',
    7 => 'Jul',
    8 => 'Ago',
    9 => 'Set',
    10 => 'Out',
    11 => 'Nov',
    _ => 'Dez',
  };
  return showYear ? '$month ${date.year}' : month;
}

void _paintText(
  Canvas canvas,
  String text,
  Offset offset, {
  required double maxWidth,
  required TextStyle style,
}) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    ellipsis: '...',
    textDirection: TextDirection.ltr,
    textScaler: TextScaler.noScaling,
  )..layout(maxWidth: max(1, maxWidth));
  painter.paint(canvas, offset);
}

void _paintIcon(Canvas canvas, IconData icon, Offset offset, Color color) {
  final painter = TextPainter(
    text: TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: color,
        fontSize: 16,
      ),
    ),
    textDirection: TextDirection.ltr,
    textScaler: TextScaler.noScaling,
  )..layout();
  painter.paint(canvas, offset);
}

Color _timelineStatusColor(String status) {
  return switch (_normalizeNetworkText(status)) {
    'active' || 'ativo' => _tealColor,
    'expired' || 'historical' || 'inactive' || 'encerrado' => _amberColor,
    'dismissed' || 'suspended' || 'blocked' => _roseColor,
    _ => _slateColor,
  };
}

Color _timelineEventColor(String eventType) {
  return switch (eventType) {
    'admission' => _tealColor,
    'move' => _amberColor,
    'dismissal' => _roseColor,
    'calendar_entry' => _slateColor,
    'timeline_record' => _deepTealColor,
    _ => _slateColor,
  };
}

String _timelineDetailTitle(
  _NetworkTimelineSelection? selection,
  _NetworkTimelinePayload payload,
) {
  if (selection == null) {
    return 'Detalhes da timeline';
  }

  return switch (selection.kind) {
    _NetworkTimelineSelectionKind.contract =>
      payload.contractByPublicId(selection.publicId)?.displayName ?? 'Contrato',
    _NetworkTimelineSelectionKind.position =>
      payload.positionByPublicId(selection.publicId)?.displayName ?? 'Posto',
    _NetworkTimelineSelectionKind.collaborator =>
      _timelineCollaboratorByEmploymentLink(
            payload,
            selection.publicId,
          )?.personName ??
          'Colaborador',
    _NetworkTimelineSelectionKind.event =>
      payload.eventByPublicId(selection.publicId)?.label ?? 'Evento',
  };
}

_NetworkTimelineSegment? _timelineSegmentByEmploymentLink(
  _NetworkTimelinePayload payload,
  String employmentLinkPublicId,
) {
  for (final collaborator in payload.collaborators) {
    for (final segment in collaborator.segments) {
      if (segment.employmentLinkPublicId == employmentLinkPublicId) {
        return segment;
      }
    }
  }
  return null;
}

_NetworkTimelineCollaborator? _timelineCollaboratorBySegment(
  _NetworkTimelinePayload payload,
  _NetworkTimelineSegment segment,
) {
  for (final collaborator in payload.collaborators) {
    if (collaborator.segments.contains(segment)) {
      return collaborator;
    }
  }
  return null;
}

_NetworkTimelineCollaborator? _timelineCollaboratorByEmploymentLink(
  _NetworkTimelinePayload payload,
  String employmentLinkPublicId,
) {
  final segment = _timelineSegmentByEmploymentLink(
    payload,
    employmentLinkPublicId,
  );
  if (segment == null) {
    return null;
  }
  return _timelineCollaboratorBySegment(payload, segment);
}

String _initialsFor(String name) {
  final parts = name.split(' ').where((part) => part.isNotEmpty).toList();
  if (parts.isEmpty) {
    return '--';
  }
  if (parts.length == 1) {
    return parts.first.substring(0, min(2, parts.first.length)).toUpperCase();
  }
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

String _titleCase(String value) {
  if (value.isEmpty) {
    return value;
  }

  return value
      .split(RegExp(r'[\s_-]+'))
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
