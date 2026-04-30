part of '../../app/app.dart';

enum _GraphNodeKind { company, contract, person }

enum _GraphEdgeType { portfolio, origin, scope, allocation, dismissal, history }

extension on _GraphEdgeType {
  String get label => switch (this) {
    _GraphEdgeType.portfolio => 'carteira empresarial',
    _GraphEdgeType.origin => 'vinculo de origem',
    _GraphEdgeType.scope => 'escopo contratual',
    _GraphEdgeType.allocation => 'alocacao ativa',
    _GraphEdgeType.dismissal => 'desligamento recente',
    _GraphEdgeType.history => 'passagem anterior',
  };

  Color get color => switch (this) {
    _GraphEdgeType.portfolio => _slateColor,
    _GraphEdgeType.origin => _deepTealColor,
    _GraphEdgeType.scope => _amberColor,
    _GraphEdgeType.allocation => _tealColor,
    _GraphEdgeType.dismissal => _roseColor,
    _GraphEdgeType.history => _slateColor,
  };

  bool get dashed => switch (this) {
    _GraphEdgeType.portfolio => false,
    _GraphEdgeType.origin => true,
    _GraphEdgeType.scope => false,
    _GraphEdgeType.allocation => false,
    _GraphEdgeType.dismissal => true,
    _GraphEdgeType.history => true,
  };
}

class _GraphNode {
  const _GraphNode({
    required this.id,
    required this.kind,
    required this.rootCompanyId,
    required this.label,
    required this.subtitle,
    required this.miniLabel,
    required this.position,
    required this.status,
    required this.color,
    required this.icon,
    required this.highlights,
    this.sector,
    this.jobTitle,
    this.gender,
    this.race,
    this.tenureMonths,
    this.hasWarnings = false,
    this.isRoot = false,
    this.dismissedDaysAgo,
  });

  final String id;
  final _GraphNodeKind kind;
  final String rootCompanyId;
  final String label;
  final String subtitle;
  final String miniLabel;
  final Alignment position;
  final String status;
  final Color color;
  final IconData icon;
  final List<String> highlights;
  final String? sector;
  final String? jobTitle;
  final String? gender;
  final String? race;
  final int? tenureMonths;
  final bool hasWarnings;
  final bool isRoot;
  final int? dismissedDaysAgo;

  String get kindLabel => switch (kind) {
    _GraphNodeKind.company => isRoot ? 'empresa-raiz' : 'empresa-cliente',
    _GraphNodeKind.contract => 'contrato',
    _GraphNodeKind.person => 'funcionario',
  };

  String? get tenureBand {
    if (tenureMonths == null) {
      return null;
    }
    if (tenureMonths! < 12) {
      return 'ate 1 ano';
    }
    if (tenureMonths! < 36) {
      return '1 a 3 anos';
    }
    if (tenureMonths! < 60) {
      return '3 a 5 anos';
    }
    return '5 anos ou mais';
  }

  _GraphNode copyWith({Alignment? position}) {
    return _GraphNode(
      id: id,
      kind: kind,
      rootCompanyId: rootCompanyId,
      label: label,
      subtitle: subtitle,
      miniLabel: miniLabel,
      position: position ?? this.position,
      status: status,
      color: color,
      icon: icon,
      highlights: highlights,
      sector: sector,
      jobTitle: jobTitle,
      gender: gender,
      race: race,
      tenureMonths: tenureMonths,
      hasWarnings: hasWarnings,
      isRoot: isRoot,
      dismissedDaysAgo: dismissedDaysAgo,
    );
  }
}

class _GraphEdge {
  const _GraphEdge({
    required this.from,
    required this.to,
    required this.type,
    required this.detail,
  });

  final String from;
  final String to;
  final _GraphEdgeType type;
  final String detail;
}

class _GraphConnectionDetail {
  const _GraphConnectionDetail({required this.node, required this.edge});

  final _GraphNode node;
  final _GraphEdge edge;
}

class _NetworkFacetData {
  const _NetworkFacetData({
    required this.rootCompanies,
    required this.sectors,
    required this.jobTitles,
    required this.tenureBands,
    required this.genders,
    required this.races,
    required this.hasRecordsWithWarnings,
    required this.hasRecordsWithoutWarnings,
  });

