part of '../../../app/app.dart';

class _FocusBoardApiRepository {
  _FocusBoardApiRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<_FocusBoardRemoteNotePayload>> listAllNotes() async {
    final session = await _apiClient.ensureDevelopmentSession();
    final statuses = const ['ACTIVE', 'COMPLETED', 'ARCHIVED', 'TRASHED'];
    final results = await Future.wait([
      for (final status in statuses)
        _apiClient.getMap(
          'focus-board/notes',
          query: {'status': status, 'limit': '100'},
        ),
    ]);

    return [
      for (final data in results)
        for (final item in _apiMapList(data['items']))
          _focusBoardRemoteNoteFromApi(item, session: session, detail: false),
    ];
  }

  Future<_FocusBoardRemoteNotePayload> createNote(
    _FocusBoardNoteDraft draft, {
    required _ViewerAccessProfile viewerProfile,
    String? parentNotePublicId,
    String? clientMigrationId,
  }) async {
    final session = await _apiClient.ensureDevelopmentSession();
    final data = await _apiClient.postMap(
      'focus-board/notes',
      body: _focusBoardCreateBodyFromDraft(
        draft,
        parentNotePublicId: parentNotePublicId,
        clientMigrationId: clientMigrationId,
      ),
    );
    return _focusBoardRemoteNoteFromApi(data, session: session, detail: true);
  }

  Future<_FocusBoardRemoteNotePayload> updateNote(
    _FocusBoardNote note,
    Map<String, dynamic> body,
  ) async {
    final session = await _apiClient.ensureDevelopmentSession();
    final data = await _apiClient.patchMap(
      'focus-board/notes/${note.id}',
      body: {
        ...body,
        if (note.remoteVersion > 0) 'expectedVersion': note.remoteVersion,
      },
    );
    return _focusBoardRemoteNoteFromApi(data, session: session, detail: true);
  }

  Future<_FocusBoardRemoteNotePayload> completeNote(_FocusBoardNote note) {
    return _transition(note, 'complete');
  }

  Future<_FocusBoardRemoteNotePayload> reopenNote(_FocusBoardNote note) {
    return _transition(note, 'reopen');
  }

  Future<_FocusBoardRemoteNotePayload> archiveNote(_FocusBoardNote note) {
    return _transition(note, 'archive');
  }

  Future<_FocusBoardRemoteNotePayload> trashNote(_FocusBoardNote note) {
    return _transition(note, 'trash');
  }

  Future<_FocusBoardRemoteNotePayload> restoreNote(_FocusBoardNote note) {
    return _transition(note, 'restore');
  }

  Future<_FocusBoardRemoteNotePayload> deleteNote(_FocusBoardNote note) async {
    final session = await _apiClient.ensureDevelopmentSession();
    final data = await _apiClient.deleteMap('focus-board/notes/${note.id}');
    return _focusBoardRemoteNoteFromApi(data, session: session, detail: true);
  }

  Future<List<_FocusBoardRemoteEvent>> listEvents(String publicId) async {
    final data = await _apiClient.getMap('focus-board/notes/$publicId/events');
    return [
      for (final item in _apiMapList(data['items']))
        _FocusBoardRemoteEvent(
          publicId: _apiText(item['publicId']),
          eventType: _apiText(item['eventType'], fallback: 'UPDATED'),
          summary: _apiText(item['summary']),
          actorName: _apiText(item['actorName'], fallback: 'Sistema'),
          createdAt: _apiDate(item['createdAt']) ?? DateTime.now(),
        ),
    ];
  }

  Future<_FocusBoardRemoteNotePayload> _transition(
    _FocusBoardNote note,
    String action,
  ) async {
    final session = await _apiClient.ensureDevelopmentSession();
    final data = await _apiClient.postMap(
      'focus-board/notes/${note.id}/$action',
      body: {if (note.remoteVersion > 0) 'expectedVersion': note.remoteVersion},
    );
    return _focusBoardRemoteNoteFromApi(data, session: session, detail: true);
  }
}

Map<String, dynamic> _focusBoardCreateBodyFromDraft(
  _FocusBoardNoteDraft draft, {
  String? parentNotePublicId,
  String? clientMigrationId,
}) {
  final participants = _focusBoardParticipantsFromAssignments(
    draft.assignments,
    visibility: draft.visibility,
  );
  final contexts = _focusBoardContextsFromDraft(draft);
  return {
    'kind': 'NOTE',
    'title': draft.title.trim().isEmpty ? 'Nota' : draft.title.trim(),
    'body': draft.description.trim().isEmpty ? null : draft.description.trim(),
    'priority': _focusBoardPriorityApiValue(draft.priority),
    'visibility': _focusBoardVisibilityApiValue(draft.visibility),
    'completionMode': _focusBoardCompletionModeApiValue(
      draft.replicasEnabled
          ? draft.replicaMode
          : _FocusBoardReplicaMode.ownerOnly,
    ),
    'dueAt': draft.dueAt.toIso8601String(),
    if (parentNotePublicId != null && parentNotePublicId.trim().isNotEmpty)
      'parentNotePublicId': parentNotePublicId.trim(),
    if (clientMigrationId != null && clientMigrationId.trim().isNotEmpty)
      'clientMigrationId': clientMigrationId.trim(),
    'contexts': contexts,
    'participants': participants,
  };
}

