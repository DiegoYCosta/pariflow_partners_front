part of '../../../app/app.dart';

final _peopleWorkspaceData = _EntityWorkspaceData(
  title: 'Funcionarios com ficha mais legivel',
  subtitle:
      'A consulta de pessoas respeita a separacao entre registro-base, vinculo, empresa e historico. O layout evita transformar tudo em um bloco confuso.',
  searchHint: 'buscar por nome, cpf, email ou telefone',
  listHint:
      'A lista abre a ficha certa sem perder o contexto. A lateral antecipa historico, status e relacoes principais.',
  productionHint:
      'Primeiro passo real: combinar ficha base, vinculos e tags protegidas em uma leitura unica, sem quebrar a consulta humana do colaborador.',
  integrationFocus: [
    'ficha consolidada',
    'vinculos',
    'tags protegidas',
    'historico',
  ],
  filters: ['ativos', 'desligados recentes', 'mais de um vinculo'],
  accent: _roseColor,
  items: _buildPeopleWorkspaceItems(),
);

List<_EntityItem> _buildPeopleWorkspaceItems() => [
  ..._buildVisualNetworkEmployeeItems(),
  _EntityItem(
    publicId: 'pes_01hpes0000000000000001',
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
    attachments: [
      _AttachmentRecord(
        publicId: 'anx_01hpesformal000000000001',
        title: 'ASO admissional',
        classification: _AttachmentClassification.formalDocument,
        summary: 'Documento formal ligado ao dossie base do colaborador.',
        status: 'vigente',
        updatedAtLabel: 'atualizado em 01/2026',
        accessPolicy: _ProtectedAccessPolicy(
          owner: _audienceCamila,
          allowedGroups: [_CollaboratorAudienceGroup.board],
          allowedPeople: [_audienceMarta],
        ),
      ),
    ],
    sensitiveNotes: [
      _SensitiveNoteTag(
        label: 'filha com consulta nas segundas',
        note:
            'Preferir nao marcar troca de turno de segunda logo cedo sem confirmar. Entrada anonima permitida, visualizacao restrita por conter contexto familiar sensivel.',
        classification: _SensitiveNoteClassification.familyContext,
        color: _roseColor,
        sortOrder: 1,
        accessPolicy: _ProtectedAccessPolicy(
          owner: _audienceMarta,
          allowedPeople: [_audienceDiego],
        ),
      ),
      _SensitiveNoteTag(
        label: 'faz krav maga',
        note:
            'Informacao contextual util para leitura de perfil em posto de seguranca, sem substituir avaliacao formal nem treinamento exigido.',
        classification: _SensitiveNoteClassification.trainingOrSkill,
        color: _tealColor,
        sortOrder: 2,
        accessPolicy: _ProtectedAccessPolicy(
          owner: _audienceCamila,
          allowedGroups: [_CollaboratorAudienceGroup.supervision],
          allowedPeople: [_audienceLucas],
        ),
      ),
    ],
  ),
  _EntityItem(
    publicId: 'pes_01hpes0000000000000002',
    title: 'Bruno Tavares',
    subtitle: 'Pessoa desligada recentemente e ainda relevante para a teia.',
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
    attachments: [
      _AttachmentRecord(
        publicId: 'anx_01hpessens000000000002',
        title: 'Relato interno de desligamento',
        classification: _AttachmentClassification.sensitiveAttachment,
        summary:
            'Arquivo protegido com contexto complementar ao desligamento recente.',
        status: 'restrito',
        updatedAtLabel: 'atualizado em 04/2026',
        accessPolicy: _ProtectedAccessPolicy(
          owner: _audienceDiego,
          allowedGroups: [_CollaboratorAudienceGroup.board],
          allowedPeople: [_audienceMarta],
        ),
        canDownload: false,
      ),
    ],
    sensitiveNotes: [
      _SensitiveNoteTag(
        label: 'costuma atrasar',
        note:
            'Historico informal de atrasos recorrentes no primeiro turno. Registrar como observacao interna, nao como fato disciplinar definitivo.',
        classification: _SensitiveNoteClassification.behavioralSignal,
        color: _amberColor,
        sortOrder: 1,
        accessPolicy: _ProtectedAccessPolicy(owner: _audienceLucas),
      ),
      _SensitiveNoteTag(
        label: 'mente sobre justificativas',
        note:
            'Sinal relatado pela operacao, ainda dependente de confirmacao documental. A leitura deve ficar protegida para evitar difusao indevida.',
        classification: _SensitiveNoteClassification.behavioralSignal,
        color: _roseColor,
        sortOrder: 2,
        accessPolicy: _ProtectedAccessPolicy(
          owner: _audienceMarta,
          allowedGroups: [_CollaboratorAudienceGroup.board],
        ),
      ),
    ],
  ),
  _EntityItem(
    publicId: 'pes_01hpes0000000000000003',
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
    attachments: [
      _AttachmentRecord(
        publicId: 'anx_01hpesref000000000003',
        title: 'Resumo de transicao de posto',
        classification: _AttachmentClassification.supportingReference,
        summary:
            'Referencia de apoio para leitura rapida da movimentacao recente.',
        status: 'ativo',
        updatedAtLabel: 'atualizado em 03/2026',
        accessPolicy: _ProtectedAccessPolicy(
          owner: _audienceLucas,
          allowedGroups: [_CollaboratorAudienceGroup.auxiliary],
          allowedPeople: [_audienceMarta],
        ),
      ),
    ],
    sensitiveNotes: [
      _SensitiveNoteTag(
        label: 'filho cursa administracao',
        note:
            'Contexto pessoal coletado em conversa de rotina. Pode ajudar no entendimento humano do quadro, mas exige leitura autenticada por ser dado sensivel e lateral ao contrato.',
        classification: _SensitiveNoteClassification.personalContext,
        color: _slateColor,
        sortOrder: 1,
        accessPolicy: _ProtectedAccessPolicy(
          owner: _audienceCamila,
          allowedGroups: [_CollaboratorAudienceGroup.board],
          allowedPeople: [_audienceMarta],
        ),
      ),
    ],
  ),
  ..._buildGeneratedPeopleItems(),
];

List<_EntityItem> _buildVisualNetworkEmployeeItems() {
  return _networkGraphContractPreview.nodes
      .where((node) => node.lane == _NetworkGraphLane.employee)
      .map(_buildVisualNetworkEmployeeItem)
      .toList();
}

