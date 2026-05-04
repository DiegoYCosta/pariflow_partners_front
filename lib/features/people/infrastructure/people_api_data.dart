part of '../../../app/app.dart';

class _PeopleApiRepository {
  _PeopleApiRepository({_ApiClient? apiClient})
    : _apiClient = apiClient ?? _ApiClient();

  final _ApiClient _apiClient;

  Future<_PeopleRuntimeData> loadWorkspaceData() async {
    final session = await _apiClient.ensureDevelopmentSession();
    final peopleEnvelope = await _apiClient.getMap(
      'pessoas',
      query: const {'page': '1', 'perPage': '24'},
    );
    final people = _apiMapList(peopleEnvelope['items']);

    if (people.isEmpty) {
      return _PeopleRuntimeData.mock(
        errorMessage:
            'API conectada, mas ainda nao ha pessoas no banco local. Mantive o mock para preservar a leitura da tela.',
      );
    }

    final bundles = await Future.wait(people.map(_loadPersonBundle));
    final items = bundles.map(_entityItemFromApi).toList(growable: false);

    return _PeopleRuntimeData.live(
      _EntityWorkspaceData(
        title: 'Funcionarios com dados reais',
        subtitle:
            'Consulta de pessoas vinda da API, preservando registro-base, vinculos, tags sensiveis e anexos autorizados pelo backend.',
        searchHint: 'GET /api/v1/pessoas',
        listHint:
            'A lista usa publicId e envelope padrao da API para abrir a ficha operacional.',
        productionHint:
            'Corte vertical ativo: sessao dev-token, pessoas, vinculos, tags e anexos lidos do backend com fallback local.',
        integrationFocus: [
          'API real',
          'publicId',
          'ACL no backend',
          'fallback seguro',
        ],
        filters: ['pessoas', 'vinculos', 'tags-entidade', 'anexos'],
        accent: _roseColor,
        items: items,
      ),
      session,
    );
  }

  Future<_PeopleApiBundle> _loadPersonBundle(
    Map<String, dynamic> listItem,
  ) async {
    final publicId = _apiText(listItem['publicId']);

    final detailFuture = _apiClient
        .getMap('pessoas/$publicId')
        .catchError((_) => listItem);
    final linksFuture = _safeItems(
      'vinculos',
      query: {'personPublicId': publicId, 'perPage': '20'},
    );
    final tagsFuture = _safeItems(
      'tags-entidade',
      query: {'targetType': 'PERSON', 'targetPublicId': publicId},
    );
    final attachmentsFuture = _safeItems(
      'anexos',
      query: {'personPublicId': publicId},
    );

    return _PeopleApiBundle(
      detail: await detailFuture,
      links: await linksFuture,
      tags: await tagsFuture,
      attachments: await attachmentsFuture,
    );
  }

  Future<List<Map<String, dynamic>>> _safeItems(
    String path, {
    Map<String, String?> query = const {},
  }) async {
    try {
      final data = await _apiClient.getMap(path, query: query);
      return _apiMapList(data['items']);
    } on _ApiException {
      return const [];
    }
  }
}

class _PeopleRuntimeData {
  const _PeopleRuntimeData({
    required this.data,
    required this.sourceLabel,
    required this.isLive,
    required this.isLoading,
    this.session,
    this.errorMessage,
  });

  factory _PeopleRuntimeData.mock({String? errorMessage}) {
    return _PeopleRuntimeData(
      data: _peopleWorkspaceData,
      sourceLabel: errorMessage == null ? 'mock local' : 'mock fallback',
      isLive: false,
      isLoading: false,
      errorMessage: errorMessage,
    );
  }

  factory _PeopleRuntimeData.live(
    _EntityWorkspaceData data,
    _SessionSnapshot session,
  ) {
    final profileLabel = session.profiles.isEmpty
        ? session.securityContext
        : session.profiles.join('/');
    return _PeopleRuntimeData(
      data: data,
      sourceLabel: 'API real | $profileLabel',
      isLive: true,
      isLoading: false,
      session: session,
    );
  }

