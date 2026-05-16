part of '../../app/app.dart';

class _NetworkTimelinePayload {
  const _NetworkTimelinePayload({
    required this.period,
    required this.focus,
    required this.contractsCount,
    required this.collaboratorsCount,
    required this.events,
    required this.currentSnapshot,
    required this.warnings,
    required this.meta,
  });

  factory _NetworkTimelinePayload.fromMap(Map<String, dynamic> map) {
    final data = (map['data'] as Map?)?.cast<String, dynamic>() ?? map;
    final layers = (data['layers'] as Map?)?.cast<String, dynamic>() ?? const {};
    final meta = (map['meta'] as Map?)?.cast<String, dynamic>() ?? const {};

    return _NetworkTimelinePayload(
      period: _NetworkGraphPeriod.fromMap(
        (data['period'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      focus: _NetworkTimelineFocus.fromMap(
        (data['focus'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      contractsCount: (layers['contracts'] as List<dynamic>? ?? const []).length,
      collaboratorsCount:
          (layers['collaborators'] as List<dynamic>? ?? const []).length,
      events: [
        for (final event in (layers['events'] as List<dynamic>? ?? const []))
          _NetworkTimelineEvent.fromMap((event as Map).cast<String, dynamic>()),
      ],
      currentSnapshot: _NetworkTimelineCurrentSnapshot.fromMap(
        (data['currentSnapshot'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      warnings: [
        for (final warning in (data['warnings'] as List<dynamic>? ?? const []))
          _NetworkTimelineWarning.fromMap(
            (warning as Map).cast<String, dynamic>(),
          ),
      ],
      meta: _NetworkGraphMeta.fromMap(meta),
    );
  }

  final _NetworkGraphPeriod period;
  final _NetworkTimelineFocus focus;
  final int contractsCount;
  final int collaboratorsCount;
  final List<_NetworkTimelineEvent> events;
  final _NetworkTimelineCurrentSnapshot currentSnapshot;
  final List<_NetworkTimelineWarning> warnings;
  final _NetworkGraphMeta meta;
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
      linkedEntities: [
        for (final entity
            in (map['linkedEntities'] as List<dynamic>? ?? const []))
          _NetworkTimelineLinkedEntity.fromMap(
            (entity as Map).cast<String, dynamic>(),
          ),
      ],
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
  final List<_NetworkTimelineLinkedEntity> linkedEntities;
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
    required this.contractsCount,
    required this.positionsCount,
    required this.collaboratorsCount,
  });

  factory _NetworkTimelineCurrentSnapshot.fromMap(Map<String, dynamic> map) {
    return _NetworkTimelineCurrentSnapshot(
      contractsCount: (map['contracts'] as List<dynamic>? ?? const []).length,
      positionsCount: (map['positions'] as List<dynamic>? ?? const []).length,
      collaboratorsCount:
          (map['collaborators'] as List<dynamic>? ?? const []).length,
    );
  }

  final int contractsCount;
  final int positionsCount;
  final int collaboratorsCount;
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
