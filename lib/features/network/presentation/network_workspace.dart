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
                  label: 'preview antiga desativada',
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
                      label:
                          _networkGraphContractPreview.primaryFocusDisplayName,
                      icon: Icons.center_focus_strong_outlined,
                      color: _tealColor,
                      background: _tealColor.withValues(alpha: 0.12),
                    ),
                    _Tag(
                      label:
                          '${_networkGraphContractPreview.countNodesInLane(_NetworkGraphLane.employee)} colaboradores no preview',
                      icon: Icons.badge_outlined,
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

  late final TextEditingController _searchController;
  final TransformationController _canvasController = TransformationController();
  late String _periodPreset;
  late Set<String> _selectedRootIds;
  late Set<String> _selectedClientIds;
  late Set<String> _contractStatuses;
  late Set<String> _employeeStatuses;
  late bool _includeHistorical;
  late bool _includeIndirect;
  bool _showFilters = false;
  bool _showDetailPanel = true;
  double _zoom = 1.0;
  Size _canvasViewportSize = Size.zero;
  _NetworkGraphLane? _selectedLaneForDetails;
  final Set<_NetworkGraphLane> _hiddenLanes = {};
  final Set<_NetworkGraphLane> _activeOnlyLanes = {};

  _NetworkGraphPayload get _payload => _networkGraphContractPreview;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: _payload.filters.search);
    _periodPreset = _payload.filters.applied.periodPreset;
    _selectedRootIds = {..._payload.filters.applied.rootCompanyPublicIds};
    _selectedClientIds = {..._payload.filters.applied.clientCompanyPublicIds};
    _contractStatuses = {..._payload.filters.applied.contractStatuses};
    _employeeStatuses = {..._payload.filters.applied.employeeStatuses};
    _includeHistorical = _payload.filters.applied.includeHistorical;
    _includeIndirect = _payload.filters.applied.includeIndirect;
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
      if (preset == '6m') {
        _includeHistorical = false;
      } else if (preset == '1y') {
        _includeHistorical = true;
      }
    });
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
  }

  void _syncZoomFromCanvas() {
    final nextZoom = _canvasController.value
        .getMaxScaleOnAxis()
        .clamp(_minCanvasZoom, _maxCanvasZoom)
        .toDouble();
    if ((nextZoom - _zoom).abs() < 0.005) {
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
  }

  void _restoreFilters() {
    setState(() {
      _searchController.text = _payload.filters.search;
      _periodPreset = _payload.filters.applied.periodPreset;
      _selectedRootIds = {..._payload.filters.applied.rootCompanyPublicIds};
      _selectedClientIds = {..._payload.filters.applied.clientCompanyPublicIds};
      _contractStatuses = {..._payload.filters.applied.contractStatuses};
      _employeeStatuses = {..._payload.filters.applied.employeeStatuses};
      _includeHistorical = _payload.filters.applied.includeHistorical;
      _includeIndirect = _payload.filters.applied.includeIndirect;
      _selectedLaneForDetails = null;
      _hiddenLanes.clear();
      _activeOnlyLanes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final view = _filteredView();
    final selectedNode = view.selectedNodeFor(widget.selectedNodeId);
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
                  onToggleFilters: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                ),
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
                      onToggleRoot: (publicId) {
                        setState(() {
                          _toggleInSet(_selectedRootIds, publicId);
                        });
                      },
                      onToggleClient: (publicId) {
                        setState(() {
                          _toggleInSet(_selectedClientIds, publicId);
                        });
                      },
                      onToggleContractStatus: (value) {
                        setState(() {
                          _toggleInSet(_contractStatuses, value);
                        });
                      },
                      onToggleEmployeeStatus: (value) {
                        setState(() {
                          _toggleInSet(_employeeStatuses, value);
                        });
                      },
                      onToggleHistorical: (value) {
                        setState(() {
                          _includeHistorical = value;
                        });
                      },
                      onToggleIndirect: (value) {
                        setState(() {
                          _includeIndirect = value;
                        });
                      },
                      onRestore: _restoreFilters,
                    ),
                  ),
                  secondChild: const SizedBox.shrink(),
                ),
                Expanded(
                  child: wide
                      ? Row(
                          children: [
                            Expanded(child: graphSection),
                            if (_showDetailPanel)
                              SizedBox(width: 424, child: detailPanel),
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
        const legendHeight = 62.0;
        final canvasAreaHeight = max(
          520.0,
          constraints.maxHeight - legendHeight,
        );
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: legendHeight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 18, 28, 0),
                child: Row(
                  children: const [
                    _RelationalLegendItem(
                      color: _tealColor,
                      label: 'Active Relationship',
                    ),
                    SizedBox(width: 42),
                    _RelationalLegendItem(
                      color: _amberColor,
                      label: 'Historical Relationship',
                    ),
                    SizedBox(width: 42),
                    _RelationalLegendItem(
                      color: Color(0xFF8C8C92),
                      label: 'Indirect Relationship',
                      dashed: true,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
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
                                      transformationController:
                                          _canvasController,
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
                                      onInteractionEnd: (_) =>
                                          _syncZoomFromCanvas(),
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
                                                      positions:
                                                          layout.positions,
                                                      selectedNodeId:
                                                          selectedNode
                                                              ?.publicId,
                                                    ),
                                              ),
                                            ),
                                            for (final node in view.nodes)
                                              if (layout.positions[node
                                                      .publicId]
                                                  case final rect?)
                                                Positioned.fromRect(
                                                  rect: rect,
                                                  child: _RelationalNetworkNodeCard(
                                                    node: node,
                                                    selected:
                                                        selectedNode
                                                            ?.publicId ==
                                                        node.publicId,
                                                    connected: connectedIds
                                                        .contains(
                                                          node.publicId,
                                                        ),
                                                    onTap: () {
                                                      setState(() {
                                                        _selectedLaneForDetails =
                                                            null;
                                                        _showDetailPanel = true;
                                                      });
                                                      widget.onSelectNode(
                                                        node.publicId,
                                                      );
                                                    },
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
                  Positioned(
                    left: layout.laneRailWidth + 18,
                    bottom: 18,
                    child: _RelationalViewportDock(
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
            ),
          ],
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

    for (final node in _payload.nodes) {
      final rootFilterActive = _selectedRootIds.isNotEmpty;
      final clientFilterActive = _selectedClientIds.isNotEmpty;

      if (rootFilterActive &&
          node.lane == _NetworkGraphLane.rootCompany &&
          !_selectedRootIds.contains(node.publicId)) {
        continue;
      }

      if (clientFilterActive &&
          node.lane == _NetworkGraphLane.clientCompany &&
          !_selectedClientIds.contains(node.publicId)) {
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

    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _RelationalNetworkView(
        nodes: visibleNodes,
        edges: bridgedEdges,
        payload: _payload,
      );
    }

    final matchedIds = visibleNodes
        .where(
          (node) =>
              node.displayName.toLowerCase().contains(query) ||
              node.subtitle.toLowerCase().contains(query) ||
              node.badges.any((badge) => badge.toLowerCase().contains(query)),
        )
        .map((node) => node.publicId)
        .toSet();

    final visibleIds = {...matchedIds};
    for (final edge in bridgedEdges) {
      if (matchedIds.contains(edge.fromPublicId) ||
          matchedIds.contains(edge.toPublicId)) {
        visibleIds.add(edge.fromPublicId);
        visibleIds.add(edge.toPublicId);
      }
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

    return _RelationalNetworkView(
      nodes: nodes,
      edges: edges,
      payload: _payload,
    );
  }
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
    _NetworkGraphLane.rootCompany => 'Inactive groups',
    _NetworkGraphLane.clientCompany => 'Inactive clients',
    _NetworkGraphLane.contract => 'Ended contracts',
    _NetworkGraphLane.position => 'Ended positions',
    _NetworkGraphLane.employee => 'Dismissed employees',
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
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onZoomOut,
    required this.onZoomIn,
    required this.onResetViewport,
    required this.onPeriodChanged,
    required this.onToggleFilters,
  });

  final TextEditingController searchController;
  final double zoom;
  final List<String> periodPresets;
  final String selectedPeriodPreset;
  final bool showFilters;
  final VoidCallback onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onZoomOut;
  final VoidCallback onZoomIn;
  final VoidCallback onResetViewport;
  final ValueChanged<String> onPeriodChanged;
  final VoidCallback onToggleFilters;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE9E6DF))),
      ),
      child: Row(
        children: [
          const _RelationalNetworkMark(),
          const SizedBox(width: 16),
          SizedBox(
            width: 270,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Relational Network',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 26,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Business Overview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _mutedColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _RelationalControlCard(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _RelationalIconButton(
                            icon: Icons.remove_rounded,
                            onTap: onZoomOut,
                          ),
                          SizedBox(
                            width: 88,
                            child: Center(
                              child: Text(
                                '${(zoom * 100).round()}%',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: _mutedColor),
                              ),
                            ),
                          ),
                          _RelationalIconButton(
                            icon: Icons.add_rounded,
                            onTap: onZoomIn,
                          ),
                          Container(width: 1, height: 44, color: _lineColor),
                          _RelationalIconButton(
                            icon: Icons.fit_screen_outlined,
                            onTap: onResetViewport,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 22),
                    _RelationalControlCard(
                      width: 410,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              color: _slateColor,
                              size: 25,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: searchController,
                                onChanged: (_) => onSearchChanged(),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText:
                                      'Search companies, contracts, employees...',
                                  isCollapsed: true,
                                ),
                              ),
                            ),
                            if (searchController.text.isNotEmpty)
                              IconButton(
                                onPressed: onClearSearch,
                                icon: const Icon(Icons.close_rounded),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 22),
                    Text(
                      'Period:',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: _mutedColor),
                    ),
                    const SizedBox(width: 12),
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
                    const SizedBox(width: 22),
                    _RelationalControlCard(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: onToggleFilters,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 17,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                showFilters
                                    ? Icons.filter_alt_rounded
                                    : Icons.filter_alt_outlined,
                                color: _inkColor,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Filters',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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

class _RelationalLegendItem extends StatelessWidget {
  const _RelationalLegendItem({
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
          width: 40,
          height: 12,
          child: CustomPaint(
            painter: _RelationalLegendLinePainter(color: color, dashed: dashed),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: _mutedColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
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
  const _RelationalControlCard({required this.child, this.width});

  final Widget child;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
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
    required this.onToggleRoot,
    required this.onToggleClient,
    required this.onToggleContractStatus,
    required this.onToggleEmployeeStatus,
    required this.onToggleHistorical,
    required this.onToggleIndirect,
    required this.onRestore,
  });

  final _NetworkGraphPayload payload;
  final Set<String> selectedRootIds;
  final Set<String> selectedClientIds;
  final Set<String> contractStatuses;
  final Set<String> employeeStatuses;
  final bool includeHistorical;
  final bool includeIndirect;
  final ValueChanged<String> onToggleRoot;
  final ValueChanged<String> onToggleClient;
  final ValueChanged<String> onToggleContractStatus;
  final ValueChanged<String> onToggleEmployeeStatus;
  final ValueChanged<bool> onToggleHistorical;
  final ValueChanged<bool> onToggleIndirect;
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
                'Available filters',
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
            title: 'Root companies',
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
            title: 'Client companies',
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
            title: 'Contract status',
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
            title: 'Employee status',
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
                label: const Text('Show historical relationships'),
                selected: includeHistorical,
                onSelected: onToggleHistorical,
              ),
              FilterChip(
                label: const Text('Show indirect relationships'),
                selected: includeIndirect,
                onSelected: onToggleIndirect,
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
    final color = _laneColor(lane);
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
                      child: Text(
                        _laneNumber(lane),
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: color),
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
  });

  final _NetworkGraphNode node;
  final bool selected;
  final bool connected;
  final VoidCallback onTap;

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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
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
    final laneColor = _laneColor(node.lane);
    if (node.lane == _NetworkGraphLane.employee) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: laneColor.withValues(alpha: 0.10),
          shape: BoxShape.circle,
          border: Border.all(color: laneColor.withValues(alpha: 0.24)),
        ),
        alignment: Alignment.center,
        child: Text(
          _initialsFor(node.displayName),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: laneColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: laneColor.withValues(alpha: 0.10),
        shape: BoxShape.circle,
        border: Border.all(color: laneColor.withValues(alpha: 0.24)),
      ),
      child: Icon(_iconForLane(node.lane), color: laneColor, size: 29),
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
    required this.onCenterTap,
    required this.onResetTap,
  });

  final VoidCallback onCenterTap;
  final VoidCallback onResetTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 138,
          height: 138,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _lineColor),
            boxShadow: [
              BoxShadow(
                color: _deepTealColor.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: CustomPaint(painter: _RelationalMiniMapPainter()),
        ),
        const SizedBox(width: 14),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RelationalDockButton(
              icon: Icons.gps_fixed_rounded,
              onTap: onCenterTap,
            ),
            const SizedBox(height: 12),
            _RelationalDockButton(
              icon: Icons.fit_screen_outlined,
              onTap: onResetTap,
            ),
          ],
        ),
      ],
    );
  }
}

