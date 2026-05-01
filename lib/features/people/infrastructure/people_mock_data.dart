part of '../../../app/app.dart';

const _peopleWorkspaceData = _EntityWorkspaceData(
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
      sensitiveNotes: [
        _SensitiveNoteTag(
          label: 'filha com consulta nas segundas',
          note:
              'Preferir nao marcar troca de turno de segunda logo cedo sem confirmar. Entrada anonima permitida, visualizacao restrita por conter contexto familiar sensivel.',
          classification: _SensitiveNoteClassification.familyContext,
          color: _roseColor,
          sortOrder: 1,
          requiresLoginToView: true,
          requiresLoginToCreate: false,
        ),
        _SensitiveNoteTag(
          label: 'faz krav maga',
          note:
              'Informacao contextual util para leitura de perfil em posto de seguranca, sem substituir avaliacao formal nem treinamento exigido.',
          classification: _SensitiveNoteClassification.trainingOrSkill,
          color: _tealColor,
          sortOrder: 2,
        ),
      ],
    ),
    _EntityItem(
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
      sensitiveNotes: [
        _SensitiveNoteTag(
          label: 'costuma atrasar',
          note:
              'Historico informal de atrasos recorrentes no primeiro turno. Registrar como observacao interna, nao como fato disciplinar definitivo.',
          classification: _SensitiveNoteClassification.behavioralSignal,
          color: _amberColor,
          sortOrder: 1,
        ),
        _SensitiveNoteTag(
          label: 'mente sobre justificativas',
          note:
              'Sinal relatado pela operacao, ainda dependente de confirmacao documental. A leitura deve ficar protegida para evitar difusao indevida.',
          classification: _SensitiveNoteClassification.behavioralSignal,
          color: _roseColor,
          sortOrder: 2,
        ),
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
      sensitiveNotes: [
        _SensitiveNoteTag(
          label: 'filho cursa administracao',
          note:
              'Contexto pessoal coletado em conversa de rotina. Pode ajudar no entendimento humano do quadro, mas exige leitura autenticada por ser dado sensivel e lateral ao contrato.',
          classification: _SensitiveNoteClassification.personalContext,
          color: _slateColor,
          sortOrder: 1,
        ),
      ],
    ),
  ],
);
