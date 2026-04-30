import 'package:flutter/material.dart';

const _canvasColor = Color(0xFFF4EFE6);
const _paperColor = Color(0xFFFFFCF7);
const _lineColor = Color(0xFFE3D9CB);
const _inkColor = Color(0xFF182521);
const _mutedColor = Color(0xFF64736D);
const _tealColor = Color(0xFF0F766E);
const _deepTealColor = Color(0xFF143C38);
const _amberColor = Color(0xFFBF6B2D);
const _roseColor = Color(0xFFA35252);
const _slateColor = Color(0xFF536A75);

void main() {
  runApp(const PariFlowPartnersApp());
}

class PariFlowPartnersApp extends StatelessWidget {
  const PariFlowPartnersApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _tealColor,
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'PariFlow Partners',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme.copyWith(
          primary: _tealColor,
          onPrimary: Colors.white,
          secondary: _amberColor,
          onSecondary: Colors.white,
          surface: _paperColor,
          onSurface: _inkColor,
          outline: const Color(0xFF9AA9A2),
        ),
        scaffoldBackgroundColor: _canvasColor,
        textTheme: const TextTheme(
          displaySmall: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.1,
            height: 1.05,
            color: _inkColor,
          ),
          headlineSmall: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
            color: _inkColor,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _inkColor,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _inkColor,
          ),
          bodyLarge: TextStyle(fontSize: 16, height: 1.55, color: _inkColor),
          bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: _inkColor),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _inkColor,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            color: _inkColor,
          ),
        ),
      ),
      home: const LayoutPreviewPage(),
    );
  }
}

enum _Destination { home, companies, contracts, people, network }

enum _HomeMode { overview, network }

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

class LayoutPreviewPage extends StatefulWidget {
  const LayoutPreviewPage({super.key});

  @override
  State<LayoutPreviewPage> createState() => _LayoutPreviewPageState();
}

class _LayoutPreviewPageState extends State<LayoutPreviewPage> {
  _Destination _destination = _Destination.home;
  _HomeMode _homeMode = _HomeMode.overview;
  _NetworkFilterState _networkFilters = const _NetworkFilterState();
  bool _showAdvancedNetworkFilters = false;
  String _selectedNetworkNodeId = 'person_ana';
  String? _hoveredNetworkNodeId;
  final Map<_Destination, int> _selectedItemIndex = {
    _Destination.companies: 0,
    _Destination.contracts: 0,
    _Destination.people: 0,
  };

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final showSidebar = width >= 1120;
    final page = _pageInfo[_destination]!;

    return Scaffold(
      drawer: showSidebar
          ? null
          : Drawer(
              backgroundColor: _deepTealColor,
              child: SafeArea(
                child: _AppSidebar(
                  current: _destination,
                  onSelect: _handleDestination,
                ),
              ),
            ),
      bottomNavigationBar: showSidebar
          ? null
          : NavigationBar(
              selectedIndex: _Destination.values.indexOf(_destination),
              onDestinationSelected: (index) {
                _handleDestination(_Destination.values[index]);
              },
              backgroundColor: _paperColor,
              indicatorColor: page.accent.withValues(alpha: 0.14),
              destinations: [
                for (final item in _pageInfo.values)
                  NavigationDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.icon, color: page.accent),
                    label: item.shortLabel,
                  ),
              ],
            ),
      body: SafeArea(
        child: Row(
          children: [
            if (showSidebar)
              Container(
                width: 252,
                color: _deepTealColor,
                child: _AppSidebar(
                  current: _destination,
                  onSelect: _handleDestination,
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  showSidebar ? 30 : 18,
                  18,
                  showSidebar ? 30 : 18,
                  showSidebar ? 30 : 104,
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1420),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TopBar(page: page, showMenuButton: !showSidebar),
                        const SizedBox(height: 24),
                        _buildContent(page, width),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(_PageInfo page, double width) {
    switch (_destination) {
      case _Destination.home:
        return _HomeContent(
          mode: _homeMode,
          filters: _networkFilters,
          showAdvancedFilters: _showAdvancedNetworkFilters,
          selectedNodeId: _selectedNetworkNodeId,
          hoveredNodeId: _hoveredNetworkNodeId,
          onChangeMode: (mode) {
            setState(() {
              _homeMode = mode;
            });
          },
          onFiltersChanged: (filters) {
            setState(() {
              _networkFilters = filters;
            });
          },
          onToggleAdvancedFilters: () {
            setState(() {
              _showAdvancedNetworkFilters = !_showAdvancedNetworkFilters;
            });
          },
          onSelectNode: _handleNetworkNodeSelection,
          onHoverNode: _handleNetworkNodeHover,
          onChooseDestination: _handleChoice,
          onOpenFullNetwork: () {
            setState(() {
              _destination = _Destination.network;
            });
          },
          pageWidth: width,
        );
      case _Destination.network:
        return _NetworkWorkspace(
          title: page.title,
          subtitle: page.description,
          filters: _networkFilters,
          showAdvancedFilters: _showAdvancedNetworkFilters,
          selectedNodeId: _selectedNetworkNodeId,
          hoveredNodeId: _hoveredNetworkNodeId,
          compact: false,
          onFiltersChanged: (filters) {
            setState(() {
              _networkFilters = filters;
            });
          },
          onToggleAdvancedFilters: () {
            setState(() {
              _showAdvancedNetworkFilters = !_showAdvancedNetworkFilters;
            });
          },
          onSelectNode: _handleNetworkNodeSelection,
          onHoverNode: _handleNetworkNodeHover,
          actionLabel: 'Mostrar na primeira pagina',
          onAction: () {
            setState(() {
              _destination = _Destination.home;
              _homeMode = _HomeMode.network;
            });
          },
        );
      case _Destination.companies:
      case _Destination.contracts:
      case _Destination.people:
        final data = _entityData[_destination]!;
        final selectedIndex = _selectedItemIndex[_destination] ?? 0;
        return _EntityWorkspace(
          data: data,
          selectedIndex: selectedIndex,
          onSelectItem: (index) {
            setState(() {
              _selectedItemIndex[_destination] = index;
            });
          },
        );
    }
  }

  void _handleDestination(_Destination destination) {
    setState(() {
      _destination = destination;
      if (destination == _Destination.network) {
        _homeMode = _HomeMode.network;
      }
    });
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _handleChoice(_ChoiceTarget target) {
    switch (target) {
      case _ChoiceTarget.companies:
        _handleDestination(_Destination.companies);
        return;
      case _ChoiceTarget.contracts:
        _handleDestination(_Destination.contracts);
        return;
      case _ChoiceTarget.people:
        _handleDestination(_Destination.people);
        return;
      case _ChoiceTarget.network:
        setState(() {
          _destination = _Destination.home;
          _homeMode = _HomeMode.network;
        });
        return;
    }
  }

  void _handleNetworkNodeSelection(String nodeId) {
    setState(() {
      _selectedNetworkNodeId = nodeId;
      _hoveredNetworkNodeId = null;
    });
  }

  void _handleNetworkNodeHover(String? nodeId) {
    setState(() {
      _hoveredNetworkNodeId = nodeId;
    });
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.page, required this.showMenuButton});

  final _PageInfo page;
  final bool showMenuButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Builder(
      builder: (context) {
        return Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 14,
          spacing: 14,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                if (showMenuButton)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: IconButton.filledTonal(
                      onPressed: Scaffold.of(context).openDrawer,
                      icon: const Icon(Icons.menu_rounded),
                    ),
                  ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PariFlow Partners',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge,
                      ),
                      Text(
                        page.kicker,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _mutedColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _Tag(
                  label: 'layout inicial',
                  icon: Icons.space_dashboard_outlined,
                  color: _slateColor,
                  background: Colors.white,
                ),
                _Tag(
                  label: 'sessao privilegiada',
                  icon: Icons.security_outlined,
                  color: page.accent,
                  background: page.accent.withValues(alpha: 0.12),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: _lineColor),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: _deepTealColor,
                        child: Text(
                          'DC',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Diego Costa',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'admin | traceavel',
                            style: TextStyle(color: _mutedColor, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _AppSidebar extends StatelessWidget {
  const _AppSidebar({required this.current, required this.onSelect});

  final _Destination current;
  final ValueChanged<_Destination> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PariFlow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Home mais limpa, escolha objetiva e espaco reservado para a teia relacional.',
                  style: TextStyle(color: Color(0xFFD1E0DB), height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Entradas principais',
            style: TextStyle(
              color: Color(0xFFA9C1BA),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: _pageInfo.length,
              separatorBuilder: (_, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = _pageInfo.values.elementAt(index);
                final selected = item.destination == current;
                return InkWell(
                  onTap: () => onSelect(item.destination),
                  borderRadius: BorderRadius.circular(22),
                  child: Ink(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: selected
                            ? Colors.white.withValues(alpha: 0.18)
                            : Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: selected
                                ? item.accent.withValues(alpha: 0.22)
                                : Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(item.icon, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.shortLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.sidebarHint,
                                style: const TextStyle(
                                  color: Color(0xFFD0DFDA),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF0E2E2A),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crescimento previsto',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Dossie, auditoria e relatorios entram depois, mas nao precisam poluir a home inicial.',
                  style: TextStyle(color: Color(0xFFC9D9D4), height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.mode,
    required this.filters,
    required this.showAdvancedFilters,
    required this.selectedNodeId,
    required this.hoveredNodeId,
    required this.onChangeMode,
    required this.onFiltersChanged,
    required this.onToggleAdvancedFilters,
    required this.onSelectNode,
    required this.onHoverNode,
    required this.onChooseDestination,
    required this.onOpenFullNetwork,
    required this.pageWidth,
  });

  final _HomeMode mode;
  final _NetworkFilterState filters;
  final bool showAdvancedFilters;
  final String selectedNodeId;
  final String? hoveredNodeId;
  final ValueChanged<_HomeMode> onChangeMode;
  final ValueChanged<_NetworkFilterState> onFiltersChanged;
  final VoidCallback onToggleAdvancedFilters;
  final ValueChanged<String> onSelectNode;
  final ValueChanged<String?> onHoverNode;
  final ValueChanged<_ChoiceTarget> onChooseDestination;
  final VoidCallback onOpenFullNetwork;
  final double pageWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ChoiceHero(
          mode: mode,
          onChangeMode: onChangeMode,
          onChooseDestination: onChooseDestination,
        ),
        const SizedBox(height: 24),
        if (mode == _HomeMode.overview)
          _HomeOverview(
            onChooseDestination: onChooseDestination,
            pageWidth: pageWidth,
          )
        else
          _NetworkWorkspace(
            title: 'Teia relacional na primeira pagina',
            subtitle:
                'O usuario pode abrir a teia aqui mesmo para enxergar carteiras, clientes e historico antes de decidir o proximo clique.',
            filters: filters,
            showAdvancedFilters: showAdvancedFilters,
            selectedNodeId: selectedNodeId,
            hoveredNodeId: hoveredNodeId,
            compact: true,
            onFiltersChanged: onFiltersChanged,
            onToggleAdvancedFilters: onToggleAdvancedFilters,
            onSelectNode: onSelectNode,
            onHoverNode: onHoverNode,
            actionLabel: 'Abrir em tela focada',
            onAction: onOpenFullNetwork,
          ),
      ],
    );
  }
}

class _ChoiceHero extends StatelessWidget {
  const _ChoiceHero({
    required this.mode,
    required this.onChangeMode,
    required this.onChooseDestination,
  });

  final _HomeMode mode;
  final ValueChanged<_HomeMode> onChangeMode;
  final ValueChanged<_ChoiceTarget> onChooseDestination;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _Panel(
      padding: const EdgeInsets.all(28),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 1040;

          final intro = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _deepTealColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'home guiada por escolha',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Escolha por onde comecar.',
                style: theme.textTheme.displaySmall,
              ),
              const SizedBox(height: 12),
              Text(
                'A primeira pagina deixa o usuario decidir se quer consultar empresas, contratos, funcionarios ou abrir a teia relacional. O resto fica guardado em workspaces mais focados.',
                style: theme.textTheme.bodyLarge?.copyWith(color: _mutedColor),
              ),
              const SizedBox(height: 22),
              SegmentedButton<_HomeMode>(
                segments: const [
                  ButtonSegment(
                    value: _HomeMode.overview,
                    icon: Icon(Icons.space_dashboard_outlined),
                    label: Text('Resumo'),
                  ),
                  ButtonSegment(
                    value: _HomeMode.network,
                    icon: Icon(Icons.hub_outlined),
                    label: Text('Teia'),
                  ),
                ],
                selected: {mode},
                onSelectionChanged: (selection) {
                  onChangeMode(selection.first);
                },
              ),
            ],
          );

          final choices = _ChoiceGrid(onChooseDestination: onChooseDestination);

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [intro, const SizedBox(height: 24), choices],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: intro),
              const SizedBox(width: 24),
              Expanded(flex: 6, child: choices),
            ],
          );
        },
      ),
    );
  }
}

class _ChoiceGrid extends StatelessWidget {
  const _ChoiceGrid({required this.onChooseDestination});

  final ValueChanged<_ChoiceTarget> onChooseDestination;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        for (final choice in _choices)
          SizedBox(
            width: 260,
            child: _ChoiceCard(
              choice: choice,
              onTap: () => onChooseDestination(choice.target),
            ),
          ),
      ],
    );
  }
}

