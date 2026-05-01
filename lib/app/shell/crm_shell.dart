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
  });

  final _PageInfo page;
  final _ViewerAccessProfile viewerProfile;
  final bool showMenuButton;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 920;
        final titleWidth = compact
            ? (constraints.maxWidth - (showMenuButton ? 104 : 68)).clamp(
                220.0,
                520.0,
              )
            : 520.0;
        final searchWidth = compact ? constraints.maxWidth : 420.0;

        return Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 18,
          spacing: 18,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
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
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _deepTealColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.account_tree_outlined,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: titleWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PariFlow Partners',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.8,
                          color: _inkColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${page.shortLabel} | ${page.kicker}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _mutedColor, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  width: searchWidth,
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _lineColor),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search_rounded, color: _mutedColor),
                      SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          'Buscar pessoas, empresas e contratos',
                          style: TextStyle(color: _mutedColor, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
                _Tag(
                  label: _ShellFeatureFlags.activeVariant.rolloutSummary,
                  icon: Icons.flag_outlined,
                  color: _amberColor,
                  background: _amberColor.withValues(alpha: 0.12),
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _lineColor),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Center(
                        child: Icon(
                          Icons.notifications_none_rounded,
                          color: _inkColor,
                        ),
                      ),
                      Positioned(
                        top: -6,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _amberColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            '3',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _lineColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: viewerProfile.color,
                        child: Text(
                          viewerProfile.badge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            viewerProfile.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            viewerProfile.label,
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

class _CrmSidebar extends StatelessWidget {
  const _CrmSidebar({required this.current, required this.onSelect});

  final _Destination current;
  final ValueChanged<_Destination> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PariFlow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Partners',
                  style: TextStyle(
                    color: Color(0xFFE9C18A),
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2.2,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Migracao gradual para o shell CRM sem desligar o fluxo antigo antes da hora.',
                  style: TextStyle(color: Color(0xFFD7E5E0), height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Navegacao principal',
            style: TextStyle(
              color: Color(0xFFA8C0B9),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.separated(
              itemCount: _pageInfo.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _pageInfo.values.elementAt(index);
                final selected = item.destination == current;
                return InkWell(
                  onTap: () => onSelect(item.destination),
                  borderRadius: BorderRadius.circular(26),
                  child: Ink(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: selected
                            ? item.accent.withValues(alpha: 0.70)
                            : Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: selected
                                ? item.accent.withValues(alpha: 0.24)
                                : Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(item.icon, color: Colors.white),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.shortLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.sidebarHint,
                                style: const TextStyle(
                                  color: Color(0xFFCFDDD8),
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
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF0E2E2A),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ponto de atencao',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'A teia nova so entra depois do contrato relacional entre root companies, client companies, contracts e people.',
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
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final card in _summaryCards)
              SizedBox(
                width: pageWidth >= 1320 ? 290 : pageWidth >= 920 ? 250 : double.infinity,
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
                    'Primeiro shell, depois modulos mestre, depois ficha de pessoa e so entao a teia nova em faixas. O contrato relacional continua sendo o bloqueador principal.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
                  ),
                  const SizedBox(height: 18),
                  for (final item in const [
                    'shell novo com feature flag',
                    'empresas, clientes e contratos',
                    'pessoas e vinculos',
                    'teia nova com endpoint canonico',
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
                children: [
                  left,
                  const SizedBox(height: 18),
                  right,
                ],
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D3935), Color(0xFF144842)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: _deepTealColor.withValues(alpha: 0.16),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 1000;

          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Tag(
                label: _ShellVariant.crm.label,
                icon: Icons.auto_awesome_mosaic_outlined,
                color: Colors.white,
                background: Colors.white.withValues(alpha: 0.14),
              ),
              const SizedBox(height: 24),
              const Text(
                'O que voce deseja consultar hoje?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 54,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -2.4,
                  height: 0.98,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Shell CRM em coexistencia controlada. O legado continua vivo, mas esta tela ja organiza a entrada em torno de empresas, contratos, pessoas e rede visual.',
                style: const TextStyle(
                  color: Color(0xFFD5E2DE),
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _Tag(
                    label: viewerProfile.consultationSummary,
                    icon: viewerProfile.canViewSensitive
                        ? Icons.lock_open_rounded
                        : Icons.lock_outline_rounded,
                    color: Colors.white,
                    background: Colors.white.withValues(alpha: 0.14),
                  ),
                  _Tag(
                    label: 'teia nova depende de contrato',
                    icon: Icons.hub_outlined,
                    color: Colors.white,
                    background: Colors.white.withValues(alpha: 0.14),
                  ),
                ],
              ),
            ],
          );

          final side = Container(
            constraints: const BoxConstraints(maxWidth: 360),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leitura de rollout',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  '1. shell paralelo\n2. modulos mestre\n3. ficha de pessoa\n4. contrato da teia\n5. teia nova\n6. desligamento do legado',
                  style: TextStyle(
                    color: Color(0xFFD7E4E0),
                    height: 1.6,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          );

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                copy,
                const SizedBox(height: 24),
                side,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: copy),
              const SizedBox(width: 24),
              Expanded(flex: 4, child: side),
            ],
          );
        },
      ),
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Ink(
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: _lineColor),
          boxShadow: [
            BoxShadow(
              color: _deepTealColor.withValues(alpha: 0.05),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 94,
              height: 94,
              decoration: BoxDecoration(
                color: choice.color.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(choice.icon, size: 42, color: choice.color),
            ),
            const SizedBox(height: 22),
            Text(
              choice.title.replaceFirst('Consultar ', ''),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w600,
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
              decoration: BoxDecoration(
                color: choice.color,
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