_EntityItem _buildVisualNetworkEmployeeItem(_NetworkGraphNode node) {
  final extras = node.detailSnapshot.extras;
  final contract = '${extras['contract'] ?? '-'}';
  final clientCompany = '${extras['clientCompany'] ?? '-'}';
  final manager = '${extras['manager'] ?? '-'}';
  final department = '${extras['department'] ?? '-'}';
  final employeeId = '${extras['employeeId'] ?? node.publicId}';
  final primaryBadge = node.badges.isEmpty
      ? 'visual network'
      : node.badges.first;

  return _EntityItem(
    publicId: node.publicId,
    title: node.displayName,
    subtitle: '${node.subtitle} com ficha aberta a partir da Visual Network.',
    meta: '${_titleCase(node.status)} | $contract | $clientCompany',
    status: node.status == 'active' ? 'ativo' : _titleCase(node.status),
    icon: Icons.badge_outlined,
    color: _roseColor,
    detailSummary:
        'A ficha individual do colaborador sai da leitura de malha e abre aqui, preservando separacao entre contexto relacional, identificacao humana e historico operacional.',
    relations: [
      'Employee ID: $employeeId',
      'Contrato atual: $contract',
      'Empresa cliente: $clientCompany',
      'Gestor imediato: $manager',
      'Departamento: $department',
      'Marcador visual: $primaryBadge',
    ],
    attachments: _visualNetworkEmployeeAttachments(node),
    sensitiveNotes: _visualNetworkEmployeeNotes(node),
  );
}

List<_AttachmentRecord> _visualNetworkEmployeeAttachments(
  _NetworkGraphNode node,
) {
  final owner = switch (node.publicId) {
    'employee_jessica_lee' => _audienceCamila,
    'employee_michael_chen' => _audienceLucas,
    'employee_sarah_johnson' => _audienceMarta,
    'employee_david_williams' => _audienceDiego,
    'employee_emily_davis' => _audienceCamila,
    _ => _audienceCamila,
  };

  final company = node.displayName.split(' ').first;
  return [
    _AttachmentRecord(
      publicId: 'anx_${node.publicId}_offer',
      title: 'Offer Letter - $company.pdf',
      classification: _AttachmentClassification.formalDocument,
      summary: 'Documento formal do vinculo atual do colaborador.',
      status: 'ativo',
      updatedAtLabel: 'updated on 08/2024',
      accessPolicy: _ProtectedAccessPolicy(
        owner: owner,
        allowedGroups: const [_CollaboratorAudienceGroup.board],
        allowedPeople: const [_audienceMarta],
      ),
    ),
    _AttachmentRecord(
      publicId: 'anx_${node.publicId}_agreement',
      title: 'Employment Agreement.pdf',
      classification: _AttachmentClassification.formalDocument,
      summary: 'Contrato de trabalho armazenado no dossie base.',
      status: 'ativo',
      updatedAtLabel: 'updated on 01/2025',
      accessPolicy: _ProtectedAccessPolicy(
        owner: owner,
        allowedGroups: const [_CollaboratorAudienceGroup.supervision],
      ),
    ),
    _AttachmentRecord(
      publicId: 'anx_${node.publicId}_review',
      title: 'Performance Review - 2025.xlsx',
      classification: _AttachmentClassification.supportingReference,
      summary:
          'Planilha de acompanhamento de desempenho com leitura rastreavel.',
      status: 'restrito',
      updatedAtLabel: 'updated on 03/2026',
      accessPolicy: _ProtectedAccessPolicy(
        owner: owner,
        allowedPeople: const [_audienceDiego, _audienceMarta],
      ),
      canDownload: false,
    ),
  ];
}

List<_SensitiveNoteTag> _visualNetworkEmployeeNotes(_NetworkGraphNode node) {
  return switch (node.publicId) {
    'employee_jessica_lee' => [
      _SensitiveNoteTag(
        label: 'cross-team escalation',
        note:
            'Atua como ponto de escalacao entre cliente e operacao. A nota permanece protegida porque mistura percepcao de lideranca e rotina da conta.',
        classification: _SensitiveNoteClassification.behavioralSignal,
        color: _tealColor,
        sortOrder: 1,
        accessPolicy: _ProtectedAccessPolicy(
          owner: _audienceCamila,
          allowedGroups: [_CollaboratorAudienceGroup.supervision],
        ),
      ),
      _SensitiveNoteTag(
        label: 'relocated for role',
        note:
            'Mudanca de cidade registrada no onboarding e relevante para decisoes de mobilidade e cobertura.',
        classification: _SensitiveNoteClassification.personalContext,
        color: _amberColor,
        sortOrder: 2,
        accessPolicy: _ProtectedAccessPolicy(
          owner: _audienceCamila,
          allowedPeople: [_audienceMarta],
        ),
      ),
    ],
    'employee_michael_chen' => [
      _SensitiveNoteTag(
        label: 'infra access overlap',
        note:
            'Acesso compartilhado com dois contratos exige trilha de auditoria e validacao adicional em trocas de alocacao.',
        classification: _SensitiveNoteClassification.operationalRisk,
        color: _roseColor,
        sortOrder: 1,
        accessPolicy: _ProtectedAccessPolicy(
          owner: _audienceLucas,
          allowedGroups: [_CollaboratorAudienceGroup.board],
        ),
      ),
    ],
    'employee_sarah_johnson' => [
      _SensitiveNoteTag(
        label: 'performance concern (2025)',
        note:
            'Ponto de atencao de performance ligado a volume de entregas durante a transicao entre maintenance e consulting.',
        classification: _SensitiveNoteClassification.behavioralSignal,
        color: _tealColor,
        sortOrder: 1,
        accessPolicy: _ProtectedAccessPolicy(
          owner: _audienceMarta,
          allowedGroups: [_CollaboratorAudienceGroup.board],
          allowedPeople: [_audienceDiego],
        ),
      ),
      _SensitiveNoteTag(
        label: 'family caregiver',
        note:
            'Contexto familiar relevante para agendas presenciais e composicao de jornada, com leitura limitada ao grupo autorizado.',
        classification: _SensitiveNoteClassification.familyContext,
        color: _amberColor,
        sortOrder: 2,
        accessPolicy: _ProtectedAccessPolicy(
          owner: _audienceMarta,
          allowedPeople: [_audienceCamila],
        ),
      ),
      _SensitiveNoteTag(
        label: 'confidential medical note',
        note:
            'Observacao clinica protegida que nao deve ser refletida fora do fluxo autorizado pela API.',
        classification: _SensitiveNoteClassification.personalContext,
        color: _slateColor,
        sortOrder: 3,
        accessPolicy: _ProtectedAccessPolicy(
          owner: _audienceDiego,
          allowedGroups: [_CollaboratorAudienceGroup.board],
        ),
      ),
    ],
    'employee_david_williams' => [
      _SensitiveNoteTag(
        label: 'client recovery lead',
        note:
            'Historico de atuacao em recuperacao de conta com cliente critico. A leitura e mantida em camada protegida por envolver risco comercial.',
        classification: _SensitiveNoteClassification.trainingOrSkill,
        color: _tealColor,
        sortOrder: 1,
        accessPolicy: _ProtectedAccessPolicy(
          owner: _audienceDiego,
          allowedGroups: [_CollaboratorAudienceGroup.supervision],
        ),
      ),
    ],
    'employee_emily_davis' => [
      _SensitiveNoteTag(
        label: 'feedback required',
        note:
            'Feedback estruturado pendente apos a fase de preservacao operacional no contrato expirado.',
        classification: _SensitiveNoteClassification.behavioralSignal,
        color: _amberColor,
        sortOrder: 1,
        accessPolicy: _ProtectedAccessPolicy(
          owner: _audienceCamila,
          allowedGroups: [_CollaboratorAudienceGroup.supervision],
          allowedPeople: [_audienceMarta],
        ),
      ),
    ],
    _ => const [],
  };
}

