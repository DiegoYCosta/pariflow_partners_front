part of '../../../app/app.dart';

const _clientCompaniesWorkspaceData = _EntityWorkspaceData(
  title: 'Empresas clientes com contexto proprio',
  subtitle:
      'Cliente nao fica mais escondido dentro de prestadoras e contratos. A carteira passa a ter leitura propria, com transicoes, multi-prestadora e memoria operacional protegida.',
  searchHint: 'buscar por nome da carteira, documento ou unidade',
  listHint:
      'O detalhe do cliente precisa cruzar prestadoras, contratos, pessoas impactadas e risco operacional sem obrigar a abrir a teia inteira.',
  productionHint:
      'Primeiro passo real: entregar lista de clientes com detalhe rico, preservando a diferenca entre cliente, prestadora e contrato no mesmo payload.',
  integrationFocus: [
    'carteira de clientes',
    'multi-prestadora',
    'contratos relevantes',
    'contexto protegido',
  ],
  filters: ['ativos', 'multi-prestadora', 'com transicao recente'],
  accent: _slateColor,
  items: [
    _EntityItem(
      publicId: 'cli_01hcli0000000000000001',
      title: 'Condominio Bela Vista',
      subtitle:
          'Carteira operacional com seguranca ativa e historico recente de troca de cobertura.',
      meta: '1 prestadora ativa | 1 historica | 2 contratos relevantes',
      status: 'ativo',
      icon: Icons.business_outlined,
      color: _slateColor,
      detailSummary:
          'A leitura do cliente precisa explicitar quem atende hoje, quem atendeu antes e como isso repercute em contratos e quadro alocado.',
      relations: [
        'Prestadora ativa: PariFlow Servicos Ltda',
        'Prestadora historica: Alpha Facilities',
        'Contrato em foco: CTR-PORT-2026-001',
      ],
      attachments: [
        _AttachmentRecord(
          publicId: 'anx_01hcliformal000000000001',
          title: 'Escopo cadastral da operacao',
          classification: _AttachmentClassification.formalDocument,
          summary:
              'Documento usado para abrir rapidamente a leitura contratual e operacional da carteira.',
          status: 'vigente',
          updatedAtLabel: 'atualizado em 04/2026',
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceDiego,
            allowedGroups: [
              _CollaboratorAudienceGroup.board,
              _CollaboratorAudienceGroup.supervision,
            ],
          ),
        ),
      ],
      sensitiveNotes: [
        _SensitiveNoteTag(
          label: 'troca de cobertura exige aviso previo',
          note:
              'Sempre que houver mudanca de lideranca de posto, o cliente pede aviso antes do fechamento do dia anterior. Mantem a operacao mais estavel.',
          classification: _SensitiveNoteClassification.routineContext,
          color: _amberColor,
          sortOrder: 1,
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceMarta,
            allowedGroups: [_CollaboratorAudienceGroup.supervision],
            allowedPeople: [_audienceDiego],
          ),
        ),
      ],
    ),
    _EntityItem(
      publicId: 'cli_01hcli0000000000000002',
      title: 'Reserva Mirante',
      subtitle:
          'Cliente com rotacao alta e risco operacional concentrado na limpeza tecnica.',
      meta: '1 prestadora ativa | 6 desligamentos recentes | risco contratual',
      status: 'atencao',
      icon: Icons.business_outlined,
      color: _roseColor,
      detailSummary:
          'Aqui o cliente vira centro de decisao: nao basta olhar a prestadora, porque a dor real esta no impacto da rotacao sobre a carteira.',
      relations: [
        'Prestadora ativa: Alpha Facilities',
        'Contrato em foco: CTR-LIMP-2026-007',
        'Pessoas impactadas no recorte: 19',
      ],
      attachments: [
        _AttachmentRecord(
          publicId: 'anx_01hclisens000000000002',
          title: 'Analise interna de escalada de risco',
          classification: _AttachmentClassification.sensitiveAttachment,
          summary:
              'Arquivo com leitura controlada para quem acompanha risco de rotacao e cobertura de postos.',
          status: 'restrito',
          updatedAtLabel: 'atualizado em 04/2026',
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceCamila,
            allowedGroups: [_CollaboratorAudienceGroup.board],
            allowedPeople: [_audienceMarta],
          ),
          canDownload: false,
        ),
      ],
      sensitiveNotes: [
        _SensitiveNoteTag(
          label: 'cliente reage mal a troca sem contextualizacao',
          note:
              'Mudancas de equipe sem narrativa clara viram ruido comercial rapidamente. A leitura fica restrita a quem negocia ou coordena a conta.',
          classification: _SensitiveNoteClassification.operationalRisk,
          color: _roseColor,
          sortOrder: 1,
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceDiego,
            allowedGroups: [_CollaboratorAudienceGroup.board],
            allowedPeople: [_audienceCamila],
          ),
        ),
      ],
    ),
    _EntityItem(
      publicId: 'cli_01hcli0000000000000003',
      title: 'Torre Nascente',
      subtitle:
          'Cliente com cobertura patrimonial estavel e baixo ruido operacional.',
      meta: '1 prestadora ativa | 1 contrato principal | quadro estavel',
      status: 'estavel',
      icon: Icons.business_outlined,
      color: _tealColor,
      detailSummary:
          'Nem toda carteira precisa gritar urgencia. Este detalhe mostra como ler estabilidade sem perder contexto historico.',
      relations: [
        'Prestadora ativa: Orbe Seguranca',
        'Contrato em foco: CTR-VIG-2026-004',
        'Pessoas impactadas no recorte: 12',
      ],
      attachments: [
        _AttachmentRecord(
          publicId: 'anx_01hcliref000000000003',
          title: 'Referencia de rotina do posto',
          classification: _AttachmentClassification.supportingReference,
          summary:
              'Material de apoio para leitura operacional rapida, sem peso de documento formal.',
          status: 'ativo',
          updatedAtLabel: 'atualizado em 03/2026',
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceLucas,
            allowedGroups: [_CollaboratorAudienceGroup.auxiliary],
            allowedPeople: [_audienceMarta],
          ),
        ),
      ],
    ),
    _EntityItem(
      publicId: 'cli_01hcli0000000000000004',
      title: 'Parque das Flores',
      subtitle:
          'Carteira em expansao com recepcao, apoio operacional e historico cruzado com mais de uma prestadora.',
      meta: '2 prestadoras relevantes | onboarding acelerado | 27 pessoas alocadas',
      status: 'expansao',
      icon: Icons.business_outlined,
      color: _amberColor,
      detailSummary:
          'Cliente novo em expansao exige leitura de implantacao, cobertura e transicao entre prestadoras sem simplificar demais o contexto.',
      relations: [
        'Prestadora ativa: Nova Horizonte Apoio Operacional',
        'Prestadora complementar: Atlas Portaria e Servicos',
        'Contrato em foco: CTR-APO-2026-011',
      ],
      attachments: [
        _AttachmentRecord(
          publicId: 'anx_01hcliformal000000000004',
          title: 'Plano de onboarding da unidade',
          classification: _AttachmentClassification.formalDocument,
          summary:
              'Documento de referencia para implantacao e leitura do inicio da carteira.',
          status: 'vigente',
          updatedAtLabel: 'atualizado em 04/2026',
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceDiego,
            allowedGroups: [_CollaboratorAudienceGroup.board],
            allowedPeople: [_audienceMarta],
          ),
        ),
      ],
      sensitiveNotes: [
        _SensitiveNoteTag(
          label: 'cliente valida lider de turno nominalmente',
          note:
              'Trocas de lideranca precisam ser comunicadas com antecedencia e nomeadas no contato principal. Mantem confianca no comeco da operacao.',
          classification: _SensitiveNoteClassification.routineContext,
          color: _tealColor,
          sortOrder: 1,
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceMarta,
            allowedGroups: [_CollaboratorAudienceGroup.supervision],
          ),
        ),
      ],
    ),
    _EntityItem(
      publicId: 'cli_01hcli0000000000000005',
      title: 'Jardim Atlantico',
      subtitle:
          'Cliente com zeladoria integrada, manutencao leve e pessoas circulando entre unidades.',
      meta: '1 prestadora ativa | 1 prestadora historica | 4 pessoas multiempresa',
      status: 'multiunidade',
      icon: Icons.business_outlined,
      color: _slateColor,
      detailSummary:
          'O cliente deixa explicito quando a mesma pessoa aparece em mais de uma frente. Isso prepara o terreno para a teia nova sem fingir que tudo e arvore.',
      relations: [
        'Prestadora ativa: Prisma Zeladoria Integrada',
        'Prestadora historica: Alpha Facilities',
        'Contrato em foco: CTR-ZEL-2026-005',
      ],
      attachments: [
        _AttachmentRecord(
          publicId: 'anx_01hcliref000000000005',
          title: 'Resumo de circulacao entre torres',
          classification: _AttachmentClassification.supportingReference,
          summary:
              'Referencia operacional de apoio para leitura de pessoas que transitam entre frentes do mesmo cliente.',
          status: 'ativo',
          updatedAtLabel: 'atualizado em 04/2026',
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceCamila,
            allowedGroups: [_CollaboratorAudienceGroup.supervision],
            allowedPeople: [_audienceLucas],
          ),
        ),
      ],
    ),
    _EntityItem(
      publicId: 'cli_01hcli0000000000000006',
      title: 'Estacao Central Corporate',
      subtitle:
          'Cliente com portaria, apoio administrativo e operacao distribuida entre duas frentes de atendimento.',
      meta: '1 prestadora ativa | 1 contrato principal | 10 pessoas no recorte',
      status: 'ativo',
      icon: Icons.business_outlined,
      color: _tealColor,
      detailSummary:
          'A carteira centraliza leitura de atendimento, acesso e retaguarda sem misturar juridico, operacao e quadro humano no mesmo bloco.',
      relations: [
        'Prestadora ativa: Atlas Portaria e Servicos',
        'Prestadora de apoio historica: Nova Horizonte Apoio Operacional',
        'Leitura futura: teia com arestas ativas e historicas',
      ],
      attachments: [
        _AttachmentRecord(
          publicId: 'anx_01hcliformal000000000006',
          title: 'Escopo consolidado de atendimento',
          classification: _AttachmentClassification.formalDocument,
          summary:
              'Documento formal para leitura objetiva de escopo e cobertura da unidade.',
          status: 'vigente',
          updatedAtLabel: 'atualizado em 02/2026',
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceDiego,
            allowedGroups: [
              _CollaboratorAudienceGroup.board,
              _CollaboratorAudienceGroup.supervision,
            ],
          ),
        ),
        _AttachmentRecord(
          publicId: 'anx_01hclisens000000000006',
          title: 'Observacoes comerciais sensiveis',
          classification: _AttachmentClassification.sensitiveAttachment,
          summary:
              'Memoria lateral da carteira usada em renegociacao e calibragem de atendimento.',
          status: 'restrito',
          updatedAtLabel: 'atualizado em 04/2026',
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceDiego,
            allowedGroups: [_CollaboratorAudienceGroup.board],
            allowedPeople: [_audienceCamila],
          ),
          canDownload: false,
        ),
      ],
      sensitiveNotes: [
        _SensitiveNoteTag(
          label: 'diretoria quer contexto antes de renegociar',
          note:
              'Qualquer ajuste comercial mais sensivel precisa ser lido com o historico recente de cobertura e satisfacao do cliente.',
          classification: _SensitiveNoteClassification.operationalRisk,
          color: _amberColor,
          sortOrder: 1,
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceDiego,
            allowedGroups: [_CollaboratorAudienceGroup.board],
          ),
        ),
      ],
    ),
  ],
);
