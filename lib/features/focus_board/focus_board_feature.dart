part of '../../app/app.dart';

enum _FocusBoardNotePriority { normal, important, urgent }

enum _FocusBoardNoteCompletionState { incomplete, partial, complete }

enum _FocusBoardNoteStatusFilter { pending, completed, all }

enum _FocusBoardNoteSort {
  createdAt,
  editedOrCreatedAt,
  creatorName,
  creatorId,
  company,
  status,
}

enum _FocusBoardNoteVisibility { private, shared }

enum _FocusBoardReplicaMode { ownerOnly, firstCompletesAll, allMustComplete }

enum _FocusBoardAssignmentType { person, group, company, contract, other }

enum _FocusBoardTextCommitResult { none, draftSaved, textUpdated }

enum _FocusBoardTaskMode { reminder, alarm, timer }

extension on _FocusBoardTaskMode {
  String get label => switch (this) {
    _FocusBoardTaskMode.reminder => 'Lembrete',
    _FocusBoardTaskMode.alarm => 'Alarme',
    _FocusBoardTaskMode.timer => 'Timer',
  };

  String get dialogTitle => switch (this) {
    _FocusBoardTaskMode.reminder => 'Novo lembrete',
    _FocusBoardTaskMode.alarm => 'Novo alarme',
    _FocusBoardTaskMode.timer => 'Novo timer',
  };

  String get defaultTitle => switch (this) {
    _FocusBoardTaskMode.reminder => 'Novo lembrete',
    _FocusBoardTaskMode.alarm => 'Novo alarme',
    _FocusBoardTaskMode.timer => 'Novo timer',
  };

  String get defaultDescription => switch (this) {
    _FocusBoardTaskMode.reminder =>
      'Registrar lembrete com notificacao por canais externos.',
    _FocusBoardTaskMode.alarm =>
      'Configurar alarme para aviso ativo no horario definido.',
    _FocusBoardTaskMode.timer =>
      'Criar timer com aviso ao fim do periodo configurado.',
  };

  String get category => switch (this) {
    _FocusBoardTaskMode.reminder => 'TASK_REMINDER',
    _FocusBoardTaskMode.alarm => 'TASK_ALARM',
    _FocusBoardTaskMode.timer => 'TASK_TIMER',
  };

  String get kind => switch (this) {
    _FocusBoardTaskMode.reminder ||
    _FocusBoardTaskMode.alarm ||
    _FocusBoardTaskMode.timer => 'REMINDER',
  };

  String get defaultPriority => switch (this) {
    _FocusBoardTaskMode.reminder => 'NORMAL',
    _FocusBoardTaskMode.alarm => 'HIGH',
    _FocusBoardTaskMode.timer => 'NORMAL',
  };

  String get defaultNotificationPolicy => switch (this) {
    _FocusBoardTaskMode.reminder => 'ONE_BUSINESS_DAY_BEFORE',
    _FocusBoardTaskMode.alarm || _FocusBoardTaskMode.timer => 'ON_DUE_DATE',
  };

  IconData get icon => switch (this) {
    _FocusBoardTaskMode.reminder => Icons.add_circle_outline_rounded,
    _FocusBoardTaskMode.alarm => Icons.notifications_none_rounded,
    _FocusBoardTaskMode.timer => Icons.timer_outlined,
  };
}

extension on _FocusBoardNotePriority {
  String get key => switch (this) {
    _FocusBoardNotePriority.normal => 'normal',
    _FocusBoardNotePriority.important => 'important',
    _FocusBoardNotePriority.urgent => 'urgent',
  };

  String get label => switch (this) {
    _FocusBoardNotePriority.normal => 'Normal',
    _FocusBoardNotePriority.important => 'Importante',
    _FocusBoardNotePriority.urgent => 'Urgente',
  };

  Color get color => switch (this) {
    _FocusBoardNotePriority.normal => _tealColor,
    _FocusBoardNotePriority.important => const Color(0xFFE9A100),
    _FocusBoardNotePriority.urgent => const Color(0xFFD81F2A),
  };

  IconData get icon => switch (this) {
    _FocusBoardNotePriority.normal => Icons.check_circle_outline_rounded,
    _FocusBoardNotePriority.important => Icons.star_rounded,
    _FocusBoardNotePriority.urgent => Icons.priority_high_rounded,
  };
}

extension on _FocusBoardNoteCompletionState {
  String get label => switch (this) {
    _FocusBoardNoteCompletionState.incomplete => 'Incompleto',
    _FocusBoardNoteCompletionState.partial => 'Parcial',
    _FocusBoardNoteCompletionState.complete => 'Completo',
  };

  int get sortRank => switch (this) {
    _FocusBoardNoteCompletionState.incomplete => 0,
    _FocusBoardNoteCompletionState.partial => 1,
    _FocusBoardNoteCompletionState.complete => 2,
  };

  Color get color => switch (this) {
    _FocusBoardNoteCompletionState.incomplete => _roseColor,
    _FocusBoardNoteCompletionState.partial => _amberColor,
    _FocusBoardNoteCompletionState.complete => _tealColor,
  };
}

extension on _FocusBoardNoteStatusFilter {
  String get label => switch (this) {
    _FocusBoardNoteStatusFilter.pending => 'Pendentes',
    _FocusBoardNoteStatusFilter.completed => 'Concluidos',
    _FocusBoardNoteStatusFilter.all => 'Todos',
  };
}

extension on _FocusBoardNoteSort {
  String get label => switch (this) {
    _FocusBoardNoteSort.createdAt => 'Data de criacao',
    _FocusBoardNoteSort.editedOrCreatedAt => 'Edicao/criacao',
    _FocusBoardNoteSort.creatorName => 'Nome de quem escreveu',
    _FocusBoardNoteSort.creatorId => 'ID de quem escreveu',
    _FocusBoardNoteSort.company => 'Empresa vinculada',
    _FocusBoardNoteSort.status => 'Status',
  };
}

extension on _FocusBoardNoteVisibility {
  String get key => switch (this) {
    _FocusBoardNoteVisibility.private => 'private',
    _FocusBoardNoteVisibility.shared => 'shared',
  };

  String get label => switch (this) {
    _FocusBoardNoteVisibility.private => 'Somente eu',
    _FocusBoardNoteVisibility.shared => 'Compartilhada',
  };
}

extension on _FocusBoardReplicaMode {
  String get key => switch (this) {
    _FocusBoardReplicaMode.ownerOnly => 'ownerOnly',
    _FocusBoardReplicaMode.firstCompletesAll => 'firstCompletesAll',
    _FocusBoardReplicaMode.allMustComplete => 'allMustComplete',
  };

  String get label => switch (this) {
    _FocusBoardReplicaMode.ownerOnly => 'Sem replicas',
    _FocusBoardReplicaMode.firstCompletesAll => 'Primeiro completa todos',
    _FocusBoardReplicaMode.allMustComplete => 'Todos precisam preencher',
  };
}

extension on _FocusBoardAssignmentType {
  String get key => switch (this) {
    _FocusBoardAssignmentType.person => 'person',
    _FocusBoardAssignmentType.group => 'group',
    _FocusBoardAssignmentType.company => 'company',
    _FocusBoardAssignmentType.contract => 'contract',
    _FocusBoardAssignmentType.other => 'other',
  };

  String get label => switch (this) {
    _FocusBoardAssignmentType.person => 'Pessoa',
    _FocusBoardAssignmentType.group => 'Grupo',
    _FocusBoardAssignmentType.company => 'Empresa',
    _FocusBoardAssignmentType.contract => 'Contrato',
    _FocusBoardAssignmentType.other => 'Outro',
  };
}

_FocusBoardNoteVisibility _focusBoardVisibilityFromKey(String value) {
  final key = value.trim().toLowerCase();
  for (final visibility in _FocusBoardNoteVisibility.values) {
    if (visibility.key.toLowerCase() == key) {
      return visibility;
    }
  }
  return _FocusBoardNoteVisibility.private;
}

_FocusBoardReplicaMode _focusBoardReplicaModeFromKey(String value) {
  final key = value.trim();
  for (final mode in _FocusBoardReplicaMode.values) {
    if (mode.key == key) {
      return mode;
    }
  }
  return _FocusBoardReplicaMode.ownerOnly;
}

_FocusBoardNotePriority _focusBoardPriorityFromKey(String value) {
  final key = value.trim().toLowerCase();
  for (final priority in _FocusBoardNotePriority.values) {
    if (priority.key == key) {
      return priority;
    }
  }
  return _FocusBoardNotePriority.normal;
}

_FocusBoardAssignmentType _focusBoardAssignmentTypeFromKey(String value) {
  final key = value.trim().toLowerCase();
  for (final type in _FocusBoardAssignmentType.values) {
    if (type.key == key) {
      return type;
    }
  }
  return _FocusBoardAssignmentType.other;
}