_PersonProfileData _personProfileFor(_EntityItem item) {
  switch (item.publicId) {
    case 'pes_01hpes0000000000000001':
      return const _PersonProfileData(
        roleTitle: 'Site Operations Supervisor',
        statusLabel: 'Active',
        statusColor: _tealColor,
        profileFields: [
          _PersonInfoField(
            icon: Icons.mail_outline_rounded,
            label: 'Email',
            value: 'ana.rocha@pariflow.com.br',
          ),
          _PersonInfoField(
            icon: Icons.call_outlined,
            label: 'Phone',
            value: '+55 (11) 98921-4450',
          ),
          _PersonInfoField(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: 'Sao Paulo, SP',
          ),
          _PersonInfoField(
            icon: Icons.link_rounded,
            label: 'LinkedIn',
            value: 'linkedin.com/in/ana-paula-rocha',
          ),
          _PersonInfoField(
            icon: Icons.badge_outlined,
            label: 'Employee ID',
            value: 'PFP-02184',
          ),
          _PersonInfoField(
            icon: Icons.cake_outlined,
            label: 'Date of Birth',
            value: 'May 14, 1988 (37)',
          ),
          _PersonInfoField(
            icon: Icons.public_outlined,
            label: 'Nationality',
            value: 'Brazilian',
          ),
          _PersonInfoField(
            icon: Icons.verified_user_outlined,
            label: 'Work Authorization',
            value: 'Authorized to work in Brazil',
          ),
        ],
        managerName: 'Sarah Mitchell',
        managerRole: 'Regional Operations Director',
        teamLabel: 'Operations Excellence',
        departmentLabel: 'Field Operations',
        timelineSummary: 'Timeline of Ana current and past company links.',
        employmentLinks: [
          _EmploymentLinkRecord(
            periodLabel: 'Jan 2025\n- Present',
            companyName: 'PariFlow Servicos Ltda',
            roleTitle: 'Site Operations Supervisor',
            fullDateLabel: 'Jan 06, 2025 - Present',
            locationLabel: 'Sao Paulo, SP',
            brandMonogram: 'PF',
            accent: _tealColor,
            isCurrent: true,
          ),
          _EmploymentLinkRecord(
            periodLabel: 'Aug 2022\n- Dec 2024',
            companyName: 'Orbe Seguranca',
            roleTitle: 'Operations Coordinator',
            fullDateLabel: 'Aug 15, 2022 - Dec 18, 2024',
            locationLabel: 'Barueri, SP',
            brandMonogram: 'OS',
            accent: _slateColor,
          ),
          _EmploymentLinkRecord(
            periodLabel: 'Feb 2019\n- Jul 2022',
            companyName: 'Atlas Portaria e Servicos',
            roleTitle: 'Team Lead',
            fullDateLabel: 'Feb 04, 2019 - Jul 29, 2022',
            locationLabel: 'Guarulhos, SP',
            brandMonogram: 'AT',
            accent: _amberColor,
          ),
        ],
      );
    case 'pes_01hpes0000000000000002':
      return const _PersonProfileData(
        roleTitle: 'Field Support Assistant',
        statusLabel: 'Dismissed',
        statusColor: _roseColor,
        profileFields: [
          _PersonInfoField(
            icon: Icons.mail_outline_rounded,
            label: 'Email',
            value: 'bruno.tavares@alphafacilities.com.br',
          ),
          _PersonInfoField(
            icon: Icons.call_outlined,
            label: 'Phone',
            value: '+55 (21) 98114-2205',
          ),
          _PersonInfoField(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: 'Rio de Janeiro, RJ',
          ),
          _PersonInfoField(
            icon: Icons.link_rounded,
            label: 'LinkedIn',
            value: 'linkedin.com/in/bruno-tavares',
          ),
          _PersonInfoField(
            icon: Icons.badge_outlined,
            label: 'Employee ID',
            value: 'ALF-07442',
          ),
          _PersonInfoField(
            icon: Icons.cake_outlined,
            label: 'Date of Birth',
            value: 'Nov 03, 1992 (33)',
          ),
          _PersonInfoField(
            icon: Icons.public_outlined,
            label: 'Nationality',
            value: 'Brazilian',
          ),
          _PersonInfoField(
            icon: Icons.verified_user_outlined,
            label: 'Work Authorization',
            value: 'Authorized to work in Brazil',
          ),
        ],
        managerName: 'Diego Costa',
        managerRole: 'People & Risk Director',
        teamLabel: 'Risk Follow-up',
        departmentLabel: 'Field Support',
        timelineSummary: 'Timeline of Bruno most recent employment links.',
        employmentLinks: [
          _EmploymentLinkRecord(
            periodLabel: 'Jun 2025\n- Apr 2026',
            companyName: 'Alpha Facilities',
            roleTitle: 'Field Support Assistant',
            fullDateLabel: 'Jun 10, 2025 - Apr 14, 2026',
            locationLabel: 'Rio de Janeiro, RJ',
            brandMonogram: 'AF',
            accent: _roseColor,
          ),
          _EmploymentLinkRecord(
            periodLabel: 'Jan 2023\n- May 2025',
            companyName: 'Atlas Portaria e Servicos',
            roleTitle: 'Coverage Analyst',
            fullDateLabel: 'Jan 09, 2023 - May 30, 2025',
            locationLabel: 'Niteroi, RJ',
            brandMonogram: 'AT',
            accent: _amberColor,
          ),
        ],
      );
    case 'pes_01hpes0000000000000003':
      return const _PersonProfileData(
        roleTitle: 'Talent Mobility Analyst',
        statusLabel: 'Historical Link',
        statusColor: _amberColor,
        profileFields: [
          _PersonInfoField(
            icon: Icons.mail_outline_rounded,
            label: 'Email',
            value: 'carla.mendes@pariflow.com.br',
          ),
          _PersonInfoField(
            icon: Icons.call_outlined,
            label: 'Phone',
            value: '+55 (31) 98831-9120',
          ),
          _PersonInfoField(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: 'Belo Horizonte, MG',
          ),
          _PersonInfoField(
            icon: Icons.link_rounded,
            label: 'LinkedIn',
            value: 'linkedin.com/in/carla-mendes',
          ),
          _PersonInfoField(
            icon: Icons.badge_outlined,
            label: 'Employee ID',
            value: 'PFP-05410',
          ),
          _PersonInfoField(
            icon: Icons.cake_outlined,
            label: 'Date of Birth',
            value: 'Jul 21, 1990 (35)',
          ),
          _PersonInfoField(
            icon: Icons.public_outlined,
            label: 'Nationality',
            value: 'Brazilian',
          ),
          _PersonInfoField(
            icon: Icons.verified_user_outlined,
            label: 'Work Authorization',
            value: 'Authorized to work in Brazil',
          ),
        ],
        managerName: 'Camila Prado',
        managerRole: 'Mobility Program Manager',
        teamLabel: 'People Mobility',
        departmentLabel: 'People Operations',
        timelineSummary: 'Timeline of Carla current and past company links.',
        employmentLinks: [
          _EmploymentLinkRecord(
            periodLabel: 'Feb 2026\n- Present',
            companyName: 'PariFlow Servicos Ltda',
            roleTitle: 'Talent Mobility Analyst',
            fullDateLabel: 'Feb 03, 2026 - Present',
            locationLabel: 'Belo Horizonte, MG',
            brandMonogram: 'PF',
            accent: _tealColor,
            isCurrent: true,
          ),
          _EmploymentLinkRecord(
            periodLabel: 'May 2024\n- Jan 2026',
            companyName: 'Orbe Seguranca',
            roleTitle: 'Transition Coordinator',
            fullDateLabel: 'May 06, 2024 - Jan 24, 2026',
            locationLabel: 'Contagem, MG',
            brandMonogram: 'OS',
            accent: _slateColor,
          ),
          _EmploymentLinkRecord(
            periodLabel: 'Mar 2022\n- Apr 2024',
            companyName: 'Nova Horizonte Apoio Operacional',
            roleTitle: 'People Analyst',
            fullDateLabel: 'Mar 14, 2022 - Apr 30, 2024',
            locationLabel: 'Belo Horizonte, MG',
            brandMonogram: 'NH',
            accent: _amberColor,
          ),
        ],
      );
    default:
      if (item.publicId.startsWith('employee_')) {
        final node = _networkGraphContractPreview.nodeByPublicId(item.publicId);
        if (node != null) {
          return _visualNetworkPersonProfile(node, item);
        }
      }
      return _generatedPersonProfile(item);
  }
}

