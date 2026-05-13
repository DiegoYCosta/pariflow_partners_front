part of '../../../app/app.dart';

class _PeopleApiRepository {
  _PeopleApiRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<void> createPerson(Map<String, dynamic> body) async {
    await _apiClient.postMap('pessoas', body: body);
  }

  Future<void> updatePerson(String publicId, Map<String, dynamic> body) async {
    await _apiClient.patchMap('pessoas/$publicId', body: body);
  }

  Future<void> removePerson(String publicId) async {
    await _apiClient.deleteMap('pessoas/$publicId');
  }

  Future<void> createEmploymentLink(Map<String, dynamic> body) async {
    await _apiClient.postMap('vinculos', body: body);
  }

  Future<_EmploymentLinkLookupData> loadEmploymentLinkLookups() async {
    await _apiClient.ensureDevelopmentSession();
    final results = await Future.wait([
      _safeItems(
        'empresas-prestadoras',
        query: const {'page': '1', 'perPage': '100'},
      ),
      _safeItems('contratos', query: const {'page': '1', 'perPage': '100'}),
    ]);

    return _EmploymentLinkLookupData(
      providerCompanies: results[0]
          .map(_employmentProviderOptionFromApi)
          .toList(),
      contracts: results[1].map(_employmentContractOptionFromApi).toList(),
    );
  }

  Future<void> createOccurrence(Map<String, dynamic> body) async {
    await _apiClient.postMap('ocorrencias', body: body);
  }

  Future<void> updateOccurrence(
    String publicId,
    Map<String, dynamic> body,
  ) async {
    await _apiClient.patchMap('ocorrencias/$publicId', body: body);
  }

  Future<void> removeOccurrence(String publicId) async {
    await _apiClient.deleteMap('ocorrencias/$publicId');
  }

  Future<void> createAttachment(Map<String, dynamic> body) async {
    await _apiClient.postMap('anexos', body: body);
  }

  Future<void> updateAttachment(
    String publicId,
    Map<String, dynamic> body,
  ) async {
    await _apiClient.patchMap('anexos/$publicId', body: body);
  }

  Future<void> removeAttachment(String publicId) async {
    await _apiClient.deleteMap('anexos/$publicId');
  }

  Future<void> createCalendarEntry(Map<String, dynamic> body) async {
    await _apiClient.postMap('agenda', body: body);
  }

  Future<void> cancelCalendarEntry(String publicId) async {
    await _apiClient.deleteMap('agenda/$publicId');
  }