Map<String, dynamic> _focusBoardUpdateBodyFromDraft(
  _FocusBoardNoteDraft draft,
) {
  return {
      ..._focusBoardCreateBodyFromDraft(draft),
      'editJustification': 'Atualizacao feita pela interface Focus Board.',
    }
    ..remove('kind')
    ..remove('parentNotePublicId')
    ..remove('clientMigrationId');
}

List<Map<String, dynamic>> _focusBoardContextsFromDraft(
  _FocusBoardNoteDraft draft,
) {
  final contexts = <Map<String, dynamic>>[];
  final companyLabel = draft.companyLabel.trim();
  if (companyLabel.isNotEmpty) {
    contexts.add({'contextType': 'OTHER', 'externalLabel': companyLabel});
  }
  for (final assignment in draft.assignments) {
    switch (assignment.type) {
      case _FocusBoardAssignmentType.person:
        contexts.add({
          'contextType': 'PERSON',
          'contextPublicId': assignment.id,
        });
        break;
      case _FocusBoardAssignmentType.contract:
        contexts.add({
          'contextType': 'CONTRACT',
          'contextPublicId': assignment.id,
        });
        break;
      case _FocusBoardAssignmentType.company:
      case _FocusBoardAssignmentType.group:
      case _FocusBoardAssignmentType.other:
        if (assignment.label.trim().isNotEmpty) {
          contexts.add({
            'contextType': 'OTHER',
            'externalLabel': assignment.label.trim(),
          });
        }
        break;
    }
  }
  return contexts.take(20).toList(growable: false);
}

List<Map<String, dynamic>> _focusBoardParticipantsFromAssignments(
  List<_FocusBoardAssignment> assignments, {
  required _FocusBoardNoteVisibility visibility,
}) {
  if (visibility == _FocusBoardNoteVisibility.private) {
    return const [];
  }

  final participants = <Map<String, dynamic>>[];
  for (final assignment in assignments) {
    if (assignment.type != _FocusBoardAssignmentType.group) {
      continue;
    }
    final group = _audienceGroupFromKey(assignment.id);
    if (group == null) {
      continue;
    }
    participants.add({
      'participantType': 'SENSITIVE_AUDIENCE_GROUP',
      'audienceGroupKey': group.key,
      'role': 'VIEWER',
      'canComplete': true,
      'requiredForCompletion': false,
    });
  }
  return participants;
}

_FocusBoardRemoteNotePayload _focusBoardRemoteNoteFromApi(
  Map<String, dynamic> item, {
  required SessionSnapshot session,
  required bool detail,
}) {
  final owner = _apiMap(item['owner']);
  final ownerPublicId = _apiText(
    owner['publicId'],
    fallback: session.userPublicId,
  );
  final ownerName = _apiText(owner['name'], fallback: session.userName);
  final status = _apiText(item['status'], fallback: 'ACTIVE').toUpperCase();
  final title = _apiText(item['title'], fallback: 'Nota');
  final body = detail ? _apiText(item['body']) : _apiText(item['bodyPreview']);
  final createdAt = _apiDate(item['createdAt']) ?? DateTime.now();
  final updatedAt = _apiDate(item['updatedAt']);
  final completedAt = _apiDate(item['completedAt']);
  final archivedAt = _apiDate(item['archivedAt']);
  final trashedAt = _apiDate(item['trashedAt']);
  final contexts = _apiMapList(item['contexts']);
  final companyLabel = _focusBoardCompanyLabelFromContexts(contexts);
  final assignments = _focusBoardAssignmentsFromApi(item);
  final permissions = _FocusBoardRemotePermissions.fromApi(
    _apiMap(item['permissions']),
  );
  final note = _FocusBoardNote(
    id: _apiText(item['publicId']),
    title: title,
    description: body,
    priority: _focusBoardPriorityFromApi(item['priority']),
    dueAt: _apiDate(item['dueAt']) ?? updatedAt ?? createdAt,
    createdAt: createdAt,
    createdById: ownerPublicId,
    createdByName: ownerName,
    updatedAt: updatedAt,
    lastEditedAt: updatedAt,
    companyLabel: companyLabel,
    visibility: _focusBoardVisibilityFromApi(item['visibility']),
    replicasEnabled:
        _focusBoardCompletionModeFromApi(item['completionMode']) !=
        _FocusBoardReplicaMode.ownerOnly,
    replicaMode: _focusBoardCompletionModeFromApi(item['completionMode']),
    assignments: assignments,
    completedByOwner: status == 'COMPLETED',
    completedAt: completedAt,
    inTrash: status == 'TRASHED',
    trashedAt: trashedAt,
    inArchive: status == 'ARCHIVED',
    archivedAt: archivedAt,
    isDraft: false,
    remoteVersion: _apiInt(item['version']),
    remotePermissions: permissions,
    audit: [
      _FocusBoardAuditEntry(
        at: updatedAt ?? createdAt,
        actorId: ownerPublicId,
        actorName: ownerName,
        action: status.toLowerCase(),
        details: 'Nota sincronizada pelo backend do Focus Board.',
      ),
    ],
  );

  return _FocusBoardRemoteNotePayload(
    note: note,
    version: note.remoteVersion,
    permissions: permissions,
  );
}