_PersonProfileData _visualNetworkPersonProfile(
  _NetworkGraphNode node,
  _EntityItem item,
) {
  final extras = node.detailSnapshot.extras;
  final department = '${extras['department'] ?? 'Operations'}';
  final manager = '${extras['manager'] ?? 'Team Lead'}';
  final location = '${extras['location'] ?? 'Austin, Texas, USA'}';
  final employeeId = '${extras['employeeId'] ?? item.publicId}';
  final email =
      '${extras['email'] ?? _emailFromName(item.title, domain: 'aurora.com')}';
  final phone = '${extras['phone'] ?? '+1 (555) 201-4400'}';
  final linkedIn = _linkedInFromName(item.title);
  final roleTitle = node.subtitle;
  final contract =
      '${extras['contract'] ?? (node.badges.isEmpty ? 'Active Contract' : node.badges.first)}';
  final clientCompany = '${extras['clientCompany'] ?? 'Client Portfolio'}';

  return _PersonProfileData(
    roleTitle: roleTitle,
    statusLabel: '${extras['statusLabel'] ?? _titleCase(node.status)}',
    statusColor: node.status == 'active' ? _tealColor : _amberColor,
    profileFields: [
      _PersonInfoField(
        icon: Icons.mail_outline_rounded,
        label: 'Email',
        value: email,
      ),
      _PersonInfoField(icon: Icons.call_outlined, label: 'Phone', value: phone),
      _PersonInfoField(
        icon: Icons.location_on_outlined,
        label: 'Location',
        value: location,
      ),
      _PersonInfoField(
        icon: Icons.link_rounded,
        label: 'LinkedIn',
        value: linkedIn,
      ),
      _PersonInfoField(
        icon: Icons.badge_outlined,
        label: 'Employee ID',
        value: employeeId,
      ),
      _PersonInfoField(
        icon: Icons.cake_outlined,
        label: 'Date of Birth',
        value: _birthDateForSeed(item.publicId, usFormat: true),
      ),
      const _PersonInfoField(
        icon: Icons.public_outlined,
        label: 'Nationality',
        value: 'American',
      ),
      const _PersonInfoField(
        icon: Icons.verified_user_outlined,
        label: 'Work Authorization',
        value: 'Authorized to work in the USA',
      ),
    ],
    managerName: manager,
    managerRole: _managerRoleForDepartment(department),
    teamLabel: '$clientCompany Delivery',
    departmentLabel: department,
    timelineSummary:
        'Timeline of ${item.title.split(' ').first} current and past contracts.',
    employmentLinks: _visualNetworkEmploymentLinks(node, contract, location),
  );
}