  Future<_PeopleRuntimeData> loadWorkspaceData() async {
    final session = await _apiClient.ensureDevelopmentSession();
    final peopleEnvelope = await _apiClient.getMap(
      'pessoas',
      query: const {'page': '1', 'perPage': '24'},
    );
    final people = _apiMapList(peopleEnvelope['items']);

    if (people.isEmpty) {
      return _PeopleRuntimeData.empty(
        session,
        message:
            'API conectada, mas ainda nao ha pessoas no recorte. Nenhum dado mock foi carregado.',
      );
    }

    final visualIdentities = await VisualIdentityLocalStore.instance
        .loadForType(entityType: VisualEntityType.user);
    final bundles = await Future.wait(people.map(_loadPersonBundle));
    final items = bundles
        .map(
          (bundle) => _entityItemFromApi(
            bundle,
            visualIdentityOverride:
                visualIdentities[_apiText(bundle.detail['publicId'])],
          ),
        )
        .toList(growable: false);

    return _PeopleRuntimeData.live(
      _EntityWorkspaceData(
        title: 'Funcionarios com dados reais',
        subtitle:
            'Consulta de pessoas vinda da API, preservando registro-base, vinculos, ocorrencias, tags sensiveis e anexos autorizados pelo backend.',
        searchHint: 'GET /api/v1/pessoas',
        listHint:
            'A lista usa publicId e envelope padrao da API para abrir a ficha operacional.',
        productionHint:
            'Corte vertical ativo: pessoas, vinculos, ocorrencias, tags e anexos lidos do backend sem fallback de dados locais.',
        integrationFocus: [
          'API real',
          'publicId',
          'ACL no backend',
          'sem mock',
        ],
        filters: [
          'pessoas',
          'vinculos',
          'ocorrencias',
          'tags-entidade',
          'anexos',
        ],
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
    final occurrencesFuture = _safeItems(
      'ocorrencias',
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
    final calendarEntriesFuture = _safeItems(
      'agenda',
      query: {'personPublicId': publicId},
    );

    return _PeopleApiBundle(
      detail: await detailFuture,
      links: await linksFuture,
      occurrences: await occurrencesFuture,
      tags: await tagsFuture,
      attachments: await attachmentsFuture,
      calendarEntries: await calendarEntriesFuture,
    );
  }

  Future<List<Map<String, dynamic>>> _safeItems(
    String path, {
    Map<String, String?> query = const {},
  }) async {
    try {
      final data = await _apiClient.getMap(path, query: query);
      return _apiMapList(data['items']);
    } on ApiException {
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

  factory _PeopleRuntimeData.initial() {
    return _PeopleRuntimeData(
      data: _entityWorkspaceWithoutItems(
        _peopleWorkspaceMeta,
        productionHint: 'Aguardando resposta da API real de People.',
        integrationFocus: const ['API real', 'sem mock'],
      ),
      sourceLabel: 'aguardando API',
      isLive: false,
      isLoading: false,
    );
  }

  factory _PeopleRuntimeData.empty(
    SessionSnapshot session, {
    required String message,
  }) {
    return _PeopleRuntimeData(
      data: _entityWorkspaceWithoutItems(
        _peopleWorkspaceMeta,
        productionHint:
            'A API de People respondeu sem registros para este recorte. A tela nao carrega dados mock em execucao real.',
        integrationFocus: const ['API real', 'sem registros', 'sem mock'],
      ),
      sourceLabel: 'API real | ${_peopleSessionLabel(session)}',
      isLive: true,
      isLoading: false,
      session: session,
      errorMessage: message,
    );
  }

  factory _PeopleRuntimeData.unavailable({required String message}) {
    return _PeopleRuntimeData(
      data: _entityWorkspaceWithoutItems(
        _peopleWorkspaceMeta,
        productionHint:
            'A API de People nao respondeu. A tela foi mantida sem dados locais para evitar confusao com a base real.',
        integrationFocus: const ['API indisponivel', 'sem mock'],
      ),
      sourceLabel: 'API indisponivel',
      isLive: false,
      isLoading: false,
      errorMessage: message,
    );
  }

  factory _PeopleRuntimeData.live(
    _EntityWorkspaceData data,
    SessionSnapshot session,
  ) {
    return _PeopleRuntimeData(
      data: data,
      sourceLabel: 'API real | ${_peopleSessionLabel(session)}',
      isLive: true,
      isLoading: false,
      session: session,
    );
  }

  final _EntityWorkspaceData data;
  final String sourceLabel;
  final bool isLive;
  final bool isLoading;
  final SessionSnapshot? session;
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
    required this.occurrences,
    required this.tags,
    required this.attachments,
    required this.calendarEntries,
  });

  final Map<String, dynamic> detail;
  final List<Map<String, dynamic>> links;
  final List<Map<String, dynamic>> occurrences;
  final List<Map<String, dynamic>> tags;
  final List<Map<String, dynamic>> attachments;
  final List<Map<String, dynamic>> calendarEntries;
}

class _EmploymentLinkLookupData {
  const _EmploymentLinkLookupData({
    required this.providerCompanies,
    required this.contracts,
  });

  final List<_EntitySelectOption> providerCompanies;
  final List<_EmploymentContractOption> contracts;
}

class _EmploymentContractOption {
  const _EmploymentContractOption({
    required this.publicId,
    required this.label,
    required this.description,
    required this.providerCompanyPublicId,
    required this.providerLabel,
    required this.clientLabel,
    required this.status,
    required this.positions,
  });

  final String publicId;
  final String label;
  final String description;
  final String providerCompanyPublicId;
  final String providerLabel;
  final String clientLabel;
  final String status;
  final List<_EmploymentPositionOption> positions;
}

class _EmploymentPositionOption {
  const _EmploymentPositionOption({
    required this.publicId,
    required this.label,
  });

  final String publicId;
  final String label;
}

_EntitySelectOption _employmentProviderOptionFromApi(
  Map<String, dynamic> company,
) {
  return _providerOptionFromApi(company);
}

_EmploymentContractOption _employmentContractOptionFromApi(
  Map<String, dynamic> contract,
) {
  final publicId = _apiText(contract['publicId']);
  final provider = _apiMap(contract['providerCompany']);
  final client = _apiMap(contract['clientCompany']);
  final contractType = _apiMap(contract['contractType']);
  final contractModel = _apiMap(contract['contractModel']);
  final providerLabel = _apiText(
    provider['tradeName'],
    fallback: _apiText(
      provider['legalName'],
      fallback: 'Prestadora nao informada',
    ),
  );
  final clientLabel = _apiText(
    client['name'],
    fallback: 'Cliente nao informado',
  );
  final modelLabel = _apiText(contractModel['name']);
  final typeLabel = _apiText(
    contractType['name'],
    fallback: 'tipo nao definido',
  );
  final status = _apiText(contract['status'], fallback: 'ACTIVE');
  final startsAt = _apiLongDate(contract['startsAt']);
  final positions = _apiMapList(contract['positions'])
      .map(_employmentPositionOptionFromApi)
      .where((position) => position.publicId.isNotEmpty)
      .toList(growable: false);

  return _EmploymentContractOption(
    publicId: publicId,
    label: modelLabel.isEmpty ? 'Contrato $publicId' : modelLabel,
    description:
        '$clientLabel | $typeLabel | ${_entityStatusLabel(status)} | inicio $startsAt',
    providerCompanyPublicId: _apiText(provider['publicId']),
    providerLabel: providerLabel,
    clientLabel: clientLabel,
    status: status,
    positions: positions,
  );
}

_EmploymentPositionOption _employmentPositionOptionFromApi(
  Map<String, dynamic> position,
) {
  final service = _apiMap(position['service']);
  final parts = [
    _apiText(position['name'], fallback: 'Posto sem nome'),
    _apiText(service['name']),
    _apiText(position['location']),
    _apiText(position['schedule'], fallback: _apiText(position['shift'])),
  ]..removeWhere((part) => part.isEmpty);

  return _EmploymentPositionOption(
    publicId: _apiText(position['publicId']),
    label: parts.join(' | '),
  );
}

_EntityItem _entityItemFromApi(
  _PeopleApiBundle bundle, {
  EntityVisualIdentity? visualIdentityOverride,
}) {
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
  final occurrences = bundle.occurrences
      .map(_occurrenceFromApi)
      .toList(growable: false);
  final occurrenceCount = occurrences.length;
  final attachments = bundle.attachments
      .where((attachment) => attachment['canView'] != false)
      .map(_attachmentFromApi)
      .toList(growable: false);
  final calendarEntries = bundle.calendarEntries
      .map(_calendarEntryFromApi)
      .toList(growable: false);

  return _EntityItem(
    publicId: publicId,
    title: name,
    subtitle: '$roleTitle | $clientCompany',
    meta:
        '$statusLabel | $linkCount vinculos | $occurrenceCount ocorrencias | $providerCompany',
    status: statusLabel,
    icon: icon,
    color: color,
    detailSummary:
        'Registro carregado do backend com pessoa, vinculos, ocorrencias, tags sensiveis e anexos autorizados por ACL.',
    relations: [
      'CPF: ${_apiText(person['cpf'], fallback: 'nao informado')}',
      'Email: ${_apiText(person['email'], fallback: 'nao informado')}',
      'Telefone: ${_apiText(person['phone'], fallback: 'nao informado')}',
      'Prestadora atual: $providerCompany',
      'Cliente conectado: $clientCompany',
      'Vinculos carregados: $linkCount',
      'Ocorrencias carregadas: $occurrenceCount',
      'Tags visiveis: ${tags.length}',
      'Anexos visiveis: ${attachments.length}',
      'Agenda: ${calendarEntries.length} itens',
    ],
    attachments: attachments,
    sensitiveNotes: tags,
    personProfile: _personProfileFromApi(
      person,
      links,
      occurrences,
      calendarEntries,
    ),
    visualIdentity:
        visualIdentityOverride ??
        VisualIdentityGenerator.forEntity(
          entityType: VisualEntityType.user,
          entityId: publicId,
          displayName: name,
        ),
  );
}

_PersonProfileData _personProfileFromApi(
  Map<String, dynamic> person,
  List<Map<String, dynamic>> links,
  List<_OccurrenceRecord> occurrences,
  List<_CalendarEntryRecord> calendarEntries,
) {
  final currentLink = _currentApiLink(links);
  final address = _apiMap(person['addressJson']);
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
        label: 'Endereco',
        value: _addressLabel(address, fallback: location),
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
        '${links.length} vinculos e ${occurrences.length} ocorrencias carregados diretamente da API.',
    employmentLinks: links.map(_employmentLinkFromApi).toList(growable: false),
    crudSnapshot: _PersonCrudSnapshot(
      publicId: _apiText(person['publicId']),
      name: _apiText(person['name']),
      cpf: _apiText(person['cpf']),
      rg: _apiText(person['rg']),
      email: _apiText(person['email']),
      phone: _apiText(person['phone']),
      birthDateInput: _apiDateInput(person['birthDate']),
      zipCode: _apiText(address['zipCode']),
      street: _apiText(address['street']),
      number: _apiText(address['number']),
      district: _apiText(address['district']),
      city: _apiText(address['city']),
      state: _apiText(address['state']),
      notes: _apiText(person['notes']),
    ),
    occurrences: occurrences,
    calendarEntries: calendarEntries,
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
  final contract = _apiMap(link['contract']);
  final contractModel = _apiMap(contract['contractModel']);
  final contractPublicId = _apiText(contract['publicId']);
  final contractLabel = _apiText(
    contractModel['name'],
    fallback: contractPublicId.isEmpty
        ? 'Contrato nao informado'
        : contractPublicId,
  );
  final contractStatus = _apiText(contract['status'], fallback: 'ACTIVE');
  final contractEndsAt = _apiDate(contract['endsAt']);
  final linkStatusLabel = _employmentLinkStatusLabel(
    status: status,
    endsAt: effectiveEnd,
    contractEndsAt: contractEndsAt,
  );

  return _EmploymentLinkRecord(
    periodLabel:
        '${_apiShortMonthYear(startsAt)}\n- ${isCurrent ? 'Present' : _apiShortMonthYear(effectiveEnd)}',
    companyName: providerCompany,
    roleTitle: roleTitle,
    contractLabel: contractLabel,
    contractPublicId: contractPublicId,
    contractStatusLabel: _entityStatusLabel(contractStatus),
    linkStatusLabel: linkStatusLabel,
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

String _employmentLinkStatusLabel({
  required String status,
  required DateTime? endsAt,
  required DateTime? contractEndsAt,
}) {
  final now = DateTime.now();
  if (status == 'DISMISSED') {
    return 'encerrado';
  }
  if ((endsAt != null && endsAt.isBefore(now)) ||
      (contractEndsAt != null && contractEndsAt.isBefore(now))) {
    return 'vencido';
  }
  if (status == 'ACTIVE') {
    return 'ativo';
  }
  return status.toLowerCase();
}

_OccurrenceRecord _occurrenceFromApi(Map<String, dynamic> occurrence) {
  return _OccurrenceRecord(
    publicId: _apiText(occurrence['publicId']),
    type: _apiText(occurrence['type'], fallback: 'REGISTRO'),
    scope: _apiText(occurrence['scope'], fallback: 'people-dossie'),
    nature: _apiText(occurrence['nature'], fallback: 'NEUTRAL'),
    title: _apiText(occurrence['title'], fallback: 'Ocorrencia sem titulo'),
    description: _apiText(occurrence['description']),
    occurredAtInput: _apiDateInput(occurrence['occurredAt']),
    occurredAtLabel: _apiLongDate(occurrence['occurredAt']),
    severityLevel: _apiText(occurrence['severityLevel'], fallback: 'LOW'),
    visibility: _apiText(occurrence['visibility'], fallback: 'INTERNAL'),
    status: _apiText(occurrence['status'], fallback: 'ACTIVE'),
    attachmentCount: _apiInt(occurrence['attachmentCount']),
    showInExecutivePanel: occurrence['showInExecutivePanel'] == true,
  );
}

_CalendarEntryRecord _calendarEntryFromApi(Map<String, dynamic> entry) {
  final notification = _apiMap(entry['notification']);
  return _CalendarEntryRecord(
    publicId: _apiText(entry['publicId']),
    kind: _apiText(entry['kind'], fallback: 'REMINDER'),
    kindLabel: _apiText(entry['kindLabel'], fallback: 'Lembrete'),
    status: _apiText(entry['status'], fallback: 'SCHEDULED'),
    statusLabel: _apiText(entry['statusLabel'], fallback: 'Agendado'),
    priority: _apiText(entry['priority'], fallback: 'NORMAL'),
    priorityLabel: _apiText(entry['priorityLabel'], fallback: 'Normal'),
    title: _apiText(entry['title'], fallback: 'Lembrete sem titulo'),
    description: _apiText(entry['description']),
    startsAt:
        _apiDate(entry['startsAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    startsAtLabel: _apiText(entry['startsAtLabel']),
    notificationPolicy: _apiText(notification['policy']),
    notificationPolicyLabel: _apiText(
      notification['policyLabel'],
      fallback: 'No dia',
    ),
    notificationScheduledAt: _apiDate(notification['scheduledAt']),
    notificationScheduledAtLabel: _apiText(
      notification['scheduledAtLabel'],
      fallback: 'nao agendada',
    ),
    notificationChannelsLabel: _apiText(
      notification['channelsLabel'],
      fallback: 'No app',
    ),
    canEdit: entry['canEdit'] == true,
    canCancel: entry['canCancel'] == true,
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
    accessPolicy: _protectedAccessPolicyFromApi(tag),
  );
}

_AttachmentRecord _attachmentFromApi(Map<String, dynamic> attachment) {
  final classification = _attachmentClassificationFromApi(
    _apiText(attachment['classification']),
  );
  final updatedAt = attachment['updatedAt'] ?? attachment['createdAt'];

  return _AttachmentRecord(
    publicId: _apiText(attachment['publicId']),
    occurrencePublicId: _apiText(attachment['occurrencePublicId']),
    title: _apiText(attachment['fileName'], fallback: 'Anexo protegido'),
    classification: classification,
    summary: _attachmentSummaryFromApi(attachment),
    status: _apiText(attachment['status'], fallback: 'ACTIVE').toLowerCase(),
    updatedAtLabel: 'atualizado em ${_apiLongDate(updatedAt)}',
    accessPolicy: _protectedAccessPolicyFromApi(attachment),
    displayScope: _apiText(attachment['displayScope']),
    mimeType: _apiText(attachment['mimeType']),
    externalLink: _apiText(attachment['externalLink']),
    physicalLocation: _apiText(attachment['physicalLocation']),
    canDownload: attachment['canDownload'] != false,
    canEdit: attachment['canEdit'] == true || attachment['canManage'] == true,
    canDelete:
        attachment['canDelete'] == true || attachment['canManage'] == true,
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

String _addressLabel(Map<String, dynamic> address, {required String fallback}) {
  final street = _apiText(address['street']);
  final number = _apiText(address['number']);
  final district = _apiText(address['district']);
  final city = _apiText(address['city']);
  final state = _apiText(address['state']).toUpperCase();
  final line = [
    [street, number].where((value) => value.isNotEmpty).join(', '),
    district,
    [city, state].where((value) => value.isNotEmpty).join('/'),
  ].where((value) => value.isNotEmpty).join(' | ');

  return line.isEmpty ? fallback : line;
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

String _shortMonth(int month) {
  const labels = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  if (month < 1 || month > labels.length) {
    return '-';
  }
  return labels[month - 1];
}

String _companyMonogram(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);

  if (parts.isEmpty) {
    return 'PF';
  }
  if (parts.length == 1) {
    return parts.first.substring(0, min(2, parts.first.length)).toUpperCase();
  }
  return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
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

String _apiDateInput(Object? value) {
  final date = _apiDate(value);
  if (date == null) {
    return '';
  }
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
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

_ProtectedAccessPolicy _protectedAccessPolicyFromApi(
  Map<String, dynamic> item,
) {
  final createdBy = _apiMap(item['createdBy']);
  final ownerPublicId = _apiText(
    item['ownerUserPublicId'],
    fallback: _apiText(createdBy['publicId']),
  );
  final ownerName = _apiText(
    createdBy['name'],
    fallback: ownerPublicId.isEmpty
        ? 'Autoria registrada pela API'
        : 'Usuario ${_shortPublicId(ownerPublicId)}',
  );
  final allowedGroups = <_CollaboratorAudienceGroup>[];
  for (final key in _apiTextList(item['allowedGroupKeys'])) {
    final group = _audienceGroupFromKey(key);
    if (group != null) {
      allowedGroups.add(group);
    }
  }

  final allowedPeople = <_AudiencePerson>[];
  for (final publicId in _apiTextList(item['allowedUserPublicIds'])) {
    if (publicId.isEmpty || publicId == ownerPublicId) {
      continue;
    }
    allowedPeople.add(
      _AudiencePerson(
        publicId: publicId,
        name: 'Usuario ${_shortPublicId(publicId)}',
      ),
    );
  }

  return _ProtectedAccessPolicy(
    owner: _AudiencePerson(publicId: ownerPublicId, name: ownerName),
    allowedGroups: allowedGroups,
    allowedPeople: allowedPeople,
    canViewOverride: item.containsKey('canView')
        ? item['canView'] == true
        : null,
    canManageOverride: item.containsKey('canManage')
        ? item['canManage'] == true
        : null,
  );
}

List<String> _apiTextList(Object? value) {
  if (value is! List) {
    return const [];
  }
  return [
    for (final item in value)
      if (_apiText(item).isNotEmpty) _apiText(item),
  ];
}

String _shortPublicId(String publicId) {
  if (publicId.length <= 10) {
    return publicId;
  }
  return '${publicId.substring(0, 7)}...${publicId.substring(publicId.length - 4)}';
}

String _peopleRuntimeErrorMessage(Object error) {
  if (error is ApiException) {
    return 'API indisponivel para People (${error.code}). Nenhum dado mock foi carregado.';
  }
  return 'Nao foi possivel sincronizar People com a API. Nenhum dado mock foi carregado.';
}

String _peopleSessionLabel(SessionSnapshot session) {
  return session.profiles.isEmpty
      ? session.securityContext
      : session.profiles.join('/');
}