String _focusBoardDateKey(DateTime value) {
  final local = value.toLocal();
  return '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}

String _focusBoardShortDateLabel(DateTime value) {
  final local = value.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/'
      '${local.month.toString().padLeft(2, '0')}/${local.year}';
}

String _focusBoardShortDateTimeLabel(DateTime value) {
  final local = value.toLocal();
  return '${_focusBoardShortDateLabel(local)} '
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}

DateTime? _focusBoardDateFromJson(Object? value) {
  if (value is! String || value.trim().isEmpty) {
    return null;
  }
  return DateTime.tryParse(value)?.toLocal();
}

String _focusBoardParentNoteIdFromAudit(
  List<_FocusBoardAuditEntry> auditEntries,
) {
  for (final entry in auditEntries) {
    final match = RegExp(
      r'nota\s+(fbn-\d+)',
      caseSensitive: false,
    ).firstMatch(entry.details);
    if (match != null) {
      return match.group(1) ?? '';
    }
  }
  return '';
}

String _focusBoardText(Object? value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

String _focusBoardActorId(_ViewerAccessProfile viewerProfile) {
  final publicId = viewerProfile.publicId?.trim();
  if (publicId != null && publicId.isNotEmpty) {
    return publicId;
  }
  return viewerProfile.key.trim().isEmpty ? 'public' : viewerProfile.key.trim();
}

bool _focusBoardIsEmptyDraftText(String title, String description) {
  final normalizedTitle = title.trim();
  return (normalizedTitle.isEmpty || normalizedTitle == 'Nova nota') &&
      description.trim().isEmpty;
}

String _focusBoardTitleForSavedDraft(String title, String description) {
  final normalizedTitle = title.trim();
  if (normalizedTitle.isNotEmpty && normalizedTitle != 'Nova nota') {
    return normalizedTitle;
  }
  return description.trim().isEmpty ? 'Nova nota' : 'Nota';
}

class _FocusBoardAssignment {
  const _FocusBoardAssignment({
    required this.type,
    required this.id,
    required this.label,
    this.completed = false,
    this.completedAt,
    this.completedById = '',
    this.completedByName = '',
  });

  final _FocusBoardAssignmentType type;
  final String id;
  final String label;
  final bool completed;
  final DateTime? completedAt;
  final String completedById;
  final String completedByName;

  bool matchesViewer(_ViewerAccessProfile viewerProfile) {
    final actorId = _focusBoardActorId(viewerProfile);
    final normalizedId = id.trim().toLowerCase();
    return switch (type) {
      _FocusBoardAssignmentType.person => normalizedId == actorId.toLowerCase(),
      _FocusBoardAssignmentType.group => viewerProfile.groups.any(
        (group) => group.key.toLowerCase() == normalizedId,
      ),
      _FocusBoardAssignmentType.company =>
        viewerProfile.organizationLabel?.trim().toLowerCase() == normalizedId,
      _FocusBoardAssignmentType.contract => false,
      _FocusBoardAssignmentType.other => false,
    };
  }

  _FocusBoardAssignment copyWith({
    _FocusBoardAssignmentType? type,
    String? id,
    String? label,
    bool? completed,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    String? completedById,
    String? completedByName,
  }) {
    return _FocusBoardAssignment(
      type: type ?? this.type,
      id: id ?? this.id,
      label: label ?? this.label,
      completed: completed ?? this.completed,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
      completedById: completedById ?? this.completedById,
      completedByName: completedByName ?? this.completedByName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.key,
      'id': id,
      'label': label,
      'completed': completed,
      'completedAt': completedAt?.toIso8601String(),
      'completedById': completedById,
      'completedByName': completedByName,
    };
  }

  static _FocusBoardAssignment fromJson(Map<String, dynamic> json) {
    return _FocusBoardAssignment(
      type: _focusBoardAssignmentTypeFromKey(_focusBoardText(json['type'])),
      id: _focusBoardText(json['id']),
      label: _focusBoardText(json['label'], fallback: 'Responsavel'),
      completed: json['completed'] == true,
      completedAt: _focusBoardDateFromJson(json['completedAt']),
      completedById: _focusBoardText(json['completedById']),
      completedByName: _focusBoardText(json['completedByName']),
    );
  }
}

class _FocusBoardAuditEntry {
  const _FocusBoardAuditEntry({
    required this.at,
    required this.actorId,
    required this.actorName,
    required this.action,
    required this.details,
  });

  final DateTime at;
  final String actorId;
  final String actorName;
  final String action;
  final String details;

  Map<String, dynamic> toJson() {
    return {
      'at': at.toIso8601String(),
      'actorId': actorId,
      'actorName': actorName,
      'action': action,
      'details': details,
    };
  }

  static _FocusBoardAuditEntry fromJson(Map<String, dynamic> json) {
    return _FocusBoardAuditEntry(
      at: _focusBoardDateFromJson(json['at']) ?? DateTime.now(),
      actorId: _focusBoardText(json['actorId'], fallback: 'system'),
      actorName: _focusBoardText(json['actorName'], fallback: 'Sistema'),
      action: _focusBoardText(json['action'], fallback: 'registro'),
      details: _focusBoardText(json['details']),
    );
  }
}

class _FocusBoardNoteDraft {
  const _FocusBoardNoteDraft({
    required this.title,
    required this.description,
    required this.priority,
    required this.dueAt,
    required this.companyLabel,
    required this.assignments,
    this.visibility = _FocusBoardNoteVisibility.private,
    this.replicasEnabled = true,
    this.replicaMode = _FocusBoardReplicaMode.ownerOnly,
  });

  final String title;
  final String description;
  final _FocusBoardNotePriority priority;
  final DateTime dueAt;
  final String companyLabel;
  final List<_FocusBoardAssignment> assignments;
  final _FocusBoardNoteVisibility visibility;
  final bool replicasEnabled;
  final _FocusBoardReplicaMode replicaMode;
}

class _FocusBoardNote {
  const _FocusBoardNote({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.dueAt,
    required this.createdAt,
    required this.createdById,
    required this.createdByName,
    this.parentNoteId = '',
    this.rootNoteId = '',
    this.updatedAt,
    this.lastEditedAt,
    this.companyLabel = '',
    this.visibility = _FocusBoardNoteVisibility.private,
    this.replicasEnabled = true,
    this.replicaMode = _FocusBoardReplicaMode.ownerOnly,
    this.closedAt,
    this.closedById = '',
    this.closedByName = '',
    this.assignments = const [],
    this.completedByOwner = false,
    this.completedAt,
    this.inTrash = false,
    this.trashedAt,
    this.inArchive = false,
    this.archivedAt,
    this.restoredFromAutoTrash = false,
    this.isDraft = false,
    this.audit = const [],
  });

  final String id;
  final String title;
  final String description;
  final _FocusBoardNotePriority priority;
  final DateTime dueAt;
  final DateTime createdAt;
  final String createdById;
  final String createdByName;
  final String parentNoteId;
  final String rootNoteId;
  final DateTime? updatedAt;
  final DateTime? lastEditedAt;
  final String companyLabel;
  final _FocusBoardNoteVisibility visibility;
  final bool replicasEnabled;
  final _FocusBoardReplicaMode replicaMode;
  final DateTime? closedAt;
  final String closedById;
  final String closedByName;
  final List<_FocusBoardAssignment> assignments;
  final bool completedByOwner;
  final DateTime? completedAt;
  final bool inTrash;
  final DateTime? trashedAt;
  final bool inArchive;
  final DateTime? archivedAt;
  final bool restoredFromAutoTrash;
  final bool isDraft;
  final List<_FocusBoardAuditEntry> audit;

  bool isCreator(_ViewerAccessProfile viewerProfile) {
    return createdById == _focusBoardActorId(viewerProfile);
  }

  bool canViewerRead(_ViewerAccessProfile viewerProfile) {
    if (isCreator(viewerProfile)) {
      return true;
    }
    if (visibility == _FocusBoardNoteVisibility.private) {
      return false;
    }
    if (assignments.isEmpty) {
      return viewerProfile.isAuthenticated;
    }
    if (viewerAssigned(viewerProfile)) {
      return true;
    }
    final hasBroadTarget = assignments.any(
      (assignment) =>
          assignment.type == _FocusBoardAssignmentType.contract ||
          assignment.type == _FocusBoardAssignmentType.other,
    );
    return hasBroadTarget && viewerProfile.isAuthenticated;
  }

  bool viewerAssigned(_ViewerAccessProfile viewerProfile) {
    return assignments.any(
      (assignment) => assignment.matchesViewer(viewerProfile),
    );
  }

  bool get hasAssignments => assignments.isNotEmpty;

  bool get hasMultipleAssignments => assignments.length > 1;

  bool get isManualReplica {
    return parentNoteId.isNotEmpty ||
        audit.any((entry) => entry.action == 'replica gerada');
  }

  int get completedAssignmentCount {
    return assignments.where((assignment) => assignment.completed).length;
  }

  bool get isClosed => closedAt != null;

  _FocusBoardNoteCompletionState get completionState {
    if (isClosed) {
      return _FocusBoardNoteCompletionState.complete;
    }
    final anyAssignmentComplete = completedAssignmentCount > 0;
    final allAssignmentsComplete =
        assignments.isNotEmpty &&
        completedAssignmentCount == assignments.length;
    final fullyComplete = switch (replicasEnabled
        ? replicaMode
        : _FocusBoardReplicaMode.ownerOnly) {
      _FocusBoardReplicaMode.ownerOnly => completedByOwner,
      _FocusBoardReplicaMode.firstCompletesAll =>
        completedByOwner || anyAssignmentComplete,
      _FocusBoardReplicaMode.allMustComplete =>
        assignments.isEmpty ? completedByOwner : allAssignmentsComplete,
    };
    if (fullyComplete) {
      return _FocusBoardNoteCompletionState.complete;
    }
    if (completedByOwner || completedAssignmentCount > 0) {
      return _FocusBoardNoteCompletionState.partial;
    }
    return _FocusBoardNoteCompletionState.incomplete;
  }

  DateTime get editedOrCreatedAt => lastEditedAt ?? updatedAt ?? createdAt;

  bool get isComplete =>
      completionState == _FocusBoardNoteCompletionState.complete;

  _FocusBoardNote copyWith({
    String? id,
    String? title,
    String? description,
    _FocusBoardNotePriority? priority,
    DateTime? dueAt,
    DateTime? createdAt,
    String? createdById,
    String? createdByName,
    String? parentNoteId,
    String? rootNoteId,
    DateTime? updatedAt,
    bool clearUpdatedAt = false,
    DateTime? lastEditedAt,
    bool clearLastEditedAt = false,
    String? companyLabel,
    _FocusBoardNoteVisibility? visibility,
    bool? replicasEnabled,
    _FocusBoardReplicaMode? replicaMode,
    DateTime? closedAt,
    bool clearClosedAt = false,
    String? closedById,
    String? closedByName,
    List<_FocusBoardAssignment>? assignments,
    bool? completedByOwner,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    bool? inTrash,
    DateTime? trashedAt,
    bool clearTrashedAt = false,
    bool? inArchive,
    DateTime? archivedAt,
    bool clearArchivedAt = false,
    bool? restoredFromAutoTrash,
    bool? isDraft,
    List<_FocusBoardAuditEntry>? audit,
  }) {
    return _FocusBoardNote(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueAt: dueAt ?? this.dueAt,
      createdAt: createdAt ?? this.createdAt,
      createdById: createdById ?? this.createdById,
      createdByName: createdByName ?? this.createdByName,
      parentNoteId: parentNoteId ?? this.parentNoteId,
      rootNoteId: rootNoteId ?? this.rootNoteId,
      updatedAt: clearUpdatedAt ? null : updatedAt ?? this.updatedAt,
      lastEditedAt: clearLastEditedAt
          ? null
          : lastEditedAt ?? this.lastEditedAt,
      companyLabel: companyLabel ?? this.companyLabel,
      visibility: visibility ?? this.visibility,
      replicasEnabled: replicasEnabled ?? this.replicasEnabled,
      replicaMode: replicaMode ?? this.replicaMode,
      closedAt: clearClosedAt ? null : closedAt ?? this.closedAt,
      closedById: clearClosedAt ? '' : closedById ?? this.closedById,
      closedByName: clearClosedAt ? '' : closedByName ?? this.closedByName,
      assignments: assignments ?? this.assignments,
      completedByOwner: completedByOwner ?? this.completedByOwner,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
      inTrash: inTrash ?? this.inTrash,
      trashedAt: clearTrashedAt ? null : trashedAt ?? this.trashedAt,
      inArchive: inArchive ?? this.inArchive,
      archivedAt: clearArchivedAt ? null : archivedAt ?? this.archivedAt,
      restoredFromAutoTrash:
          restoredFromAutoTrash ?? this.restoredFromAutoTrash,
      isDraft: isDraft ?? this.isDraft,
      audit: audit ?? this.audit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.key,
      'dueAt': dueAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'createdById': createdById,
      'createdByName': createdByName,
      'parentNoteId': parentNoteId,
      'rootNoteId': rootNoteId,
      'updatedAt': updatedAt?.toIso8601String(),
      'lastEditedAt': lastEditedAt?.toIso8601String(),
      'companyLabel': companyLabel,
      'visibility': visibility.key,
      'replicasEnabled': replicasEnabled,
      'replicaMode': replicaMode.key,
      'closedAt': closedAt?.toIso8601String(),
      'closedById': closedById,
      'closedByName': closedByName,
      'assignments': assignments
          .map((assignment) => assignment.toJson())
          .toList(),
      'completedByOwner': completedByOwner,
      'completedAt': completedAt?.toIso8601String(),
      'inTrash': inTrash,
      'trashedAt': trashedAt?.toIso8601String(),
      'inArchive': inArchive,
      'archivedAt': archivedAt?.toIso8601String(),
      'restoredFromAutoTrash': restoredFromAutoTrash,
      'isDraft': isDraft,
      'audit': audit.map((entry) => entry.toJson()).toList(),
    };
  }

  static _FocusBoardNote fromJson(Map<String, dynamic> json) {
    final assignmentsRaw = json['assignments'];
    final auditRaw = json['audit'];
    final auditEntries = auditRaw is List
        ? [
            for (final entry in auditRaw)
              if (entry is Map)
                _FocusBoardAuditEntry.fromJson(
                  Map<String, dynamic>.from(entry),
                ),
          ]
        : const <_FocusBoardAuditEntry>[];
    final parentNoteId = _focusBoardText(
      json['parentNoteId'],
      fallback: _focusBoardParentNoteIdFromAudit(auditEntries),
    );
    return _FocusBoardNote(
      id: _focusBoardText(json['id']),
      title: _focusBoardText(json['title'], fallback: 'Nota'),
      description: _focusBoardText(json['description']),
      priority: _focusBoardPriorityFromKey(_focusBoardText(json['priority'])),
      dueAt:
          _focusBoardDateFromJson(json['dueAt']) ??
          DateTime.now().add(const Duration(days: 7)),
      createdAt: _focusBoardDateFromJson(json['createdAt']) ?? DateTime.now(),
      createdById: _focusBoardText(json['createdById'], fallback: 'system'),
      createdByName: _focusBoardText(
        json['createdByName'],
        fallback: 'Sistema',
      ),
      parentNoteId: parentNoteId,
      rootNoteId: _focusBoardText(json['rootNoteId'], fallback: parentNoteId),
      updatedAt: _focusBoardDateFromJson(json['updatedAt']),
      lastEditedAt: _focusBoardDateFromJson(json['lastEditedAt']),
      companyLabel: _focusBoardText(json['companyLabel']),
      visibility: _focusBoardVisibilityFromKey(
        _focusBoardText(json['visibility']),
      ),
      replicasEnabled: json['replicasEnabled'] != false,
      replicaMode: _focusBoardReplicaModeFromKey(
        _focusBoardText(json['replicaMode']),
      ),
      closedAt: _focusBoardDateFromJson(json['closedAt']),
      closedById: _focusBoardText(json['closedById']),
      closedByName: _focusBoardText(json['closedByName']),
      assignments: assignmentsRaw is List
          ? [
              for (final assignment in assignmentsRaw)
                if (assignment is Map)
                  _FocusBoardAssignment.fromJson(
                    Map<String, dynamic>.from(assignment),
                  ),
            ]
          : const [],
      completedByOwner: json['completedByOwner'] == true,
      completedAt: _focusBoardDateFromJson(json['completedAt']),
      inTrash: json['inTrash'] == true,
      trashedAt: _focusBoardDateFromJson(json['trashedAt']),
      inArchive: json['inArchive'] == true,
      archivedAt: _focusBoardDateFromJson(json['archivedAt']),
      restoredFromAutoTrash: json['restoredFromAutoTrash'] == true,
      isDraft: json['isDraft'] == true,
      audit: auditEntries,
    );
  }
}

class _FocusBoardFilterProfile {
  const _FocusBoardFilterProfile({
    required this.id,
    required this.name,
    this.excludedCreatorIds = const [],
    this.excludedAssignmentLabels = const [],
    this.excludedCompanyLabels = const [],
    this.showTrash = false,
    this.showArchive = false,
  });

  final String id;
  final String name;
  final List<String> excludedCreatorIds;
  final List<String> excludedAssignmentLabels;
  final List<String> excludedCompanyLabels;
  final bool showTrash;
  final bool showArchive;

  static const generic = _FocusBoardFilterProfile(
    id: 'generic',
    name: 'Perfil generico',
  );

  bool excludes(_FocusBoardNote note) {
    if (showTrash) {
      if (!note.inTrash) {
        return true;
      }
    } else if (showArchive) {
      if (!note.inArchive || note.inTrash) {
        return true;
      }
    } else if (note.inTrash || note.inArchive) {
      return true;
    }
    if (excludedCreatorIds.contains(note.createdById)) {
      return true;
    }
    final company = note.companyLabel.trim().toLowerCase();
    if (company.isNotEmpty &&
        excludedCompanyLabels
            .map((label) => label.trim().toLowerCase())
            .contains(company)) {
      return true;
    }
    final excludedAssignments = excludedAssignmentLabels
        .map((label) => label.trim().toLowerCase())
        .toSet();
    return note.assignments.any(
      (assignment) =>
          excludedAssignments.contains(assignment.label.trim().toLowerCase()),
    );
  }

  _FocusBoardFilterProfile copyWith({
    String? id,
    String? name,
    List<String>? excludedCreatorIds,
    List<String>? excludedAssignmentLabels,
    List<String>? excludedCompanyLabels,
    bool? showTrash,
    bool? showArchive,
  }) {
    return _FocusBoardFilterProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      excludedCreatorIds: excludedCreatorIds ?? this.excludedCreatorIds,
      excludedAssignmentLabels:
          excludedAssignmentLabels ?? this.excludedAssignmentLabels,
      excludedCompanyLabels:
          excludedCompanyLabels ?? this.excludedCompanyLabels,
      showTrash: showTrash ?? this.showTrash,
      showArchive: showArchive ?? this.showArchive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'excludedCreatorIds': excludedCreatorIds,
      'excludedAssignmentLabels': excludedAssignmentLabels,
      'excludedCompanyLabels': excludedCompanyLabels,
      'showTrash': showTrash,
      'showArchive': showArchive,
    };
  }

  static _FocusBoardFilterProfile fromJson(Map<String, dynamic> json) {
    return _FocusBoardFilterProfile(
      id: _focusBoardText(json['id'], fallback: 'profile'),
      name: _focusBoardText(json['name'], fallback: 'Perfil salvo'),
      excludedCreatorIds: _focusBoardStringList(json['excludedCreatorIds']),
      excludedAssignmentLabels: _focusBoardStringList(
        json['excludedAssignmentLabels'],
      ),
      excludedCompanyLabels: _focusBoardStringList(
        json['excludedCompanyLabels'],
      ),
      showTrash: json['showTrash'] == true,
      showArchive: json['showArchive'] == true,
    );
  }
}

List<String> _focusBoardStringList(Object? value) {
  if (value is! List) {
    return const [];
  }
  return [
    for (final item in value)
      if (item.toString().trim().isNotEmpty) item.toString().trim(),
  ];
}

class _FocusBoardNotesController extends ChangeNotifier {
  static const _notesStorageKey = 'pariflow.focus_board.notes.v1';
  static const _profilesStorageKey = 'pariflow.focus_board.filters.v1';
  static const _activeProfileStorageKey =
      'pariflow.focus_board.active_filter.v1';

  final List<_FocusBoardNote> _notes = [];
  final List<_FocusBoardFilterProfile> _filterProfiles = [];
  bool _loaded = false;
  bool _loading = false;
  _FocusBoardNoteStatusFilter _statusFilter = _FocusBoardNoteStatusFilter.all;
  _FocusBoardNoteSort _sort = _FocusBoardNoteSort.editedOrCreatedAt;
  _FocusBoardFilterProfile _activeFilter = _FocusBoardFilterProfile.generic;

  bool get loaded => _loaded;
  bool get loading => _loading;
  _FocusBoardNoteStatusFilter get statusFilter => _statusFilter;
  _FocusBoardNoteSort get sort => _sort;
  _FocusBoardFilterProfile get activeFilter => _activeFilter;
  List<_FocusBoardFilterProfile> get savedFilterProfiles =>
      List.unmodifiable(_filterProfiles);
  List<_FocusBoardNote> get notes => List.unmodifiable(_notes);

  Future<void> ensureLoaded() async {
    if (_loaded || _loading) {
      return;
    }
    _loading = true;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    _notes
      ..clear()
      ..addAll(_readNotes(preferences.getString(_notesStorageKey)));
    _filterProfiles
      ..clear()
      ..addAll(_readProfiles(preferences.getString(_profilesStorageKey)));
    final activeRaw = preferences.getString(_activeProfileStorageKey);
    if (activeRaw != null && activeRaw.isNotEmpty) {
      final active = [
        _FocusBoardFilterProfile.generic,
        ..._filterProfiles,
      ].where((profile) => profile.id == activeRaw).firstOrNull;
      if (active != null) {
        _activeFilter = active;
      }
    }
    _applyAutomaticTrash();
    _loaded = true;
    _loading = false;
    notifyListeners();
    await _persistNotes();
  }

  List<_FocusBoardNote> visibleNotes(_ViewerAccessProfile viewerProfile) {
    final visibleContainer = [
      for (final note in _notes)
        if (note.canViewerRead(viewerProfile) &&
            (_activeFilter.showTrash
                ? note.inTrash
                : _activeFilter.showArchive
                ? note.inArchive && !note.inTrash
                : !note.inTrash && !note.inArchive))
          note,
    ];
    final filtered = [
      for (final note in visibleContainer)
        if (!_activeFilter.excludes(note) && _matchesStatusFilter(note)) note,
    ];
    final includedIds = <String>{};
    final byId = {for (final note in visibleContainer) note.id: note};
    final childrenByParent = <String, List<_FocusBoardNote>>{};
    for (final note in visibleContainer) {
      if (note.parentNoteId.isEmpty) {
        continue;
      }
      childrenByParent.putIfAbsent(note.parentNoteId, () => []).add(note);
    }
    for (final note in filtered) {
      includedIds.add(note.id);
      var parentId = note.parentNoteId;
      final visited = <String>{note.id};
      while (parentId.isNotEmpty && !visited.contains(parentId)) {
        visited.add(parentId);
        final parent = byId[parentId];
        if (parent == null) {
          break;
        }
        includedIds.add(parent.id);
        parentId = parent.parentNoteId;
      }
      void includeChildren(String parentId) {
        final children = childrenByParent[parentId] ?? const [];
        for (final child in children) {
          if (!includedIds.add(child.id)) {
            continue;
          }
          includeChildren(child.id);
        }
      }

      includeChildren(note.id);
    }
    return _threadOrderedNotes([
      for (final note in visibleContainer)
        if (includedIds.contains(note.id)) note,
    ]);
  }

  int get urgentCount {
    return _notes
        .where(
          (note) =>
              !note.inTrash &&
              !note.inArchive &&
              note.priority == _FocusBoardNotePriority.urgent &&
              !note.isComplete,
        )
        .length;
  }

  int get importantCount {
    return _notes
        .where(
          (note) =>
              !note.inTrash &&
              !note.inArchive &&
              note.priority == _FocusBoardNotePriority.important &&
              !note.isComplete,
        )
        .length;
  }

  int get normalCount {
    return _notes
        .where(
          (note) =>
              !note.inTrash &&
              !note.inArchive &&
              note.priority == _FocusBoardNotePriority.normal &&
              !note.isComplete,
        )
        .length;
  }

  int get pendingCount {
    return _notes
        .where((note) => !note.inTrash && !note.inArchive && !note.isComplete)
        .length;
  }

  int get completedCount {
    return _notes
        .where((note) => !note.inTrash && !note.inArchive && note.isComplete)
        .length;
  }

  int get trashCount {
    return _notes.where((note) => note.inTrash).length;
  }

  int get archiveCount {
    return _notes.where((note) => note.inArchive && !note.inTrash).length;
  }

  Future<void> addNote({
    required _FocusBoardNoteDraft draft,
    required _ViewerAccessProfile viewerProfile,
  }) async {
    await ensureLoaded();
    final now = DateTime.now();
    final actorId = _focusBoardActorId(viewerProfile);
    final note = _FocusBoardNote(
      id: 'fbn-${now.microsecondsSinceEpoch}',
      title: draft.title.trim().isEmpty ? 'Nota' : draft.title.trim(),
      description: draft.description.trim(),
      priority: draft.priority,
      dueAt: draft.dueAt,
      createdAt: now,
      createdById: actorId,
      createdByName: viewerProfile.name,
      companyLabel: draft.companyLabel.trim(),
      visibility: draft.visibility,
      replicasEnabled: draft.replicasEnabled,
      replicaMode: draft.replicaMode,
      assignments: draft.assignments,
      audit: [
        _FocusBoardAuditEntry(
          at: now,
          actorId: actorId,
          actorName: viewerProfile.name,
          action: 'criado',
          details:
              'Nota criada com prazo ${_focusBoardShortDateLabel(draft.dueAt)}.',
        ),
      ],
    );
    _notes.insert(0, note);
    notifyListeners();
    await _persistNotes();
  }

  Future<_FocusBoardNote> createSimpleNote({
    required _ViewerAccessProfile viewerProfile,
  }) async {
    await ensureLoaded();
    final now = DateTime.now();
    final actorId = _focusBoardActorId(viewerProfile);
    final note = _FocusBoardNote(
      id: 'fbn-${now.microsecondsSinceEpoch}',
      title: 'Nova nota',
      description: '',
      priority: _FocusBoardNotePriority.normal,
      dueAt: now.add(const Duration(days: 7)),
      createdAt: now,
      createdById: actorId,
      createdByName: viewerProfile.name,
      visibility: _FocusBoardNoteVisibility.private,
      replicasEnabled: true,
      replicaMode: _FocusBoardReplicaMode.ownerOnly,
      isDraft: true,
      audit: [
        _FocusBoardAuditEntry(
          at: now,
          actorId: actorId,
          actorName: viewerProfile.name,
          action: 'criado',
          details:
              'Nota simples criada privada por padrao com prazo de 7 dias.',
        ),
      ],
    );
    _notes.insert(0, note);
    notifyListeners();
    await _persistNotes();
    return note;
  }

  Future<void> updateNote({
    required String id,
    required _FocusBoardNoteDraft draft,
    required _ViewerAccessProfile viewerProfile,
  }) async {
    await ensureLoaded();
    final index = _notes.indexWhere((note) => note.id == id);
    if (index < 0) {
      return;
    }
    final current = _notes[index];
    if (!current.isCreator(viewerProfile)) {
      return;
    }
    if (current.isClosed) {
      return;
    }
    final now = DateTime.now();
    final changes = <String>[];
    if (current.title != draft.title.trim()) {
      changes.add('titulo: "${current.title}" -> "${draft.title.trim()}"');
    }
    if (current.description != draft.description.trim()) {
      changes.add(
        'texto: "${current.description}" -> "${draft.description.trim()}"',
      );
    }
    if (current.priority != draft.priority) {
      changes.add(
        'prioridade: ${current.priority.label} -> ${draft.priority.label}',
      );
    }
    if (_focusBoardDateKey(current.dueAt) != _focusBoardDateKey(draft.dueAt)) {
      changes.add(
        'prazo: ${_focusBoardShortDateLabel(current.dueAt)} -> ${_focusBoardShortDateLabel(draft.dueAt)}',
      );
    }
    if (current.companyLabel.trim() != draft.companyLabel.trim()) {
      changes.add(
        'empresa: ${current.companyLabel} -> ${draft.companyLabel.trim()}',
      );
    }
    if (current.visibility != draft.visibility) {
      changes.add(
        'visibilidade: ${current.visibility.label} -> ${draft.visibility.label}',
      );
    }
    if (current.replicasEnabled != draft.replicasEnabled) {
      changes.add(
        'replicas: ${current.replicasEnabled ? 'habilitadas' : 'desabilitadas'} -> ${draft.replicasEnabled ? 'habilitadas' : 'desabilitadas'}',
      );
    }
    if (current.replicaMode != draft.replicaMode) {
      changes.add(
        'modo de replica: ${current.replicaMode.label} -> ${draft.replicaMode.label}',
      );
    }
    final actorId = _focusBoardActorId(viewerProfile);
    final nextTitle = _limitGrandchildText(
      current.id,
      draft.title.trim().isEmpty ? 'Nota' : draft.title.trim(),
    );
    final nextDescription = _limitGrandchildText(
      current.id,
      draft.description.trim(),
    );
    _notes[index] = current.copyWith(
      title: nextTitle,
      description: nextDescription,
      priority: draft.priority,
      dueAt: draft.dueAt,
      companyLabel: draft.companyLabel.trim(),
      visibility: draft.visibility,
      replicasEnabled: draft.replicasEnabled,
      replicaMode: draft.replicaMode,
      assignments: draft.assignments,
      isDraft: false,
      updatedAt: now,
      lastEditedAt: now,
      audit: [
        ...current.audit,
        _FocusBoardAuditEntry(
          at: now,
          actorId: actorId,
          actorName: viewerProfile.name,
          action: 'editado',
          details: changes.isEmpty
              ? 'Edicao sem alteracao textual.'
              : changes.join(' | '),
        ),
      ],
    );
    notifyListeners();
    await _persistNotes();
  }

  Future<_FocusBoardTextCommitResult> updateNoteText({
    required String id,
    required String title,
    required String description,
    required _ViewerAccessProfile viewerProfile,
  }) async {
    await ensureLoaded();
    final index = _notes.indexWhere((note) => note.id == id);
    if (index < 0) {
      return _FocusBoardTextCommitResult.none;
    }
    final current = _notes[index];
    if (!current.isCreator(viewerProfile) || current.isClosed) {
      return _FocusBoardTextCommitResult.none;
    }
    final rawNextTitle = current.isDraft
        ? _focusBoardTitleForSavedDraft(title, description)
        : title.trim().isEmpty
        ? 'Nova nota'
        : title.trim();
    final rawNextDescription = description.trim();
    final nextTitle = _limitGrandchildText(current.id, rawNextTitle);
    final nextDescription = _limitGrandchildText(
      current.id,
      rawNextDescription,
    );
    if (current.title == nextTitle && current.description == nextDescription) {
      if (!current.isDraft) {
        return _FocusBoardTextCommitResult.none;
      }
      _notes[index] = current.copyWith(isDraft: false);
      notifyListeners();
      await _persistNotes();
      return _FocusBoardTextCommitResult.draftSaved;
    }
    if (current.isDraft) {
      if (_focusBoardIsEmptyDraftText(title, description)) {
        return _FocusBoardTextCommitResult.none;
      }
      _notes[index] = current.copyWith(
        title: nextTitle,
        description: nextDescription,
        isDraft: false,
        clearUpdatedAt: true,
        clearLastEditedAt: true,
      );
      notifyListeners();
      await _persistNotes();
      return _FocusBoardTextCommitResult.draftSaved;
    }
    final now = DateTime.now();
    final changes = <String>[];
    if (current.title != nextTitle) {
      changes.add('titulo: "${current.title}" -> "$nextTitle"');
    }
    if (current.description != nextDescription) {
      changes.add('texto: "${current.description}" -> "$nextDescription"');
    }
    _notes[index] = current.copyWith(
      title: nextTitle,
      description: nextDescription,
      updatedAt: now,
      lastEditedAt: now,
      audit: [
        ...current.audit,
        _FocusBoardAuditEntry(
          at: now,
          actorId: _focusBoardActorId(viewerProfile),
          actorName: viewerProfile.name,
          action: 'texto atualizado',
          details: changes.join(' | '),
        ),
      ],
    );
    notifyListeners();
    await _persistNotes();
    return _FocusBoardTextCommitResult.textUpdated;
  }

  String _limitGrandchildText(String noteId, String value) {
    if (threadDepthFor(noteId) < 2 || value.length <= 15) {
      return value;
    }
    return value.substring(0, 15);
  }

  Future<_FocusBoardNote?> discardDraft({
    required String id,
    required _ViewerAccessProfile viewerProfile,
  }) async {
    await ensureLoaded();
    final index = _notes.indexWhere((note) => note.id == id);
    if (index < 0) {
      return null;
    }
    final current = _notes[index];
    if (!current.isCreator(viewerProfile) ||
        !current.isDraft ||
        current.isClosed ||
        !_focusBoardIsEmptyDraftText(current.title, current.description)) {
      return null;
    }
    final removed = _notes.removeAt(index);
    notifyListeners();
    await _persistNotes();
    return removed;
  }

  Future<void> restoreDiscardedDraft(_FocusBoardNote note) async {
    await ensureLoaded();
    if (_notes.any((entry) => entry.id == note.id)) {
      return;
    }
    _notes.insert(0, note.copyWith(isDraft: true));
    notifyListeners();
    await _persistNotes();
  }

  Future<void> toggleOwnerCompletion({
    required String id,
    required _ViewerAccessProfile viewerProfile,
  }) async {
    await ensureLoaded();
    final index = _notes.indexWhere((note) => note.id == id);
    if (index < 0) {
      return;
    }
    final current = _notes[index];
    if (current.isClosed) {
      return;
    }
    final now = DateTime.now();
    final nextCompleted = !current.completedByOwner;
    final actorId = _focusBoardActorId(viewerProfile);
    var nextAssignments = current.assignments;
    if (nextCompleted &&
        current.replicasEnabled &&
        current.replicaMode == _FocusBoardReplicaMode.firstCompletesAll) {
      nextAssignments = [
        for (final assignment in current.assignments)
          assignment.copyWith(
            completed: true,
            completedAt: now,
            completedById: actorId,
            completedByName: viewerProfile.name,
          ),
      ];
    }
    var next = current.copyWith(
      completedByOwner: nextCompleted,
      assignments: nextAssignments,
      restoredFromAutoTrash: false,
      updatedAt: now,
      audit: [
        ...current.audit,
        _FocusBoardAuditEntry(
          at: now,
          actorId: actorId,
          actorName: viewerProfile.name,
          action: nextCompleted ? 'concluido' : 'reaberto',
          details: nextCompleted
              ? 'Marcado como concluido; lixeira automatica em 1 dia.'
              : 'Conclusao removida manualmente.',
        ),
      ],
    );
    next = next.copyWith(
      completedAt: next.isComplete ? current.completedAt ?? now : null,
      clearCompletedAt: !next.isComplete,
    );
    _notes[index] = next;
    notifyListeners();
    await _persistNotes();
  }

  Future<void> toggleAssignmentCompletion({
    required String noteId,
    required String assignmentId,
    required _ViewerAccessProfile viewerProfile,
  }) async {
    await ensureLoaded();
    final index = _notes.indexWhere((note) => note.id == noteId);
    if (index < 0) {
      return;
    }
    final current = _notes[index];
    if (current.isClosed || !current.replicasEnabled) {
      return;
    }
    final assignmentIndex = current.assignments.indexWhere(
      (assignment) => assignment.id == assignmentId,
    );
    if (assignmentIndex < 0) {
      return;
    }
    final now = DateTime.now();
    final actorId = _focusBoardActorId(viewerProfile);
    final assignment = current.assignments[assignmentIndex];
    final nextCompleted = !assignment.completed;
    final nextAssignments = [...current.assignments];
    nextAssignments[assignmentIndex] = assignment.copyWith(
      completed: nextCompleted,
      completedAt: nextCompleted ? now : null,
      clearCompletedAt: !nextCompleted,
      completedById: nextCompleted ? actorId : '',
      completedByName: nextCompleted ? viewerProfile.name : '',
    );
    if (nextCompleted &&
        current.replicaMode == _FocusBoardReplicaMode.firstCompletesAll) {
      for (
        var assignmentIndex = 0;
        assignmentIndex < nextAssignments.length;
        assignmentIndex += 1
      ) {
        nextAssignments[assignmentIndex] = nextAssignments[assignmentIndex]
            .copyWith(
              completed: true,
              completedAt: now,
              completedById: actorId,
              completedByName: viewerProfile.name,
            );
      }
    }
    var next = current.copyWith(
      assignments: nextAssignments,
      updatedAt: now,
      audit: [
        ...current.audit,
        _FocusBoardAuditEntry(
          at: now,
          actorId: actorId,
          actorName: viewerProfile.name,
          action: nextCompleted ? 'replica concluida' : 'replica reaberta',
          details:
              '${assignment.label} ${nextCompleted ? 'concluiu' : 'removeu conclusao'}.',
        ),
      ],
    );
    next = next.copyWith(
      completedAt: next.isComplete ? current.completedAt ?? now : null,
      clearCompletedAt: !next.isComplete,
    );
    _notes[index] = next;
    notifyListeners();
    await _persistNotes();
  }

  Future<void> moveToTrash({
    required String id,
    required _ViewerAccessProfile viewerProfile,
  }) async {
    await ensureLoaded();
    final linked = fullThreadNotes(id);
    if (linked.isEmpty) {
      return;
    }
    final now = DateTime.now();
    final actorId = _focusBoardActorId(viewerProfile);
    for (final current in linked) {
      final index = _notes.indexWhere((note) => note.id == current.id);
      if (index < 0) {
        continue;
      }
      _notes[index] = current.copyWith(
        inTrash: true,
        trashedAt: now,
        inArchive: false,
        clearArchivedAt: true,
        updatedAt: now,
        audit: [
          ...current.audit,
          _FocusBoardAuditEntry(
            at: now,
            actorId: actorId,
            actorName: viewerProfile.name,
            action: 'movido para lixeira',
            details: current.isComplete
                ? 'Nota completa movida para lixeira.'
                : 'Nota incompleta movida para lixeira com confirmacao.',
          ),
        ],
      );
    }
    notifyListeners();
    await _persistNotes();
  }

  Future<void> moveToArchive({
    required String id,
    required _ViewerAccessProfile viewerProfile,
  }) async {
    await ensureLoaded();
    final linked = fullThreadNotes(id);
    if (linked.isEmpty) {
      return;
    }
    final now = DateTime.now();
    final actorId = _focusBoardActorId(viewerProfile);
    for (final current in linked) {
      final index = _notes.indexWhere((note) => note.id == current.id);
      if (index < 0) {
        continue;
      }
      _notes[index] = current.copyWith(
        inArchive: true,
        archivedAt: now,
        inTrash: false,
        clearTrashedAt: true,
        updatedAt: now,
        audit: [
          ...current.audit,
          _FocusBoardAuditEntry(
            at: now,
            actorId: actorId,
            actorName: viewerProfile.name,
            action: 'arquivado',
            details: 'Nota arquivada junto ao encadeamento vinculado.',
          ),
        ],
      );
    }
    notifyListeners();
    await _persistNotes();
  }

  Future<void> closeNote({
    required String id,
    required _ViewerAccessProfile viewerProfile,
  }) async {
    await ensureLoaded();
    final linked = fullThreadNotes(id);
    if (linked.isEmpty) {
      return;
    }
    final root = linked.first;
    if (!root.isCreator(viewerProfile) || root.isClosed) {
      return;
    }
    final now = DateTime.now();
    final actorId = _focusBoardActorId(viewerProfile);
    for (final current in linked) {
      final index = _notes.indexWhere((note) => note.id == current.id);
      if (index < 0) {
        continue;
      }
      _notes[index] = current.copyWith(
        closedAt: now,
        closedById: actorId,
        closedByName: viewerProfile.name,
        completedAt: now,
        updatedAt: now,
        audit: [
          ...current.audit,
          _FocusBoardAuditEntry(
            at: now,
            actorId: actorId,
            actorName: viewerProfile.name,
            action: 'encerrado',
            details: 'Criador encerrou a nota e o encadeamento vinculado.',
          ),
        ],
      );
    }
    notifyListeners();
    await _persistNotes();
  }

  Future<void> replicateNote({
    required String id,
    required _ViewerAccessProfile viewerProfile,
  }) async {
    await ensureLoaded();
    final source = _notes.where((note) => note.id == id).firstOrNull;
    if (source == null || source.isClosed || !source.replicasEnabled) {
      return;
    }
    final now = DateTime.now();
    final actorId = _focusBoardActorId(viewerProfile);
    final sourceDepth = threadDepthFor(source.id);
    if (sourceDepth >= 2) {
      return;
    }
    final rootId = source.rootNoteId.isNotEmpty
        ? source.rootNoteId
        : source.parentNoteId.isEmpty
        ? source.id
        : source.parentNoteId;
    final childDescription = sourceDepth >= 1 ? '' : source.description;
    final childTitle = sourceDepth >= 1 ? 'Resposta curta' : source.title;
    final replica = _FocusBoardNote(
      id: 'fbn-${now.microsecondsSinceEpoch}',
      title: childTitle,
      description: childDescription,
      priority: source.priority,
      dueAt: source.dueAt,
      createdAt: now,
      createdById: actorId,
      createdByName: viewerProfile.name,
      parentNoteId: source.id,
      rootNoteId: rootId,
      companyLabel: source.companyLabel,
      visibility: _FocusBoardNoteVisibility.private,
      replicasEnabled: sourceDepth == 0,
      replicaMode: _FocusBoardReplicaMode.ownerOnly,
      isDraft: true,
      audit: [
        _FocusBoardAuditEntry(
          at: now,
          actorId: actorId,
          actorName: viewerProfile.name,
          action: 'replicado',
          details: 'Replica criada a partir da nota ${source.id}.',
        ),
      ],
    );
    _notes.add(replica);
    _notes[_notes.indexWhere((note) => note.id == id)] = source.copyWith(
      updatedAt: now,
      audit: [
        ...source.audit,
        _FocusBoardAuditEntry(
          at: now,
          actorId: actorId,
          actorName: viewerProfile.name,
          action: 'replica gerada',
          details: '${viewerProfile.name} replicou esta nota.',
        ),
      ],
    );
    notifyListeners();
    await _persistNotes();
  }

  int threadDepthFor(String noteId) {
    final byId = {for (final note in _notes) note.id: note};
    var depth = 0;
    var current = byId[noteId];
    final visited = <String>{};
    while (current != null &&
        current.parentNoteId.isNotEmpty &&
        visited.add(current.id)) {
      depth += 1;
      current = byId[current.parentNoteId];
      if (depth >= 2) {
        return 2;
      }
    }
    return depth;
  }

  List<_FocusBoardNote> threadNotes(String noteId) {
    final byId = {for (final note in _notes) note.id: note};
    final root = byId[noteId];
    if (root == null) {
      return const [];
    }
    final ids = <String>{root.id};
    void includeChildren(String parentId) {
      final children =
          _notes
              .where((note) => note.parentNoteId == parentId)
              .toList(growable: false)
            ..sort((left, right) => left.createdAt.compareTo(right.createdAt));
      for (final child in children) {
        if (!ids.add(child.id)) {
          continue;
        }
        includeChildren(child.id);
      }
    }

    includeChildren(root.id);
    return _threadOrderedNotes([
      for (final note in _notes)
        if (ids.contains(note.id)) note,
    ]);
  }

  bool threadHasPending(String noteId) {
    return fullThreadNotes(noteId).any((note) => !note.isComplete);
  }

  Future<void> restoreFromTrash({
    required String id,
    required _ViewerAccessProfile viewerProfile,
  }) async {
    await ensureLoaded();
    final linked = fullThreadNotes(id);
    if (linked.isEmpty) {
      return;
    }
    final now = DateTime.now();
    final actorId = _focusBoardActorId(viewerProfile);
    for (final current in linked) {
      final index = _notes.indexWhere((note) => note.id == current.id);
      if (index < 0) {
        continue;
      }
      _notes[index] = current.copyWith(
        inTrash: false,
        clearTrashedAt: true,
        restoredFromAutoTrash: true,
        updatedAt: now,
        audit: [
          ...current.audit,
          _FocusBoardAuditEntry(
            at: now,
            actorId: actorId,
            actorName: viewerProfile.name,
            action: 'restaurado',
            details: 'Nota movida manualmente para fora da lixeira.',
          ),
        ],
      );
    }
    notifyListeners();
    await _persistNotes();
  }

  Future<void> restoreFromArchive({
    required String id,
    required _ViewerAccessProfile viewerProfile,
  }) async {
    await ensureLoaded();
    final linked = fullThreadNotes(id);
    if (linked.isEmpty) {
      return;
    }
    final now = DateTime.now();
    final actorId = _focusBoardActorId(viewerProfile);
    for (final current in linked) {
      final index = _notes.indexWhere((note) => note.id == current.id);
      if (index < 0) {
        continue;
      }
      _notes[index] = current.copyWith(
        inArchive: false,
        clearArchivedAt: true,
        updatedAt: now,
        audit: [
          ...current.audit,
          _FocusBoardAuditEntry(
            at: now,
            actorId: actorId,
            actorName: viewerProfile.name,
            action: 'restaurado do arquivo',
            details: 'Nota movida manualmente para fora dos arquivados.',
          ),
        ],
      );
    }
    notifyListeners();
    await _persistNotes();
  }

  Future<void> deleteThreadSegmentPermanently({
    required String id,
    required _ViewerAccessProfile viewerProfile,
  }) async {
    await ensureLoaded();
    final target = _notes.where((note) => note.id == id).firstOrNull;
    if (target == null ||
        target.parentNoteId.isEmpty ||
        !target.isCreator(viewerProfile)) {
      return;
    }
    final linked = threadNotes(id);
    if (linked.isEmpty) {
      return;
    }
    final linkedIds = linked.map((note) => note.id).toSet();
    final now = DateTime.now();
    final actorId = _focusBoardActorId(viewerProfile);
    final parentIndex = _notes.indexWhere(
      (note) => note.id == target.parentNoteId,
    );
    if (parentIndex >= 0) {
      final parent = _notes[parentIndex];
      _notes[parentIndex] = parent.copyWith(
        updatedAt: now,
        audit: [
          ...parent.audit,
          _FocusBoardAuditEntry(
            at: now,
            actorId: actorId,
            actorName: viewerProfile.name,
            action: 'resposta excluida permanentemente',
            details:
                '${linked.length} item(ns) do encadeamento foram removidos sem passar pela lixeira.',
          ),
        ],
      );
    }
    _notes.removeWhere((note) => linkedIds.contains(note.id));
    notifyListeners();
    await _persistNotes();
  }

  Future<void> moveManyToTrash({
    required Iterable<String> ids,
    required _ViewerAccessProfile viewerProfile,
  }) async {
    for (final id in ids) {
      await moveToTrash(id: id, viewerProfile: viewerProfile);
    }
  }

  Future<void> completeMany({
    required Iterable<String> ids,
    required _ViewerAccessProfile viewerProfile,
  }) async {
    await ensureLoaded();
    for (final id in ids) {
      final note = _notes.where((entry) => entry.id == id).firstOrNull;
      if (note != null && !note.completedByOwner) {
        await toggleOwnerCompletion(id: id, viewerProfile: viewerProfile);
      }
    }
  }

  Future<void> setStatusFilter(_FocusBoardNoteStatusFilter filter) async {
    _statusFilter = filter;
    notifyListeners();
  }

  Future<void> setSort(_FocusBoardNoteSort sort) async {
    _sort = sort;
    notifyListeners();
  }

  Future<void> setActiveFilter(_FocusBoardFilterProfile profile) async {
    _activeFilter = profile;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_activeProfileStorageKey, profile.id);
  }

  Future<void> saveFilterProfile(_FocusBoardFilterProfile profile) async {
    await ensureLoaded();
    final normalized = profile.copyWith(
      id: profile.id == 'generic'
          ? 'profile-${DateTime.now().microsecondsSinceEpoch}'
          : profile.id,
      name: profile.name.trim().isEmpty ? 'Perfil salvo' : profile.name.trim(),
    );
    final index = _filterProfiles.indexWhere(
      (entry) => entry.id == normalized.id,
    );
    if (index >= 0) {
      _filterProfiles[index] = normalized;
    } else {
      if (_filterProfiles.length >= 4) {
        _filterProfiles.removeAt(0);
      }
      _filterProfiles.add(normalized);
    }
    _activeFilter = normalized;
    notifyListeners();
    await _persistProfiles();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_activeProfileStorageKey, normalized.id);
  }

  Future<void> resetFilters() async {
    _activeFilter = _FocusBoardFilterProfile.generic;
    _statusFilter = _FocusBoardNoteStatusFilter.all;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_activeProfileStorageKey, _activeFilter.id);
  }

  List<_FocusBoardNote> _readNotes(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return const [];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }
      return [
        for (final item in decoded)
          if (item is Map)
            _FocusBoardNote.fromJson(Map<String, dynamic>.from(item)),
      ];
    } catch (_) {
      return const [];
    }
  }

  List<_FocusBoardFilterProfile> _readProfiles(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return const [];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }
      return [
        for (final item in decoded)
          if (item is Map)
            _FocusBoardFilterProfile.fromJson(Map<String, dynamic>.from(item)),
      ].take(4).toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  bool _matchesStatusFilter(_FocusBoardNote note) {
    return switch (_statusFilter) {
      _FocusBoardNoteStatusFilter.pending => !note.isComplete,
      _FocusBoardNoteStatusFilter.completed => note.isComplete,
      _FocusBoardNoteStatusFilter.all => true,
    };
  }

  int _compareNotes(_FocusBoardNote left, _FocusBoardNote right) {
    final comparison = switch (_sort) {
      _FocusBoardNoteSort.createdAt => right.createdAt.compareTo(
        left.createdAt,
      ),
      _FocusBoardNoteSort.editedOrCreatedAt =>
        right.editedOrCreatedAt.compareTo(left.editedOrCreatedAt),
      _FocusBoardNoteSort.creatorName =>
        left.createdByName.toLowerCase().compareTo(
          right.createdByName.toLowerCase(),
        ),
      _FocusBoardNoteSort.creatorId => left.createdById.toLowerCase().compareTo(
        right.createdById.toLowerCase(),
      ),
      _FocusBoardNoteSort.company => left.companyLabel.toLowerCase().compareTo(
        right.companyLabel.toLowerCase(),
      ),
      _FocusBoardNoteSort.status => left.completionState.sortRank.compareTo(
        right.completionState.sortRank,
      ),
    };
    if (comparison != 0) {
      return comparison;
    }
    return right.createdAt.compareTo(left.createdAt);
  }

  List<_FocusBoardNote> _threadOrderedNotes(List<_FocusBoardNote> notes) {
    final byId = {for (final note in notes) note.id: note};
    final childrenByParent = <String, List<_FocusBoardNote>>{};
    for (final note in notes) {
      if (note.parentNoteId.isEmpty || !byId.containsKey(note.parentNoteId)) {
        continue;
      }
      childrenByParent.putIfAbsent(note.parentNoteId, () => []).add(note);
    }
    for (final children in childrenByParent.values) {
      children.sort((left, right) => left.createdAt.compareTo(right.createdAt));
    }
    final roots = [
      for (final note in notes)
        if (note.parentNoteId.isEmpty || !byId.containsKey(note.parentNoteId))
          note,
    ]..sort(_compareNotes);
    final ordered = <_FocusBoardNote>[];
    void appendThread(_FocusBoardNote note) {
      ordered.add(note);
      for (final child in childrenByParent[note.id] ?? const []) {
        appendThread(child);
      }
    }

    for (final root in roots) {
      appendThread(root);
    }
    return ordered;
  }

  String? rootNoteIdFor(String noteId) {
    final byId = {for (final note in _notes) note.id: note};
    var current = byId[noteId];
    if (current == null) {
      return null;
    }
    final visited = <String>{};
    while (current != null && visited.add(current.id)) {
      final parentId = current.parentNoteId;
      if (parentId.isEmpty) {
        return current.id;
      }
      final parent = byId[parentId];
      if (parent == null) {
        return current.id;
      }
      current = parent;
    }
    return current?.id;
  }

  bool isRootNote(String noteId) => rootNoteIdFor(noteId) == noteId;

  List<_FocusBoardNote> fullThreadNotes(String noteId) {
    final rootId = rootNoteIdFor(noteId);
    if (rootId == null) {
      return const [];
    }
    return threadNotes(rootId);
  }

  void _applyAutomaticTrash() {
    final now = DateTime.now();
    var changed = false;
    for (var index = 0; index < _notes.length; index += 1) {
      final note = _notes[index];
      final completedAt = note.completedAt;
      if (note.inTrash ||
          note.inArchive ||
          note.restoredFromAutoTrash ||
          completedAt == null ||
          !note.isComplete) {
        continue;
      }
      if (now.difference(completedAt) < const Duration(days: 1)) {
        continue;
      }
      _notes[index] = note.copyWith(
        inTrash: true,
        trashedAt: now,
        updatedAt: now,
        audit: [
          ...note.audit,
          _FocusBoardAuditEntry(
            at: now,
            actorId: 'system',
            actorName: 'Sistema',
            action: 'lixeira automatica',
            details: 'Nota completa ha 1 dia movida para lixeira.',
          ),
        ],
      );
      changed = true;
    }
    if (changed) {
      notifyListeners();
    }
  }

  Future<void> _persistNotes() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _notesStorageKey,
      jsonEncode(_notes.map((note) => note.toJson()).toList()),
    );
  }

  Future<void> _persistProfiles() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _profilesStorageKey,
      jsonEncode(_filterProfiles.map((profile) => profile.toJson()).toList()),
    );
  }
}