List<_EmploymentLinkRecord> _visualNetworkEmploymentLinks(
  _NetworkGraphNode node,
  String contract,
  String location,
) {
  switch (node.publicId) {
    case 'employee_jessica_lee':
      return const [
        _EmploymentLinkRecord(
          periodLabel: 'Mar 2021\n- Present',
          companyName: 'Summit Retail LLC',
          roleTitle: 'Project Manager',
          fullDateLabel: 'Mar 04, 2021 - Present',
          locationLabel: 'Seattle, WA',
          brandMonogram: 'SR',
          accent: _tealColor,
          isCurrent: true,
        ),
        _EmploymentLinkRecord(
          periodLabel: 'Jan 2018\n- Feb 2021',
          companyName: 'North Harbor Commerce',
          roleTitle: 'Operations Specialist',
          fullDateLabel: 'Jan 08, 2018 - Feb 26, 2021',
          locationLabel: 'Portland, OR',
          brandMonogram: 'NH',
          accent: _slateColor,
        ),
      ];
    case 'employee_michael_chen':
      return const [
        _EmploymentLinkRecord(
          periodLabel: 'Jul 2022\n- Present',
          companyName: 'Summit Solutions Inc.',
          roleTitle: 'IT Specialist',
          fullDateLabel: 'Jul 18, 2022 - Present',
          locationLabel: 'Austin, TX',
          brandMonogram: 'SS',
          accent: _tealColor,
          isCurrent: true,
        ),
        _EmploymentLinkRecord(
          periodLabel: 'May 2019\n- Jun 2022',
          companyName: 'BlueStack Systems',
          roleTitle: 'Infrastructure Analyst',
          fullDateLabel: 'May 06, 2019 - Jun 30, 2022',
          locationLabel: 'Dallas, TX',
          brandMonogram: 'BS',
          accent: _slateColor,
        ),
      ];
    case 'employee_sarah_johnson':
      return const [
        _EmploymentLinkRecord(
          periodLabel: 'Jan 2022\n- Present',
          companyName: 'Pioneer Services LLC',
          roleTitle: 'Senior Analyst',
          fullDateLabel: 'Jan 15, 2022 - Present',
          locationLabel: 'Chicago, IL',
          brandMonogram: 'PS',
          accent: _tealColor,
          isCurrent: true,
        ),
        _EmploymentLinkRecord(
          periodLabel: 'Jun 2019\n- Jul 2022',
          companyName: 'Summit Solutions Inc.',
          roleTitle: 'Consulting Analyst',
          fullDateLabel: 'Jun 10, 2019 - Jul 31, 2022',
          locationLabel: 'Austin, TX',
          brandMonogram: 'SS',
          accent: _amberColor,
        ),
        _EmploymentLinkRecord(
          periodLabel: 'Jan 2016\n- May 2019',
          companyName: 'NextWave Digital',
          roleTitle: 'Associate Analyst',
          fullDateLabel: 'Jan 04, 2016 - May 31, 2019',
          locationLabel: 'Austin, TX',
          brandMonogram: 'ND',
          accent: _slateColor,
        ),
        _EmploymentLinkRecord(
          periodLabel: 'Jun 2013\n- Dec 2015',
          companyName: 'BlueStone Apps',
          roleTitle: 'Product Analyst',
          fullDateLabel: 'Jun 03, 2013 - Dec 18, 2015',
          locationLabel: 'Austin, TX',
          brandMonogram: 'BA',
          accent: _roseColor,
        ),
      ];
    case 'employee_david_williams':
      return const [
        _EmploymentLinkRecord(
          periodLabel: 'Nov 2020\n- Present',
          companyName: 'Pioneer Services LLC',
          roleTitle: 'Account Manager',
          fullDateLabel: 'Nov 02, 2020 - Present',
          locationLabel: 'Chicago, IL',
          brandMonogram: 'PS',
          accent: _tealColor,
          isCurrent: true,
        ),
        _EmploymentLinkRecord(
          periodLabel: 'Apr 2017\n- Oct 2020',
          companyName: 'Redwood Client Services',
          roleTitle: 'Client Success Lead',
          fullDateLabel: 'Apr 17, 2017 - Oct 21, 2020',
          locationLabel: 'Milwaukee, WI',
          brandMonogram: 'RC',
          accent: _slateColor,
        ),
      ];
    case 'employee_emily_davis':
      return const [
        _EmploymentLinkRecord(
          periodLabel: 'May 2023\n- Present',
          companyName: 'Pioneer Tech LLC',
          roleTitle: 'Operations Lead',
          fullDateLabel: 'May 10, 2023 - Present',
          locationLabel: 'Denver, CO',
          brandMonogram: 'PT',
          accent: _tealColor,
          isCurrent: true,
        ),
        _EmploymentLinkRecord(
          periodLabel: 'Aug 2019\n- Apr 2023',
          companyName: 'FrontRange Logistics',
          roleTitle: 'Regional Coordinator',
          fullDateLabel: 'Aug 05, 2019 - Apr 28, 2023',
          locationLabel: 'Denver, CO',
          brandMonogram: 'FL',
          accent: _amberColor,
        ),
      ];
    default:
      return [
        _EmploymentLinkRecord(
          periodLabel: 'Current',
          companyName: contract,
          roleTitle: node.subtitle,
          fullDateLabel:
              '${node.detailSnapshot.extras['startDate'] ?? 'Current'} - Present',
          locationLabel: location,
          brandMonogram: _companyMonogram(contract),
          accent: _tealColor,
          isCurrent: true,
        ),
      ];
  }
}

_PersonProfileData _generatedPersonProfile(_EntityItem item) {
  final seed = _stableSeed(item.publicId);
  final currentCompany =
      _relationValue(item.relations, 'Prestadora atual') ??
      _relationValue(item.relations, 'Prestadora anterior') ??
      'PariFlow Servicos Ltda';
  final previousCompany = _relationValue(item.relations, 'Passagem anterior');
  final contract =
      _relationValue(item.relations, 'Contrato atual') ??
      _relationValue(item.relations, 'Contrato relacionado') ??
      'Contrato sem rotulo';
  final client =
      _relationValue(item.relations, 'Cliente conectado') ??
      'Cliente nao informado';
  final location = _locationForClient(client);
  final roleTitle = _generatedRoleTitle(seed);
  final managerName = _managerNameForSeed(seed);
  final department = _departmentForRole(roleTitle);
  final team = '${client.split(' ').first} Operations';
  final currentStartYear = 2023 + (seed % 3);
  final currentMonth = 1 + (seed % 10);
  final previousEndYear = currentStartYear - 1;

  final links = <_EmploymentLinkRecord>[
    _EmploymentLinkRecord(
      periodLabel: item.status == 'desligado recente'
          ? '${_shortMonth(currentMonth)} $currentStartYear\n- Apr 2026'
          : '${_shortMonth(currentMonth)} $currentStartYear\n- Present',
      companyName: currentCompany,
      roleTitle: roleTitle,
      fullDateLabel: item.status == 'desligado recente'
          ? '${_fullMonth(currentMonth)} ${10 + (seed % 18)}, $currentStartYear - Apr 14, 2026'
          : '${_fullMonth(currentMonth)} ${10 + (seed % 18)}, $currentStartYear - Present',
      locationLabel: location,
      brandMonogram: _companyMonogram(currentCompany),
      accent: item.status == 'desligado recente' ? _roseColor : _tealColor,
      isCurrent: item.status != 'desligado recente',
    ),
  ];

  if (previousCompany != null) {
    links.add(
      _EmploymentLinkRecord(
        periodLabel: 'Jan ${previousEndYear - 2}\n- Dec $previousEndYear',
        companyName: previousCompany,
        roleTitle: _previousRoleTitle(seed),
        fullDateLabel:
            'Jan 08, ${previousEndYear - 2} - Dec 15, $previousEndYear',
        locationLabel: location,
        brandMonogram: _companyMonogram(previousCompany),
        accent: _amberColor,
      ),
    );
  }

  links.add(
    _EmploymentLinkRecord(
      periodLabel: 'Feb ${previousEndYear - 5}\n- Dec ${previousEndYear - 3}',
      companyName: 'BaseLine Services',
      roleTitle: _earlyCareerRoleTitle(seed),
      fullDateLabel:
          'Feb 05, ${previousEndYear - 5} - Dec 20, ${previousEndYear - 3}',
      locationLabel: location,
      brandMonogram: 'BS',
      accent: _slateColor,
    ),
  );

  return _PersonProfileData(
    roleTitle: roleTitle,
    statusLabel: switch (item.status) {
      'ativo' => 'Active',
      'desligado recente' => 'Dismissed',
      _ => 'Historical Link',
    },
    statusColor: switch (item.status) {
      'ativo' => _tealColor,
      'desligado recente' => _roseColor,
      _ => _amberColor,
    },
    profileFields: [
      _PersonInfoField(
        icon: Icons.mail_outline_rounded,
        label: 'Email',
        value: _emailFromName(item.title, domain: 'pariflow.com.br'),
      ),
      _PersonInfoField(
        icon: Icons.call_outlined,
        label: 'Phone',
        value: _phoneForSeed(seed),
      ),
      _PersonInfoField(
        icon: Icons.location_on_outlined,
        label: 'Location',
        value: location,
      ),
      _PersonInfoField(
        icon: Icons.link_rounded,
        label: 'LinkedIn',
        value: _linkedInFromName(item.title),
      ),
      _PersonInfoField(
        icon: Icons.badge_outlined,
        label: 'Employee ID',
        value: 'PFP-${(seed % 90000 + 10000).toString()}',
      ),
      _PersonInfoField(
        icon: Icons.cake_outlined,
        label: 'Date of Birth',
        value: _birthDateForSeed(item.publicId),
      ),
      const _PersonInfoField(
        icon: Icons.public_outlined,
        label: 'Nationality',
        value: 'Brazilian',
      ),
      const _PersonInfoField(
        icon: Icons.verified_user_outlined,
        label: 'Work Authorization',
        value: 'Authorized to work in Brazil',
      ),
    ],
    managerName: managerName,
    managerRole: _managerRoleForDepartment(department),
    teamLabel: team,
    departmentLabel: department,
    timelineSummary:
        'Timeline of current and past contracts linked to this employee.',
    employmentLinks: links,
  );
}