  final _EntityWorkspaceData data;
  final String sourceLabel;
  final bool isLive;
  final bool isLoading;
  final _SessionSnapshot? session;
  final String? errorMessage;

  _PeopleRuntimeData copyWith({bool? isLoading}) {
    return _PeopleRuntimeData(
      data: data,
      sourceLabel: isLoading == true ? 'sincronizando API' : sourceLabel,
      isLive: isLive,
      isLoading: isLoading ?? this.isLoading,
      session: session,
      errorMessage: isLoading == true ? null : errorMessage,
    );
  }
}

class _PeopleApiBundle {
  const _PeopleApiBundle({
    required this.detail,
    required this.links,
    required this.tags,
    required this.attachments,
  });

  final Map<String, dynamic> detail;
  final List<Map<String, dynamic>> links;
  final List<Map<String, dynamic>> tags;
  final List<Map<String, dynamic>> attachments;
}

_EntityItem _entityItemFromApi(_PeopleApiBundle bundle) {
  final person = bundle.detail;
  final links = bundle.links.isNotEmpty
      ? bundle.links
      : _apiMapList(person['links']);
  final currentLink = _currentApiLink(links);
  final publicId = _apiText(person['publicId']);
  final name = _apiText(person['name'], fallback: 'Pessoa sem nome');
  final roleTitle = _apiRoleTitle(currentLink);
  final providerCompany = _apiProviderCompanyName(currentLink);
  final clientCompany = _apiClientCompanyName(currentLink);
  final linkCount = links.length;
  final status = _apiPersonStatus(links);
  final statusLabel = switch (status) {
    _ApiPersonStatus.active => 'ativo',
    _ApiPersonStatus.dismissed => 'desligado recente',
    _ApiPersonStatus.historical => 'historico',
    _ApiPersonStatus.unlinked => 'sem vinculo',
  };
  final color = switch (status) {
    _ApiPersonStatus.active => _tealColor,
    _ApiPersonStatus.dismissed => _roseColor,
    _ApiPersonStatus.historical => _amberColor,
    _ApiPersonStatus.unlinked => _slateColor,
  };
  final icon = switch (status) {
    _ApiPersonStatus.active => Icons.badge_outlined,
    _ApiPersonStatus.dismissed => Icons.person_off_outlined,
    _ApiPersonStatus.historical => Icons.history_rounded,
    _ApiPersonStatus.unlinked => Icons.person_outline_rounded,
  };
  final tags = bundle.tags
      .where((tag) => tag['canView'] != false)
      .map(_sensitiveNoteFromApi)
      .toList(growable: false);
  final attachments = bundle.attachments
      .where((attachment) => attachment['canView'] != false)
      .map(_attachmentFromApi)
      .toList(growable: false);

  return _EntityItem(
    publicId: publicId,
    title: name,
    subtitle: '$roleTitle | $clientCompany',
    meta: '$statusLabel | $linkCount vinculos | $providerCompany',
    status: statusLabel,
    icon: icon,
    color: color,
    detailSummary:
        'Registro carregado do backend com pessoa, vinculos, tags sensiveis e anexos autorizados por ACL.',
    relations: [
      'CPF: ${_apiText(person['cpf'], fallback: 'nao informado')}',
      'Email: ${_apiText(person['email'], fallback: 'nao informado')}',
      'Telefone: ${_apiText(person['phone'], fallback: 'nao informado')}',
      'Prestadora atual: $providerCompany',
      'Cliente conectado: $clientCompany',
      'Vinculos carregados: $linkCount',
      'Tags visiveis: ${tags.length}',
      'Anexos visiveis: ${attachments.length}',
    ],
    attachments: attachments,
    sensitiveNotes: tags,
    personProfile: _personProfileFromApi(person, links),
  );
}

