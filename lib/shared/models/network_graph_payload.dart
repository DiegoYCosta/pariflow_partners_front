part of '../../app/app.dart';

enum _NetworkGraphLane { rootCompany, clientCompany, contract, employee }

enum _NetworkGraphNodeType { rootCompany, clientCompany, contract, employee }

enum _NetworkGraphRelationshipState { active, historical, indirect }

class _NetworkGraphPayload {
  const _NetworkGraphPayload({
    required this.period,
    required this.lanes,
    required this.nodes,
    required this.edges,
    required this.filters,
    required this.legend,
    required this.focus,
    required this.meta,
  });

  factory _NetworkGraphPayload.fromMap(Map<String, dynamic> map) {
    final data = (map['data'] as Map?)?.cast<String, dynamic>() ?? map;
    final meta = (map['meta'] as Map?)?.cast<String, dynamic>() ?? const {};

    return _NetworkGraphPayload(
      period: _NetworkGraphPeriod.fromMap(
        (data['period'] as Map).cast<String, dynamic>(),
      ),
      lanes: [
        for (final lane in (data['lanes'] as List<dynamic>))
          _networkGraphLaneFromApi(lane as String),
      ],
      nodes: [
        for (final node in (data['nodes'] as List<dynamic>))
          _NetworkGraphNode.fromMap((node as Map).cast<String, dynamic>()),
      ],
      edges: [
        for (final edge in (data['edges'] as List<dynamic>))
          _NetworkGraphEdge.fromMap((edge as Map).cast<String, dynamic>()),
      ],
      filters: _NetworkGraphFilters.fromMap(
        (data['filters'] as Map).cast<String, dynamic>(),
      ),
      legend: _NetworkGraphLegend.fromMap(
        (data['legend'] as Map).cast<String, dynamic>(),
      ),
      focus: _NetworkGraphFocus.fromMap(
        (data['focus'] as Map).cast<String, dynamic>(),
      ),
      meta: _NetworkGraphMeta.fromMap(meta),
    );
  }

  final _NetworkGraphPeriod period;
  final List<_NetworkGraphLane> lanes;
  final List<_NetworkGraphNode> nodes;
  final List<_NetworkGraphEdge> edges;
  final _NetworkGraphFilters filters;
  final _NetworkGraphLegend legend;
  final _NetworkGraphFocus focus;
  final _NetworkGraphMeta meta;

  _NetworkGraphNode? nodeByPublicId(String publicId) {
    for (final node in nodes) {
      if (node.publicId == publicId) {
        return node;
      }
    }
    return null;
  }

  int countNodesInLane(_NetworkGraphLane lane) =>
      nodes.where((node) => node.lane == lane).length;

  String get primaryFocusDisplayName {
    final selectedNode = focus.selectedNodePublicId != null
        ? nodeByPublicId(focus.selectedNodePublicId!)
        : null;
    final anchorNode = focus.viewportAnchorPublicId != null
        ? nodeByPublicId(focus.viewportAnchorPublicId!)
        : null;
    return selectedNode?.displayName ??
        anchorNode?.displayName ??
        focus.selectedNodePublicId ??
        focus.viewportAnchorPublicId ??
        'nenhum foco definido';
  }
}

class _NetworkGraphPeriod {
  const _NetworkGraphPeriod({
    required this.preset,
    required this.from,
    required this.to,
  });

  factory _NetworkGraphPeriod.fromMap(Map<String, dynamic> map) {
    return _NetworkGraphPeriod(
      preset: map['preset'] as String,
      from: map['from'] as String,
      to: map['to'] as String,
    );
  }

  final String preset;
  final String from;
  final String to;
}

class _NetworkGraphNode {
  const _NetworkGraphNode({
    required this.publicId,
    required this.nodeType,
    required this.lane,
    required this.displayName,
    required this.subtitle,
    required this.status,
    required this.badges,
    required this.detailSnapshot,
  });

