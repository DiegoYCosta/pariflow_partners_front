part of '../../app/app.dart';

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.viewerProfile,
    required this.onChooseDestination,
    required this.pageWidth,
  });

  final _ViewerAccessProfile viewerProfile;
  final ValueChanged<_ChoiceTarget> onChooseDestination;
  final double pageWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ChoiceHero(onChooseDestination: onChooseDestination),
        const SizedBox(height: 24),
        _HomeOverview(
          viewerProfile: viewerProfile,
          onChooseDestination: onChooseDestination,
          pageWidth: pageWidth,
        ),
      ],
    );
  }
}

class _ChoiceHero extends StatelessWidget {
  const _ChoiceHero({required this.onChooseDestination});

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
                'A home agora funciona como roteador limpo entre os modulos operacionais e a Visual Network. A leitura visual abre direto na pagina canonica, sem etapa intermediaria nem preview legado.',
                style: theme.textTheme.bodyLarge?.copyWith(color: _mutedColor),
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
    required this.viewerProfile,
    required this.onChooseDestination,
    required this.pageWidth,
  });

  final _ViewerAccessProfile viewerProfile;
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
              Expanded(
                flex: 4,
                child: _Panel(
                  child: _AccessContextPanel(viewerProfile: viewerProfile),
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              _Panel(child: _AccessContextPanel(viewerProfile: viewerProfile)),
              const SizedBox(height: 24),
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
  const _AccessContextPanel({required this.viewerProfile});

  final _ViewerAccessProfile viewerProfile;

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
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Tag(
              label: viewerProfile.label,
              icon: viewerProfile.icon,
              color: viewerProfile.color,
              background: viewerProfile.color.withValues(alpha: 0.12),
            ),
            _Tag(
              label: 'envio anonimo permitido',
              icon: Icons.outbox_outlined,
              color: _amberColor,
              background: _amberColor.withValues(alpha: 0.12),
            ),
            _Tag(
              label: viewerProfile.consultationSummary,
              icon: viewerProfile.canViewSensitive
                  ? Icons.lock_open_rounded
                  : Icons.lock_outline_rounded,
              color: viewerProfile.canViewSensitive ? _tealColor : _roseColor,
              background:
                  (viewerProfile.canViewSensitive ? _tealColor : _roseColor)
                      .withValues(alpha: 0.12),
            ),
            if (viewerProfile.isAuthenticated)
              _Tag(
                label: 'compartilhamento por grupo ou pessoa',
                icon: Icons.rule_folder_outlined,
                color: _slateColor,
                background: _slateColor.withValues(alpha: 0.12),
              ),
          ],
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
              child: _SpriteMoldIcon(mold: choice.mold, size: 30),
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
            leading: _SpriteMoldIcon(mold: card.mold, size: 18),
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
          child: _SpriteMoldIcon(mold: item.mold, size: 26),
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

class _ChoiceCardData {
  const _ChoiceCardData({
    required this.target,
    required this.title,
    required this.description,
    required this.hint,
    required this.mold,
    required this.color,
    required this.background,
    required this.borderColor,
  });

  final _ChoiceTarget target;
  final String title;
  final String description;
  final String hint;
  final _SpriteMold mold;
  final Color color;
  final Color background;
  final Color borderColor;
}

enum _ChoiceTarget { companies, clientCompanies, contracts, people, network }

class _SummaryCardData {
  const _SummaryCardData({
    required this.label,
    required this.value,
    required this.description,
    required this.mold,
    required this.color,
  });

  final String label;
  final String value;
  final String description;
  final _SpriteMold mold;
  final Color color;
}

class _ResumeItem {
  const _ResumeItem({
    required this.target,
    required this.title,
    required this.description,
    required this.mold,
    required this.color,
  });

  final _ChoiceTarget target;
  final String title;
  final String description;
  final _SpriteMold mold;
  final Color color;
}

const _choices = [
  _ChoiceCardData(
    target: _ChoiceTarget.companies,
    title: 'Consultar prestadoras',
    description:
        'Abrir um workspace mais calmo para prestadoras, status e relacoes principais.',
    hint: 'lista curta, detalhe ao lado, sem poluicao',
    mold: _SpriteMold.company,
    color: _tealColor,
    background: Color(0xFFF4FBF8),
    borderColor: Color(0xFFCFE3DB),
  ),
  _ChoiceCardData(
    target: _ChoiceTarget.clientCompanies,
    title: 'Consultar clientes',
    description:
        'Abrir a carteira de clientes sem esconder transicoes, multi-prestadora e contexto operacional.',
    hint: 'cliente como modulo proprio, nao como reflexo da prestadora',
    mold: _SpriteMold.company,
    color: _slateColor,
    background: Color(0xFFF4F8FA),
    borderColor: Color(0xFFD2DDE4),
  ),
  _ChoiceCardData(
    target: _ChoiceTarget.contracts,
    title: 'Consultar contratos',
    description:
        'Entrar direto no contexto contratual, com filtros e conexoes relevantes.',
    hint: 'cliente, prestadora e vigencia no mesmo eixo',
    mold: _SpriteMold.document,
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
    mold: _SpriteMold.people,
    color: _roseColor,
    background: Color(0xFFFFF5F4),
    borderColor: Color(0xFFF0D2D2),
  ),
  _ChoiceCardData(
    target: _ChoiceTarget.network,
    title: 'Abrir Visual Network',
    description:
        'Entrar direto no business overview da malha relacional, sem pagina intermediaria de teia.',
    hint: 'visual network canonica com drill-down controlado',
    mold: _SpriteMold.network,
    color: _slateColor,
    background: Color(0xFFF4F8FA),
    borderColor: Color(0xFFD2DDE4),
  ),
];

const _summaryCards = [
  _SummaryCardData(
    label: 'Prestadoras monitoradas',
    value: '6',
    description: 'Prestadoras simuladas no recorte atual do workspace.',
    mold: _SpriteMold.company,
    color: _tealColor,
  ),
  _SummaryCardData(
    label: 'Clientes em carteira',
    value: '6',
    description:
        'Empresas clientes tratadas como modulo proprio no shell novo.',
    mold: _SpriteMold.company,
    color: _slateColor,
  ),
  _SummaryCardData(
    label: 'Contratos ativos',
    value: '14',
    description: 'Contratos ativos distribuidos entre as empresas do mock.',
    mold: _SpriteMold.document,
    color: _amberColor,
  ),
  _SummaryCardData(
    label: 'Funcionarios em foco',
    value: '68',
    description:
        'Pessoas simuladas com mistura de ativos, historico e desligamento recente.',
    mold: _SpriteMold.people,
    color: _roseColor,
  ),
];

const _resumeItems = [
  _ResumeItem(
    target: _ChoiceTarget.companies,
    title: 'Prestadoras com atualizacao recente',
    description:
        'Retomar uma lista curta de empresas que impactam contratos e postos.',
    mold: _SpriteMold.company,
    color: _tealColor,
  ),
  _ResumeItem(
    target: _ChoiceTarget.clientCompanies,
    title: 'Clientes com transicao de atendimento',
    description:
        'Abrir direto a carteira quando a leitura central for o cliente, e nao a prestadora.',
    mold: _SpriteMold.company,
    color: _slateColor,
  ),
  _ResumeItem(
    target: _ChoiceTarget.contracts,
    title: 'Contratos proximos de vencimento',
    description:
        'Entrar direto no contexto contratual sem atravessar varios cards.',
    mold: _SpriteMold.document,
    color: _amberColor,
  ),
  _ResumeItem(
    target: _ChoiceTarget.people,
    title: 'Funcionarios com mudanca recente',
    description:
        'Abrir a ficha de quem teve movimentacao, desligamento ou mudanca de status.',
    mold: _SpriteMold.people,
    color: _roseColor,
  ),
];