_PersonProfileData _personProfileFromApi(
  Map<String, dynamic> person,
  List<Map<String, dynamic>> links,
) {
  final currentLink = _currentApiLink(links);
  final roleTitle = _apiRoleTitle(currentLink);
  final providerCompany = _apiProviderCompanyName(currentLink);
  final clientCompany = _apiClientCompanyName(currentLink);
  final position = _apiMap(currentLink?['position']);
  final service = _apiMap(position['service']);
  final location = _apiText(
    position['location'],
    fallback: _apiText(clientCompany, fallback: 'contexto nao informado'),
  );
  final status = _apiPersonStatus(links);
  final statusLabel = switch (status) {
    _ApiPersonStatus.active => 'Active',
    _ApiPersonStatus.dismissed => 'Dismissed',
    _ApiPersonStatus.historical => 'Historical Link',
    _ApiPersonStatus.unlinked => 'No Link',
  };
  final statusColor = switch (status) {
    _ApiPersonStatus.active => _tealColor,
    _ApiPersonStatus.dismissed => _roseColor,
    _ApiPersonStatus.historical => _amberColor,
    _ApiPersonStatus.unlinked => _slateColor,
  };

  return _PersonProfileData(
    roleTitle: roleTitle,
    statusLabel: statusLabel,
    statusColor: statusColor,
    profileFields: [
      _PersonInfoField(
        icon: Icons.mail_outline_rounded,
        label: 'Email',
        value: _apiText(person['email'], fallback: 'nao informado'),
      ),
      _PersonInfoField(
        icon: Icons.call_outlined,
        label: 'Phone',
        value: _apiText(person['phone'], fallback: 'nao informado'),
      ),
      _PersonInfoField(
        icon: Icons.badge_outlined,
        label: 'CPF',
        value: _apiText(person['cpf'], fallback: 'nao informado'),
      ),
      _PersonInfoField(
        icon: Icons.assignment_ind_outlined,
        label: 'RG',
        value: _apiText(person['rg'], fallback: 'nao informado'),
      ),
      _PersonInfoField(
        icon: Icons.cake_outlined,
        label: 'Date of Birth',
        value: _apiLongDate(person['birthDate']),
      ),
      _PersonInfoField(
        icon: Icons.business_outlined,
        label: 'Provider',
        value: providerCompany,
      ),
      _PersonInfoField(
        icon: Icons.apartment_rounded,
        label: 'Client',
        value: clientCompany,
      ),
      _PersonInfoField(
        icon: Icons.location_on_outlined,
        label: 'Location',
        value: location,
      ),
    ],
    managerName: providerCompany,
    managerRole: 'Empresa prestadora',
    teamLabel: clientCompany,
    departmentLabel: _apiText(
      service['name'],
      fallback: _apiText(position['status'], fallback: 'Operacao'),
    ),
    timelineSummary:
        '${links.length} vinculos carregados diretamente de /api/v1/vinculos.',
    employmentLinks: links.map(_employmentLinkFromApi).toList(growable: false),
  );
}

_EmploymentLinkRecord _employmentLinkFromApi(Map<String, dynamic> link) {
  final providerCompany = _apiProviderCompanyName(link);
  final position = _apiMap(link['position']);
  final startsAt = _apiDate(link['startsAt']);
  final endsAt = _apiDate(link['endsAt']);
  final dismissedAt = _apiDate(_apiMap(link['dismissal'])['dismissedAt']);
  final effectiveEnd = endsAt ?? dismissedAt;
  final status = _apiText(link['status']).toUpperCase();
  final isCurrent = status == 'ACTIVE' && effectiveEnd == null;
  final roleTitle = _apiRoleTitle(link);
  final location = _apiText(
    position['location'],
    fallback: _apiClientCompanyName(link),
  );

  return _EmploymentLinkRecord(
    periodLabel:
        '${_apiShortMonthYear(startsAt)}\n- ${isCurrent ? 'Present' : _apiShortMonthYear(effectiveEnd)}',
    companyName: providerCompany,
    roleTitle: roleTitle,
    fullDateLabel:
        '${_apiLongDate(startsAt)} - ${isCurrent ? 'Present' : _apiLongDate(effectiveEnd)}',
    locationLabel: location,
    brandMonogram: _companyMonogram(providerCompany),
    accent: isCurrent
        ? _tealColor
        : status == 'DISMISSED'
        ? _roseColor
        : _amberColor,
    isCurrent: isCurrent,
  );
}