class _RelationalMiniMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final frame = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(18),
    );
    canvas.drawRRect(frame, Paint()..color = const Color(0xFFF7F4EE));

    final active = Paint()
      ..color = _tealColor.withValues(alpha: 0.42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final accent = Paint()
      ..color = _amberColor.withValues(alpha: 0.34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path()
      ..moveTo(size.width * 0.16, size.height * 0.24)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.42,
        size.width * 0.26,
        size.height * 0.38,
        size.width * 0.28,
        size.height * 0.58,
      )
      ..moveTo(size.width * 0.50, size.height * 0.24)
      ..cubicTo(
        size.width * 0.48,
        size.height * 0.42,
        size.width * 0.54,
        size.height * 0.40,
        size.width * 0.56,
        size.height * 0.60,
      )
      ..moveTo(size.width * 0.78, size.height * 0.26)
      ..cubicTo(
        size.width * 0.76,
        size.height * 0.44,
        size.width * 0.72,
        size.height * 0.42,
        size.width * 0.70,
        size.height * 0.62,
      );
    canvas.drawPath(path, active);

    canvas.drawLine(
      Offset(size.width * 0.28, size.height * 0.58),
      Offset(size.width * 0.56, size.height * 0.60),
      active,
    );
    canvas.drawLine(
      Offset(size.width * 0.56, size.height * 0.60),
      Offset(size.width * 0.70, size.height * 0.62),
      active,
    );
    canvas.drawLine(
      Offset(size.width * 0.38, size.height * 0.80),
      Offset(size.width * 0.62, size.height * 0.80),
      accent,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RelationalDockButton extends StatelessWidget {
  const _RelationalDockButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: 54,
          height: 54,
          child: Icon(icon, color: _inkColor),
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
        label: 'Items in layer',
        value: '${nodes.length}',
      ),
      _RelationalDetailField(
        icon: Icons.check_circle_outline_rounded,
        label: 'Active in filter scope',
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
                    'Layer controls',
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
          final ctaLabel = employeeNode ? 'View Full Profile' : cta?.label;

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
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        color: laneColor.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                        border: Border.all(color: laneColor, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: node.lane == _NetworkGraphLane.employee
                          ? Text(
                              _initialsFor(node.displayName),
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(color: laneColor, fontSize: 32),
                            )
                          : Icon(
                              _iconForLane(node.lane),
                              color: laneColor,
                              size: 48,
                            ),
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
                      foregroundColor: _inkColor,
                      side: const BorderSide(color: _lineColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: Theme.of(context).textTheme.titleMedium,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            ctaLabel ?? 'View Details',
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
            label: 'Employee ID',
            value: '${extras['employeeId'] ?? node.publicId}',
          ),
          _RelationalDetailField(
            icon: Icons.mail_outline_rounded,
            label: 'Email',
            value: '${extras['email'] ?? '-'}',
          ),
          _RelationalDetailField(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: '${extras['phone'] ?? '-'}',
          ),
          _RelationalDetailField(
            icon: Icons.apartment_outlined,
            label: 'Department',
            value: '${extras['department'] ?? '-'}',
          ),
          _RelationalDetailField(
            icon: Icons.manage_accounts_outlined,
            label: 'Manager',
            value: '${extras['manager'] ?? '-'}',
          ),
          _RelationalDetailField(
            icon: Icons.business_outlined,
            label: 'Client Company',
            value: '${extras['clientCompany'] ?? '-'}',
          ),
          _RelationalDetailField(
            icon: Icons.description_outlined,
            label: 'Contract',
            value: '${extras['contract'] ?? '-'}',
          ),
          _RelationalDetailField(
            icon: Icons.work_outline_rounded,
            label: 'Position',
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
            label: 'Start Date',
            value: '${extras['startDate'] ?? '-'}',
          ),
          _RelationalDetailField(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: '${extras['location'] ?? '-'}',
          ),
        ]);
        break;
      case _NetworkGraphLane.position:
        fields.addAll([
          _RelationalDetailField(
            icon: Icons.description_outlined,
            label: 'Contract',
            value: '${extras['contract'] ?? '-'}',
          ),
          _RelationalDetailField(
            icon: Icons.schedule_outlined,
            label: 'Scale',
            value: '${extras['scale'] ?? '-'}',
          ),
          _RelationalDetailField(
            icon: Icons.wb_sunny_outlined,
            label: 'Shift',
            value: '${extras['shift'] ?? '-'}',
          ),
          _RelationalDetailField(
            icon: Icons.group_outlined,
            label: 'Active employees',
            value: '${snapshot.activeEmployees ?? 0}',
          ),
          if (snapshot.historicalEmployees != null)
            _RelationalDetailField(
              icon: Icons.history_toggle_off_outlined,
              label: 'Historical employees',
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
            label: 'Location',
            value: '${extras['location'] ?? '-'}',
          ),
        ]);
        break;
      case _NetworkGraphLane.contract:
        fields.addAll([
          _RelationalDetailField(
            icon: Icons.flag_outlined,
            label: 'Contract status',
            value: snapshot.contractStatus == null
                ? _titleCase(node.status)
                : _titleCase(snapshot.contractStatus!),
            accent: snapshot.contractStatus == 'active'
                ? _tealColor
                : _amberColor,
          ),
          _RelationalDetailField(
            icon: Icons.business_outlined,
            label: 'Client companies',
            value: snapshot.clientCompanies.isEmpty
                ? '-'
                : snapshot.clientCompanies.join(', '),
          ),
          _RelationalDetailField(
            icon: Icons.group_outlined,
            label: 'Active employees',
            value: '${snapshot.activeEmployees ?? 0}',
          ),
          if (snapshot.historicalEmployees != null)
            _RelationalDetailField(
              icon: Icons.history_toggle_off_outlined,
              label: 'Historical employees',
              value: '${snapshot.historicalEmployees}',
            ),
        ]);
        break;
      case _NetworkGraphLane.clientCompany:
        fields.addAll([
          _RelationalDetailField(
            icon: Icons.account_tree_outlined,
            label: 'Root companies',
            value: snapshot.rootCompanies.isEmpty
                ? '-'
                : snapshot.rootCompanies.join(', '),
          ),
          _RelationalDetailField(
            icon: Icons.description_outlined,
            label: 'Active contracts',
            value: '${snapshot.activeContracts ?? 0}',
          ),
          _RelationalDetailField(
            icon: Icons.badge_outlined,
            label: 'Active employees',
            value: '${snapshot.activeEmployees ?? 0}',
          ),
          if (snapshot.indirectConnections != null)
            _RelationalDetailField(
              icon: Icons.route_outlined,
              label: 'Indirect connections',
              value: '${snapshot.indirectConnections}',
            ),
        ]);
        break;
      case _NetworkGraphLane.rootCompany:
        fields.addAll([
          _RelationalDetailField(
            icon: Icons.business_outlined,
            label: 'Active client companies',
            value: '${snapshot.activeClientCompanies ?? 0}',
          ),
          _RelationalDetailField(
            icon: Icons.description_outlined,
            label: 'Active contracts',
            value: '${snapshot.activeContracts ?? 0}',
          ),
          _RelationalDetailField(
            icon: Icons.badge_outlined,
            label: 'Active employees',
            value: '${snapshot.activeEmployees ?? 0}',
          ),
          if (snapshot.historicalEmployees != null)
            _RelationalDetailField(
              icon: Icons.history_toggle_off_outlined,
              label: 'Historical employees',
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
    _NetworkGraphLane.rootCompany => 'Root Companies',
    _NetworkGraphLane.clientCompany => 'Client Companies',
    _NetworkGraphLane.contract => 'Contracts',
    _NetworkGraphLane.position => 'Positions',
    _NetworkGraphLane.employee => 'Employees',
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
    _NetworkGraphLane.rootCompany => 'Root Company Details',
    _NetworkGraphLane.clientCompany => 'Client Company Details',
    _NetworkGraphLane.contract => 'Contract Details',
    _NetworkGraphLane.position => 'Position Details',
    _NetworkGraphLane.employee => 'Employee Details',
  };
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