  factory _NetworkGraphNode.fromMap(Map<String, dynamic> map) {
    return _NetworkGraphNode(
      publicId: map['publicId'] as String,
      nodeType: _networkGraphNodeTypeFromApi(map['nodeType'] as String),
      lane: _networkGraphLaneFromApi(map['lane'] as String),
      displayName: map['displayName'] as String,
      subtitle: map['subtitle'] as String,
      status: map['status'] as String,
      badges: [
        for (final badge in (map['badges'] as List<dynamic>)) badge as String,
      ],
      detailSnapshot: _NetworkDetailSnapshot.fromMap(
        (map['detailSnapshot'] as Map).cast<String, dynamic>(),
      ),
    );
  }

  final String publicId;
  final _NetworkGraphNodeType nodeType;
  final _NetworkGraphLane lane;
  final String displayName;
  final String subtitle;
  final String status;
  final List<String> badges;
  final _NetworkDetailSnapshot detailSnapshot;
}

class _NetworkDetailSnapshot {
  const _NetworkDetailSnapshot({
    required this.kind,
    required this.summary,
    this.contractStatus,
    this.activeClientCompanies,
    this.activeContracts,
    this.activeEmployees,
    this.historicalEmployees,
    this.historicalContracts,
    this.indirectConnections,
    this.rootCompanies = const [],
    this.clientCompanies = const [],
    this.cta,
    this.extras = const {},
  });

  factory _NetworkDetailSnapshot.fromMap(Map<String, dynamic> map) {
    final knownKeys = {
      'kind',
      'summary',
      'contractStatus',
      'activeClientCompanies',
      'activeContracts',
      'activeEmployees',
      'historicalEmployees',
      'historicalContracts',
      'indirectConnections',
      'rootCompanies',
      'clientCompanies',
      'cta',
    };

    return _NetworkDetailSnapshot(
      kind: map['kind'] as String,
      summary: map['summary'] as String,
      contractStatus: map['contractStatus'] as String?,
      activeClientCompanies: map['activeClientCompanies'] as int?,
      activeContracts: map['activeContracts'] as int?,
      activeEmployees: map['activeEmployees'] as int?,
      historicalEmployees: map['historicalEmployees'] as int?,
      historicalContracts: map['historicalContracts'] as int?,
      indirectConnections: map['indirectConnections'] as int?,
      rootCompanies: [
        for (final item in (map['rootCompanies'] as List<dynamic>? ?? const []))
          item as String,
      ],
      clientCompanies: [
        for (final item
            in (map['clientCompanies'] as List<dynamic>? ?? const []))
          item as String,
      ],
      cta: map['cta'] == null
          ? null
          : _NetworkDetailCta.fromMap((map['cta'] as Map).cast<String, dynamic>()),
      extras: {
        for (final entry in map.entries)
          if (!knownKeys.contains(entry.key)) entry.key: entry.value,
      },
    );
  }

  final String kind;
  final String summary;
  final String? contractStatus;
  final int? activeClientCompanies;
  final int? activeContracts;
  final int? activeEmployees;
  final int? historicalEmployees;
  final int? historicalContracts;
  final int? indirectConnections;
  final List<String> rootCompanies;
  final List<String> clientCompanies;
  final _NetworkDetailCta? cta;
  final Map<String, Object?> extras;
}

class _NetworkDetailCta {
  const _NetworkDetailCta({
    required this.label,
    required this.targetPublicId,
  });

  factory _NetworkDetailCta.fromMap(Map<String, dynamic> map) {
    return _NetworkDetailCta(
      label: map['label'] as String,
      targetPublicId: map['targetPublicId'] as String,
    );
  }

  final String label;
  final String targetPublicId;
}

class _NetworkGraphEdge {
  const _NetworkGraphEdge({
    required this.publicId,
    required this.fromPublicId,
    required this.toPublicId,
    required this.relationshipKind,
    required this.relationshipState,
    required this.periodStart,
    required this.periodEnd,
    required this.metadataLabel,
  });