  final List<_GraphNode> rootCompanies;
  final List<String> sectors;
  final List<String> jobTitles;
  final List<String> tenureBands;
  final List<String> genders;
  final List<String> races;
  final bool hasRecordsWithWarnings;
  final bool hasRecordsWithoutWarnings;
}

const _graphNodes = [
  _GraphNode(
    id: 'company_jotabe',
    kind: _GraphNodeKind.company,
    rootCompanyId: 'company_jotabe',
    label: 'SEDE JOTABE',
    subtitle:
        'Empresa-raiz com carteira propria e quadro terceirizado rastreavel.',
    miniLabel: 'empresa-raiz',
    position: Alignment(-0.88, -0.72),
    status: 'ativo',
    color: _tealColor,
    icon: Icons.apartment_outlined,
    highlights: [
      'Tem o mesmo peso estrutural da VVG dentro da teia.',
      'Ao ocultar esta raiz, clientes, contratos e colaboradores vinculados somem juntos.',
      'Funciona como ancora de rastreabilidade para origem do colaborador.',
    ],
    isRoot: true,
  ),
  _GraphNode(
    id: 'client_bela_vista',
    kind: _GraphNodeKind.company,
    rootCompanyId: 'company_jotabe',
    label: 'Condominio Bela Vista',
    subtitle: 'Cliente da carteira JOTABE com operacao de seguranca.',
    miniLabel: 'cliente',
    position: Alignment(-0.46, -0.58),
    status: 'ativo',
    color: _slateColor,
    icon: Icons.business_outlined,
    highlights: [
      'Empresa-cliente conectada a uma raiz especifica.',
      'Ajuda a deixar explicito para onde o colaborador foi subdirecionado.',
      'Pode ser ocultada de forma indireta ao desligar a visibilidade da raiz.',
    ],
  ),
  _GraphNode(
    id: 'contract_portaria',
    kind: _GraphNodeKind.contract,
    rootCompanyId: 'company_jotabe',
    label: 'CTR-SEG-2026-001',
    subtitle: 'Controle de acesso e ronda leve no Bela Vista.',
    miniLabel: 'contrato',
    position: Alignment(-0.04, -0.44),
    status: 'ativo',
    color: _amberColor,
    icon: Icons.description_outlined,
    highlights: [
      'Amarra o cliente ao quadro de seguranca alocado pela JOTABE.',
      'Permite filtrar a malha por setor e cargo sem perder a trilha da origem.',
      'Serve como ponte entre empresa-cliente e colaborador terceirizado.',
    ],
  ),
  _GraphNode(
    id: 'person_ana',
    kind: _GraphNodeKind.person,
    rootCompanyId: 'company_jotabe',
    label: 'Ana Paula Rocha',
    subtitle: 'Origem JOTABE | alocada no Bela Vista.',
    miniLabel: 'acesso',
    position: Alignment(0.42, -0.48),
    status: 'ativo',
    color: _tealColor,
    icon: Icons.badge_outlined,
    highlights: [
      'Mostra o caso classico de colaboradora vinculada a uma raiz e enviada para cliente especifico.',
      'Permite filtrar por setor, sexo, raca e tempo de servico sem perder a origem.',
      'Pode abrir ficha consolidada com trilha completa da alocacao.',
    ],
    sector: 'Seguranca',
    jobTitle: 'Controlador de Acesso',
    gender: 'feminino',
    race: 'branca',
    tenureMonths: 26,
  ),
  _GraphNode(
    id: 'client_horizonte',
    kind: _GraphNodeKind.company,
    rootCompanyId: 'company_jotabe',
    label: 'Horizonte Offices',
    subtitle: 'Cliente da carteira JOTABE com frente ADM e formacao.',
    miniLabel: 'cliente',
    position: Alignment(-0.46, -0.10),
    status: 'ativo',
    color: _slateColor,
    icon: Icons.business_outlined,
    highlights: [
      'Expande a teia para uma segunda carteira cliente da mesma raiz.',
      'Ajuda a provar que a ocultacao por raiz precisa derrubar toda a subarvore.',
      'Mantem contratos de apoio administrativo e entrada de aprendizes.',
    ],
  ),
  _GraphNode(
    id: 'contract_adm',
    kind: _GraphNodeKind.contract,
    rootCompanyId: 'company_jotabe',
    label: 'CTR-ADM-2026-014',
    subtitle: 'Apoio administrativo e formacao em escritorio.',
    miniLabel: 'contrato',
    position: Alignment(-0.02, -0.04),
    status: 'ativo',
    color: _amberColor,
    icon: Icons.description_outlined,
    highlights: [
      'Mantem cargos administrativos e de entrada no mesmo contexto contratual.',
      'Ajuda a demonstrar filtros dinamicos para setor e emprego especifico.',
      'Pode continuar visivel mesmo quando a leitura sai da seguranca.',
    ],
  ),
  _GraphNode(
    id: 'person_lucas',
    kind: _GraphNodeKind.person,
    rootCompanyId: 'company_jotabe',
    label: 'Lucas Andrade',
    subtitle: 'Origem JOTABE | frente administrativa ativa.',
    miniLabel: 'adm',
    position: Alignment(0.42, -0.08),
    status: 'ativo',
    color: _tealColor,
    icon: Icons.badge_outlined,
    highlights: [
      'Representa colaborador com advertencia anexa e tempo de casa mais longo.',
      'Ajuda a validar filtros de sexo, raca autodeclarada e advertencia.',
      'Mostra que o contrato pode sustentar mais de um perfil ocupacional.',
    ],
    sector: 'Area ADM',
    jobTitle: 'Supervisor Administrativo',
    gender: 'masculino',
    race: 'pardo',
    tenureMonths: 49,
    hasWarnings: true,
  ),
  _GraphNode(
    id: 'person_mila',
    kind: _GraphNodeKind.person,
    rootCompanyId: 'company_jotabe',
    label: 'Mila Santos',
    subtitle: 'Origem JOTABE | trilha de aprendizagem em andamento.',
    miniLabel: 'aprendiz',
    position: Alignment(0.68, 0.16),
    status: 'ativo',
    color: _tealColor,
    icon: Icons.school_outlined,
    highlights: [
      'Insere o eixo de estagiarios e jovens aprendizes na propria teia.',
      'Permite validar tempo de servico curto e recortes mais recentes de entrada.',
      'Mostra como a teia pode servir a contextos de formacao sem filtro fixo previo.',
    ],
    sector: 'Estagiarios + Jovens Aprendizes',
    jobTitle: 'Estagiaria Administrativa',
    gender: 'feminino',
    race: 'preta',
    tenureMonths: 7,
  ),
  _GraphNode(
    id: 'company_vvg',
    kind: _GraphNodeKind.company,
    rootCompanyId: 'company_vvg',
    label: 'VVG Servicos',
    subtitle: 'Empresa-raiz com carteira propria e equipe rastreavel.',
    miniLabel: 'empresa-raiz',
    position: Alignment(-0.88, 0.42),
    status: 'ativo',
    color: _roseColor,
    icon: Icons.apartment_outlined,
    highlights: [
      'Tem o mesmo peso estrutural da SEDE JOTABE.',
      'Pode ser desligada da teia inteira sem afetar a outra raiz.',
      'Explicita a necessidade de grupos empresariais independentes no mesmo mapa.',
    ],
    isRoot: true,
  ),
  _GraphNode(
    id: 'client_aurora',
    kind: _GraphNodeKind.company,
    rootCompanyId: 'company_vvg',
    label: 'Hospital Aurora',
    subtitle: 'Cliente da carteira VVG com frente de governanca.',
    miniLabel: 'cliente',
    position: Alignment(-0.46, 0.32),
    status: 'ativo',
    color: _slateColor,
    icon: Icons.local_hospital_outlined,
    highlights: [
      'Cliente conectado a uma segunda raiz de mesmo peso.',
      'Ajuda a demonstrar como contratos e desligados antigos podem reaparecer.',
      'Mantem a leitura de governanca, limpeza e historico na mesma subarvore.',
    ],
  ),
  _GraphNode(
    id: 'contract_governanca',
    kind: _GraphNodeKind.contract,
    rootCompanyId: 'company_vvg',
    label: 'CTR-GOV-2026-021',
    subtitle: 'Governanca operacional e lideranca de limpeza hospitalar.',
    miniLabel: 'contrato',
    position: Alignment(-0.02, 0.36),
    status: 'ativo',
    color: _amberColor,
    icon: Icons.description_outlined,
    highlights: [
      'Contrato que concentra ativos e desligados de varias janelas temporais.',
      'E um bom exemplo para habilitar 6 meses, 1 ano, 2 anos, 5 anos e todo o periodo.',
      'Tambem sustenta historico multiempresa em casos de passagem anterior.',
    ],
  ),
  _GraphNode(
    id: 'person_carla',
    kind: _GraphNodeKind.person,
    rootCompanyId: 'company_vvg',
    label: 'Carla Mendes',
    subtitle: 'Origem VVG | lideranca ativa em governanca.',
    miniLabel: 'governanca',
    position: Alignment(0.42, 0.24),
    status: 'ativo',
    color: _tealColor,
    icon: Icons.badge_outlined,
    highlights: [
      'Mantem o setor de governanca vivo na teia atual.',
      'Permite enxergar passagem anterior entre grupos empresariais.',
      'E um caso bom para abrir detalhe de risco, historico e relacoes cruzadas.',
    ],
    sector: 'Area de Governanca',
    jobTitle: 'Lider de Limpeza',
    gender: 'feminino',
    race: 'parda',
    tenureMonths: 18,
  ),
  _GraphNode(
    id: 'person_bruno',
    kind: _GraphNodeKind.person,
    rootCompanyId: 'company_vvg',
    label: 'Bruno Tavares',
    subtitle: 'Desligado ha 18 dias | historico ainda quente.',
    miniLabel: 'desligado',
    position: Alignment(0.58, 0.56),
    status: 'desligado',
    color: _roseColor,
    icon: Icons.person_off_outlined,
    highlights: [
      'Permanece visivel nas janelas curtas e some quando o recorte fecha abaixo de 18 dias.',
      'Ajuda a validar filtros de advertencia anexa e recortes juridicos.',
      'Continua rastreavel ate a raiz VVG e ao contrato hospitalar.',
    ],
    sector: 'Area de Governanca',
    jobTitle: 'Auxiliar de Limpeza',
    gender: 'masculino',
    race: 'preto',
    tenureMonths: 38,
    hasWarnings: true,
    dismissedDaysAgo: 18,
  ),
  _GraphNode(
    id: 'person_vera',
    kind: _GraphNodeKind.person,
    rootCompanyId: 'company_vvg',
    label: 'Vera Sousa',
    subtitle: 'Desligada ha 420 dias | historico remoto relevante.',
    miniLabel: 'historico',
    position: Alignment(0.26, 0.78),
    status: 'desligado',
    color: _roseColor,
    icon: Icons.person_off_outlined,
    highlights: [
      'Volta para a malha quando o usuario sobe para 2 anos ou todo o periodo.',
      'Prova que a teia nao pode limitar desligados antigos a um teto fixo de 90 dias.',
      'Mantem rastreabilidade de origem mesmo em desligamentos remotos.',
    ],
    sector: 'Area de Governanca',
    jobTitle: 'Governanta',
    gender: 'feminino',
    race: 'branca',
    tenureMonths: 86,
    dismissedDaysAgo: 420,
  ),
];

