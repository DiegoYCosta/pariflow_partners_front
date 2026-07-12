part of '../../../app/app.dart';

class _FocusBoardRemotePermissions {
  const _FocusBoardRemotePermissions({
    this.canEdit = false,
    this.canComplete = false,
    this.canArchive = false,
    this.canTrash = false,
    this.canRestore = false,
    this.canDelete = false,
  });

  final bool canEdit;
  final bool canComplete;
  final bool canArchive;
  final bool canTrash;
  final bool canRestore;
  final bool canDelete;

  static _FocusBoardRemotePermissions fromApi(Map<String, dynamic> json) {
    return _FocusBoardRemotePermissions(
      canEdit: json['canEdit'] == true,
      canComplete: json['canComplete'] == true,
      canArchive: json['canArchive'] == true,
      canTrash: json['canTrash'] == true,
      canRestore: json['canRestore'] == true,
      canDelete: json['canDelete'] == true,
    );
  }
}

class _FocusBoardRemoteNotePayload {
  const _FocusBoardRemoteNotePayload({
    required this.note,
    required this.version,
    required this.permissions,
  });

  final _FocusBoardNote note;
  final int version;
  final _FocusBoardRemotePermissions permissions;
}

class _FocusBoardRemoteEvent {
  const _FocusBoardRemoteEvent({
    required this.publicId,
    required this.eventType,
    required this.summary,
    required this.actorName,
    required this.createdAt,
  });

  final String publicId;
  final String eventType;
  final String summary;
  final String actorName;
  final DateTime createdAt;

  _FocusBoardAuditEntry toAuditEntry() {
    return _FocusBoardAuditEntry(
      at: createdAt,
      actorId: publicId,
      actorName: actorName,
      action: eventType,
      details: summary,
    );
  }
}