class _FocusBoardPersistentController extends ChangeNotifier {
  _FocusBoardPersistentController({
    ApiClient? apiClient,
    this.fastInitialLoad = false,
  }) : _repository = _PeopleApiRepository(apiClient: apiClient),
       notesController = _FocusBoardNotesController();

  final _PeopleApiRepository _repository;
  final bool fastInitialLoad;
  final _FocusBoardNotesController notesController;
  _PeopleRuntimeData _runtimeData = _PeopleRuntimeData.initial();
  Future<void>? _activeLoad;
  bool _requestedInitialLoad = false;
  bool _requestedFullLoad = false;
  String? _selectedPersonPublicId;

  _PeopleRuntimeData get runtimeData => _runtimeData;
  List<_EntityItem> get people => _runtimeData.data.items;

  _EntityItem? get selectedItem {
    if (people.isEmpty) {
      return null;
    }
    final selectedPublicId = _selectedPersonPublicId;
    if (selectedPublicId != null) {
      for (final item in people) {
        if (item.publicId == selectedPublicId) {
          return item;
        }
      }
    }
    return people.first;
  }

  Future<void> ensureLoaded() {
    unawaited(notesController.ensureLoaded());
    if (_requestedInitialLoad) {
      return _activeLoad ?? Future<void>.value();
    }
    _requestedInitialLoad = true;
    return refresh();
  }

