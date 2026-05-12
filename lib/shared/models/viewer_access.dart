part of '../../app/app.dart';

enum _CollaboratorAudienceGroup { board, supervision, auxiliary }

extension on _CollaboratorAudienceGroup {
  String get key => switch (this) {
    _CollaboratorAudienceGroup.board => 'DIRECTOR',
    _CollaboratorAudienceGroup.supervision => 'SUPERVISION',
    _CollaboratorAudienceGroup.auxiliary => 'AUXILIARY',
  };

  String get label => switch (this) {
    _CollaboratorAudienceGroup.board => 'Diretoria',
    _CollaboratorAudienceGroup.supervision => 'Supervisao',
    _CollaboratorAudienceGroup.auxiliary => 'Auxiliares',
  };

  IconData get icon => switch (this) {
    _CollaboratorAudienceGroup.board => Icons.approval_outlined,
    _CollaboratorAudienceGroup.supervision => Icons.manage_accounts_outlined,
    _CollaboratorAudienceGroup.auxiliary => Icons.groups_outlined,
  };

  Color get color => switch (this) {
    _CollaboratorAudienceGroup.board => _tealColor,
    _CollaboratorAudienceGroup.supervision => _amberColor,
    _CollaboratorAudienceGroup.auxiliary => _slateColor,
  };
}

_CollaboratorAudienceGroup? _audienceGroupFromKey(String key) {
  final normalized = key.trim().toUpperCase();
  for (final group in _CollaboratorAudienceGroup.values) {
    if (group.key == normalized) {
      return group;
    }
  }
  return null;
}

class _AudiencePerson {
  const _AudiencePerson({required this.publicId, required this.name});

  final String publicId;
  final String name;

  Color get color => _slateColor;
}

class _ViewerAccessProfile {
  const _ViewerAccessProfile({
    required this.key,
    required this.name,
    required this.badge,
    required this.description,
    required this.icon,
    required this.color,
    this.publicId,
    this.organizationLabel,
    this.groups = const [],
  });

  final String key;
  final String name;
  final String badge;
  final String description;
  final IconData icon;
  final Color color;
  final String? publicId;
  final String? organizationLabel;
  final List<_CollaboratorAudienceGroup> groups;

  bool get isAuthenticated => publicId != null;

  bool get canViewSensitive => isAuthenticated;

  String get label =>
      isAuthenticated ? 'consulta autenticada' : 'entrada publica';

  String get consultationSummary => isAuthenticated
      ? 'leitura so do que a API liberar'
      : 'somente envio sem login';

  String get managementSummary => isAuthenticated
      ? 'gestao restrita a autoria autenticada'
      : 'sem leitura, edicao ou exclusao';
}

const _publicViewerProfile = _ViewerAccessProfile(
  key: 'public',
  name: 'Entrada publica',
  badge: 'PG',
  description:
      'Pode enviar observacoes curtas sem login, mas nao pode consultar nenhum conteudo protegido.',
  icon: Icons.outbox_outlined,
  color: _amberColor,
);

const _sessionViewerProfileFallback = _ViewerAccessProfile(
  key: 'authenticated-session',
  name: 'Sessao autenticada',
  badge: 'SA',
  description:
      'Perfil autenticado carregado da sessao da API. A leitura fica limitada ao que o backend liberar.',
  icon: Icons.verified_user_outlined,
  color: _tealColor,
);

_ViewerAccessProfile _viewerProfileFromSession(SessionSnapshot session) {
  final groups = [
    for (final key in session.audienceGroups)
      if (_audienceGroupFromKey(key) != null) _audienceGroupFromKey(key)!,
  ];
  final primaryGroup = groups.isEmpty ? null : groups.first;
  final name = session.userName.trim().isEmpty
      ? 'Sessao autenticada'
      : session.userName.trim();
  final publicId = session.userPublicId.trim();

  return _ViewerAccessProfile(
    key: publicId.isEmpty ? 'authenticated-session' : publicId,
    name: name,
    badge: _viewerBadgeFromName(name),
    description:
        'Perfil carregado da sessao da API. Perfis: ${session.profiles.isEmpty ? session.securityContext : session.profiles.join('/')}',
    icon: primaryGroup?.icon ?? Icons.verified_user_outlined,
    color: primaryGroup?.color ?? _tealColor,
    publicId: publicId.isEmpty ? null : publicId,
    organizationLabel: session.tenantRootCompanyLabel.isEmpty
        ? null
        : session.tenantRootCompanyLabel,
    groups: groups,
  );
}

String _viewerBadgeFromName(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);
  if (parts.isEmpty) {
    return 'SA';
  }
  if (parts.length == 1) {
    return parts.first.substring(0, min(2, parts.first.length)).toUpperCase();
  }
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

List<_ViewerAccessProfile> _viewerProfileOptions(_ViewerAccessProfile current) {
  return [current.isAuthenticated ? current : _publicViewerProfile];
}

class _ProtectedAccessPolicy {
  const _ProtectedAccessPolicy({
    required this.owner,
    this.allowedGroups = const [],
    this.allowedPeople = const [],
    this.canViewOverride,
    this.canManageOverride,
  });

  final _AudiencePerson owner;
  final List<_CollaboratorAudienceGroup> allowedGroups;
  final List<_AudiencePerson> allowedPeople;
  final bool? canViewOverride;
  final bool? canManageOverride;

  String get ownerUserPublicId => owner.publicId;

  List<String> get allowedGroupKeys =>
      allowedGroups.map((group) => group.key).toList(growable: false);

  List<String> get allowedUserPublicIds =>
      allowedPeople.map((person) => person.publicId).toList(growable: false);

  bool get isOwnerOnly => allowedGroups.isEmpty && allowedPeople.isEmpty;

  bool canViewerRead(_ViewerAccessProfile viewer) {
    if (!viewer.isAuthenticated || viewer.publicId == null) {
      return false;
    }
    if (canViewOverride != null) {
      return canViewOverride!;
    }
    if (viewer.publicId == owner.publicId) {
      return true;
    }
    if (allowedPeople.any((person) => person.publicId == viewer.publicId)) {
      return true;
    }
    for (final group in allowedGroups) {
      if (viewer.groups.contains(group)) {
        return true;
      }
    }
    return false;
  }

  bool canViewerManage(_ViewerAccessProfile viewer) =>
      canManageOverride ??
      (viewer.publicId != null && viewer.publicId == owner.publicId);

  bool canViewerEdit(_ViewerAccessProfile viewer) => canViewerManage(viewer);

  bool canViewerDelete(_ViewerAccessProfile viewer) => canViewerManage(viewer);

  String get audienceSummary => isOwnerOnly
      ? 'somente a autora ou o autor'
      : 'compartilhado com grupos e pessoas especificas';
}
