part of '../../app/app.dart';

enum _ViewerAccessLevel {
  publicSubmission,
  authenticatedReader,
  privilegedOperator,
}

extension on _ViewerAccessLevel {
  String get label => switch (this) {
    _ViewerAccessLevel.publicSubmission => 'entrada publica',
    _ViewerAccessLevel.authenticatedReader => 'consulta autenticada',
    _ViewerAccessLevel.privilegedOperator => 'perfil privilegiado',
  };

  String get description => switch (this) {
    _ViewerAccessLevel.publicSubmission =>
      'Pode enviar tag curta sem login, mas nao pode consultar conteudo sensivel.',
    _ViewerAccessLevel.authenticatedReader =>
      'Ja consegue ler tags e anexos protegidos, sem abrir ferramentas internas de gestao.',
    _ViewerAccessLevel.privilegedOperator =>
      'Leitura autenticada com trilha interna para editar ordem, cor e remocao logica.',
  };

  IconData get icon => switch (this) {
    _ViewerAccessLevel.publicSubmission => Icons.outbox_outlined,
    _ViewerAccessLevel.authenticatedReader => Icons.verified_user_outlined,
    _ViewerAccessLevel.privilegedOperator => Icons.admin_panel_settings_outlined,
  };

  Color get color => switch (this) {
    _ViewerAccessLevel.publicSubmission => _amberColor,
    _ViewerAccessLevel.authenticatedReader => _slateColor,
    _ViewerAccessLevel.privilegedOperator => _tealColor,
  };

  bool get canViewSensitive => this != _ViewerAccessLevel.publicSubmission;

  bool get canManageSensitive =>
      this == _ViewerAccessLevel.privilegedOperator;

  String get consultationSummary => canViewSensitive
      ? 'consulta sensivel liberada'
      : 'consulta sensivel bloqueada';

  String get managementSummary => canManageSensitive
      ? 'edicao e remocao internas habilitadas'
      : 'sem acoes internas de gestao';
}