const _graphEdges = [
  _GraphEdge(
    from: 'company_jotabe',
    to: 'client_bela_vista',
    type: _GraphEdgeType.portfolio,
    detail: 'A SEDE JOTABE sustenta esta carteira cliente.',
  ),
  _GraphEdge(
    from: 'client_bela_vista',
    to: 'contract_portaria',
    type: _GraphEdgeType.scope,
    detail: 'Este cliente recebe o contrato de seguranca da JOTABE.',
  ),
  _GraphEdge(
    from: 'company_jotabe',
    to: 'person_ana',
    type: _GraphEdgeType.origin,
    detail: 'Ana esta vinculada diretamente a raiz JOTABE antes da alocacao.',
  ),
  _GraphEdge(
    from: 'contract_portaria',
    to: 'person_ana',
    type: _GraphEdgeType.allocation,
    detail: 'Ana esta alocada no posto de controlador de acesso.',
  ),
  _GraphEdge(
    from: 'company_jotabe',
    to: 'client_horizonte',
    type: _GraphEdgeType.portfolio,
    detail: 'Horizonte Offices integra a carteira da SEDE JOTABE.',
  ),
  _GraphEdge(
    from: 'client_horizonte',
    to: 'contract_adm',
    type: _GraphEdgeType.scope,
    detail: 'A carteira JOTABE desdobra apoio administrativo neste cliente.',
  ),
  _GraphEdge(
    from: 'company_jotabe',
    to: 'person_lucas',
    type: _GraphEdgeType.origin,
    detail: 'Lucas esta vinculado a JOTABE e depois direcionado ao cliente.',
  ),
  _GraphEdge(
    from: 'contract_adm',
    to: 'person_lucas',
    type: _GraphEdgeType.allocation,
    detail: 'Lucas atua como supervisor administrativo neste contrato.',
  ),
  _GraphEdge(
    from: 'contract_adm',
    to: 'person_mila',
    type: _GraphEdgeType.allocation,
    detail: 'Mila entra pela trilha de aprendizagem dentro deste contrato.',
  ),
  _GraphEdge(
    from: 'company_vvg',
    to: 'client_aurora',
    type: _GraphEdgeType.portfolio,
    detail: 'A VVG controla esta carteira hospitalar.',
  ),
  _GraphEdge(
    from: 'client_aurora',
    to: 'contract_governanca',
    type: _GraphEdgeType.scope,
    detail: 'O cliente recebe o contrato hospitalar de governanca e limpeza.',
  ),
  _GraphEdge(
    from: 'company_vvg',
    to: 'person_carla',
    type: _GraphEdgeType.origin,
    detail: 'Carla esta vinculada a VVG antes da alocacao no hospital.',
  ),
  _GraphEdge(
    from: 'contract_governanca',
    to: 'person_carla',
    type: _GraphEdgeType.allocation,
    detail: 'Carla lidera a frente operacional de governanca neste contrato.',
  ),
  _GraphEdge(
    from: 'contract_governanca',
    to: 'person_bruno',
    type: _GraphEdgeType.dismissal,
    detail: 'Bruno saiu deste contrato dentro da janela curta ainda visivel.',
  ),
  _GraphEdge(
    from: 'contract_governanca',
    to: 'person_vera',
    type: _GraphEdgeType.dismissal,
    detail: 'Vera so volta quando a teia abre o recorte historico mais longo.',
  ),
  _GraphEdge(
    from: 'person_carla',
    to: 'company_jotabe',
    type: _GraphEdgeType.history,
    detail: 'Carla teve passagem anterior em uma carteira ligada a JOTABE.',
  ),
];

