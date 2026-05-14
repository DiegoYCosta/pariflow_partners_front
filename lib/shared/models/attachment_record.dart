part of '../../app/app.dart';

enum _AttachmentClassification {
  formalDocument,
  sensitiveAttachment,
  supportingReference,
}

extension on _AttachmentClassification {
  String get label => switch (this) {
    _AttachmentClassification.formalDocument => 'documento formal',
    _AttachmentClassification.sensitiveAttachment => 'anexo sensivel',
    _AttachmentClassification.supportingReference => 'referencia de apoio',
  };

  String get description => switch (this) {
    _AttachmentClassification.formalDocument =>
      'Documento oficial usado para leitura cadastral, juridica ou contratual.',
    _AttachmentClassification.sensitiveAttachment =>
      'Arquivo protegido que existe no dossie, mas depende de sessao para leitura integral.',
    _AttachmentClassification.supportingReference =>
      'Referencia operacional ou memoria lateral que nao substitui documento formal.',
  };

  IconData get icon => switch (this) {
    _AttachmentClassification.formalDocument => Icons.description_outlined,
    _AttachmentClassification.sensitiveAttachment => Icons.lock_outline_rounded,
    _AttachmentClassification.supportingReference => Icons.attach_file_rounded,
  };

  Color get color => switch (this) {
    _AttachmentClassification.formalDocument => _tealColor,
    _AttachmentClassification.sensitiveAttachment => _roseColor,
    _AttachmentClassification.supportingReference => _amberColor,
  };
}

class _AttachmentRecord {
  const _AttachmentRecord({
    required this.publicId,
    this.occurrencePublicId = '',
    required this.title,
    required this.classification,
    required this.summary,
    required this.status,
    required this.updatedAtLabel,
    required this.accessPolicy,
    this.displayScope = '',
    this.mimeType = '',
    this.externalLink = '',
    this.physicalLocation = '',
    this.accessSource = '',
    this.requiresSensitiveSession = false,
    this.canDownload = true,
    this.canEdit = false,
    this.canDelete = false,
  });

  final String publicId;
  final String occurrencePublicId;
  final String title;
  final _AttachmentClassification classification;
  final String summary;
  final String status;
  final String updatedAtLabel;
  final _ProtectedAccessPolicy accessPolicy;
  final String displayScope;
  final String mimeType;
  final String externalLink;
  final String physicalLocation;
  final String accessSource;
  final bool requiresSensitiveSession;
  final bool canDownload;
  final bool canEdit;
  final bool canDelete;

  String accessSummary(_ViewerAccessProfile viewer) {
    if (!accessPolicy.canViewerRead(viewer)) {
      return 'conteudo nao compartilhado com este perfil';
    }
    if (requiresSensitiveSession) {
      return 'consulta liberada | step-up sensivel obrigatorio';
    }
    return canDownload
        ? 'consulta liberada | download rastreavel'
        : 'consulta liberada | sem download direto';
  }

  String get accessSourceLabel {
    return switch (accessSource.toUpperCase()) {
      'S3_PRIVATE' => 'storage privado',
      'EXTERNAL_LINK' => 'link externo auditado',
      'METADATA_ONLY' => 'sem arquivo digital',
      _ =>
        externalLink.isNotEmpty
            ? 'link externo auditado'
            : physicalLocation.isNotEmpty
            ? 'arquivo fisico'
            : 'origem protegida',
    };
  }
}
