part of '../app.dart';

enum _Destination {
  home,
  companies,
  clientCompanies,
  contracts,
  people,
  network,
  timeline,
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
  _ViewerAccessProfile _viewerProfile = _sessionViewerProfileFallback;
  _NetworkFilterState _networkFilters = const _NetworkFilterState();
  bool _showAdvancedNetworkFilters = false;
  bool _focusBoardDetached = false;
  bool _focusBoardSlotVisible = true;
  double _focusBoardSlotScale = 1.0;
  Offset? _focusBoardFloatingOffset;
  Size? _focusBoardFloatingSize;
  bool _focusBoardFloatingMaximized = false;
  bool _focusBoardFloatingWindowVisible = false;
  bool _focusBoardDockCandidate = false;
  bool _focusBoardDockCancelledForDrag = false;
  final FocusNode _focusBoardDockKeyboardFocusNode = FocusNode(
    debugLabel: 'focus-board-dock-keyboard',
  );
  Timer? _focusBoardWindowMonitor;
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
    unawaited(_loadViewerProfile());
  }

  @override
  void dispose() {
    _focusBoardWindowMonitor?.cancel();
    _focusBoardDockKeyboardFocusNode.dispose();
    _focusBoardController.dispose();
    super.dispose();
  }

  Future<void> _loadViewerProfile() async {
    try {
      final session = await ApiClient().ensureDevelopmentSession();
      if (!mounted) {
        return;
      }
      setState(() {
        _viewerProfile = _viewerProfileFromSession(session);
      });
    } on ApiException {
      if (!mounted) {
        return;
      }
      setState(() {
        _viewerProfile = _publicViewerProfile;
      });
    }
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
                          child: _buildCrmWorkspaceRegion(
                            page,
                            width,
                            showSidebar,
                          ),
                        ),
                      ],
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

  Widget _buildCrmWorkspaceRegion(
    _PageInfo page,
    double width,
    bool showSidebar,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sideSlot = constraints.maxWidth >= 980;
        final workspace = _buildCrmWorkspaceScroll(page, width, showSidebar);
        final baseExtent = sideSlot
            ? min(430.0, max(360.0, constraints.maxWidth * 0.24))
            : min(360.0, max(260.0, constraints.maxHeight * 0.34));
        final slotScale = _focusBoardSlotScale.clamp(0.8, 1.2).toDouble();
        final slotExtent = baseExtent * slotScale;
        final panelExtent = sideSlot
            ? constraints.maxHeight
            : min(constraints.maxWidth - 24, max(320.0, constraints.maxWidth));
        final slotRect = sideSlot
            ? Rect.fromLTWH(
                constraints.maxWidth - slotExtent,
                0,
                slotExtent,
                panelExtent,
              )
            : Rect.fromLTWH(
                0,
                constraints.maxHeight - slotExtent,
                constraints.maxWidth,
                slotExtent,
              );
        final slot = _PersistentFocusBoardDock(
          controller: _focusBoardController,
          viewerProfile: _viewerProfile,
          detached: _focusBoardDetached,
          visible: _focusBoardSlotVisible,
          resizeAxis: sideSlot ? Axis.horizontal : Axis.vertical,
          extent: slotExtent,
          panelExtent: panelExtent,
          onExtentChanged: (value) {
            setState(() {
              _focusBoardSlotScale = (value / baseExtent)
                  .clamp(0.8, 1.2)
                  .toDouble();
            });
          },
          onToggleVisibility: () {
            setState(() {
              _focusBoardSlotVisible = !_focusBoardSlotVisible;
            });
          },
          onDetach: () {
            final openResult = openFocusBoardStandaloneWindow(
              _focusBoardStandaloneUri(),
            );
            final openedInBrowser = openResult.openedInBrowser;
            setState(() {
              _focusBoardDetached = true;
              _focusBoardSlotVisible = false;
              _focusBoardFloatingMaximized = false;
              _focusBoardFloatingWindowVisible = !openedInBrowser;
              if (_focusBoardFloatingWindowVisible) {
                _focusBoardFloatingSize ??= Size(
                  min(780.0, constraints.maxWidth - 48),
                  min(660.0, constraints.maxHeight - 48),
                );
                _focusBoardFloatingOffset ??= Offset(
                  max(
                    18.0,
                    constraints.maxWidth - _focusBoardFloatingSize!.width - 28,
                  ),
                  22,
                );
              }
            });
            if (openedInBrowser) {
              _startFocusBoardWindowMonitor();
            } else {
              _focusBoardWindowMonitor?.cancel();
            }
            _showFocusBoardOpenFeedback(openResult);
          },
          onAttach: () {
            closeFocusBoardStandaloneWindow();
            _focusBoardWindowMonitor?.cancel();
            setState(() {
              _focusBoardDetached = false;
              _focusBoardSlotVisible = true;
              _focusBoardFloatingWindowVisible = false;
            });
          },
        );

        final body = sideSlot
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: workspace),
                  SizedBox(width: slotExtent, child: slot),
                ],
              )
            : Column(
                children: [
                  Expanded(child: workspace),
                  SizedBox(height: slotExtent, child: slot),
                ],
              );

        return Stack(
          children: [
            body,
            if (_focusBoardDockCandidate && _focusBoardFloatingWindowVisible)
              _buildFocusBoardDockTargetOverlay(slotRect),
            if (_focusBoardDetached && _focusBoardFloatingWindowVisible)
              _buildDetachedFocusBoardWindow(constraints, slotRect),
          ],
        );
      },
    );
  }

  Widget _buildDetachedFocusBoardWindow(
    BoxConstraints constraints,
    Rect slotRect,
  ) {
    final defaultSize = Size(
      min(780.0, constraints.maxWidth - 48),
      min(660.0, constraints.maxHeight - 48),
    );
    final size = _focusBoardFloatingMaximized
        ? Size(constraints.maxWidth - 36, constraints.maxHeight - 36)
        : _clampFloatingSize(
            _focusBoardFloatingSize ?? defaultSize,
            constraints,
          );
    final offset = _focusBoardFloatingMaximized
        ? const Offset(18, 18)
        : _clampFloatingOffset(
            _focusBoardFloatingOffset ?? const Offset(24, 24),
            size,
            constraints,
          );

    return Positioned(
      left: offset.dx,
      top: offset.dy,
      width: size.width,
      height: size.height,
      child: KeyboardListener(
        focusNode: _focusBoardDockKeyboardFocusNode,
        onKeyEvent: (event) {
          if (event is! KeyDownEvent ||
              event.logicalKey != LogicalKeyboardKey.escape ||
              !_focusBoardDockCandidate) {
            return;
          }
          setState(() {
            _focusBoardDockCandidate = false;
            _focusBoardDockCancelledForDrag = true;
          });
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Acoplamento cancelado para este movimento.'),
              ),
            );
        },
        child: _FocusBoardFloatingWindow(
          controller: _focusBoardController,
          viewerProfile: _viewerProfile,
          maximized: _focusBoardFloatingMaximized,
          onMoveStart: () {
            _focusBoardDockKeyboardFocusNode.requestFocus();
            setState(() {
              _focusBoardDockCandidate = false;
              _focusBoardDockCancelledForDrag = false;
            });
          },
          onMove: (delta) {
            if (_focusBoardFloatingMaximized) {
              return;
            }
            final nextOffset = _clampFloatingOffset(
              offset + delta,
              size,
              constraints,
            );
            final nextAnchor = Offset(
              nextOffset.dx + size.width / 2,
              nextOffset.dy + 22,
            );
            setState(() {
              _focusBoardFloatingOffset = nextOffset;
              _focusBoardDockCandidate =
                  !_focusBoardDockCancelledForDrag &&
                  slotRect.inflate(36).contains(nextAnchor);
            });
          },
          onMoveEnd: () {
            if (_focusBoardDockCandidate && !_focusBoardDockCancelledForDrag) {
              closeFocusBoardStandaloneWindow();
              _focusBoardWindowMonitor?.cancel();
              setState(() {
                _focusBoardDetached = false;
                _focusBoardSlotVisible = true;
                _focusBoardFloatingMaximized = false;
                _focusBoardFloatingWindowVisible = false;
                _focusBoardDockCandidate = false;
                _focusBoardDockCancelledForDrag = false;
              });
              return;
            }
            closeFocusBoardStandaloneWindow();
            _focusBoardWindowMonitor?.cancel();
            setState(() {
              _focusBoardDockCandidate = false;
              _focusBoardDockCancelledForDrag = false;
            });
          },
          onResize: (delta) {
            if (_focusBoardFloatingMaximized) {
              return;
            }
            setState(() {
              _focusBoardFloatingSize = _clampFloatingSize(
                Size(size.width + delta.dx, size.height + delta.dy),
                constraints,
              );
              _focusBoardDockCandidate = false;
              _focusBoardDockCancelledForDrag = false;
            });
          },
          onToggleMaximized: () {
            setState(() {
              _focusBoardFloatingMaximized = !_focusBoardFloatingMaximized;
              _focusBoardDockCandidate = false;
              _focusBoardDockCancelledForDrag = false;
            });
          },
          onAttach: () {
            closeFocusBoardStandaloneWindow();
            _focusBoardWindowMonitor?.cancel();
            setState(() {
              _focusBoardDetached = false;
              _focusBoardSlotVisible = true;
              _focusBoardFloatingMaximized = false;
              _focusBoardFloatingWindowVisible = false;
              _focusBoardDockCandidate = false;
              _focusBoardDockCancelledForDrag = false;
            });
          },
        ),
      ),
    );
  }

  Widget _buildFocusBoardDockTargetOverlay(Rect slotRect) {
    final rect = slotRect.deflate(12);
    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _deepTealColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _deepTealColor, width: 2),
          ),
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _deepTealColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Text(
                  'Solte para acoplar automaticamente - Esc cancela',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Size _clampFloatingSize(Size value, BoxConstraints constraints) {
    return Size(
      value.width
          .clamp(360.0, max(360.0, constraints.maxWidth - 36))
          .toDouble(),
      value.height
          .clamp(360.0, max(360.0, constraints.maxHeight - 36))
          .toDouble(),
    );
  }

  Offset _clampFloatingOffset(
    Offset value,
    Size size,
    BoxConstraints constraints,
  ) {
    return Offset(
      value.dx
          .clamp(12.0, max(12.0, constraints.maxWidth - size.width - 12))
          .toDouble(),
      value.dy
          .clamp(12.0, max(12.0, constraints.maxHeight - size.height - 12))
          .toDouble(),
    );
  }

  Widget _buildCrmWorkspaceScroll(
    _PageInfo page,
    double width,
    bool showSidebar,
  ) {
    return SingleChildScrollView(
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
            maxWidth: _destination == _Destination.network
                ? double.infinity
                : 1560,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildWorkspaceContent(page, width)],
          ),
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
      case _Destination.timeline:
        return _TimelineWorkspace(viewerProfile: _viewerProfile);
    }
  }

  void _handleDestination(_Destination destination) {
    final keepFocusBoardDetached = isFocusBoardStandaloneWindowOpen();
    setState(() {
      _destination = destination;
      _focusBoardDetached = keepFocusBoardDetached;
      _focusBoardSlotVisible = !keepFocusBoardDetached;
      if (!keepFocusBoardDetached) {
        _focusBoardFloatingWindowVisible = false;
        _focusBoardWindowMonitor?.cancel();
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

  Uri _focusBoardStandaloneUri() {
    final queryParameters = Map<String, String>.of(Uri.base.queryParameters)
      ..remove('focusPerson');
    return Uri.base.replace(
      queryParameters: queryParameters,
      fragment: _focusBoardStandaloneRoute,
    );
  }

  void _startFocusBoardWindowMonitor() {
    _focusBoardWindowMonitor?.cancel();
    _focusBoardWindowMonitor = Timer.periodic(
      const Duration(milliseconds: 800),
      (timer) {
        if (isFocusBoardStandaloneWindowOpen()) {
          return;
        }
        timer.cancel();
        if (!mounted ||
            !_focusBoardDetached ||
            _focusBoardFloatingWindowVisible) {
          return;
        }
        setState(() {
          _focusBoardDetached = false;
          _focusBoardSlotVisible = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Focus Board fechado e acoplado novamente.'),
          ),
        );
      },
    );
  }

  void _showFocusBoardOpenFeedback(FocusBoardWindowOpenResult result) {
    final message = switch (result.status) {
      FocusBoardWindowOpenStatus.opened =>
        'Focus Board aberto em janela separada. Ao fechar, ele volta para o slot.',
      FocusBoardWindowOpenStatus.focusedExisting =>
        'Focus Board ja estava aberto; foquei a janela existente.',
      FocusBoardWindowOpenStatus.blocked =>
        'O navegador bloqueou a janela do Focus Board. Libere pop-ups para este site.',
      FocusBoardWindowOpenStatus.unsupported =>
        'Este ambiente nao abriu uma janela separada. Use a janela interna temporaria.',
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
                        for (final value in _viewerProfileOptions(
                          viewerProfile,
                        ))
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
  _Destination.timeline: _PageInfo(
    destination: _Destination.timeline,
    shortLabel: 'Timeline',
    title: 'Timeline',
    description:
        'Historico operacional mensal com calendario, registros e vinculos.',
    kicker: 'Logbook mensal para operacao, contratos, pessoas e empresas',
    sidebarHint: 'registros mensais e historico',
    mold: _SpriteMold.calendar,
    accent: _tealColor,
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
