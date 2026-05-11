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
  final _reportsRepository = _ReportsApiRepository();
  late _CrmReportTemplate _selected;
  final Set<String> _requiredFilters = {'Empresa', 'Periodo'};
  final Set<String> _optionalFilters = {'Status'};
  final Map<String, String> _filterValues = {};
  _ReportExecutionResult? _execution;
  bool _isRunningReport = false;
  String? _reportError;
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
      execution: _execution,
      isRunning: _isRunningReport,
      errorMessage: _reportError,
      onRun: _executeSelectedReport,
      onCopyCsv: _execution?.csv.isNotEmpty == true ? _copyCurrentCsv : null,
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
          onPressed: _isRunningReport
              ? null
              : () {
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
        if (_execution?.csv.isNotEmpty == true)
          TextButton.icon(
            onPressed: _isRunningReport ? null : _copyCurrentCsv,
            icon: const Icon(Icons.table_view_outlined, size: 18),
            label: const Text('Copiar CSV'),
          ),
        FilledButton.icon(
          onPressed: _isRunningReport ? null : _executeSelectedReport,
          icon: _isRunningReport
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.play_arrow_rounded, size: 18),
          label: Text(_isRunningReport ? 'Executando' : 'Executar'),
        ),
        TextButton(
          onPressed: _isRunningReport
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
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
    _execution = null;
    _reportError = null;
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

  Future<void> _executeSelectedReport() async {
    setState(() {
      _isRunningReport = true;
      _reportError = null;
    });

    try {
      final result = await _reportsRepository.executeReport(
        template: _selected,
        filters: Map<String, String>.from(_filterValues),
        requiredFilters: Set<String>.from(_requiredFilters),
        optionalFilters: Set<String>.from(_optionalFilters),
        delivery: _delivery,
        frequency: _frequency,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _execution = result;
        _isRunningReport = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.isReady
                ? 'Relatorio executado com ${result.rows.length} linhas.'
                : 'Relatorio preparado para a proxima etapa de implementacao.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isRunningReport = false;
        _reportError = _reportExecutionErrorMessage(error);
      });
    }
  }

  Future<void> _copyCurrentCsv() async {
    final csv = _execution?.csv;
    if (csv == null || csv.isEmpty) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: csv));
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('CSV do relatorio copiado.')));
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
    required this.execution,
    required this.isRunning,
    required this.errorMessage,
    required this.onRun,
    required this.onCopyCsv,
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
  final _ReportExecutionResult? execution;
  final bool isRunning;
  final String? errorMessage;
  final VoidCallback onRun;
  final VoidCallback? onCopyCsv;

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
          const SizedBox(height: 16),
          _CrmReportExecutionPanel(
            execution: execution,
            isRunning: isRunning,
            errorMessage: errorMessage,
            onRun: onRun,
            onCopyCsv: onCopyCsv,
          ),
        ],
      ),
    );
  }
}

class _CrmReportExecutionPanel extends StatelessWidget {
  const _CrmReportExecutionPanel({
    required this.execution,
    required this.isRunning,
    required this.errorMessage,
    required this.onRun,
    required this.onCopyCsv,
  });

  final _ReportExecutionResult? execution;
  final bool isRunning;
  final String? errorMessage;
  final VoidCallback onRun;
  final VoidCallback? onCopyCsv;

