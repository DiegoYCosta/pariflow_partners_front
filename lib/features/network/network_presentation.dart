part of '../../app/app.dart';

enum _DismissedPeriod { sixMonths, oneYear, twoYears, fiveYears, allTime }

enum _NetworkZoomPreset { overview, reading, focus, detail }

enum _NetworkMapControlMode { guided, direct }

extension on _DismissedPeriod {
  String get label => switch (this) {
    _DismissedPeriod.sixMonths => '6 meses',
    _DismissedPeriod.oneYear => '1 ano',
    _DismissedPeriod.twoYears => '2 anos',
    _DismissedPeriod.fiveYears => '5 anos',
    _DismissedPeriod.allTime => 'todo o periodo',
  };

  String get summary => switch (this) {
    _DismissedPeriod.sixMonths => 'desligados ate 6 meses',
    _DismissedPeriod.oneYear => 'desligados ate 1 ano',
    _DismissedPeriod.twoYears => 'desligados ate 2 anos',
    _DismissedPeriod.fiveYears => 'desligados ate 5 anos',
    _DismissedPeriod.allTime => 'desligados de todo o periodo',
  };

  int? get maxDays => switch (this) {
    _DismissedPeriod.sixMonths => 183,
    _DismissedPeriod.oneYear => 365,
    _DismissedPeriod.twoYears => 730,
    _DismissedPeriod.fiveYears => 1825,
    _DismissedPeriod.allTime => null,
  };
}

extension on _NetworkZoomPreset {
  String get label => switch (this) {
    _NetworkZoomPreset.overview => 'geral',
    _NetworkZoomPreset.reading => 'leitura',
    _NetworkZoomPreset.focus => 'foco',
    _NetworkZoomPreset.detail => 'detalhe',
  };

  double get multiplier => switch (this) {
    _NetworkZoomPreset.overview => 1,
    _NetworkZoomPreset.reading => 1.12,
    _NetworkZoomPreset.focus => 1.32,
    _NetworkZoomPreset.detail => 1.56,
  };
}

extension on _NetworkMapControlMode {
  String get label => switch (this) {
    _NetworkMapControlMode.guided => 'mouse guiado',
    _NetworkMapControlMode.direct => 'explorar com mouse',
  };
}

class _NetworkFilterState {
  const _NetworkFilterState({
    this.dismissedDays = 45,
    this.dismissedPeriod,
    this.hiddenRootCompanyIds = const {},
    this.selectedSectors = const {},
    this.selectedJobTitles = const {},
    this.selectedTenureBands = const {},
    this.selectedGenders = const {},
    this.selectedRaces = const {},
    this.requireWarnings,
  });

  static const _unset = Object();

  final int dismissedDays;
  final _DismissedPeriod? dismissedPeriod;
  final Set<String> hiddenRootCompanyIds;
  final Set<String> selectedSectors;
  final Set<String> selectedJobTitles;
  final Set<String> selectedTenureBands;
  final Set<String> selectedGenders;
  final Set<String> selectedRaces;
  final bool? requireWarnings;

  bool get usesCustomDismissedWindow => dismissedPeriod == null;

  int? get maxDismissedDays => dismissedPeriod?.maxDays ?? dismissedDays;

  String get dismissedWindowLabel =>
      dismissedPeriod?.label ?? '$dismissedDays dias';

  String get dismissedWindowSummary =>
      dismissedPeriod?.summary ?? 'desligados ate $dismissedDays dias';

