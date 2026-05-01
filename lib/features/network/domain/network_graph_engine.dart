part of '../../../app/app.dart';

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

