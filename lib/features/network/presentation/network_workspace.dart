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
  late final TextEditingController _searchController;
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
    setState(() {
      _zoom = (_zoom + delta).clamp(0.85, 1.25);
    });
  }

  void _resetViewport() {
    setState(() {
      _zoom = 1.0;
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final view = _filteredView();
    final selectedNode = view.selectedNodeFor(widget.selectedNodeId);
    final legendEntries = _payload.legend.relationshipStates;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1340;
        final graphWidth = wide
            ? constraints.maxWidth - 448
            : constraints.maxWidth;
        final graphSection = _buildGraphSection(
          context,
          graphWidth: graphWidth,
          view: view,
          selectedNode: selectedNode,
        );
        final detailPanel = _buildDetailPanel(
          context,
          selectedNode: selectedNode,
          visibleNodes: view.nodes,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Panel(
              padding: const EdgeInsets.fromLTRB(28, 26, 28, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runSpacing: 18,
                    spacing: 18,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: _tealColor.withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.hub_outlined,
                              size: 38,
                              color: _tealColor,
                            ),
                          ),
                          const SizedBox(width: 18),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Visual Network',
                                style: Theme.of(context).textTheme.displaySmall
                                    ?.copyWith(
                                      fontSize: 34,
                                      letterSpacing: -1.4,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Business Overview',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: _mutedColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _RelationalControlCard(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _RelationalIconButton(
                                  icon: Icons.remove_rounded,
                                  onTap: () => _adjustZoom(-0.05),
                                ),
                                SizedBox(
                                  width: 86,
                                  child: Center(
                                    child: Text(
                                      '${(_zoom * 100).round()}%',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge,
                                    ),
                                  ),
                                ),
                                _RelationalIconButton(
                                  icon: Icons.add_rounded,
                                  onTap: () => _adjustZoom(0.05),
                                ),
                                const SizedBox(width: 6),
                                _RelationalIconButton(
                                  icon: Icons.fit_screen_outlined,
                                  onTap: _resetViewport,
                                ),
                              ],
                            ),
                          ),
                          _RelationalControlCard(
                            width: 540,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search_rounded,
                                  color: _slateColor,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (_) => setState(() {}),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText:
                                          'Search companies, contracts, employees...',
                                      isCollapsed: true,
                                    ),
                                  ),
                                ),
                                if (_searchController.text.isNotEmpty)
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                      });
                                    },
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                              ],
                            ),
                          ),
                          _RelationalControlCard(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Period:',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(width: 12),
                                for (final preset
                                    in _payload.filters.available.periodPresets)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: _RelationalPeriodChip(
                                      label: preset,
                                      selected: preset == _periodPreset,
                                      onTap: () => _setPeriodPreset(preset),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          _RelationalControlCard(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(22),
                              onTap: () {
                                setState(() {
                                  _showFilters = !_showFilters;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 16,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.filter_alt_outlined,
                                      color: _inkColor,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Filters',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 220),
                    crossFadeState: _showFilters
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Padding(
                      padding: const EdgeInsets.only(top: 24),
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
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: graphSection),
                  const SizedBox(width: 24),
                  SizedBox(width: 424, child: detailPanel),
                ],
              )
            else
              Column(
                children: [
                  graphSection,
                  const SizedBox(height: 24),
                  detailPanel,
                ],
              ),
            const SizedBox(height: 18),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final entry in legendEntries)
                      _Tag(
                        label: entry.label,
                        icon: _legendIconForState(entry.value),
                        color: _edgeColorForState(entry.value),
                        background: _edgeColorForState(
                          entry.value,
                        ).withValues(alpha: 0.12),
                      ),
                  ],
                ),
                TextButton.icon(
                  onPressed: widget.onAction,
                  icon: const Icon(Icons.reply_rounded),
                  label: Text(widget.actionLabel),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildGraphSection(
    BuildContext context, {
    required double graphWidth,
    required _RelationalNetworkView view,
    required _NetworkGraphNode? selectedNode,
  }) {
    return _Panel(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (view.nodes.isEmpty) {
            return SizedBox(
              height: 460,
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

          final cardWidth = constraints.maxWidth >= 980 ? 228.0 : 176.0;
          final cardHeight = constraints.maxWidth >= 980 ? 120.0 : 104.0;
          final layout = _RelationalCanvasLayout.compute(
            canvasWidth: max(constraints.maxWidth - 16, 760),
            laneRailWidth: constraints.maxWidth >= 980 ? 156 : 122,
            topPadding: 44,
            laneSpacing: constraints.maxWidth >= 980 ? 214 : 188,
            horizontalPadding: constraints.maxWidth >= 980 ? 26 : 18,
            cardWidth: cardWidth,
            cardHeight: cardHeight,
            payload: _payload,
            nodes: view.nodes,
          );

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
          final scaledHeight = layout.canvasHeight * max(_zoom, 1.0);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _Tag(
                    label: '${view.nodes.length} nos visiveis',
                    icon: Icons.device_hub_outlined,
                    color: _tealColor,
                    background: _tealColor.withValues(alpha: 0.12),
                  ),
                  _Tag(
                    label: '${view.edges.length} relacoes ativas no recorte',
                    icon: Icons.route_outlined,
                    color: _slateColor,
                    background: _slateColor.withValues(alpha: 0.12),
                  ),
                  if (_searchController.text.isNotEmpty)
                    _Tag(
                      label: 'busca: ${_searchController.text}',
                      icon: Icons.search_rounded,
                      color: _amberColor,
                      background: _amberColor.withValues(alpha: 0.12),
                    ),
                ],
              ),
              const SizedBox(height: 22),
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
                              laneTops: layout.laneTops,
                              cardHeight: layout.cardHeight,
                            ),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(28),
                                        gradient: RadialGradient(
                                          center: const Alignment(-0.24, -0.72),
                                          radius: 1.18,
                                          colors: [
                                            _tealColor.withValues(alpha: 0.06),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: Transform.scale(
                                      scale: _zoom,
                                      alignment: Alignment.topCenter,
                                      child: SizedBox(
                                        width: layout.contentWidth,
                                        height: layout.canvasHeight,
                                        child: Stack(
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
                                                  child:
                                                      _RelationalNetworkNodeCard(
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
                                                            _showDetailPanel =
                                                                true;
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
                          if (selectedNode != null) {
                            widget.onSelectNode(selectedNode.publicId);
                          }
                        },
                        onResetTap: _resetViewport,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailPanel(
    BuildContext context, {
    required _NetworkGraphNode? selectedNode,
    required List<_NetworkGraphNode> visibleNodes,
  }) {
    if (!_showDetailPanel) {
      return _Panel(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          height: 280,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.chevron_left_rounded,
                  size: 42,
                  color: _slateColor,
                ),
                const SizedBox(height: 14),
                Text(
                  'Painel lateral recolhido.',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Clique em um no para reabrir o detalhe.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: _mutedColor),
                ),
                const SizedBox(height: 18),
                FilledButton.tonalIcon(
                  onPressed: () {
                    setState(() {
                      _showDetailPanel = true;
                    });
                  },
                  icon: const Icon(Icons.open_in_new_outlined),
                  label: const Text('Reabrir detalhe'),
                ),
              ],
            ),
          ),
        ),
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
      payload: _payload,
      onClose: () {
        setState(() {
          _showDetailPanel = false;
        });
      },
      onSelectNode: widget.onSelectNode,
      onOpenEmployeeProfile: widget.onOpenEmployeeProfile,
      visibleNodes: visibleNodes,
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

      allowedNodes.add(node);
    }

    final allowedIds = allowedNodes.map((node) => node.publicId).toSet();
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

    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _RelationalNetworkView(
        nodes: allowedNodes,
        edges: filteredEdges,
        payload: _payload,
      );
    }

    final matchedIds = allowedNodes
        .where(
          (node) =>
              node.displayName.toLowerCase().contains(query) ||
              node.subtitle.toLowerCase().contains(query) ||
              node.badges.any((badge) => badge.toLowerCase().contains(query)),
        )
        .map((node) => node.publicId)
        .toSet();

    final visibleIds = {...matchedIds};
    for (final edge in filteredEdges) {
      if (matchedIds.contains(edge.fromPublicId) ||
          matchedIds.contains(edge.toPublicId)) {
        visibleIds.add(edge.fromPublicId);
        visibleIds.add(edge.toPublicId);
      }
    }

    final nodes = allowedNodes
        .where((node) => visibleIds.contains(node.publicId))
        .toList();
    final edges = filteredEdges
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
  }) {
    final contentWidth = canvasWidth - laneRailWidth;
    final positions = <String, Rect>{};
    final laneTops = <_NetworkGraphLane, double>{};
    var laneIndex = 0;

    for (final lane in payload.lanes) {
      final laneNodes = nodes.where((node) => node.lane == lane).toList();
      final top = topPadding + (laneIndex * laneSpacing);
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
            laneRailWidth +
            horizontalPadding +
            max(0.0, (usableWidth - occupiedWidth) / 2);

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

      laneIndex += 1;
    }

    final canvasHeight =
        topPadding +
        ((payload.lanes.length - 1) * laneSpacing) +
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
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _lineColor),
        boxShadow: [
          BoxShadow(
            color: _deepTealColor.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Icon(icon, color: _inkColor, size: 28),
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
  const _RelationalLaneRail({required this.laneTops, required this.cardHeight});

  final Map<_NetworkGraphLane, double> laneTops;
  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (final lane in _NetworkGraphLane.values)
          if (laneTops[lane] case final top?)
            Positioned(
              top: top,
              left: 0,
              right: 18,
              child: SizedBox(
                height: cardHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _laneColor(lane).withValues(alpha: 0.36),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _laneNumber(lane),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: _laneColor(lane)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _laneLabel(lane),
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: _laneColor(lane)),
                    ),
                  ],
                ),
              ),
            ),
        if (laneTops.length > 1)
          Positioned(
            top: (laneTops[_NetworkGraphLane.rootCompany] ?? 0) + 62,
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
      borderRadius: BorderRadius.circular(28),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: emphasis, width: selected ? 2.2 : 1.0),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: selected ? 26 : 20,
              offset: const Offset(0, 10),
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
                          ? 18
                          : 17,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    node.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: _mutedColor),
                  ),
                  if (node.badges.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      node.badges.first,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: laneColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
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
        width: 64,
        height: 64,
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
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: laneColor.withValues(alpha: 0.10),
        shape: BoxShape.circle,
        border: Border.all(color: laneColor.withValues(alpha: 0.24)),
      ),
      child: Icon(_iconForLane(node.lane), color: laneColor, size: 34),
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

