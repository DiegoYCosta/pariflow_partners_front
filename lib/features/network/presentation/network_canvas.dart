part of '../../../app/app.dart';

class _NetworkCanvasCard extends StatefulWidget {
  const _NetworkCanvasCard({
    required this.visibleNodes,
    required this.selectedNodeId,
    required this.hoveredNodeId,
    required this.focusNodeId,
    required this.compact,
    required this.onSelectNode,
    required this.onHoverNode,
  });

  final List<_GraphNode> visibleNodes;
  final String selectedNodeId;
  final String? hoveredNodeId;
  final String focusNodeId;
  final bool compact;
  final ValueChanged<String> onSelectNode;
  final ValueChanged<String?> onHoverNode;

  @override
  State<_NetworkCanvasCard> createState() => _NetworkCanvasCardState();
}

class _NetworkCanvasCardState extends State<_NetworkCanvasCard>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformController =
      TransformationController();
  _NetworkZoomPreset _zoomPreset = _NetworkZoomPreset.overview;
  _NetworkMapControlMode _controlMode = _NetworkMapControlMode.guided;
  Size? _viewportSize;
  bool _hasInitializedViewport = false;
  double _canvasWidth = 1500.0;
  double _canvasHeight = 820.0;
  late final AnimationController _cameraController;
  Animation<Matrix4>? _cameraAnimation;

  @override
  void initState() {
    super.initState();
    _cameraController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 360),
        )..addListener(() {
          final animation = _cameraAnimation;
          if (animation != null) {
            _transformController.value = animation.value;
          }
        });
  }

  @override
  void didUpdateWidget(covariant _NetworkCanvasCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    final visibleIdsChanged =
        oldWidget.visibleNodes.map((node) => node.id).join('|') !=
        widget.visibleNodes.map((node) => node.id).join('|');

    if (visibleIdsChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _applyZoomPreset(_zoomPreset);
        }
      });
    } else if (oldWidget.selectedNodeId != widget.selectedNodeId &&
        _zoomPreset != _NetworkZoomPreset.overview) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _centerOnNode(widget.selectedNodeId);
        }
      });
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleEdges = _visibleGraphEdges(widget.visibleNodes);
    final relatedIds = _relatedNodeIds(widget.focusNodeId, visibleEdges);
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final stackedControls = viewportWidth < 960;
    final compactCanvas = viewportWidth < 760;
    final canvasWidth = widget.compact ? 1260.0 : 1500.0;
    final canvasHeight = widget.compact
        ? (compactCanvas ? 560.0 : 700.0)
        : (compactCanvas ? 680.0 : 820.0);
    _canvasWidth = canvasWidth;
    _canvasHeight = canvasHeight;
    final jumpNodes = _jumpNodes();
    final selectedLabel = _nodeLabelById(
      widget.selectedNodeId,
      widget.visibleNodes,
    );
    final isPreviewActive =
        widget.hoveredNodeId != null &&
        widget.hoveredNodeId != widget.selectedNodeId;
    final contextJumpNodes = jumpNodes
        .where(
          (node) =>
              node.id == widget.selectedNodeId || node.id == widget.focusNodeId,
        )
        .toList();
    final contextJumpIds = contextJumpNodes.map((node) => node.id).toSet();
    final companyJumpNodes = jumpNodes
        .where(
          (node) =>
              node.kind == _GraphNodeKind.company &&
              !contextJumpIds.contains(node.id),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Teia relacional', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Clique ou toque fixa a leitura. Hover apenas antecipa relacoes e o painel volta para o no selecionado ao sair.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
        ),
        const SizedBox(height: 16),
        _CanvasControlGroup(
          title: 'Legenda da malha',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  const _EdgeLegendTag(type: _GraphEdgeType.portfolio),
                  const _EdgeLegendTag(type: _GraphEdgeType.origin),
                  const _EdgeLegendTag(type: _GraphEdgeType.scope),
                  const _EdgeLegendTag(type: _GraphEdgeType.allocation),
                  const _EdgeLegendTag(type: _GraphEdgeType.dismissal),
                  const _EdgeLegendTag(type: _GraphEdgeType.history),
                  _Tag(
                    label: isPreviewActive
                        ? 'previa por hover'
                        : 'leitura fixada',
                    icon: isPreviewActive
                        ? Icons.mouse_outlined
                        : Icons.check_circle_outline_rounded,
                    color: _slateColor,
                    background: _slateColor.withValues(alpha: 0.12),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                isPreviewActive
                    ? 'A malha esta lendo uma previa temporaria. Ao sair do hover, o destaque volta para o no selecionado.'
                    : 'A leitura esta ancorada no no selecionado. Os vinculos ligados a ele ficam mais fortes no canvas.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F4EC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _lineColor),
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _CanvasOrientationStep(
                icon: Icons.ads_click_outlined,
                title: '1. Fixe um no',
                text: 'Clique ou toque para trocar o no que ancora a leitura.',
              ),
              _CanvasOrientationStep(
                icon: Icons.mouse_outlined,
                title: '2. Use hover como previa',
                text:
                    'O hover so antecipa relacoes e nao substitui a selecao fixa.',
              ),
              _CanvasOrientationStep(
                icon: Icons.tune_rounded,
                title: '3. Reenquadre abaixo',
                text:
                    'Use salto, centralizacao, zoom e presets para reposicionar a malha.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (stackedControls)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CanvasControlGroup(
                title: 'Saltos rapidos',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        PopupMenuButton<String>(
                          tooltip: 'Abrir menu de salto',
                          onSelected: (nodeId) {
                            widget.onSelectNode(nodeId);
                            _centerOnNode(nodeId);
                          },
                          itemBuilder: (context) => _buildJumpMenuItems(
                            contextJumpNodes,
                            companyJumpNodes,
                          ),
                          child: const _CanvasToolbarButton(
                            icon: Icons.travel_explore_rounded,
                            label: 'Abrir menu de salto',
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _centerOnNode(widget.focusNodeId),
                          icon: const Icon(Icons.center_focus_strong_rounded),
                          label: const Text('Centralizar leitura'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${contextJumpNodes.length} itens do contexto atual e ${companyJumpNodes.length} empresas visiveis entram neste menu.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _CanvasControlGroup(
                title: 'Zoom manual',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Afastar zoom',
                      onPressed: () => _adjustZoom(-0.08),
                      icon: const Icon(Icons.zoom_out_rounded),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'Aproximar zoom',
                      onPressed: () => _adjustZoom(0.08),
                      icon: const Icon(Icons.zoom_in_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _CanvasControlGroup(
                title: 'Mouse',
                child: SegmentedButton<_NetworkMapControlMode>(
                  segments: [
                    for (final mode in _NetworkMapControlMode.values)
                      ButtonSegment(value: mode, label: Text(mode.label)),
                  ],
                  selected: {_controlMode},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _controlMode = selection.first;
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              _CanvasControlGroup(
                title: 'Enquadramento',
                child: SegmentedButton<_NetworkZoomPreset>(
                  segments: [
                    for (final preset in _NetworkZoomPreset.values)
                      ButtonSegment(value: preset, label: Text(preset.label)),
                  ],
                  selected: {_zoomPreset},
                  onSelectionChanged: (selection) {
                    final preset = selection.first;
                    setState(() {
                      _zoomPreset = preset;
                    });
                    _applyZoomPreset(
                      preset,
                      anchorNodeId: preset == _NetworkZoomPreset.overview
                          ? null
                          : widget.focusNodeId,
                    );
                  },
                ),
              ),
            ],
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              _CanvasControlGroup(
                title: 'Saltos rapidos',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        PopupMenuButton<String>(
                          tooltip: 'Abrir menu de salto',
                          onSelected: (nodeId) {
                            widget.onSelectNode(nodeId);
                            _centerOnNode(nodeId);
                          },
                          itemBuilder: (context) => _buildJumpMenuItems(
                            contextJumpNodes,
                            companyJumpNodes,
                          ),
                          child: const _CanvasToolbarButton(
                            icon: Icons.travel_explore_rounded,
                            label: 'Abrir menu de salto',
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _centerOnNode(widget.focusNodeId),
                          icon: const Icon(Icons.center_focus_strong_rounded),
                          label: const Text('Centralizar leitura'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${contextJumpNodes.length} itens do contexto atual e ${companyJumpNodes.length} empresas visiveis entram neste menu.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
                    ),
                  ],
                ),
              ),
              _CanvasControlGroup(
                title: 'Zoom manual',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Afastar zoom',
                      onPressed: () => _adjustZoom(-0.08),
                      icon: const Icon(Icons.zoom_out_rounded),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'Aproximar zoom',
                      onPressed: () => _adjustZoom(0.08),
                      icon: const Icon(Icons.zoom_in_rounded),
                    ),
                  ],
                ),
              ),
              _CanvasControlGroup(
                title: 'Mouse',
                child: SegmentedButton<_NetworkMapControlMode>(
                  segments: [
                    for (final mode in _NetworkMapControlMode.values)
                      ButtonSegment(value: mode, label: Text(mode.label)),
                  ],
                  selected: {_controlMode},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _controlMode = selection.first;
                    });
                  },
                ),
              ),
              _CanvasControlGroup(
                title: 'Enquadramento',
                child: SegmentedButton<_NetworkZoomPreset>(
                  segments: [
                    for (final preset in _NetworkZoomPreset.values)
                      ButtonSegment(value: preset, label: Text(preset.label)),
                  ],
                  selected: {_zoomPreset},
                  onSelectionChanged: (selection) {
                    final preset = selection.first;
                    setState(() {
                      _zoomPreset = preset;
                    });
                    _applyZoomPreset(
                      preset,
                      anchorNodeId: preset == _NetworkZoomPreset.overview
                          ? null
                          : widget.focusNodeId,
                    );
                  },
                ),
              ),
            ],
          ),
        const SizedBox(height: 10),
        Text(
          _controlMode == _NetworkMapControlMode.guided
              ? 'Mouse guiado ativo: o mapa nao arrasta nem amplia sem intencao. Use os grupos acima para saltar, recentralizar e reenquadrar a leitura.'
              : 'Exploracao livre ativa: arrastar e zoom direto do mouse foram liberados para inspecao manual.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
        ),
        const SizedBox(height: 18),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: canvasHeight,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final viewportSize = Size(
                  constraints.maxWidth,
                  constraints.maxHeight,
                );
                _handleViewportSize(viewportSize, canvasWidth, canvasHeight);

                return Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFEDF5F1), Color(0xFFF8F5EE)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _lineColor),
                  ),
                  child: InteractiveViewer(
                    transformationController: _transformController,
                    boundaryMargin: const EdgeInsets.all(100),
                    minScale: 0.55,
                    maxScale: 2.35,
                    panEnabled: _controlMode == _NetworkMapControlMode.direct,
                    scaleEnabled: _controlMode == _NetworkMapControlMode.direct,
                    panAxis: PanAxis.aligned,
                    interactionEndFrictionCoefficient: 0.00008,
                    scaleFactor: 420,
                    trackpadScrollCausesScale: false,
                    constrained: false,
                    child: SizedBox(
                      width: canvasWidth,
                      height: canvasHeight,
                      child: Stack(
                        children: [
                          CustomPaint(
                            size: Size(canvasWidth, canvasHeight),
                            painter: _NetworkLinkPainter(
                              nodes: widget.visibleNodes,
                              edges: visibleEdges,
                              focusNodeId: widget.focusNodeId,
                            ),
                          ),
                          Positioned(
                            left: 18,
                            top: 18,
                            child: _CanvasHintCard(
                              selectedLabel: selectedLabel,
                              focusedLabel: _nodeLabelById(
                                widget.focusNodeId,
                                widget.visibleNodes,
                              ),
                              relatedCount: relatedIds.length,
                              isPreviewActive: isPreviewActive,
                            ),
                          ),
                          for (final node in widget.visibleNodes)
                            _NetworkNodeWidget(
                              node: node,
                              selected: node.id == widget.selectedNodeId,
                              focused: node.id == widget.focusNodeId,
                              muted:
                                  widget.focusNodeId.isNotEmpty &&
                                  node.id != widget.focusNodeId &&
                                  !relatedIds.contains(node.id),
                              parentSize: Size(canvasWidth, canvasHeight),
                              onTap: () => widget.onSelectNode(node.id),
                              onHoverChanged: widget.onHoverNode,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  List<_GraphNode> _jumpNodes() {
    final companies =
        widget.visibleNodes
            .where((node) => node.kind == _GraphNodeKind.company)
            .toList()
          ..sort((left, right) {
            if (left.isRoot != right.isRoot) {
              return left.isRoot ? -1 : 1;
            }
            return left.label.compareTo(right.label);
          });

    final nodesById = {for (final node in widget.visibleNodes) node.id: node};
    final ordered = <_GraphNode>[];
    final seen = <String>{};

    void addNode(String? nodeId) {
      if (nodeId == null ||
          seen.contains(nodeId) ||
          !nodesById.containsKey(nodeId)) {
        return;
      }
      seen.add(nodeId);
      ordered.add(nodesById[nodeId]!);
    }

    addNode(widget.selectedNodeId);
    addNode(widget.focusNodeId);
    for (final company in companies) {
      addNode(company.id);
    }

    return ordered;
  }

  List<PopupMenuEntry<String>> _buildJumpMenuItems(
    List<_GraphNode> contextNodes,
    List<_GraphNode> companyNodes,
  ) {
    final items = <PopupMenuEntry<String>>[];

    void addHeader(String label) {
      items.add(
        PopupMenuItem<String>(
          enabled: false,
          height: 32,
          child: Text(
            label,
            style: const TextStyle(
              color: _mutedColor,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    void addNodes(List<_GraphNode> nodes) {
      for (final node in nodes) {
        items.add(
          PopupMenuItem<String>(value: node.id, child: Text(_jumpLabel(node))),
        );
      }
    }

    if (contextNodes.isNotEmpty) {
      addHeader('Contexto atual');
      addNodes(contextNodes);
    }

    if (companyNodes.isNotEmpty) {
      if (items.isNotEmpty) {
        items.add(const PopupMenuDivider());
      }
      addHeader('Empresas visiveis');
      addNodes(companyNodes);
    }

    return items;
  }

  String _jumpLabel(_GraphNode node) {
    if (node.id == widget.selectedNodeId) {
      return 'Selecionado: ${node.label}';
    }
    if (node.id == widget.focusNodeId &&
        widget.focusNodeId != widget.selectedNodeId) {
      return 'Previa atual: ${node.label}';
    }
    if (node.kind == _GraphNodeKind.company) {
      return '${node.isRoot ? 'Carteira' : 'Empresa'}: ${node.label}';
    }
    return '${node.kindLabel}: ${node.label}';
  }

  void _handleViewportSize(
    Size viewportSize,
    double canvasWidth,
    double canvasHeight,
  ) {
    if (_viewportSize == viewportSize && _hasInitializedViewport) {
      return;
    }

    _viewportSize = viewportSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (!_hasInitializedViewport) {
        _applyZoomPreset(_NetworkZoomPreset.overview, animated: false);
        _hasInitializedViewport = true;
      } else {
        _applyZoomPreset(
          _zoomPreset,
          anchorNodeId: _zoomPreset == _NetworkZoomPreset.overview
              ? null
              : widget.focusNodeId,
        );
      }
    });
  }

  void _applyZoomPreset(
    _NetworkZoomPreset preset, {
    String? anchorNodeId,
    bool animated = true,
  }) {
    final viewportSize = _viewportSize;
    if (viewportSize == null) {
      return;
    }

    final fitScale = _fitScale(viewportSize, _canvasWidth, _canvasHeight);
    final targetScale = (fitScale * preset.multiplier).clamp(0.55, 2.35);

    if (preset == _NetworkZoomPreset.overview || anchorNodeId == null) {
      final translateX = (viewportSize.width - (_canvasWidth * fitScale)) / 2;
      final translateY = (viewportSize.height - (_canvasHeight * fitScale)) / 2;
      _setTransform(translateX, translateY, fitScale, animated: animated);
      return;
    }

    final target = _nodeCanvasCenter(anchorNodeId, _canvasWidth, _canvasHeight);
    final translateX = (viewportSize.width / 2) - (target.dx * targetScale);
    final translateY = (viewportSize.height / 2) - (target.dy * targetScale);

    _setTransform(translateX, translateY, targetScale, animated: animated);
  }

  void _centerOnNode(String nodeId) {
    final viewportSize = _viewportSize;
    if (viewportSize == null) {
      return;
    }

    final fitScale = _fitScale(viewportSize, _canvasWidth, _canvasHeight);
    final currentScale = _transformController.value.getMaxScaleOnAxis();
    final targetScale = currentScale < fitScale * 1.1
        ? (fitScale * 1.2).clamp(0.55, 2.35)
        : currentScale;
    final target = _nodeCanvasCenter(nodeId, _canvasWidth, _canvasHeight);
    final translateX = (viewportSize.width / 2) - (target.dx * targetScale);
    final translateY = (viewportSize.height / 2) - (target.dy * targetScale);

    _setTransform(translateX, translateY, targetScale);
  }

  void _adjustZoom(double delta) {
    final viewportSize = _viewportSize;
    if (viewportSize == null) {
      return;
    }

    final targetScale = (_transformController.value.getMaxScaleOnAxis() + delta)
        .clamp(0.55, 2.35);
    final target = _nodeCanvasCenter(
      widget.focusNodeId,
      _canvasWidth,
      _canvasHeight,
    );
    final translateX = (viewportSize.width / 2) - (target.dx * targetScale);
    final translateY = (viewportSize.height / 2) - (target.dy * targetScale);

    _setTransform(translateX, translateY, targetScale);
  }

  double _fitScale(Size viewportSize, double canvasWidth, double canvasHeight) {
    final horizontalFit = viewportSize.width / canvasWidth;
    final verticalFit = viewportSize.height / canvasHeight;
    return (horizontalFit < verticalFit ? horizontalFit : verticalFit) * 0.94;
  }

  Offset _nodeCanvasCenter(
    String nodeId,
    double canvasWidth,
    double canvasHeight,
  ) {
    final node = widget.visibleNodes.firstWhere(
      (entry) => entry.id == nodeId,
      orElse: () => widget.visibleNodes.first,
    );
    final size = _graphNodeCardSize(node);
    final normalizedX = (node.position.x + 1) / 2;
    final normalizedY = (node.position.y + 1) / 2;
    final left = (canvasWidth - size.width) * normalizedX;
    final top = (canvasHeight - size.height) * normalizedY;

    return Offset(left + (size.width / 2), top + (size.height / 2));
  }

  Matrix4 _buildTransform(double translateX, double translateY, double scale) {
    return Matrix4.diagonal3Values(scale, scale, 1)
      ..setTranslationRaw(translateX, translateY, 0);
  }

  void _setTransform(
    double translateX,
    double translateY,
    double scale, {
    bool animated = true,
  }) {
    final target = _buildTransform(translateX, translateY, scale);

    if (!animated) {
      _cameraController.stop();
      _transformController.value = target;
      return;
    }

    _cameraController.stop();
    _cameraAnimation =
        Matrix4Tween(
          begin: _transformController.value.clone(),
          end: target,
        ).animate(
          CurvedAnimation(
            parent: _cameraController,
            curve: Curves.easeInOutCubicEmphasized,
          ),
        );
    _cameraController
      ..reset()
      ..forward();
  }
}

class _NodeKindBadge extends StatelessWidget {
  const _NodeKindBadge({required this.node});

  final _GraphNode node;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: node.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        node.miniLabel,
        style: TextStyle(
          color: node.color,
          fontSize: 10,
          height: 1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _NetworkNodeWidget extends StatelessWidget {
  const _NetworkNodeWidget({
    required this.node,
    required this.selected,
    required this.focused,
    required this.muted,
    required this.parentSize,
    required this.onTap,
    required this.onHoverChanged,
  });

  final _GraphNode node;
  final bool selected;
  final bool focused;
  final bool muted;
  final Size parentSize;
  final VoidCallback onTap;
  final ValueChanged<String?> onHoverChanged;

  @override
  Widget build(BuildContext context) {
    final size = _graphNodeCardSize(node);

    final normalizedX = (node.position.x + 1) / 2;
    final normalizedY = (node.position.y + 1) / 2;
    final left = (parentSize.width - size.width) * normalizedX;
    final top = (parentSize.height - size.height) * normalizedY;

    return Positioned(
      left: left,
      top: top,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => onHoverChanged(node.id),
        onExit: (_) => onHoverChanged(null),
        child: Tooltip(
          message: '${node.label}\n${node.subtitle}',
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              opacity: muted ? 0.34 : 1,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                offset: focused
                    ? const Offset(0, -0.018)
                    : selected
                    ? const Offset(0, -0.008)
                    : Offset.zero,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  scale: focused
                      ? 1.035
                      : selected
                      ? 1.012
                      : 1,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    width: size.width,
                    height: size.height,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: focused ? node.color : _lineColor,
                        width: selected
                            ? 2.4
                            : focused
                            ? 2
                            : 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: node.color.withValues(
                            alpha: focused
                                ? 0.22
                                : selected
                                ? 0.12
                                : 0.06,
                          ),
                          blurRadius: focused
                              ? 26
                              : selected
                              ? 18
                              : 14,
                          offset: Offset(
                            0,
                            focused
                                ? 12
                                : selected
                                ? 10
                                : 8,
                          ),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: node.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                node.icon,
                                size: 15,
                                color: node.color,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                node.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: _inkColor,
                                  fontSize: 13,
                                  height: 1.15,
                                ),
                              ),
                            ),
                            if (selected || focused) ...[
                              const SizedBox(width: 6),
                              Icon(
                                selected
                                    ? Icons.check_circle_rounded
                                    : Icons.visibility_rounded,
                                size: 15,
                                color: selected ? _tealColor : _slateColor,
                              ),
                            ],
                          ],
                        ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _NodeKindBadge(node: node),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Size _graphNodeCardSize(_GraphNode node) {
  return switch (node.kind) {
    _GraphNodeKind.company =>
      node.isRoot ? const Size(194, 98) : const Size(182, 92),
    _GraphNodeKind.contract => const Size(168, 86),
    _GraphNodeKind.person => const Size(158, 84),
  };
}