List<_GraphNode> _structuralGraphNodes(_NetworkFilterState filters) {
  final maxDays = filters.maxDismissedDays;

  return _graphNodes.where((node) {
    if (filters.hiddenRootCompanyIds.contains(node.rootCompanyId)) {
      return false;
    }
    if (node.kind != _GraphNodeKind.person || node.dismissedDaysAgo == null) {
      return true;
    }
    if (maxDays == null) {
      return true;
    }
    return node.dismissedDaysAgo! <= maxDays;
  }).toList();
}

_NetworkFacetData _networkFacets(List<_GraphNode> structuralNodes) {
  final people = structuralNodes
      .where((node) => node.kind == _GraphNodeKind.person)
      .toList();
  final tenureOrder = [
    'ate 1 ano',
    '1 a 3 anos',
    '3 a 5 anos',
    '5 anos ou mais',
  ];

  final sectors = <String>{};
  final jobTitles = <String>{};
  final genders = <String>{};
  final races = <String>{};
  final tenureBands = <String>{};

  for (final person in people) {
    if (person.sector != null) {
      sectors.add(person.sector!);
    }
    if (person.jobTitle != null) {
      jobTitles.add(person.jobTitle!);
    }
    if (person.gender != null) {
      genders.add(person.gender!);
    }
    if (person.race != null) {
      races.add(person.race!);
    }
    if (person.tenureBand != null) {
      tenureBands.add(person.tenureBand!);
    }
  }

  final orderedTenureBands = tenureBands.toList()
    ..sort(
      (left, right) =>
          tenureOrder.indexOf(left).compareTo(tenureOrder.indexOf(right)),
    );

  return _NetworkFacetData(
    rootCompanies: _graphNodes
        .where((node) => node.kind == _GraphNodeKind.company && node.isRoot)
        .toList(),
    sectors: sectors.toList(),
    jobTitles: jobTitles.toList(),
    tenureBands: orderedTenureBands,
    genders: genders.toList(),
    races: races.toList(),
    hasRecordsWithWarnings: people.any((person) => person.hasWarnings),
    hasRecordsWithoutWarnings: people.any((person) => !person.hasWarnings),
  );
}