  Future<void> refresh() {
    if (_activeLoad != null) {
      return _activeLoad!;
    }

    _runtimeData = _runtimeData.copyWith(isLoading: true);
    notifyListeners();

    final shouldUseFastInitialLoad =
        fastInitialLoad && !_requestedFullLoad && people.isEmpty;
    _requestedFullLoad = true;

    _activeLoad =
        (shouldUseFastInitialLoad
                ? _repository.loadFocusBoardInitialData()
                : _repository.loadWorkspaceData())
            .then((data) {
              _runtimeData = data;
              _normalizeSelection();
              notifyListeners();
              if (shouldUseFastInitialLoad) {
                unawaited(_refreshFullWorkspaceInBackground());
              }
            })
            .catchError((Object error) {
              _runtimeData = _PeopleRuntimeData.unavailable(
                message: _peopleRuntimeErrorMessage(error),
              );
              notifyListeners();
            })
            .whenComplete(() {
              _activeLoad = null;
            });

    return _activeLoad!;
  }

  Future<void> _refreshFullWorkspaceInBackground() async {
    try {
      final data = await _repository.loadWorkspaceData();
      _runtimeData = data;
      _normalizeSelection();
      notifyListeners();
    } catch (_) {
      // O recorte inicial permanece visivel; o usuario ainda pode atualizar.
    }
  }