class _HomeOverview extends StatelessWidget {
  const _HomeOverview({
    required this.onChooseDestination,
    required this.pageWidth,
  });

  final ValueChanged<_ChoiceTarget> onChooseDestination;
  final double pageWidth;

  @override
  Widget build(BuildContext context) {
    final twoColumns = pageWidth >= 1180;

    return Column(
      children: [
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: _summaryCards
              .map(
                (card) => SizedBox(
                  width: pageWidth >= 1340
                      ? 314
                      : pageWidth >= 880
                      ? 260
                      : double.infinity,
                  child: _SummaryCard(card: card),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
        if (twoColumns)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: _Panel(
                  child: _ResumeList(onChooseDestination: onChooseDestination),
                ),
              ),
              const SizedBox(width: 24),
              const Expanded(
                flex: 4,
                child: _Panel(child: _AccessContextPanel()),
              ),
            ],
          )
        else
          const Column(
            children: [
              _Panel(child: _AccessContextPanel()),
              SizedBox(height: 24),
            ],
          ),
        if (!twoColumns)
          _Panel(child: _ResumeList(onChooseDestination: onChooseDestination)),
      ],
    );
  }
}

class _ResumeList extends StatelessWidget {
  const _ResumeList({required this.onChooseDestination});

  final ValueChanged<_ChoiceTarget> onChooseDestination;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Retomar do ponto certo', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Os proximos passos ficam concentrados em uma fila curta. Sem excesso de cards concorrendo pela atencao.',
          style: theme.textTheme.bodyMedium?.copyWith(color: _mutedColor),
        ),
        const SizedBox(height: 20),
        for (final item in _resumeItems)
          _ResumeTile(
            item: item,
            onTap: () => onChooseDestination(item.target),
          ),
      ],
    );
  }
}

class _AccessContextPanel extends StatelessWidget {
  const _AccessContextPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acesso e criterio de exibicao',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'A home fica mais calma porque dossie, auditoria e conteudo sensivel nao ocupam o centro o tempo todo. Eles aparecem no momento certo.',
          style: theme.textTheme.bodyMedium?.copyWith(color: _mutedColor),
        ),
        const SizedBox(height: 18),
        const _ContextBullet(
          icon: Icons.visibility_off_outlined,
          title: 'Mascaramento parcial',
          text:
              'Dados sensiveis nao precisam ficar escancarados na primeira leitura.',
          color: _amberColor,
        ),
        const SizedBox(height: 12),
        const _ContextBullet(
          icon: Icons.route_outlined,
          title: 'Entrada por intencao',
          text:
              'O usuario primeiro escolhe o caminho, depois aprofunda no workspace correto.',
          color: _tealColor,
        ),
        const SizedBox(height: 12),
        const _ContextBullet(
          icon: Icons.history_toggle_off_outlined,
          title: 'Teia opcional',
          text:
              'A visao relacional pode ser aberta logo na home, mas nao domina a experiencia se nao for necessaria.',
          color: _roseColor,
        ),
      ],
    );
  }
}

class _EntityWorkspace extends StatelessWidget {
  const _EntityWorkspace({
    required this.data,
    required this.selectedIndex,
    required this.onSelectItem,
  });

  final _EntityWorkspaceData data;
  final int selectedIndex;
  final ValueChanged<int> onSelectItem;