String? _relationValue(List<String> relations, String prefix) {
  for (final relation in relations) {
    final marker = '$prefix: ';
    if (relation.startsWith(marker)) {
      return relation.substring(marker.length).trim();
    }
  }
  return null;
}

String _linkedInFromName(String name) {
  final slug = name.toLowerCase().replaceAll(' ', '-');
  return 'linkedin.com/in/$slug';
}

String _emailFromName(String name, {required String domain}) {
  final normalized = name.toLowerCase().replaceAll(' ', '.');
  return '$normalized@$domain';
}

String _managerRoleForDepartment(String department) {
  final lower = department.toLowerCase();
  if (lower.contains('operation')) {
    return 'Operations Director';
  }
  if (lower.contains('analytic')) {
    return 'Analytics Manager';
  }
  if (lower.contains('account')) {
    return 'Client Portfolio Director';
  }
  if (lower.contains('infrastructure')) {
    return 'Infrastructure Manager';
  }
  return 'Department Lead';
}

String _generatedRoleTitle(int seed) {
  const roles = [
    'Operations Analyst',
    'Site Supervisor',
    'People Operations Coordinator',
    'Field Support Specialist',
    'Contract Mobility Analyst',
    'Client Operations Lead',
  ];
  return roles[seed % roles.length];
}

String _previousRoleTitle(int seed) {
  const roles = [
    'Operations Coordinator',
    'Coverage Analyst',
    'Regional Support Lead',
    'Shift Supervisor',
  ];
  return roles[seed % roles.length];
}

String _earlyCareerRoleTitle(int seed) {
  const roles = [
    'Administrative Assistant',
    'Junior Analyst',
    'Operations Assistant',
    'Support Coordinator',
  ];
  return roles[seed % roles.length];
}

String _departmentForRole(String role) {
  final lower = role.toLowerCase();
  if (lower.contains('people')) {
    return 'People Operations';
  }
  if (lower.contains('client')) {
    return 'Client Services';
  }
  if (lower.contains('contract')) {
    return 'Contract Management';
  }
  return 'Field Operations';
}

String _managerNameForSeed(int seed) {
  const names = [
    'Sarah Mitchell',
    'Camila Prado',
    'Diego Costa',
    'Marta Nogueira',
    'Lucas Lima',
  ];
  return names[seed % names.length];
}

int _stableSeed(String value) {
  return value.runes.fold<int>(0, (total, rune) => total + rune);
}

String _phoneForSeed(int seed) {
  final a = 10 + (seed % 80);
  final b = 1000 + (seed % 8000);
  final c = 1000 + ((seed * 3) % 8000);
  return '+55 ($a) 9$b-$c';
}

String _birthDateForSeed(String seedValue, {bool usFormat = false}) {
  final seed = _stableSeed(seedValue);
  final month = 1 + (seed % 12);
  final day = 1 + (seed % 27);
  final year = 1984 + (seed % 13);
  final age = 2026 - year;
  if (usFormat) {
    return '${_fullMonth(month)} $day, $year ($age)';
  }
  return '${_fullMonth(month)} $day, $year ($age)';
}

String _locationForClient(String client) {
  return switch (client) {
    'Condominio Bela Vista' => 'Sao Paulo, SP',
    'Reserva Mirante' => 'Rio de Janeiro, RJ',
    'Torre Nascente' => 'Campinas, SP',
    'Parque das Flores' => 'Curitiba, PR',
    'Jardim Atlantico' => 'Belo Horizonte, MG',
    'Residencial Aurora' => 'Santos, SP',
    _ => 'Sao Paulo, SP',
  };
}

String _companyMonogram(String company) {
  final words = company
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();
  if (words.length == 1) {
    return words.first.substring(0, min(2, words.first.length)).toUpperCase();
  }
  return '${words.first[0]}${words[1][0]}'.toUpperCase();
}

String _shortMonth(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return months[month - 1];
}

String _fullMonth(int month) {
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
  return months[month - 1];
}

class _PeopleBatchSpec {
  const _PeopleBatchSpec({
    required this.key,
    required this.company,
    required this.contract,
    required this.client,
    required this.operation,
    required this.previousCompany,
    required this.count,
    required this.activeColor,
  });

  final String key;
  final String company;
  final String contract;
  final String client;
  final String operation;
  final String previousCompany;
  final int count;
  final Color activeColor;
}

enum _MockPersonMode { active, history, dismissed }