String _focusBoardCompanyLabelFromContexts(
  List<Map<String, dynamic>> contexts,
) {
  for (final context in contexts) {
    final type = _apiText(context['contextType']).toUpperCase();
    if (type == 'PROVIDER_COMPANY' ||
        type == 'CLIENT_COMPANY' ||
        type == 'CONTRACT' ||
        type == 'OTHER') {
      final label = _apiText(context['label']);
      if (label.isNotEmpty) {
        return label;
      }
    }
  }
  return '';
}

List<_FocusBoardAssignment> _focusBoardAssignmentsFromApi(
  Map<String, dynamic> item,
) {
  final participants = _apiMapList(item['participants']);
  return [
    for (final participant in participants)
      if (_focusBoardAssignmentFromParticipant(participant) != null)
        _focusBoardAssignmentFromParticipant(participant)!,
  ];
}

_FocusBoardAssignment? _focusBoardAssignmentFromParticipant(
  Map<String, dynamic> participant,
) {
  final participantType = _apiText(
    participant['participantType'],
  ).toUpperCase();
  if (participantType == 'USER') {
    final user = _apiMap(participant['user']);
    final publicId = _apiText(user['publicId']);
    if (publicId.isEmpty) {
      return null;
    }
    return _FocusBoardAssignment(
      type: _FocusBoardAssignmentType.person,
      id: publicId,
      label: _apiText(user['name'], fallback: publicId),
      completed: participant['completedAt'] != null,
      completedAt: _apiDate(participant['completedAt']),
    );
  }
  if (participantType == 'SENSITIVE_AUDIENCE_GROUP') {
    final groupKey = _apiText(participant['audienceGroupKey']);
    final group = _audienceGroupFromKey(groupKey);
    if (group == null) {
      return null;
    }
    return _FocusBoardAssignment(
      type: _FocusBoardAssignmentType.group,
      id: group.key,
      label: group.label,
      completed: participant['completedAt'] != null,
      completedAt: _apiDate(participant['completedAt']),
    );
  }
  if (participantType == 'ACCESS_PROFILE') {
    final profile = _apiMap(participant['accessProfile']);
    final code = _apiText(profile['code']);
    if (code.isEmpty) {
      return null;
    }
    return _FocusBoardAssignment(
      type: _FocusBoardAssignmentType.group,
      id: code,
      label: _apiText(profile['name'], fallback: code),
      completed: participant['completedAt'] != null,
      completedAt: _apiDate(participant['completedAt']),
    );
  }
  return null;
}

String _focusBoardPriorityApiValue(_FocusBoardNotePriority priority) {
  return switch (priority) {
    _FocusBoardNotePriority.normal => 'NORMAL',
    _FocusBoardNotePriority.important => 'IMPORTANT',
    _FocusBoardNotePriority.urgent => 'URGENT',
  };
}

_FocusBoardNotePriority _focusBoardPriorityFromApi(Object? value) {
  return switch (_apiText(value).toUpperCase()) {
    'URGENT' => _FocusBoardNotePriority.urgent,
    'IMPORTANT' => _FocusBoardNotePriority.important,
    _ => _FocusBoardNotePriority.normal,
  };
}

String _focusBoardVisibilityApiValue(_FocusBoardNoteVisibility visibility) {
  return switch (visibility) {
    _FocusBoardNoteVisibility.private => 'PRIVATE',
    _FocusBoardNoteVisibility.shared => 'SHARED',
  };
}

_FocusBoardNoteVisibility _focusBoardVisibilityFromApi(Object? value) {
  return _apiText(value).toUpperCase() == 'SHARED'
      ? _FocusBoardNoteVisibility.shared
      : _FocusBoardNoteVisibility.private;
}

String _focusBoardCompletionModeApiValue(_FocusBoardReplicaMode mode) {
  return switch (mode) {
    _FocusBoardReplicaMode.ownerOnly => 'OWNER_ONLY',
    _FocusBoardReplicaMode.firstCompletesAll => 'FIRST_COMPLETES_ALL',
    _FocusBoardReplicaMode.allMustComplete => 'ALL_MUST_COMPLETE',
  };
}

_FocusBoardReplicaMode _focusBoardCompletionModeFromApi(Object? value) {
  return switch (_apiText(value).toUpperCase()) {
    'FIRST_COMPLETES_ALL' => _FocusBoardReplicaMode.firstCompletesAll,
    'ALL_MUST_COMPLETE' => _FocusBoardReplicaMode.allMustComplete,
    _ => _FocusBoardReplicaMode.ownerOnly,
  };
}

String _focusBoardApiErrorMessage(Object error) {
  if (error is ApiException) {
    return 'API do Focus Board indisponivel (${error.code}). ${error.message}';
  }
  return 'Nao foi possivel carregar notas do Focus Board pela API.';
}
