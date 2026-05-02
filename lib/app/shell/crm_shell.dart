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
    required this.page,
    required this.viewerProfile,
    required this.showMenuButton,
    required this.onViewerChanged,
  });

  final _PageInfo page;
  final _ViewerAccessProfile viewerProfile;
  final bool showMenuButton;
  final ValueChanged<_ViewerAccessProfile> onViewerChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isHome = page.destination == _Destination.home;
        final compact = constraints.maxWidth < 920;
        final today = DateTime.now();
        final title = isHome
            ? '${_greeting(today)}, ${viewerProfile.name.split(' ').first}'
            : page.title;
        final subtitle = isHome
            ? _formatDate(today)
            : '${page.shortLabel} | ${page.kicker}';

        return Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 18,
          spacing: 18,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showMenuButton)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Builder(
                      builder: (context) => IconButton.filledTonal(
                        onPressed: Scaffold.of(context).openDrawer,
                        icon: const Icon(Icons.menu_rounded),
                      ),
                    ),
                  ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: compact ? constraints.maxWidth - 88 : 540,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.9,
                          color: _inkColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _mutedColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (isHome) ...[
                  const _CrmToolbarGlyph(icon: Icons.search_rounded),
                  const _CrmToolbarGlyph(
                    icon: Icons.notifications_none_rounded,
                    badge: '3',
                  ),
                ] else ...[
                  const _CrmIconAction(icon: Icons.search_rounded),
                  const _CrmIconAction(
                    icon: Icons.notifications_none_rounded,
                    badge: '3',
                  ),
                  _CrmViewerChip(
                    viewerProfile: viewerProfile,
                    compact: compact,
                    onViewerChanged: onViewerChanged,
                  ),
                ],
                Container(
                  width: isHome ? 60 : 58,
                  height: isHome ? 60 : 58,
                  decoration: const BoxDecoration(
                    color: _deepTealColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _greeting(DateTime now) {
    if (now.hour < 12) {
      return 'Good morning';
    }
    if (now.hour < 18) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }

  String _formatDate(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(_crmLogoAsset, width: 210, fit: BoxFit.contain),
            const SizedBox(height: 26),
            Container(
              width: double.infinity,
              height: 1,
              color: Colors.white.withValues(alpha: 0.10),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: ListView.separated(
                itemCount: _pageInfo.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final item = _pageInfo.values.elementAt(index);
                  final selected = item.destination == current;
                  return InkWell(
                    onTap: () => onSelect(item.destination),
                    borderRadius: BorderRadius.circular(26),
                    child: Ink(
                      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF1C464B)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: selected
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.transparent,
                        ),
                      ),
                      child: Stack(
                        children: [
                          if (selected)
                            Positioned(
                              left: -22,
                              top: 6,
                              bottom: 6,
                              child: Container(
                                width: 4,
                                decoration: BoxDecoration(
                                  color: _amberColor,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          Row(
                            children: [
                              _SpriteMoldIcon(
                                mold: item.mold,
                                state: selected
                                    ? _SpriteMoldState.selected
                                    : _SpriteMoldState.base,
                                color: selected
                                    ? null
                                    : const Color(0xFFDCE9E3),
                                size: 34,
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Text(
                                  item.shortLabel,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: selected ? 18 : 17,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              width: double.infinity,
              height: 1,
              color: Colors.white.withValues(alpha: 0.10),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white.withValues(alpha: 0.10),
                  child: Text(
                    viewerProfile.badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
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
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        viewerProfile.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFC7D5D0),
                          fontSize: 14,
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
        final cardsPerRow = constraints.maxWidth >= 1380
            ? 4
            : constraints.maxWidth >= 800
            ? 2
            : 1;
        const spacing = 22.0;
        final cardWidth = cardsPerRow == 1
            ? double.infinity
            : (constraints.maxWidth - (spacing * (cardsPerRow - 1))) /
                  cardsPerRow;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _CrmDashboardHero(),
            const SizedBox(height: 40),
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
            const SizedBox(height: 40),
            const _CrmDashboardQuote(),
          ],
        );
      },
    );
  }
}

class _CrmDashboardHero extends StatelessWidget {
  const _CrmDashboardHero();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 980;
        final headlineSize = stacked ? 44.0 : 60.0;
        final headlineColor = stacked ? _deepTealColor : Colors.white;
        final headlineAccentColor = stacked
            ? const Color(0xFFC8891F)
            : const Color(0xFFE5A64C);
        final chipColor = stacked ? _deepTealColor : Colors.white;
        final chipBackground = stacked
            ? Colors.white.withValues(alpha: 0.78)
            : Colors.white.withValues(alpha: 0.14);
        final accentBarColor = stacked
            ? const Color(0xFFC8891F)
            : const Color(0xFFE5A64C);
        final mobileFeatureWidth = min(constraints.maxWidth * 0.84, 360.0);

        return Container(
          width: double.infinity,
          height: stacked ? 600 : 418,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: _deepTealColor.withValues(alpha: 0.16),
                blurRadius: 36,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
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
                    bottom: 10,
                    width: mobileFeatureWidth,
                    height: 324,
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
                    height: 152,
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
                  child: IgnorePointer(
                    child: Padding(
                      padding: EdgeInsets.all(stacked ? 28 : 42),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: stacked
                                ? constraints.maxWidth
                                : min(constraints.maxWidth * 0.58, 760.0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Tag(
                                label: _ShellVariant.crm.label,
                                icon: Icons.auto_awesome_mosaic_outlined,
                                color: chipColor,
                                background: chipBackground,
                              ),
                              const SizedBox(height: 18),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    color: headlineColor,
                                    fontSize: headlineSize,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -2.4,
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
                              const SizedBox(height: 18),
                              Container(
                                width: 92,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: accentBarColor,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
      borderRadius: BorderRadius.circular(32),
      child: Ink(
        padding: const EdgeInsets.fromLTRB(28, 34, 28, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFFE8ECEB)),
          boxShadow: [
            BoxShadow(
              color: _deepTealColor.withValues(alpha: 0.07),
              blurRadius: 34,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 122,
              height: 122,
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
                  color: _spriteTintForChoiceTarget(choice.target, choice.color),
                  size: 70,
                  semanticLabel: copy.title,
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              copy.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: 26,
                color: _deepTealColor,
                fontWeight: FontWeight.w500,
                letterSpacing: -1.1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              copy.subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: _mutedColor,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            Container(
              width: 58,
              height: 58,
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
          return Text(
            '" Clarity drives better decisions. Insight builds stronger partnerships. "',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: _deepTealColor,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
          );
        }

        return Row(
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
        );
      },
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

class _CrmIconAction extends StatelessWidget {
  const _CrmIconAction({required this.icon, this.badge});

  final IconData icon;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.70),
              shape: BoxShape.circle,
              border: Border.all(color: _lineColor),
            ),
            child: Icon(icon, color: _deepTealColor, size: 28),
          ),
          if (badge != null)
            Positioned(
              top: -4,
              right: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(
                  color: _amberColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CrmToolbarGlyph extends StatelessWidget {
  const _CrmToolbarGlyph({required this.icon, this.badge});

  final IconData icon;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(child: Icon(icon, color: _deepTealColor, size: 34)),
          if (badge != null)
            Positioned(
              top: -4,
              right: -2,
              child: Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: _amberColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CrmViewerChip extends StatelessWidget {
  const _CrmViewerChip({
    required this.viewerProfile,
    required this.compact,
    required this.onViewerChanged,
  });

  final _ViewerAccessProfile viewerProfile;
  final bool compact;
  final ValueChanged<_ViewerAccessProfile> onViewerChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _lineColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<_ViewerAccessProfile>(
          value: viewerProfile,
          borderRadius: BorderRadius.circular(20),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: viewerProfile.color,
          ),
          onChanged: (value) {
            if (value != null) {
              onViewerChanged(value);
            }
          },
          selectedItemBuilder: (context) {
            return _viewerProfiles.map((value) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: value.color,
                    child: Text(
                      value.badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    compact ? value.name.split(' ').first : value.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              );
            }).toList();
          },
          items: [
            for (final value in _viewerProfiles)
              DropdownMenuItem(
                value: value,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: value.color,
                      child: Text(
                        value.badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          value.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          value.label,
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
      ),
    );
  }
}