  @override
  Widget build(BuildContext context) {
    final selectedItem = data.items[selectedIndex];

    return Column(
      children: [
        _Panel(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.title, style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 12),
              Text(
                data.subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: _mutedColor),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _Tag(
                    label: data.searchHint,
                    icon: Icons.search_rounded,
                    color: _mutedColor,
                    background: const Color(0xFFF4EEE5),
                  ),
                  for (final filter in data.filters)
                    _Tag(
                      label: filter,
                      icon: Icons.tune_outlined,
                      color: data.accent,
                      background: data.accent.withValues(alpha: 0.12),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 1120;

            if (stacked) {
              return Column(
                children: [
                  _Panel(
                    child: _EntityListCard(
                      data: data,
                      selectedIndex: selectedIndex,
                      onSelectItem: onSelectItem,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _Panel(child: _EntityDetailCard(item: selectedItem)),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: _Panel(
                    child: _EntityListCard(
                      data: data,
                      selectedIndex: selectedIndex,
                      onSelectItem: onSelectItem,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 5,
                  child: _Panel(child: _EntityDetailCard(item: selectedItem)),
                ),
              ],
            );
          },
        ),
      ],
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

class _EntityListCard extends StatelessWidget {
  const _EntityListCard({
    required this.data,
    required this.selectedIndex,
    required this.onSelectItem,
  });

  final _EntityWorkspaceData data;
  final int selectedIndex;
  final ValueChanged<int> onSelectItem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lista guiada', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          data.listHint,
          style: theme.textTheme.bodyMedium?.copyWith(color: _mutedColor),
        ),
        const SizedBox(height: 18),
        for (final entry in data.items.indexed)
          _EntityListTile(
            item: entry.$2,
            selected: entry.$1 == selectedIndex,
            onTap: () => onSelectItem(entry.$1),
          ),
      ],
    );
  }
}

class _EntityDetailCard extends StatelessWidget {
  const _EntityDetailCard({required this.item});

  final _EntityItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Preview do detalhe', style: theme.textTheme.titleLarge),
            _Tag(
              label: item.status,
              icon: item.icon,
              color: item.color,
              background: item.color.withValues(alpha: 0.12),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(item.title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          item.subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(color: _mutedColor),
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
              Text(
                'Por que esta tela existe',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Text(
                item.detailSummary,
                style: theme.textTheme.bodyMedium?.copyWith(color: _inkColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text('Relacoes principais', style: theme.textTheme.titleMedium),
        const SizedBox(height: 10),
        for (final relation in item.relations)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _lineColor),
            ),
            child: Text(
              relation,
              style: theme.textTheme.bodyMedium?.copyWith(color: _inkColor),
            ),
          ),
      ],
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({required this.choice, required this.onTap});

  final _ChoiceCardData choice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: choice.background,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: choice.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: choice.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(choice.icon, color: choice.color),
            ),
            const SizedBox(height: 18),
            Text(choice.title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              choice.description,
              style: theme.textTheme.bodyMedium?.copyWith(color: _mutedColor),
            ),
            const SizedBox(height: 16),
            Text(
              choice.hint,
              style: theme.textTheme.labelMedium?.copyWith(color: choice.color),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.card});

  final _SummaryCardData card;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _Panel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Tag(
            label: card.label,
            icon: card.icon,
            color: card.color,
            background: card.color.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 14),
          Text(card.value, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            card.description,
            style: theme.textTheme.bodyMedium?.copyWith(color: _mutedColor),
          ),
        ],
      ),
    );
  }
}

class _ResumeTile extends StatelessWidget {
  const _ResumeTile({required this.item, required this.onTap});

  final _ResumeItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _lineColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(item.icon, color: item.color),
        ),
        title: Text(item.title, style: theme.textTheme.titleMedium),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            item.description,
            style: theme.textTheme.bodyMedium?.copyWith(color: _mutedColor),
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