  @override
  Widget build(BuildContext context) {
    final result = execution;
    final ready = result?.isReady == true;

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
            children: [
              Icon(
                ready
                    ? Icons.check_circle_outline_rounded
                    : Icons.analytics_outlined,
                color: ready ? _tealColor : _slateColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Resultado',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: _inkColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: isRunning ? null : onRun,
                icon: isRunning
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow_rounded, size: 17),
                label: Text(isRunning ? 'Executando' : 'Executar'),
              ),
            ],
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 8),
            _CrmReportExecutionNotice(
              icon: Icons.error_outline_rounded,
              color: _roseColor,
              message: errorMessage!,
            ),
          ] else if (isRunning) ...[
            const SizedBox(height: 8),
            const SizedBox(height: 3, child: LinearProgressIndicator()),
          ] else if (result == null) ...[
            const SizedBox(height: 8),
            _CrmReportExecutionNotice(
              icon: Icons.info_outline_rounded,
              color: _slateColor,
              message: 'Aguardando execucao do relatorio selecionado.',
            ),
          ] else ...[
            const SizedBox(height: 8),
            if (result.metrics.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final metric in result.metrics)
                    _CrmReportMetricPill(metric: metric),
                ],
              ),
            if (result.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (final note in result.notes.take(2)) ...[
                _CrmReportExecutionNotice(
                  icon: Icons.info_outline_rounded,
                  color: result.isReady ? _amberColor : _slateColor,
                  message: note,
                ),
                const SizedBox(height: 6),
              ],
            ],
            if (result.hasRows) ...[
              const SizedBox(height: 10),
              _CrmReportPreviewTable(result: result),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${result.rows.length} linhas retornadas',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _mutedColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onCopyCsv,
                    icon: const Icon(Icons.table_view_outlined, size: 17),
                    label: const Text('CSV'),
                  ),
                ],
              ),
            ] else if (result.isReady) ...[
              const SizedBox(height: 8),
              _CrmReportExecutionNotice(
                icon: Icons.manage_search_outlined,
                color: _slateColor,
                message: 'Relatorio executado sem linhas para este recorte.',
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _CrmReportMetricPill extends StatelessWidget {
  const _CrmReportMetricPill({required this.metric});

  final _ReportMetric metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 96),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFFE5EAE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            metric.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: _deepTealColor,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            metric.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: _mutedColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CrmReportPreviewTable extends StatelessWidget {
  const _CrmReportPreviewTable({required this.result});

  final _ReportExecutionResult result;

  @override
  Widget build(BuildContext context) {
    final columns = result.columns.take(6).toList(growable: false);
    final rows = result.rows.take(6).toList(growable: false);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 34,
        dataRowMinHeight: 34,
        dataRowMaxHeight: 42,
        horizontalMargin: 10,
        columnSpacing: 18,
        columns: [
          for (final column in columns)
            DataColumn(
              label: Text(
                column.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: _inkColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
        rows: [
          for (final row in rows)
            DataRow(
              cells: [
                for (final column in columns)
                  DataCell(
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 180),
                      child: Text(
                        _apiText(row[column.keyName], fallback: '-'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _inkColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _CrmReportExecutionNotice extends StatelessWidget {
  const _CrmReportExecutionNotice({
    required this.icon,
    required this.color,
    required this.message,
  });

  final IconData icon;
  final Color color;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
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

String _reportExecutionErrorMessage(Object error) {
  if (error is ApiException) {
    return 'Nao foi possivel executar o relatorio (${error.code}).';
  }
  return 'Nao foi possivel executar o relatorio agora.';
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

const _dashboardAllFilter = 'Todos';

class _CrmDashboardContent extends StatefulWidget {
  const _CrmDashboardContent({
    required this.viewerProfile,
    required this.onChooseDestination,
    required this.pageWidth,
  });

  final _ViewerAccessProfile viewerProfile;
  final ValueChanged<_ChoiceTarget> onChooseDestination;
  final double pageWidth;

  @override
  State<_CrmDashboardContent> createState() => _CrmDashboardContentState();
}

class _CrmDashboardContentState extends State<_CrmDashboardContent> {
  final _repository = _HomeDashboardApiRepository();
  late final TextEditingController _searchController;
  late Future<_HomeDashboardData> _dashboardFuture;
  Set<String> _contractIds = <String>{};
  Set<String> _units = <String>{};
  Set<String> _departments = <String>{};
  Set<String> _positions = <String>{};
  Set<String> _regimes = <String>{};
  _DashboardPeriodSelection _period = const _DashboardPeriodSelection.current();
  String _search = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _dashboardFuture = _repository.load(query: _dashboardQuery());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CrmDashboardHero(onChooseDestination: widget.onChooseDestination),
            const SizedBox(height: 16),
            FutureBuilder<_HomeDashboardData>(
              future: _dashboardFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const _CrmDashboardLoading();
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return _CrmDashboardError(
                    error: snapshot.error,
                    onRetry: _reload,
                  );
                }

                final data = snapshot.data!;
                final rows = _filteredRows(data);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CrmDashboardFilterBar(
                      data: data,
                      selectedContractIds: _effectiveOptionSelection(
                        _contractIds,
                        data.filters.contracts.map((option) => option.value),
                      ),
                      selectedUnits: _effectiveOptionSelection(
                        _units,
                        data.filters.units,
                      ),
                      selectedDepartments: _effectiveOptionSelection(
                        _departments,
                        data.filters.departments,
                      ),
                      selectedPositions: _effectiveOptionSelection(
                        _positions,
                        data.filters.positions,
                      ),
                      selectedRegimes: _effectiveOptionSelection(
                        _regimes,
                        data.filters.regimes,
                      ),
                      period: _period,
                      onContractsChanged: (values) =>
                          _applyDashboardFilters(contractIds: values),
                      onUnitsChanged: (values) =>
                          _applyDashboardFilters(units: values),
                      onDepartmentsChanged: (values) =>
                          _applyDashboardFilters(departments: values),
                      onPositionsChanged: (values) =>
                          _applyDashboardFilters(positions: values),
                      onRegimesChanged: (values) =>
                          _applyDashboardFilters(regimes: values),
                      onPeriodChanged: (period) =>
                          _applyDashboardFilters(period: period),
                      onCustomPeriod: _openCustomPeriodPicker,
                    ),
                    const SizedBox(height: 18),
                    _CrmDashboardMetricGrid(
                      data: data,
                      onChooseDestination: widget.onChooseDestination,
                    ),
                    const SizedBox(height: 18),
                    _CrmActiveEmployeesPanel(
                      rows: rows,
                      totalRows: data.rows.length,
                      searchController: _searchController,
                      onSearchChanged: (value) =>
                          setState(() => _search = value.trim()),
                      onClearSearch: () {
                        _searchController.clear();
                        setState(() => _search = '');
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _reload() {
    setState(() {
      _dashboardFuture = _repository.load(query: _dashboardQuery());
    });
  }

  _HomeDashboardQuery _dashboardQuery() {
    return _HomeDashboardQuery(
      contractIds: _contractIds,
      units: _units,
      departments: _departments,
      positions: _positions,
      regimes: _regimes,
      period: _period,
    );
  }

  void _applyDashboardFilters({
    Set<String>? contractIds,
    Set<String>? units,
    Set<String>? departments,
    Set<String>? positions,
    Set<String>? regimes,
    _DashboardPeriodSelection? period,
  }) {
    setState(() {
      if (contractIds != null) {
        _contractIds = contractIds;
      }
      if (units != null) {
        _units = units;
      }
      if (departments != null) {
        _departments = departments;
      }
      if (positions != null) {
        _positions = positions;
      }
      if (regimes != null) {
        _regimes = regimes;
      }
      if (period != null) {
        _period = period;
      }
      _dashboardFuture = _repository.load(query: _dashboardQuery());
    });
  }

  Future<void> _openCustomPeriodPicker() async {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final initialRange = DateTimeRange(
      start:
          _period.start ?? normalizedToday.subtract(const Duration(days: 30)),
      end: _period.end ?? normalizedToday,
    );
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: normalizedToday,
      initialDateRange: initialRange,
      helpText: 'Personalizar periodo',
      cancelText: 'Cancelar',
      confirmText: 'Aplicar',
      saveText: 'Aplicar',
    );

    if (picked == null) {
      return;
    }

    _applyDashboardFilters(
      period: _DashboardPeriodSelection.custom(picked.start, picked.end),
    );
  }

  Set<String> _effectiveOptionSelection(
    Set<String> selected,
    Iterable<String> options,
  ) {
    final validOptions = options.toSet();
    return selected.where(validOptions.contains).toSet().cast<String>();
  }

  List<_HomeDashboardEmployeeRow> _filteredRows(_HomeDashboardData data) {
    final contractIds = _effectiveOptionSelection(
      _contractIds,
      data.filters.contracts.map((option) => option.value),
    );
    final units = _effectiveOptionSelection(_units, data.filters.units);
    final departments = _effectiveOptionSelection(
      _departments,
      data.filters.departments,
    );
    final positions = _effectiveOptionSelection(
      _positions,
      data.filters.positions,
    );
    final regimes = _effectiveOptionSelection(_regimes, data.filters.regimes);
    final query = _search.toLowerCase();

    return data.rows
        .where((row) {
          if (contractIds.isNotEmpty &&
              !contractIds.contains(row.contractPublicId)) {
            return false;
          }
          if (units.isNotEmpty && !units.contains(row.unit)) {
            return false;
          }
          if (departments.isNotEmpty && !departments.contains(row.department)) {
            return false;
          }
          if (positions.isNotEmpty && !positions.contains(row.position)) {
            return false;
          }
          if (regimes.isNotEmpty && !regimes.contains(row.regime)) {
            return false;
          }
          if (query.isEmpty) {
            return true;
          }

          final searchable = [
            row.employeeName,
            row.email,
            row.registration,
            row.contractLabel,
            row.position,
            row.department,
            row.unit,
            row.regime,
          ].join(' ').toLowerCase();
          return searchable.contains(query);
        })
        .toList(growable: false);
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
        final headlineSize = stacked ? 34.0 : 32.0;
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
            height: stacked ? 360 : 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _deepTealColor.withValues(alpha: 0.16),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
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
                      height: 190,
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
                      bottom: -18,
                      height: 96,
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
                      padding: EdgeInsets.all(stacked ? 24 : 36),
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
                                    letterSpacing: 0,
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

class _CrmDashboardFilterBar extends StatelessWidget {
  const _CrmDashboardFilterBar({
    required this.data,
    required this.selectedContractIds,
    required this.selectedUnits,
    required this.selectedDepartments,
    required this.selectedPositions,
    required this.selectedRegimes,
    required this.period,
    required this.onContractsChanged,
    required this.onUnitsChanged,
    required this.onDepartmentsChanged,
    required this.onPositionsChanged,
    required this.onRegimesChanged,
    required this.onPeriodChanged,
    required this.onCustomPeriod,
  });

  final _HomeDashboardData data;
  final Set<String> selectedContractIds;
  final Set<String> selectedUnits;
  final Set<String> selectedDepartments;
  final Set<String> selectedPositions;
  final Set<String> selectedRegimes;
  final _DashboardPeriodSelection period;
  final ValueChanged<Set<String>> onContractsChanged;
  final ValueChanged<Set<String>> onUnitsChanged;
  final ValueChanged<Set<String>> onDepartmentsChanged;
  final ValueChanged<Set<String>> onPositionsChanged;
  final ValueChanged<Set<String>> onRegimesChanged;
  final ValueChanged<_DashboardPeriodSelection> onPeriodChanged;
  final VoidCallback onCustomPeriod;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final columns = compact
              ? 1
              : constraints.maxWidth >= 1320
              ? 6
              : 3;
          final itemWidth = compact
              ? constraints.maxWidth
              : (constraints.maxWidth - 12 * (columns - 1)) / columns;

          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: itemWidth,
                child: _CrmDashboardMultiSelectTile(
                  label: 'Contratos',
                  selectedLabel: _dashboardSelectionLabel(
                    selectedContractIds,
                    data.filters.contracts,
                  ),
                  options: data.filters.contracts,
                  selectedValues: selectedContractIds,
                  icon: Icons.description_outlined,
                  onChanged: onContractsChanged,
                ),
              ),
              SizedBox(
                width: itemWidth,
                child: _CrmDashboardMultiSelectTile(
                  label: 'Unidade',
                  selectedLabel: _dashboardStringSelectionLabel(
                    selectedUnits,
                    data.filters.units,
                  ),
                  options: _dashboardChoicesFromStrings(data.filters.units),
                  selectedValues: selectedUnits,
                  icon: Icons.apartment_rounded,
                  onChanged: onUnitsChanged,
                ),
              ),
              SizedBox(
                width: itemWidth,
                child: _CrmDashboardMultiSelectTile(
                  label: 'Departamento',
                  selectedLabel: _dashboardStringSelectionLabel(
                    selectedDepartments,
                    data.filters.departments,
                  ),
                  options: _dashboardChoicesFromStrings(
                    data.filters.departments,
                  ),
                  selectedValues: selectedDepartments,
                  icon: Icons.account_tree_outlined,
                  onChanged: onDepartmentsChanged,
                ),
              ),
              SizedBox(
                width: itemWidth,
                child: _CrmDashboardMultiSelectTile(
                  label: 'Cargo',
                  selectedLabel: _dashboardStringSelectionLabel(
                    selectedPositions,
                    data.filters.positions,
                  ),
                  options: _dashboardChoicesFromStrings(data.filters.positions),
                  selectedValues: selectedPositions,
                  icon: Icons.work_outline_rounded,
                  onChanged: onPositionsChanged,
                ),
              ),
              SizedBox(
                width: itemWidth,
                child: _CrmDashboardMultiSelectTile(
                  label: 'Regime',
                  selectedLabel: _dashboardStringSelectionLabel(
                    selectedRegimes,
                    data.filters.regimes,
                  ),
                  options: _dashboardChoicesFromStrings(data.filters.regimes),
                  selectedValues: selectedRegimes,
                  icon: Icons.badge_outlined,
                  onChanged: onRegimesChanged,
                ),
              ),
              SizedBox(
                width: itemWidth,
                child: _CrmDashboardDateTile(
                  baseDate: data.baseDate,
                  period: period,
                  responsePeriod: data.period,
                  onSelected: onPeriodChanged,
                  onCustomPeriod: onCustomPeriod,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CrmDashboardMultiSelectTile extends StatefulWidget {
  const _CrmDashboardMultiSelectTile({
    required this.label,
    required this.selectedLabel,
    required this.options,
    required this.selectedValues,
    required this.icon,
    required this.onChanged,
  });

  final String label;
  final String selectedLabel;
  final List<_HomeDashboardFilterOption> options;
  final Set<String> selectedValues;
  final IconData icon;
  final ValueChanged<Set<String>> onChanged;

  @override
  State<_CrmDashboardMultiSelectTile> createState() =>
      _CrmDashboardMultiSelectTileState();
}

class _CrmDashboardMultiSelectTileState
    extends State<_CrmDashboardMultiSelectTile> {
  final MenuController _menuController = MenuController();
  late Set<String> _pendingValues;

  @override
  void initState() {
    super.initState();
    _pendingValues = {...widget.selectedValues};
  }

  @override
  void didUpdateWidget(covariant _CrmDashboardMultiSelectTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_menuController.isOpen) {
      _pendingValues = {...widget.selectedValues};
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final menuWidth = max(300.0, constraints.maxWidth);

        return MenuAnchor(
          controller: _menuController,
          alignmentOffset: const Offset(0, 8),
          onOpen: () {
            setState(() {
              _pendingValues = {...widget.selectedValues};
            });
          },
          onClose: _commitPendingValues,
          menuChildren: [
            _CrmDashboardMultiSelectMenu(
              width: menuWidth,
              title: widget.label,
              options: widget.options,
              selectedValues: _pendingValues,
              onChanged: (values) {
                setState(() {
                  _pendingValues = values;
                });
              },
            ),
          ],
          builder: (context, controller, child) {
            return _CrmDashboardFilterShell(
              label: widget.label,
              value: widget.selectedLabel,
              icon: widget.icon,
              trailing: Icon(
                controller.isOpen
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 20,
              ),
              onTap: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
            );
          },
        );
      },
    );
  }

  void _commitPendingValues() {
    final optionValues = widget.options.map((option) => option.value).toSet();
    final normalizedValues =
        optionValues.isNotEmpty &&
            optionValues.difference(_pendingValues).isEmpty
        ? <String>{}
        : _pendingValues;

    if (!_dashboardSetEquals(normalizedValues, widget.selectedValues)) {
      widget.onChanged({...normalizedValues});
    }
  }
}

class _CrmDashboardMultiSelectMenu extends StatelessWidget {
  const _CrmDashboardMultiSelectMenu({
    required this.width,
    required this.title,
    required this.options,
    required this.selectedValues,
    required this.onChanged,
  });

  final double width;
  final String title;
  final List<_HomeDashboardFilterOption> options;
  final Set<String> selectedValues;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final optionValues = options.map((option) => option.value).toSet();
    final allSelected =
        selectedValues.isEmpty ||
        (optionValues.isNotEmpty &&
            optionValues.difference(selectedValues).isEmpty);

    return Container(
      width: width,
      constraints: const BoxConstraints(maxHeight: 360),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E7E5)),
        boxShadow: [
          BoxShadow(
            color: _inkColor.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: options.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Nenhuma opcao disponivel no recorte atual.'),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _inkColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                CheckboxListTile(
                  value: allSelected,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('Selecionar todos'),
                  onChanged: (_) => onChanged(<String>{}),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    children: [
                      for (final option in options)
                        CheckboxListTile(
                          value:
                              allSelected ||
                              selectedValues.contains(option.value),
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(
                            option.label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onChanged: (checked) {
                            final nextValues = allSelected
                                ? {...optionValues}
                                : {...selectedValues};
                            if (checked == true) {
                              nextValues.add(option.value);
                            } else {
                              nextValues.remove(option.value);
                            }
                            onChanged(nextValues);
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _CrmDashboardDateTile extends StatelessWidget {
  const _CrmDashboardDateTile({
    required this.baseDate,
    required this.period,
    required this.responsePeriod,
    required this.onSelected,
    required this.onCustomPeriod,
  });

  final String baseDate;
  final _DashboardPeriodSelection period;
  final _HomeDashboardPeriod responsePeriod;
  final ValueChanged<_DashboardPeriodSelection> onSelected;
  final VoidCallback onCustomPeriod;

  @override
  Widget build(BuildContext context) {
    final value = period.isCurrent
        ? 'Estatisticas atuais'
        : responsePeriod.label;

    return PopupMenuButton<String>(
      tooltip: 'Data base',
      offset: const Offset(0, 58),
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 320),
      onSelected: (value) {
        if (value == 'custom') {
          onCustomPeriod();
          return;
        }
        onSelected(_DashboardPeriodSelection.preset(value));
      },
      itemBuilder: (context) => const [
        PopupMenuItem<String>(value: 'current', child: Text('Atual')),
        PopupMenuDivider(height: 1),
        PopupMenuItem<String>(value: 'last30', child: Text('Ultimos 30 dias')),
        PopupMenuItem<String>(value: 'last45', child: Text('Ultimos 45 dias')),
        PopupMenuItem<String>(value: 'last90', child: Text('Ultimos 90 dias')),
        PopupMenuItem<String>(value: 'last6m', child: Text('Ultimos 6 meses')),
        PopupMenuItem<String>(value: 'last1y', child: Text('Ultimo ano')),
        PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          value: 'custom',
          child: Text('Personalizar periodo...'),
        ),
      ],
      child: _CrmDashboardFilterShell(
        label: 'Data base',
        value: '$value - ${_apiLongDate(baseDate)}',
        icon: Icons.calendar_today_outlined,
        trailing: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
      ),
    );
  }
}

class _CrmDashboardFilterShell extends StatelessWidget {
  const _CrmDashboardFilterShell({
    required this.label,
    required this.value,
    required this.icon,
    required this.trailing,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E7E5)),
          ),
          child: Row(
            children: [
              Icon(icon, color: _mutedColor, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _mutedColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _inkColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

bool _dashboardSetEquals(Set<String> left, Set<String> right) {
  if (left.length != right.length) {
    return false;
  }

  return left.difference(right).isEmpty;
}

List<_HomeDashboardFilterOption> _dashboardChoicesFromStrings(
  List<String> values,
) {
  return [
    for (final value in values)
      _HomeDashboardFilterOption(value: value, label: value),
  ];
}

String _dashboardSelectionLabel(
  Set<String> selectedValues,
  List<_HomeDashboardFilterOption> options,
) {
  if (selectedValues.isEmpty || selectedValues.length == options.length) {
    return _dashboardAllFilter;
  }

  if (selectedValues.length == 1) {
    final selected = selectedValues.first;
    return options
        .firstWhere(
          (option) => option.value == selected,
          orElse: () =>
              _HomeDashboardFilterOption(value: selected, label: selected),
        )
        .label;
  }

  return '${selectedValues.length} selecionados';
}

String _dashboardStringSelectionLabel(
  Set<String> selectedValues,
  List<String> options,
) {
  return _dashboardSelectionLabel(
    selectedValues,
    _dashboardChoicesFromStrings(options),
  );
}

class _CrmDashboardMetricGrid extends StatelessWidget {
  const _CrmDashboardMetricGrid({
    required this.data,
    required this.onChooseDestination,
  });

  final _HomeDashboardData data;
  final ValueChanged<_ChoiceTarget> onChooseDestination;

  @override
  Widget build(BuildContext context) {
    final metrics = data.metrics;
    final cards = [
      _CrmMetricCardData(
        title: 'Colaboradores ativos',
        value: metrics.activeEmployees,
        detail: '${metrics.providerCompanies} prestadoras ativas',
        icon: Icons.groups_2_outlined,
        color: const Color(0xFF2563A8),
        target: _ChoiceTarget.people,
      ),
      _CrmMetricCardData(
        title: 'Novos (${data.period.shortLabel})',
        value: metrics.newEmployees30Days,
        detail: '+${metrics.newEmployees30Days} no recorte',
        icon: Icons.person_add_alt_1_outlined,
        color: _tealColor,
        target: _ChoiceTarget.people,
      ),
      _CrmMetricCardData(
        title: 'Pendentes',
        value: metrics.pendingLinks,
        detail: 'Acoes necessarias',
        icon: Icons.hourglass_top_rounded,
        color: const Color(0xFFD79A16),
        target: _ChoiceTarget.people,
      ),
      _CrmMetricCardData(
        title: 'Em risco',
        value: metrics.riskItems,
        detail: '${metrics.activeContracts} contratos ativos',
        icon: Icons.gpp_maybe_outlined,
        color: _roseColor,
        target: _ChoiceTarget.network,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardsPerRow = constraints.maxWidth >= 1180
            ? 4
            : constraints.maxWidth >= 760
            ? 2
            : 1;
        const spacing = 16.0;
        final width = cardsPerRow == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - spacing * (cardsPerRow - 1)) /
                  cardsPerRow;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final card in cards)
              SizedBox(
                width: width,
                child: _CrmDashboardMetricCard(
                  card: card,
                  onTap: () => onChooseDestination(card.target),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CrmMetricCardData {
  const _CrmMetricCardData({
    required this.title,
    required this.value,
    required this.detail,
    required this.icon,
    required this.color,
    required this.target,
  });

  final String title;
  final int value;
  final String detail;
  final IconData icon;
  final Color color;
  final _ChoiceTarget target;
}

class _CrmDashboardMetricCard extends StatelessWidget {
  const _CrmDashboardMetricCard({required this.card, required this.onTap});

  final _CrmMetricCardData card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        height: 154,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE7ECEA)),
          boxShadow: [
            BoxShadow(
              color: _inkColor.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final showSparkline = constraints.maxWidth >= 420;

            return Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        card.color.withValues(alpha: 0.22),
                        card.color.withValues(alpha: 0.08),
                        Colors.white,
                      ],
                    ),
                  ),
                  child: Icon(card.icon, color: card.color, size: 32),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        card.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _inkColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${card.value}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        card.detail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: card.color,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showSparkline)
                  SizedBox(
                    width: 78,
                    height: 54,
                    child: _CrmMetricSparkline(color: card.color),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CrmMetricSparkline extends StatelessWidget {
  const _CrmMetricSparkline({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _CrmMetricSparklinePainter(color));
  }
}

class _CrmMetricSparklinePainter extends CustomPainter {
  const _CrmMetricSparklinePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final points = [
      const Offset(0.04, 0.80),
      const Offset(0.20, 0.54),
      const Offset(0.36, 0.64),
      const Offset(0.52, 0.32),
      const Offset(0.70, 0.42),
      const Offset(0.88, 0.18),
      const Offset(0.98, 0.24),
    ];

    for (var i = 0; i < points.length; i++) {
      final point = Offset(
        points[i].dx * size.width,
        points[i].dy * size.height,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CrmMetricSparklinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _CrmActiveEmployeesPanel extends StatelessWidget {
  const _CrmActiveEmployeesPanel({
    required this.rows,
    required this.totalRows,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
  });

  final List<_HomeDashboardEmployeeRow> rows;
  final int totalRows;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 760;
                final title = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Colaboradores ativos',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${rows.length} exibidos de $totalRows no recorte atual',
                      style: const TextStyle(color: _mutedColor, fontSize: 13),
                    ),
                  ],
                );
                final search = _ContextSearchField(
                  controller: searchController,
                  hintText: 'Buscar colaborador',
                  accent: _slateColor,
                  maxWidth: compact ? double.infinity : 320,
                  onChanged: onSearchChanged,
                  onSubmitted: onSearchChanged,
                  onClear: onClearSearch,
                  onSearch: () => onSearchChanged(searchController.text),
                );

                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [title, const SizedBox(height: 14), search],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: title),
                    search,
                    const SizedBox(width: 12),
                    _CrmSmallToolbarButton(
                      icon: Icons.view_column_outlined,
                      label: 'Colunas',
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.more_vert_rounded, color: _mutedColor),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE7ECEA)),
          _CrmEmployeeTable(rows: rows),
        ],
      ),
    );
  }
}

class _CrmSmallToolbarButton extends StatelessWidget {
  const _CrmSmallToolbarButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E7E5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: _inkColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: _inkColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CrmEmployeeTable extends StatelessWidget {
  const _CrmEmployeeTable({required this.rows});

  final List<_HomeDashboardEmployeeRow> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const _CrmEmptyEmployeeRows();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 1120;

        if (compact) {
          return Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                for (final row in rows) _CrmEmployeeCompactCard(row: row),
              ],
            ),
          );
        }

        return Column(
          children: [
            const _CrmEmployeeHeaderRow(),
            for (final row in rows) _CrmEmployeeDataRow(row: row),
            _CrmEmployeePagination(totalRows: rows.length),
          ],
        );
      },
    );
  }
}

class _CrmEmployeeHeaderRow extends StatelessWidget {
  const _CrmEmployeeHeaderRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      color: const Color(0xFFF8FAFA),
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: const Row(
        children: [
          _CrmTableHeaderCell(label: 'Colaborador', flex: 3),
          _CrmTableHeaderCell(label: 'Matricula', flex: 2),
          _CrmTableHeaderCell(label: 'Cargo', flex: 2),
          _CrmTableHeaderCell(label: 'Departamento', flex: 2),
          _CrmTableHeaderCell(label: 'Unidade', flex: 2),
          _CrmTableHeaderCell(label: 'Admissao', flex: 1),
          _CrmTableHeaderCell(label: 'Regime', flex: 1),
          _CrmTableHeaderCell(label: 'Situacao', flex: 1),
          SizedBox(width: 28),
        ],
      ),
    );
  }
}

class _CrmTableHeaderCell extends StatelessWidget {
  const _CrmTableHeaderCell({required this.label, required this.flex});

  final String label;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: _inkColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CrmEmployeeDataRow extends StatelessWidget {
  const _CrmEmployeeDataRow({required this.row});

  final _HomeDashboardEmployeeRow row;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 66),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE7ECEA))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                _CrmEmployeeAvatar(row: row),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row.employeeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _inkColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        row.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _mutedColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _CrmTableTextCell(text: row.registration, flex: 2),
          _CrmTableTextCell(text: row.position, flex: 2),
          _CrmTableTextCell(text: row.department, flex: 2),
          _CrmTableTextCell(text: row.unit, flex: 2),
          _CrmTableTextCell(text: _apiLongDate(row.admissionDate), flex: 1),
          _CrmTableTextCell(text: row.regime, flex: 1),
          Expanded(flex: 1, child: _CrmStatusPill(row: row)),
          const SizedBox(width: 28, child: Icon(Icons.more_vert_rounded)),
        ],
      ),
    );
  }
}

class _CrmTableTextCell extends StatelessWidget {
  const _CrmTableTextCell({required this.text, required this.flex});

  final String text;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: _inkColor, fontSize: 13),
      ),
    );
  }
}

class _CrmEmployeeAvatar extends StatelessWidget {
  const _CrmEmployeeAvatar({required this.row});

  final _HomeDashboardEmployeeRow row;

  @override
  Widget build(BuildContext context) {
    final colors = _avatarColors(row.employeeName);
    return CircleAvatar(
      radius: 20,
      backgroundColor: colors.background,
      child: Text(
        row.employeeInitials,
        maxLines: 1,
        overflow: TextOverflow.clip,
        style: TextStyle(
          color: colors.foreground,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _CrmStatusPill extends StatelessWidget {
  const _CrmStatusPill({required this.row});

  final _HomeDashboardEmployeeRow row;

  @override
  Widget build(BuildContext context) {
    final color = switch (row.status.toUpperCase()) {
      'ACTIVE' => _tealColor,
      'PENDING' => _amberColor,
      'SUSPENDED' || 'BLOCKED' || 'DISMISSED' => _roseColor,
      _ => _slateColor,
    };

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          row.statusLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _CrmEmployeeCompactCard extends StatelessWidget {
  const _CrmEmployeeCompactCard({required this.row});

  final _HomeDashboardEmployeeRow row;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7ECEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CrmEmployeeAvatar(row: row),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.employeeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _inkColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      row.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _mutedColor, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _CrmStatusPill(row: row),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _CrmCompactMeta(label: 'Cargo', value: row.position),
              _CrmCompactMeta(label: 'Departamento', value: row.department),
              _CrmCompactMeta(label: 'Unidade', value: row.unit),
              _CrmCompactMeta(
                label: 'Admissao',
                value: _apiLongDate(row.admissionDate),
              ),
              _CrmCompactMeta(label: 'Regime', value: row.regime),
            ],
          ),
        ],
      ),
    );
  }
}

class _CrmCompactMeta extends StatelessWidget {
  const _CrmCompactMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _mutedColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _inkColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CrmEmployeePagination extends StatelessWidget {
  const _CrmEmployeePagination({required this.totalRows});

  final int totalRows;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE7ECEA))),
      ),
      child: Row(
        children: [
          const Text(
            'Linhas por pagina: 10',
            style: TextStyle(color: _inkColor),
          ),
          const Spacer(),
          Text(
            totalRows == 0 ? '0' : '1-$totalRows',
            style: const TextStyle(color: _mutedColor),
          ),
          const SizedBox(width: 18),
          const Icon(Icons.chevron_left_rounded, color: _mutedColor),
          const SizedBox(width: 8),
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '1',
              style: TextStyle(
                color: Color(0xFF2563A8),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: _mutedColor),
        ],
      ),
    );
  }
}

