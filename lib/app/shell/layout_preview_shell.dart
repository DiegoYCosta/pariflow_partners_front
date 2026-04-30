part of '../app.dart';

enum _Destination { home, companies, contracts, people, network }

enum _HomeMode { overview, network }

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
          actionLabel: 'Levar esta leitura para a home',
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
    title: 'Workspace da teia relacional',
    description:
        'Leitura focada da malha com mais espaco para navegacao, contexto e historico.',
    kicker: 'Workspace visual de carteiras, origens e historico',
    sidebarHint: 'workspace focado da malha relacional',
    icon: Icons.hub_outlined,
    accent: _slateColor,
  ),
};