List<_GraphNode> _visibleGraphNodes(_NetworkFilterState filters) {
  final structuralNodes = _structuralGraphNodes(filters);
  final facets = _networkFacets(structuralNodes);
  final effectiveSectors = filters.selectedSectors.intersection(
    facets.sectors.toSet(),
  );
  final effectiveJobTitles = filters.selectedJobTitles.intersection(
    facets.jobTitles.toSet(),
  );
  final effectiveTenureBands = filters.selectedTenureBands.intersection(
    facets.tenureBands.toSet(),
  );
  final effectiveGenders = filters.selectedGenders.intersection(
    facets.genders.toSet(),
  );
  final effectiveRaces = filters.selectedRaces.intersection(
    facets.races.toSet(),
  );

  final candidates = structuralNodes.where((node) {
    if (node.kind != _GraphNodeKind.person) {
      return true;
    }
    if (effectiveSectors.isNotEmpty && !effectiveSectors.contains(node.sector)) {
      return false;
    }
    if (effectiveJobTitles.isNotEmpty &&
        !effectiveJobTitles.contains(node.jobTitle)) {
      return false;
    }
    if (effectiveTenureBands.isNotEmpty &&
        !effectiveTenureBands.contains(node.tenureBand)) {
      return false;
    }
    if (effectiveGenders.isNotEmpty &&
        !effectiveGenders.contains(node.gender)) {
      return false;
    }
    if (effectiveRaces.isNotEmpty && !effectiveRaces.contains(node.race)) {
      return false;
    }
    if (filters.requireWarnings != null &&
        node.hasWarnings != filters.requireWarnings) {
      return false;
    }
    return true;
  }).toList();

  return _layoutGraphNodes(_pruneGraphNodes(candidates));
}