  void selectPerson(String publicId) {
    if (publicId.isEmpty || _selectedPersonPublicId == publicId) {
      return;
    }
    _selectedPersonPublicId = publicId;
    notifyListeners();
  }

  Future<void> createCalendarEntry(Map<String, dynamic> body) async {
    await _repository.createCalendarEntry(body);
    await refresh();
  }

  Future<void> cancelCalendarEntry(String publicId) async {
    await _repository.cancelCalendarEntry(publicId);
    await refresh();
  }

  void _normalizeSelection() {
    if (people.isEmpty) {
      _selectedPersonPublicId = null;
      return;
    }
    final selectedPublicId = _selectedPersonPublicId;
    if (selectedPublicId == null ||
        !people.any((item) => item.publicId == selectedPublicId)) {
      _selectedPersonPublicId = people.first.publicId;
    }
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }
}

class _FocusBoardStandalonePage extends StatefulWidget {
  const _FocusBoardStandalonePage();

  @override
  State<_FocusBoardStandalonePage> createState() =>
      _FocusBoardStandalonePageState();
}

class _FocusBoardStandalonePageState extends State<_FocusBoardStandalonePage> {
  late final _FocusBoardPersistentController _controller;
  _ViewerAccessProfile _viewerProfile = _sessionViewerProfileFallback;