class _CrmEmptyEmployeeRows extends StatelessWidget {
  const _CrmEmptyEmployeeRows();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: Text(
          'Nenhum colaborador ativo encontrado para os filtros atuais.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
        ),
      ),
    );
  }
}

class _CrmDashboardLoading extends StatelessWidget {
  const _CrmDashboardLoading();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          const SizedBox(height: 3, child: LinearProgressIndicator()),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth >= 760
                  ? (constraints.maxWidth - 48) / 4
                  : constraints.maxWidth;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (var index = 0; index < 4; index++)
                    Container(
                      width: width,
                      height: 112,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F5F4),
                        borderRadius: BorderRadius.circular(16),
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

class _CrmDashboardError extends StatelessWidget {
  const _CrmDashboardError({required this.error, required this.onRetry});

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final message = error is ApiException
        ? 'API indisponivel para o resumo (${(error! as ApiException).code}).'
        : 'Nao foi possivel carregar o resumo operacional.';

    return _Panel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _roseColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.cloud_off_outlined, color: _roseColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumo operacional nao carregado',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  '$message Nenhum dado mock foi exibido.',
                  style: const TextStyle(color: _mutedColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Recarregar'),
          ),
        ],
      ),
    );
  }
}

({Color background, Color foreground}) _avatarColors(String seed) {
  final palette = [
    (background: const Color(0xFFE8F1FF), foreground: const Color(0xFF2563A8)),
    (background: const Color(0xFFE6F6EA), foreground: const Color(0xFF2E8B57)),
    (background: const Color(0xFFF1E6FF), foreground: const Color(0xFF7A3FC7)),
    (background: const Color(0xFFFFF3D8), foreground: const Color(0xFFC8891F)),
  ];
  final index =
      seed.codeUnits.fold<int>(0, (sum, code) => sum + code) % palette.length;
  return palette[index];
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
                        semanticLabel: widget.item.shortLabel,
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
