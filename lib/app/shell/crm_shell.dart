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
              if (tight) ...[
                _CrmHeaderIconButton(
                  icon: Icons.search_rounded,
                  tooltip: 'Buscar',
                ),
                const SizedBox(width: 4),
                _CrmHeaderIconButton(
                  icon: Icons.summarize_outlined,
                  tooltip: 'Relatorios',
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (context) =>
                        _CrmReportsCenterDialog(viewerProfile: viewerProfile),
                  ),
                ),
                const Spacer(),
              ] else ...[
                SizedBox(
                  width: searchWidth,
                  child: const _CrmHeaderSearchBox(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _CrmReportsCommandMenu(viewerProfile: viewerProfile),
                ),
                const SizedBox(width: 8),
              ],
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

enum _CrmReportFamily {
  strategic,
  management,
  controls,
  compliance,
  audit,
  automation,
}

class _CrmReportFamilyMeta {
  const _CrmReportFamilyMeta({
    required this.family,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final _CrmReportFamily family;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

const List<_CrmReportFamilyMeta> _crmReportFamilies = [
  _CrmReportFamilyMeta(
    family: _CrmReportFamily.strategic,
    title: 'Operacionais',
    subtitle: 'Consultas, tendencias e leitura executiva.',
    icon: Icons.grid_view_rounded,
    color: _slateColor,
  ),
  _CrmReportFamilyMeta(
    family: _CrmReportFamily.controls,
    title: 'Controles',
    subtitle: 'Pendencias, SLA, documentos e evidencias.',
    icon: Icons.gpp_good_outlined,
    color: _slateColor,
  ),
  _CrmReportFamilyMeta(
    family: _CrmReportFamily.management,
    title: 'Gerenciais',
    subtitle: 'Pessoas, contratos, carteira e operacao corrente.',
    icon: Icons.groups_2_outlined,
    color: Color(0xFF2563A8),
  ),
  _CrmReportFamilyMeta(
    family: _CrmReportFamily.compliance,
    title: 'Compliance',
    subtitle: 'Excecoes, acessos sensiveis e criticidade.',
    icon: Icons.verified_user_outlined,
    color: _roseColor,
  ),
  _CrmReportFamilyMeta(
    family: _CrmReportFamily.audit,
    title: 'Logs/Auditoria',
    subtitle: 'Trilha de alteracoes, exclusoes e parametros.',
    icon: Icons.receipt_long_outlined,
    color: _amberColor,
  ),
  _CrmReportFamilyMeta(
    family: _CrmReportFamily.automation,
    title: 'Automacoes',
    subtitle: 'Recorrencia, destinatarios e pacotes periodicos.',
    icon: Icons.smart_toy_outlined,
    color: Color(0xFF6D5DA8),
  ),
];

class _CrmReportTemplate {
  const _CrmReportTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.family,
    required this.filters,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final _CrmReportFamily family;
  final List<String> filters;
}

const List<_CrmReportTemplate> _crmReportTemplates = [
  _CrmReportTemplate(
    id: 'strategic_executive_map',
    title: 'Mapa executivo',
    description: 'Indicadores de carteira, pessoas, contratos e risco.',
    icon: Icons.map_outlined,
    family: _CrmReportFamily.strategic,
    filters: ['Diretoria', 'Periodo', 'Carteira', 'Risco', 'Comparativo'],
  ),
  _CrmReportTemplate(
    id: 'strategic_trends',
    title: 'Tendencias operacionais',
    description: 'Evolucao de headcount, admissioes, contratos e demanda.',
    icon: Icons.trending_up_rounded,
    family: _CrmReportFamily.strategic,
    filters: ['Periodo', 'Empresa', 'Modulo', 'Indicador', 'Projecao'],
  ),
  _CrmReportTemplate(
    id: 'strategic_network_risk',
    title: 'Risco da malha',
    description: 'Concentracao por cliente, posicoes criticas e dependencias.',
    icon: Icons.hub_outlined,
    family: _CrmReportFamily.strategic,
    filters: ['Grupo', 'Cliente', 'Contrato', 'Criticidade', 'Status'],
  ),
  _CrmReportTemplate(
    id: 'strategic_board_pack',
    title: 'Board pack',
    description: 'Pacote premium para reunioes executivas e conselhos.',
    icon: Icons.workspace_premium_outlined,
    family: _CrmReportFamily.strategic,
    filters: ['Periodo', 'Publico', 'Resumo', 'Anexos', 'Formato'],
  ),
  _CrmReportTemplate(
    id: 'management_employees',
    title: 'Quadro ativo',
    description: 'Colaboradores ativos, admissional e alocacao por empresa.',
    icon: Icons.badge_outlined,
    family: _CrmReportFamily.management,
    filters: ['Empresa', 'Status', 'Cargo', 'Departamento', 'Periodo'],
  ),
  _CrmReportTemplate(
    id: 'management_hires',
    title: 'Admissoes',
    description: 'Contratados entre datas, origem e etapa admissional.',
    icon: Icons.how_to_reg_outlined,
    family: _CrmReportFamily.management,
    filters: ['Periodo', 'Empresa', 'Cargo', 'Etapa', 'Origem'],
  ),
  _CrmReportTemplate(
    id: 'management_dismissals',
    title: 'Desligados',
    description: 'Historico de desligamentos, motivos e responsaveis.',
    icon: Icons.person_off_outlined,
    family: _CrmReportFamily.management,
    filters: ['Periodo', 'Empresa', 'Motivo', 'Cargo', 'Responsavel'],
  ),
  _CrmReportTemplate(
    id: 'management_movements',
    title: 'Movimentacoes',
    description: 'Transferencias, promocoes, desligamentos e aprovacoes.',
    icon: Icons.swap_horiz_rounded,
    family: _CrmReportFamily.management,
    filters: ['Tipo', 'Periodo', 'Origem', 'Destino', 'Responsavel'],
  ),
  _CrmReportTemplate(
    id: 'management_departments',
    title: 'Distribuicao',
    description: 'Distribuicao por departamento, senioridade e cargo.',
    icon: Icons.groups_2_outlined,
    family: _CrmReportFamily.management,
    filters: ['Departamento', 'Cargo', 'Empresa', 'Status', 'Tempo'],
  ),
  _CrmReportTemplate(
    id: 'management_indicators',
    title: 'Indicadores',
    description: 'Headcount, contratacoes, carteira e comparativos.',
    icon: Icons.query_stats_rounded,
    family: _CrmReportFamily.management,
    filters: ['Periodo', 'Empresa', 'Indicador', 'Comparativo', 'Publico'],
  ),
  _CrmReportTemplate(
    id: 'management_contracts',
    title: 'Relatorios gerenciais',
    description: 'Contratos, posicoes, clientes vinculados e vigencia.',
    icon: Icons.description_outlined,
    family: _CrmReportFamily.management,
    filters: ['Grupo', 'Cliente', 'Status', 'Vigencia', 'Responsavel'],
  ),
  _CrmReportTemplate(
    id: 'controls_documents',
    title: 'Pendencias documentais',
    description: 'Documentos ausentes, vencidos ou aguardando revisao.',
    icon: Icons.assignment_late_outlined,
    family: _CrmReportFamily.controls,
    filters: ['Documento', 'Vencimento', 'Pessoa', 'Empresa', 'Severidade'],
  ),
  _CrmReportTemplate(
    id: 'controls_sla',
    title: 'SLA de rotinas',
    description: 'Prazos de admissao, revisao, anexos e movimentacoes.',
    icon: Icons.timer_outlined,
    family: _CrmReportFamily.controls,
    filters: ['Rotina', 'Prazo', 'Responsavel', 'Equipe', 'Status'],
  ),
  _CrmReportTemplate(
    id: 'controls_movements',
    title: 'Movimentacoes',
    description: 'Transferencias, desligamentos, admissoes e aprovacoes.',
    icon: Icons.swap_horiz_rounded,
    family: _CrmReportFamily.controls,
    filters: ['Tipo', 'Periodo', 'Origem', 'Destino', 'Responsavel'],
  ),
  _CrmReportTemplate(
    id: 'controls_evidence',
    title: 'Anexos e evidencias',
    description: 'Arquivos, comprovantes, links e status de revisao.',
    icon: Icons.attach_file_rounded,
    family: _CrmReportFamily.controls,
    filters: ['Modulo', 'Tipo', 'Pessoa', 'Contrato', 'Revisao'],
  ),
  _CrmReportTemplate(
    id: 'compliance_alerts',
    title: 'Alertas e compliance',
    description: 'Sinais de atencao por regra, perfil e criticidade.',
    icon: Icons.warning_amber_rounded,
    family: _CrmReportFamily.compliance,
    filters: ['Regra', 'Criticidade', 'Modulo', 'Periodo', 'Responsavel'],
  ),
  _CrmReportTemplate(
    id: 'compliance_sensitive_access',
    title: 'Acessos sensiveis',
    description: 'Consultas, downloads e sessoes privilegiadas.',
    icon: Icons.lock_person_outlined,
    family: _CrmReportFamily.compliance,
    filters: ['Usuario', 'Perfil', 'Recurso', 'Periodo', 'Resultado'],
  ),
  _CrmReportTemplate(
    id: 'compliance_expirations',
    title: 'Vencimentos criticos',
    description: 'Contratos, documentos e obrigacoes perto do limite.',
    icon: Icons.event_busy_outlined,
    family: _CrmReportFamily.compliance,
    filters: ['Tipo', 'Janela', 'Cliente', 'Contrato', 'Severidade'],
  ),
  _CrmReportTemplate(
    id: 'compliance_exceptions',
    title: 'Excecoes operacionais',
    description: 'Itens fora da regra, justificativas e recorrencia.',
    icon: Icons.report_problem_outlined,
    family: _CrmReportFamily.compliance,
    filters: ['Regra', 'Justificativa', 'Modulo', 'Periodo', 'Dono'],
  ),
  _CrmReportTemplate(
    id: 'audit_changes',
    title: 'Historico de alteracoes',
    description: 'Mudancas em cadastros, contratos, pessoas e anexos.',
    icon: Icons.manage_history_outlined,
    family: _CrmReportFamily.audit,
    filters: ['Modulo', 'Usuario', 'Periodo', 'Tipo de campo', 'Entidade'],
  ),
  _CrmReportTemplate(
    id: 'audit_deletions',
    title: 'Historico de exclusoes',
    description: 'Registros removidos, origem, responsavel e justificativa.',
    icon: Icons.delete_outline_rounded,
    family: _CrmReportFamily.audit,
    filters: ['Modulo', 'Usuario', 'Periodo', 'Motivo', 'Entidade'],
  ),
  _CrmReportTemplate(
    id: 'audit_additions',
    title: 'Historico de adicoes',
    description: 'Novos cadastros, anexos, contratos e relacionamentos.',
    icon: Icons.add_circle_outline_rounded,
    family: _CrmReportFamily.audit,
    filters: ['Modulo', 'Criado por', 'Periodo', 'Origem', 'Entidade'],
  ),
  _CrmReportTemplate(
    id: 'audit_settings',
    title: 'Configuracoes do app',
    description: 'Alteracoes de parametros, permissoes e preferencias.',
    icon: Icons.settings_outlined,
    family: _CrmReportFamily.audit,
    filters: ['Parametro', 'Usuario', 'Perfil', 'Periodo', 'Impacto'],
  ),
  _CrmReportTemplate(
    id: 'audit_sessions',
    title: 'Seguranca de sessoes',
    description: 'Logins, refresh, expiracoes, falhas e encerramentos.',
    icon: Icons.verified_user_outlined,
    family: _CrmReportFamily.audit,
    filters: ['Usuario', 'Origem', 'Periodo', 'Evento', 'Dispositivo'],
  ),
  _CrmReportTemplate(
    id: 'automation_management',
    title: 'Fechamento executivo',
    description: 'Recorrencia do board pack e pacote de diretoria.',
    icon: Icons.event_repeat_outlined,
    family: _CrmReportFamily.automation,
    filters: ['Relatorio base', 'Frequencia', 'Destinatarios', 'Formato'],
  ),
  _CrmReportTemplate(
    id: 'automation_logs',
    title: 'Rotina de logs',
    description: 'Modelo visual para envio periodico de auditoria.',
    icon: Icons.history_edu_outlined,
    family: _CrmReportFamily.automation,
    filters: ['Evento', 'Modulo', 'Frequencia', 'Retencao'],
  ),
  _CrmReportTemplate(
    id: 'automation_status',
    title: 'Status semanal',
    description: 'Modelo visual para acompanhamento recorrente de pendencias.',
    icon: Icons.mark_email_read_outlined,
    family: _CrmReportFamily.automation,
    filters: ['Status', 'Periodicidade', 'Equipe', 'Canal'],
  ),
  _CrmReportTemplate(
    id: 'automation_controls',
    title: 'Trilha de controles',
    description: 'Envio recorrente de pendencias, SLA e evidencias.',
    icon: Icons.playlist_add_check_circle_outlined,
    family: _CrmReportFamily.automation,
    filters: ['Controle', 'Frequencia', 'Dono', 'Escalonamento'],
  ),
];

class _CrmReportsCommandMenu extends StatelessWidget {
  const _CrmReportsCommandMenu({required this.viewerProfile});

  final _ViewerAccessProfile viewerProfile;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final family in _orderedCrmReportFamilies)
              _CrmReportFamilyMenuButton(
                meta: family,
                templates: _templatesFor(family.family),
                highlighted: family.family == _CrmReportFamily.management,
                onSelected: (template) =>
                    _openReportSettings(context, template),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openReportSettings(
    BuildContext context,
    _CrmReportTemplate template,
  ) {
    return showDialog<void>(
      context: context,
      builder: (context) => _CrmReportsCenterDialog(
        viewerProfile: viewerProfile,
        initialTemplate: template,
        lockedTemplate: true,
      ),
    );
  }
}

List<_CrmReportFamilyMeta> get _orderedCrmReportFamilies {
  const order = [
    _CrmReportFamily.management,
    _CrmReportFamily.strategic,
    _CrmReportFamily.controls,
    _CrmReportFamily.compliance,
    _CrmReportFamily.audit,
    _CrmReportFamily.automation,
  ];
  return [
    for (final family in order)
      _crmReportFamilies.firstWhere((meta) => meta.family == family),
  ];
}

class _CrmReportFamilyMenuButton extends StatelessWidget {
  const _CrmReportFamilyMenuButton({
    required this.meta,
    required this.templates,
    required this.highlighted,
    required this.onSelected,
  });

  final _CrmReportFamilyMeta meta;
  final List<_CrmReportTemplate> templates;
  final bool highlighted;
  final ValueChanged<_CrmReportTemplate> onSelected;

  @override
  Widget build(BuildContext context) {
    final foreground = highlighted ? meta.color : _inkColor;
    final background = highlighted
        ? meta.color.withValues(alpha: 0.10)
        : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: PopupMenuButton<_CrmReportTemplate>(
        tooltip: meta.title,
        offset: const Offset(0, 39),
        constraints: const BoxConstraints(minWidth: 306, maxWidth: 360),
        onSelected: onSelected,
        itemBuilder: (context) => [
          PopupMenuItem<_CrmReportTemplate>(
            enabled: false,
            height: 56,
            child: _CrmReportMenuHeader(meta: meta, count: templates.length),
          ),
          const PopupMenuDivider(height: 1),
          if (templates.isEmpty)
            const PopupMenuItem<_CrmReportTemplate>(
              enabled: false,
              child: Text('Nenhuma opcao disponivel'),
            )
          else
            for (final template in templates)
              PopupMenuItem<_CrmReportTemplate>(
                value: template,
                height: 58,
                child: _CrmReportMenuItem(
                  template: template,
                  color: meta.color,
                ),
              ),
        ],
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: highlighted
                  ? meta.color.withValues(alpha: 0.16)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(meta.icon, color: foreground, size: 20),
              const SizedBox(width: 9),
              Text(
                meta.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 5),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: foreground,
                size: 19,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CrmReportMenuHeader extends StatelessWidget {
  const _CrmReportMenuHeader({required this.meta, required this.count});

  final _CrmReportFamilyMeta meta;
  final int count;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 318,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: meta.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(meta.icon, color: meta.color, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meta.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _inkColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '$count modelos com filtros proprios',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _mutedColor,
                    fontWeight: FontWeight.w700,
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

class _CrmReportMenuItem extends StatelessWidget {
  const _CrmReportMenuItem({required this.template, required this.color});

  final _CrmReportTemplate template;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 318,
      child: Row(
        children: [
          Icon(template.icon, color: color, size: 19),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _inkColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  template.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _mutedColor,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
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

class _CrmReportsCenterDialog extends StatefulWidget {
  const _CrmReportsCenterDialog({
    required this.viewerProfile,
    this.initialTemplate,
    this.lockedTemplate = false,
  });

  final _ViewerAccessProfile viewerProfile;
  final _CrmReportTemplate? initialTemplate;
  final bool lockedTemplate;

  @override
  State<_CrmReportsCenterDialog> createState() =>
      _CrmReportsCenterDialogState();
}

class _CrmReportsCenterDialogState extends State<_CrmReportsCenterDialog> {
  late _CrmReportTemplate _selected;
  final Set<String> _requiredFilters = {'Empresa', 'Periodo'};
  final Set<String> _optionalFilters = {'Status'};
  final Map<String, String> _filterValues = {};
  String _frequency = 'Semanal';
  String _delivery = 'Painel';

  @override
  void initState() {
    super.initState();
    _selected = widget.initialTemplate ?? _crmReportTemplates.first;
    _syncFilterDefaults(_selected);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final designer = _CrmReportDesignerPanel(
      template: _selected,
      viewerProfile: widget.viewerProfile,
      requiredFilters: _requiredFilters,
      optionalFilters: _optionalFilters,
      frequency: _frequency,
      delivery: _delivery,
      filterValues: _filterValues,
      onToggleRequired: _toggleRequiredFilter,
      onToggleOptional: _toggleOptionalFilter,
      onFilterValueChanged: _updateFilterValue,
      onFrequencyChanged: (value) {
        setState(() {
          _frequency = value;
        });
      },
      onDeliveryChanged: (value) {
        setState(() {
          _delivery = value;
        });
      },
    );

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      titlePadding: const EdgeInsets.fromLTRB(24, 22, 18, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      title: Row(
        children: [
          Icon(
            widget.lockedTemplate ? _selected.icon : Icons.summarize_outlined,
            color: _tealColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.lockedTemplate
                      ? _selected.title
                      : 'Central de relatorios',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (widget.lockedTemplate) ...[
                  const SizedBox(height: 3),
                  Text(
                    _selected.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _mutedColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Fechar',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
      content: SizedBox(
        width: widget.lockedTemplate
            ? min(size.width * 0.76, 680)
            : min(size.width * 0.92, 1180),
        height: min(size.height * 0.80, 720),
        child: widget.lockedTemplate
            ? designer
            : LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 920;
                  final catalog = _CrmReportsCatalog(
                    selected: _selected,
                    onSelected: (template) {
                      setState(() {
                        _selected = template;
                        _syncFilterDefaults(template);
                      });
                    },
                  );

                  if (stacked) {
                    return Column(
                      children: [
                        Expanded(flex: 5, child: catalog),
                        const SizedBox(height: 14),
                        Expanded(flex: 4, child: designer),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(flex: 7, child: catalog),
                      const SizedBox(width: 16),
                      Expanded(flex: 4, child: designer),
                    ],
                  );
                },
              ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            setState(() {
              _syncFilterDefaults(_selected);
            });
          },
          icon: const Icon(Icons.restart_alt_rounded, size: 18),
          label: Text(
            widget.lockedTemplate
                ? 'Restaurar configuracao'
                : 'Restaurar modelo',
          ),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.check_rounded, size: 18),
          label: Text(widget.lockedTemplate ? 'Aplicar' : 'Concluir'),
        ),
      ],
    );
  }

  void _syncFilterDefaults(_CrmReportTemplate template) {
    _requiredFilters
      ..clear()
      ..addAll(template.filters.take(2));
    _optionalFilters
      ..clear()
      ..addAll(template.filters.skip(2).take(1));
    _filterValues
      ..clear()
      ..addAll(_defaultReportFilterValues(template));
    _frequency = template.family == _CrmReportFamily.automation
        ? 'Semanal'
        : 'Manual';
    _delivery = template.family == _CrmReportFamily.automation
        ? 'Email'
        : 'Painel';
  }

  void _toggleRequiredFilter(String filter) {
    setState(() {
      if (_requiredFilters.contains(filter)) {
        _requiredFilters.remove(filter);
        return;
      }
      _optionalFilters.remove(filter);
      _requiredFilters.add(filter);
      _ensureFilterDraft(filter);
    });
  }

  void _toggleOptionalFilter(String filter) {
    setState(() {
      if (_optionalFilters.contains(filter)) {
        _optionalFilters.remove(filter);
        return;
      }
      _requiredFilters.remove(filter);
      _optionalFilters.add(filter);
      _ensureFilterDraft(filter);
    });
  }

  void _updateFilterValue(String key, String value) {
    setState(() {
      _filterValues[key] = value;
    });
  }

  void _ensureFilterDraft(String filter) {
    for (final entry in _defaultValuesForReportFilter(filter).entries) {
      _filterValues.putIfAbsent(entry.key, () => entry.value);
    }
  }
}

class _CrmReportsCatalog extends StatelessWidget {
  const _CrmReportsCatalog({required this.selected, required this.onSelected});

  final _CrmReportTemplate selected;
  final ValueChanged<_CrmReportTemplate> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView.separated(
          itemCount: _orderedCrmReportFamilies.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final family = _orderedCrmReportFamilies[index];
            return _CrmReportCategoryColumn(
              meta: family,
              templates: _templatesFor(family.family),
              selected: selected,
              onSelected: onSelected,
            );
          },
        );
      },
    );
  }
}

List<_CrmReportTemplate> _templatesFor(_CrmReportFamily family) {
  return [
    for (final template in _crmReportTemplates)
      if (template.family == family) template,
  ];
}

class _CrmReportCategoryColumn extends StatelessWidget {
  const _CrmReportCategoryColumn({
    required this.meta,
    required this.templates,
    required this.selected,
    required this.onSelected,
  });

  final _CrmReportFamilyMeta meta;
  final List<_CrmReportTemplate> templates;
  final _CrmReportTemplate selected;
  final ValueChanged<_CrmReportTemplate> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5EAE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: meta.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(meta.icon, color: meta.color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meta.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: _deepTealColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meta.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _mutedColor,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _CrmReportCountBadge(count: templates.length, color: meta.color),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth >= 560;
              final tileWidth = twoColumns
                  ? ((constraints.maxWidth - 10) / 2).floorToDouble()
                  : constraints.maxWidth;

              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final template in templates)
                    SizedBox(
                      width: tileWidth,
                      child: _CrmReportTemplateTile(
                        template: template,
                        selected: selected.id == template.id,
                        onTap: () => onSelected(template),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CrmReportCountBadge extends StatelessWidget {
  const _CrmReportCountBadge({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Text(
        '$count',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CrmReportTemplateTile extends StatelessWidget {
  const _CrmReportTemplateTile({
    required this.template,
    required this.selected,
    required this.onTap,
  });

  final _CrmReportTemplate template;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? _tealColor : const Color(0xFF5D6C67);
    return Material(
      color: selected ? _tealColor.withValues(alpha: 0.10) : Colors.white,
      borderRadius: BorderRadius.circular(7),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        child: Container(
          constraints: const BoxConstraints(minHeight: 82),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: selected
                  ? _tealColor.withValues(alpha: 0.46)
                  : const Color(0xFFE5EAE8),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(template.icon, color: color, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      template.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: selected ? _deepTealColor : _inkColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                template.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _mutedColor,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CrmReportDesignerPanel extends StatelessWidget {
  const _CrmReportDesignerPanel({
    required this.template,
    required this.viewerProfile,
    required this.requiredFilters,
    required this.optionalFilters,
    required this.frequency,
    required this.delivery,
    required this.filterValues,
    required this.onToggleRequired,
    required this.onToggleOptional,
    required this.onFilterValueChanged,
    required this.onFrequencyChanged,
    required this.onDeliveryChanged,
  });

  final _CrmReportTemplate template;
  final _ViewerAccessProfile viewerProfile;
  final Set<String> requiredFilters;
  final Set<String> optionalFilters;
  final String frequency;
  final String delivery;
  final Map<String, String> filterValues;
  final ValueChanged<String> onToggleRequired;
  final ValueChanged<String> onToggleOptional;
  final void Function(String key, String value) onFilterValueChanged;
  final ValueChanged<String> onFrequencyChanged;
  final ValueChanged<String> onDeliveryChanged;

  @override
  Widget build(BuildContext context) {
    final automation = template.family == _CrmReportFamily.automation;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5EAE8)),
      ),
      child: ListView(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _tealColor.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(template.icon, color: _tealColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _inkColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _familyLabel(template.family),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _mutedColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Filtros obrigatorios',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          _CrmReportFilterWrap(
            filters: template.filters,
            activeFilters: requiredFilters,
            color: _tealColor,
            onSelected: onToggleRequired,
          ),
          const SizedBox(height: 16),
          Text(
            'Filtros opcionais',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          _CrmReportFilterWrap(
            filters: template.filters,
            activeFilters: optionalFilters,
            color: _amberColor,
            onSelected: onToggleOptional,
          ),
          const SizedBox(height: 16),
          Text(
            'Parametros configuraveis',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          _CrmReportFilterConfigurator(
            template: template,
            viewerProfile: viewerProfile,
            activeFilters: {...requiredFilters, ...optionalFilters},
            values: filterValues,
            onChanged: onFilterValueChanged,
          ),
          const SizedBox(height: 16),
          Text('Saida', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in const ['Painel', 'PDF', 'Planilha', 'Email'])
                ChoiceChip(
                  label: Text(option),
                  selected: delivery == option,
                  onSelected: (_) => onDeliveryChanged(option),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (automation) ...[
            Text(
              'Programacao visual',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final option in const [
                  'Diario',
                  'Semanal',
                  'Quinzenal',
                  'Mensal',
                ])
                  ChoiceChip(
                    label: Text(option),
                    selected: frequency == option,
                    onSelected: (_) => onFrequencyChanged(option),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _CrmAutomationPreviewLine(
              icon: Icons.schedule_outlined,
              label: '08:00',
              value: frequency,
            ),
            _CrmAutomationPreviewLine(
              icon: Icons.group_outlined,
              label: 'Destinatarios',
              value: 'Gestores e responsaveis',
            ),
            _CrmAutomationPreviewLine(
              icon: Icons.lock_clock_outlined,
              label: 'Status',
              value: 'Planejado para fase posterior',
            ),
          ] else ...[
            _CrmAutomationPreviewLine(
              icon: Icons.tune_outlined,
              label: 'Execucao',
              value: 'Manual, com filtros proprios',
            ),
          ],
        ],
      ),
    );
  }
}

enum _CrmReportFilterKind { period, options, search }

class _CrmReportFilterConfigurator extends StatelessWidget {
  const _CrmReportFilterConfigurator({
    required this.template,
    required this.viewerProfile,
    required this.activeFilters,
    required this.values,
    required this.onChanged,
  });

  final _CrmReportTemplate template;
  final _ViewerAccessProfile viewerProfile;
  final Set<String> activeFilters;
  final Map<String, String> values;
  final void Function(String key, String value) onChanged;

  @override
  Widget build(BuildContext context) {
    final orderedFilters = [
      for (final filter in template.filters)
        if (activeFilters.contains(filter)) filter,
    ];

    if (orderedFilters.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAF9),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: const Color(0xFFE5EAE8)),
        ),
        child: Text(
          'Selecione filtros obrigatorios ou opcionais para configurar os parametros do relatorio.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: _mutedColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _CrmReportMethodNote(),
        const SizedBox(height: 10),
        for (var index = 0; index < orderedFilters.length; index++) ...[
          _CrmReportFilterConfigCard(
            filter: orderedFilters[index],
            viewerProfile: viewerProfile,
            values: values,
            onChanged: onChanged,
          ),
          if (index < orderedFilters.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _CrmReportMethodNote extends StatelessWidget {
  const _CrmReportMethodNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _tealColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: _tealColor.withValues(alpha: 0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.manage_search_outlined, color: _tealColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Modelo de pesquisa: escopo, periodo, status, recortes e saida. Os relatorios seguem a mesma logica de busca estruturada.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _deepTealColor,
                height: 1.28,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CrmReportFilterConfigCard extends StatelessWidget {
  const _CrmReportFilterConfigCard({
    required this.filter,
    required this.viewerProfile,
    required this.values,
    required this.onChanged,
  });

  final String filter;
  final _ViewerAccessProfile viewerProfile;
  final Map<String, String> values;
  final void Function(String key, String value) onChanged;

  @override
  Widget build(BuildContext context) {
    final kind = _kindForReportFilter(filter);
    final accent = _colorForReportFilter(kind);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFFE5EAE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_iconForReportFilter(kind), color: accent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  filter,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _inkColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                _kindLabelForReportFilter(kind),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          switch (kind) {
            _CrmReportFilterKind.period => _CrmReportPeriodFields(
              filter: filter,
              values: values,
              onChanged: onChanged,
            ),
            _CrmReportFilterKind.options => _CrmReportOptionSelector(
              filter: filter,
              viewerProfile: viewerProfile,
              values: values,
              onChanged: onChanged,
            ),
            _CrmReportFilterKind.search => _CrmReportSearchField(
              filter: filter,
              values: values,
              onChanged: onChanged,
            ),
          },
        ],
      ),
    );
  }
}

class _CrmReportPeriodFields extends StatelessWidget {
  const _CrmReportPeriodFields({
    required this.filter,
    required this.values,
    required this.onChanged,
  });

  final String filter;
  final Map<String, String> values;
  final void Function(String key, String value) onChanged;

  @override
  Widget build(BuildContext context) {
    final startKey = _reportFilterKey(filter, 'inicio');
    final endKey = _reportFilterKey(filter, 'fim');

    return Row(
      children: [
        Expanded(
          child: _CrmReportTextInput(
            keyName: startKey,
            label: 'De',
            hint: 'DD/MM/AAAA',
            value: values[startKey],
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _CrmReportTextInput(
            keyName: endKey,
            label: 'Ate',
            hint: 'DD/MM/AAAA',
            value: values[endKey],
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _CrmReportOptionSelector extends StatefulWidget {
  const _CrmReportOptionSelector({
    required this.filter,
    required this.viewerProfile,
    required this.values,
    required this.onChanged,
  });

  final String filter;
  final _ViewerAccessProfile viewerProfile;
  final Map<String, String> values;
  final void Function(String key, String value) onChanged;

  @override
  State<_CrmReportOptionSelector> createState() =>
      _CrmReportOptionSelectorState();
}

class _CrmReportOptionSelectorState extends State<_CrmReportOptionSelector> {
  String? _accessError;

  @override
  Widget build(BuildContext context) {
    final keyName = _reportFilterKey(widget.filter, 'valor');
    final options = _optionsForReportFilter(widget.filter);
    final selected = widget.values[keyName] ?? options.first;
    final audienceFilter = _isReportAudienceFilter(widget.filter);
    final currentAudience = _viewerReportAudienceLabel(widget.viewerProfile);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (audienceFilter) ...[
          _CrmReportAudienceHierarchyNote(viewerProfile: widget.viewerProfile),
          const SizedBox(height: 8),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              _CrmReportAudienceAwareChip(
                label: option,
                selected: selected == option,
                current: audienceFilter && option == currentAudience,
                blocked:
                    audienceFilter &&
                    !_canViewerSelectReportAudience(
                      widget.viewerProfile,
                      option,
                    ),
                onSelected: () {
                  if (audienceFilter &&
                      !_canViewerSelectReportAudience(
                        widget.viewerProfile,
                        option,
                      )) {
                    setState(() {
                      _accessError = _reportAudienceDeniedMessage(
                        widget.viewerProfile,
                        option,
                      );
                    });
                    return;
                  }

                  setState(() {
                    _accessError = null;
                  });
                  widget.onChanged(keyName, option);
                },
              ),
          ],
        ),
        if (_accessError != null) ...[
          const SizedBox(height: 8),
          _CrmReportAccessError(message: _accessError!),
        ],
      ],
    );
  }
}

class _CrmReportAudienceHierarchyNote extends StatelessWidget {
  const _CrmReportAudienceHierarchyNote({required this.viewerProfile});

  final _ViewerAccessProfile viewerProfile;

  @override
  Widget build(BuildContext context) {
    final audience = _viewerReportAudienceLabel(viewerProfile);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: viewerProfile.color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: viewerProfile.color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(viewerProfile.icon, color: viewerProfile.color, size: 17),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Perfil atual: $audience. Publicos acima exigem liberacao de admin.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _inkColor,
                height: 1.25,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CrmReportAudienceAwareChip extends StatelessWidget {
  const _CrmReportAudienceAwareChip({
    required this.label,
    required this.selected,
    required this.current,
    required this.blocked,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final bool current;
  final bool blocked;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final color = blocked
        ? _mutedColor
        : current
        ? _tealColor
        : _deepTealColor;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (blocked) ...[
            Icon(Icons.lock_outline_rounded, size: 14, color: color),
            const SizedBox(width: 5),
          ] else if (current) ...[
            Icon(Icons.person_pin_circle_outlined, size: 14, color: color),
            const SizedBox(width: 5),
          ],
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: current
          ? _tealColor.withValues(alpha: 0.20)
          : _tealColor.withValues(alpha: 0.14),
      backgroundColor: blocked ? const Color(0xFFF3F5F4) : null,
      side: BorderSide(
        color: current
            ? _tealColor.withValues(alpha: 0.65)
            : blocked
            ? const Color(0xFFD8DEDB)
            : const Color(0xFFC8D4CF),
      ),
      labelStyle: TextStyle(
        color: blocked ? _mutedColor : _inkColor,
        fontWeight: current ? FontWeight.w900 : FontWeight.w700,
      ),
    );
  }
}

class _CrmReportAccessError extends StatelessWidget {
  const _CrmReportAccessError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _roseColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: _roseColor.withValues(alpha: 0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: _roseColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _roseColor,
                height: 1.25,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CrmReportSearchField extends StatelessWidget {
  const _CrmReportSearchField({
    required this.filter,
    required this.values,
    required this.onChanged,
  });

  final String filter;
  final Map<String, String> values;
  final void Function(String key, String value) onChanged;

  @override
  Widget build(BuildContext context) {
    final keyName = _reportFilterKey(filter, 'valor');
    return _CrmReportTextInput(
      keyName: keyName,
      label: filter,
      hint: _hintForReportFilter(filter),
      value: values[keyName],
      icon: Icons.manage_search_outlined,
      onChanged: onChanged,
    );
  }
}

class _CrmReportTextInput extends StatelessWidget {
  const _CrmReportTextInput({
    required this.keyName,
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
    this.icon,
  });

  final String keyName;
  final String label;
  final String hint;
  final String? value;
  final IconData? icon;
  final void Function(String key, String value) onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey(keyName),
      initialValue: value ?? '',
      onChanged: (text) => onChanged(keyName, text),
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        hintText: hint,
        prefixIcon: icon == null ? null : Icon(icon, size: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 11,
        ),
      ),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: _inkColor,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _CrmReportFilterWrap extends StatelessWidget {
  const _CrmReportFilterWrap({
    required this.filters,
    required this.activeFilters,
    required this.color,
    required this.onSelected,
  });

  final List<String> filters;
  final Set<String> activeFilters;
  final Color color;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final filter in filters)
          FilterChip(
            label: Text(filter),
            selected: activeFilters.contains(filter),
            selectedColor: color.withValues(alpha: 0.14),
            checkmarkColor: color,
            side: BorderSide(
              color: activeFilters.contains(filter)
                  ? color.withValues(alpha: 0.38)
                  : const Color(0xFFE5EAE8),
            ),
            onSelected: (_) => onSelected(filter),
          ),
      ],
    );
  }
}

Map<String, String> _defaultReportFilterValues(_CrmReportTemplate template) {
  final values = <String, String>{};
  for (final filter in template.filters.take(3)) {
    values.addAll(_defaultValuesForReportFilter(filter));
  }
  return values;
}

Map<String, String> _defaultValuesForReportFilter(String filter) {
  return switch (_kindForReportFilter(filter)) {
    _CrmReportFilterKind.period => {
      _reportFilterKey(filter, 'inicio'): '',
      _reportFilterKey(filter, 'fim'): '',
    },
    _CrmReportFilterKind.options => {
      _reportFilterKey(filter, 'valor'): _optionsForReportFilter(filter).first,
    },
    _CrmReportFilterKind.search => {_reportFilterKey(filter, 'valor'): ''},
  };
}

String _reportFilterKey(String filter, String slot) {
  return '$filter::$slot';
}

_CrmReportFilterKind _kindForReportFilter(String filter) {
  final normalized = filter.toLowerCase();
  if (_matchesAny(normalized, const [
    'periodo',
    'vigencia',
    'vencimento',
    'prazo',
    'janela',
    'tempo',
  ])) {
    return _CrmReportFilterKind.period;
  }

  if (_matchesAny(normalized, const [
    'status',
    'criticidade',
    'severidade',
    'risco',
    'impacto',
    'resultado',
    'formato',
    'publico',
    'resumo',
    'comparativo',
    'projecao',
    'etapa',
    'evento',
    'periodicidade',
    'frequencia',
    'canal',
    'escalonamento',
    'revisao',
    'tipo',
    'indicador',
    'modulo',
    'perfil',
    'retencao',
  ])) {
    return _CrmReportFilterKind.options;
  }

  return _CrmReportFilterKind.search;
}

bool _matchesAny(String value, List<String> needles) {
  return needles.any(value.contains);
}

bool _isReportAudienceFilter(String filter) {
  return filter.toLowerCase().contains('publico');
}

String _viewerReportAudienceLabel(_ViewerAccessProfile viewer) {
  if (viewer.groups.contains(_CollaboratorAudienceGroup.board)) {
    return 'Diretoria';
  }
  if (viewer.groups.contains(_CollaboratorAudienceGroup.supervision)) {
    return 'Gestores';
  }
  if (viewer.groups.contains(_CollaboratorAudienceGroup.auxiliary)) {
    return 'Operacao';
  }
  return 'Publico';
}

int _viewerReportAudienceRank(_ViewerAccessProfile viewer) {
  return _reportAudienceRank(_viewerReportAudienceLabel(viewer));
}

int _reportAudienceRank(String audience) {
  return switch (audience.toLowerCase()) {
    'diretoria' => 50,
    'compliance' => 40,
    'gestores' => 30,
    'rh' => 20,
    'operacao' || 'auxiliares' => 10,
    _ => 0,
  };
}

bool _canViewerSelectReportAudience(
  _ViewerAccessProfile viewer,
  String audience,
) {
  if (!viewer.isAuthenticated) {
    return _reportAudienceRank(audience) == 0;
  }
  return _reportAudienceRank(audience) <= _viewerReportAudienceRank(viewer);
}

String _reportAudienceDeniedMessage(
  _ViewerAccessProfile viewer,
  String audience,
) {
  final current = _viewerReportAudienceLabel(viewer);
  return 'Seu perfil ($current) nao permite selecionar $audience. Solicite liberacao ao admin para relatorios acima da sua hierarquia.';
}

List<String> _optionsForReportFilter(String filter) {
  final normalized = filter.toLowerCase();
  if (normalized.contains('publico')) {
    return const ['Diretoria', 'Compliance', 'Gestores', 'RH', 'Operacao'];
  }
  if (normalized.contains('status')) {
    return const [
      'Todos',
      'Ativo',
      'Pendente',
      'Admissional',
      'Afastado',
      'Historico',
      'Encerrado',
    ];
  }
  if (_matchesAny(normalized, const ['criticidade', 'severidade', 'risco'])) {
    return const ['Todos', 'Baixo', 'Medio', 'Alto', 'Critico'];
  }
  if (normalized.contains('impacto')) {
    return const ['Todos', 'Baixo', 'Medio', 'Alto'];
  }
  if (normalized.contains('resultado')) {
    return const ['Todos', 'Permitido', 'Negado', 'Falha'];
  }
  if (normalized.contains('formato')) {
    return const ['Painel', 'PDF', 'Planilha', 'Email'];
  }
  if (normalized.contains('publico')) {
    return const ['Diretoria', 'Gestores', 'RH', 'Compliance'];
  }
  if (normalized.contains('resumo')) {
    return const ['Executivo', 'Sintetico', 'Detalhado'];
  }
  if (normalized.contains('comparativo')) {
    return const [
      'Sem comparativo',
      'Mes anterior',
      'Trimestre anterior',
      'Ano anterior',
    ];
  }
  if (normalized.contains('projecao')) {
    return const ['30 dias', '60 dias', '90 dias'];
  }
  if (normalized.contains('etapa')) {
    return const ['Todas', 'Triagem', 'Documentacao', 'Aprovacao', 'Concluida'];
  }
  if (normalized.contains('evento')) {
    return const ['Todos', 'Login', 'Alteracao', 'Download', 'Exclusao'];
  }
  if (_matchesAny(normalized, const ['frequencia', 'periodicidade'])) {
    return const ['Diario', 'Semanal', 'Quinzenal', 'Mensal'];
  }
  if (normalized.contains('canal')) {
    return const ['Painel', 'Email', 'Teams', 'Exportacao'];
  }
  if (normalized.contains('escalonamento')) {
    return const ['Sem escalonamento', 'Gestor', 'Diretoria', 'Compliance'];
  }
  if (normalized.contains('revisao')) {
    return const ['Todos', 'Aguardando', 'Aprovado', 'Reprovado'];
  }
  if (normalized.contains('modulo')) {
    return const ['Todos', 'Pessoas', 'Empresas', 'Contratos', 'Network'];
  }
  if (normalized.contains('perfil')) {
    return const ['Todos', 'Admin', 'Gestor', 'Operacao', 'Leitura'];
  }
  if (normalized.contains('retencao')) {
    return const ['30 dias', '90 dias', '180 dias', '1 ano'];
  }
  if (normalized.contains('indicador')) {
    return const ['Headcount', 'Contratos', 'SLA', 'Risco'];
  }
  if (normalized.contains('tipo')) {
    return const ['Todos', 'Admissao', 'Movimentacao', 'Desligamento', 'Anexo'];
  }

  return const ['Todos', 'Inclui', 'Exclui'];
}

String _hintForReportFilter(String filter) {
  final normalized = filter.toLowerCase();
  if (_matchesAny(normalized, const ['empresa', 'grupo', 'cliente'])) {
    return 'Buscar por nome, CNPJ ou carteira';
  }
  if (_matchesAny(normalized, const ['pessoa', 'usuario', 'responsavel'])) {
    return 'Buscar por nome, email ou identificador';
  }
  if (_matchesAny(normalized, const ['contrato', 'documento', 'anexo'])) {
    return 'Buscar por codigo, titulo ou vinculo';
  }
  if (_matchesAny(normalized, const ['cargo', 'departamento', 'equipe'])) {
    return 'Buscar por area, cargo ou equipe';
  }
  if (_matchesAny(normalized, const ['regra', 'recurso', 'parametro'])) {
    return 'Buscar regra, recurso ou parametro';
  }
  return 'Digite para filtrar este recorte';
}

IconData _iconForReportFilter(_CrmReportFilterKind kind) {
  return switch (kind) {
    _CrmReportFilterKind.period => Icons.date_range_outlined,
    _CrmReportFilterKind.options => Icons.tune_outlined,
    _CrmReportFilterKind.search => Icons.manage_search_outlined,
  };
}

Color _colorForReportFilter(_CrmReportFilterKind kind) {
  return switch (kind) {
    _CrmReportFilterKind.period => _tealColor,
    _CrmReportFilterKind.options => _amberColor,
    _CrmReportFilterKind.search => _slateColor,
  };
}

String _kindLabelForReportFilter(_CrmReportFilterKind kind) {
  return switch (kind) {
    _CrmReportFilterKind.period => 'intervalo',
    _CrmReportFilterKind.options => 'opcoes',
    _CrmReportFilterKind.search => 'busca',
  };
}

class _CrmAutomationPreviewLine extends StatelessWidget {
  const _CrmAutomationPreviewLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF9),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFFE5EAE8)),
      ),
      child: Row(
        children: [
          Icon(icon, color: _mutedColor, size: 18),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _inkColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _mutedColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _familyLabel(_CrmReportFamily family) {
  return switch (family) {
    _CrmReportFamily.strategic => 'Relatorios estrategicos',
    _CrmReportFamily.management => 'Relatorios gerenciais',
    _CrmReportFamily.controls => 'Relatorios de controles',
    _CrmReportFamily.compliance => 'Compliance e risco',
    _CrmReportFamily.audit => 'Logs e auditoria',
    _CrmReportFamily.automation => 'Automacao visual',
  };
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
