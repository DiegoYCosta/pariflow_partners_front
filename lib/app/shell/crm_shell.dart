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
    color: _tealColor,
  ),
  _CrmReportFamilyMeta(
    family: _CrmReportFamily.controls,
    title: 'Controles',
    subtitle: 'Pendencias, SLA, documentos e evidencias.',
    icon: Icons.gpp_good_outlined,
    color: _tealColor,
  ),
  _CrmReportFamilyMeta(
    family: _CrmReportFamily.management,
    title: 'Gerenciais',
    subtitle: 'Pessoas, contratos, carteira e operacao corrente.',
    icon: Icons.groups_2_outlined,
    color: _tealColor,
  ),
  _CrmReportFamilyMeta(
    family: _CrmReportFamily.compliance,
    title: 'Compliance',
    subtitle: 'Excecoes, acessos sensiveis e criticidade.',
    icon: Icons.verified_user_outlined,
    color: _tealColor,
  ),
  _CrmReportFamilyMeta(
    family: _CrmReportFamily.audit,
    title: 'Logs/Auditoria',
    subtitle: 'Trilha de alteracoes, exclusoes e parametros.',
    icon: Icons.receipt_long_outlined,
    color: _tealColor,
  ),
  _CrmReportFamilyMeta(
    family: _CrmReportFamily.automation,
    title: 'Automacoes',
    subtitle: 'Recorrencia, destinatarios e pacotes periodicos.',
    icon: Icons.smart_toy_outlined,
    color: _tealColor,
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
    id: 'controls_calendar',
    title: 'Compromissos e lembretes',
    description: 'Agenda por periodo, incluindo finais de semana e feriados.',
    icon: Icons.event_note_outlined,
    family: _CrmReportFamily.controls,
    filters: [
      'Periodo',
      'Tipo de agenda',
      'Status da agenda',
      'Empresa',
      'Vinculo',
    ],
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final families = _orderedCrmReportFamilies;
        final visibleCount = _visibleReportFamilyCount(
          constraints.maxWidth,
          families.length,
        );
        final visibleFamilies = families.take(visibleCount);
        final hiddenFamilies = families
            .skip(visibleCount)
            .toList(growable: false);

        return SizedBox(
          height: 46,
          child: Row(
            children: [
              for (final family in visibleFamilies)
                Flexible(
                  fit: FlexFit.loose,
                  child: _CrmReportFamilyMenuButton(
                    meta: family,
                    templates: _templatesFor(family.family),
                    onSelected: (template) =>
                        _openReportSettings(context, template),
                  ),
                ),
              if (hiddenFamilies.isNotEmpty)
                _CrmReportFamilyOverflowButton(
                  families: hiddenFamilies,
                  onSelected: (template) =>
                      _openReportSettings(context, template),
                ),
            ],
          ),
        );
      },
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

int _visibleReportFamilyCount(double width, int total) {
  final visible = switch (width) {
    < 230 => 0,
    < 420 => 1,
    < 590 => 2,
    < 760 => 3,
    < 930 => 4,
    < 1100 => 5,
    _ => total,
  };
  return visible.clamp(0, total);
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

class _CrmReportFamilyMenuButton extends StatefulWidget {
  const _CrmReportFamilyMenuButton({
    required this.meta,
    required this.templates,
    required this.onSelected,
  });

  final _CrmReportFamilyMeta meta;
  final List<_CrmReportTemplate> templates;
  final ValueChanged<_CrmReportTemplate> onSelected;

  @override
  State<_CrmReportFamilyMenuButton> createState() =>
      _CrmReportFamilyMenuButtonState();
}

class _CrmReportFamilyMenuButtonState
    extends State<_CrmReportFamilyMenuButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final foreground = _hovered ? Colors.white : _inkColor;
    final background = _hovered ? _deepTealColor : Colors.transparent;
    final borderColor = _hovered ? _deepTealColor : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: PopupMenuButton<_CrmReportTemplate>(
          tooltip: widget.meta.title,
          offset: const Offset(0, 39),
          constraints: const BoxConstraints(minWidth: 306, maxWidth: 360),
          onSelected: widget.onSelected,
          itemBuilder: (context) =>
              _reportFamilyMenuEntries(widget.meta, widget.templates),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 13),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.meta.icon, color: foreground, size: 20),
                const SizedBox(width: 9),
                Flexible(
                  child: Text(
                    widget.meta.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w800,
                    ),
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
      ),
    );
  }
}

class _CrmReportFamilyOverflowButton extends StatefulWidget {
  const _CrmReportFamilyOverflowButton({
    required this.families,
    required this.onSelected,
  });

  final List<_CrmReportFamilyMeta> families;
  final ValueChanged<_CrmReportTemplate> onSelected;

  @override
  State<_CrmReportFamilyOverflowButton> createState() =>
      _CrmReportFamilyOverflowButtonState();
}

