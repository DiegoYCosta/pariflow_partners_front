part of '../app.dart';

enum _Destination {
  home,
  companies,
  clientCompanies,
  contracts,
  people,
  network,
}

class LayoutPreviewPage extends StatelessWidget {
  const LayoutPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return switch (_ShellFeatureFlags.activeVariant) {
      _ShellVariant.legacy => const _LegacyShellPage(),
      _ShellVariant.crm => const _CrmShellPage(),
    };
  }
}

class _ShellPreviewPage extends StatefulWidget {
  const _ShellPreviewPage({required this.variant});

  final _ShellVariant variant;

  @override
  State<_ShellPreviewPage> createState() => _ShellPreviewPageState();
}

class _ShellPreviewPageState extends State<_ShellPreviewPage> {
  _Destination _destination = _Destination.home;
  _ViewerAccessProfile _viewerProfile = _diegoViewerProfile;
  _NetworkFilterState _networkFilters = const _NetworkFilterState();
  bool _showAdvancedNetworkFilters = false;
  bool _focusBoardDetached = false;
  String _selectedNetworkNodeId = '';
  String? _hoveredNetworkNodeId;
  late final _FocusBoardPersistentController _focusBoardController;
  final Map<_Destination, int> _selectedItemIndex = {
    _Destination.companies: 0,
    _Destination.clientCompanies: 0,
    _Destination.contracts: 0,
    _Destination.people: 0,
  };

  @override
  void initState() {
    super.initState();
    _focusBoardController = _FocusBoardPersistentController();
    _focusBoardController.ensureLoaded();
  }

  @override
  void dispose() {
    _focusBoardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final showSidebar = width >= 1120;
    final page = _pageInfo[_destination]!;

    return switch (widget.variant) {
      _ShellVariant.legacy => _buildLegacyShell(page, width, showSidebar),
      _ShellVariant.crm => _buildCrmShell(page, width, showSidebar),
    };
  }