  @override
  void initState() {
    super.initState();
    _controller = _FocusBoardPersistentController(fastInitialLoad: true);
    _controller.ensureLoaded();
    unawaited(_loadViewerProfile());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadViewerProfile() async {
    try {
      final session = await ApiClient().ensureDevelopmentSession();
      if (!mounted) {
        return;
      }
      setState(() {
        _viewerProfile = _viewerProfileFromSession(session);
      });
    } on ApiException {
      if (!mounted) {
        return;
      }
      setState(() {
        _viewerProfile = _publicViewerProfile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvasColor,
      body: SafeArea(
        child: _FocusBoardDetachedWorkspace(
          controller: _controller,
          viewerProfile: _viewerProfile,
          onAttach: _returnToCrm,
          showHeader: false,
          showPeopleSelector: false,
          matchDockedLayout: true,
        ),
      ),
    );
  }

  void _returnToCrm() {
    closeCurrentFocusBoardWindow();
    Future<void>.delayed(const Duration(milliseconds: 160), () {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    });
  }
}

class _PersistentFocusBoardDock extends StatefulWidget {
  const _PersistentFocusBoardDock({
    required this.controller,
    required this.viewerProfile,
    required this.detached,
    required this.visible,
    required this.resizeAxis,
    required this.extent,
    required this.panelExtent,
    required this.onExtentChanged,
    required this.onToggleVisibility,
    required this.onDetach,
    required this.onAttach,
  });

  final _FocusBoardPersistentController controller;
  final _ViewerAccessProfile viewerProfile;
  final bool detached;
  final bool visible;
  final Axis resizeAxis;
  final double extent;
  final double panelExtent;
  final ValueChanged<double> onExtentChanged;
  final VoidCallback onToggleVisibility;
  final VoidCallback onDetach;
  final VoidCallback onAttach;

  @override
  State<_PersistentFocusBoardDock> createState() =>
      _PersistentFocusBoardDockState();
}

class _PersistentFocusBoardDockState extends State<_PersistentFocusBoardDock> {
  @override
  void initState() {
    super.initState();
    widget.controller.ensureLoaded();
  }

  @override
  void didUpdateWidget(covariant _PersistentFocusBoardDock oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.controller.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    final sideDock = widget.resizeAxis == Axis.horizontal;
    final compact = sideDock ? widget.extent < 430 : true;
    final board = _focusBoardSlotContent(compact);

    return SizedBox(
      width: sideDock ? widget.extent : double.infinity,
      height: sideDock ? double.infinity : widget.extent,
      child: Align(
        alignment: sideDock ? Alignment.topCenter : Alignment.center,
        child: SizedBox(
          width: sideDock ? widget.extent : double.infinity,
          height: sideDock ? widget.panelExtent : widget.extent,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _paperColor.withValues(alpha: 0.94),
              border: Border(
                left: sideDock
                    ? const BorderSide(color: _lineColor)
                    : BorderSide.none,
                top: sideDock
                    ? BorderSide.none
                    : const BorderSide(color: _lineColor),
              ),
              boxShadow: [
                BoxShadow(
                  color: _inkColor.withValues(alpha: 0.08),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: sideDock
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _FocusBoardResizeHandle(
                        axis: widget.resizeAxis,
                        onDragDelta: (delta) => widget.onExtentChanged(
                          widget.extent - delta.delta.dx,
                        ),
                      ),
                      Expanded(
                        child: _FocusBoardDockedVerticalFit(child: board),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _FocusBoardResizeHandle(
                        axis: widget.resizeAxis,
                        onDragDelta: (delta) => widget.onExtentChanged(
                          widget.extent - delta.delta.dy,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                          child: board,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _focusBoardSlotContent(bool compact) {
    if (widget.detached) {
      return Column(
        children: [
          _FocusBoardSlotToolbar(
            visible: widget.visible,
            detached: widget.detached,
            onToggleVisibility: widget.onToggleVisibility,
            onDetach: widget.onAttach,
            onAttach: widget.onAttach,
          ),
          Expanded(
            child: _FocusBoardSlotPlaceholder(
              icon: Icons.open_in_new_rounded,
              title: 'Board em janela separada',
              message:
                  'Ao fechar a janela do navegador, o board volta para este slot.',
              primaryLabel: 'Acoplar',
              primaryIcon: Icons.call_received_rounded,
              onPrimary: widget.onAttach,
              onToolbarDetach: widget.onAttach,
              onToolbarAttach: widget.onAttach,
              detached: true,
              visible: widget.visible,
              onToggleVisibility: widget.onToggleVisibility,
              showToolbar: false,
            ),
          ),
          SizedBox(height: 320, child: _fixedFooterForSlot()),
        ],
      );
    }

    if (!widget.visible) {
      return _FocusBoardSlotPlaceholder(
        icon: Icons.visibility_off_outlined,
        title: 'Focus Board oculta',
        message:
            'O conteudo deste slot esta oculto, mas o espaco continua reservado.',
        primaryLabel: 'Mostrar',
        primaryIcon: Icons.visibility_outlined,
        onPrimary: widget.onToggleVisibility,
        onToolbarDetach: widget.onDetach,
        onToolbarAttach: widget.onAttach,
        detached: false,
        visible: widget.visible,
        onToggleVisibility: widget.onToggleVisibility,
      );
    }

    return Column(
      children: [
        _FocusBoardSlotToolbar(
          visible: widget.visible,
          detached: widget.detached,
          onToggleVisibility: widget.onToggleVisibility,
          onDetach: widget.onDetach,
          onAttach: widget.onAttach,
        ),
        Expanded(
          child: Material(
            color: Colors.transparent,
            elevation: 0,
            child: AnimatedBuilder(
              animation: widget.controller,
              builder: (context, _) {
                return _FocusBoardRuntimeFrame(
                  controller: widget.controller,
                  viewerProfile: widget.viewerProfile,
                  compact: compact,
                  onDetach: widget.onDetach,
                  onRefresh: widget.controller.refresh,
                  onCreateReminder: (item, mode) =>
                      _openCreateReminder(item, mode),
                  onCancelReminder: _confirmCancelReminder,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _fixedFooterForSlot() {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return AnimatedBuilder(
          animation: widget.controller.notesController,
          builder: (context, _) {
            final item = widget.controller.selectedItem;
            final profile = item?.personProfile;
            if (item == null || profile == null) {
              return const _FocusBoardFooterEmpty(
                icon: Icons.event_busy_outlined,
                text: 'Agenda fixa indisponivel enquanto os dados carregam.',
              );
            }
            final entries =
                profile.calendarEntries.where((entry) {
                  final status = entry.status.toUpperCase();
                  return status != 'CANCELED' && status != 'COMPLETED';
                }).toList()..sort(
                  (left, right) => left.startsAt.compareTo(right.startsAt),
                );
            return _FocusBoardFixedFooter(
              calendarEntries: entries,
              onAddCalendarEntry: (mode) => _openCreateReminder(item, mode),
              onCancelCalendarEntry: _confirmCancelReminder,
            );
          },
        );
      },
    );
  }

  Future<void> _openCreateReminder(
    _EntityItem item, [
    _FocusBoardTaskMode mode = _FocusBoardTaskMode.reminder,
  ]) async {
    final profile = item.personProfile;
    if (profile == null) {
      return;
    }

    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _CalendarEntryCrudDialog(
        personPublicId: item.publicId,
        personName: item.title,
        profile: profile,
        mode: mode,
      ),
    );

    if (body == null || !mounted) {
      return;
    }

    try {
      await widget.controller.createCalendarEntry(body);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${mode.label} criado na Focus Board.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_peopleMutationErrorMessage(error)),
          backgroundColor: _roseColor,
        ),
      );
    }
  }

  Future<void> _confirmCancelReminder(_CalendarEntryRecord entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar lembrete'),
        content: const Text(
          'O item sera marcado como cancelado, preservando historico e auditoria.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancelar item'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await widget.controller.cancelCalendarEntry(entry.publicId);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item cancelado na Focus Board.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_peopleMutationErrorMessage(error)),
          backgroundColor: _roseColor,
        ),
      );
    }
  }
}

class _FocusBoardDockedVerticalFit extends StatelessWidget {
  const _FocusBoardDockedVerticalFit({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.maxHeight.isFinite || constraints.maxHeight >= 720) {
          return child;
        }
        final scale = (constraints.maxHeight / 720).clamp(0.56, 1.0).toDouble();
        return ClipRect(
          child: Align(
            alignment: Alignment.topLeft,
            widthFactor: 1,
            heightFactor: 1,
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: constraints.maxWidth / scale,
                height: constraints.maxHeight / scale,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FocusBoardSlotToolbar extends StatelessWidget {
  const _FocusBoardSlotToolbar({
    required this.visible,
    required this.detached,
    required this.onToggleVisibility,
    required this.onDetach,
    required this.onAttach,
  });

  final bool visible;
  final bool detached;
  final VoidCallback onToggleVisibility;
  final VoidCallback onDetach;
  final VoidCallback onAttach;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: _deepTealColor,
        border: Border(bottom: BorderSide(color: Color(0x26000000))),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.dashboard_customize_outlined,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Focus Board',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            tooltip: visible ? 'Ocultar slot' : 'Mostrar slot',
            onPressed: onToggleVisibility,
            color: Colors.white,
            icon: Icon(
              visible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 18,
            ),
          ),
          IconButton(
            tooltip: detached ? 'Acoplar Focus Board' : 'Destacar Focus Board',
            onPressed: detached ? onAttach : onDetach,
            color: Colors.white,
            icon: Icon(
              detached
                  ? Icons.call_received_rounded
                  : Icons.open_in_full_rounded,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusBoardSlotPlaceholder extends StatelessWidget {
  const _FocusBoardSlotPlaceholder({
    required this.icon,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.primaryIcon,
    required this.onPrimary,
    required this.onToolbarDetach,
    required this.onToolbarAttach,
    required this.detached,
    required this.visible,
    required this.onToggleVisibility,
    this.showToolbar = true,
  });

  final IconData icon;
  final String title;
  final String message;
  final String primaryLabel;
  final IconData primaryIcon;
  final VoidCallback onPrimary;
  final VoidCallback onToolbarDetach;
  final VoidCallback onToolbarAttach;
  final bool detached;
  final bool visible;
  final VoidCallback onToggleVisibility;
  final bool showToolbar;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showToolbar)
          _FocusBoardSlotToolbar(
            visible: visible,
            detached: detached,
            onToggleVisibility: onToggleVisibility,
            onDetach: onToolbarDetach,
            onAttach: onToolbarAttach,
          ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _deepTealColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: _deepTealColor, size: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _inkColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _mutedColor,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: onPrimary,
                    icon: Icon(primaryIcon, size: 18),
                    label: Text(primaryLabel),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FocusBoardResizeHandle extends StatelessWidget {
  const _FocusBoardResizeHandle({
    required this.axis,
    required this.onDragDelta,
  });

  final Axis axis;
  final ValueChanged<DragUpdateDetails> onDragDelta;

  @override
  Widget build(BuildContext context) {
    final horizontal = axis == Axis.horizontal;
    return MouseRegion(
      cursor: horizontal
          ? SystemMouseCursors.resizeColumn
          : SystemMouseCursors.resizeRow,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: horizontal ? onDragDelta : null,
        onVerticalDragUpdate: horizontal ? null : onDragDelta,
        child: SizedBox(
          width: horizontal ? 12 : double.infinity,
          height: horizontal ? double.infinity : 12,
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _mutedColor.withValues(alpha: 0.42),
                borderRadius: BorderRadius.circular(99),
              ),
              child: SizedBox(
                width: horizontal ? 3 : 54,
                height: horizontal ? 54 : 3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FocusBoardFloatingWindow extends StatelessWidget {
  const _FocusBoardFloatingWindow({
    required this.controller,
    required this.viewerProfile,
    required this.maximized,
    required this.onMoveStart,
    required this.onMove,
    required this.onMoveEnd,
    required this.onResize,
    required this.onToggleMaximized,
    required this.onAttach,
  });

  final _FocusBoardPersistentController controller;
  final _ViewerAccessProfile viewerProfile;
  final bool maximized;
  final VoidCallback onMoveStart;
  final ValueChanged<Offset> onMove;
  final VoidCallback onMoveEnd;
  final ValueChanged<Offset> onResize;
  final VoidCallback onToggleMaximized;
  final VoidCallback onAttach;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 18,
      borderRadius: BorderRadius.circular(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _paperColor,
            border: Border.all(color: _lineColor),
            boxShadow: [
              BoxShadow(
                color: _inkColor.withValues(alpha: 0.18),
                blurRadius: 32,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.move,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (_) => onMoveStart(),
                  onPanUpdate: (details) => onMove(details.delta),
                  onPanEnd: (_) => onMoveEnd(),
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    color: const Color(0xFFF7FAF8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.drag_indicator_rounded,
                          color: _mutedColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.dashboard_customize_outlined,
                          color: _deepTealColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Focus Board',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: _inkColor,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        IconButton(
                          tooltip: maximized ? 'Restaurar' : 'Maximizar',
                          onPressed: onToggleMaximized,
                          icon: Icon(
                            maximized
                                ? Icons.fullscreen_exit_rounded
                                : Icons.fullscreen_rounded,
                            size: 18,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Acoplar no slot',
                          onPressed: onAttach,
                          icon: const Icon(
                            Icons.call_received_rounded,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _FocusBoardDetachedWorkspace(
                  controller: controller,
                  viewerProfile: viewerProfile,
                  onAttach: onAttach,
                  showHeader: false,
                  showPeopleSelector: false,
                  matchDockedLayout: true,
                ),
              ),
              if (!maximized)
                Align(
                  alignment: Alignment.bottomRight,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeDownRight,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanUpdate: (details) => onResize(details.delta),
                      child: const SizedBox(
                        width: 24,
                        height: 18,
                        child: Icon(
                          Icons.drag_handle_rounded,
                          color: _mutedColor,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FocusBoardDetachedWorkspace extends StatefulWidget {
  const _FocusBoardDetachedWorkspace({
    required this.controller,
    required this.viewerProfile,
    required this.onAttach,
    this.showHeader = true,
    this.showPeopleSelector = false,
    this.matchDockedLayout = false,
  });

  final _FocusBoardPersistentController controller;
  final _ViewerAccessProfile viewerProfile;
  final VoidCallback onAttach;
  final bool showHeader;
  final bool showPeopleSelector;
  final bool matchDockedLayout;

  @override
  State<_FocusBoardDetachedWorkspace> createState() =>
      _FocusBoardDetachedWorkspaceState();
}

class _FocusBoardDetachedWorkspaceState
    extends State<_FocusBoardDetachedWorkspace> {
  @override
  void initState() {
    super.initState();
    widget.controller.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.sizeOf(context).width;
            if (widget.matchDockedLayout) {
              final height = constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : 660.0;
              return Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  height: max(360.0, height - 24),
                  child: _FocusBoardRuntimeFrame(
                    controller: widget.controller,
                    viewerProfile: widget.viewerProfile,
                    compact: true,
                    onDetach: widget.onAttach,
                    onRefresh: widget.controller.refresh,
                    detachedLabel: 'Acoplar',
                    dockedPresentation: true,
                    collapseDockedFooterInitially: true,
                    onCreateReminder: (item, mode) =>
                        _openCreateReminder(item, mode),
                    onCancelReminder: _confirmCancelReminder,
                  ),
                ),
              );
            }
            final showSelector = widget.showPeopleSelector && width >= 980;
            final runtimeMaxWidth = showSelector ? 760.0 : double.infinity;
            final people = widget.controller.people;
            final selected = widget.controller.selectedItem;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                width >= 1120 ? 28 : 16,
                24,
                width >= 1120 ? 28 : 16,
                width >= 1120 ? 24 : 96,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: widget.showPeopleSelector ? 1180 : 820,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.showHeader) ...[
                        _FocusBoardDetachedHeader(
                          sourceLabel:
                              widget.controller.runtimeData.sourceLabel,
                          isLoading: widget.controller.runtimeData.isLoading,
                          onAttach: widget.onAttach,
                          onRefresh: widget.controller.refresh,
                        ),
                        const SizedBox(height: 18),
                      ],
                      if (widget.showPeopleSelector) ...[
                        if (showSelector)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 330,
                                child: _FocusBoardPeopleSelector(
                                  people: people,
                                  selectedPublicId: selected?.publicId,
                                  onSelected: widget.controller.selectPerson,
                                ),
                              ),
                              const SizedBox(width: 22),
                              Flexible(
                                fit: FlexFit.loose,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: runtimeMaxWidth,
                                  ),
                                  child: _FocusBoardRuntimeFrame(
                                    controller: widget.controller,
                                    viewerProfile: widget.viewerProfile,
                                    compact: false,
                                    onDetach: widget.onAttach,
                                    onRefresh: widget.controller.refresh,
                                    detachedLabel: 'Acoplar',
                                    onCreateReminder: (item, mode) =>
                                        _openCreateReminder(item, mode),
                                    onCancelReminder: _confirmCancelReminder,
                                  ),
                                ),
                              ),
                            ],
                          )
                        else ...[
                          _FocusBoardPeopleSelector(
                            people: people,
                            selectedPublicId: selected?.publicId,
                            onSelected: widget.controller.selectPerson,
                          ),
                          const SizedBox(height: 18),
                          _FocusBoardRuntimeFrame(
                            controller: widget.controller,
                            viewerProfile: widget.viewerProfile,
                            compact: false,
                            onDetach: widget.onAttach,
                            onRefresh: widget.controller.refresh,
                            detachedLabel: 'Acoplar',
                            onCreateReminder: (item, mode) =>
                                _openCreateReminder(item, mode),
                            onCancelReminder: _confirmCancelReminder,
                          ),
                        ],
                      ] else
                        _FocusBoardRuntimeFrame(
                          controller: widget.controller,
                          viewerProfile: widget.viewerProfile,
                          compact: false,
                          onDetach: widget.onAttach,
                          onRefresh: widget.controller.refresh,
                          detachedLabel: 'Acoplar',
                          onCreateReminder: (item, mode) =>
                              _openCreateReminder(item, mode),
                          onCancelReminder: _confirmCancelReminder,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openCreateReminder(
    _EntityItem item, [
    _FocusBoardTaskMode mode = _FocusBoardTaskMode.reminder,
  ]) async {
    final profile = item.personProfile;
    if (profile == null) {
      return;
    }

    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _CalendarEntryCrudDialog(
        personPublicId: item.publicId,
        personName: item.title,
        profile: profile,
        mode: mode,
      ),
    );

    if (body == null || !mounted) {
      return;
    }

    try {
      await widget.controller.createCalendarEntry(body);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${mode.label} criado na Focus Board.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_peopleMutationErrorMessage(error)),
          backgroundColor: _roseColor,
        ),
      );
    }
  }

  Future<void> _confirmCancelReminder(_CalendarEntryRecord entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar lembrete'),
        content: const Text(
          'O item sera marcado como cancelado, preservando historico e auditoria.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancelar item'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await widget.controller.cancelCalendarEntry(entry.publicId);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item cancelado na Focus Board.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_peopleMutationErrorMessage(error)),
          backgroundColor: _roseColor,
        ),
      );
    }
  }
}

class _FocusBoardRuntimeFrame extends StatelessWidget {
  const _FocusBoardRuntimeFrame({
    required this.controller,
    required this.viewerProfile,
    required this.compact,
    required this.onDetach,
    required this.onRefresh,
    required this.onCreateReminder,
    required this.onCancelReminder,
    this.dockedPresentation = false,
    this.collapseDockedFooterInitially = false,
    this.detachedLabel,
  });

  final _FocusBoardPersistentController controller;
  final _ViewerAccessProfile viewerProfile;
  final bool compact;
  final VoidCallback onDetach;
  final VoidCallback onRefresh;
  final void Function(_EntityItem, _FocusBoardTaskMode) onCreateReminder;
  final ValueChanged<_CalendarEntryRecord> onCancelReminder;
  final bool dockedPresentation;
  final bool collapseDockedFooterInitially;
  final String? detachedLabel;

  @override
  Widget build(BuildContext context) {
    final runtime = controller.runtimeData;
    final item = controller.selectedItem;
    final profile = item?.personProfile;

    if (runtime.isLoading && item == null) {
      return _FocusBoardShellCard(
        compact: compact,
        child: const _FocusBoardResponsiveViewport(
          compact: true,
          child: _FocusBoardLoadingState(),
        ),
      );
    }

    if (item == null || profile == null) {
      return _FocusBoardShellCard(
        compact: compact,
        child: _FocusBoardResponsiveViewport(
          compact: compact,
          child: _FocusBoardEmptyState(
            message:
                runtime.errorMessage ??
                'A Focus Board ainda nao recebeu colaboradores da API.',
            onRefresh: onRefresh,
          ),
        ),
      );
    }

    final notes = [...item.sensitiveNotes]
      ..sort((left, right) => left.sortOrder.compareTo(right.sortOrder));
    final sections = _buildSensitiveSections(notes);
    final docked = detachedLabel == null;
    final useDockedPresentation = docked || dockedPresentation;
    final hub = _FocusBoardHubPanel(
      viewerProfile: viewerProfile,
      item: item,
      profile: profile,
      people: controller.people,
      notesController: controller.notesController,
      attachments: item.attachments,
      sections: sections,
      calendarEntries: profile.calendarEntries,
      docked: useDockedPresentation,
      dockedFooterInitiallyCollapsed:
          useDockedPresentation && collapseDockedFooterInitially,
      onAddCalendarEntry: (mode) => onCreateReminder(item, mode),
      onCancelCalendarEntry: onCancelReminder,
      onDetach: onDetach,
      onRefresh: onRefresh,
      detachLabel: detachedLabel,
    );

    return _FocusBoardShellCard(
      compact: compact,
      child: useDockedPresentation
          ? hub
          : _FocusBoardResponsiveViewport(compact: compact, child: hub),
    );
  }
}

class _FocusBoardResponsiveViewport extends StatelessWidget {
  const _FocusBoardResponsiveViewport({
    required this.compact,
    required this.child,
  });

  final bool compact;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : (compact ? 380.0 : 680.0);
        final availableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : double.infinity;
        final effectiveCompact = compact || availableWidth < 520;
        final designWidth = effectiveCompact ? 380.0 : 680.0;
        final preferredHeight = effectiveCompact ? 560.0 : 680.0;
        final widthScale = availableWidth / designWidth;
        final heightScale = availableHeight.isFinite
            ? availableHeight / preferredHeight
            : 1.0;
        final scale = min(
          1.0,
          min(widthScale, heightScale),
        ).clamp(0.72, 1.0).toDouble();

        return ClipRect(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Align(
              alignment: Alignment.topLeft,
              widthFactor: scale,
              heightFactor: scale,
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.topLeft,
                child: SizedBox(width: designWidth, child: child),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FocusBoardShellCard extends StatelessWidget {
  const _FocusBoardShellCard({required this.child, required this.compact});

  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(compact ? 18 : 24),
      child: child,
    );
  }
}

class _FocusBoardLoadingState extends StatelessWidget {
  const _FocusBoardLoadingState();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Carregando Focus Board...',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: _inkColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusBoardEmptyState extends StatelessWidget {
  const _FocusBoardEmptyState({required this.message, required this.onRefresh});

  final String message;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _deepTealColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.dashboard_customize_outlined,
                  color: _deepTealColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Focus Board',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                tooltip: 'Atualizar',
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _mutedColor,
              height: 1.3,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusBoardDetachedHeader extends StatelessWidget {
  const _FocusBoardDetachedHeader({
    required this.sourceLabel,
    required this.isLoading,
    required this.onAttach,
    required this.onRefresh,
  });

  final String sourceLabel;
  final bool isLoading;
  final VoidCallback onAttach;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _deepTealColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.dashboard_customize_outlined,
              color: _deepTealColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Focus Board',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  'Focus Board | $sourceLabel',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _mutedColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Atualizar',
            onPressed: isLoading ? null : onRefresh,
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: onAttach,
            icon: const Icon(Icons.call_received_rounded, size: 18),
            label: const Text('Acoplar'),
          ),
        ],
      ),
    );
  }
}

class _FocusBoardPeopleSelector extends StatelessWidget {
  const _FocusBoardPeopleSelector({
    required this.people,
    required this.selectedPublicId,
    required this.onSelected,
  });

  final List<_EntityItem> people;
  final String? selectedPublicId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Colaboradores',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: _inkColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          if (people.isEmpty)
            const _HubEmptyLine(
              icon: Icons.people_outline_rounded,
              text: 'Nenhum colaborador carregado para selecionar.',
            )
          else
            for (final item in people.take(12)) ...[
              _FocusBoardPersonOption(
                item: item,
                selected: item.publicId == selectedPublicId,
                onTap: () => onSelected(item.publicId),
              ),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }
}

class _FocusBoardPersonOption extends StatelessWidget {
  const _FocusBoardPersonOption({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _EntityItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected
              ? _tealColor.withValues(alpha: 0.10)
              : const Color(0xFFF8FAFB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? _tealColor.withValues(alpha: 0.28) : _lineColor,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: item.color.withValues(alpha: 0.13),
              child: Icon(item.icon, size: 18, color: item.color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _inkColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _mutedColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: _tealColor,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
