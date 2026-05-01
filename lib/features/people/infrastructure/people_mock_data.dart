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

String _generatedSubtitle(_PeopleBatchSpec batch, _MockPersonMode mode) =>
    switch (mode) {
      _MockPersonMode.active =>
        'Pessoa em operacao ativa de ${batch.operation}.',
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
