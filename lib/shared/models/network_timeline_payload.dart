part of '../../app/app.dart';

class _NetworkTimelinePayload {
  const _NetworkTimelinePayload({
    required this.period,
    required this.focus,
    required this.contracts,
    required this.collaborators,
    required this.events,
    required this.currentSnapshot,
    required this.legend,
    required this.warnings,
    required this.meta,
  });

  factory _NetworkTimelinePayload.fromMap(Map<String, dynamic> map) {
    final data = (map['data'] as Map?)?.cast<String, dynamic>() ?? map;
    final layers =
        (data['layers'] as Map?)?.cast<String, dynamic>() ?? const {};
    final meta = (map['meta'] as Map?)?.cast<String, dynamic>() ?? const {};

    return _NetworkTimelinePayload(
      period: _NetworkGraphPeriod.fromMap(
        (data['period'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      focus: _NetworkTimelineFocus.fromMap(
        (data['focus'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      contracts: _networkTimelineMapList(
        layers['contracts'],
        _NetworkTimelineContract.fromMap,
      ),
      collaborators: _networkTimelineMapList(
        layers['collaborators'],
        _NetworkTimelineCollaborator.fromMap,
      ),
      events: _networkTimelineMapList(
        layers['events'],
        _NetworkTimelineEvent.fromMap,
      ),
      currentSnapshot: _NetworkTimelineCurrentSnapshot.fromMap(
        (data['currentSnapshot'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      legend: _NetworkTimelineLegend.fromMap(
        (data['legend'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      warnings: _networkTimelineMapList(
        data['warnings'],
        _NetworkTimelineWarning.fromMap,
      ),
      meta: _NetworkGraphMeta.fromMap(meta),
    );
  }

  final _NetworkGraphPeriod period;
  final _NetworkTimelineFocus focus;
  final List<_NetworkTimelineContract> contracts;
  final List<_NetworkTimelineCollaborator> collaborators;
  final List<_NetworkTimelineEvent> events;
  final _NetworkTimelineCurrentSnapshot currentSnapshot;
  final _NetworkTimelineLegend legend;
  final List<_NetworkTimelineWarning> warnings;
  final _NetworkGraphMeta meta;

  int get contractsCount => contracts.length;

  int get collaboratorsCount => collaborators.length;

  _NetworkTimelineContract? contractByPublicId(String publicId) {
    for (final contract in contracts) {
      if (contract.publicId == publicId) {
        return contract;
      }
    }
    return null;
  }

  _NetworkTimelinePosition? positionByPublicId(String publicId) {
    for (final contract in contracts) {
      for (final position in contract.positions) {
        if (position.publicId == publicId) {
          return position;
        }
      }
    }
    return null;
  }

  _NetworkTimelineCollaborator? collaboratorByPublicId(String publicId) {
    for (final collaborator in collaborators) {
      if (collaborator.personPublicId == publicId) {
        return collaborator;
      }
    }
    return null;
  }

  _NetworkTimelineEvent? eventByPublicId(String publicId) {
    for (final event in events) {
      if (event.publicId == publicId) {
        return event;
      }
    }
    return null;
  }
}

class _NetworkTimelineFocus {
  const _NetworkTimelineFocus({
    this.companyPublicId,
    this.companyType,
    this.displayName,
  });

  factory _NetworkTimelineFocus.fromMap(Map<String, dynamic> map) {
    return _NetworkTimelineFocus(
      companyPublicId: map['companyPublicId'] as String?,
      companyType: map['companyType'] as String?,
      displayName: map['displayName'] as String?,
    );
  }

  final String? companyPublicId;
  final String? companyType;
  final String? displayName;
}

class _NetworkTimelineContract {
  const _NetworkTimelineContract({
    required this.publicId,
    required this.providerCompanyPublicId,
    required this.providerCompanyName,
    required this.clientCompanyPublicId,
    required this.clientCompanyName,
    required this.displayName,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    required this.positions,
  });

  factory _NetworkTimelineContract.fromMap(Map<String, dynamic> map) {
    return _NetworkTimelineContract(
      publicId: _networkTimelineText(map, 'publicId'),
      providerCompanyPublicId: _networkTimelineText(
        map,
        'providerCompanyPublicId',
      ),
      providerCompanyName: _networkTimelineText(map, 'providerCompanyName'),
      clientCompanyPublicId: _networkTimelineText(map, 'clientCompanyPublicId'),
      clientCompanyName: _networkTimelineText(map, 'clientCompanyName'),
      displayName: _networkTimelineText(map, 'displayName'),
      startsAt: map['startsAt'] as String?,
      endsAt: map['endsAt'] as String?,
      status: _networkTimelineText(map, 'status'),
      positions: _networkTimelineMapList(
        map['positions'],
        _NetworkTimelinePosition.fromMap,
      ),
    );
  }

  final String publicId;
  final String providerCompanyPublicId;
  final String providerCompanyName;
  final String clientCompanyPublicId;
  final String clientCompanyName;
  final String displayName;
  final String? startsAt;
  final String? endsAt;
  final String status;
  final List<_NetworkTimelinePosition> positions;
}

class _NetworkTimelinePosition {
  const _NetworkTimelinePosition({
    required this.publicId,
    required this.contractPublicId,
    required this.displayName,
    required this.serviceName,
    required this.location,
    required this.shift,
    required this.schedule,
    required this.status,
    required this.startsAt,
    required this.endsAt,
    required this.dateSource,
    required this.allocations,
  });

  factory _NetworkTimelinePosition.fromMap(Map<String, dynamic> map) {
    return _NetworkTimelinePosition(
      publicId: _networkTimelineText(map, 'publicId'),
      contractPublicId: _networkTimelineText(map, 'contractPublicId'),
      displayName: _networkTimelineText(map, 'displayName'),
      serviceName: _networkTimelineText(map, 'serviceName'),
      location: _networkTimelineText(map, 'location'),
      shift: _networkTimelineText(map, 'shift'),
      schedule: _networkTimelineText(map, 'schedule'),
      status: _networkTimelineText(map, 'status'),
      startsAt: map['startsAt'] as String?,
      endsAt: map['endsAt'] as String?,
      dateSource: _networkTimelineText(map, 'dateSource'),
      allocations: _networkTimelineMapList(
        map['allocations'],
        _NetworkTimelineAllocation.fromMap,
      ),
    );
  }

  final String publicId;
  final String contractPublicId;
  final String displayName;
  final String serviceName;
  final String location;
  final String shift;
  final String schedule;
  final String status;
  final String? startsAt;
  final String? endsAt;
  final String dateSource;
  final List<_NetworkTimelineAllocation> allocations;
}

class _NetworkTimelineAllocation {
  const _NetworkTimelineAllocation({
    required this.employmentLinkPublicId,
    required this.personPublicId,
    required this.personName,
    required this.providerCompanyPublicId,
    required this.contractPublicId,
    required this.positionPublicId,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    required this.type,
  });

  factory _NetworkTimelineAllocation.fromMap(Map<String, dynamic> map) {
    return _NetworkTimelineAllocation(
      employmentLinkPublicId: _networkTimelineText(
        map,
        'employmentLinkPublicId',
      ),
      personPublicId: _networkTimelineText(map, 'personPublicId'),
      personName: _networkTimelineText(map, 'personName'),
      providerCompanyPublicId: _networkTimelineText(
        map,
        'providerCompanyPublicId',
      ),
      contractPublicId: _networkTimelineText(map, 'contractPublicId'),
      positionPublicId: _networkTimelineText(map, 'positionPublicId'),
      startsAt: map['startsAt'] as String?,
      endsAt: map['endsAt'] as String?,
      status: _networkTimelineText(map, 'status'),
      type: _networkTimelineText(map, 'type'),
    );
  }

  final String employmentLinkPublicId;
  final String personPublicId;
  final String personName;
  final String providerCompanyPublicId;
  final String contractPublicId;
  final String positionPublicId;
  final String? startsAt;
  final String? endsAt;
  final String status;
  final String type;
}

class _NetworkTimelineCollaborator {
  const _NetworkTimelineCollaborator({
    required this.personPublicId,
    required this.personName,
    required this.status,
    required this.segments,
    required this.events,
  });

  factory _NetworkTimelineCollaborator.fromMap(Map<String, dynamic> map) {
    return _NetworkTimelineCollaborator(
      personPublicId: _networkTimelineText(map, 'personPublicId'),
      personName: _networkTimelineText(map, 'personName'),
      status: _networkTimelineText(map, 'status'),
      segments: _networkTimelineMapList(
        map['segments'],
        _NetworkTimelineSegment.fromMap,
      ),
      events: _networkTimelineMapList(
        map['events'],
        _NetworkTimelineEvent.fromMap,
      ),
    );
  }

  final String personPublicId;
  final String personName;
  final String status;
  final List<_NetworkTimelineSegment> segments;
  final List<_NetworkTimelineEvent> events;
}

class _NetworkTimelineSegment {
  const _NetworkTimelineSegment({
    required this.kind,
    required this.employmentLinkPublicId,
    required this.contractPublicId,
    required this.positionPublicId,
    required this.startsAt,
    required this.endsAt,
    required this.status,
  });

  factory _NetworkTimelineSegment.fromMap(Map<String, dynamic> map) {
    return _NetworkTimelineSegment(
      kind: _networkTimelineText(map, 'kind'),
      employmentLinkPublicId: _networkTimelineText(
        map,
        'employmentLinkPublicId',
      ),
      contractPublicId: _networkTimelineText(map, 'contractPublicId'),
      positionPublicId: _networkTimelineText(map, 'positionPublicId'),
      startsAt: map['startsAt'] as String?,
      endsAt: map['endsAt'] as String?,
      status: _networkTimelineText(map, 'status'),
    );
  }

  final String kind;
  final String employmentLinkPublicId;
  final String contractPublicId;
  final String positionPublicId;
  final String? startsAt;
  final String? endsAt;
  final String status;
}

class _NetworkTimelineEvent {
  const _NetworkTimelineEvent({
    required this.publicId,
    required this.eventType,
    required this.source,
    required this.occurredAt,
    required this.label,
    required this.notes,
    required this.personPublicId,
    required this.employmentLinkPublicId,
    required this.positionPublicId,
    required this.originPositionPublicId,
    required this.destinationPositionPublicId,
    required this.originLabel,
    required this.destinationLabel,
    required this.linkedEntities,
  });

  factory _NetworkTimelineEvent.fromMap(Map<String, dynamic> map) {
    return _NetworkTimelineEvent(
      publicId: map['publicId'] as String? ?? '',
      eventType: map['eventType'] as String? ?? '',
      source: map['source'] as String? ?? '',
      occurredAt: map['occurredAt'] as String?,
      label: map['label'] as String? ?? '',
      notes: map['notes'] as String?,
      personPublicId: map['personPublicId'] as String?,
      employmentLinkPublicId: map['employmentLinkPublicId'] as String?,
      positionPublicId: map['positionPublicId'] as String?,
      originPositionPublicId: map['originPositionPublicId'] as String?,
      destinationPositionPublicId:
          map['destinationPositionPublicId'] as String?,
      originLabel: map['originLabel'] as String?,
      destinationLabel: map['destinationLabel'] as String?,
      linkedEntities: _networkTimelineMapList(
        map['linkedEntities'],
        _NetworkTimelineLinkedEntity.fromMap,
      ),
    );
  }

  final String publicId;
  final String eventType;
  final String source;
  final String? occurredAt;
  final String label;
  final String? notes;
  final String? personPublicId;
  final String? employmentLinkPublicId;
  final String? positionPublicId;
  final String? originPositionPublicId;
  final String? destinationPositionPublicId;
  final String? originLabel;
  final String? destinationLabel;
  final List<_NetworkTimelineLinkedEntity> linkedEntities;

  bool get hasStructuredMove =>
      originPositionPublicId != null && destinationPositionPublicId != null;
}

class _NetworkTimelineLinkedEntity {
  const _NetworkTimelineLinkedEntity({
    required this.entityType,
    required this.entityPublicId,
    required this.labelSnapshot,
  });

  factory _NetworkTimelineLinkedEntity.fromMap(Map<String, dynamic> map) {
    return _NetworkTimelineLinkedEntity(
      entityType: map['entityType'] as String? ?? '',
      entityPublicId: map['entityPublicId'] as String?,
      labelSnapshot: map['labelSnapshot'] as String? ?? '',
    );
  }

  final String entityType;
  final String? entityPublicId;
  final String labelSnapshot;
}

class _NetworkTimelineCurrentSnapshot {
  const _NetworkTimelineCurrentSnapshot({
    required this.contracts,
    required this.positions,
    required this.collaborators,
  });

  factory _NetworkTimelineCurrentSnapshot.fromMap(Map<String, dynamic> map) {
    return _NetworkTimelineCurrentSnapshot(
      contracts: _networkTimelineMapList(
        map['contracts'],
        _NetworkTimelineSnapshotContract.fromMap,
      ),
      positions: _networkTimelineMapList(
        map['positions'],
        _NetworkTimelineSnapshotPosition.fromMap,
      ),
      collaborators: _networkTimelineMapList(
        map['collaborators'],
        _NetworkTimelineSnapshotCollaborator.fromMap,
      ),
    );
  }

  final List<_NetworkTimelineSnapshotContract> contracts;
  final List<_NetworkTimelineSnapshotPosition> positions;
  final List<_NetworkTimelineSnapshotCollaborator> collaborators;

  int get contractsCount => contracts.length;

  int get positionsCount => positions.length;

  int get collaboratorsCount => collaborators.length;

  List<_NetworkTimelineSnapshotPosition> positionsForContract(
    String contractPublicId,
  ) {
    return [
      for (final position in positions)
        if (position.contractPublicId == contractPublicId) position,
    ];
  }

  List<_NetworkTimelineSnapshotCollaborator> collaboratorsForPosition(
    String positionPublicId,
  ) {
    return [
      for (final collaborator in collaborators)
        if (collaborator.positionPublicId == positionPublicId) collaborator,
    ];
  }
}

class _NetworkTimelineSnapshotContract {
  const _NetworkTimelineSnapshotContract({
    required this.publicId,
    required this.displayName,
    required this.status,
    required this.activePositions,
    required this.activeCollaborators,
  });

  factory _NetworkTimelineSnapshotContract.fromMap(Map<String, dynamic> map) {
    return _NetworkTimelineSnapshotContract(
      publicId: _networkTimelineText(map, 'publicId'),
      displayName: _networkTimelineText(map, 'displayName'),
      status: _networkTimelineText(map, 'status'),
      activePositions: _networkTimelineInt(map, 'activePositions'),
      activeCollaborators: _networkTimelineInt(map, 'activeCollaborators'),
    );
  }

  final String publicId;
  final String displayName;
  final String status;
  final int activePositions;
  final int activeCollaborators;
}

class _NetworkTimelineSnapshotPosition {
  const _NetworkTimelineSnapshotPosition({
    required this.publicId,
    required this.contractPublicId,
    required this.displayName,
    required this.status,
    required this.activeCollaborators,
  });

  factory _NetworkTimelineSnapshotPosition.fromMap(Map<String, dynamic> map) {
    return _NetworkTimelineSnapshotPosition(
      publicId: _networkTimelineText(map, 'publicId'),
      contractPublicId: _networkTimelineText(map, 'contractPublicId'),
      displayName: _networkTimelineText(map, 'displayName'),
      status: _networkTimelineText(map, 'status'),
      activeCollaborators: _networkTimelineInt(map, 'activeCollaborators'),
    );
  }

  final String publicId;
  final String contractPublicId;
  final String displayName;
  final String status;
  final int activeCollaborators;
}

class _NetworkTimelineSnapshotCollaborator {
  const _NetworkTimelineSnapshotCollaborator({
    required this.personPublicId,
    required this.personName,
    required this.employmentLinkPublicId,
    required this.contractPublicId,
    required this.positionPublicId,
    required this.status,
  });

  factory _NetworkTimelineSnapshotCollaborator.fromMap(
    Map<String, dynamic> map,
  ) {
    return _NetworkTimelineSnapshotCollaborator(
      personPublicId: _networkTimelineText(map, 'personPublicId'),
      personName: _networkTimelineText(map, 'personName'),
      employmentLinkPublicId: _networkTimelineText(
        map,
        'employmentLinkPublicId',
      ),
      contractPublicId: _networkTimelineText(map, 'contractPublicId'),
      positionPublicId: _networkTimelineText(map, 'positionPublicId'),
      status: _networkTimelineText(map, 'status'),
    );
  }

  final String personPublicId;
  final String personName;
  final String employmentLinkPublicId;
  final String contractPublicId;
  final String positionPublicId;
  final String status;
}

class _NetworkTimelineLegend {
  const _NetworkTimelineLegend({
    required this.eventTypes,
    required this.relationshipStates,
  });

  factory _NetworkTimelineLegend.fromMap(Map<String, dynamic> map) {
    return _NetworkTimelineLegend(
      eventTypes: _networkTimelineMapList(
        map['eventTypes'],
        _NetworkGraphLegendEntry.fromMap,
      ),
      relationshipStates: _networkTimelineMapList(
        map['relationshipStates'],
        _NetworkGraphLegendEntry.fromMap,
      ),
    );
  }

  final List<_NetworkGraphLegendEntry> eventTypes;
  final List<_NetworkGraphLegendEntry> relationshipStates;
}

class _NetworkTimelineWarning {
  const _NetworkTimelineWarning({
    required this.code,
    required this.severity,
    required this.entityPublicId,
    required this.message,
  });

  factory _NetworkTimelineWarning.fromMap(Map<String, dynamic> map) {
    return _NetworkTimelineWarning(
      code: map['code'] as String? ?? '',
      severity: map['severity'] as String? ?? 'warning',
      entityPublicId: map['entityPublicId'] as String? ?? '',
      message: map['message'] as String? ?? '',
    );
  }

  final String code;
  final String severity;
  final String entityPublicId;
  final String message;
}

List<T> _networkTimelineMapList<T>(
  Object? value,
  T Function(Map<String, dynamic>) builder,
) {
  if (value is! List) {
    return <T>[];
  }

  return [
    for (final item in value)
      if (item is Map) builder(item.cast<String, dynamic>()),
  ];
}

String _networkTimelineText(Map<String, dynamic> map, String key) {
  final value = map[key];
  return value == null ? '' : '$value';
}

int _networkTimelineInt(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse('${value ?? ''}') ?? 0;
}

@visibleForTesting
Map<String, Object?> debugNetworkTimelinePayloadSummary(
  Map<String, dynamic> map,
) {
  final payload = _NetworkTimelinePayload.fromMap(map);
  final positionsCount = payload.contracts.fold<int>(
    0,
    (total, contract) => total + contract.positions.length,
  );
  final allocationsCount = payload.contracts.fold<int>(
    0,
    (total, contract) =>
        total +
        contract.positions.fold<int>(
          0,
          (positionTotal, position) =>
              positionTotal + position.allocations.length,
        ),
  );
  final moveEvent = payload.events.where((event) => event.eventType == 'move');

  return {
    'periodPreset': payload.period.preset,
    'periodFrom': payload.period.from,
    'periodTo': payload.period.to,
    'contractsCount': payload.contractsCount,
    'positionsCount': positionsCount,
    'allocationsCount': allocationsCount,
    'collaboratorsCount': payload.collaboratorsCount,
    'eventsCount': payload.events.length,
    'snapshotContractsCount': payload.currentSnapshot.contractsCount,
    'snapshotPositionsCount': payload.currentSnapshot.positionsCount,
    'snapshotCollaboratorsCount': payload.currentSnapshot.collaboratorsCount,
    'warningsCount': payload.warnings.length,
    'firstWarningCode': payload.warnings.isEmpty
        ? null
        : payload.warnings.first.code,
    'firstMoveHasStructuredLink': moveEvent.isEmpty
        ? null
        : moveEvent.first.hasStructuredMove,
    'metaTraceId': payload.meta.traceId,
  };
}