  _NetworkFilterState copyWith({
    int? dismissedDays,
    Object? dismissedPeriod = _unset,
    Set<String>? hiddenRootCompanyIds,
    Set<String>? selectedSectors,
    Set<String>? selectedJobTitles,
    Set<String>? selectedTenureBands,
    Set<String>? selectedGenders,
    Set<String>? selectedRaces,
    Object? requireWarnings = _unset,
  }) {
    return _NetworkFilterState(
      dismissedDays: dismissedDays ?? this.dismissedDays,
      dismissedPeriod: dismissedPeriod == _unset
          ? this.dismissedPeriod
          : dismissedPeriod as _DismissedPeriod?,
      hiddenRootCompanyIds: hiddenRootCompanyIds ?? this.hiddenRootCompanyIds,
      selectedSectors: selectedSectors ?? this.selectedSectors,
      selectedJobTitles: selectedJobTitles ?? this.selectedJobTitles,
      selectedTenureBands: selectedTenureBands ?? this.selectedTenureBands,
      selectedGenders: selectedGenders ?? this.selectedGenders,
      selectedRaces: selectedRaces ?? this.selectedRaces,
      requireWarnings: requireWarnings == _unset
          ? this.requireWarnings
          : requireWarnings as bool?,
    );
  }
}

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
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final structuralNodes = _structuralGraphNodes(filters);
    final facets = _networkFacets(structuralNodes);
    final effectiveSectors = filters.selectedSectors.intersection(
      facets.sectors.toSet(),
    );
    final effectiveJobTitles = filters.selectedJobTitles.intersection(
      facets.jobTitles.toSet(),
    );
    final effectiveTenureBands = filters.selectedTenureBands.intersection(
      facets.tenureBands.toSet(),
    );
    final effectiveGenders = filters.selectedGenders.intersection(
      facets.genders.toSet(),
    );
    final effectiveRaces = filters.selectedRaces.intersection(
      facets.races.toSet(),
    );
    final visibleNodes = _visibleGraphNodes(filters);
    final activePeopleCount = visibleNodes
        .where(
          (node) =>
              node.kind == _GraphNodeKind.person && node.status == 'ativo',
        )
        .length;
    final dismissedPeopleCount = visibleNodes
        .where(
          (node) =>
              node.kind == _GraphNodeKind.person && node.status == 'desligado',
        )
        .length;
    final visibleRootCompanies = visibleNodes
        .where((node) => node.kind == _GraphNodeKind.company && node.isRoot)
        .length;
    final activeFacetCount =
        effectiveSectors.length +
        effectiveJobTitles.length +
        effectiveTenureBands.length +
        effectiveGenders.length +
        effectiveRaces.length +
        (filters.requireWarnings == null ? 0 : 1);
    final hasVisibleNodes = visibleNodes.isNotEmpty;
    final selectedNode = hasVisibleNodes
        ? visibleNodes.firstWhere(
            (node) => node.id == selectedNodeId,
            orElse: () => visibleNodes.first,
          )
        : null;
    final focusNode = hasVisibleNodes
        ? visibleNodes.firstWhere(
            (node) => node.id == hoveredNodeId,
            orElse: () => selectedNode!,
          )
        : null;

    return Column(
      children: [
        _Panel(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 14,
                spacing: 14,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 780),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          subtitle,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(color: _mutedColor),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: onAction,
                    icon: const Icon(Icons.open_in_full_rounded),
                    label: Text(actionLabel),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _Tag(
                    label: '$activePeopleCount ativos',
                    icon: Icons.person_outline_rounded,
                    color: _tealColor,
                    background: _tealColor.withValues(alpha: 0.12),
                  ),
                  _Tag(
                    label: filters.dismissedPeriod == _DismissedPeriod.allTime
                        ? '$dismissedPeopleCount desligados no historico'
                        : '$dismissedPeopleCount desligados no recorte',
                    icon: Icons.person_off_outlined,
                    color: _roseColor,
                    background: _roseColor.withValues(alpha: 0.12),
                  ),
                  _Tag(
                    label: '$visibleRootCompanies carteiras-raiz visiveis',
                    icon: Icons.apartment_outlined,
                    color: _slateColor,
                    background: _slateColor.withValues(alpha: 0.12),
                  ),
                  if (activeFacetCount > 0)
                    _Tag(
                      label: '$activeFacetCount filtros ativos',
                      icon: Icons.filter_alt_outlined,
                      color: _amberColor,
                      background: _amberColor.withValues(alpha: 0.12),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F4EC),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: _lineColor),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final stackedPrimary = constraints.maxWidth < 980;

                    final dismissedWindowSection = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Janela de desligados',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'A barra fina de 1 a 90 dias continua aqui para leitura curta, enquanto os atalhos abrem recortes historicos maiores.',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_outlined,
                              color: _amberColor,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                filters.usesCustomDismissedWindow
                                    ? 'Janela fina ativa: desligados ate ${filters.dismissedDays} dias'
                                    : 'Atalho ativo: ${filters.dismissedWindowSummary}',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                            ),
                            Text(
                              '${filters.dismissedDays}d',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: filters.usesCustomDismissedWindow
                                        ? _amberColor
                                        : _mutedColor,
                                  ),
                            ),
                          ],
                        ),
                        Slider(
                          value: filters.dismissedDays.toDouble(),
                          min: 1,
                          max: 90,
                          divisions: 89,
                          label: '${filters.dismissedDays} dias',
                          onChanged: (value) {
                            onFiltersChanged(
                              filters.copyWith(
                                dismissedDays: value.round(),
                                dismissedPeriod: null,
                              ),
                            );
                          },
                        ),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            FilterChip(
                              label: const Text('janela 1-90 dias'),
                              selected: filters.usesCustomDismissedWindow,
                              onSelected: (_) {
                                onFiltersChanged(
                                  filters.copyWith(dismissedPeriod: null),
                                );
                              },
                            ),
                            for (final period in _DismissedPeriod.values)
                              FilterChip(
                                label: Text(period.label),
                                selected: filters.dismissedPeriod == period,
                                onSelected: (_) {
                                  onFiltersChanged(
                                    filters.copyWith(dismissedPeriod: period),
                                  );
                                },
                              ),
                          ],
                        ),
                      ],
                    );

                    final companySection = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Carteiras empresariais',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'O esconder por raiz continua estrategico: some a arvore inteira daquela carteira, com clientes, contratos e pessoas.',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final company in facets.rootCompanies)
                              FilterChip(
                                label: Text(company.label),
                                selected: !filters.hiddenRootCompanyIds
                                    .contains(company.id),
                                onSelected: (selected) {
                                  final nextHidden = {
                                    ...filters.hiddenRootCompanyIds,
                                  };
                                  if (selected) {
                                    nextHidden.remove(company.id);
                                  } else {
                                    nextHidden.add(company.id);
                                  }
                                  onFiltersChanged(
                                    filters.copyWith(
                                      hiddenRootCompanyIds: nextHidden,
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ],
                    );

                    final filterActions = Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        OutlinedButton.icon(
                          onPressed: onToggleAdvancedFilters,
                          icon: Icon(
                            showAdvancedFilters
                                ? Icons.unfold_less_rounded
                                : Icons.tune_rounded,
                          ),
                          label: Text(
                            showAdvancedFilters
                                ? 'Ocultar filtros avancados'
                                : 'Mostrar filtros avancados',
                          ),
                        ),
                        if (activeFacetCount > 0)
                          TextButton.icon(
                            onPressed: () {
                              onFiltersChanged(
                                filters.copyWith(
                                  selectedSectors: {},
                                  selectedJobTitles: {},
                                  selectedTenureBands: {},
                                  selectedGenders: {},
                                  selectedRaces: {},
                                  requireWarnings: null,
                                ),
                              );
                            },
                            icon: const Icon(Icons.filter_alt_off_outlined),
                            label: const Text('Limpar filtros avancados'),
                          ),
                      ],
                    );

                    if (stackedPrimary) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          dismissedWindowSection,
                          const SizedBox(height: 20),
                          companySection,
                          const SizedBox(height: 18),
                          filterActions,
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 7, child: dismissedWindowSection),
                            const SizedBox(width: 20),
                            Expanded(flex: 5, child: companySection),
                          ],
                        ),
                        const SizedBox(height: 18),
                        filterActions,
                      ],
                    );
                  },
                ),
              ),
              if (showAdvancedFilters) ...[
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: _lineColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filtros avancados da malha atual',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Essas facetas so aparecem porque existem no conjunto que a teia ja esta mostrando. Nada fica pregado como filtro fixo.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
                      ),
                      const SizedBox(height: 16),
                      _NetworkFilterSection(
                        title: 'Setores disponiveis',
                        subtitle:
                            'Os setores nascem dos contratos e colaboradores visiveis agora.',
                        children: [
                          for (final sector in facets.sectors)
                            FilterChip(
                              label: Text(sector),
                              selected: effectiveSectors.contains(sector),
                              onSelected: (_) {
                                onFiltersChanged(
                                  filters.copyWith(
                                    selectedSectors: _toggleValue(
                                      effectiveSectors,
                                      sector,
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                      if (facets.jobTitles.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        _NetworkFilterSection(
                          title: 'Empregos especificos',
                          subtitle:
                              'Cada cargo pode entrar ou sair da leitura sem colapsar a estrutura da teia.',
                          children: [
                            for (final jobTitle in facets.jobTitles)
                              FilterChip(
                                label: Text(jobTitle),
                                selected: effectiveJobTitles.contains(jobTitle),
                                onSelected: (_) {
                                  onFiltersChanged(
                                    filters.copyWith(
                                      selectedJobTitles: _toggleValue(
                                        effectiveJobTitles,
                                        jobTitle,
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ],
                      if (facets.tenureBands.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        _NetworkFilterSection(
                          title: 'Tempo de servico',
                          subtitle:
                              'Permite recortes por permanencia sem transformar a home num formulario enorme.',
                          children: [
                            for (final band in facets.tenureBands)
                              FilterChip(
                                label: Text(band),
                                selected: effectiveTenureBands.contains(band),
                                onSelected: (_) {
                                  onFiltersChanged(
                                    filters.copyWith(
                                      selectedTenureBands: _toggleValue(
                                        effectiveTenureBands,
                                        band,
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ],
                      if (facets.genders.isNotEmpty || facets.races.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        _NetworkFilterSection(
                          title: 'Recortes de colaborador',
                          subtitle:
                              'Sexo, raca autodeclarada e advertencias ficam disponiveis quando a teia realmente tem esses dados no resultado atual.',
                          children: [
                            for (final gender in facets.genders)
                              FilterChip(
                                label: Text(gender),
                                selected: effectiveGenders.contains(gender),
                                onSelected: (_) {
                                  onFiltersChanged(
                                    filters.copyWith(
                                      selectedGenders: _toggleValue(
                                        effectiveGenders,
                                        gender,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            for (final race in facets.races)
                              FilterChip(
                                label: Text(race),
                                selected: effectiveRaces.contains(race),
                                onSelected: (_) {
                                  onFiltersChanged(
                                    filters.copyWith(
                                      selectedRaces: _toggleValue(
                                        effectiveRaces,
                                        race,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            if (facets.hasRecordsWithWarnings)
                              FilterChip(
                                label: const Text('com advertencias'),
                                selected: filters.requireWarnings == true,
                                onSelected: (_) {
                                  onFiltersChanged(
                                    filters.copyWith(
                                      requireWarnings:
                                          filters.requireWarnings == true
                                          ? null
                                          : true,
                                    ),
                                  );
                                },
                              ),
                            if (facets.hasRecordsWithoutWarnings)
                              FilterChip(
                                label: const Text('sem advertencias'),
                                selected: filters.requireWarnings == false,
                                onSelected: (_) {
                                  onFiltersChanged(
                                    filters.copyWith(
                                      requireWarnings:
                                          filters.requireWarnings == false
                                          ? null
                                          : false,
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (!hasVisibleNodes)
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nenhum no ficou visivel',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'A combinacao atual ocultou todas as carteiras ou removeu os contratos e colaboradores da malha.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
                ),
                const SizedBox(height: 18),
                FilledButton.tonalIcon(
                  onPressed: () {
                    onFiltersChanged(const _NetworkFilterState());
                  },
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('Restaurar filtros da teia'),
                ),
              ],
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final activeSelectedNode = selectedNode!;
              final activeFocusNode = focusNode!;
              final stacked = constraints.maxWidth < 1160;

              if (stacked) {
                return Column(
                  children: [
                    _Panel(
                      child: _NetworkCanvasCard(
                        visibleNodes: visibleNodes,
                        selectedNodeId: activeSelectedNode.id,
                        hoveredNodeId: hoveredNodeId,
                        focusNodeId: activeFocusNode.id,
                        compact: compact,
                        onSelectNode: onSelectNode,
                        onHoverNode: onHoverNode,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _Panel(
                      child: _NetworkDetailCard(
                        node: activeFocusNode,
                        visibleNodes: visibleNodes,
                        isPreview:
                            hoveredNodeId != null &&
                            hoveredNodeId != activeSelectedNode.id,
                      ),
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: _Panel(
                      child: _NetworkCanvasCard(
                        visibleNodes: visibleNodes,
                        selectedNodeId: activeSelectedNode.id,
                        hoveredNodeId: hoveredNodeId,
                        focusNodeId: activeFocusNode.id,
                        compact: compact,
                        onSelectNode: onSelectNode,
                        onHoverNode: onHoverNode,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 4,
                    child: _Panel(
                      child: _NetworkDetailCard(
                        node: activeFocusNode,
                        visibleNodes: visibleNodes,
                        isPreview:
                            hoveredNodeId != null &&
                            hoveredNodeId != activeSelectedNode.id,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}

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
  late final AnimationController _cameraController;
  Animation<Matrix4>? _cameraAnimation;

  @override
  void initState() {
    super.initState();
    _cameraController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 260),
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
    final canvasWidth = widget.compact ? 1260.0 : 1500.0;
    final canvasHeight = widget.compact ? 700.0 : 820.0;
    final jumpNodes = _jumpNodes();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Teia relacional', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Clique fixa o foco. Hover previsualiza relacoes sem perder o contexto atual.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
        ),
        const SizedBox(height: 16),
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
              label: widget.hoveredNodeId == null
                  ? 'clique para fixar foco'
                  : 'hover ativo',
              icon: widget.hoveredNodeId == null
                  ? Icons.ads_click_outlined
                  : Icons.mouse_outlined,
              color: _slateColor,
              background: _slateColor.withValues(alpha: 0.12),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            PopupMenuButton<String>(
              tooltip: 'Ir para empresa ou foco',
              onSelected: (nodeId) {
                widget.onSelectNode(nodeId);
                _centerOnNode(nodeId);
              },
              itemBuilder: (context) => [
                for (final node in jumpNodes)
                  PopupMenuItem<String>(
                    value: node.id,
                    child: Text(_jumpLabel(node)),
                  ),
              ],
              child: const _CanvasToolbarButton(
                icon: Icons.travel_explore_rounded,
                label: 'Ir para empresa ou foco',
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _centerOnNode(widget.focusNodeId),
              icon: const Icon(Icons.center_focus_strong_rounded),
              label: const Text('Centralizar foco'),
            ),
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
            SegmentedButton<_NetworkMapControlMode>(
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
            SegmentedButton<_NetworkZoomPreset>(
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
          ],
        ),
        const SizedBox(height: 10),
        Text(
          _controlMode == _NetworkMapControlMode.guided
              ? 'Mouse guiado ativo: o mapa nao arrasta nem amplia sem intencao. Use os botoes e presets para navegar.'
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
                    scaleEnabled:
                        _controlMode == _NetworkMapControlMode.direct,
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
                              focusedLabel: _nodeLabelById(
                                widget.focusNodeId,
                                widget.visibleNodes,
                              ),
                              relatedCount: relatedIds.length,
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

  String _jumpLabel(_GraphNode node) {
    if (node.id == widget.selectedNodeId) {
      return 'Selecionado: ${node.label}';
    }
    if (node.id == widget.focusNodeId) {
      return 'Foco atual: ${node.label}';
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

    final canvasWidth = widget.compact ? 1260.0 : 1500.0;
    final canvasHeight = widget.compact ? 700.0 : 820.0;
    final fitScale = _fitScale(viewportSize, canvasWidth, canvasHeight);
    final targetScale = (fitScale * preset.multiplier).clamp(0.55, 2.35);

    if (preset == _NetworkZoomPreset.overview || anchorNodeId == null) {
      final translateX = (viewportSize.width - (canvasWidth * fitScale)) / 2;
      final translateY = (viewportSize.height - (canvasHeight * fitScale)) / 2;
      _setTransform(translateX, translateY, fitScale, animated: animated);
      return;
    }

    final target = _nodeCanvasCenter(anchorNodeId, canvasWidth, canvasHeight);
    final translateX = (viewportSize.width / 2) - (target.dx * targetScale);
    final translateY = (viewportSize.height / 2) - (target.dy * targetScale);

    _setTransform(translateX, translateY, targetScale, animated: animated);
  }

  void _centerOnNode(String nodeId) {
    final viewportSize = _viewportSize;
    if (viewportSize == null) {
      return;
    }

    final canvasWidth = widget.compact ? 1260.0 : 1500.0;
    final canvasHeight = widget.compact ? 700.0 : 820.0;
    final fitScale = _fitScale(viewportSize, canvasWidth, canvasHeight);
    final currentScale = _transformController.value.getMaxScaleOnAxis();
    final targetScale = currentScale < fitScale * 1.1
        ? (fitScale * 1.2).clamp(0.55, 2.35)
        : currentScale;
    final target = _nodeCanvasCenter(nodeId, canvasWidth, canvasHeight);
    final translateX = (viewportSize.width / 2) - (target.dx * targetScale);
    final translateY = (viewportSize.height / 2) - (target.dy * targetScale);

    _setTransform(translateX, translateY, targetScale);
  }

  void _adjustZoom(double delta) {
    final viewportSize = _viewportSize;
    if (viewportSize == null) {
      return;
    }

    final canvasWidth = widget.compact ? 1260.0 : 1500.0;
    final canvasHeight = widget.compact ? 700.0 : 820.0;
    final targetScale = (_transformController.value.getMaxScaleOnAxis() + delta)
        .clamp(0.55, 2.35);
    final target = _nodeCanvasCenter(
      widget.focusNodeId,
      canvasWidth,
      canvasHeight,
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
            curve: Curves.easeOutCubic,
          ),
        );
    _cameraController
      ..reset()
      ..forward();
  }
}

class _NetworkDetailCard extends StatelessWidget {
  const _NetworkDetailCard({
    required this.node,
    required this.visibleNodes,
    required this.isPreview,
  });

  final _GraphNode node;
  final List<_GraphNode> visibleNodes;
  final bool isPreview;

  @override
  Widget build(BuildContext context) {
    final connections = _connectionDetailsForNode(node.id, visibleNodes);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Foco da teia', style: theme.textTheme.titleLarge),
            _Tag(
              label: node.kindLabel,
              icon: node.icon,
              color: node.color,
              background: node.color.withValues(alpha: 0.12),
            ),
            if (isPreview)
              _Tag(
                label: 'pre-visualizacao',
                icon: Icons.mouse_outlined,
                color: _slateColor,
                background: _slateColor.withValues(alpha: 0.12),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Text(node.label, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          node.subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(color: _mutedColor),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Tag(
              label: node.status,
              icon: _statusIconForNode(node),
              color: node.color,
              background: node.color.withValues(alpha: 0.12),
            ),
            _Tag(
              label: '${connections.length} relacoes visiveis',
              icon: Icons.route_outlined,
              color: _slateColor,
              background: _slateColor.withValues(alpha: 0.12),
            ),
            if (node.sector != null)
              _Tag(
                label: node.sector!,
                icon: Icons.layers_outlined,
                color: _amberColor,
                background: _amberColor.withValues(alpha: 0.12),
              ),
            if (node.jobTitle != null)
              _Tag(
                label: node.jobTitle!,
                icon: Icons.work_outline_rounded,
                color: _slateColor,
                background: _slateColor.withValues(alpha: 0.12),
              ),
            if (node.tenureBand != null)
              _Tag(
                label: node.tenureBand!,
                icon: Icons.timelapse_outlined,
                color: _tealColor,
                background: _tealColor.withValues(alpha: 0.12),
              ),
            if (node.hasWarnings)
              _Tag(
                label: 'com advertencias',
                icon: Icons.warning_amber_rounded,
                color: _roseColor,
                background: _roseColor.withValues(alpha: 0.12),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F1E7),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _lineColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Leitura imediata', style: theme.textTheme.titleMedium),
              const SizedBox(height: 10),
              for (final bullet in node.highlights)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: node.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          bullet,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _inkColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text('Relacionamentos visiveis', style: theme.textTheme.titleMedium),
        const SizedBox(height: 10),
        for (final connection in connections)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _lineColor),
            ),
            child: Row(
              children: [
                Icon(connection.node.icon, color: connection.node.color),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            connection.node.label,
                            style: theme.textTheme.labelLarge,
                          ),
                          _CompactRelationPill(type: connection.edge.type),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        connection.edge.detail,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _mutedColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _NetworkFilterSection extends StatelessWidget {
  const _NetworkFilterSection({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 10, runSpacing: 10, children: children),
      ],
    );
  }
}

class _CompactRelationPill extends StatelessWidget {
  const _CompactRelationPill({required this.type});

  final _GraphEdgeType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: type.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        type.label,
        style: TextStyle(
          color: type.color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

Set<String> _toggleValue(Set<String> values, String value) {
  final next = {...values};
  if (next.contains(value)) {
    next.remove(value);
  } else {
    next.add(value);
  }
  return next;
}

class _EdgeLegendTag extends StatelessWidget {
  const _EdgeLegendTag({required this.type});

  final _GraphEdgeType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: type.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: type.color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (type.dashed)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++)
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(right: 3),
                    decoration: BoxDecoration(
                      color: type.color,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            )
          else
            Container(
              width: 18,
              height: 0,
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: type.color, width: 2.4)),
              ),
            ),
          const SizedBox(width: 8),
          Text(
            type.label,
            style: TextStyle(color: type.color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _CanvasHintCard extends StatelessWidget {
  const _CanvasHintCard({
    required this.focusedLabel,
    required this.relatedCount,
  });

  final String focusedLabel;
  final int relatedCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _lineColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Foco atual',
            style: TextStyle(
              color: _mutedColor,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            focusedLabel,
            style: const TextStyle(
              color: _inkColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$relatedCount nos ligados em destaque',
            style: const TextStyle(color: _mutedColor, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _CanvasToolbarButton extends StatelessWidget {
  const _CanvasToolbarButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _lineColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: _slateColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: _inkColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
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
              duration: const Duration(milliseconds: 160),
              opacity: muted ? 0.34 : 1,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 180),
                scale: focused ? 1.03 : 1,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
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
                          alpha: focused ? 0.2 : 0.06,
                        ),
                        blurRadius: focused ? 22 : 14,
                        offset: const Offset(0, 8),
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
                            child: Icon(node.icon, size: 15, color: node.color),
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

class _NetworkLinkPainter extends CustomPainter {
  _NetworkLinkPainter({
    required this.nodes,
    required this.edges,
    required this.focusNodeId,
  });

  final List<_GraphNode> nodes;
  final List<_GraphEdge> edges;
  final String focusNodeId;

  @override
  void paint(Canvas canvas, Size size) {
    final positions = <String, Offset>{};

    for (final node in nodes) {
      final nodeSize = _graphNodeCardSize(node);
      final normalizedX = (node.position.x + 1) / 2;
      final normalizedY = (node.position.y + 1) / 2;
      positions[node.id] = Offset(
        (size.width - nodeSize.width) * normalizedX + (nodeSize.width / 2),
        (size.height - nodeSize.height) * normalizedY + (nodeSize.height / 2),
      );
    }

    final relatedIds = _relatedNodeIds(focusNodeId, edges);

    for (final edge in edges) {
      final from = positions[edge.from];
      final to = positions[edge.to];
      if (from == null || to == null) {
        continue;
      }

      final isFocusedConnection =
          edge.from == focusNodeId || edge.to == focusNodeId;

      final controlX = (from.dx + to.dx) / 2;
      final path = Path()
        ..moveTo(from.dx, from.dy)
        ..quadraticBezierTo(controlX, (from.dy + to.dy) / 2, to.dx, to.dy);

      final strokePaint = Paint()
        ..color = edge.type.color.withValues(
          alpha: isFocusedConnection
              ? 0.72
              : relatedIds.isEmpty
              ? 0.22
              : 0.12,
        )
        ..strokeWidth = isFocusedConnection ? 3.2 : 2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      if (edge.type.dashed) {
        _drawDashedPath(canvas, path, strokePaint);
      } else {
        canvas.drawPath(path, strokePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _NetworkLinkPainter oldDelegate) {
    return oldDelegate.focusNodeId != focusNodeId ||
        oldDelegate.nodes != nodes ||
        oldDelegate.edges != edges;
  }
}
