part of '../../app/app.dart';

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
