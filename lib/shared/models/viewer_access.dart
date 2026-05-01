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

class _AudiencePerson {
  const _AudiencePerson({
    required this.publicId,
    required this.name,
    required this.group,
  });

  final String publicId;
  final String name;
  final _CollaboratorAudienceGroup group;
}

const _audienceDiego = _AudiencePerson(
  publicId: 'usr_01hdgo0000000000000001',
  name: 'Diego Costa',
  group: _CollaboratorAudienceGroup.board,
);

const _audienceMarta = _AudiencePerson(
  publicId: 'usr_01hmrt0000000000000002',
  name: 'Marta Nogueira',
  group: _CollaboratorAudienceGroup.supervision,
);

const _audienceCamila = _AudiencePerson(
  publicId: 'usr_01hcml0000000000000003',
  name: 'Camila Prado',
  group: _CollaboratorAudienceGroup.supervision,
);

const _audienceLucas = _AudiencePerson(
  publicId: 'usr_01hlcs0000000000000004',
  name: 'Lucas Lima',
  group: _CollaboratorAudienceGroup.auxiliary,
);

class _ViewerAccessProfile {
  const _ViewerAccessProfile({
    required this.key,
    required this.name,
    required this.badge,
    required this.description,
    required this.icon,
    required this.color,
    this.publicId,
    this.groups = const [],
  });

  final String key;
  final String name;
  final String badge;
  final String description;
  final IconData icon;
  final Color color;
  final String? publicId;
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

const _diegoViewerProfile = _ViewerAccessProfile(
  key: 'diego',
  name: 'Diego Costa',
  badge: 'DC',
  description:
      'Perfil autenticado da Diretoria. So enxerga o que foi compartilhado com ele, com Diretoria ou por autoria propria.',
  icon: Icons.approval_outlined,
  color: _tealColor,
  publicId: 'usr_01hdgo0000000000000001',
  groups: [_CollaboratorAudienceGroup.board],
);

const _martaViewerProfile = _ViewerAccessProfile(
  key: 'marta',
  name: 'Marta Nogueira',
  badge: 'MN',
  description:
      'Perfil autenticado de Supervisao. Leitura limitada ao que foi compartilhado com Supervisao, diretamente com Marta ou por autoria propria.',
  icon: Icons.manage_accounts_outlined,
  color: _amberColor,
  publicId: 'usr_01hmrt0000000000000002',
  groups: [_CollaboratorAudienceGroup.supervision],
);

const _camilaViewerProfile = _ViewerAccessProfile(
  key: 'camila',
  name: 'Camila Prado',
  badge: 'CP',
  description:
      'Perfil autenticado usado para validar compartilhamento por pessoa especifica, sem depender de todo o grupo de Supervisao.',
  icon: Icons.alternate_email_outlined,
  color: _roseColor,
  publicId: 'usr_01hcml0000000000000003',
  groups: [_CollaboratorAudienceGroup.supervision],
);

const _lucasViewerProfile = _ViewerAccessProfile(
  key: 'lucas',
  name: 'Lucas Lima',
  badge: 'LL',
  description:
      'Perfil autenticado de Auxiliares. So consulta conteudo enviado especificamente para esse grupo, para Lucas ou criado por ele.',
  icon: Icons.groups_outlined,
  color: _slateColor,
  publicId: 'usr_01hlcs0000000000000004',
  groups: [_CollaboratorAudienceGroup.auxiliary],
);

const _viewerProfiles = [
  _publicViewerProfile,
  _diegoViewerProfile,
  _martaViewerProfile,
  _camilaViewerProfile,
  _lucasViewerProfile,
];

class _ProtectedAccessPolicy {
  const _ProtectedAccessPolicy({
    required this.owner,
    this.allowedGroups = const [],
    this.allowedPeople = const [],
  });

  final _AudiencePerson owner;
  final List<_CollaboratorAudienceGroup> allowedGroups;
  final List<_AudiencePerson> allowedPeople;

  String get ownerUserPublicId => owner.publicId;

  List<String> get allowedGroupKeys => allowedGroups
      .map((group) => group.key)
      .toList(growable: false);

  List<String> get allowedUserPublicIds => allowedPeople
      .map((person) => person.publicId)
      .toList(growable: false);

  bool get isOwnerOnly =>
      allowedGroups.isEmpty && allowedPeople.isEmpty;

  bool canViewerRead(_ViewerAccessProfile viewer) {
    if (!viewer.isAuthenticated || viewer.publicId == null) {
      return false;
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
      viewer.publicId != null && viewer.publicId == owner.publicId;

  bool canViewerEdit(_ViewerAccessProfile viewer) => canViewerManage(viewer);

  bool canViewerDelete(_ViewerAccessProfile viewer) => canViewerManage(viewer);

  String get audienceSummary => isOwnerOnly
      ? 'somente a autora ou o autor'
      : 'compartilhado com grupos e pessoas especificas';
}