_SensitiveNoteTag _sensitiveNoteFromApi(Map<String, dynamic> tag) {
  final classification = _sensitiveClassificationFromApi(
    _apiText(tag['classification']),
  );
  final color = _apiColor(
    _apiText(tag['color']),
    fallback: _sensitiveClassificationColor(classification),
  );

  return _SensitiveNoteTag(
    label: _apiText(tag['label'], fallback: 'tag sensivel'),
    note: _apiText(tag['content'], fallback: 'Sem conteudo informado.'),
    classification: classification,
    color: color,
    sortOrder: _apiInt(tag['sortOrder']),
    accessPolicy: _apiReturnedContentAccessPolicy,
  );
}

_AttachmentRecord _attachmentFromApi(Map<String, dynamic> attachment) {
  final classification = _attachmentClassificationFromApi(
    _apiText(attachment['classification']),
  );
  final updatedAt = attachment['updatedAt'] ?? attachment['createdAt'];

  return _AttachmentRecord(
    publicId: _apiText(attachment['publicId']),
    title: _apiText(attachment['fileName'], fallback: 'Anexo protegido'),
    classification: classification,
    summary: _attachmentSummaryFromApi(attachment),
    status: _apiText(attachment['status'], fallback: 'ACTIVE').toLowerCase(),
    updatedAtLabel: 'atualizado em ${_apiLongDate(updatedAt)}',
    accessPolicy: _apiReturnedContentAccessPolicy,
    canDownload: attachment['canDownload'] != false,
  );
}

String _attachmentSummaryFromApi(Map<String, dynamic> attachment) {
  final scope = _apiText(attachment['displayScope']);
  final location = _apiText(
    attachment['physicalLocation'],
    fallback: _apiText(attachment['externalLink']),
  );

  if (scope.isNotEmpty && location.isNotEmpty) {
    return '$scope | $location';
  }
  if (scope.isNotEmpty) {
    return scope;
  }
  if (location.isNotEmpty) {
    return location;
  }
  return 'Anexo autorizado pelo backend para a sessao atual.';
}

enum _ApiPersonStatus { active, dismissed, historical, unlinked }

_ApiPersonStatus _apiPersonStatus(List<Map<String, dynamic>> links) {
  if (links.isEmpty) {
    return _ApiPersonStatus.unlinked;
  }
  if (links.any((link) => _apiText(link['status']).toUpperCase() == 'ACTIVE')) {
    return _ApiPersonStatus.active;
  }
  if (links.any(
    (link) => _apiText(link['status']).toUpperCase() == 'DISMISSED',
  )) {
    return _ApiPersonStatus.dismissed;
  }
  return _ApiPersonStatus.historical;
}

Map<String, dynamic>? _currentApiLink(List<Map<String, dynamic>> links) {
  for (final link in links) {
    if (_apiText(link['status']).toUpperCase() == 'ACTIVE') {
      return link;
    }
  }
  return links.isEmpty ? null : links.first;
}

String _apiRoleTitle(Map<String, dynamic>? link) {
  final position = _apiMap(link?['position']);
  return _apiText(
    position['name'],
    fallback: _apiText(link?['type'], fallback: 'Sem cargo ativo'),
  );
}

String _apiProviderCompanyName(Map<String, dynamic>? link) {
  final providerCompany = _apiMap(link?['providerCompany']);
  return _apiText(
    providerCompany['tradeName'],
    fallback: _apiText(
      providerCompany['legalName'],
      fallback: 'Prestadora nao informada',
    ),
  );
}

String _apiClientCompanyName(Map<String, dynamic>? link) {
  final contract = _apiMap(link?['contract']);
  final clientCompany = _apiMap(contract['clientCompany']);
  return _apiText(clientCompany['name'], fallback: 'Cliente nao informado');
}

