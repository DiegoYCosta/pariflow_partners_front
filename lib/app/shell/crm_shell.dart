part of '../app.dart';

class _CrmShellPage extends StatelessWidget {
  const _CrmShellPage();

  @override
  Widget build(BuildContext context) {
    return const _ShellPreviewPage(variant: _ShellVariant.crm);
  }
}

class _CrmTopBar extends StatelessWidget {
  const _CrmTopBar({
    required this.viewerProfile,
    required this.showMenuButton,
    required this.onViewerChanged,
  });

  final _ViewerAccessProfile viewerProfile;
  final bool showMenuButton;
  final ValueChanged<_ViewerAccessProfile> onViewerChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tight = constraints.maxWidth < 540;
        final compactProfile = constraints.maxWidth < 760;
        final searchWidth = constraints.maxWidth >= 980
            ? 280.0
            : constraints.maxWidth >= 720
            ? 236.0
            : min(220.0, constraints.maxWidth * 0.38);

        return Container(
          height: 54,
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth >= 980 ? 24 : 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(bottom: BorderSide(color: Color(0xFFE7ECEA))),
            boxShadow: [
              BoxShadow(
                color: _inkColor.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              if (showMenuButton) ...[
                _CrmHeaderIconButton(
                  icon: Icons.menu_rounded,
                  tooltip: 'Abrir menu',
                  onPressed: Scaffold.of(context).openDrawer,
                ),
                const SizedBox(width: 8),
              ],
              if (tight)
                const _CrmHeaderIconButton(
                  icon: Icons.search_rounded,
                  tooltip: 'Buscar',
                )
              else
                SizedBox(
                  width: searchWidth,
                  child: const _CrmHeaderSearchBox(),
                ),
              const Spacer(),
              const _CrmHeaderIconButton(
                icon: Icons.notifications_none_rounded,
                tooltip: 'Notificacoes',
                badge: '3',
              ),
              const SizedBox(width: 6),
              const _CrmHeaderIconButton(
                icon: Icons.help_outline_rounded,
                tooltip: 'Ajuda',
              ),
              SizedBox(width: compactProfile ? 8 : 14),
              _CrmHeaderViewerMenu(
                viewerProfile: viewerProfile,
                compact: compactProfile,
                onViewerChanged: onViewerChanged,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CrmHeaderSearchBox extends StatelessWidget {
  const _CrmHeaderSearchBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFFE5EAE8)),
      ),
      child: const Row(
        children: [
          Icon(Icons.search_rounded, color: Color(0xFF98A39E), size: 15),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Search people, companies...',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Color(0xFF98A39E), fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _CrmHeaderIconButton extends StatelessWidget {
  const _CrmHeaderIconButton({
    required this.icon,
    required this.tooltip,
    this.badge,
    this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final String? badge;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: IconButton(
              onPressed: onPressed ?? () {},
              tooltip: tooltip,
              icon: Icon(icon, color: const Color(0xFF1F302C), size: 21),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 34, height: 34),
              style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          if (badge != null)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 14,
                height: 14,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _tealColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CrmHeaderViewerMenu extends StatelessWidget {
  const _CrmHeaderViewerMenu({
    required this.viewerProfile,
    required this.compact,
    required this.onViewerChanged,
  });

  final _ViewerAccessProfile viewerProfile;
  final bool compact;
  final ValueChanged<_ViewerAccessProfile> onViewerChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<_ViewerAccessProfile>(
        value: viewerProfile,
        isDense: true,
        borderRadius: BorderRadius.circular(12),
        dropdownColor: Colors.white,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF1F302C),
          size: 19,
        ),
        onChanged: (value) {
          if (value != null) {
            onViewerChanged(value);
          }
        },
        selectedItemBuilder: (context) {
          return _viewerProfiles.map((value) {
            return _CrmHeaderViewerIdentity(
              viewerProfile: value,
              compact: compact,
            );
          }).toList();
        },
        items: [
          for (final value in _viewerProfiles)
            DropdownMenuItem(
              value: value,
              child: _CrmHeaderViewerIdentity(
                viewerProfile: value,
                compact: false,
              ),
            ),
        ],
      ),
    );
  }
}

class _CrmHeaderViewerIdentity extends StatelessWidget {
  const _CrmHeaderViewerIdentity({
    required this.viewerProfile,
    required this.compact,
  });

  final _ViewerAccessProfile viewerProfile;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return SizedBox(
        width: 34,
        height: 34,
        child: _CrmHeaderAvatar(viewerProfile: viewerProfile),
      );
    }

    return SizedBox(
      width: 150,
      height: 38,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CrmHeaderAvatar(viewerProfile: viewerProfile),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viewerProfile.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF1F302C),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _viewerRoleLabel(viewerProfile),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF6F7D78),
                    fontSize: 9.5,
                    height: 1.1,
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

class _CrmHeaderAvatar extends StatelessWidget {
  const _CrmHeaderAvatar({required this.viewerProfile});

  final _ViewerAccessProfile viewerProfile;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 17,
      backgroundColor: viewerProfile.color.withValues(alpha: 0.16),
      child: CircleAvatar(
        radius: 14,
        backgroundColor: viewerProfile.color,
        child: Text(
          viewerProfile.badge,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

String _viewerRoleLabel(_ViewerAccessProfile profile) {
  if (profile.groups.isEmpty) {
    return 'Public Access';
  }

  return profile.groups.map((group) => group.label).join(' / ');
}

class _CrmSidebar extends StatelessWidget {
  const _CrmSidebar({
    required this.current,
    required this.viewerProfile,
    required this.onSelect,
  });

  final _Destination current;
  final _ViewerAccessProfile viewerProfile;
  final ValueChanged<_Destination> onSelect;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF062F33), Color(0xFF08272C), Color(0xFF041E23)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior:
                Clip.none, // Permite que itens saiam da borda se necessário
            children: [
              const _CrmInteractiveBrand(), // O logo fica na camada de baixo
              Positioned(
                left: 22,
                right: 22,
                bottom: 1, // Coloca a barra exatamente na linha final do logo
                child: Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 22),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: _pageInfo.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = _pageInfo.values.elementAt(index);
                        return _CrmSidebarNavItem(
                          item: item,
                          selected: item.destination == current,
                          onTap: () => onSelect(item.destination),
                        );
                      },
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white.withValues(alpha: 0.10),
                        child: Text(
                          viewerProfile.badge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              viewerProfile.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              viewerProfile.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFC7D5D0),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CrmDashboardContent extends StatelessWidget {
  const _CrmDashboardContent({
    required this.viewerProfile,
    required this.onChooseDestination,
    required this.pageWidth,
  });

  final _ViewerAccessProfile viewerProfile;
  final ValueChanged<_ChoiceTarget> onChooseDestination;
  final double pageWidth;

  @override
  Widget build(BuildContext context) {
    final dashboardChoices = _choices
        .where((choice) => choice.target != _ChoiceTarget.clientCompanies)
        .toList(growable: false);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardsPerRow = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 620
            ? 2
            : 1;
        const spacing = 20.0;
        final cardWidth = cardsPerRow == 1
            ? double.infinity
            : (constraints.maxWidth - (spacing * (cardsPerRow - 1))) /
                  cardsPerRow;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CrmDashboardHero(onChooseDestination: onChooseDestination),
            const SizedBox(height: 22),
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final choice in dashboardChoices)
                  SizedBox(
                    width: cardWidth,
                    child: _CrmEntryCard(
                      choice: choice,
                      onTap: () => onChooseDestination(choice.target),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            const _CrmDashboardQuote(),
          ],
        );
      },
    );
  }
}

class _CrmDashboardHero extends StatelessWidget {
  const _CrmDashboardHero({required this.onChooseDestination});

  final ValueChanged<_ChoiceTarget> onChooseDestination;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 980;
        final headlineSize = stacked ? 36.0 : 44.0;
        final headlineColor = stacked ? _deepTealColor : Colors.white;
        final headlineAccentColor = stacked
            ? const Color(0xFFC8891F)
            : const Color(0xFFE5A64C);
        final accentBarColor = stacked
            ? const Color(0xFFC8891F)
            : const Color(0xFFE5A64C);
        final mobileFeatureWidth = min(constraints.maxWidth * 0.84, 360.0);

        return Semantics(
          label: _ShellVariant.crm.label,
          child: Container(
            width: double.infinity,
            height: stacked ? 560 : 290,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: _deepTealColor.withValues(alpha: 0.16),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                children: [
                  if (stacked) ...[
                    Positioned.fill(
                      child: Image.asset(
                        _crmBannerMobileAsset,
                        fit: BoxFit.cover,
                        alignment: const Alignment(0.56, 0.58),
                      ),
                    ),
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.56,
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(
                            sigmaX: 7.0,
                            sigmaY: 7.0,
                          ),
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
                              const Color(0xF7FFF8F0),
                              const Color(0xE8F8F0DF),
                              const Color(0xD8F1E6CF),
                              const Color(0xA8D0C7A7),
                            ],
                            stops: const [0.0, 0.32, 0.72, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(0.80, -0.08),
                            radius: 0.94,
                            colors: [
                              const Color(0x56A7AE74),
                              const Color(0x18A7AE74),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.34, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -6,
                      bottom: 8,
                      width: mobileFeatureWidth,
                      height: 280,
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(34),
                            boxShadow: [
                              BoxShadow(
                                color: _deepTealColor.withValues(alpha: 0.14),
                                blurRadius: 28,
                                offset: const Offset(0, 20),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.30),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(34),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ImageFiltered(
                                  imageFilter: ImageFilter.blur(
                                    sigmaX: 1.2,
                                    sigmaY: 1.2,
                                  ),
                                  child: Image.asset(
                                    _crmBannerWebAsset,
                                    fit: BoxFit.cover,
                                    alignment: const Alignment(0.74, 0.50),
                                  ),
                                ),
                                Positioned.fill(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          const Color(0xA8F0DFC0),
                                          const Color(0x72E2D4B1),
                                          const Color(0x82C7C08F),
                                        ],
                                        stops: const [0.0, 0.54, 1.0],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: RadialGradient(
                                        center: const Alignment(0.84, 0.18),
                                        radius: 0.90,
                                        colors: [
                                          const Color(0x42A5AE76),
                                          const Color(0x14A5AE76),
                                          Colors.transparent,
                                        ],
                                        stops: const [0.0, 0.34, 1.0],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Positioned.fill(
                      child: Image.asset(
                        _crmBannerWebAsset,
                        fit: BoxFit.cover,
                        alignment: Alignment.centerRight,
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xF205262B),
                              const Color(0xE2124B4E),
                              const Color(0xB3124B4E),
                              const Color(0x5C124B4E),
                            ],
                            stops: const [0.0, 0.34, 0.70, 1.0],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: -8,
                      height: 118,
                      child: Opacity(
                        opacity: 0.92,
                        child: HighTechLightWaves(
                          primaryColor: const Color(0xFF63E6E2),
                          accentColor: const Color(0xFFE4A23B),
                          numberOfWaves: 6,
                          waveAmplitude: 0.108,
                          waveFrequency: 0.038,
                          waveSpeed: 0.0054,
                          pulseSpeedMultiplier: 1.55,
                          pulseSize: 6.8,
                        ),
                      ),
                    ),
                  ],
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.all(stacked ? 24 : 38),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: stacked
                                ? constraints.maxWidth
                                : min(constraints.maxWidth * 0.72, 760.0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    color: headlineColor,
                                    fontSize: headlineSize,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -1.4,
                                    height: 0.98,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: 'O que voce gostaria de\n',
                                    ),
                                    TextSpan(
                                      text: 'consultar hoje?',
                                      style: TextStyle(
                                        color: headlineAccentColor,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: 74,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: accentBarColor,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              const SizedBox(height: 18),
                              _CrmHeroSearch(
                                onChooseDestination: onChooseDestination,
                                accent: stacked ? _tealColor : _slateColor,
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
        );
      },
    );
  }
}

class _CrmHeroSearch extends StatefulWidget {
  const _CrmHeroSearch({
    required this.onChooseDestination,
    required this.accent,
  });

  final ValueChanged<_ChoiceTarget> onChooseDestination;
  final Color accent;

  @override
  State<_CrmHeroSearch> createState() => _CrmHeroSearchState();
}

class _CrmHeroSearchState extends State<_CrmHeroSearch> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ContextSearchField(
      controller: _controller,
      hintText: 'digite sua busca',
      accent: widget.accent,
      maxWidth: 520,
      onSubmitted: (_) => _submit(),
      onClear: () {
        _controller.clear();
        setState(() {});
      },
      onSearch: _submit,
    );
  }

  void _submit() {
    final query = _controller.text.trim().toLowerCase();
    final target = switch (query) {
      final value
          when value.contains('contr') ||
              value.contains('document') ||
              value.contains('doc') =>
        _ChoiceTarget.contracts,
      final value
          when value.contains('client') ||
              value.contains('cliente') ||
              value.contains('carteira') =>
        _ChoiceTarget.clientCompanies,
      final value
          when value.contains('people') ||
              value.contains('employee') ||
              value.contains('pessoa') ||
              value.contains('colaborador') =>
        _ChoiceTarget.people,
      final value
          when value.contains('network') ||
              value.contains('rede') ||
              value.contains('visual') =>
        _ChoiceTarget.network,
      _ => _ChoiceTarget.companies,
    };

    widget.onChooseDestination(target);
  }
}

class _CrmEntryCard extends StatelessWidget {
  const _CrmEntryCard({required this.choice, required this.onTap});

  final _ChoiceCardData choice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final copy = switch (choice.target) {
      _ChoiceTarget.companies => (
        title: 'Companies',
        subtitle: 'Explore and manage\nyour companies',
      ),
      _ChoiceTarget.clientCompanies => (
        title: 'Clients',
        subtitle: 'Open your managed\nclient portfolio',
      ),
      _ChoiceTarget.contracts => (
        title: 'Contracts',
        subtitle: 'View and manage\nyour contracts',
      ),
      _ChoiceTarget.people => (
        title: 'Employees',
        subtitle: 'Manage and connect\nwith your team',
      ),
      _ChoiceTarget.network => (
        title: 'Visual Network',
        subtitle: 'Explore your business\nnetwork visually',
      ),
    };
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Ink(
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0xFFE8ECEB)),
          boxShadow: [
            BoxShadow(
              color: _deepTealColor.withValues(alpha: 0.07),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    choice.color.withValues(alpha: 0.18),
                    choice.color.withValues(alpha: 0.07),
                    Colors.white,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: _SpriteMoldIcon(
                  mold: choice.mold,
                  state: _spriteStateForChoiceTarget(choice.target),
                  color: _spriteTintForChoiceTarget(
                    choice.target,
                    choice.color,
                  ),
                  size: 58,
                  semanticLabel: copy.title,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              copy.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: 23,
                color: _deepTealColor,
                fontWeight: FontWeight.w500,
                letterSpacing: -1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              copy.subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: _mutedColor,
                fontSize: 14,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: _amberColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CrmDashboardQuote extends StatelessWidget {
  const _CrmDashboardQuote();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 860) {
          return Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Text(
              '" Clarity drives better decisions. Insight builds stronger partnerships. "',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: _deepTealColor,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Row(
            children: [
              const Expanded(child: Divider(indent: 120)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '"',
                      style: TextStyle(
                        color: _amberColor,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: min(constraints.maxWidth * 0.56, 560.0),
                      ),
                      child: Text(
                        'Clarity drives better decisions. Insight builds stronger partnerships.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: _deepTealColor,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '"',
                      style: TextStyle(
                        color: _amberColor,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(child: Divider(endIndent: 120)),
            ],
          ),
        );
      },
    );
  }
}

class _CrmInteractiveBrand extends StatefulWidget {
  const _CrmInteractiveBrand();

  @override
  State<_CrmInteractiveBrand> createState() => _CrmInteractiveBrandState();
}

class _CrmInteractiveBrandState extends State<_CrmInteractiveBrand>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shineController;
  bool _hovered = false;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  void _triggerShine() {
    if (!_shineController.isAnimating) {
      _shineController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Configurações para o modo EXPANDIDO (Clique)
    // Logo menor e mais discreto
    double logoScale = _isExpanded ? 0.65 : 1.04;
    double logoTop = _isExpanded ? 14.0 : 42.0;
    double logoLeft = _isExpanded
        ? 8.0
        : 16.0; // Puxado levemente para a esquerda
    double logoOpacity = _isExpanded ? 0.30 : 1.0;

    // Texto (PFP.WEBP) com mais destaque e melhor centralizado
    double textScale = _isExpanded
        ? 1.42
        : 1.12; // Aumentado para mais destaque
    double textTop = _isExpanded ? 72.0 : 66.0;
    double textLeft = _isExpanded
        ? 32.0
        : 96.0; // Ajustado para centralizar o bloco

    const animationDuration = Duration(milliseconds: 600);
    const animationCurve = Curves.easeInOutCubic;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _hovered = true);
        Future.delayed(const Duration(milliseconds: 300), _triggerShine);
      },
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: SizedBox(
          width: double.infinity,
          height: 180,
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              Image.asset(
                _crmLogoBackdropAsset,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                color: const Color(0xFF6DA59A).withValues(alpha: 0.12),
                colorBlendMode: BlendMode.screen,
              ),
              // FUNDO COM BRILHO DOURADO SUTIL
              AnimatedContainer(
                duration: animationDuration,
                curve: animationCurve,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.5, -0.1),
                    radius: _hovered ? 2.0 : 1.0,
                    colors: [
                      const Color(0xFFFFD700).withValues(
                        alpha: (_hovered || _isExpanded) ? 0.03 : 0.01,
                      ),
                      const Color(0xFF2D7872).withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // ESCALA GLOBAL PARA HOVER (Acompanha os novos tamanhos)
              AnimatedScale(
                scale: _hovered ? 1.18 : 1.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  transform: Matrix4.identity()
                    ..translateByDouble(0, _hovered ? -2.0 : 0.0, 0, 1),
                  child: Stack(
                    children: [
                      _CrmBrandArtwork(
                        shadowOpacity: _hovered ? 0.40 : 0.35,
                        logoScale: logoScale,
                        logoTop: logoTop,
                        logoLeft: logoLeft,
                        logoOpacity: logoOpacity,
                        textScale: textScale,
                        textTop: textTop,
                        textLeft: textLeft,
                        duration: animationDuration,
                        curve: animationCurve,
                      ),
                      AnimatedBuilder(
                        animation: _shineController,
                        builder: (context, child) {
                          final value = Curves.easeInOutSine.transform(
                            _shineController.value,
                          );
                          final visible = _shineController.isAnimating
                              ? sin(value * pi)
                              : 0.0;
                          return IgnorePointer(
                            child: Opacity(
                              opacity: (visible * 0.35)
                                  .clamp(0.0, 1.0)
                                  .toDouble(),
                              child: ShaderMask(
                                blendMode: BlendMode.srcATop,
                                shaderCallback: (rect) {
                                  final x = -1.5 + (value * 3.0);
                                  return LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withValues(alpha: 0.20),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.5, 1.0],
                                  ).createShader(rect);
                                },
                                child: _CrmBrandArtwork(
                                  shadowOpacity: 0,
                                  shinePass: true,
                                  logoScale: logoScale,
                                  logoTop: logoTop,
                                  logoLeft: logoLeft,
                                  logoOpacity: logoOpacity,
                                  textScale: textScale,
                                  textTop: textTop,
                                  textLeft: textLeft,
                                  duration: animationDuration,
                                  curve: animationCurve,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CrmBrandArtwork extends StatelessWidget {
  const _CrmBrandArtwork({
    required this.shadowOpacity,
    required this.logoScale,
    required this.logoTop,
    required this.logoLeft,
    required this.logoOpacity,
    required this.textScale,
    required this.textTop,
    required this.textLeft,
    required this.duration,
    required this.curve,
    this.shinePass = false,
  });

  final double shadowOpacity;
  final double logoScale;
  final double logoTop;
  final double logoLeft;
  final double logoOpacity;
  final double textScale;
  final double textTop;
  final double textLeft;
  final Duration duration;
  final Curve curve;
  final bool shinePass;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedPositioned(
          duration: duration,
          curve: curve,
          left: logoLeft,
          top: logoTop,
          width: 104 * logoScale,
          height: 104 * logoScale,
          child: AnimatedOpacity(
            duration: duration,
            curve: curve,
            opacity: logoOpacity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: shinePass
                    ? const []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: shadowOpacity * 0.7,
                          ),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
              ),
              child: Image.asset(_crmLogoSymbolAsset, fit: BoxFit.contain),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: duration,
          curve: curve,
          left: textLeft,
          right: 18,
          top: textTop,
          height: 58 * textScale,
          child: DecoratedBox(
            decoration: BoxDecoration(
              boxShadow: shinePass
                  ? const []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: shadowOpacity * 0.6,
                        ),
                        blurRadius: 14,
                        offset: const Offset(0, 7),
                      ),
                    ],
            ),
            child: Image.asset(_crmLogoWordmarkAsset, fit: BoxFit.contain),
          ),
        ),
      ],
    );
  }
}

class _CrmSidebarNavItem extends StatefulWidget {
  const _CrmSidebarNavItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _PageInfo item;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_CrmSidebarNavItem> createState() => _CrmSidebarNavItemState();
}

class _CrmSidebarNavItemState extends State<_CrmSidebarNavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered && !selected ? 1.025 : 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.08),
                      blurRadius: 24,
                      spreadRadius: 0.5,
                    ),
                  ]
                : _hovered
                ? [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(26),
            child: Ink(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(
                        colors: [Color(0xFF1F4A50), Color(0xFF173F46)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: selected
                    ? null
                    : _hovered
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: selected
                      ? const Color(0xFFE0A64C).withValues(alpha: 0.18)
                      : _hovered
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.transparent,
                  width: selected ? 1.0 : 1,
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (selected)
                    Positioned(
                      left: -8,
                      top: 14,
                      bottom: 14,
                      child: Container(
                        width: 2.5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0A64C).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFE0A64C,
                              ).withValues(alpha: 0.3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (selected)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            gradient: RadialGradient(
                              center: const Alignment(-0.92, -0.05),
                              radius: 1.15,
                              colors: [
                                Colors.white.withValues(alpha: 0.09),
                                const Color(0xFFF7F3EA).withValues(alpha: 0.05),
                                Colors.transparent,
                              ],
                              stops: const [0, 0.18, 0.68],
                            ),
                          ),
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      _SpriteMoldIcon(
                        mold: widget.item.mold,
                        state: selected
                            ? _SpriteMoldState.selected
                            : _SpriteMoldState.base,
                        color: selected ? null : const Color(0xFFDCE9E3),
                        size: 34,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOutCubic,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: selected
                                ? 17
                                : _hovered
                                ? 16.5
                                : 16,
                            letterSpacing: -0.2,
                          ),
                          child: Text(widget.item.shortLabel),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CrmMetricCard extends StatelessWidget {
  const _CrmMetricCard({required this.card});

  final _SummaryCardData card;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Tag(
            label: card.label,
            leading: _SpriteMoldIcon(mold: card.mold, size: 18),
            color: card.color,
            background: card.color.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 16),
          Text(card.value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            card.description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
          ),
        ],
      ),
    );
  }
}

class _CrmSectionHeader extends StatelessWidget {
  const _CrmSectionHeader({required this.page});

  final _PageInfo page;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 14,
      spacing: 14,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(page.title, style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 10),
            Text(
              page.description,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: _mutedColor),
            ),
          ],
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Tag(
              label: page.shortLabel,
              leading: _SpriteMoldIcon(
                mold: page.mold,
                state: _SpriteMoldState.selected,
                size: 18,
              ),
              color: page.accent,
              background: page.accent.withValues(alpha: 0.12),
            ),
            _Tag(
              label: 'coexistencia com legado',
              icon: Icons.compare_arrows_outlined,
              color: _slateColor,
              background: _slateColor.withValues(alpha: 0.12),
            ),
          ],
        ),
      ],
    );
  }
}
