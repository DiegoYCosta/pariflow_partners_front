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
    _AttachmentClassification.formalDocument =>
      Icons.description_outlined,
    _AttachmentClassification.sensitiveAttachment =>
      Icons.lock_outline_rounded,
    _AttachmentClassification.supportingReference =>
      Icons.attach_file_rounded,
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
    required this.title,
    required this.classification,
    required this.summary,
    required this.status,
    required this.updatedAtLabel,
    required this.accessPolicy,
    this.canDownload = true,
  });

  final String publicId;
  final String title;
  final _AttachmentClassification classification;
  final String summary;
  final String status;
  final String updatedAtLabel;
  final _ProtectedAccessPolicy accessPolicy;
  final bool canDownload;

  String accessSummary(_ViewerAccessProfile viewer) {
    if (!accessPolicy.canViewerRead(viewer)) {
      return 'conteudo nao compartilhado com este perfil';
    }
    return canDownload
        ? 'consulta liberada | download rastreavel'
        : 'consulta liberada | sem download direto';
  }
}