List<Map<String, dynamic>> _apiMapList(Object? value) {
  if (value is! List) {
    return const [];
  }

  return [
    for (final item in value)
      if (item is Map) item.cast<String, dynamic>(),
  ];
}

Map<String, dynamic> _apiMap(Object? value) {
  if (value is Map) {
    return value.cast<String, dynamic>();
  }
  return const {};
}

String _apiText(Object? value, {String fallback = ''}) {
  if (value == null) {
    return fallback;
  }
  final text = '$value'.trim();
  return text.isEmpty ? fallback : text;
}

int _apiInt(Object? value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(_apiText(value)) ?? 0;
}

DateTime? _apiDate(Object? value) {
  if (value is DateTime) {
    return value;
  }
  final text = _apiText(value);
  return text.isEmpty ? null : DateTime.tryParse(text);
}

String _apiShortMonthYear(Object? value) {
  final date = _apiDate(value);
  if (date == null) {
    return '-';
  }
  return '${_shortMonth(date.month)} ${date.year}';
}

String _apiLongDate(Object? value) {
  final date = _apiDate(value);
  if (date == null) {
    return 'nao informado';
  }
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

Color _apiColor(String value, {required Color fallback}) {
  final normalized = value.replaceAll('#', '').trim();
  if (normalized.length != 6) {
    return fallback;
  }

  final parsed = int.tryParse(normalized, radix: 16);
  if (parsed == null) {
    return fallback;
  }

  return Color(0xFF000000 | parsed);
}

_SensitiveNoteClassification _sensitiveClassificationFromApi(String value) {
  switch (value.toUpperCase()) {
    case 'BEHAVIORAL_SIGNAL':
      return _SensitiveNoteClassification.behavioralSignal;
    case 'ROUTINE_CONTEXT':
      return _SensitiveNoteClassification.routineContext;
    case 'FAMILY_CONTEXT':
      return _SensitiveNoteClassification.familyContext;
    case 'TRAINING_OR_SKILL':
      return _SensitiveNoteClassification.trainingOrSkill;
    case 'PERSONAL_CONTEXT':
      return _SensitiveNoteClassification.personalContext;
    case 'OPERATIONAL_RISK':
      return _SensitiveNoteClassification.operationalRisk;
    default:
      return _SensitiveNoteClassification.routineContext;
  }
}

Color _sensitiveClassificationColor(
  _SensitiveNoteClassification classification,
) {
  return switch (classification) {
    _SensitiveNoteClassification.behavioralSignal => _amberColor,
    _SensitiveNoteClassification.routineContext => _slateColor,
    _SensitiveNoteClassification.familyContext => _roseColor,
    _SensitiveNoteClassification.trainingOrSkill => _tealColor,
    _SensitiveNoteClassification.personalContext => _slateColor,
    _SensitiveNoteClassification.operationalRisk => _roseColor,
  };
}

_AttachmentClassification _attachmentClassificationFromApi(String value) {
  switch (value.toUpperCase()) {
    case 'FORMAL_DOCUMENT':
      return _AttachmentClassification.formalDocument;
    case 'SENSITIVE_ATTACHMENT':
      return _AttachmentClassification.sensitiveAttachment;
    case 'SUPPORTING_REFERENCE':
      return _AttachmentClassification.supportingReference;
    default:
      return _AttachmentClassification.supportingReference;
  }
}

const _apiReturnedContentAccessPolicy = _ProtectedAccessPolicy(
  owner: _audienceDiego,
  allowedGroups: [
    _CollaboratorAudienceGroup.board,
    _CollaboratorAudienceGroup.supervision,
    _CollaboratorAudienceGroup.auxiliary,
  ],
  allowedPeople: [_audienceMarta, _audienceCamila, _audienceLucas],
);

String _peopleRuntimeErrorMessage(Object error) {
  if (error is _ApiException) {
    return 'API indisponivel para People (${error.code}). Mantive o mock local sem expor dados protegidos.';
  }
  return 'Nao foi possivel sincronizar People com a API. Mantive o mock local para evitar regressao visual.';
}
