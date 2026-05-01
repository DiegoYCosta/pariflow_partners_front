part of '../../../app/app.dart';

const _contractsWorkspaceData = _EntityWorkspaceData(
  title: 'Contratos com leitura contextual',
  subtitle:
      'A consulta contratual fica organizada por vigencia, cliente, prestadora e volume de pessoas impactadas.',
  searchHint: 'buscar por cliente, prestadora ou codigo do contrato',
  listHint:
      'O contrato deixa de ser uma linha abstrata. A tela destaca vigencia, empresa relacionada e impacto operacional.',
  productionHint:
      'Primeiro passo real: consolidar vigencia, cliente e prestadora no mesmo payload, preparando a entrada de documentos formais por contrato.',
  integrationFocus: [
    'vigencia',
    'cliente',
    'prestadora',
    'documentos formais',
  ],
  filters: ['vigentes', 'a vencer', 'com rotacao recente'],
  accent: _amberColor,
  items: [
    _EntityItem(
      publicId: 'ctr_01hctr0000000000000001',
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
      publicId: 'ctr_01hctr0000000000000002',
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
      publicId: 'ctr_01hctr0000000000000003',
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
);
