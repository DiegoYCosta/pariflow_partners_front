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
    final visibleEdges = _visibleGraphEdges(visibleNodes);
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
    final visibleCompanyCount = visibleNodes
        .where((node) => node.kind == _GraphNodeKind.company)
        .length;
    final visibleContractCount = visibleNodes
        .where((node) => node.kind == _GraphNodeKind.contract)
        .length;
    final visiblePeopleCount = visibleNodes
        .where((node) => node.kind == _GraphNodeKind.person)
        .length;
    final hiddenRootCount = filters.hiddenRootCompanyIds
        .intersection(facets.rootCompanies.map((company) => company.id).toSet())
        .length;
    final structureSummary = filters.usesCustomDismissedWindow
        ? 'janela manual de ${filters.dismissedDays} dias'
        : filters.dismissedWindowSummary;
    final hasVisibleNodes = visibleNodes.isNotEmpty;
    final sparseNetwork =
        hasVisibleNodes &&
        (visibleNodes.length <= 5 || visibleEdges.length <= 4);
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
    final advancedSummaryTags = <Widget>[
      if (activeFacetCount == 0)
        _Tag(
          label: 'sem filtros exploratorios ativos',
          icon: Icons.filter_alt_off_outlined,
          color: _slateColor,
          background: _slateColor.withValues(alpha: 0.12),
        ),
      if (effectiveSectors.isNotEmpty)
        _Tag(
          label: '${effectiveSectors.length} setores',
          icon: Icons.layers_outlined,
          color: _amberColor,
          background: _amberColor.withValues(alpha: 0.12),
        ),
      if (effectiveJobTitles.isNotEmpty)
        _Tag(
          label: '${effectiveJobTitles.length} cargos',
          icon: Icons.work_outline_rounded,
          color: _slateColor,
          background: _slateColor.withValues(alpha: 0.12),
        ),
      if (effectiveTenureBands.isNotEmpty)
        _Tag(
          label: '${effectiveTenureBands.length} faixas de tempo',
          icon: Icons.timelapse_outlined,
          color: _tealColor,
          background: _tealColor.withValues(alpha: 0.12),
        ),
      if (effectiveGenders.isNotEmpty || effectiveRaces.isNotEmpty)
        _Tag(
          label:
              '${effectiveGenders.length + effectiveRaces.length} recortes de colaborador',
          icon: Icons.badge_outlined,
          color: _roseColor,
          background: _roseColor.withValues(alpha: 0.12),
        ),
      if (filters.requireWarnings != null)
        _Tag(
          label: filters.requireWarnings!
              ? 'com advertencias'
              : 'sem advertencias',
          icon: Icons.warning_amber_rounded,
          color: _roseColor,
          background: _roseColor.withValues(alpha: 0.12),
        ),
    ];

    void clearAdvancedFilters() {
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
    }

    void showAllRootCompanies() {
      onFiltersChanged(filters.copyWith(hiddenRootCompanyIds: {}));
    }

    void restoreAllFilters() {
      onFiltersChanged(const _NetworkFilterState());
    }

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
                    label: compact ? 'preview na home' : 'workspace completo',
                    icon: compact
                        ? Icons.home_outlined
                        : Icons.open_in_full_rounded,
                    color: _slateColor,
                    background: _slateColor.withValues(alpha: 0.12),
                  ),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: _lineColor),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final stackedRecap = constraints.maxWidth < 980;
                    final recapBlocks = [
                      _NetworkRecapBlock(
                        title: 'Estrutura visivel',
                        text:
                            '$visibleCompanyCount empresas, $visibleContractCount contratos e $visiblePeopleCount pessoas sustentam a leitura atual.',
                      ),
                      _NetworkRecapBlock(
                        title: 'Recorte estrutural',
                        text:
                            'Desligados em $structureSummary. Carteiras visiveis: $visibleRootCompanies de ${facets.rootCompanies.length}${hiddenRootCount > 0 ? ' com $hiddenRootCount ocultas manualmente.' : '.'}',
                      ),
                      _NetworkRecapBlock(
                        title: 'Recorte exploratorio',
                        text: activeFacetCount > 0
                            ? '$activeFacetCount filtros avancados estao apertando a malha atual.'
                            : 'Nenhum filtro avancado esta estreitando a leitura agora.',
                      ),
                    ];

                    if (stackedRecap) {
                      return Column(
                        children: [
                          for (
                            var index = 0;
                            index < recapBlocks.length;
                            index++
                          ) ...[
                            recapBlocks[index],
                            if (index != recapBlocks.length - 1)
                              const SizedBox(height: 14),
                          ],
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var index = 0; index < recapBlocks.length; index++)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: index == recapBlocks.length - 1 ? 0 : 14,
                              ),
                              child: recapBlocks[index],
                            ),
                          ),
                      ],
                    );
                  },
                ),
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

                    final dismissedWindowSection = _NetworkInsetCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Janela de desligados',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'A barra fina de 1 a 90 dias continua aqui para leitura curta, enquanto os atalhos abrem recortes historicos maiores.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: _mutedColor),
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
                      ),
                    );

                    final companySection = _NetworkInsetCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Carteiras empresariais',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'O esconder por raiz continua estrategico: some a arvore inteira daquela carteira, com clientes, contratos e pessoas.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: _mutedColor),
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
                      ),
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
                            onPressed: clearAdvancedFilters,
                            icon: const Icon(Icons.filter_alt_off_outlined),
                            label: const Text('Limpar filtros avancados'),
                          ),
                        if (hiddenRootCount > 0)
                          TextButton.icon(
                            onPressed: showAllRootCompanies,
                            icon: const Icon(Icons.visibility_outlined),
                            label: const Text('Mostrar todas as carteiras'),
                          ),
                      ],
                    );

                    if (stackedPrimary) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Filtros estruturais',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Esses controles redefinem a estrutura minima da malha antes de qualquer recorte exploratorio.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: _mutedColor),
                          ),
                          const SizedBox(height: 14),
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
                        Text(
                          'Filtros estruturais',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Esses controles redefinem a estrutura minima da malha antes de qualquer recorte exploratorio.',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
                        ),
                        const SizedBox(height: 14),
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
                        'Filtros exploratorios da malha atual',
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
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: advancedSummaryTags,
                      ),
                      const SizedBox(height: 18),
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
                      if (facets.genders.isNotEmpty ||
                          facets.races.isNotEmpty) ...[
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
                  'O recorte atual zerou a malha',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'A combinacao atual ocultou todas as carteiras visiveis ou apertou a leitura a ponto de remover contratos e colaboradores da malha.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _Tag(
                      label: structureSummary,
                      icon: Icons.schedule_outlined,
                      color: _amberColor,
                      background: _amberColor.withValues(alpha: 0.12),
                    ),
                    if (hiddenRootCount > 0)
                      _Tag(
                        label: '$hiddenRootCount carteiras ocultas',
                        icon: Icons.visibility_off_outlined,
                        color: _slateColor,
                        background: _slateColor.withValues(alpha: 0.12),
                      ),
                    if (activeFacetCount > 0)
                      _Tag(
                        label: '$activeFacetCount filtros exploratorios ativos',
                        icon: Icons.filter_alt_outlined,
                        color: _roseColor,
                        background: _roseColor.withValues(alpha: 0.12),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: restoreAllFilters,
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('Restaurar filtros da teia'),
                    ),
                    if (activeFacetCount > 0)
                      TextButton.icon(
                        onPressed: clearAdvancedFilters,
                        icon: const Icon(Icons.filter_alt_off_outlined),
                        label: const Text('Limpar filtros exploratorios'),
                      ),
                    if (hiddenRootCount > 0)
                      TextButton.icon(
                        onPressed: showAllRootCompanies,
                        icon: const Icon(Icons.visibility_outlined),
                        label: const Text('Mostrar todas as carteiras'),
                      ),
                  ],
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              if (sparseNetwork) ...[
                _Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Leitura enxuta',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'A malha continua valida, mas este recorte deixou apenas ${visibleNodes.length} nos e ${visibleEdges.length} conexoes visiveis. Se a leitura ficou estreita demais, afrouxe primeiro os filtros exploratorios ou reabra carteiras ocultas.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _Tag(
                            label: '$visibleCompanyCount empresas',
                            icon: Icons.apartment_outlined,
                            color: _slateColor,
                            background: _slateColor.withValues(alpha: 0.12),
                          ),
                          _Tag(
                            label: '$visibleContractCount contratos',
                            icon: Icons.description_outlined,
                            color: _amberColor,
                            background: _amberColor.withValues(alpha: 0.12),
                          ),
                          _Tag(
                            label: '$visiblePeopleCount pessoas',
                            icon: Icons.badge_outlined,
                            color: _tealColor,
                            background: _tealColor.withValues(alpha: 0.12),
                          ),
                        ],
                      ),
                      if (activeFacetCount > 0 || hiddenRootCount > 0) ...[
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            if (activeFacetCount > 0)
                              TextButton.icon(
                                onPressed: clearAdvancedFilters,
                                icon: const Icon(Icons.filter_alt_off_outlined),
                                label: const Text(
                                  'Afrouxar filtros exploratorios',
                                ),
                              ),
                            if (hiddenRootCount > 0)
                              TextButton.icon(
                                onPressed: showAllRootCompanies,
                                icon: const Icon(Icons.visibility_outlined),
                                label: const Text('Reabrir carteiras ocultas'),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
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
                            selectedNodeLabel: activeSelectedNode.label,
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
                            selectedNodeLabel: activeSelectedNode.label,
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
          ),
      ],
    );
  }
}