class _ContextBullet extends StatelessWidget {
  const _ContextBullet({
    required this.icon,
    required this.title,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(color: _mutedColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EntityListTile extends StatelessWidget {
  const _EntityListTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _EntityItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: selected ? item.color.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: selected ? item.color : _lineColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(item.title, style: theme.textTheme.titleMedium),
                  _Tag(
                    label: item.status,
                    icon: item.icon,
                    color: item.color,
                    background: item.color.withValues(alpha: 0.12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(color: _mutedColor),
              ),
              const SizedBox(height: 10),
              Text(
                item.meta,
                style: theme.textTheme.labelMedium?.copyWith(color: item.color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.padding = const EdgeInsets.all(24)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _paperColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _lineColor),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF231C10).withValues(alpha: 0.04),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
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

class _PageInfo {
  const _PageInfo({
    required this.destination,
    required this.shortLabel,
    required this.title,
    required this.description,
    required this.kicker,
    required this.sidebarHint,
    required this.icon,
    required this.accent,
  });

  final _Destination destination;
  final String shortLabel;
  final String title;
  final String description;
  final String kicker;
  final String sidebarHint;
  final IconData icon;
  final Color accent;
}

class _ChoiceCardData {
  const _ChoiceCardData({
    required this.target,
    required this.title,
    required this.description,
    required this.hint,
    required this.icon,
    required this.color,
    required this.background,
    required this.borderColor,
  });

  final _ChoiceTarget target;
  final String title;
  final String description;
  final String hint;
  final IconData icon;
  final Color color;
  final Color background;
  final Color borderColor;
}

enum _ChoiceTarget { companies, contracts, people, network }

class _SummaryCardData {
  const _SummaryCardData({
    required this.label,
    required this.value,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String description;
  final IconData icon;
  final Color color;
}

class _ResumeItem {
  const _ResumeItem({
    required this.target,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final _ChoiceTarget target;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
}

class _EntityWorkspaceData {
  const _EntityWorkspaceData({
    required this.title,
    required this.subtitle,
    required this.searchHint,
    required this.listHint,
    required this.filters,
    required this.items,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final String searchHint;
  final String listHint;
  final List<String> filters;
  final List<_EntityItem> items;
  final Color accent;
}

class _EntityItem {
  const _EntityItem({
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.status,
    required this.icon,
    required this.color,
    required this.detailSummary,
    required this.relations,
  });

  final String title;
  final String subtitle;
  final String meta;
  final String status;
  final IconData icon;
  final Color color;
  final String detailSummary;
  final List<String> relations;
}

enum _GraphNodeKind { company, contract, person }

enum _GraphEdgeType { portfolio, origin, scope, allocation, dismissal, history }

extension on _GraphEdgeType {
  String get label => switch (this) {
    _GraphEdgeType.portfolio => 'carteira empresarial',
    _GraphEdgeType.origin => 'vinculo de origem',
    _GraphEdgeType.scope => 'escopo contratual',
    _GraphEdgeType.allocation => 'alocacao ativa',
    _GraphEdgeType.dismissal => 'desligamento recente',
    _GraphEdgeType.history => 'passagem anterior',
  };

  Color get color => switch (this) {
    _GraphEdgeType.portfolio => _slateColor,
    _GraphEdgeType.origin => _deepTealColor,
    _GraphEdgeType.scope => _amberColor,
    _GraphEdgeType.allocation => _tealColor,
    _GraphEdgeType.dismissal => _roseColor,
    _GraphEdgeType.history => _slateColor,
  };

  bool get dashed => switch (this) {
    _GraphEdgeType.portfolio => false,
    _GraphEdgeType.origin => true,
    _GraphEdgeType.scope => false,
    _GraphEdgeType.allocation => false,
    _GraphEdgeType.dismissal => true,
    _GraphEdgeType.history => true,
  };
}

class _GraphNode {
  const _GraphNode({
    required this.id,
    required this.kind,
    required this.rootCompanyId,
    required this.label,
    required this.subtitle,
    required this.miniLabel,
    required this.position,
    required this.status,
    required this.color,
    required this.icon,
    required this.highlights,
    this.sector,
    this.jobTitle,
    this.gender,
    this.race,
    this.tenureMonths,
    this.hasWarnings = false,
    this.isRoot = false,
    this.dismissedDaysAgo,
  });

  final String id;
  final _GraphNodeKind kind;
  final String rootCompanyId;
  final String label;
  final String subtitle;
  final String miniLabel;
  final Alignment position;
  final String status;
  final Color color;
  final IconData icon;
  final List<String> highlights;
  final String? sector;
  final String? jobTitle;
  final String? gender;
  final String? race;
  final int? tenureMonths;
  final bool hasWarnings;
  final bool isRoot;
  final int? dismissedDaysAgo;

  String get kindLabel => switch (kind) {
    _GraphNodeKind.company => isRoot ? 'empresa-raiz' : 'empresa-cliente',
    _GraphNodeKind.contract => 'contrato',
    _GraphNodeKind.person => 'funcionario',
  };

  String? get tenureBand {
    if (tenureMonths == null) {
      return null;
    }
    if (tenureMonths! < 12) {
      return 'ate 1 ano';
    }
    if (tenureMonths! < 36) {
      return '1 a 3 anos';
    }
    if (tenureMonths! < 60) {
      return '3 a 5 anos';
    }
    return '5 anos ou mais';
  }

  _GraphNode copyWith({Alignment? position}) {
    return _GraphNode(
      id: id,
      kind: kind,
      rootCompanyId: rootCompanyId,
      label: label,
      subtitle: subtitle,
      miniLabel: miniLabel,
      position: position ?? this.position,
      status: status,
      color: color,
      icon: icon,
      highlights: highlights,
      sector: sector,
      jobTitle: jobTitle,
      gender: gender,
      race: race,
      tenureMonths: tenureMonths,
      hasWarnings: hasWarnings,
      isRoot: isRoot,
      dismissedDaysAgo: dismissedDaysAgo,
    );
  }
}

class _GraphEdge {
  const _GraphEdge({
    required this.from,
    required this.to,
    required this.type,
    required this.detail,
  });

  final String from;
  final String to;
  final _GraphEdgeType type;
  final String detail;
}

class _GraphConnectionDetail {
  const _GraphConnectionDetail({required this.node, required this.edge});

  final _GraphNode node;
  final _GraphEdge edge;
}

class _NetworkFacetData {
  const _NetworkFacetData({
    required this.rootCompanies,
    required this.sectors,
    required this.jobTitles,
    required this.tenureBands,
    required this.genders,
    required this.races,
    required this.hasRecordsWithWarnings,
    required this.hasRecordsWithoutWarnings,
  });

  final List<_GraphNode> rootCompanies;
  final List<String> sectors;
  final List<String> jobTitles;
  final List<String> tenureBands;
  final List<String> genders;
  final List<String> races;
  final bool hasRecordsWithWarnings;
  final bool hasRecordsWithoutWarnings;
}

const _pageInfo = {
  _Destination.home: _PageInfo(
    destination: _Destination.home,
    shortLabel: 'Inicio',
    title: 'Inicio',
    description: 'Escolha enxuta entre consulta direta e teia relacional.',
    kicker: 'Escolha direta para empresas, contratos, funcionarios ou teia',
    sidebarHint: 'escolha o caminho inicial',
    icon: Icons.home_outlined,
    accent: _tealColor,
  ),
  _Destination.companies: _PageInfo(
    destination: _Destination.companies,
    shortLabel: 'Empresas',
    title: 'Empresas prestadoras',
    description: 'Workspace focado em consulta e contexto empresarial.',
    kicker: 'Consulta focada em prestadoras',
    sidebarHint: 'contexto empresarial e contratual',
    icon: Icons.apartment_outlined,
    accent: _tealColor,
  ),
  _Destination.contracts: _PageInfo(
    destination: _Destination.contracts,
    shortLabel: 'Contratos',
    title: 'Contratos',
    description: 'Workspace focado em contexto contratual e relacoes.',
    kicker: 'Consulta focada em contratos',
    sidebarHint: 'filtros e relacoes principais',
    icon: Icons.description_outlined,
    accent: _amberColor,
  ),
  _Destination.people: _PageInfo(
    destination: _Destination.people,
    shortLabel: 'Funcionarios',
    title: 'Funcionarios',
    description: 'Workspace focado em ficha consolidada e historico.',
    kicker: 'Consulta focada em pessoas e historico',
    sidebarHint: 'registro-base e passagens',
    icon: Icons.badge_outlined,
    accent: _roseColor,
  ),
  _Destination.network: _PageInfo(
    destination: _Destination.network,
    shortLabel: 'Teia',
    title: 'Teia relacional',
    description:
        'Visao clicavel de empresas-raiz, clientes, contratos e historico de colaboradores.',
    kicker: 'Mapa visual de carteiras, origens e historico',
    sidebarHint: 'empresas-raiz, clientes e periodos historicos',
    icon: Icons.hub_outlined,
    accent: _slateColor,
  ),
};

const _choices = [
  _ChoiceCardData(
    target: _ChoiceTarget.companies,
    title: 'Consultar empresas',
    description:
        'Abrir um workspace mais calmo para prestadoras, status e relacoes principais.',
    hint: 'lista curta, detalhe ao lado, sem poluicao',
    icon: Icons.apartment_outlined,
    color: _tealColor,
    background: Color(0xFFF4FBF8),
    borderColor: Color(0xFFCFE3DB),
  ),
  _ChoiceCardData(
    target: _ChoiceTarget.contracts,
    title: 'Consultar contratos',
    description:
        'Entrar direto no contexto contratual, com filtros e conexoes relevantes.',
    hint: 'cliente, prestadora e vigencia no mesmo eixo',
    icon: Icons.assignment_outlined,
    color: _amberColor,
    background: Color(0xFFFFF6EF),
    borderColor: Color(0xFFF1D8BF),
  ),
  _ChoiceCardData(
    target: _ChoiceTarget.people,
    title: 'Consultar funcionarios',
    description:
        'Abrir a ficha consolidada sem misturar pessoa, empresa, vinculo e historico.',
    hint: 'registro-base, status e historico multiempresa',
    icon: Icons.groups_outlined,
    color: _roseColor,
    background: Color(0xFFFFF5F4),
    borderColor: Color(0xFFF0D2D2),
  ),
  _ChoiceCardData(
    target: _ChoiceTarget.network,
    title: 'Abrir teia visual',
    description:
        'Ver empresas-raiz, clientes, contratos e colaboradores em uma malha clicavel com historico filtravel.',
    hint: 'periodos historicos e foco clicavel',
    icon: Icons.hub_outlined,
    color: _slateColor,
    background: Color(0xFFF4F8FA),
    borderColor: Color(0xFFD2DDE4),
  ),
];

const _summaryCards = [
  _SummaryCardData(
    label: 'Empresas monitoradas',
    value: '18',
    description: 'Prestadoras prontas para consulta e conexao com contratos.',
    icon: Icons.business_outlined,
    color: _tealColor,
  ),
  _SummaryCardData(
    label: 'Contratos ativos',
    value: '42',
    description: 'Contratos com leitura focada em vigencia, cliente e risco.',
    icon: Icons.assignment_turned_in_outlined,
    color: _amberColor,
  ),
  _SummaryCardData(
    label: 'Funcionarios em foco',
    value: '342',
    description: 'Registros com historico e passagens multiempresa.',
    icon: Icons.badge_outlined,
    color: _roseColor,
  ),
];

const _resumeItems = [
  _ResumeItem(
    target: _ChoiceTarget.companies,
    title: 'Prestadoras com atualizacao recente',
    description:
        'Retomar uma lista curta de empresas que impactam contratos e postos.',
    icon: Icons.domain_verification_outlined,
    color: _tealColor,
  ),
  _ResumeItem(
    target: _ChoiceTarget.contracts,
    title: 'Contratos proximos de vencimento',
    description:
        'Entrar direto no contexto contratual sem atravessar varios cards.',
    icon: Icons.schedule_outlined,
    color: _amberColor,
  ),
  _ResumeItem(
    target: _ChoiceTarget.people,
    title: 'Funcionarios com mudanca recente',
    description:
        'Abrir a ficha de quem teve movimentacao, desligamento ou mudanca de status.',
    icon: Icons.person_search_outlined,
    color: _roseColor,
  ),
];

const _entityData = {
  _Destination.companies: _EntityWorkspaceData(
    title: 'Empresas com workspace focado',
    subtitle:
        'Aqui a interface para de tentar mostrar tudo ao mesmo tempo. A consulta empresarial fica limpa, com lista e detalhe no mesmo contexto.',
    searchHint: 'buscar por razao social, fantasia ou documento',
    listHint:
        'A lista fica curta, clicavel e orientada por contexto. O detalhe aparece ao lado sem romper a navegacao.',
    filters: ['ativas', 'com contratos em aberto', 'multiempresa'],
    accent: _tealColor,
    items: [
      _EntityItem(
        title: 'PariFlow Servicos Ltda',
        subtitle: 'Prestadora principal com operacao ativa em 4 contratos.',
        meta: 'CNPJ estavel | 4 contratos | 61 funcionarios ativos',
        status: 'ativa',
        icon: Icons.apartment_outlined,
        color: _tealColor,
        detailSummary:
            'O detalhe de empresa precisa sustentar busca, leitura de contratos e acesso rapido aos funcionarios relacionados.',
        relations: [
          'Cliente conectado: Condominio Bela Vista',
          'Contrato em foco: Portaria e controle de acesso',
          'Fila relacionada: 3 mudancas de quadro nesta semana',
        ],
      ),
      _EntityItem(
        title: 'Alpha Facilities',
        subtitle:
            'Prestadora com risco moderado e rotacao alta no ultimo ciclo.',
        meta: '2 contratos | 18 desligamentos em 45 dias | atencao operacional',
        status: 'atencao',
        icon: Icons.apartment_outlined,
        color: _amberColor,
        detailSummary:
            'Esse tipo de detalhe ajuda a cruzar historico de desligamento, risco e contratos ativos sem abrir a teia inteira.',
        relations: [
          'Cliente conectado: Reserva Mirante',
          'Contrato em foco: Limpeza tecnica',
          'Leitura futura: mapa de riscos e ocorrencias criticas',
        ],
      ),
      _EntityItem(
        title: 'Orbe Seguranca',
        subtitle: 'Prestadora com base pequena e contratos concentrados.',
        meta:
            '1 contrato | 12 funcionarios ativos | sem desligamentos recentes',
        status: 'estavel',
        icon: Icons.apartment_outlined,
        color: _slateColor,
        detailSummary:
            'O workspace continua simples mesmo quando o contexto e menor. O usuario nao precisa atravessar uma home cheia para chegar aqui.',
        relations: [
          'Cliente conectado: Torre Nascente',
          'Contrato em foco: Vigilancia patrimonial',
          'Leitura futura: auditoria e anexos sensiveis por vinculo',
        ],
      ),
    ],
  ),
  _Destination.contracts: _EntityWorkspaceData(
    title: 'Contratos com leitura contextual',
    subtitle:
        'A consulta contratual fica organizada por vigencia, cliente, prestadora e volume de pessoas impactadas.',
    searchHint: 'buscar por cliente, prestadora ou codigo do contrato',
    listHint:
        'O contrato deixa de ser uma linha abstrata. A tela destaca vigencia, empresa relacionada e impacto operacional.',
    filters: ['vigentes', 'a vencer', 'com rotacao recente'],
    accent: _amberColor,
    items: [
      _EntityItem(
        title: 'CTR-PORT-2026-001',
        subtitle: 'Portaria e controle de acesso no Condominio Bela Vista.',
        meta: 'vigente ate 12/2026 | 26 pessoas alocadas | 1 rotacao recente',
        status: 'vigente',
        icon: Icons.description_outlined,
        color: _amberColor,
        detailSummary:
            'O detalhe contratual precisa costurar cliente, prestadora, quadro e mudancas sem exigir varias telas intermediarias.',
        relations: [
          'Prestadora: PariFlow Servicos Ltda',
          'Cliente: Condominio Bela Vista',
          'Postos principais: Portaria diurna e noturna',
        ],
      ),
      _EntityItem(
        title: 'CTR-LIMP-2026-007',
        subtitle: 'Limpeza tecnica com aumento de desligamentos recentes.',
        meta: 'vigente ate 08/2026 | 19 pessoas | 6 desligamentos em 45 dias',
        status: 'atencao',
        icon: Icons.description_outlined,
        color: _roseColor,
        detailSummary:
            'Quando a rotacao sobe, o contrato vira um ponto central de investigacao e precisa levar o usuario para pessoas e teia sem atrito.',
        relations: [
          'Prestadora: Alpha Facilities',
          'Cliente: Reserva Mirante',
          'Leitura futura: ocorrencias e dossie por contrato',
        ],
      ),
      _EntityItem(
        title: 'CTR-VIG-2026-004',
        subtitle: 'Vigilancia patrimonial com quadro estavel.',
        meta: 'vigente ate 04/2027 | 12 pessoas | nenhum desligamento recente',
        status: 'estavel',
        icon: Icons.description_outlined,
        color: _slateColor,
        detailSummary:
            'Mesmo contratos estaveis precisam manter uma leitura limpa para nao parecer que tudo e urgencia o tempo inteiro.',
        relations: [
          'Prestadora: Orbe Seguranca',
          'Cliente: Torre Nascente',
          'Leitura futura: historico de acesso sensivel ao contrato',
        ],
      ),
    ],
  ),
  _Destination.people: _EntityWorkspaceData(
    title: 'Funcionarios com ficha mais legivel',
    subtitle:
        'A consulta de pessoas respeita a separacao entre registro-base, vinculo, empresa e historico. O layout evita transformar tudo em um bloco confuso.',
    searchHint: 'buscar por nome, cpf, email ou telefone',
    listHint:
        'A lista abre a ficha certa sem perder o contexto. A lateral antecipa historico, status e relacoes principais.',
    filters: ['ativos', 'desligados recentes', 'mais de um vinculo'],
    accent: _roseColor,
    items: [
      _EntityItem(
        title: 'Ana Paula Rocha',
        subtitle: 'Pessoa-base com vinculo ativo e historico anterior.',
        meta: 'ativo | 2 passagens | desligamento anterior em 2025',
        status: 'ativo',
        icon: Icons.badge_outlined,
        color: _tealColor,
        detailSummary:
            'A ficha precisa abrir com leitura humana: quem e a pessoa, qual o contexto atual e como o historico aparece sem colapsar tudo.',
        relations: [
          'Prestadora atual: PariFlow Servicos Ltda',
          'Contrato atual: CTR-PORT-2026-001',
          'Leitura futura: dossie e anexos sensiveis por ocorrencia',
        ],
      ),
      _EntityItem(
        title: 'Bruno Tavares',
        subtitle:
            'Pessoa desligada recentemente e ainda relevante para a teia.',
        meta: 'desligado ha 18 dias | 1 contrato | risco juridico em revisao',
        status: 'desligado recente',
        icon: Icons.person_off_outlined,
        color: _roseColor,
        detailSummary:
            'O detalhe precisa sustentar a transicao entre status atual, desligamento, periodo e proximas consultas juridicas.',
        relations: [
          'Prestadora anterior: Alpha Facilities',
          'Contrato relacionado: CTR-LIMP-2026-007',
          'Leitura futura: rastreio de downloads e historico de acesso',
        ],
      ),
      _EntityItem(
        title: 'Carla Mendes',
        subtitle: 'Pessoa com historico multiempresa e movimentacoes recentes.',
        meta: 'ativo | 3 passagens | 1 transferencia neste mes',
        status: 'historico ampliado',
        icon: Icons.compare_arrows_outlined,
        color: _amberColor,
        detailSummary:
            'Esse tipo de ficha justifica a teia visual: ha valor em enxergar rapidamente como a pessoa se conecta a diferentes contextos.',
        relations: [
          'Prestadora atual: PariFlow Servicos Ltda',
          'Passagem anterior: Orbe Seguranca',
          'Leitura futura: mapa de riscos e historico consolidado',
        ],
      ),
    ],
  ),
};

const _graphNodes = [
  _GraphNode(
    id: 'company_jotabe',
    kind: _GraphNodeKind.company,
    rootCompanyId: 'company_jotabe',
    label: 'SEDE JOTABE',
    subtitle:
        'Empresa-raiz com carteira propria e quadro terceirizado rastreavel.',
    miniLabel: 'empresa-raiz',
    position: Alignment(-0.88, -0.72),
    status: 'ativo',
    color: _tealColor,
    icon: Icons.apartment_outlined,
    highlights: [
      'Tem o mesmo peso estrutural da VVG dentro da teia.',
      'Ao ocultar esta raiz, clientes, contratos e colaboradores vinculados somem juntos.',
      'Funciona como ancora de rastreabilidade para origem do colaborador.',
    ],
    isRoot: true,
  ),
  _GraphNode(
    id: 'client_bela_vista',
    kind: _GraphNodeKind.company,
    rootCompanyId: 'company_jotabe',
    label: 'Condominio Bela Vista',
    subtitle: 'Cliente da carteira JOTABE com operacao de seguranca.',
    miniLabel: 'cliente',
    position: Alignment(-0.46, -0.58),
    status: 'ativo',
    color: _slateColor,
    icon: Icons.business_outlined,
    highlights: [
      'Empresa-cliente conectada a uma raiz especifica.',
      'Ajuda a deixar explicito para onde o colaborador foi subdirecionado.',
      'Pode ser ocultada de forma indireta ao desligar a visibilidade da raiz.',
    ],
  ),
  _GraphNode(
    id: 'contract_portaria',
    kind: _GraphNodeKind.contract,
    rootCompanyId: 'company_jotabe',
    label: 'CTR-SEG-2026-001',
    subtitle: 'Controle de acesso e ronda leve no Bela Vista.',
    miniLabel: 'contrato',
    position: Alignment(-0.04, -0.44),
    status: 'ativo',
    color: _amberColor,
    icon: Icons.description_outlined,
    highlights: [
      'Amarra o cliente ao quadro de seguranca alocado pela JOTABE.',
      'Permite filtrar a malha por setor e cargo sem perder a trilha da origem.',
      'Serve como ponte entre empresa-cliente e colaborador terceirizado.',
    ],
  ),
  _GraphNode(
    id: 'person_ana',
    kind: _GraphNodeKind.person,
    rootCompanyId: 'company_jotabe',
    label: 'Ana Paula Rocha',
    subtitle: 'Origem JOTABE | alocada no Bela Vista.',
    miniLabel: 'acesso',
    position: Alignment(0.42, -0.48),
    status: 'ativo',
    color: _tealColor,
    icon: Icons.badge_outlined,
    highlights: [
      'Mostra o caso classico de colaboradora vinculada a uma raiz e enviada para cliente especifico.',
      'Permite filtrar por setor, sexo, raca e tempo de servico sem perder a origem.',
      'Pode abrir ficha consolidada com trilha completa da alocacao.',
    ],
    sector: 'Seguranca',
    jobTitle: 'Controlador de Acesso',
    gender: 'feminino',
    race: 'branca',
    tenureMonths: 26,
  ),
  _GraphNode(
    id: 'client_horizonte',
    kind: _GraphNodeKind.company,
    rootCompanyId: 'company_jotabe',
    label: 'Horizonte Offices',
    subtitle: 'Cliente da carteira JOTABE com frente ADM e formacao.',
    miniLabel: 'cliente',
    position: Alignment(-0.46, -0.10),
    status: 'ativo',
    color: _slateColor,
    icon: Icons.business_outlined,
    highlights: [
      'Expande a teia para uma segunda carteira cliente da mesma raiz.',
      'Ajuda a provar que a ocultacao por raiz precisa derrubar toda a subarvore.',
      'Mantem contratos de apoio administrativo e entrada de aprendizes.',
    ],
  ),
  _GraphNode(
    id: 'contract_adm',
    kind: _GraphNodeKind.contract,
    rootCompanyId: 'company_jotabe',
    label: 'CTR-ADM-2026-014',
    subtitle: 'Apoio administrativo e formacao em escritorio.',
    miniLabel: 'contrato',
    position: Alignment(-0.02, -0.04),
    status: 'ativo',
    color: _amberColor,
    icon: Icons.description_outlined,
    highlights: [
      'Mantem cargos administrativos e de entrada no mesmo contexto contratual.',
      'Ajuda a demonstrar filtros dinamicos para setor e emprego especifico.',
      'Pode continuar visivel mesmo quando a leitura sai da seguranca.',
    ],
  ),
  _GraphNode(
    id: 'person_lucas',
    kind: _GraphNodeKind.person,
    rootCompanyId: 'company_jotabe',
    label: 'Lucas Andrade',
    subtitle: 'Origem JOTABE | frente administrativa ativa.',
    miniLabel: 'adm',
    position: Alignment(0.42, -0.08),
    status: 'ativo',
    color: _tealColor,
    icon: Icons.badge_outlined,
    highlights: [
      'Representa colaborador com advertencia anexa e tempo de casa mais longo.',
      'Ajuda a validar filtros de sexo, raca autodeclarada e advertencia.',
      'Mostra que o contrato pode sustentar mais de um perfil ocupacional.',
    ],
    sector: 'Area ADM',
    jobTitle: 'Supervisor Administrativo',
    gender: 'masculino',
    race: 'pardo',
    tenureMonths: 49,
    hasWarnings: true,
  ),
  _GraphNode(
    id: 'person_mila',
    kind: _GraphNodeKind.person,
    rootCompanyId: 'company_jotabe',
    label: 'Mila Santos',
    subtitle: 'Origem JOTABE | trilha de aprendizagem em andamento.',
    miniLabel: 'aprendiz',
    position: Alignment(0.68, 0.16),
    status: 'ativo',
    color: _tealColor,
    icon: Icons.school_outlined,
    highlights: [
      'Insere o eixo de estagiarios e jovens aprendizes na propria teia.',
      'Permite validar tempo de servico curto e recortes mais recentes de entrada.',
      'Mostra como a teia pode servir a contextos de formacao sem filtro fixo previo.',
    ],
    sector: 'Estagiarios + Jovens Aprendizes',
    jobTitle: 'Estagiaria Administrativa',
    gender: 'feminino',
    race: 'preta',
    tenureMonths: 7,
  ),
  _GraphNode(
    id: 'company_vvg',
    kind: _GraphNodeKind.company,
    rootCompanyId: 'company_vvg',
    label: 'VVG Servicos',
    subtitle: 'Empresa-raiz com carteira propria e equipe rastreavel.',
    miniLabel: 'empresa-raiz',
    position: Alignment(-0.88, 0.42),
    status: 'ativo',
    color: _roseColor,
    icon: Icons.apartment_outlined,
    highlights: [
      'Tem o mesmo peso estrutural da SEDE JOTABE.',
      'Pode ser desligada da teia inteira sem afetar a outra raiz.',
      'Explicita a necessidade de grupos empresariais independentes no mesmo mapa.',
    ],
    isRoot: true,
  ),
  _GraphNode(
    id: 'client_aurora',
    kind: _GraphNodeKind.company,
    rootCompanyId: 'company_vvg',
    label: 'Hospital Aurora',
    subtitle: 'Cliente da carteira VVG com frente de governanca.',
    miniLabel: 'cliente',
    position: Alignment(-0.46, 0.32),
    status: 'ativo',
    color: _slateColor,
    icon: Icons.local_hospital_outlined,
    highlights: [
      'Cliente conectado a uma segunda raiz de mesmo peso.',
      'Ajuda a demonstrar como contratos e desligados antigos podem reaparecer.',
      'Mantem a leitura de governanca, limpeza e historico na mesma subarvore.',
    ],
  ),
  _GraphNode(
    id: 'contract_governanca',
    kind: _GraphNodeKind.contract,
    rootCompanyId: 'company_vvg',
    label: 'CTR-GOV-2026-021',
    subtitle: 'Governanca operacional e lideranca de limpeza hospitalar.',
    miniLabel: 'contrato',
    position: Alignment(-0.02, 0.36),
    status: 'ativo',
    color: _amberColor,
    icon: Icons.description_outlined,
    highlights: [
      'Contrato que concentra ativos e desligados de varias janelas temporais.',
      'E um bom exemplo para habilitar 6 meses, 1 ano, 2 anos, 5 anos e todo o periodo.',
      'Tambem sustenta historico multiempresa em casos de passagem anterior.',
    ],
  ),
  _GraphNode(
    id: 'person_carla',
    kind: _GraphNodeKind.person,
    rootCompanyId: 'company_vvg',
    label: 'Carla Mendes',
    subtitle: 'Origem VVG | lideranca ativa em governanca.',
    miniLabel: 'governanca',
    position: Alignment(0.42, 0.24),
    status: 'ativo',
    color: _tealColor,
    icon: Icons.badge_outlined,
    highlights: [
      'Mantem o setor de governanca vivo na teia atual.',
      'Permite enxergar passagem anterior entre grupos empresariais.',
      'E um caso bom para abrir detalhe de risco, historico e relacoes cruzadas.',
    ],
    sector: 'Area de Governanca',
    jobTitle: 'Lider de Limpeza',
    gender: 'feminino',
    race: 'parda',
    tenureMonths: 18,
  ),
  _GraphNode(
    id: 'person_bruno',
    kind: _GraphNodeKind.person,
    rootCompanyId: 'company_vvg',
    label: 'Bruno Tavares',
    subtitle: 'Desligado ha 18 dias | historico ainda quente.',
    miniLabel: 'desligado',
    position: Alignment(0.58, 0.56),
    status: 'desligado',
    color: _roseColor,
    icon: Icons.person_off_outlined,
    highlights: [
      'Permanece visivel nas janelas curtas e some quando o recorte fecha abaixo de 18 dias.',
      'Ajuda a validar filtros de advertencia anexa e recortes juridicos.',
      'Continua rastreavel ate a raiz VVG e ao contrato hospitalar.',
    ],
    sector: 'Area de Governanca',
    jobTitle: 'Auxiliar de Limpeza',
    gender: 'masculino',
    race: 'preto',
    tenureMonths: 38,
    hasWarnings: true,
    dismissedDaysAgo: 18,
  ),
  _GraphNode(
    id: 'person_vera',
    kind: _GraphNodeKind.person,
    rootCompanyId: 'company_vvg',
    label: 'Vera Sousa',
    subtitle: 'Desligada ha 420 dias | historico remoto relevante.',
    miniLabel: 'historico',
    position: Alignment(0.26, 0.78),
    status: 'desligado',
    color: _roseColor,
    icon: Icons.person_off_outlined,
    highlights: [
      'Volta para a malha quando o usuario sobe para 2 anos ou todo o periodo.',
      'Prova que a teia nao pode limitar desligados antigos a um teto fixo de 90 dias.',
      'Mantem rastreabilidade de origem mesmo em desligamentos remotos.',
    ],
    sector: 'Area de Governanca',
    jobTitle: 'Governanta',
    gender: 'feminino',
    race: 'branca',
    tenureMonths: 86,
    dismissedDaysAgo: 420,
  ),
];

const _graphEdges = [
  _GraphEdge(
    from: 'company_jotabe',
    to: 'client_bela_vista',
    type: _GraphEdgeType.portfolio,
    detail: 'A SEDE JOTABE sustenta esta carteira cliente.',
  ),
  _GraphEdge(
    from: 'client_bela_vista',
    to: 'contract_portaria',
    type: _GraphEdgeType.scope,
    detail: 'Este cliente recebe o contrato de seguranca da JOTABE.',
  ),
  _GraphEdge(
    from: 'company_jotabe',
    to: 'person_ana',
    type: _GraphEdgeType.origin,
    detail: 'Ana esta vinculada diretamente a raiz JOTABE antes da alocacao.',
  ),
  _GraphEdge(
    from: 'contract_portaria',
    to: 'person_ana',
    type: _GraphEdgeType.allocation,
    detail: 'Ana esta alocada no posto de controlador de acesso.',
  ),
  _GraphEdge(
    from: 'company_jotabe',
    to: 'client_horizonte',
    type: _GraphEdgeType.portfolio,
    detail: 'Horizonte Offices integra a carteira da SEDE JOTABE.',
  ),
  _GraphEdge(
    from: 'client_horizonte',
    to: 'contract_adm',
    type: _GraphEdgeType.scope,
    detail: 'A carteira JOTABE desdobra apoio administrativo neste cliente.',
  ),
  _GraphEdge(
    from: 'company_jotabe',
    to: 'person_lucas',
    type: _GraphEdgeType.origin,
    detail: 'Lucas esta vinculado a JOTABE e depois direcionado ao cliente.',
  ),
  _GraphEdge(
    from: 'contract_adm',
    to: 'person_lucas',
    type: _GraphEdgeType.allocation,
    detail: 'Lucas atua como supervisor administrativo neste contrato.',
  ),
  _GraphEdge(
    from: 'contract_adm',
    to: 'person_mila',
    type: _GraphEdgeType.allocation,
    detail: 'Mila entra pela trilha de aprendizagem dentro deste contrato.',
  ),
  _GraphEdge(
    from: 'company_vvg',
    to: 'client_aurora',
    type: _GraphEdgeType.portfolio,
    detail: 'A VVG controla esta carteira hospitalar.',
  ),
  _GraphEdge(
    from: 'client_aurora',
    to: 'contract_governanca',
    type: _GraphEdgeType.scope,
    detail: 'O cliente recebe o contrato hospitalar de governanca e limpeza.',
  ),
  _GraphEdge(
    from: 'company_vvg',
    to: 'person_carla',
    type: _GraphEdgeType.origin,
    detail: 'Carla esta vinculada a VVG antes da alocacao no hospital.',
  ),
  _GraphEdge(
    from: 'contract_governanca',
    to: 'person_carla',
    type: _GraphEdgeType.allocation,
    detail: 'Carla lidera a frente operacional de governanca neste contrato.',
  ),
  _GraphEdge(
    from: 'contract_governanca',
    to: 'person_bruno',
    type: _GraphEdgeType.dismissal,
    detail: 'Bruno saiu deste contrato dentro da janela curta ainda visivel.',
  ),
  _GraphEdge(
    from: 'contract_governanca',
    to: 'person_vera',
    type: _GraphEdgeType.dismissal,
    detail: 'Vera so volta quando a teia abre o recorte historico mais longo.',
  ),
  _GraphEdge(
    from: 'person_carla',
    to: 'company_jotabe',
    type: _GraphEdgeType.history,
    detail: 'Carla teve passagem anterior em uma carteira ligada a JOTABE.',
  ),
];

List<_GraphNode> _structuralGraphNodes(_NetworkFilterState filters) {
  final maxDays = filters.maxDismissedDays;

  return _graphNodes.where((node) {
    if (filters.hiddenRootCompanyIds.contains(node.rootCompanyId)) {
      return false;
    }
    if (node.kind != _GraphNodeKind.person || node.dismissedDaysAgo == null) {
      return true;
    }
    if (maxDays == null) {
      return true;
    }
    return node.dismissedDaysAgo! <= maxDays;
  }).toList();
}

_NetworkFacetData _networkFacets(List<_GraphNode> structuralNodes) {
  final people = structuralNodes
      .where((node) => node.kind == _GraphNodeKind.person)
      .toList();
  final tenureOrder = [
    'ate 1 ano',
    '1 a 3 anos',
    '3 a 5 anos',
    '5 anos ou mais',
  ];

  final sectors = <String>{};
  final jobTitles = <String>{};
  final genders = <String>{};
  final races = <String>{};
  final tenureBands = <String>{};

  for (final person in people) {
    if (person.sector != null) {
      sectors.add(person.sector!);
    }
    if (person.jobTitle != null) {
      jobTitles.add(person.jobTitle!);
    }
    if (person.gender != null) {
      genders.add(person.gender!);
    }
    if (person.race != null) {
      races.add(person.race!);
    }
    if (person.tenureBand != null) {
      tenureBands.add(person.tenureBand!);
    }
  }

  final orderedTenureBands = tenureBands.toList()
    ..sort(
      (left, right) =>
          tenureOrder.indexOf(left).compareTo(tenureOrder.indexOf(right)),
    );

  return _NetworkFacetData(
    rootCompanies: _graphNodes
        .where((node) => node.kind == _GraphNodeKind.company && node.isRoot)
        .toList(),
    sectors: sectors.toList(),
    jobTitles: jobTitles.toList(),
    tenureBands: orderedTenureBands,
    genders: genders.toList(),
    races: races.toList(),
    hasRecordsWithWarnings: people.any((person) => person.hasWarnings),
    hasRecordsWithoutWarnings: people.any((person) => !person.hasWarnings),
  );
}

List<_GraphNode> _visibleGraphNodes(_NetworkFilterState filters) {
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

  final candidates = structuralNodes.where((node) {
    if (node.kind != _GraphNodeKind.person) {
      return true;
    }
    if (effectiveSectors.isNotEmpty &&
        !effectiveSectors.contains(node.sector)) {
      return false;
    }
    if (effectiveJobTitles.isNotEmpty &&
        !effectiveJobTitles.contains(node.jobTitle)) {
      return false;
    }
    if (effectiveTenureBands.isNotEmpty &&
        !effectiveTenureBands.contains(node.tenureBand)) {
      return false;
    }
    if (effectiveGenders.isNotEmpty &&
        !effectiveGenders.contains(node.gender)) {
      return false;
    }
    if (effectiveRaces.isNotEmpty && !effectiveRaces.contains(node.race)) {
      return false;
    }
    if (filters.requireWarnings != null &&
        node.hasWarnings != filters.requireWarnings) {
      return false;
    }
    return true;
  }).toList();

  return _layoutGraphNodes(_pruneGraphNodes(candidates));
}

List<_GraphNode> _pruneGraphNodes(List<_GraphNode> nodes) {
  final nodesById = {for (final node in nodes) node.id: node};
  var currentIds = nodesById.keys.toSet();
  var changed = true;

  while (changed) {
    changed = false;
    final visibleEdges = _graphEdges.where(
      (edge) => currentIds.contains(edge.from) && currentIds.contains(edge.to),
    );
    final adjacency = <String, Set<String>>{
      for (final id in currentIds) id: <String>{},
    };

    for (final edge in visibleEdges) {
      adjacency[edge.from]!.add(edge.to);
      adjacency[edge.to]!.add(edge.from);
    }

    final nextIds = <String>{};

    for (final nodeId in currentIds) {
      final node = nodesById[nodeId]!;
      final neighbors = adjacency[nodeId] ?? const <String>{};

      if (neighbors.isEmpty) {
        continue;
      }

      if (node.kind == _GraphNodeKind.person) {
        nextIds.add(nodeId);
        continue;
      }

      if (node.kind == _GraphNodeKind.contract) {
        final hasPersonNeighbor = neighbors.any(
          (neighborId) => nodesById[neighborId]!.kind == _GraphNodeKind.person,
        );
        if (hasPersonNeighbor) {
          nextIds.add(nodeId);
        }
        continue;
      }

      final hasNonCompanyNeighbor = neighbors.any(
        (neighborId) => nodesById[neighborId]!.kind != _GraphNodeKind.company,
      );
      if (hasNonCompanyNeighbor) {
        nextIds.add(nodeId);
      }
    }

    if (nextIds.length != currentIds.length) {
      currentIds = nextIds;
      changed = true;
    }
  }

  return nodes.where((node) => currentIds.contains(node.id)).toList();
}

List<_GraphNode> _layoutGraphNodes(List<_GraphNode> nodes) {
  if (nodes.isEmpty) {
    return nodes;
  }

  final nodesById = {for (final node in nodes) node.id: node};
  final visibleEdges = _visibleGraphEdges(nodes);
  final positioned = <String, Alignment>{};
  final rootCompanies =
      nodes
          .where((node) => node.kind == _GraphNodeKind.company && node.isRoot)
          .toList()
        ..sort(
          (left, right) => _graphNodeOriginalOrder(
            left.id,
          ).compareTo(_graphNodeOriginalOrder(right.id)),
        );

  final laneCenters = _spreadAlignments(
    rootCompanies.length,
    center: 0,
    spread: rootCompanies.length == 1 ? 0 : 1.18,
  );

  for (var rootIndex = 0; rootIndex < rootCompanies.length; rootIndex++) {
    final root = rootCompanies[rootIndex];
    final laneCenter = laneCenters[rootIndex];
    positioned[root.id] = Alignment(laneCenter, -0.80);

    final clients =
        nodes
            .where(
              (node) =>
                  node.kind == _GraphNodeKind.company &&
                  !node.isRoot &&
                  node.rootCompanyId == root.id,
            )
            .toList()
          ..sort(
            (left, right) => _graphNodeOriginalOrder(
              left.id,
            ).compareTo(_graphNodeOriginalOrder(right.id)),
          );

    final clientCenters = _spreadAlignments(
      clients.length,
      center: laneCenter,
      spread: clients.length == 1 ? 0 : 0.34,
    );

    final positionedPeopleForRoot = <String>{};

    for (var clientIndex = 0; clientIndex < clients.length; clientIndex++) {
      final client = clients[clientIndex];
      final clientCenter = clientCenters[clientIndex];
      positioned[client.id] = Alignment(clientCenter, -0.34);

      final clientContracts = _contractsForClient(
        client.id,
        nodesById,
        visibleEdges,
      );
      final contractCenters = _spreadAlignments(
        clientContracts.length,
        center: clientCenter,
        spread: clientContracts.length == 1 ? 0 : 0.16,
      );

      for (
        var contractIndex = 0;
        contractIndex < clientContracts.length;
        contractIndex++
      ) {
        final contract = clientContracts[contractIndex];
        final contractCenter = contractCenters[contractIndex];
        positioned[contract.id] = Alignment(contractCenter, 0.02);

        final contractPeople = _peopleForContract(
          contract.id,
          nodesById,
          visibleEdges,
        );
        for (
          var rowStart = 0;
          rowStart < contractPeople.length;
          rowStart += 2
        ) {
          final row = rowStart ~/ 2;
          final rowPeople = contractPeople.skip(rowStart).take(2).toList();
          final rowCenters = _spreadAlignments(
            rowPeople.length,
            center: contractCenter,
            spread: rowPeople.length == 1 ? 0 : 0.24,
          );

          for (var rowIndex = 0; rowIndex < rowPeople.length; rowIndex++) {
            final person = rowPeople[rowIndex];
            final personY = 0.36 + (row * 0.24);
            positioned[person.id] = Alignment(rowCenters[rowIndex], personY);
            positionedPeopleForRoot.add(person.id);
          }
        }
      }
    }

    final unassignedPeople =
        nodes
            .where(
              (node) =>
                  node.kind == _GraphNodeKind.person &&
                  node.rootCompanyId == root.id &&
                  !positionedPeopleForRoot.contains(node.id),
            )
            .toList()
          ..sort(
            (left, right) => _graphNodeOriginalOrder(
              left.id,
            ).compareTo(_graphNodeOriginalOrder(right.id)),
          );

    for (
      var looseIndex = 0;
      looseIndex < unassignedPeople.length;
      looseIndex++
    ) {
      final loosePerson = unassignedPeople[looseIndex];
      final looseOffsets = _spreadAlignments(
        unassignedPeople.length,
        center: laneCenter,
        spread: unassignedPeople.length == 1 ? 0 : 0.20,
      );
      positioned[loosePerson.id] = Alignment(
        looseOffsets[looseIndex],
        0.34 + ((looseIndex ~/ 2) * 0.24),
      );
    }
  }

  return nodes
      .map((node) => node.copyWith(position: positioned[node.id]))
      .toList();
}

List<_GraphNode> _contractsForClient(
  String clientId,
  Map<String, _GraphNode> nodesById,
  List<_GraphEdge> visibleEdges,
) {
  return visibleEdges
      .where(
        (edge) => edge.type == _GraphEdgeType.scope && edge.from == clientId,
      )
      .map((edge) => nodesById[edge.to])
      .whereType<_GraphNode>()
      .toList()
    ..sort(
      (left, right) => _graphNodeOriginalOrder(
        left.id,
      ).compareTo(_graphNodeOriginalOrder(right.id)),
    );
}

List<_GraphNode> _peopleForContract(
  String contractId,
  Map<String, _GraphNode> nodesById,
  List<_GraphEdge> visibleEdges,
) {
  final people = visibleEdges
      .where(
        (edge) =>
            (edge.type == _GraphEdgeType.allocation ||
                edge.type == _GraphEdgeType.dismissal) &&
            edge.from == contractId,
      )
      .map((edge) => nodesById[edge.to])
      .whereType<_GraphNode>()
      .toList();

  people.sort((left, right) {
    if (left.status != right.status) {
      return left.status == 'ativo' ? -1 : 1;
    }
    return _graphNodeOriginalOrder(
      left.id,
    ).compareTo(_graphNodeOriginalOrder(right.id));
  });

  return people;
}

int _graphNodeOriginalOrder(String nodeId) {
  return _graphNodes.indexWhere((node) => node.id == nodeId);
}

List<double> _spreadAlignments(
  int count, {
  required double center,
  required double spread,
}) {
  if (count <= 0) {
    return const [];
  }
  if (count == 1) {
    return [center];
  }

  final start = center - (spread / 2);
  final step = spread / (count - 1);
  return List<double>.generate(count, (index) => start + (step * index));
}

List<_GraphEdge> _visibleGraphEdges(List<_GraphNode> visibleNodes) {
  return _graphEdges.where((edge) {
    return visibleNodes.any((node) => node.id == edge.from) &&
        visibleNodes.any((node) => node.id == edge.to);
  }).toList();
}

List<_GraphConnectionDetail> _connectionDetailsForNode(
  String nodeId,
  List<_GraphNode> visibleNodes,
) {
  final visibleEdges = _visibleGraphEdges(visibleNodes);
  final details = <_GraphConnectionDetail>[];

  for (final edge in visibleEdges) {
    final relatedNodeId = edge.from == nodeId
        ? edge.to
        : edge.to == nodeId
        ? edge.from
        : null;

    if (relatedNodeId == null) {
      continue;
    }

    final relatedNode = visibleNodes.firstWhere(
      (node) => node.id == relatedNodeId,
    );

    details.add(_GraphConnectionDetail(node: relatedNode, edge: edge));
  }

  return details;
}

Set<String> _relatedNodeIds(String nodeId, List<_GraphEdge> edges) {
  final ids = <String>{};

  for (final edge in edges) {
    if (edge.from == nodeId) {
      ids.add(edge.to);
    } else if (edge.to == nodeId) {
      ids.add(edge.from);
    }
  }

  return ids;
}

String _nodeLabelById(String nodeId, List<_GraphNode> nodes) {
  return nodes
      .firstWhere((node) => node.id == nodeId, orElse: () => nodes.first)
      .label;
}

IconData _statusIconForNode(_GraphNode node) {
  if (node.status == 'desligado') {
    return Icons.person_off_outlined;
  }

  if (node.kind == _GraphNodeKind.contract) {
    return Icons.description_outlined;
  }

  return node.icon;
}

void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
  for (final metric in path.computeMetrics()) {
    var distance = 0.0;
    const dash = 8.0;
    const gap = 6.0;

    while (distance < metric.length) {
      final next = distance + dash;
      canvas.drawPath(
        metric.extractPath(distance, next.clamp(0, metric.length).toDouble()),
        paint,
      );
      distance += dash + gap;
    }
  }
}
