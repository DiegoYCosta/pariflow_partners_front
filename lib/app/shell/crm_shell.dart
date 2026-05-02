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
        final compact = constraints.maxWidth < 920;
        final today = DateTime.now();
        final title = page.destination == _Destination.home
            ? '${_greeting(today)}, ${viewerProfile.name.split(' ').first}'
            : page.title;
        final subtitle = page.destination == _Destination.home
            ? '${_formatDate(today)} | shell CRM com layout institucional'
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
                Container(
                  width: 58,
                  height: 58,
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
      return 'Bom dia';
    }
    if (now.hour < 18) {
      return 'Boa tarde';
    }
    return 'Boa noite';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
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
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = _pageInfo.values.elementAt(index);
                  final selected = item.destination == current;
                  return InkWell(
                    onTap: () => onSelect(item.destination),
                    borderRadius: BorderRadius.circular(28),
                    child: Ink(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white.withValues(alpha: 0.10)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: selected
                              ? Colors.white.withValues(alpha: 0.14)
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: selected
                                  ? item.accent.withValues(alpha: 0.18)
                                  : Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(
                              item.icon,
                              color: selected
                                  ? const Color(0xFFE2A041)
                                  : Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.shortLabel,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: selected ? 18 : 17,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.sidebarHint,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFFC8D8D3),
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
    final cardsPerRow = pageWidth >= 1500
        ? 4
        : pageWidth >= 1100
        ? 2
        : 1;
    final cardWidth = cardsPerRow == 4
        ? 270.0
        : cardsPerRow == 2
        ? (pageWidth - 60) / 2
        : double.infinity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CrmDashboardHero(viewerProfile: viewerProfile),
        const SizedBox(height: 28),
        Wrap(
          spacing: 18,
          runSpacing: 18,
          children: [
            for (final choice in _choices)
              SizedBox(
                width: cardWidth,
                child: _CrmEntryCard(
                  choice: choice,
                  onTap: () => onChooseDestination(choice.target),
                ),
              ),
          ],
        ),
        const SizedBox(height: 28),
        const Center(
          child: Text(
            'Clareza gera decisoes melhores. Contexto gera parcerias mais fortes.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _deepTealColor,
              fontSize: 22,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final card in _summaryCards)
              SizedBox(
                width: pageWidth >= 1320
                    ? 290
                    : pageWidth >= 920
                    ? 250
                    : double.infinity,
                child: _CrmMetricCard(card: card),
              ),
          ],
        ),
        const SizedBox(height: 28),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 1080;

            final left = _Panel(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ordem sensata de rollout',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Primeiro shell, depois modulos mestre, depois ficha de pessoa e so entao a Visual Network canonica. O contrato relacional continua sendo o bloqueador principal.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
                  ),
                  const SizedBox(height: 18),
                  for (final item in const [
                    'shell novo com feature flag',
                    'empresas, clientes e contratos',
                    'pessoas e vinculos',
                    'visual network com endpoint canonico',
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: _amberColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(item),
                        ],
                      ),
                    ),
                ],
              ),
            );

            final right = _Panel(
              padding: const EdgeInsets.all(24),
              child: _AccessContextPanel(viewerProfile: viewerProfile),
            );

            if (stacked) {
              return Column(
                children: [left, const SizedBox(height: 18), right],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: left),
                const SizedBox(width: 18),
                Expanded(flex: 4, child: right),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _CrmDashboardHero extends StatelessWidget {
  const _CrmDashboardHero({required this.viewerProfile});

  final _ViewerAccessProfile viewerProfile;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 980;
        final bannerAsset = stacked
            ? _crmBannerMobileAsset
            : _crmBannerWebAsset;
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
        final showHeroMetaTags = constraints.maxWidth < 0;

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
                      _crmBackgroundAsset,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    width: constraints.maxWidth * 0.90,
                    height: 352,
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: 0.82,
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(
                            sigmaX: 0.9,
                            sigmaY: 0.9,
                          ),
                          child: Image.asset(
                            bannerAsset,
                            fit: BoxFit.cover,
                            alignment: const Alignment(0.42, 1.0),
                          ),
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
                            const Color(0xFDFFFDF8),
                            const Color(0xF6FFF9F0),
                            const Color(0xD9FFF7EE),
                            const Color(0xA9FFF7EE),
                          ],
                          stops: const [0.0, 0.30, 0.70, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0.86, -0.18),
                          radius: 0.86,
                          colors: [
                            const Color(0x58F3C97C),
                            const Color(0x26F3C97C),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.34, 1.0],
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Positioned.fill(
                    child: Image.asset(
                      bannerAsset,
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
                              if (showHeroMetaTags) ...[
                                const SizedBox(height: 18),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    _Tag(
                                      label: viewerProfile.consultationSummary,
                                      icon: viewerProfile.canViewSensitive
                                          ? Icons.lock_open_rounded
                                          : Icons.lock_outline_rounded,
                                      color: chipColor,
                                      background: chipBackground,
                                    ),
                                    _Tag(
                                      label: _ShellFeatureFlags
                                          .activeVariant
                                          .rolloutSummary,
                                      icon: Icons.flag_outlined,
                                      color: chipColor,
                                      background: chipBackground,
                                    ),
                                    _Tag(
                                      label:
                                          '${_networkGraphContractPreview.lanes.length} faixas da visual network',
                                      icon: Icons.view_week_outlined,
                                      color: chipColor,
                                      background: chipBackground,
                                    ),
                                  ],
                                ),
                              ],
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
    final title = switch (choice.target) {
      _ChoiceTarget.companies => 'Empresas',
      _ChoiceTarget.clientCompanies => 'Clientes',
      _ChoiceTarget.contracts => 'Contratos',
      _ChoiceTarget.people => 'Pessoas',
      _ChoiceTarget.network => 'Visual Network',
    };
    final iconColor = switch (choice.target) {
      _ChoiceTarget.people => _tealColor,
      _ChoiceTarget.network => _amberColor,
      _ => choice.color,
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(34),
      child: Ink(
        padding: const EdgeInsets.fromLTRB(30, 34, 30, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(34),
          border: Border.all(color: _lineColor),
          boxShadow: [
            BoxShadow(
              color: _deepTealColor.withValues(alpha: 0.06),
              blurRadius: 28,
              offset: const Offset(0, 12),
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
                    choice.color.withValues(alpha: 0.16),
                    choice.color.withValues(alpha: 0.06),
                    Colors.white,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(choice.icon, size: 50, color: iconColor),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                letterSpacing: -1.1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              choice.description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: _mutedColor),
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
            icon: card.icon,
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
              icon: page.icon,
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