  factory _NetworkGraphEdge.fromMap(Map<String, dynamic> map) {
    final metadata = (map['metadata'] as Map?)?.cast<String, dynamic>() ?? const {};
    return _NetworkGraphEdge(
      publicId: map['publicId'] as String,
      fromPublicId: map['fromPublicId'] as String,
      toPublicId: map['toPublicId'] as String,
      relationshipKind: map['relationshipKind'] as String,
      relationshipState: _networkGraphRelationshipStateFromApi(
        map['relationshipState'] as String,
      ),
      periodStart: map['periodStart'] as String?,
      periodEnd: map['periodEnd'] as String?,
      metadataLabel: metadata['label'] as String?,
    );
  }

  final String publicId;
  final String fromPublicId;
  final String toPublicId;
  final String relationshipKind;
  final _NetworkGraphRelationshipState relationshipState;
  final String? periodStart;
  final String? periodEnd;
  final String? metadataLabel;
}

class _NetworkGraphFilters {
  const _NetworkGraphFilters({
    required this.search,
    required this.applied,
    required this.available,
  });

  factory _NetworkGraphFilters.fromMap(Map<String, dynamic> map) {
    return _NetworkGraphFilters(
      search: map['search'] as String? ?? '',
      applied: _NetworkGraphAppliedFilters.fromMap(
        (map['applied'] as Map).cast<String, dynamic>(),
      ),
      available: _NetworkGraphAvailableFilters.fromMap(
        (map['available'] as Map).cast<String, dynamic>(),
      ),
    );
  }

  final String search;
  final _NetworkGraphAppliedFilters applied;
  final _NetworkGraphAvailableFilters available;
}

class _NetworkGraphAppliedFilters {
  const _NetworkGraphAppliedFilters({
    required this.periodPreset,
    required this.rootCompanyPublicIds,
    required this.clientCompanyPublicIds,
    required this.contractStatuses,
    required this.employeeStatuses,
    required this.includeHistorical,
    required this.includeIndirect,
  });

  factory _NetworkGraphAppliedFilters.fromMap(Map<String, dynamic> map) {
    return _NetworkGraphAppliedFilters(
      periodPreset: map['periodPreset'] as String,
      rootCompanyPublicIds: [
        for (final item
            in (map['rootCompanyPublicIds'] as List<dynamic>? ?? const []))
          item as String,
      ],
      clientCompanyPublicIds: [
        for (final item
            in (map['clientCompanyPublicIds'] as List<dynamic>? ?? const []))
          item as String,
      ],
      contractStatuses: [
        for (final item
            in (map['contractStatuses'] as List<dynamic>? ?? const []))
          item as String,
      ],
      employeeStatuses: [
        for (final item
            in (map['employeeStatuses'] as List<dynamic>? ?? const []))
          item as String,
      ],
      includeHistorical: map['includeHistorical'] as bool? ?? false,
      includeIndirect: map['includeIndirect'] as bool? ?? false,
    );
  }

  final String periodPreset;
  final List<String> rootCompanyPublicIds;
  final List<String> clientCompanyPublicIds;
  final List<String> contractStatuses;
  final List<String> employeeStatuses;
  final bool includeHistorical;
  final bool includeIndirect;
}

class _NetworkGraphAvailableFilters {
  const _NetworkGraphAvailableFilters({
    required this.periodPresets,
    required this.rootCompanies,
    required this.clientCompanies,
    required this.contractStatuses,
    required this.employeeStatuses,
    required this.relationshipStates,
  });

  factory _NetworkGraphAvailableFilters.fromMap(Map<String, dynamic> map) {
    return _NetworkGraphAvailableFilters(
      periodPresets: [
        for (final item
            in (map['periodPresets'] as List<dynamic>? ?? const []))
          item as String,
      ],
      rootCompanies: [
        for (final item
            in (map['rootCompanies'] as List<dynamic>? ?? const []))
          _NetworkGraphFilterOption.fromMap((item as Map).cast<String, dynamic>()),
      ],
      clientCompanies: [
        for (final item
            in (map['clientCompanies'] as List<dynamic>? ?? const []))
          _NetworkGraphFilterOption.fromMap((item as Map).cast<String, dynamic>()),
      ],
      contractStatuses: [
        for (final item
            in (map['contractStatuses'] as List<dynamic>? ?? const []))
          item as String,
      ],
      employeeStatuses: [
        for (final item
            in (map['employeeStatuses'] as List<dynamic>? ?? const []))
          item as String,
      ],
      relationshipStates: [
        for (final item
            in (map['relationshipStates'] as List<dynamic>? ?? const []))
          item as String,
      ],
    );
  }