const _generatedPeopleBatches = [
  _PeopleBatchSpec(
    key: 'pariflow',
    company: 'PariFlow Servicos Ltda',
    contract: 'CTR-PORT-2026-001',
    client: 'Condominio Bela Vista',
    operation: 'portaria e controle de acesso',
    previousCompany: 'Orbe Seguranca',
    count: 14,
    activeColor: _tealColor,
  ),
  _PeopleBatchSpec(
    key: 'alpha',
    company: 'Alpha Facilities',
    contract: 'CTR-LIMP-2026-007',
    client: 'Reserva Mirante',
    operation: 'limpeza tecnica',
    previousCompany: 'Atlas Portaria e Servicos',
    count: 11,
    activeColor: _amberColor,
  ),
  _PeopleBatchSpec(
    key: 'orbe',
    company: 'Orbe Seguranca',
    contract: 'CTR-VIG-2026-004',
    client: 'Torre Nascente',
    operation: 'vigilancia patrimonial',
    previousCompany: 'Prisma Zeladoria Integrada',
    count: 8,
    activeColor: _slateColor,
  ),
  _PeopleBatchSpec(
    key: 'nova',
    company: 'Nova Horizonte Apoio Operacional',
    contract: 'CTR-APO-2026-011',
    client: 'Parque das Flores',
    operation: 'apoio operacional e recepcao',
    previousCompany: 'PariFlow Servicos Ltda',
    count: 12,
    activeColor: _tealColor,
  ),
  _PeopleBatchSpec(
    key: 'prisma',
    company: 'Prisma Zeladoria Integrada',
    contract: 'CTR-ZEL-2026-005',
    client: 'Jardim Atlantico',
    operation: 'zeladoria e manutencao leve',
    previousCompany: 'Alpha Facilities',
    count: 10,
    activeColor: _slateColor,
  ),
  _PeopleBatchSpec(
    key: 'atlas',
    company: 'Atlas Portaria e Servicos',
    contract: 'CTR-ATL-2026-009',
    client: 'Residencial Aurora',
    operation: 'portaria residencial 24h',
    previousCompany: 'Nova Horizonte Apoio Operacional',
    count: 10,
    activeColor: _amberColor,
  ),
];

const _generatedFirstNames = [
  'Joao',
  'Mariana',
  'Pedro',
  'Larissa',
  'Rafael',
  'Bianca',
  'Thiago',
  'Juliana',
  'Diego',
  'Patricia',
  'Caio',
];

const _generatedMiddleNames = [
  'Silva',
  'Souza',
  'Oliveira',
  'Costa',
  'Lima',
  'Pereira',
  'Almeida',
  'Ferreira',
  'Ribeiro',
  'Gomes',
  'Martins',
  'Barbosa',
  'Cardoso',
];

const _generatedLastNames = [
  'Santos',
  'Rocha',
  'Melo',
  'Nogueira',
  'Batista',
  'Moura',
  'Araujo',
  'Campos',
  'Teixeira',
  'Freitas',
  'Rezende',
  'Fonseca',
  'Cavalcante',
  'Monteiro',
  'Assis',
  'Farias',
  'Vieira',
];

List<_EntityItem> _buildGeneratedPeopleItems() {
  final items = <_EntityItem>[];
  var sequence = 4;

  for (final batch in _generatedPeopleBatches) {
    for (var localIndex = 0; localIndex < batch.count; localIndex++) {
      final globalIndex = sequence - 4;
      final mode = _mockModeForBatch(batch.key, localIndex);
      final publicId = 'pes_sim_${sequence.toString().padLeft(4, '0')}';
      items.add(
        _EntityItem(
          publicId: publicId,
          title: _generatedPersonName(globalIndex),
          subtitle: _generatedSubtitle(batch, mode),
          meta: _generatedMeta(batch, mode, localIndex),
          status: _generatedStatusLabel(mode),
          icon: _generatedIcon(mode),
          color: _generatedColor(batch, mode),
          detailSummary: _generatedDetailSummary(batch, mode),
          relations: _generatedRelations(batch, mode),
          attachments: _generatedAttachments(batch, localIndex, publicId),
          sensitiveNotes: _generatedNotes(batch, localIndex),
        ),
      );
      sequence++;
    }
  }

  return items;
}

String _generatedPersonName(int index) {
  final first = _generatedFirstNames[index % _generatedFirstNames.length];
  final middle =
      _generatedMiddleNames[(index * 3) % _generatedMiddleNames.length];
  final last = _generatedLastNames[(index * 5) % _generatedLastNames.length];
  return '$first $middle $last';
}

_MockPersonMode _mockModeForBatch(String key, int localIndex) {
  switch (key) {
    case 'alpha':
      if (localIndex % 5 == 0) {
        return _MockPersonMode.dismissed;
      }
      if (localIndex % 4 == 0) {
        return _MockPersonMode.history;
      }
      return _MockPersonMode.active;
    case 'atlas':
      if (localIndex == 2 || localIndex == 7) {
        return _MockPersonMode.dismissed;
      }
      if (localIndex.isOdd) {
        return _MockPersonMode.history;
      }
      return _MockPersonMode.active;
    case 'nova':
      if (localIndex == 3 || localIndex == 9) {
        return _MockPersonMode.dismissed;
      }
      if (localIndex % 3 == 0) {
        return _MockPersonMode.history;
      }
      return _MockPersonMode.active;
    case 'prisma':
      if (localIndex == 4) {
        return _MockPersonMode.dismissed;
      }
      if (localIndex % 4 == 1) {
        return _MockPersonMode.history;
      }
      return _MockPersonMode.active;
    case 'orbe':
      if (localIndex == 5) {
        return _MockPersonMode.history;
      }
      return _MockPersonMode.active;
    case 'pariflow':
    default:
      if (localIndex == 6 || localIndex == 12) {
        return _MockPersonMode.dismissed;
      }
      if (localIndex % 4 == 1) {
        return _MockPersonMode.history;
      }
      return _MockPersonMode.active;
  }
}

String _generatedStatusLabel(_MockPersonMode mode) => switch (mode) {
  _MockPersonMode.active => 'ativo',
  _MockPersonMode.history => 'historico ampliado',
  _MockPersonMode.dismissed => 'desligado recente',
};

IconData _generatedIcon(_MockPersonMode mode) => switch (mode) {
  _MockPersonMode.active => Icons.badge_outlined,
  _MockPersonMode.history => Icons.compare_arrows_outlined,
  _MockPersonMode.dismissed => Icons.person_off_outlined,
};

Color _generatedColor(_PeopleBatchSpec batch, _MockPersonMode mode) =>
    switch (mode) {
      _MockPersonMode.active => batch.activeColor,
      _MockPersonMode.history => _amberColor,
      _MockPersonMode.dismissed => _roseColor,
    };

String _generatedSubtitle(
  _PeopleBatchSpec batch,
  _MockPersonMode mode,
) => switch (mode) {
  _MockPersonMode.active => 'Pessoa em operacao ativa de ${batch.operation}.',
  _MockPersonMode.history =>
    'Pessoa com passagens entre postos e leitura historica mais rica.',
  _MockPersonMode.dismissed =>
    'Pessoa desligada recentemente e ainda relevante para o contexto da equipe.',
};