List<_GraphNode> _pruneGraphNodes(List<_GraphNode> nodes) {
  final nodesById = {for (final node in nodes) node.id: node};
  var currentIds = nodesById.keys.toSet();
  var changed = true;

  while (changed) {
    changed = false;
    final visibleEdges = _graphEdges.where(
      (edge) => currentIds.contains(edge.from) && currentIds.contains(edge.to),
    );
    final adjacency = <String, Set<String>>{
      for (final id in currentIds) id: <String>{},
    };

    for (final edge in visibleEdges) {
      adjacency[edge.from]!.add(edge.to);
      adjacency[edge.to]!.add(edge.from);
    }

    final nextIds = <String>{};

    for (final nodeId in currentIds) {
      final node = nodesById[nodeId]!;
      final neighbors = adjacency[nodeId] ?? const <String>{};

      if (neighbors.isEmpty) {
        continue;
      }

      if (node.kind == _GraphNodeKind.person) {
        nextIds.add(nodeId);
        continue;
      }

      if (node.kind == _GraphNodeKind.contract) {
        final hasPersonNeighbor = neighbors.any(
          (neighborId) => nodesById[neighborId]!.kind == _GraphNodeKind.person,
        );
        if (hasPersonNeighbor) {
          nextIds.add(nodeId);
        }
        continue;
      }

      final hasNonCompanyNeighbor = neighbors.any(
        (neighborId) => nodesById[neighborId]!.kind != _GraphNodeKind.company,
      );
      if (hasNonCompanyNeighbor) {
        nextIds.add(nodeId);
      }
    }

    if (nextIds.length != currentIds.length) {
      currentIds = nextIds;
      changed = true;
    }
  }

  return nodes.where((node) => currentIds.contains(node.id)).toList();
}