  Widget _buildLegacyShell(_PageInfo page, double width, bool showSidebar) {
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
                    icon: _SpriteMoldIcon(
                      mold: item.mold,
                      size: 24,
                      color: _mutedColor,
                    ),
                    selectedIcon: _SpriteMoldIcon(
                      mold: item.mold,
                      state: _SpriteMoldState.selected,
                      size: 24,
                    ),
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
                        _TopBar(
                          page: page,
                          showMenuButton: !showSidebar,
                          viewerProfile: _viewerProfile,
                          onViewerChanged: (value) {
                            setState(() {
                              _viewerProfile = value;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildWorkspaceContent(page, width),
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

  Widget _buildCrmShell(_PageInfo page, double width, bool showSidebar) {
    final sidebarWidth = width >= 1500 ? 332.0 : 292.0;

    return Scaffold(
      drawer: showSidebar
          ? null
          : Drawer(
              backgroundColor: _deepTealColor,
              child: SafeArea(
                child: _CrmSidebar(
                  current: _destination,
                  viewerProfile: _viewerProfile,
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
                    icon: _SpriteMoldIcon(
                      mold: item.mold,
                      size: 24,
                      color: _mutedColor,
                    ),
                    selectedIcon: _SpriteMoldIcon(
                      mold: item.mold,
                      state: _SpriteMoldState.selected,
                      size: 24,
                    ),
                    label: item.shortLabel,
                  ),
              ],
            ),
      body: SafeArea(
        child: Row(
          children: [
            if (showSidebar)
              Container(
                width: sidebarWidth,
                color: _deepTealColor,
                child: _CrmSidebar(
                  current: _destination,
                  viewerProfile: _viewerProfile,
                  onSelect: _handleDestination,
                ),
              ),
            Expanded(
              child: DecoratedBox(
                decoration: const BoxDecoration(color: _paperColor),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildCrmShellBackground(
                      isHome: _destination == _Destination.home,
                      showSidebar: showSidebar,
                    ),
                    Column(
                      children: [
                        _CrmTopBar(
                          viewerProfile: _viewerProfile,
                          showMenuButton: !showSidebar,
                          onViewerChanged: (value) {
                            setState(() {
                              _viewerProfile = value;
                            });
                          },
                        ),
                        Expanded(
                          child: _focusBoardDetached
                              ? _FocusBoardDetachedWorkspace(
                                  controller: _focusBoardController,
                                  viewerProfile: _viewerProfile,
                                  onAttach: () {
                                    setState(() {
                                      _focusBoardDetached = false;
                                    });
                                  },
                                )
                              : SingleChildScrollView(
                                  padding: EdgeInsets.fromLTRB(
                                    _destination == _Destination.network
                                        ? 0
                                        : showSidebar
                                        ? 28
                                        : 16,
                                    _destination == _Destination.network
                                        ? 0
                                        : _destination == _Destination.home
                                        ? 16
                                        : 24,
                                    _destination == _Destination.network
                                        ? 0
                                        : showSidebar
                                        ? 28
                                        : 16,
                                    _destination == _Destination.network
                                        ? 0
                                        : showSidebar
                                        ? 24
                                        : 96,
                                  ),
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            _destination == _Destination.network
                                            ? double.infinity
                                            : 1560,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildWorkspaceContent(page, width),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                    _PersistentFocusBoardDock(
                      controller: _focusBoardController,
                      viewerProfile: _viewerProfile,
                      detached: _focusBoardDetached,
                      onDetach: () {
                        setState(() {
                          _focusBoardDetached = true;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCrmShellBackground({
    required bool isHome,
    required bool showSidebar,
  }) {
    final blurSigma = isHome ? 2.0 : (showSidebar ? 11.0 : 7.0);
    final textureOpacity = isHome ? 0.38 : (showSidebar ? 0.50 : 0.44);
    final veilLeadOpacity = isHome ? 0.24 : (showSidebar ? 0.68 : 0.56);
    final veilMidOpacity = isHome ? 0.10 : (showSidebar ? 0.42 : 0.30);
    final veilTailOpacity = isHome ? 0.16 : (showSidebar ? 0.52 : 0.40);
    final oliveGlowOpacity = isHome ? 0.08 : (showSidebar ? 0.18 : 0.12);

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: blurSigma,
                sigmaY: blurSigma,
              ),
              child: Opacity(
                opacity: textureOpacity,
                child: Image.asset(
                  _crmBackgroundAsset,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFF9F2E5).withValues(alpha: veilLeadOpacity),
                    const Color(0xFFF7EFD9).withValues(alpha: veilMidOpacity),
                    const Color(0xFFF5EBD7).withValues(alpha: veilTailOpacity),
                  ],
                  stops: const [0.0, 0.48, 1.0],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.82, -0.10),
                  radius: 0.92,
                  colors: [
                    const Color(0xFFA9AE7A).withValues(alpha: oliveGlowOpacity),
                    const Color(
                      0xFFA9AE7A,
                    ).withValues(alpha: oliveGlowOpacity * 0.32),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.30, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkspaceContent(_PageInfo page, double width) {
    switch (_destination) {
      case _Destination.home:
        return widget.variant == _ShellVariant.crm
            ? _CrmDashboardContent(
                viewerProfile: _viewerProfile,
                onChooseDestination: _handleChoice,
                pageWidth: width,
              )
            : _HomeContent(
                viewerProfile: _viewerProfile,
                onChooseDestination: _handleChoice,
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
          onOpenEmployeeProfile: _openEmployeeProfile,
          actionLabel: 'Voltar ao inicio',
          onAction: () {
            setState(() {
              _destination = _Destination.home;
            });
          },
        );
      case _Destination.companies:
        return _CompaniesWorkspace(
          viewerProfile: _viewerProfile,
          selectedIndex: _selectedItemIndex[_destination] ?? 0,
          onSelectItem: (index) {
            setState(() {
              _selectedItemIndex[_destination] = index;
            });
          },
        );
      case _Destination.clientCompanies:
        return _ClientCompaniesWorkspace(
          viewerProfile: _viewerProfile,
          selectedIndex: _selectedItemIndex[_destination] ?? 0,
          onSelectItem: (index) {
            setState(() {
              _selectedItemIndex[_destination] = index;
            });
          },
        );
      case _Destination.contracts:
        return _ContractsWorkspace(
          viewerProfile: _viewerProfile,
          selectedIndex: _selectedItemIndex[_destination] ?? 0,
          onSelectItem: (index) {
            setState(() {
              _selectedItemIndex[_destination] = index;
            });
          },
        );
      case _Destination.people:
        return _PeopleWorkspace(
          viewerProfile: _viewerProfile,
          selectedIndex: _selectedItemIndex[_destination] ?? 0,
          onFocusPersonChanged: _focusBoardController.selectPerson,
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
      _focusBoardDetached = false;
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
      case _ChoiceTarget.clientCompanies:
        _handleDestination(_Destination.clientCompanies);
        return;
      case _ChoiceTarget.contracts:
        _handleDestination(_Destination.contracts);
        return;
      case _ChoiceTarget.people:
        _handleDestination(_Destination.people);
        return;
      case _ChoiceTarget.network:
        _handleDestination(_Destination.network);
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

  void _openEmployeeProfile(String _) {
    setState(() {
      _destination = _Destination.people;
      _selectedItemIndex[_Destination.people] = 0;
    });
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.page,
    required this.showMenuButton,
    required this.viewerProfile,
    required this.onViewerChanged,
  });

  final _PageInfo page;
  final bool showMenuButton;
  final _ViewerAccessProfile viewerProfile;
  final ValueChanged<_ViewerAccessProfile> onViewerChanged;

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
                  label: viewerProfile.label,
                  icon: Icons.security_outlined,
                  color: viewerProfile.color,
                  background: viewerProfile.color.withValues(alpha: 0.12),
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
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<_ViewerAccessProfile>(
                      value: viewerProfile,
                      borderRadius: BorderRadius.circular(18),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: viewerProfile.color,
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          onViewerChanged(value);
                        }
                      },
                      items: [
                        for (final value in _viewerProfiles)
                          DropdownMenuItem(
                            value: value,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(value.icon, color: value.color, size: 18),
                                const SizedBox(width: 8),
                                Text(value.label),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: viewerProfile.color,
                        child: Text(
                          viewerProfile.badge,
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
                            viewerProfile.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            viewerProfile.consultationSummary,
                            style: const TextStyle(
                              color: _mutedColor,
                              fontSize: 12,
                            ),
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
                  'Home mais limpa, escolha objetiva e acesso direto a Visual Network e modulos operacionais.',
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
                          child: _SpriteMoldIcon(
                            mold: item.mold,
                            state: selected
                                ? _SpriteMoldState.selected
                                : _SpriteMoldState.base,
                            color: selected ? null : const Color(0xFFDCE9E3),
                            size: 24,
                          ),
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
    required this.mold,
    required this.accent,
  });

  final _Destination destination;
  final String shortLabel;
  final String title;
  final String description;
  final String kicker;
  final String sidebarHint;
  final _SpriteMold mold;
  final Color accent;
}

const _pageInfo = {
  _Destination.home: _PageInfo(
    destination: _Destination.home,
    shortLabel: 'Home',
    title: 'Home',
    description: 'Escolha enxuta entre modulos operacionais e Visual Network.',
    kicker:
        'Escolha direta para prestadoras, clientes, contratos, pessoas ou visual network',
    sidebarHint: 'escolha o caminho inicial',
    mold: _SpriteMold.home,
    accent: _tealColor,
  ),
  _Destination.companies: _PageInfo(
    destination: _Destination.companies,
    shortLabel: 'Companies',
    title: 'Companies',
    description: 'Workspace focado em consulta e contexto empresarial.',
    kicker: 'Consulta focada em prestadoras',
    sidebarHint: 'contexto empresarial e contratual',
    mold: _SpriteMold.company,
    accent: _tealColor,
  ),
  _Destination.clientCompanies: _PageInfo(
    destination: _Destination.clientCompanies,
    shortLabel: 'Clients',
    title: 'Clients',
    description:
        'Workspace focado em carteira, multi-prestadora e contexto operacional do cliente.',
    kicker: 'Consulta focada em clientes e carteira ativa',
    sidebarHint: 'carteira, transicao e operacao por cliente',
    mold: _SpriteMold.company,
    accent: _slateColor,
  ),
  _Destination.contracts: _PageInfo(
    destination: _Destination.contracts,
    shortLabel: 'Contracts',
    title: 'Contracts',
    description: 'Workspace focado em contexto contratual e relacoes.',
    kicker: 'Consulta focada em contratos',
    sidebarHint: 'filtros e relacoes principais',
    mold: _SpriteMold.document,
    accent: _amberColor,
  ),
  _Destination.people: _PageInfo(
    destination: _Destination.people,
    shortLabel: 'People',
    title: 'People',
    description: 'Workspace focado em ficha consolidada e historico.',
    kicker: 'Consulta focada em pessoas e historico',
    sidebarHint: 'registro-base e passagens',
    mold: _SpriteMold.people,
    accent: _roseColor,
  ),
  _Destination.network: _PageInfo(
    destination: _Destination.network,
    shortLabel: 'Network',
    title: 'Visual Network',
    description:
        'Business overview da malha relacional, com foco em empresas, contratos e conexoes.',
    kicker: 'Leitura visual de carteiras, contratos e conexoes operacionais',
    sidebarHint: 'visual network canonica',
    mold: _SpriteMold.network,
    accent: _slateColor,
  ),
};

_SpriteMoldState _spriteStateForChoiceTarget(_ChoiceTarget target) {
  return switch (target) {
    _ChoiceTarget.contracts ||
    _ChoiceTarget.network => _SpriteMoldState.selected,
    _ => _SpriteMoldState.base,
  };
}

Color? _spriteTintForChoiceTarget(_ChoiceTarget target, Color fallbackColor) {
  return switch (target) {
    _ChoiceTarget.contracts || _ChoiceTarget.network => null,
    _ChoiceTarget.people => _tealColor,
    _ => fallbackColor,
  };
}
