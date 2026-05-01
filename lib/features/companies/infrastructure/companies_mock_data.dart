part of '../../../app/app.dart';

const _companiesWorkspaceData = _EntityWorkspaceData(
  title: 'Empresas com workspace focado',
  subtitle:
      'Aqui a interface para de tentar mostrar tudo ao mesmo tempo. A consulta empresarial fica limpa, com lista e detalhe no mesmo contexto.',
  searchHint: 'buscar por razao social, fantasia ou documento',
  listHint:
      'A lista fica curta, clicavel e orientada por contexto. O detalhe aparece ao lado sem romper a navegacao.',
  productionHint:
      'Primeiro passo real: listar empresas por API, abrir detalhe autenticado e permitir memoria sensivel protegida sem poluir a consulta principal.',
  integrationFocus: [
    'lista paginada',
    'detalhe autenticado',
    'tags sensiveis',
    'anexos formais',
  ],
  filters: ['ativas', 'com contratos em aberto', 'multiempresa'],
  accent: _tealColor,
  items: [
    _EntityItem(
      publicId: 'epr_01hcmp0000000000000001',
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
      attachments: [
        _AttachmentRecord(
          publicId: 'anx_01hcmpformal000000000001',
          title: 'Contrato social atualizado',
          classification: _AttachmentClassification.formalDocument,
          summary:
              'Arquivo oficial usado para leitura cadastral e conciliacao de dados da prestadora.',
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
        _AttachmentRecord(
          publicId: 'anx_01hcmpsens000000000001',
          title: 'Relato interno de auditoria operacional',
          classification: _AttachmentClassification.sensitiveAttachment,
          summary:
              'Arquivo sensivel com leitura restrita para quem precisa contextualizar risco e recorrencia interna.',
          status: 'restrito',
          updatedAtLabel: 'atualizado em 04/2026',
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceMarta,
            allowedGroups: [_CollaboratorAudienceGroup.board],
            allowedPeople: [_audienceCamila],
          ),
          canDownload: false,
        ),
      ],
      sensitiveNotes: [
        _SensitiveNoteTag(
          label: 'preposto atrasa resposta',
          note:
              'O preposto costuma responder fora da janela combinada nas segundas e quintas. Registrar para leitura do time autenticado, sem expor isso na consulta publica.',
          classification: _SensitiveNoteClassification.operationalRisk,
          color: _amberColor,
          sortOrder: 1,
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceMarta,
            allowedGroups: [_CollaboratorAudienceGroup.board],
          ),
        ),
        _SensitiveNoteTag(
          label: 'documentacao parcial',
          note:
              'Financeiro envia anexos complementares em lotes. Essa anotacao serve como memoria operacional para quem consulta a conta logado.',
          classification: _SensitiveNoteClassification.routineContext,
          color: _slateColor,
          sortOrder: 2,
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceDiego,
            allowedGroups: [_CollaboratorAudienceGroup.supervision],
            allowedPeople: [_audienceLucas],
          ),
        ),
      ],
    ),
    _EntityItem(
      publicId: 'epr_01hcmp0000000000000002',
      title: 'Alpha Facilities',
      subtitle: 'Prestadora com risco moderado e rotacao alta no ultimo ciclo.',
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
      attachments: [
        _AttachmentRecord(
          publicId: 'anx_01hcmpformal000000000002',
          title: 'Comprovante fiscal trimestral',
          classification: _AttachmentClassification.formalDocument,
          summary:
              'Base documental para conciliacao financeira e renovacao cadastral.',
          status: 'em analise',
          updatedAtLabel: 'atualizado em 03/2026',
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceCamila,
            allowedGroups: [_CollaboratorAudienceGroup.board],
          ),
        ),
      ],
      sensitiveNotes: [
        _SensitiveNoteTag(
          label: 'turnover alto',
          note:
              'A conta acumula observacoes internas sobre perda de quadro e retrabalho em escala. Segue sensivel porque pode afetar negociacao e leitura de risco.',
          classification: _SensitiveNoteClassification.operationalRisk,
          color: _roseColor,
          sortOrder: 1,
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceCamila,
            allowedPeople: [_audienceDiego, _audienceMarta],
          ),
        ),
      ],
    ),
    _EntityItem(
      publicId: 'epr_01hcmp0000000000000003',
      title: 'Orbe Seguranca',
      subtitle: 'Prestadora com base pequena e contratos concentrados.',
      meta: '1 contrato | 12 funcionarios ativos | sem desligamentos recentes',
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
      attachments: [
        _AttachmentRecord(
          publicId: 'anx_01hcmpref000000000003',
          title: 'Checklist de onboarding do posto',
          classification: _AttachmentClassification.supportingReference,
          summary:
              'Referencia de apoio para leitura operacional rapida sem virar documento formal.',
          status: 'ativo',
          updatedAtLabel: 'atualizado em 02/2026',
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceLucas,
            allowedGroups: [_CollaboratorAudienceGroup.auxiliary],
            allowedPeople: [_audienceMarta],
          ),
        ),
      ],
    ),
    _EntityItem(
      publicId: 'epr_01hcmp0000000000000004',
      title: 'Nova Horizonte Apoio Operacional',
      subtitle:
          'Prestadora em expansao com onboarding acelerado em dois condominios.',
      meta: '3 contratos | 27 funcionarios ativos | 5 admissoes neste mes',
      status: 'expansao',
      icon: Icons.apartment_outlined,
      color: _tealColor,
      detailSummary:
          'Essa empresa pede uma leitura mais viva de implantacao, porque a base cresce rapido e a lateral de contexto evita que tudo vire navegacao quebrada.',
      relations: [
        'Cliente conectado: Parque das Flores',
        'Contrato em foco: Apoio operacional e recepcao',
        'Fila relacionada: 5 admissoes em onboarding nesta quinzena',
      ],
      attachments: [
        _AttachmentRecord(
          publicId: 'anx_01hcmpformal000000000004',
          title: 'Proposta operacional validada',
          classification: _AttachmentClassification.formalDocument,
          summary:
              'Documento formal usado para leitura de escopo e fase de implantacao.',
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
        _AttachmentRecord(
          publicId: 'anx_01hcmpref000000000004',
          title: 'Roteiro de onboarding de equipe',
          classification: _AttachmentClassification.supportingReference,
          summary:
              'Referencia de apoio para acelerar integracao de novos postos e novos lideres.',
          status: 'ativo',
          updatedAtLabel: 'atualizado em 04/2026',
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceCamila,
            allowedGroups: [_CollaboratorAudienceGroup.supervision],
            allowedPeople: [_audienceMarta],
          ),
        ),
      ],
      sensitiveNotes: [
        _SensitiveNoteTag(
          label: 'lideranca pede alinhamento diario',
          note:
              'Equipe responde melhor quando o alinhamento do turno acontece logo no comeco da jornada. Uso interno de supervisao.',
          classification: _SensitiveNoteClassification.routineContext,
          color: _tealColor,
          sortOrder: 1,
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceMarta,
            allowedGroups: [_CollaboratorAudienceGroup.supervision],
            allowedPeople: [_audienceDiego],
          ),
        ),
        _SensitiveNoteTag(
          label: 'implantacao com folga curta',
          note:
              'A margem para troca de quadro ainda e pequena. Qualquer desligamento recente impacta cobertura de posto.',
          classification: _SensitiveNoteClassification.operationalRisk,
          color: _roseColor,
          sortOrder: 2,
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceCamila,
            allowedGroups: [_CollaboratorAudienceGroup.board],
          ),
        ),
      ],
    ),
    _EntityItem(
      publicId: 'epr_01hcmp0000000000000005',
      title: 'Prisma Zeladoria Integrada',
      subtitle:
          'Prestadora com quadro estavel e passagens entre torres do mesmo grupo.',
      meta: '2 contratos | 19 funcionarios ativos | 4 pessoas multiempresa',
      status: 'multiunidade',
      icon: Icons.apartment_outlined,
      color: _slateColor,
      detailSummary:
          'O valor aqui esta na leitura de pessoas que circulam entre unidades sem perder trilha de contexto, historico e criterio de compartilhamento.',
      relations: [
        'Cliente conectado: Jardim Atlantico',
        'Contrato em foco: Zeladoria e manutencao leve',
        'Fila relacionada: 4 pessoas com passagens entre torres',
      ],
      attachments: [
        _AttachmentRecord(
          publicId: 'anx_01hcmpformal000000000005',
          title: 'Cadastro documental consolidado',
          classification: _AttachmentClassification.formalDocument,
          summary:
              'Base documental formal para leitura cadastral e apoio de auditoria.',
          status: 'vigente',
          updatedAtLabel: 'atualizado em 03/2026',
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceDiego,
            allowedGroups: [_CollaboratorAudienceGroup.board],
            allowedPeople: [_audienceMarta],
          ),
        ),
        _AttachmentRecord(
          publicId: 'anx_01hcmpref000000000005',
          title: 'Mapa de remanejamento entre torres',
          classification: _AttachmentClassification.supportingReference,
          summary:
              'Referencia operacional para leitura rapida de cobertura entre unidades do mesmo grupo.',
          status: 'ativo',
          updatedAtLabel: 'atualizado em 04/2026',
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceLucas,
            allowedGroups: [_CollaboratorAudienceGroup.supervision],
          ),
        ),
      ],
      sensitiveNotes: [
        _SensitiveNoteTag(
          label: 'time responde bem a remanejamento',
          note:
              'A operacao absorve melhor mudancas de torre quando a comunicacao chega no turno anterior. Observacao de rotina.',
          classification: _SensitiveNoteClassification.routineContext,
          color: _amberColor,
          sortOrder: 1,
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceCamila,
            allowedGroups: [_CollaboratorAudienceGroup.supervision],
            allowedPeople: [_audienceLucas],
          ),
        ),
      ],
    ),
    _EntityItem(
      publicId: 'epr_01hcmp0000000000000006',
      title: 'Atlas Portaria e Servicos',
      subtitle:
          'Prestadora nova na base, com implantacao rapida e liderancas em treinamento.',
      meta: '2 contratos | 16 funcionarios ativos | 3 lideres em treinamento',
      status: 'implantacao',
      icon: Icons.apartment_outlined,
      color: _amberColor,
      detailSummary:
          'Essa empresa representa um ponto de atencao saudavel: operacao nova, leitura de treinamento e necessidade de distinguir documento formal de memoria operacional.',
      relations: [
        'Cliente conectado: Residencial Aurora',
        'Contrato em foco: Portaria residencial 24h',
        'Fila relacionada: 3 lideres em treinamento de posto',
      ],
      attachments: [
        _AttachmentRecord(
          publicId: 'anx_01hcmpformal000000000006',
          title: 'Plano de implantacao assinado',
          classification: _AttachmentClassification.formalDocument,
          summary:
              'Documento formal de escopo e cronograma da operacao nova.',
          status: 'vigente',
          updatedAtLabel: 'atualizado em 04/2026',
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceDiego,
            allowedGroups: [_CollaboratorAudienceGroup.board],
            allowedPeople: [_audienceMarta],
          ),
        ),
        _AttachmentRecord(
          publicId: 'anx_01hcmpref000000000006',
          title: 'Guia de treinamento de posto',
          classification: _AttachmentClassification.supportingReference,
          summary:
              'Referencia de apoio usada para acelerar o preparo das novas liderancas.',
          status: 'ativo',
          updatedAtLabel: 'atualizado em 04/2026',
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceCamila,
            allowedGroups: [_CollaboratorAudienceGroup.supervision],
            allowedPeople: [_audienceDiego],
          ),
        ),
      ],
      sensitiveNotes: [
        _SensitiveNoteTag(
          label: 'liderancas ainda em consolidacao',
          note:
              'A estrutura de comando ainda esta fechando rotina e cobertura. Bom caso para acompanhamento interno mais proximo.',
          classification: _SensitiveNoteClassification.operationalRisk,
          color: _roseColor,
          sortOrder: 1,
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceMarta,
            allowedGroups: [_CollaboratorAudienceGroup.board],
          ),
        ),
      ],
    ),
  ],
);