String _generatedMeta(
  _PeopleBatchSpec batch,
  _MockPersonMode mode,
  int localIndex,
) => switch (mode) {
  _MockPersonMode.active =>
    'ativo | ${(localIndex % 3) + 1} passagem${(localIndex % 3) == 0 ? '' : 'ens'} | ${batch.company}',
  _MockPersonMode.history =>
    'ativo | ${2 + (localIndex % 2)} passagens | transferencia recente em ${batch.operation}',
  _MockPersonMode.dismissed =>
    'desligado ha ${8 + (localIndex * 3)} dias | ${batch.contract} | retorno em analise',
};

String _generatedDetailSummary(_PeopleBatchSpec batch, _MockPersonMode mode) {
  switch (mode) {
    case _MockPersonMode.active:
      return 'A ficha ajuda a localizar rapidamente a pessoa no contexto de ${batch.operation}, sem quebrar a leitura entre empresa, contrato e historico.';
    case _MockPersonMode.history:
      return 'Esse caso precisa de uma leitura um pouco mais larga porque a pessoa ja passou por outros postos, equipes ou empresas e ainda influencia o quadro atual.';
    case _MockPersonMode.dismissed:
      return 'O detalhe continua relevante depois do desligamento porque o historico recente impacta cobertura de posto, risco operacional e possivel recontratacao.';
  }
}

List<String> _generatedRelations(
  _PeopleBatchSpec batch,
  _MockPersonMode mode,
) => switch (mode) {
  _MockPersonMode.active => [
    'Prestadora atual: ${batch.company}',
    'Contrato atual: ${batch.contract}',
    'Cliente conectado: ${batch.client}',
  ],
  _MockPersonMode.history => [
    'Prestadora atual: ${batch.company}',
    'Passagem anterior: ${batch.previousCompany}',
    'Cliente conectado: ${batch.client}',
  ],
  _MockPersonMode.dismissed => [
    'Prestadora anterior: ${batch.company}',
    'Contrato relacionado: ${batch.contract}',
    'Cliente conectado: ${batch.client}',
  ],
};

List<_AttachmentRecord> _generatedAttachments(
  _PeopleBatchSpec batch,
  int localIndex,
  String personPublicId,
) {
  if (localIndex != 0) {
    return const [];
  }

  switch (batch.key) {
    case 'alpha':
      return [
        _AttachmentRecord(
          publicId: 'anx_$personPublicId',
          title: 'Parecer interno de cobertura',
          classification: _AttachmentClassification.sensitiveAttachment,
          summary:
              'Arquivo protegido com leitura restrita para acompanhamento de rotacao no posto.',
          status: 'restrito',
          updatedAtLabel: 'atualizado em 04/2026',
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceMarta,
            allowedGroups: [_CollaboratorAudienceGroup.board],
            allowedPeople: [_audienceCamila],
          ),
          canDownload: false,
        ),
      ];
    case 'atlas':
      return [
        _AttachmentRecord(
          publicId: 'anx_$personPublicId',
          title: 'Resumo de treinamento de lideranca',
          classification: _AttachmentClassification.supportingReference,
          summary:
              'Referencia de apoio para acompanhar liderancas em implantacao de posto.',
          status: 'ativo',
          updatedAtLabel: 'atualizado em 04/2026',
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceCamila,
            allowedGroups: [_CollaboratorAudienceGroup.supervision],
            allowedPeople: [_audienceDiego],
          ),
        ),
      ];
    default:
      return [
        _AttachmentRecord(
          publicId: 'anx_$personPublicId',
          title: 'Resumo operacional do vinculo',
          classification: _AttachmentClassification.supportingReference,
          summary:
              'Referencia curta para acelerar a leitura do contexto atual do colaborador.',
          status: 'ativo',
          updatedAtLabel: 'atualizado em 04/2026',
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceLucas,
            allowedGroups: [_CollaboratorAudienceGroup.supervision],
          ),
        ),
      ];
  }
}

List<_SensitiveNoteTag> _generatedNotes(
  _PeopleBatchSpec batch,
  int localIndex,
) {
  if (localIndex != 1) {
    return const [];
  }

  switch (batch.key) {
    case 'pariflow':
      return [
        _SensitiveNoteTag(
          label: 'adapta rapido a troca de posto',
          note:
              'Observacao operacional recorrente da supervisao. Ajuda na alocacao, mas nao substitui avaliacao formal.',
          classification: _SensitiveNoteClassification.routineContext,
          color: _tealColor,
          sortOrder: 1,
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceMarta,
            allowedGroups: [_CollaboratorAudienceGroup.supervision],
            allowedPeople: [_audienceDiego],
          ),
        ),
      ];
    case 'alpha':
      return [
        _SensitiveNoteTag(
          label: 'precisa de reforco no primeiro turno',
          note:
              'Ajuste fino de operacao observado nas ultimas semanas. Conteudo de uso interno para distribuicao de escala.',
          classification: _SensitiveNoteClassification.behavioralSignal,
          color: _amberColor,
          sortOrder: 1,
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceCamila,
            allowedGroups: [_CollaboratorAudienceGroup.board],
            allowedPeople: [_audienceMarta],
          ),
        ),
      ];
    case 'orbe':
      return [
        _SensitiveNoteTag(
          label: 'boa leitura de ronda noturna',
          note:
              'Registro positivo de rotina que pode ajudar a definir cobertura de turnos mais sensiveis.',
          classification: _SensitiveNoteClassification.trainingOrSkill,
          color: _slateColor,
          sortOrder: 1,
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceLucas,
            allowedGroups: [_CollaboratorAudienceGroup.supervision],
          ),
        ),
      ];
    case 'nova':
      return [
        _SensitiveNoteTag(
          label: 'familia pede folga em agenda escolar',
          note:
              'Contexto familiar relevante para combinar escala em onboarding sem criar desgaste desnecessario.',
          classification: _SensitiveNoteClassification.familyContext,
          color: _roseColor,
          sortOrder: 1,
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceMarta,
            allowedPeople: [_audienceDiego],
          ),
        ),
      ];
    case 'prisma':
      return [
        _SensitiveNoteTag(
          label: 'circula bem entre torres',
          note:
              'Observacao de rotina sobre multiunidade. Ajuda no remanejamento rapido entre frentes do mesmo contrato.',
          classification: _SensitiveNoteClassification.routineContext,
          color: _amberColor,
          sortOrder: 1,
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceCamila,
            allowedGroups: [_CollaboratorAudienceGroup.supervision],
            allowedPeople: [_audienceLucas],
          ),
        ),
      ];
    case 'atlas':
      return [
        _SensitiveNoteTag(
          label: 'perfil bom para lideranca em implantacao',
          note:
              'Sinal interno para apoiar escolha de lideranca de turno em operacao ainda nova.',
          classification: _SensitiveNoteClassification.operationalRisk,
          color: _roseColor,
          sortOrder: 1,
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceDiego,
            allowedGroups: [_CollaboratorAudienceGroup.board],
            allowedPeople: [_audienceMarta],
          ),
        ),
      ];
    default:
      return const [];
  }
}