class _CrmReportFamilyOverflowButtonState
    extends State<_CrmReportFamilyOverflowButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final foreground = _hovered ? Colors.white : _inkColor;
    final background = _hovered ? _deepTealColor : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: PopupMenuButton<_CrmReportTemplate>(
        tooltip: 'Mais relatorios',
        offset: const Offset(0, 39),
        constraints: const BoxConstraints(minWidth: 306, maxWidth: 360),
        onSelected: widget.onSelected,
        itemBuilder: (context) => [
          for (final family in widget.families) ...[
            PopupMenuItem<_CrmReportTemplate>(
              enabled: false,
              height: 52,
              child: _CrmReportMenuHeader(
                meta: family,
                count: _templatesFor(family.family).length,
              ),
            ),
            if (_templatesFor(family.family).isEmpty)
              const PopupMenuItem<_CrmReportTemplate>(
                enabled: false,
                child: Text('Nenhuma opcao disponivel'),
              )
            else
              for (final template in _templatesFor(family.family))
                PopupMenuItem<_CrmReportTemplate>(
                  value: template,
                  height: 54,
                  child: _CrmReportMenuItem(
                    template: template,
                    color: family.color,
                  ),
                ),
            const PopupMenuDivider(height: 1),
          ],
        ],
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: _hovered ? _deepTealColor : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.more_horiz_rounded, color: foreground, size: 20),
              const SizedBox(width: 8),
              Text(
                'Mais',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
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

List<PopupMenuEntry<_CrmReportTemplate>> _reportFamilyMenuEntries(
  _CrmReportFamilyMeta meta,
  List<_CrmReportTemplate> templates,
) {
  return [
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
          child: _CrmReportMenuItem(template: template, color: meta.color),
        ),
  ];
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
          if (result != null) ...[
            const SizedBox(height: 6),
            _CrmReportMetadataStrip(metadata: result.metadata),
          ],
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

class _CrmReportMetadataStrip extends StatelessWidget {
  const _CrmReportMetadataStrip({required this.metadata});

  final _ReportMetadata metadata;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _CrmReportMetadataLine(
              icon: Icons.schedule_outlined,
              text: 'Gerado em ${metadata.generatedAtLabel}',
              style: textTheme.labelMedium?.copyWith(
                color: _inkColor,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            _CrmReportMetadataLine(
              icon: Icons.person_outline_rounded,
              text: 'Usuario ${metadata.generatedByLabel}',
              style: textTheme.labelSmall?.copyWith(
                color: _mutedColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            _CrmReportMetadataLine(
              icon: Icons.business_outlined,
              text: metadata.linkedCompanyLabel,
              style: textTheme.labelSmall?.copyWith(
                color: _mutedColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            _CrmReportMetadataLine(
              icon: Icons.admin_panel_settings_outlined,
              text: metadata.permissionLabel,
              style: textTheme.labelSmall?.copyWith(
                color: _mutedColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CrmReportMetadataLine extends StatelessWidget {
  const _CrmReportMetadataLine({
    required this.icon,
    required this.text,
    required this.style,
  });

  final IconData icon;
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: _mutedColor),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: style,
          ),
        ),
      ],
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
  if (normalized.contains('agenda') && normalized.contains('tipo')) {
    return const ['Todos', 'Lembrete', 'Compromisso'];
  }
  if (normalized.contains('agenda') && normalized.contains('status')) {
    return const ['Todos', 'Agendado', 'Concluido', 'Cancelado', 'Perdido'];
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
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => showDialog<void>(
        context: context,
        builder: (context) => _CrmProfileSettingsDialog(
          viewerProfile: viewerProfile,
          onViewerChanged: onViewerChanged,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CrmHeaderViewerIdentity(
              viewerProfile: viewerProfile,
              compact: compact,
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF1F302C),
              size: 19,
            ),
          ],
        ),
      ),
    );
  }
}

class _CrmProfileSettingsDialog extends StatefulWidget {
  const _CrmProfileSettingsDialog({
    required this.viewerProfile,
    required this.onViewerChanged,
  });

  final _ViewerAccessProfile viewerProfile;
  final ValueChanged<_ViewerAccessProfile> onViewerChanged;

  @override
  State<_CrmProfileSettingsDialog> createState() =>
      _CrmProfileSettingsDialogState();
}

class _CrmProfileSettingsDialogState extends State<_CrmProfileSettingsDialog> {
  static const _calendarOverdueWindowStorageKey =
      'pariflow.calendar.overdue_window.v1';
  static const _calendarOverdueWindowOptions = <String>[
    'Nao mostrar',
    '12 horas',
    '24 horas',
    '3 dias',
    '7 dias',
    '15 dias',
    '30 dias',
  ];

  final _profileApi = ApiClient();
  final _onboardingApi = ApiClient();
  final _calendarApi = ApiClient();
  late final TextEditingController _profileZipCode;
  late final TextEditingController _profileStreet;
  late final TextEditingController _profileNumber;
  late final TextEditingController _profileDistrict;
  late final TextEditingController _profileCity;
  late final TextEditingController _profileState;
  late _ViewerAccessProfile _selectedViewer;
  String _language = 'Portugues (Brasil)';
  String _timeZone = 'America/Sao_Paulo';
  bool _use24h = true;
  bool _notifyInApp = true;
  bool _notifyEmail = true;
  bool _notifyPush = true;
  bool _notifyWhatsapp = false;
  bool _secondaryEmailActive = true;
  bool _secondaryWhatsappActive = false;
  bool _secondarySmsActive = false;
  bool _linkWhatsapp = false;
  final bool _linkEmail = true;
  bool _linkSms = false;
  String _calendarOverdueWindow = 'Nao mostrar';
  late DateTime _calendarMonth;
  var _calendarEntries = <Map<String, dynamic>>[];
  var _calendarNonBusinessDays = <Map<String, dynamic>>[];
  var _calendarFilters = <String, String>{};
  bool _loadingCalendar = false;
  bool _savingProfile = false;
  String? _calendarError;
  var _onboardingRequests = <Map<String, dynamic>>[];
  bool _loadingOnboarding = false;
  String? _onboardingError;

  @override
  void initState() {
    super.initState();
    _selectedViewer = widget.viewerProfile;
    _profileZipCode = TextEditingController();
    _profileStreet = TextEditingController();
    _profileNumber = TextEditingController();
    _profileDistrict = TextEditingController();
    _profileCity = TextEditingController(text: 'Campinas');
    _profileState = TextEditingController(text: 'SP');
    final now = DateTime.now();
    _calendarMonth = DateTime(now.year, now.month);
    unawaited(_loadCurrentUserProfile());
    unawaited(_loadCalendarPreferencesAndCalendar());
    unawaited(_loadOnboardingRequests());
  }

  @override
  void dispose() {
    _profileZipCode.dispose();
    _profileStreet.dispose();
    _profileNumber.dispose();
    _profileDistrict.dispose();
    _profileCity.dispose();
    _profileState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return DefaultTabController(
      length: 8,
      child: AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 12, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        title: Row(
          children: [
            _CrmHeaderAvatar(viewerProfile: _selectedViewer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Perfis e configuracoes',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_selectedViewer.name} | ${_viewerRoleLabel(_selectedViewer)}',
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
            IconButton(
              tooltip: 'Fechar',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
        content: SizedBox(
          width: min(size.width * 0.92, 920),
          height: min(size.height * 0.78, 680),
          child: Column(
            children: [
              const TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: 'Perfil'),
                  Tab(text: 'Conta'),
                  Tab(text: 'Seguranca'),
                  Tab(text: 'Personalizacao'),
                  Tab(text: 'Contatos'),
                  Tab(text: 'Calendario'),
                  Tab(text: 'Onboarding'),
                  Tab(text: 'Whatsapp Agentic AI Workflow'),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: TabBarView(
                  children: [
                    _profileTab(context),
                    _accountTab(context),
                    _securityTab(context),
                    _personalizationTab(context),
                    _contactsTab(context),
                    _calendarTab(context),
                    _onboardingTab(context),
                    _whatsappAgenticWorkflowTab(context),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _savingProfile ? null : () => unawaited(_logout()),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Sair'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
          FilledButton.icon(
            onPressed: _savingProfile
                ? null
                : () => unawaited(_applyProfileSettings()),
            icon: _savingProfile
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded, size: 18),
            label: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await _profileApi.logout();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _loadCurrentUserProfile() async {
    try {
      final data = await _profileApi.getMap('auth/me');
      if (!mounted) {
        return;
      }
      final user = _apiMap(data['user']);
      final address = _apiMap(user['addressJson']);
      setState(() {
        _profileZipCode.text = _apiText(address['zipCode']);
        _profileStreet.text = _apiText(address['street']);
        _profileNumber.text = _apiText(address['number']);
        _profileDistrict.text = _apiText(address['district']);
        _profileCity.text = _apiText(address['city'], fallback: 'Campinas');
        _profileState.text = _apiText(address['state'], fallback: 'SP');
      });
    } on ApiException {
      // O dialogo continua utilizavel mesmo que a leitura de preferencias falhe.
    }
  }

  Future<void> _applyProfileSettings() async {
    setState(() => _savingProfile = true);
    try {
      await _profileApi.patchMap(
        'auth/me',
        body: {'addressJson': _profileAddressJson()},
      );
      widget.onViewerChanged(_selectedViewer);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: _roseColor),
      );
    } finally {
      if (mounted) {
        setState(() => _savingProfile = false);
      }
    }
  }

  Map<String, String> _profileAddressJson() {
    final address = <String, String>{};
    void put(String key, String value) {
      final text = value.trim();
      if (text.isNotEmpty) {
        address[key] = text;
      }
    }

    put('zipCode', _profileZipCode.text);
    put('street', _profileStreet.text);
    put('number', _profileNumber.text);
    put('district', _profileDistrict.text);
    put('city', _profileCity.text);
    put('state', _profileState.text.toUpperCase());
    return address;
  }

  Widget _profileTab(BuildContext context) {
    return ListView(
      children: [
        _settingsSection(
          context,
          title: 'Perfil ativo',
          icon: Icons.account_circle_outlined,
          children: [
            _settingsInfoTile(
              icon: _selectedViewer.icon,
              title: _selectedViewer.name,
              subtitle:
                  '${_selectedViewer.publicId ?? 'sem publicId'} | ${_selectedViewer.label}',
            ),
            const SizedBox(height: 10),
            Text(
              _selectedViewer.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _mutedColor,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _accountTab(BuildContext context) {
    return ListView(
      children: [
        _settingsSection(
          context,
          title: 'Dados cadastrais',
          icon: Icons.badge_outlined,
          children: [
            _settingsInfoTile(
              icon: Icons.person_outline_rounded,
              title: 'Nome',
              subtitle: _selectedViewer.name,
            ),
            _settingsInfoTile(
              icon: Icons.fingerprint_rounded,
              title: 'ID de usuario',
              subtitle: _selectedViewer.publicId ?? 'perfil publico sem ID',
            ),
            _settingsInfoTile(
              icon: Icons.group_outlined,
              title: 'Grupos',
              subtitle: _viewerRoleLabel(_selectedViewer),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _settingsSection(
          context,
          title: 'Organizacao',
          icon: Icons.business_center_outlined,
          children: [
            _settingsInfoTile(
              icon: Icons.apartment_rounded,
              title: 'Empresa vinculada',
              subtitle:
                  _selectedViewer.organizationLabel ?? 'Nao informado pela API',
            ),
            _settingsInfoTile(
              icon: Icons.verified_user_outlined,
              title: 'Nivel operacional',
              subtitle: _selectedViewer.canViewSensitive
                  ? 'Interno autenticado'
                  : 'Entrada publica',
            ),
          ],
        ),
        const SizedBox(height: 14),
        _settingsSection(
          context,
          title: 'Endereco do usuario',
          icon: Icons.location_on_outlined,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final fieldWidth = constraints.maxWidth < 620
                    ? constraints.maxWidth
                    : (constraints.maxWidth - 12) / 2;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _settingsTextField(
                      width: fieldWidth,
                      controller: _profileZipCode,
                      label: 'CEP',
                      icon: Icons.markunread_mailbox_outlined,
                    ),
                    _settingsTextField(
                      width: fieldWidth,
                      controller: _profileStreet,
                      label: 'Logradouro',
                      icon: Icons.signpost_outlined,
                    ),
                    _settingsTextField(
                      width: fieldWidth,
                      controller: _profileNumber,
                      label: 'Numero',
                      icon: Icons.tag_outlined,
                    ),
                    _settingsTextField(
                      width: fieldWidth,
                      controller: _profileDistrict,
                      label: 'Bairro',
                      icon: Icons.map_outlined,
                    ),
                    _settingsTextField(
                      width: fieldWidth,
                      controller: _profileCity,
                      label: 'Cidade',
                      icon: Icons.location_city_outlined,
                    ),
                    _settingsTextField(
                      width: fieldWidth,
                      controller: _profileState,
                      label: 'Estado',
                      icon: Icons.flag_outlined,
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _securityTab(BuildContext context) {
    return ListView(
      children: [
        _settingsSection(
          context,
          title: 'Seguranca',
          icon: Icons.shield_outlined,
          children: [
            _settingsInfoTile(
              icon: Icons.lock_outline_rounded,
              title: 'Contexto de acesso',
              subtitle: _selectedViewer.canViewSensitive
                  ? 'Privilegiado conforme sessao interna'
                  : 'Publico, sem leitura protegida',
            ),
            _settingsInfoTile(
              icon: Icons.visibility_outlined,
              title: 'Dados sensiveis',
              subtitle: _selectedViewer.canViewSensitive
                  ? 'Pode visualizar payloads autorizados pela ACL'
                  : 'Bloqueado',
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: true,
              onChanged: null,
              title: const Text('Auditoria ativa'),
              subtitle: const Text(
                'Criacao, cancelamento e acessos sensiveis ficam rastreaveis.',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _personalizationTab(BuildContext context) {
    return ListView(
      children: [
        _settingsSection(
          context,
          title: 'Personalizacao',
          icon: Icons.tune_outlined,
          children: [
            _settingsDropdown(
              label: 'Lingua',
              value: _language,
              values: const ['Portugues (Brasil)', 'English', 'Espanol'],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _language = value);
                }
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _use24h,
              onChanged: (value) => setState(() => _use24h = value),
              title: const Text('Usar horario em 24 horas'),
              subtitle: Text(_use24h ? '14:30' : '2:30 PM'),
            ),
            _settingsDropdown(
              label: 'Fuso horario',
              value: _timeZone,
              values: const [
                'America/Sao_Paulo',
                'America/Manaus',
                'America/Fortaleza',
                'UTC',
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _timeZone = value);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 14),
        _settingsSection(
          context,
          title: 'Notificacoes',
          icon: Icons.notifications_active_outlined,
          children: [
            _settingsSwitch(
              title: 'No app',
              subtitle: 'Sempre recomendado para compromissos e lembretes.',
              value: _notifyInApp,
              onChanged: (value) => setState(() => _notifyInApp = value),
            ),
            _settingsSwitch(
              title: 'Email',
              subtitle: 'Ativo por padrao em novos lembretes.',
              value: _notifyEmail,
              onChanged: (value) => setState(() => _notifyEmail = value),
            ),
            _settingsSwitch(
              title: 'Push',
              subtitle: 'Usado quando houver dispositivo vinculado.',
              value: _notifyPush,
              onChanged: (value) => setState(() => _notifyPush = value),
            ),
            _settingsSwitch(
              title: 'WhatsApp',
              subtitle: 'Depende de contato vinculado e autorizado.',
              value: _notifyWhatsapp,
              onChanged: (value) => setState(() => _notifyWhatsapp = value),
            ),
          ],
        ),
      ],
    );
  }

  Widget _contactsTab(BuildContext context) {
    return ListView(
      children: [
        _settingsSection(
          context,
          title: 'Canais vinculados',
          icon: Icons.contact_phone_outlined,
          children: [
            _settingsSwitch(
              title: 'Vincular WhatsApp',
              subtitle: 'Canal separado para mensagens e confirmacoes.',
              value: _linkWhatsapp,
              onChanged: (value) => setState(() => _linkWhatsapp = value),
            ),
            _settingsSwitch(
              title: 'Vincular E-mail',
              subtitle: 'Canal principal de notificacao escrita.',
              value: _linkEmail,
              onChanged: null,
            ),
            _settingsSwitch(
              title: 'Vincular SMS',
              subtitle: 'Canal curto para alertas criticos.',
              value: _linkSms,
              onChanged: (value) => setState(() => _linkSms = value),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _settingsSection(
          context,
          title: 'Destinatarios',
          icon: Icons.forward_to_inbox_outlined,
          children: [
            _notificationContactCard(
              title: 'Contato principal',
              channel: 'Email',
              value: _selectedViewer.isAuthenticated
                  ? 'Canal cadastrado na API'
                  : 'sem contato autenticado',
              relationship: 'Proprio usuario',
              active: true,
              locked: true,
              message:
                  'Canal pessoal sempre ativo para compromissos e lembretes.',
              onChanged: null,
            ),
            _notificationContactCard(
              title: 'Contato secundario',
              channel: 'Email',
              value: 'Nao configurado pela API',
              relationship: 'Gestao direta',
              active: _secondaryEmailActive,
              message: _defaultNotificationDelegationMessage('Gestao direta'),
              onChanged: (value) =>
                  setState(() => _secondaryEmailActive = value),
            ),
            _notificationContactCard(
              title: 'Contato secundario',
              channel: 'WhatsApp',
              value: 'Nao configurado pela API',
              relationship: 'Contato operacional',
              active: _secondaryWhatsappActive,
              message: _defaultNotificationDelegationMessage(
                'Contato operacional',
              ),
              onChanged: (value) =>
                  setState(() => _secondaryWhatsappActive = value),
            ),
            _notificationContactCard(
              title: 'Contato secundario',
              channel: 'SMS',
              value: '+55 11 98888-0000',
              relationship: 'Escalacao de urgencia',
              active: _secondarySmsActive,
              message: _defaultNotificationDelegationMessage(
                'Escalacao de urgencia',
              ),
              onChanged: (value) => setState(() => _secondarySmsActive = value),
            ),
          ],
        ),
      ],
    );
  }

  Widget _calendarTab(BuildContext context) {
    final firstDay = DateTime(_calendarMonth.year, _calendarMonth.month);
    final daysInMonth = DateTime(
      _calendarMonth.year,
      _calendarMonth.month + 1,
      0,
    ).day;
    final leadingEmptyCells = firstDay.weekday % 7;
    final today = DateTime.now();
    final activeFilters = _calendarFilters.entries
        .where((entry) => entry.value.trim().isNotEmpty)
        .toList();

    return ListView(
      children: [
        _settingsSection(
          context,
          title: 'Calendario',
          icon: Icons.calendar_month_outlined,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Mes anterior',
                  onPressed: () {
                    setState(() {
                      _calendarMonth = DateTime(
                        _calendarMonth.year,
                        _calendarMonth.month - 1,
                      );
                    });
                    unawaited(_loadSharedCalendar());
                  },
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: Text(
                    _calendarMonthLabel(_calendarMonth),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _inkColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Proximo mes',
                  onPressed: () {
                    setState(() {
                      _calendarMonth = DateTime(
                        _calendarMonth.year,
                        _calendarMonth.month + 1,
                      );
                    });
                    unawaited(_loadSharedCalendar());
                  },
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
                IconButton(
                  tooltip: 'Hoje',
                  onPressed: () {
                    final now = DateTime.now();
                    setState(() {
                      _calendarMonth = DateTime(now.year, now.month);
                    });
                    unawaited(_loadSharedCalendar());
                  },
                  icon: const Icon(Icons.today_outlined),
                ),
                IconButton(
                  tooltip: 'Novo evento',
                  onPressed: () => unawaited(
                    _openCalendarEntryDialog(initialDate: DateTime.now()),
                  ),
                  icon: const Icon(Icons.add_circle_outline_rounded),
                ),
                IconButton(
                  tooltip: 'Filtros',
                  onPressed: _openCalendarFilters,
                  icon: const Icon(Icons.filter_alt_outlined),
                ),
                IconButton(
                  tooltip: 'Novo dia nao util',
                  onPressed: _openNonBusinessDayDialog,
                  icon: const Icon(Icons.event_busy_outlined),
                ),
                IconButton(
                  tooltip: 'Atualizar calendario',
                  onPressed: _loadingCalendar
                      ? null
                      : () => unawaited(_loadSharedCalendar()),
                  icon: _loadingCalendar
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _settingsDropdown(
              label: 'Mostrar compromissos vencidos recentes',
              value: _calendarOverdueWindow,
              values: _calendarOverdueWindowOptions,
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() => _calendarOverdueWindow = value);
                unawaited(_saveCalendarPreferences());
                unawaited(_loadSharedCalendar());
              },
            ),
            Text(
              'Inclui compromissos vencidos nesse intervalo quando ainda nao estiverem concluidos.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _mutedColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (activeFilters.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final filter in activeFilters)
                    InputChip(
                      label: Text('${filter.key}: ${filter.value}'),
                      onDeleted: () {
                        setState(() {
                          _calendarFilters = {..._calendarFilters}
                            ..remove(filter.key);
                        });
                        unawaited(_saveCalendarPreferences());
                        unawaited(_loadSharedCalendar());
                      },
                    ),
                ],
              ),
            ],
            if (_calendarError != null) ...[
              const SizedBox(height: 10),
              _HubEmptyLine(
                icon: Icons.warning_amber_rounded,
                text: _calendarError!,
              ),
            ],
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.45,
              children: [
                for (final day in const [
                  'Dom',
                  'Seg',
                  'Ter',
                  'Qua',
                  'Qui',
                  'Sex',
                  'Sab',
                ])
                  _calendarWeekdayCell(context, day),
                for (var index = 0; index < leadingEmptyCells; index += 1)
                  const SizedBox.shrink(),
                for (var day = 1; day <= daysInMonth; day += 1)
                  _calendarDayCell(
                    context,
                    day: day,
                    selected:
                        today.year == _calendarMonth.year &&
                        today.month == _calendarMonth.month &&
                        today.day == day,
                    entries: _calendarEntriesForDay(day),
                    nonBusinessDays: _calendarNonBusinessDaysForDay(day),
                    onTap: () => unawaited(_openCalendarDay(day)),
                    onAdd: () => unawaited(
                      _openCalendarEntryDialog(
                        initialDate: DateTime(
                          _calendarMonth.year,
                          _calendarMonth.month,
                          day,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (_loadingCalendar && _calendarEntries.isEmpty)
              const LinearProgressIndicator(minHeight: 2)
            else ...[
              _calendarSummaryBand(context),
              const SizedBox(height: 12),
              if (_calendarNonBusinessDays.isNotEmpty) ...[
                Text(
                  'Dias nao uteis',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: _inkColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                for (final day in _calendarNonBusinessDays.take(4)) ...[
                  _nonBusinessDayCard(context, day),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 4),
              ],
              Text(
                'Itens do mes',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: _inkColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              if (_calendarEntries.isEmpty)
                const _HubEmptyLine(
                  icon: Icons.event_available_outlined,
                  text: 'Nenhum item encontrado para o periodo e filtros.',
                )
              else
                for (final entry in _calendarEntries.take(8)) ...[
                  _calendarEntryCard(context, entry),
                  const SizedBox(height: 8),
                ],
            ],
          ],
        ),
      ],
    );
  }

  Future<void> _loadCalendarPreferencesAndCalendar() async {
    try {
      final data = await _calendarApi.getMap('auth/preferences/calendar');
      final preferences = _apiMap(data['preferences']);
      final overdueWindow = _apiText(preferences['overdueWindow']);
      if (_calendarOverdueWindowOptions.contains(overdueWindow)) {
        _calendarOverdueWindow = overdueWindow;
      }
      _calendarFilters = _calendarPreferenceStringMap(preferences['filters']);
    } on ApiException {
      final preferences = await SharedPreferences.getInstance();
      final stored = preferences.getString(_calendarOverdueWindowStorageKey);
      if (stored != null && _calendarOverdueWindowOptions.contains(stored)) {
        _calendarOverdueWindow = stored;
      }
    }
    if (mounted) {
      setState(() {});
      await _loadSharedCalendar();
    }
  }

  Future<void> _saveCalendarPreferences() async {
    try {
      await _calendarApi.patchMap(
        'auth/preferences/calendar',
        body: {
          'defaultView': 'MONTH',
          'overdueWindow': _calendarOverdueWindow,
          'filters': _calendarFilters,
        },
      );
    } on ApiException {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(
        _calendarOverdueWindowStorageKey,
        _calendarOverdueWindow,
      );
    }
  }

  Map<String, String> _calendarPreferenceStringMap(Object? value) {
    final raw = _apiMap(value);
    return {
      for (final entry in raw.entries)
        if (_apiText(entry.value).isNotEmpty) entry.key: _apiText(entry.value),
    };
  }

  Duration? get _calendarOverdueDuration => switch (_calendarOverdueWindow) {
    '12 horas' => const Duration(hours: 12),
    '24 horas' => const Duration(days: 1),
    '3 dias' => const Duration(days: 3),
    '7 dias' => const Duration(days: 7),
    '15 dias' => const Duration(days: 15),
    '30 dias' => const Duration(days: 30),
    _ => null,
  };

  Future<void> _loadSharedCalendar() async {
    if (_loadingCalendar) {
      return;
    }

    final firstDay = DateTime(_calendarMonth.year, _calendarMonth.month);
    final lastDay = DateTime(_calendarMonth.year, _calendarMonth.month + 1, 0);
    final now = DateTime.now();
    final overdueDuration = _calendarOverdueDuration;
    final overdueStart = overdueDuration == null
        ? firstDay
        : now.subtract(overdueDuration);
    final queryStart = overdueStart.isBefore(firstDay)
        ? overdueStart
        : firstDay;
    final query = <String, String?>{
      'startsAtFrom': _dateQuery(queryStart),
      'startsAtTo': _dateQuery(lastDay),
      ..._calendarFilters,
    };
    final regionCode =
        _calendarFilters['holidayRegionCode'] ??
        _calendarFilters['appliesToRegionCode'];
    final stateCode = _calendarFilters['appliesToStateCode'];

    setState(() {
      _loadingCalendar = true;
      _calendarError = null;
    });

    try {
      final results = await Future.wait([
        _calendarApi.getMap('agenda', query: query),
        _calendarApi.getMap(
          'agenda/non-business-days',
          query: {
            'from': _dateQuery(firstDay),
            'to': _dateQuery(lastDay),
            if (regionCode != null && regionCode.isNotEmpty)
              'regionCode': regionCode,
            if (stateCode != null && stateCode.isNotEmpty)
              'stateCode': stateCode,
          },
        ),
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        _calendarEntries = _filterCalendarEntriesByOverdueWindow(
          _apiMapList(results[0]['items']),
          firstDay: firstDay,
          lastDay: lastDay,
          now: now,
          overdueDuration: overdueDuration,
        );
        _calendarNonBusinessDays = _apiMapList(results[1]['items']);
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _calendarError = error.message;
      });
    } finally {
      if (mounted) {
        setState(() => _loadingCalendar = false);
      }
    }
  }

  List<Map<String, dynamic>> _filterCalendarEntriesByOverdueWindow(
    List<Map<String, dynamic>> entries, {
    required DateTime firstDay,
    required DateTime lastDay,
    required DateTime now,
    required Duration? overdueDuration,
  }) {
    return [
      for (final entry in entries)
        if (_calendarEntryBelongsInCurrentView(
          entry,
          firstDay: firstDay,
          lastDay: lastDay,
          now: now,
          overdueDuration: overdueDuration,
        ))
          entry,
    ];
  }

  bool _calendarEntryBelongsInCurrentView(
    Map<String, dynamic> entry, {
    required DateTime firstDay,
    required DateTime lastDay,
    required DateTime now,
    required Duration? overdueDuration,
  }) {
    final startsAt = _calendarOccurrenceDate(entry);
    if (startsAt == null) {
      return true;
    }
    final monthEnd = DateTime(
      lastDay.year,
      lastDay.month,
      lastDay.day,
      23,
      59,
      59,
    );
    final inDisplayedMonth =
        !startsAt.isBefore(firstDay) && !startsAt.isAfter(monthEnd);
    if (inDisplayedMonth) {
      return true;
    }
    if (overdueDuration == null ||
        !_calendarEntryIsOpen(entry) ||
        !startsAt.isBefore(now)) {
      return false;
    }
    return now.difference(startsAt) <= overdueDuration;
  }

  bool _calendarEntryIsOpen(Map<String, dynamic> entry) {
    final status = _apiText(entry['status']).toUpperCase();
    return status != 'CANCELED' && status != 'COMPLETED';
  }

  Future<void> _openCalendarFilters() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) =>
          _SharedCalendarFiltersDialog(initialFilters: _calendarFilters),
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _calendarFilters = result;
    });
    unawaited(_saveCalendarPreferences());
    unawaited(_loadSharedCalendar());
  }

  Future<void> _openNonBusinessDayDialog() async {
    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _SharedCalendarNonBusinessDayDialog(),
    );

    if (body == null || !mounted) {
      return;
    }

    setState(() => _loadingCalendar = true);
    try {
      await _calendarApi.postMap('agenda/non-business-days', body: body);
      if (mounted) {
        setState(() => _loadingCalendar = false);
      }
      await _loadSharedCalendar();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dia nao util adicionado ao calendario.')),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: _roseColor),
      );
    } finally {
      if (mounted) {
        setState(() => _loadingCalendar = false);
      }
    }
  }

  Future<void> _openCalendarDay(int day) async {
    final date = DateTime(_calendarMonth.year, _calendarMonth.month, day);
    await showDialog<void>(
      context: context,
      builder: (context) => _CalendarDayDetailsDialog(
        date: date,
        entries: _calendarEntriesForDay(day),
        nonBusinessDays: _calendarNonBusinessDaysForDay(day),
        onAddEvent: () =>
            unawaited(_openCalendarEntryDialog(initialDate: date)),
        onEditEntry: (entry) => unawaited(
          _openCalendarEntryDialog(initialDate: date, entry: entry),
        ),
        onCancelEntry: (entry) => unawaited(_confirmCancelCalendarEntry(entry)),
        onApplicability: (scope) =>
            unawaited(_openCalendarApplicability(scope)),
        scopeFromEntry: _calendarScopeFromEntry,
        scopeFromNonBusinessDay: _calendarScopeFromNonBusinessDay,
      ),
    );
  }

  Future<void> _openCalendarEntryDialog({
    required DateTime initialDate,
    Map<String, dynamic>? entry,
  }) async {
    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) =>
          _SharedCalendarEntryDialog(initialDate: initialDate, entry: entry),
    );

    if (body == null || !mounted) {
      return;
    }

    setState(() => _loadingCalendar = true);
    try {
      final publicId = _apiText(entry?['publicId']);
      if (publicId.isEmpty) {
        await _calendarApi.postMap('agenda', body: body);
      } else {
        await _calendarApi.patchMap('agenda/$publicId', body: body);
      }
      if (mounted) {
        setState(() => _loadingCalendar = false);
      }
      await _loadSharedCalendar();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            publicId.isEmpty
                ? 'Evento adicionado ao calendario.'
                : 'Evento atualizado no calendario.',
          ),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: _roseColor),
      );
    } finally {
      if (mounted) {
        setState(() => _loadingCalendar = false);
      }
    }
  }

  Future<void> _confirmCancelCalendarEntry(Map<String, dynamic> entry) async {
    final publicId = _apiText(entry['publicId']);
    if (publicId.isEmpty) {
      return;
    }
    final title = _apiText(entry['title'], fallback: 'sem titulo');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar evento'),
        content: Text(
          'O item "$title" sera marcado como cancelado, preservando historico e auditoria.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancelar item'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _loadingCalendar = true);
    try {
      await _calendarApi.deleteMap('agenda/$publicId');
      if (mounted) {
        setState(() => _loadingCalendar = false);
      }
      await _loadSharedCalendar();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento cancelado no calendario.')),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: _roseColor),
      );
    } finally {
      if (mounted) {
        setState(() => _loadingCalendar = false);
      }
    }
  }

  Widget _calendarSummaryBand(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _lineColor),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _Tag(
            label: '${_calendarEntries.length} itens',
            icon: Icons.event_note_outlined,
            color: _deepTealColor,
            background: _deepTealColor.withValues(alpha: 0.09),
          ),
          _Tag(
            label: '${_calendarNonBusinessDays.length} dias nao uteis',
            icon: Icons.event_busy_outlined,
            color: _amberColor,
            background: _amberColor.withValues(alpha: 0.12),
          ),
          _Tag(
            label: _calendarFilters.isEmpty
                ? 'sem filtros manuais'
                : '${_calendarFilters.length} filtros',
            icon: Icons.filter_alt_outlined,
            color: _mutedColor,
            background: _lineColor.withValues(alpha: 0.55),
          ),
        ],
      ),
    );
  }

  Widget _nonBusinessDayCard(BuildContext context, Map<String, dynamic> item) {
    final scope = _calendarScopeFromNonBusinessDay(item);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: _amberColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _amberColor.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_busy_outlined, color: _amberColor, size: 19),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _apiText(item['name'], fallback: 'Dia nao util'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _inkColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    _apiText(item['dateLabel']),
                    _apiText(item['regionCode']),
                    if (item['isRecurringYearly'] == true) 'recorrente anual',
                  ].where((value) => value.isNotEmpty).join(' | '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _mutedColor, fontSize: 12),
                ),
              ],
            ),
          ),
          if (scope.isNotEmpty)
            IconButton(
              tooltip: 'Ver aplicabilidade',
              onPressed: () => _openCalendarApplicability(scope),
              icon: const Icon(Icons.groups_2_outlined),
            ),
        ],
      ),
    );
  }

  Widget _calendarEntryCard(BuildContext context, Map<String, dynamic> entry) {
    final target = _apiMap(entry['target']);
    final notification = _apiMap(entry['notification']);
    final scope = _calendarScopeFromEntry(entry);
    final kind = _apiText(entry['kind']);
    final isNotice = kind == 'NOTICE';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _lineColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: (isNotice ? _amberColor : _tealColor).withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isNotice
                  ? Icons.campaign_outlined
                  : Icons.notifications_active_outlined,
              color: isNotice ? _amberColor : _tealColor,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _apiText(entry['title'], fallback: 'Item de calendario'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _inkColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  [
                    _calendarEntryDateLabel(entry),
                    _apiText(target['label']),
                    _apiText(entry['category']),
                  ].where((value) => value.isNotEmpty).join(' | '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _mutedColor,
                    fontSize: 12,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _Tag(
                      label: _apiText(entry['kindLabel'], fallback: kind),
                      icon: Icons.event_note_outlined,
                      color: _deepTealColor,
                      background: _deepTealColor.withValues(alpha: 0.09),
                    ),
                    _Tag(
                      label: _apiText(
                        notification['policyLabel'],
                        fallback: 'sem notificacao',
                      ),
                      icon: Icons.schedule_outlined,
                      color: _mutedColor,
                      background: _lineColor.withValues(alpha: 0.55),
                    ),
                    if (_apiText(entry['recurrenceRule']).isNotEmpty)
                      _Tag(
                        label: _calendarRecurrenceLabel(entry),
                        icon: Icons.event_repeat_outlined,
                        color: _amberColor,
                        background: _amberColor.withValues(alpha: 0.10),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (scope.isNotEmpty)
            IconButton(
              tooltip: 'Ver aplicabilidade',
              onPressed: () => _openCalendarApplicability(scope),
              icon: const Icon(Icons.groups_2_outlined),
            ),
        ],
      ),
    );
  }

  Future<void> _openCalendarApplicability(Map<String, String> scope) async {
    try {
      final data = await _calendarApi.getMap(
        'agenda/applicability',
        query: scope,
      );
      if (!mounted) {
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (context) => _CalendarApplicabilityDialog(data: data),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: _roseColor),
      );
    }
  }

  Map<String, String> _calendarScopeFromEntry(Map<String, dynamic> entry) {
    final applicability = _apiMap(entry['applicability']);
    final scope = <String, String>{};
    _putCalendarScope(scope, 'regionCode', applicability['regionCode']);
    _putCalendarScope(scope, 'stateCode', applicability['stateCode']);
    _putCalendarScope(scope, 'cityName', applicability['cityName']);
    if (scope.isEmpty) {
      _putCalendarScope(scope, 'regionCode', entry['holidayRegionCode']);
    }
    return scope;
  }

  Map<String, String> _calendarScopeFromNonBusinessDay(
    Map<String, dynamic> item,
  ) {
    final applicability = _apiMap(item['applicability']);
    final scope = <String, String>{};
    _putCalendarScope(
      scope,
      'regionCode',
      applicability['regionCode'] ?? item['regionCode'],
    );
    _putCalendarScope(
      scope,
      'stateCode',
      applicability['stateCode'] ?? item['stateCode'],
    );
    _putCalendarScope(
      scope,
      'cityName',
      applicability['cityName'] ?? item['cityName'],
    );
    return scope;
  }

  void _putCalendarScope(Map<String, String> scope, String key, Object? value) {
    final text = _apiText(value).trim();
    if (text.isNotEmpty) {
      scope[key] = text;
    }
  }

  List<Map<String, dynamic>> _calendarEntriesForDay(int day) {
    return _calendarEntries.where((entry) {
      final date = _calendarOccurrenceDate(entry);
      return date != null &&
          date.year == _calendarMonth.year &&
          date.month == _calendarMonth.month &&
          date.day == day;
    }).toList();
  }

  DateTime? _calendarOccurrenceDate(Map<String, dynamic> entry) {
    return _parseApiDate(
          _apiText(
            entry['occurrenceStartsAt'],
            fallback: _apiText(entry['startsAt']),
          ),
        ) ??
        _parseApiDate(_apiText(entry['startsAt']));
  }

  String _calendarEntryDateLabel(Map<String, dynamic> entry) {
    return _apiText(
      entry['occurrenceStartsAtLabel'],
      fallback: _apiText(entry['startsAtLabel']),
    );
  }

  String _calendarRecurrenceLabel(Map<String, dynamic> entry) {
    return _apiText(
      entry['recurrenceRuleLabel'],
      fallback: _recurrenceRuleLabel(_apiText(entry['recurrenceRule'])),
    );
  }

  List<Map<String, dynamic>> _calendarNonBusinessDaysForDay(int day) {
    return _calendarNonBusinessDays.where((entry) {
      final date = _parseApiDate(_apiText(entry['date']));
      if (date == null) {
        return false;
      }
      final recurring = entry['isRecurringYearly'] == true;
      return recurring
          ? date.month == _calendarMonth.month && date.day == day
          : date.year == _calendarMonth.year &&
                date.month == _calendarMonth.month &&
                date.day == day;
    }).toList();
  }

  DateTime? _parseApiDate(String value) {
    if (value.isEmpty) {
      return null;
    }
    final parsed = DateTime.tryParse(value);
    return parsed?.isUtc == true ? parsed!.toLocal() : parsed;
  }

  String _dateQuery(DateTime value) {
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  }

  Widget _onboardingTab(BuildContext context) {
    return ListView(
      children: [
        _settingsSection(
          context,
          title: 'Solicitacoes de cliente',
          icon: Icons.domain_add_outlined,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Analise interna de cadastros enviados pelo menu de login.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _mutedColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Atualizar solicitacoes',
                  onPressed: _loadingOnboarding
                      ? null
                      : () => unawaited(_loadOnboardingRequests()),
                  icon: _loadingOnboarding
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_onboardingError != null)
              _HubEmptyLine(
                icon: Icons.warning_amber_rounded,
                text: _onboardingError!,
              )
            else if (_loadingOnboarding && _onboardingRequests.isEmpty)
              const LinearProgressIndicator(minHeight: 2)
            else if (_onboardingRequests.isEmpty)
              const _HubEmptyLine(
                icon: Icons.inbox_outlined,
                text: 'Nenhuma solicitacao de onboarding encontrada.',
              )
            else
              for (final request in _onboardingRequests) ...[
                _onboardingRequestCard(context, request),
                const SizedBox(height: 10),
              ],
          ],
        ),
      ],
    );
  }

  Widget _onboardingRequestCard(
    BuildContext context,
    Map<String, dynamic> request,
  ) {
    final publicId = _apiText(request['publicId']);
    final status = _apiText(request['status']);
    final contact = _apiMap(request['primaryContact']);
    final rootCompany = _apiMap(request['tenantRootCompany']);
    final released = status == 'RELEASED';
    final rejected = status == 'REJECTED';
    final canReview = !released && !rejected;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _lineColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _apiText(request['tradeName'], fallback: 'Empresa sem nome'),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: _inkColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _Tag(
                label: _apiText(request['statusLabel'], fallback: status),
                icon: released
                    ? Icons.verified_rounded
                    : rejected
                    ? Icons.block_rounded
                    : Icons.pending_actions_rounded,
                color: released
                    ? _tealColor
                    : rejected
                    ? _roseColor
                    : _amberColor,
                background:
                    (released
                            ? _tealColor
                            : rejected
                            ? _roseColor
                            : _amberColor)
                        .withValues(alpha: 0.10),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${_apiText(request['legalName'])} | CNPJ ${_apiText(request['cnpj'])}',
            style: const TextStyle(color: _mutedColor, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            '${_apiText(contact['name'], fallback: 'Contato nao informado')} | ${_apiText(contact['email'], fallback: _apiText(contact['phone'], fallback: 'sem canal'))}',
            style: const TextStyle(color: _mutedColor, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Tag(
                label: _apiText(request['contractTypeLabel']),
                icon: Icons.assignment_outlined,
                color: _deepTealColor,
                background: _deepTealColor.withValues(alpha: 0.09),
              ),
              _Tag(
                label: _apiText(
                  rootCompany['publicId'],
                  fallback: 'empresa raiz ainda nao liberada',
                ),
                icon: Icons.apartment_rounded,
                color: _mutedColor,
                background: _lineColor.withValues(alpha: 0.55),
              ),
            ],
          ),
          if (canReview) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _loadingOnboarding
                      ? null
                      : () =>
                            _reviewOnboardingRequest(publicId, approve: false),
                  icon: const Icon(Icons.block_rounded, size: 18),
                  label: const Text('Negar'),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _loadingOnboarding
                      ? null
                      : () => _reviewOnboardingRequest(publicId, approve: true),
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Aprovar'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _loadOnboardingRequests() async {
    if (_loadingOnboarding) {
      return;
    }

    setState(() {
      _loadingOnboarding = true;
      _onboardingError = null;
    });

    try {
      final data = await _onboardingApi.getMap('client-onboarding/requests');
      if (!mounted) {
        return;
      }
      setState(() {
        _onboardingRequests = _apiMapList(data['items']);
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _onboardingError = error.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingOnboarding = false;
        });
      }
    }
  }

  Future<void> _reviewOnboardingRequest(
    String publicId, {
    required bool approve,
  }) async {
    if (publicId.isEmpty) {
      return;
    }

    setState(() => _loadingOnboarding = true);
    try {
      await _onboardingApi.postMap(
        'client-onboarding/requests/$publicId/${approve ? 'approve' : 'reject'}',
        body: {
          'note': approve
              ? 'Aprovado pela tela interna do CRM.'
              : 'Negado pela tela interna do CRM.',
        },
      );
      if (mounted) {
        setState(() => _loadingOnboarding = false);
      }
      await _loadOnboardingRequests();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            approve ? 'Solicitacao aprovada.' : 'Solicitacao negada.',
          ),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: _roseColor),
      );
    } finally {
      if (mounted) {
        setState(() => _loadingOnboarding = false);
      }
    }
  }

  Widget _whatsappAgenticWorkflowTab(BuildContext context) {
    return ListView(
      children: [
        _settingsSection(
          context,
          title: 'Whatsapp Agentic AI Workflow',
          icon: Icons.smart_toy_outlined,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _lineColor.withValues(alpha: 0.70),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.construction_rounded,
                    color: _mutedColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ainda nao implementado',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: _inkColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'A aba fica reservada para configuracao futura de automacoes agenticas via WhatsApp.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _mutedColor,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _settingsSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _lineColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _deepTealColor, size: 19),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _inkColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _settingsInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: _mutedColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _inkColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _mutedColor, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsDropdown({
    required String label,
    required String value,
    required List<String> values,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        items: [
          for (final item in values)
            DropdownMenuItem(value: item, child: Text(item)),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _calendarWeekdayCell(BuildContext context, String label) {
    return Center(
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: _mutedColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _calendarDayCell(
    BuildContext context, {
    required int day,
    required bool selected,
    required List<Map<String, dynamic>> entries,
    required List<Map<String, dynamic>> nonBusinessDays,
    required VoidCallback onTap,
    required VoidCallback onAdd,
  }) {
    return _SharedCalendarDayCell(
      day: day,
      month: _calendarMonth,
      selected: selected,
      entries: entries,
      nonBusinessDays: nonBusinessDays,
      onTap: onTap,
      onAdd: onAdd,
    );
  }

  Widget _settingsTextField({
    required double width,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        textCapitalization: textCapitalization,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18),
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _settingsSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }

  Widget _notificationContactCard({
    required String title,
    required String channel,
    required String value,
    required String relationship,
    required bool active,
    required String message,
    required ValueChanged<bool>? onChanged,
    bool locked = false,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: active
            ? _tealColor.withValues(alpha: 0.07)
            : const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active ? _tealColor.withValues(alpha: 0.20) : _lineColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$title | $channel',
                  style: const TextStyle(
                    color: _inkColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Switch(value: active, onChanged: locked ? null : onChanged),
            ],
          ),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(color: _mutedColor, fontSize: 12)),
          const SizedBox(height: 6),
          _Tag(
            label: relationship,
            icon: Icons.link_rounded,
            color: _tealColor,
            background: _tealColor.withValues(alpha: 0.10),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: _mutedColor,
              fontSize: 12,
              height: 1.28,
            ),
          ),
        ],
      ),
    );
  }

  String _defaultNotificationDelegationMessage(String relationship) {
    final userId = _selectedViewer.publicId ?? 'sem-id';
    return 'Esta mensagem foi enviada pelo usuario ${_selectedViewer.name}, ID $userId, pelo PariFlow Partners, e esta configurada para ser enviada automaticamente para esse tipo de compromisso/lembrete. Relacionamento: $relationship.';
  }

  String _calendarMonthLabel(DateTime month) {
    const labels = [
      'Janeiro',
      'Fevereiro',
      'Marco',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return '${labels[month.month - 1]} ${month.year}';
  }
}

class _SharedCalendarDayCell extends StatefulWidget {
  const _SharedCalendarDayCell({
    required this.day,
    required this.month,
    required this.selected,
    required this.entries,
    required this.nonBusinessDays,
    required this.onTap,
    required this.onAdd,
  });

  final int day;
  final DateTime month;
  final bool selected;
  final List<Map<String, dynamic>> entries;
  final List<Map<String, dynamic>> nonBusinessDays;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  State<_SharedCalendarDayCell> createState() => _SharedCalendarDayCellState();
}

class _SharedCalendarDayCellState extends State<_SharedCalendarDayCell> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final hasNonBusinessDay = widget.nonBusinessDays.isNotEmpty;
    final background = hasNonBusinessDay
        ? _amberColor.withValues(alpha: 0.10)
        : widget.selected
        ? _tealColor.withValues(alpha: 0.12)
        : const Color(0xFFF8FAFB);
    final borderColor = hasNonBusinessDay
        ? _amberColor.withValues(alpha: 0.34)
        : widget.selected
        ? _tealColor.withValues(alpha: 0.32)
        : _lineColor;
    final hoverItems = _hoverItems;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: widget.onTap,
                child: Ink(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${widget.day}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: hasNonBusinessDay || widget.selected
                              ? _deepTealColor
                              : _inkColor,
                          fontWeight: widget.selected
                              ? FontWeight.w900
                              : FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.entries.isNotEmpty)
                            Container(
                              constraints: const BoxConstraints(minWidth: 18),
                              height: 17,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                              decoration: BoxDecoration(
                                color: _deepTealColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${widget.entries.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          if (hasNonBusinessDay) ...[
                            if (widget.entries.isNotEmpty)
                              const SizedBox(width: 4),
                            Icon(
                              Icons.block_rounded,
                              color: _amberColor,
                              size: 15,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_hovered)
              Positioned.fill(
                child: _CalendarHoverHandler(
                  date: DateTime(
                    widget.month.year,
                    widget.month.month,
                    widget.day,
                  ),
                  items: hoverItems,
                  onOpen: widget.onTap,
                  onAdd: widget.onAdd,
                  addLabel: 'Adicionar compromisso',
                  emptyLabel: 'Sem compromissos marcados.',
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<_CalendarHoverItem> get _hoverItems {
    return [
      for (final entry in widget.entries)
        _CalendarHoverItem(
          icon: Icons.event_note_outlined,
          title: _apiText(entry['title'], fallback: 'Item de calendario'),
          detail: _joinCalendarHoverDetails([
            _calendarEntryDisplayDateLabel(entry),
            _apiText(entry['kindLabel'], fallback: _apiText(entry['kind'])),
            _apiText(entry['statusLabel'], fallback: _apiText(entry['status'])),
            _apiText(entry['description']),
          ]),
          color: _calendarHoverGoldColor,
        ),
      for (final item in widget.nonBusinessDays)
        _CalendarHoverItem(
          icon: Icons.event_busy_outlined,
          title: _apiText(item['name'], fallback: 'Dia nao util'),
          detail: _joinCalendarHoverDetails([
            _apiText(item['dateLabel'], fallback: _apiText(item['date'])),
            _apiText(item['regionCode']),
            _apiText(item['stateCode']),
            _apiText(item['cityName']),
            if (item['isRecurringYearly'] == true) 'recorrente anual',
          ]),
          color: _calendarHoverSlateColor,
        ),
    ];
  }
}

class _CalendarApplicabilityDialog extends StatelessWidget {
  const _CalendarApplicabilityDialog({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final width = min(MediaQuery.sizeOf(context).width * 0.92, 780.0);
    final scope = _apiMap(data['scope']);
    final people = _apiMapList(data['people']);
    final clients = _apiMapList(data['clientCompanies']);
    final providers = _apiMapList(data['providerCompanies']);

    return AlertDialog(
      title: const Text('Aplicabilidade territorial'),
      content: SizedBox(
        width: width,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Tag(
                    label: _apiText(scope['label'], fallback: 'escopo geral'),
                    icon: Icons.location_on_outlined,
                    color: _deepTealColor,
                    background: _deepTealColor.withValues(alpha: 0.09),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _applicabilitySection(
                context,
                title: 'Pessoas',
                icon: Icons.people_outline_rounded,
                items: people,
              ),
              const SizedBox(height: 12),
              _applicabilitySection(
                context,
                title: 'Clientes',
                icon: Icons.apartment_outlined,
                items: clients,
              ),
              const SizedBox(height: 12),
              _applicabilitySection(
                context,
                title: 'Prestadoras',
                icon: Icons.business_outlined,
                items: providers,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }

  Widget _applicabilitySection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Map<String, dynamic>> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _lineColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _deepTealColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$title (${items.length})',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: _inkColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const _HubEmptyLine(
              icon: Icons.search_off_outlined,
              text: 'Nenhum cadastro encontrado para este escopo.',
            )
          else
            for (final item in items.take(8)) ...[
              _applicabilityItem(item),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }

  Widget _applicabilityItem(Map<String, dynamic> item) {
    return Row(
      children: [
        const Icon(Icons.check_circle_outline_rounded, size: 17),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _apiText(item['name'], fallback: 'Cadastro sem nome'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _inkColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              Text(
                _apiText(item['address'], fallback: 'endereco nao informado'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _mutedColor, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _calendarEntryDisplayDateLabel(Map<String, dynamic> entry) {
  return _apiText(
    entry['occurrenceStartsAtLabel'],
    fallback: _apiText(entry['startsAtLabel']),
  );
}

String _calendarEntryRecurrenceDisplayLabel(Map<String, dynamic> entry) {
  return _apiText(
    entry['recurrenceRuleLabel'],
    fallback: _recurrenceRuleLabel(_apiText(entry['recurrenceRule'])),
  );
}

String _recurrenceRuleLabel(String rule) {
  return switch (rule.trim().toUpperCase()) {
    'DAILY' => 'Todos os dias',
    'WEEKDAYS' => 'Dias uteis',
    'WEEKLY' => 'Semanal',
    'MONTHLY' => 'Mensal',
    'MONTHLY_NTH_WEEKDAY' => 'Mensal por dia da semana',
    'YEARLY' => 'Anual',
    _ => 'Nao se repete',
  };
}

Map<String, String> _calendarRecurrenceOptions(DateTime date) {
  return {
    'NONE': 'Nao se repete',
    'DAILY': 'Todos os dias',
    'WEEKLY': 'Semanal: toda ${_weekdayLabel(date.weekday)}',
    'MONTHLY': 'Mensal: todo dia ${date.day}',
    'MONTHLY_NTH_WEEKDAY':
        'Mensal: ${_weekOfMonthLabel(date)} ${_weekdayLabel(date.weekday)}',
    'YEARLY': 'Anual: ${date.day}/${date.month.toString().padLeft(2, '0')}',
    'WEEKDAYS': 'Todos os dias da semana (segunda a sexta-feira)',
  };
}

String _weekdayLabel(int weekday) {
  const labels = {
    DateTime.monday: 'segunda-feira',
    DateTime.tuesday: 'terca-feira',
    DateTime.wednesday: 'quarta-feira',
    DateTime.thursday: 'quinta-feira',
    DateTime.friday: 'sexta-feira',
    DateTime.saturday: 'sabado',
    DateTime.sunday: 'domingo',
  };
  return labels[weekday] ?? 'dia da semana';
}

String _weekOfMonthLabel(DateTime date) {
  final week = ((date.day - 1) ~/ 7) + 1;
  return switch (week) {
    1 => 'na primeira',
    2 => 'na segunda',
    3 => 'na terceira',
    4 => 'na quarta',
    _ => 'na quinta',
  };
}

class _SharedCalendarFiltersDialog extends StatefulWidget {
  const _SharedCalendarFiltersDialog({required this.initialFilters});

  final Map<String, String> initialFilters;

  @override
  State<_SharedCalendarFiltersDialog> createState() =>
      _SharedCalendarFiltersDialogState();
}

class _SharedCalendarFiltersDialogState
    extends State<_SharedCalendarFiltersDialog> {
  late String _kind;
  late String _status;
  late String _recurrenceRule;
  late bool _includeDismissed;
  late final TextEditingController _category;
  late final TextEditingController _startsAtFrom;
  late final TextEditingController _startsAtTo;
  late final TextEditingController _createdAtFrom;
  late final TextEditingController _createdAtTo;
  late final TextEditingController _holidayRegionCode;
  late final TextEditingController _appliesToRegionCode;
  late final TextEditingController _appliesToStateCode;
  late final TextEditingController _appliesToCityName;
  late final TextEditingController _personPublicId;
  late final TextEditingController _providerCompanyPublicId;
  late final TextEditingController _clientCompanyPublicId;
  late final TextEditingController _contractPublicId;
  late final TextEditingController _contractTypePublicId;
  late final TextEditingController _employmentLinkPublicId;
  late final TextEditingController _positionPublicId;

  @override
  void initState() {
    super.initState();
    final filters = widget.initialFilters;
    _kind = filters['kind'] ?? '';
    _status = filters['status'] ?? '';
    _recurrenceRule = filters['recurrenceRule'] ?? '';
    _includeDismissed = filters['includeDismissed'] == 'true';
    _category = TextEditingController(text: filters['category'] ?? '');
    _startsAtFrom = TextEditingController(text: filters['startsAtFrom'] ?? '');
    _startsAtTo = TextEditingController(text: filters['startsAtTo'] ?? '');
    _createdAtFrom = TextEditingController(
      text: filters['createdAtFrom'] ?? '',
    );
    _createdAtTo = TextEditingController(text: filters['createdAtTo'] ?? '');
    _holidayRegionCode = TextEditingController(
      text: filters['holidayRegionCode'] ?? '',
    );
    _appliesToRegionCode = TextEditingController(
      text: filters['appliesToRegionCode'] ?? '',
    );
    _appliesToStateCode = TextEditingController(
      text: filters['appliesToStateCode'] ?? '',
    );
    _appliesToCityName = TextEditingController(
      text: filters['appliesToCityName'] ?? '',
    );
    _personPublicId = TextEditingController(
      text: filters['personPublicId'] ?? '',
    );
    _providerCompanyPublicId = TextEditingController(
      text: filters['providerCompanyPublicId'] ?? '',
    );
    _clientCompanyPublicId = TextEditingController(
      text: filters['clientCompanyPublicId'] ?? '',
    );
    _contractPublicId = TextEditingController(
      text: filters['contractPublicId'] ?? '',
    );
    _contractTypePublicId = TextEditingController(
      text: filters['contractTypePublicId'] ?? '',
    );
    _employmentLinkPublicId = TextEditingController(
      text: filters['employmentLinkPublicId'] ?? '',
    );
    _positionPublicId = TextEditingController(
      text: filters['positionPublicId'] ?? '',
    );
  }

  @override
  void dispose() {
    _category.dispose();
    _startsAtFrom.dispose();
    _startsAtTo.dispose();
    _createdAtFrom.dispose();
    _createdAtTo.dispose();
    _holidayRegionCode.dispose();
    _appliesToRegionCode.dispose();
    _appliesToStateCode.dispose();
    _appliesToCityName.dispose();
    _personPublicId.dispose();
    _providerCompanyPublicId.dispose();
    _clientCompanyPublicId.dispose();
    _contractPublicId.dispose();
    _contractTypePublicId.dispose();
    _employmentLinkPublicId.dispose();
    _positionPublicId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = min(MediaQuery.sizeOf(context).width * 0.92, 860.0);
    final fieldWidth = width < 620 ? width : (width - 18) / 2;

    return AlertDialog(
      title: const Text('Filtros do calendario'),
      content: SizedBox(
        width: width,
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 18,
            runSpacing: 12,
            children: [
              _dropdownField(
                width: fieldWidth,
                label: 'Tipo de agenda',
                value: _kind,
                values: const {
                  '': 'Todos',
                  'REMINDER': 'Lembrete',
                  'APPOINTMENT': 'Compromisso',
                  'NOTICE': 'Recado',
                },
                onChanged: (value) => setState(() => _kind = value ?? ''),
              ),
              _dropdownField(
                width: fieldWidth,
                label: 'Status da agenda',
                value: _status,
                values: const {
                  '': 'Todos',
                  'SCHEDULED': 'Agendado',
                  'COMPLETED': 'Concluido',
                  'CANCELED': 'Cancelado',
                  'MISSED': 'Perdido',
                },
                onChanged: (value) => setState(() => _status = value ?? ''),
              ),
              _textField(
                width: fieldWidth,
                controller: _category,
                label: 'Classificacao',
                icon: Icons.label_outline,
              ),
              _dropdownField(
                width: fieldWidth,
                label: 'Recorrencia',
                value: _recurrenceRule,
                values: const {
                  '': 'Todas',
                  'NONE': 'Nao se repete',
                  'DAILY': 'Todos os dias',
                  'WEEKDAYS': 'Dias uteis',
                  'WEEKLY': 'Semanal',
                  'MONTHLY': 'Mensal',
                  'MONTHLY_NTH_WEEKDAY': 'Mensal por dia da semana',
                  'YEARLY': 'Anual',
                },
                onChanged: (value) =>
                    setState(() => _recurrenceRule = value ?? ''),
              ),
              _textField(
                width: fieldWidth,
                controller: _startsAtFrom,
                label: 'Vigencia de',
                icon: Icons.event_outlined,
              ),
              _textField(
                width: fieldWidth,
                controller: _startsAtTo,
                label: 'Vigencia ate',
                icon: Icons.event_outlined,
              ),
              _textField(
                width: fieldWidth,
                controller: _createdAtFrom,
                label: 'Cadastro de',
                icon: Icons.manage_history_outlined,
              ),
              _textField(
                width: fieldWidth,
                controller: _createdAtTo,
                label: 'Cadastro ate',
                icon: Icons.manage_history_outlined,
              ),
              _textField(
                width: fieldWidth,
                controller: _holidayRegionCode,
                label: 'Regiao calendario',
                icon: Icons.location_city_outlined,
              ),
              _textField(
                width: fieldWidth,
                controller: _appliesToRegionCode,
                label: 'Aplica a regiao',
                icon: Icons.travel_explore_outlined,
              ),
              _textField(
                width: fieldWidth,
                controller: _appliesToStateCode,
                label: 'Aplica ao estado',
                icon: Icons.flag_outlined,
              ),
              _textField(
                width: fieldWidth,
                controller: _appliesToCityName,
                label: 'Aplica a cidade',
                icon: Icons.location_on_outlined,
              ),
              _textField(
                width: fieldWidth,
                controller: _personPublicId,
                label: 'Pessoa publicId',
                icon: Icons.person_outline,
              ),
              _textField(
                width: fieldWidth,
                controller: _providerCompanyPublicId,
                label: 'Prestadora publicId',
                icon: Icons.business_outlined,
              ),
              _textField(
                width: fieldWidth,
                controller: _clientCompanyPublicId,
                label: 'Cliente publicId',
                icon: Icons.apartment_outlined,
              ),
              _textField(
                width: fieldWidth,
                controller: _contractPublicId,
                label: 'Contrato publicId',
                icon: Icons.assignment_outlined,
              ),
              _textField(
                width: fieldWidth,
                controller: _contractTypePublicId,
                label: 'Tipo contrato publicId',
                icon: Icons.category_outlined,
              ),
              _textField(
                width: fieldWidth,
                controller: _employmentLinkPublicId,
                label: 'Vinculo publicId',
                icon: Icons.badge_outlined,
              ),
              _textField(
                width: fieldWidth,
                controller: _positionPublicId,
                label: 'Posto publicId',
                icon: Icons.work_outline,
              ),
              SizedBox(
                width: fieldWidth,
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _includeDismissed,
                  onChanged: (value) {
                    setState(() => _includeDismissed = value);
                  },
                  title: const Text('Mostrar desligados'),
                  subtitle: const Text(
                    'Por padrao lembretes de desligados ficam ocultos.',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(<String, String>{}),
          child: const Text('Limpar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(_buildFilters()),
          icon: const Icon(Icons.check_rounded, size: 18),
          label: const Text('Aplicar'),
        ),
      ],
    );
  }

  Widget _dropdownField({
    required double width,
    required String label,
    required String value,
    required Map<String, String> values,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<String>(
        initialValue: values.containsKey(value) ? value : '',
        decoration: _inputDecoration(label: label, icon: Icons.tune_outlined),
        items: [
          for (final entry in values.entries)
            DropdownMenuItem(value: entry.key, child: Text(entry.value)),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _textField({
    required double width,
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        decoration: _inputDecoration(label: label, icon: icon),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 18),
      border: const OutlineInputBorder(),
      isDense: true,
    );
  }

  Map<String, String> _buildFilters() {
    final filters = <String, String>{};
    void put(String key, String value) {
      final normalized = value.trim();
      if (normalized.isNotEmpty) {
        filters[key] = normalized;
      }
    }

    put('kind', _kind);
    put('status', _status);
    put('category', _category.text.toUpperCase());
    put('recurrenceRule', _recurrenceRule);
    put('startsAtFrom', _startsAtFrom.text);
    put('startsAtTo', _startsAtTo.text);
    put('createdAtFrom', _createdAtFrom.text);
    put('createdAtTo', _createdAtTo.text);
    put('holidayRegionCode', _holidayRegionCode.text.toUpperCase());
    put('appliesToRegionCode', _appliesToRegionCode.text.toUpperCase());
    put('appliesToStateCode', _appliesToStateCode.text.toUpperCase());
    put('appliesToCityName', _appliesToCityName.text);
    put('personPublicId', _personPublicId.text);
    put('providerCompanyPublicId', _providerCompanyPublicId.text);
    put('clientCompanyPublicId', _clientCompanyPublicId.text);
    put('contractPublicId', _contractPublicId.text);
    put('contractTypePublicId', _contractTypePublicId.text);
    put('employmentLinkPublicId', _employmentLinkPublicId.text);
    put('positionPublicId', _positionPublicId.text);
    if (_includeDismissed) {
      filters['includeDismissed'] = 'true';
    }
    return filters;
  }
}

class _SharedCalendarNonBusinessDayDialog extends StatefulWidget {
  const _SharedCalendarNonBusinessDayDialog();

  @override
  State<_SharedCalendarNonBusinessDayDialog> createState() =>
      _SharedCalendarNonBusinessDayDialogState();
}

class _SharedCalendarNonBusinessDayDialogState
    extends State<_SharedCalendarNonBusinessDayDialog> {
  final _date = TextEditingController();
  final _name = TextEditingController();
  final _regionCode = TextEditingController(text: 'BR-SP-CAMPINAS');
  final _stateCode = TextEditingController(text: 'SP');
  final _cityName = TextEditingController(text: 'Campinas');
  final _notes = TextEditingController();
  bool _recurringYearly = false;

  @override
  void dispose() {
    _date.dispose();
    _name.dispose();
    _regionCode.dispose();
    _stateCode.dispose();
    _cityName.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = min(MediaQuery.sizeOf(context).width * 0.92, 720.0);
    final fieldWidth = width < 560 ? width : (width - 16) / 2;

    return AlertDialog(
      title: const Text('Novo dia nao util'),
      content: SizedBox(
        width: width,
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _textField(
                width: fieldWidth,
                controller: _date,
                label: 'Data',
                icon: Icons.event_outlined,
              ),
              _textField(
                width: fieldWidth,
                controller: _name,
                label: 'Nome',
                icon: Icons.label_outline,
              ),
              _textField(
                width: fieldWidth,
                controller: _regionCode,
                label: 'Regiao',
                icon: Icons.location_city_outlined,
              ),
              _textField(
                width: fieldWidth,
                controller: _stateCode,
                label: 'Estado',
                icon: Icons.flag_outlined,
              ),
              _textField(
                width: fieldWidth,
                controller: _cityName,
                label: 'Cidade',
                icon: Icons.location_on_outlined,
              ),
              SizedBox(
                width: width,
                child: TextField(
                  controller: _notes,
                  maxLines: 4,
                  decoration: _inputDecoration(
                    label: 'Recado associado',
                    icon: Icons.campaign_outlined,
                  ),
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _recurringYearly,
                  onChanged: (value) {
                    setState(() => _recurringYearly = value);
                  },
                  title: const Text('Repetir anualmente'),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.check_rounded, size: 18),
          label: const Text('Salvar'),
        ),
      ],
    );
  }

  Widget _textField({
    required double width,
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        decoration: _inputDecoration(label: label, icon: icon),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 18),
      border: const OutlineInputBorder(),
      isDense: true,
    );
  }

  void _submit() {
    final date = _date.text.trim();
    final name = _name.text.trim();
    if (date.isEmpty || name.isEmpty) {
      return;
    }

    final body = <String, dynamic>{
      'date': date,
      'name': name,
      'scope': 'MUNICIPAL_HOLIDAY',
      'isRecurringYearly': _recurringYearly,
    };
    void put(String key, String value) {
      final normalized = value.trim();
      if (normalized.isNotEmpty) {
        body[key] = normalized;
      }
    }

    put('regionCode', _regionCode.text.toUpperCase());
    put('stateCode', _stateCode.text.toUpperCase());
    put('cityName', _cityName.text);
    put('notes', _notes.text);
    Navigator.of(context).pop(body);
  }
}

class _CalendarDayDetailsDialog extends StatelessWidget {
  const _CalendarDayDetailsDialog({
    required this.date,
    required this.entries,
    required this.nonBusinessDays,
    required this.onAddEvent,
    required this.onEditEntry,
    required this.onCancelEntry,
    required this.onApplicability,
    required this.scopeFromEntry,
    required this.scopeFromNonBusinessDay,
  });

  final DateTime date;
  final List<Map<String, dynamic>> entries;
  final List<Map<String, dynamic>> nonBusinessDays;
  final VoidCallback onAddEvent;
  final ValueChanged<Map<String, dynamic>> onEditEntry;
  final ValueChanged<Map<String, dynamic>> onCancelEntry;
  final ValueChanged<Map<String, String>> onApplicability;
  final Map<String, String> Function(Map<String, dynamic>) scopeFromEntry;
  final Map<String, String> Function(Map<String, dynamic>)
  scopeFromNonBusinessDay;

  @override
  Widget build(BuildContext context) {
    final width = min(MediaQuery.sizeOf(context).width * 0.92, 760.0);
    return AlertDialog(
      title: Text(_apiLongDate(date)),
      content: SizedBox(
        width: width,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (nonBusinessDays.isNotEmpty) ...[
                _sectionTitle(context, 'Dias nao uteis'),
                const SizedBox(height: 8),
                for (final item in nonBusinessDays)
                  _nonBusinessDayTile(context, item),
                const SizedBox(height: 12),
              ],
              _sectionTitle(context, 'Itens do dia'),
              const SizedBox(height: 8),
              if (entries.isEmpty)
                const _HubEmptyLine(
                  icon: Icons.event_available_outlined,
                  text: 'Nenhum item para este dia.',
                )
              else
                for (final entry in entries) _entryTile(context, entry),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
        FilledButton.icon(
          onPressed: () => _closeThen(context, onAddEvent),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Novo item'),
        ),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: _inkColor,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _nonBusinessDayTile(BuildContext context, Map<String, dynamic> item) {
    final scope = scopeFromNonBusinessDay(item);
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event_busy_outlined, color: _amberColor),
      title: Text(_apiText(item['name'], fallback: 'Dia nao util')),
      subtitle: Text(
        [
          _apiText(item['dateLabel'], fallback: _apiText(item['date'])),
          _apiText(item['regionCode']),
          _apiText(item['stateCode']),
          _apiText(item['cityName']),
        ].where((value) => value.isNotEmpty).join(' | '),
      ),
      trailing: scope.isEmpty
          ? null
          : IconButton(
              tooltip: 'Ver aplicabilidade',
              onPressed: () =>
                  _closeThen(context, () => onApplicability(scope)),
              icon: const Icon(Icons.groups_2_outlined),
            ),
    );
  }

  Widget _entryTile(BuildContext context, Map<String, dynamic> entry) {
    final scope = scopeFromEntry(entry);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: _lineColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(_apiText(entry['title'], fallback: 'Item de calendario')),
        subtitle: Text(
          [
            _calendarEntryDisplayDateLabel(entry),
            _apiText(entry['kindLabel'], fallback: _apiText(entry['kind'])),
            _apiText(entry['statusLabel'], fallback: _apiText(entry['status'])),
            if (_apiText(entry['recurrenceRule']).isNotEmpty)
              _calendarEntryRecurrenceDisplayLabel(entry),
          ].where((value) => value.isNotEmpty).join(' | '),
        ),
        trailing: Wrap(
          spacing: 2,
          children: [
            if (scope.isNotEmpty)
              IconButton(
                tooltip: 'Ver aplicabilidade',
                onPressed: () =>
                    _closeThen(context, () => onApplicability(scope)),
                icon: const Icon(Icons.groups_2_outlined),
              ),
            IconButton(
              tooltip: 'Editar',
              onPressed: entry['canEdit'] == true
                  ? () => _closeThen(context, () => onEditEntry(entry))
                  : null,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Cancelar',
              onPressed: entry['canCancel'] == true
                  ? () => _closeThen(context, () => onCancelEntry(entry))
                  : null,
              icon: const Icon(Icons.event_busy_outlined),
            ),
          ],
        ),
      ),
    );
  }

  void _closeThen(BuildContext context, VoidCallback callback) {
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) => callback());
  }
}

class _SharedCalendarEntryDialog extends StatefulWidget {
  const _SharedCalendarEntryDialog({required this.initialDate, this.entry});

  final DateTime initialDate;
  final Map<String, dynamic>? entry;

  @override
  State<_SharedCalendarEntryDialog> createState() =>
      _SharedCalendarEntryDialogState();
}

class _SharedCalendarEntryDialogState
    extends State<_SharedCalendarEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _category;
  late final TextEditingController _startsAt;
  late final TextEditingController _endsAt;
  late final TextEditingController _holidayRegionCode;
  late final TextEditingController _appliesToRegionCode;
  late final TextEditingController _appliesToStateCode;
  late final TextEditingController _appliesToCityName;
  late final TextEditingController _editJustification;
  late final TextEditingController _notificationTime;
  late final TextEditingController _notificationOffsetBusinessDays;
  late String _kind;
  late String _priority;
  late String _recurrenceRule;
  late String _businessDayPolicy;
  late String _notificationPolicy;
  late bool _isAllDay;
  late Set<String> _notificationChannels;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    final notification = _apiMap(entry?['notification']);
    final applicability = _apiMap(entry?['applicability']);
    _kind = _apiText(entry?['kind'], fallback: 'REMINDER');
    _priority = _apiText(entry?['priority'], fallback: 'NORMAL');
    _recurrenceRule = _apiText(entry?['recurrenceRule'], fallback: 'NONE');
    _businessDayPolicy = _apiText(
      entry?['businessDayPolicy'],
      fallback: 'ALLOW_NON_BUSINESS_DAY',
    );
    _notificationPolicy = _apiText(
      notification['policy'],
      fallback: _apiText(
        entry?['notificationPolicy'],
        fallback: 'ONE_BUSINESS_DAY_BEFORE',
      ),
    );
    _isAllDay = entry?['isAllDay'] != false;
    _notificationChannels = _readChannels(notification['channels']);
    _title = TextEditingController(text: _apiText(entry?['title']));
    _description = TextEditingController(text: _apiText(entry?['description']));
    _category = TextEditingController(text: _apiText(entry?['category']));
    _startsAt = TextEditingController(
      text: _dateInputFromApi(
        entry?['seriesStartsAt'] ?? entry?['startsAt'],
        widget.initialDate,
      ),
    );
    _endsAt = TextEditingController(text: _dateInputFromApi(entry?['endsAt']));
    _holidayRegionCode = TextEditingController(
      text: _apiText(entry?['holidayRegionCode']),
    );
    _appliesToRegionCode = TextEditingController(
      text: _apiText(applicability['regionCode']),
    );
    _appliesToStateCode = TextEditingController(
      text: _apiText(applicability['stateCode']),
    );
    _appliesToCityName = TextEditingController(
      text: _apiText(applicability['cityName']),
    );
    _editJustification = TextEditingController();
    _notificationTime = TextEditingController(
      text: _apiText(notification['time'], fallback: '09:00'),
    );
    _notificationOffsetBusinessDays = TextEditingController(
      text: _apiText(notification['offsetBusinessDays'], fallback: '1'),
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _category.dispose();
    _startsAt.dispose();
    _endsAt.dispose();
    _holidayRegionCode.dispose();
    _appliesToRegionCode.dispose();
    _appliesToStateCode.dispose();
    _appliesToCityName.dispose();
    _editJustification.dispose();
    _notificationTime.dispose();
    _notificationOffsetBusinessDays.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = min(MediaQuery.sizeOf(context).width * 0.92, 760.0);
    final fieldWidth = width < 620 ? width : (width - 16) / 2;
    final recurrenceOptions = _calendarRecurrenceOptions(_selectedDate);
    return AlertDialog(
      title: Text(widget.entry == null ? 'Novo item de agenda' : 'Editar item'),
      content: SizedBox(
        width: width,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _textField(
                  width: width,
                  controller: _title,
                  label: 'Titulo',
                  icon: Icons.title_outlined,
                  required: true,
                ),
                _textField(
                  width: width,
                  controller: _description,
                  label: 'Descricao',
                  icon: Icons.notes_outlined,
                  maxLines: 4,
                ),
                _dropdownField(
                  width: fieldWidth,
                  label: 'Tipo',
                  value: _kind,
                  values: const {
                    'REMINDER': 'Lembrete',
                    'APPOINTMENT': 'Compromisso',
                    'NOTICE': 'Recado',
                  },
                  onChanged: (value) =>
                      setState(() => _kind = value ?? 'REMINDER'),
                ),
                _dropdownField(
                  width: fieldWidth,
                  label: 'Prioridade',
                  value: _priority,
                  values: const {
                    'LOW': 'Baixa',
                    'NORMAL': 'Normal',
                    'HIGH': 'Alta',
                    'CRITICAL': 'Critica',
                  },
                  onChanged: (value) =>
                      setState(() => _priority = value ?? 'NORMAL'),
                ),
                _textField(
                  width: fieldWidth,
                  controller: _startsAt,
                  label: 'Inicio',
                  icon: Icons.event_outlined,
                  required: true,
                ),
                _textField(
                  width: fieldWidth,
                  controller: _endsAt,
                  label: 'Fim',
                  icon: Icons.event_available_outlined,
                ),
                _dropdownField(
                  width: fieldWidth,
                  label: 'Recorrencia',
                  value: recurrenceOptions.containsKey(_recurrenceRule)
                      ? _recurrenceRule
                      : 'NONE',
                  values: recurrenceOptions,
                  onChanged: (value) =>
                      setState(() => _recurrenceRule = value ?? 'NONE'),
                ),
                _dropdownField(
                  width: fieldWidth,
                  label: 'Dia util',
                  value: _businessDayPolicy,
                  values: const {
                    'ALLOW_NON_BUSINESS_DAY': 'Permitir',
                    'MOVE_TO_PREVIOUS_BUSINESS_DAY': 'Mover para anterior',
                    'MOVE_TO_NEXT_BUSINESS_DAY': 'Mover para proximo',
                    'REQUIRE_BUSINESS_DAY': 'Bloquear',
                  },
                  onChanged: (value) => setState(
                    () =>
                        _businessDayPolicy = value ?? 'ALLOW_NON_BUSINESS_DAY',
                  ),
                ),
                _textField(
                  width: fieldWidth,
                  controller: _category,
                  label: 'Classificacao',
                  icon: Icons.label_outline,
                ),
                _textField(
                  width: fieldWidth,
                  controller: _holidayRegionCode,
                  label: 'Regiao calendario',
                  icon: Icons.location_city_outlined,
                ),
                _textField(
                  width: fieldWidth,
                  controller: _appliesToRegionCode,
                  label: 'Aplica a regiao',
                  icon: Icons.travel_explore_outlined,
                ),
                _textField(
                  width: fieldWidth,
                  controller: _appliesToStateCode,
                  label: 'Aplica ao estado',
                  icon: Icons.flag_outlined,
                ),
                _textField(
                  width: fieldWidth,
                  controller: _appliesToCityName,
                  label: 'Aplica a cidade',
                  icon: Icons.location_on_outlined,
                ),
                if (widget.entry != null)
                  _textField(
                    width: width,
                    controller: _editJustification,
                    label: 'Justificativa da edicao',
                    icon: Icons.edit_note_outlined,
                    maxLines: 2,
                  ),
                _dropdownField(
                  width: fieldWidth,
                  label: 'Notificacao',
                  value: _notificationPolicy,
                  values: const {
                    'ON_DUE_DATE': 'No dia',
                    'ONE_BUSINESS_DAY_BEFORE': '1 dia util antes',
                    'SAME_DAY_OR_PREVIOUS_BUSINESS_DAY':
                        'No dia ou util anterior',
                    'CUSTOM_BUSINESS_DAYS_BEFORE': 'Dias uteis antes',
                  },
                  onChanged: (value) => setState(
                    () => _notificationPolicy =
                        value ?? 'ONE_BUSINESS_DAY_BEFORE',
                  ),
                ),
                _textField(
                  width: fieldWidth,
                  controller: _notificationTime,
                  label: 'Hora',
                  icon: Icons.schedule_outlined,
                ),
                if (_notificationPolicy == 'CUSTOM_BUSINESS_DAYS_BEFORE')
                  _textField(
                    width: fieldWidth,
                    controller: _notificationOffsetBusinessDays,
                    label: 'Dias uteis antes',
                    icon: Icons.work_history_outlined,
                  ),
                SizedBox(
                  width: fieldWidth,
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _isAllDay,
                    onChanged: (value) => setState(() => _isAllDay = value),
                    title: const Text('Dia inteiro'),
                  ),
                ),
                SizedBox(
                  width: width,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _channelChip(
                        'IN_APP',
                        'No app',
                        Icons.notifications_none,
                      ),
                      _channelChip('EMAIL', 'Email', Icons.mail_outline),
                      _channelChip('PUSH', 'Push', Icons.phone_iphone_outlined),
                      _channelChip(
                        'WEBHOOK',
                        'Webhook',
                        Icons.webhook_outlined,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.check_rounded, size: 18),
          label: const Text('Salvar'),
        ),
      ],
    );
  }

  DateTime get _selectedDate =>
      DateTime.tryParse(_startsAt.text) ?? widget.initialDate;

  Widget _textField({
    required double width,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
  }) {
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: _inputDecoration(label: label, icon: icon),
        validator: required
            ? (value) =>
                  (value?.trim().isEmpty ?? true) ? 'Campo obrigatorio' : null
            : null,
      ),
    );
  }

  Widget _dropdownField({
    required double width,
    required String label,
    required String value,
    required Map<String, String> values,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<String>(
        initialValue: values.containsKey(value) ? value : values.keys.first,
        decoration: _inputDecoration(label: label, icon: Icons.tune_outlined),
        items: [
          for (final item in values.entries)
            DropdownMenuItem(value: item.key, child: Text(item.value)),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _channelChip(String value, String label, IconData icon) {
    final selected = _notificationChannels.contains(value);
    return FilterChip(
      selected: selected,
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onSelected: (checked) {
        setState(() {
          if (checked) {
            _notificationChannels.add(value);
          } else {
            _notificationChannels.remove(value);
          }
        });
      },
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 18),
      border: const OutlineInputBorder(),
      isDense: true,
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_isValidTimeInput(_notificationTime.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe a hora no formato HH:mm.')),
      );
      return;
    }

    final offset =
        int.tryParse(_notificationOffsetBusinessDays.text.trim()) ?? 0;
    if (_notificationPolicy == 'CUSTOM_BUSINESS_DAYS_BEFORE' &&
        (offset < 1 || offset > 30)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Use de 1 a 30 dias uteis.')),
      );
      return;
    }

    final channels = _notificationChannels.isEmpty
        ? const ['IN_APP']
        : _notificationChannels.toList(growable: false);
    Navigator.of(context).pop(
      _cleanMutationBody({
        'kind': _kind,
        'title': _title.text,
        'description': _description.text,
        'category': _category.text.toUpperCase(),
        'recurrenceRule': _recurrenceRule,
        'startsAt': _startsAt.text,
        'endsAt': _endsAt.text,
        'timezone': 'America/Sao_Paulo',
        'isAllDay': _isAllDay,
        'priority': _priority,
        'businessDayPolicy': _businessDayPolicy,
        'holidayRegionCode': _holidayRegionCode.text.toUpperCase(),
        'appliesToRegionCode': _appliesToRegionCode.text.toUpperCase(),
        'appliesToStateCode': _appliesToStateCode.text.toUpperCase(),
        'appliesToCityName': _appliesToCityName.text,
        if (widget.entry != null) 'editJustification': _editJustification.text,
        'notificationPolicy': _notificationPolicy,
        'notificationOffsetBusinessDays':
            _notificationPolicy == 'CUSTOM_BUSINESS_DAYS_BEFORE'
            ? offset
            : (_notificationPolicy == 'ONE_BUSINESS_DAY_BEFORE' ? 1 : 0),
        'notificationTime': _notificationTime.text,
        'notificationChannels': channels,
      }),
    );
  }

  Set<String> _readChannels(Object? value) {
    if (value is List) {
      final parsed = value
          .map(_apiText)
          .where((item) => item.isNotEmpty)
          .toSet();
      if (parsed.isNotEmpty) {
        return parsed;
      }
    }
    return {'IN_APP', 'EMAIL'};
  }

  String _dateInputFromApi(Object? value, [DateTime? fallback]) {
    final text = _apiText(value);
    final parsed = text.isEmpty ? null : DateTime.tryParse(text);
    if (parsed != null) {
      return _inputDateFor(parsed);
    }
    return fallback == null ? '' : _inputDateFor(fallback);
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
                  color: Colors.white.withValues(alpha: 0.95),
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