List<_GraphNode> _layoutGraphNodes(List<_GraphNode> nodes) {
  if (nodes.isEmpty) {
    return nodes;
  }

  final nodesById = {for (final node in nodes) node.id: node};
  final visibleEdges = _visibleGraphEdges(nodes);
  final positioned = <String, Alignment>{};
  final rootCompanies =
      nodes
          .where((node) => node.kind == _GraphNodeKind.company && node.isRoot)
          .toList()
        ..sort(
          (left, right) => _graphNodeOriginalOrder(
            left.id,
          ).compareTo(_graphNodeOriginalOrder(right.id)),
        );

  final laneCenters = _spreadAlignments(
    rootCompanies.length,
    center: 0,
    spread: rootCompanies.length == 1 ? 0 : 1.18,
  );

  for (var rootIndex = 0; rootIndex < rootCompanies.length; rootIndex++) {
    final root = rootCompanies[rootIndex];
    final laneCenter = laneCenters[rootIndex];
    positioned[root.id] = Alignment(laneCenter, -0.80);

    final clients =
        nodes
            .where(
              (node) =>
                  node.kind == _GraphNodeKind.company &&
                  !node.isRoot &&
                  node.rootCompanyId == root.id,
            )
            .toList()
          ..sort(
            (left, right) => _graphNodeOriginalOrder(
              left.id,
            ).compareTo(_graphNodeOriginalOrder(right.id)),
          );

    final clientCenters = _spreadAlignments(
      clients.length,
      center: laneCenter,
      spread: clients.length == 1 ? 0 : 0.34,
    );

    final positionedPeopleForRoot = <String>{};

    for (var clientIndex = 0; clientIndex < clients.length; clientIndex++) {
      final client = clients[clientIndex];
      final clientCenter = clientCenters[clientIndex];
      positioned[client.id] = Alignment(clientCenter, -0.34);

      final clientContracts = _contractsForClient(
        client.id,
        nodesById,
        visibleEdges,
      );
      final contractCenters = _spreadAlignments(
        clientContracts.length,
        center: clientCenter,
        spread: clientContracts.length == 1 ? 0 : 0.16,
      );

      for (
        var contractIndex = 0;
        contractIndex < clientContracts.length;
        contractIndex++
      ) {
        final contract = clientContracts[contractIndex];
        final contractCenter = contractCenters[contractIndex];
        positioned[contract.id] = Alignment(contractCenter, 0.02);

        final contractPeople = _peopleForContract(
          contract.id,
          nodesById,
          visibleEdges,
        );
        for (
          var rowStart = 0;
          rowStart < contractPeople.length;
          rowStart += 2
        ) {
          final row = rowStart ~/ 2;
          final rowPeople = contractPeople.skip(rowStart).take(2).toList();
          final rowCenters = _spreadAlignments(
            rowPeople.length,
            center: contractCenter,
            spread: rowPeople.length == 1 ? 0 : 0.24,
          );

          for (var rowIndex = 0; rowIndex < rowPeople.length; rowIndex++) {
            final person = rowPeople[rowIndex];
            final personY = 0.36 + (row * 0.24);
            positioned[person.id] = Alignment(rowCenters[rowIndex], personY);
            positionedPeopleForRoot.add(person.id);
          }
        }
      }
    }

    final unassignedPeople =
        nodes
            .where(
              (node) =>
                  node.kind == _GraphNodeKind.person &&
                  node.rootCompanyId == root.id &&
                  !positionedPeopleForRoot.contains(node.id),
            )
            .toList()
          ..sort(
            (left, right) => _graphNodeOriginalOrder(
              left.id,
            ).compareTo(_graphNodeOriginalOrder(right.id)),
          );

    for (
      var looseIndex = 0;
      looseIndex < unassignedPeople.length;
      looseIndex++
    ) {
      final loosePerson = unassignedPeople[looseIndex];
      final looseOffsets = _spreadAlignments(
        unassignedPeople.length,
        center: laneCenter,
        spread: unassignedPeople.length == 1 ? 0 : 0.20,
      );
      positioned[loosePerson.id] = Alignment(
        looseOffsets[looseIndex],
        0.34 + ((looseIndex ~/ 2) * 0.24),
      );
    }
  }

  return nodes
      .map((node) => node.copyWith(position: positioned[node.id]))
      .toList();
}