class _RelationalNetworkDetailPanel extends StatelessWidget {
  const _RelationalNetworkDetailPanel({
    required this.node,
    required this.payload,
    required this.onClose,
    required this.onSelectNode,
    required this.onOpenEmployeeProfile,
    required this.visibleNodes,
  });

  final _NetworkGraphNode node;
  final _NetworkGraphPayload payload;
  final VoidCallback onClose;
  final ValueChanged<String> onSelectNode;
  final ValueChanged<String> onOpenEmployeeProfile;
  final List<_NetworkGraphNode> visibleNodes;

  @override
  Widget build(BuildContext context) {
    final laneColor = _laneColor(node.lane);
    final fields = _detailFieldsFor(node);
    final cta = node.detailSnapshot.cta;
    final employeeNode = node.lane == _NetworkGraphLane.employee;

    return _Panel(
      padding: const EdgeInsets.fromLTRB(26, 22, 26, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _detailTitleFor(node),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 30,
                    letterSpacing: -1.0,
                  ),
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded, size: 34),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 116,
                height: 116,
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
                            ?.copyWith(color: laneColor, fontSize: 34),
                      )
                    : Icon(_iconForLane(node.lane), color: laneColor, size: 50),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.displayName,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontSize: 28, letterSpacing: -1.1),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      node.subtitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: laneColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Tag(
                          label: _titleCase(node.status),
                          icon: Icons.circle_outlined,
                          color: laneColor,
                          background: laneColor.withValues(alpha: 0.12),
                        ),
                        for (final badge in node.badges.take(2))
                          _Tag(
                            label: badge,
                            icon: Icons.local_offer_outlined,
                            color: _slateColor,
                            background: _slateColor.withValues(alpha: 0.12),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            node.detailSnapshot.summary,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: _mutedColor),
          ),
          if (employeeNode) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFF1D8BF)),
              ),
              child: Text(
                'Os dados completos do employee saem da Visual Network e abrem na pagina de pessoas. Aqui a leitura fica restrita ao contexto relacional.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
              ),
            ),
          ],
          const SizedBox(height: 24),
          for (var index = 0; index < fields.length; index++) ...[
            _RelationalDetailRow(field: fields[index]),
            if (index < fields.length - 1) const SizedBox(height: 4),
          ],
          const SizedBox(height: 24),
          if (cta != null)
            FilledButton.tonalIcon(
              onPressed: () {
                if (employeeNode) {
                  onOpenEmployeeProfile(cta.targetPublicId);
                  return;
                }
                onSelectNode(cta.targetPublicId);
              },
              icon: Icon(
                employeeNode
                    ? Icons.person_search_outlined
                    : Icons.arrow_forward_rounded,
              ),
              label: Text(
                employeeNode ? 'Abrir ficha do colaborador' : cta.label,
              ),
            ),
          if (cta == null && employeeNode)
            FilledButton.tonalIcon(
              onPressed: () => onOpenEmployeeProfile(node.publicId),
              icon: const Icon(Icons.person_search_outlined),
              label: const Text('Abrir ficha do colaborador'),
            ),
        ],
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
            icon: Icons.timelapse_outlined,
            label: 'Status',
            value: '${extras['statusLabel'] ?? _titleCase(node.status)}',
            accent: node.status == 'active' ? _tealColor : _amberColor,
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
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _lineColor)),
      ),
      child: Row(
        children: [
          Icon(field.icon, color: _slateColor, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              field.label,
              style: Theme.of(context).textTheme.titleMedium,
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
    _NetworkGraphLane.employee => Icons.person_outline_rounded,
  };
}

String _laneLabel(_NetworkGraphLane lane) {
  return switch (lane) {
    _NetworkGraphLane.rootCompany => 'Root Companies',
    _NetworkGraphLane.clientCompany => 'Client Companies',
    _NetworkGraphLane.contract => 'Contracts',
    _NetworkGraphLane.employee => 'Employees',
  };
}

String _laneNumber(_NetworkGraphLane lane) {
  return switch (lane) {
    _NetworkGraphLane.rootCompany => '01',
    _NetworkGraphLane.clientCompany => '02',
    _NetworkGraphLane.contract => '03',
    _NetworkGraphLane.employee => '04',
  };
}

Color _laneColor(_NetworkGraphLane lane) {
  return switch (lane) {
    _NetworkGraphLane.rootCompany => const Color(0xFF2A5F86),
    _NetworkGraphLane.clientCompany => const Color(0xFF4A7F58),
    _NetworkGraphLane.contract => const Color(0xFF7B57D1),
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

Color _edgeColorForState(String state) {
  return switch (state) {
    'active' => _tealColor,
    'historical' => _amberColor,
    'indirect' => const Color(0xFF8C8C92),
    _ => _slateColor,
  };
}

IconData _legendIconForState(String state) {
  return switch (state) {
    'active' => Icons.timeline_outlined,
    'historical' => Icons.history_toggle_off_outlined,
    'indirect' => Icons.more_horiz_rounded,
    _ => Icons.device_hub_outlined,
  };
}

String _detailTitleFor(_NetworkGraphNode node) {
  return switch (node.lane) {
    _NetworkGraphLane.rootCompany => 'Root Company Details',
    _NetworkGraphLane.clientCompany => 'Client Company Details',
    _NetworkGraphLane.contract => 'Contract Details',
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
