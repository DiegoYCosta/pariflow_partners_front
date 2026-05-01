part of '../../../app/app.dart';

const _peopleWorkspaceData = _EntityWorkspaceData(
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
  items: [
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
          summary:
              'Documento formal ligado ao dossie base do colaborador.',
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
          accessPolicy: _ProtectedAccessPolicy(
            owner: _audienceLucas,
          ),
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
  ],
);