  final List<String> periodPresets;
  final List<_NetworkGraphFilterOption> rootCompanies;
  final List<_NetworkGraphFilterOption> clientCompanies;
  final List<String> contractStatuses;
  final List<String> employeeStatuses;
  final List<String> relationshipStates;
}

class _NetworkGraphFilterOption {
  const _NetworkGraphFilterOption({
    required this.publicId,
    required this.label,
  });

  factory _NetworkGraphFilterOption.fromMap(Map<String, dynamic> map) {
    return _NetworkGraphFilterOption(
      publicId: map['publicId'] as String,
      label: map['label'] as String,
    );
  }

  final String publicId;
  final String label;
}

class _NetworkGraphLegend {
  const _NetworkGraphLegend({required this.relationshipStates});

  factory _NetworkGraphLegend.fromMap(Map<String, dynamic> map) {
    return _NetworkGraphLegend(
      relationshipStates: [
        for (final item
            in (map['relationshipStates'] as List<dynamic>? ?? const []))
          _NetworkGraphLegendEntry.fromMap((item as Map).cast<String, dynamic>()),
      ],
    );
  }

  final List<_NetworkGraphLegendEntry> relationshipStates;
}

class _NetworkGraphLegendEntry {
  const _NetworkGraphLegendEntry({
    required this.value,
    required this.label,
  });

  factory _NetworkGraphLegendEntry.fromMap(Map<String, dynamic> map) {
    return _NetworkGraphLegendEntry(
      value: map['value'] as String,
      label: map['label'] as String,
    );
  }

  final String value;
  final String label;
}

class _NetworkGraphFocus {
  const _NetworkGraphFocus({
    this.selectedNodePublicId,
    this.hoveredNodePublicId,
    this.viewportAnchorPublicId,
  });

  factory _NetworkGraphFocus.fromMap(Map<String, dynamic> map) {
    return _NetworkGraphFocus(
      selectedNodePublicId: map['selectedNodePublicId'] as String?,
      hoveredNodePublicId: map['hoveredNodePublicId'] as String?,
      viewportAnchorPublicId: map['viewportAnchorPublicId'] as String?,
    );
  }

  final String? selectedNodePublicId;
  final String? hoveredNodePublicId;
  final String? viewportAnchorPublicId;
}

class _NetworkGraphMeta {
  const _NetworkGraphMeta({required this.traceId});

  factory _NetworkGraphMeta.fromMap(Map<String, dynamic> map) {
    return _NetworkGraphMeta(traceId: map['traceId'] as String? ?? '');
  }

  final String traceId;
}

_NetworkGraphLane _networkGraphLaneFromApi(String value) {
  return switch (value) {
    'root_company' => _NetworkGraphLane.rootCompany,
    'client_company' => _NetworkGraphLane.clientCompany,
    'contract' => _NetworkGraphLane.contract,
    'employee' => _NetworkGraphLane.employee,
    _ => throw ArgumentError.value(value, 'value', 'Lane desconhecida'),
  };
}

_NetworkGraphNodeType _networkGraphNodeTypeFromApi(String value) {
  return switch (value) {
    'root_company' => _NetworkGraphNodeType.rootCompany,
    'client_company' => _NetworkGraphNodeType.clientCompany,
    'contract' => _NetworkGraphNodeType.contract,
    'employee' => _NetworkGraphNodeType.employee,
    _ => throw ArgumentError.value(value, 'value', 'Tipo de no desconhecido'),
  };
}

_NetworkGraphRelationshipState _networkGraphRelationshipStateFromApi(
  String value,
) {
  return switch (value) {
    'active' => _NetworkGraphRelationshipState.active,
    'historical' => _NetworkGraphRelationshipState.historical,
    'indirect' => _NetworkGraphRelationshipState.indirect,
    _ => throw ArgumentError.value(
      value,
      'value',
      'Estado de relacao desconhecido',
    ),
  };
}