List<_GraphNode> _contractsForClient(
  String clientId,
  Map<String, _GraphNode> nodesById,
  List<_GraphEdge> visibleEdges,
) {
  return visibleEdges
      .where((edge) => edge.type == _GraphEdgeType.scope && edge.from == clientId)
      .map((edge) => nodesById[edge.to])
      .whereType<_GraphNode>()
      .toList()
    ..sort(
      (left, right) => _graphNodeOriginalOrder(
        left.id,
      ).compareTo(_graphNodeOriginalOrder(right.id)),
    );
}

List<_GraphNode> _peopleForContract(
  String contractId,
  Map<String, _GraphNode> nodesById,
  List<_GraphEdge> visibleEdges,
) {
  final people = visibleEdges
      .where(
        (edge) =>
            (edge.type == _GraphEdgeType.allocation ||
                edge.type == _GraphEdgeType.dismissal) &&
            edge.from == contractId,
      )
      .map((edge) => nodesById[edge.to])
      .whereType<_GraphNode>()
      .toList();

  people.sort((left, right) {
    if (left.status != right.status) {
      return left.status == 'ativo' ? -1 : 1;
    }
    return _graphNodeOriginalOrder(
      left.id,
    ).compareTo(_graphNodeOriginalOrder(right.id));
  });

  return people;
}

int _graphNodeOriginalOrder(String nodeId) {
  return _graphNodes.indexWhere((node) => node.id == nodeId);
}

List<double> _spreadAlignments(
  int count, {
  required double center,
  required double spread,
}) {
  if (count <= 0) {
    return const [];
  }
  if (count == 1) {
    return [center];
  }

  final start = center - (spread / 2);
  final step = spread / (count - 1);
  return List<double>.generate(count, (index) => start + (step * index));
}

List<_GraphEdge> _visibleGraphEdges(List<_GraphNode> visibleNodes) {
  return _graphEdges.where((edge) {
    return visibleNodes.any((node) => node.id == edge.from) &&
        visibleNodes.any((node) => node.id == edge.to);
  }).toList();
}

List<_GraphConnectionDetail> _connectionDetailsForNode(
  String nodeId,
  List<_GraphNode> visibleNodes,
) {
  final visibleEdges = _visibleGraphEdges(visibleNodes);
  final details = <_GraphConnectionDetail>[];

  for (final edge in visibleEdges) {
    final relatedNodeId = edge.from == nodeId
        ? edge.to
        : edge.to == nodeId
        ? edge.from
        : null;

    if (relatedNodeId == null) {
      continue;
    }

    final relatedNode = visibleNodes.firstWhere((node) => node.id == relatedNodeId);

    details.add(_GraphConnectionDetail(node: relatedNode, edge: edge));
  }

  return details;
}

Set<String> _relatedNodeIds(String nodeId, List<_GraphEdge> edges) {
  final ids = <String>{};

  for (final edge in edges) {
    if (edge.from == nodeId) {
      ids.add(edge.to);
    } else if (edge.to == nodeId) {
      ids.add(edge.from);
    }
  }

  return ids;
}

String _nodeLabelById(String nodeId, List<_GraphNode> nodes) {
  return nodes
      .firstWhere((node) => node.id == nodeId, orElse: () => nodes.first)
      .label;
}

IconData _statusIconForNode(_GraphNode node) {
  if (node.status == 'desligado') {
    return Icons.person_off_outlined;
  }

  if (node.kind == _GraphNodeKind.contract) {
    return Icons.description_outlined;
  }

  return node.icon;
}

void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
  for (final metric in path.computeMetrics()) {
    var distance = 0.0;
    const dash = 8.0;
    const gap = 6.0;

    while (distance < metric.length) {
      final next = distance + dash;
      canvas.drawPath(
        metric.extractPath(distance, next.clamp(0, metric.length).toDouble()),
        paint,
      );
      distance += dash + gap;
    }
  }
}
