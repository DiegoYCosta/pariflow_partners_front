part of '../../app/app.dart';

class _EntityWorkspaceApiRepository {
  _EntityWorkspaceApiRepository({_ApiClient? apiClient})
    : _apiClient = apiClient ?? _ApiClient();

  final _ApiClient _apiClient;

  Future<_EntityWorkspaceRuntimeData> loadProviderCompanies({
    String search = '',
  }) async {
    final session = await _apiClient.ensureDevelopmentSession();
    final envelope = await _apiClient.getMap(
      'empresas-prestadoras',
      query: _entityListQuery(search),
    );
    final companies = _apiMapList(envelope['items']);

    if (companies.isEmpty) {
      return _EntityWorkspaceRuntimeData.mock(
        _companiesWorkspaceData,
        errorMessage:
            'API conectada, mas ainda nao ha empresas prestadoras no recorte. Mantive o layout com dados locais.',
      );
    }

    final contracts = await _safeItems(
      'contratos',
      query: const {'page': '1', 'perPage': '100'},
    );
    final items = companies
        .map((company) => _providerCompanyItemFromApi(company, contracts))
        .toList(growable: false);

    return _EntityWorkspaceRuntimeData.live(
      _EntityWorkspaceData(
        title: _companiesWorkspaceData.title,
        subtitle:
            'Prestadoras carregadas da API, mantendo a leitura de contratos, vinculos, ocorrencias e contexto operacional no workspace atual.',
        searchHint: 'buscar por razao social, fantasia ou documento',
        listHint:
            'A lista usa publicId, contadores do backend e contratos disponiveis para montar o detalhe sem sair da pagina.',
        productionHint:
            'Integracao ativa: GET /api/v1/empresas-prestadoras com apoio de GET /api/v1/contratos para relacoes de carteira.',
        integrationFocus: [
          'API real',
          'publicId',
          'contratos conectados',
          'fallback local',
        ],
        filters: _companiesWorkspaceData.filters,
        items: items,
        accent: _companiesWorkspaceData.accent,
      ),
      session,
      '/empresas-prestadoras',
    );
  }

  Future<_EntityWorkspaceRuntimeData> loadClientCompanies({
    String search = '',
  }) async {
    final session = await _apiClient.ensureDevelopmentSession();
    final envelope = await _apiClient.getMap(
      'clientes',
      query: _entityListQuery(search),
    );
    final clients = _apiMapList(envelope['items']);

    if (clients.isEmpty) {
      return _EntityWorkspaceRuntimeData.mock(
        _clientCompaniesWorkspaceData,
        errorMessage:
            'API conectada, mas ainda nao ha clientes no recorte. Mantive o layout com dados locais.',
      );
    }

    final contracts = await _safeItems(
      'contratos',
      query: const {'page': '1', 'perPage': '100'},
    );
    final items = clients
        .map((client) => _clientCompanyItemFromApi(client, contracts))
        .toList(growable: false);

    return _EntityWorkspaceRuntimeData.live(
      _EntityWorkspaceData(
        title: _clientCompaniesWorkspaceData.title,
        subtitle:
            'Carteira de clientes carregada da API, preservando a separacao entre cliente, prestadora e contrato.',
        searchHint: 'buscar por nome da carteira, documento ou unidade',
        listHint:
            'Enquanto o backend de clientes nao agrega relacoes no detalhe, a pagina cruza contratos carregados da API.',
        productionHint:
            'Integracao ativa: GET /api/v1/clientes com apoio de GET /api/v1/contratos ate o detalhe relacional ficar nativo no backend.',
        integrationFocus: [
          'API real',
          'clientes',
          'contratos relevantes',
          'fallback local',
        ],
        filters: _clientCompaniesWorkspaceData.filters,
        items: items,
        accent: _clientCompaniesWorkspaceData.accent,
      ),
      session,
      '/clientes',
    );
  }

  Future<_EntityWorkspaceRuntimeData> loadContracts({
    String search = '',
  }) async {
    final session = await _apiClient.ensureDevelopmentSession();
    final envelope = await _apiClient.getMap(
      'contratos',
      query: _entityListQuery(search),
    );
    final contracts = _apiMapList(envelope['items']);

    if (contracts.isEmpty) {
      return _EntityWorkspaceRuntimeData.mock(
        _contractsWorkspaceData,
        errorMessage:
            'API conectada, mas ainda nao ha contratos no recorte. Mantive o layout com dados locais.',
      );
    }

    final items = contracts.map(_contractItemFromApi).toList(growable: false);

    return _EntityWorkspaceRuntimeData.live(
      _EntityWorkspaceData(
        title: _contractsWorkspaceData.title,
        subtitle:
            'Contratos carregados da API com prestadora e cliente agregados no mesmo payload.',
        searchHint: 'buscar por cliente, prestadora ou publicId',
        listHint:
            'A lista usa o contrato real e exibe vigencia, partes relacionadas e status de dominio.',
        productionHint:
            'Integracao ativa: GET /api/v1/contratos ja entrega cliente e prestadora para o detalhe contextual.',
        integrationFocus: ['API real', 'vigencia', 'cliente', 'prestadora'],
        filters: _contractsWorkspaceData.filters,
        items: items,
        accent: _contractsWorkspaceData.accent,
      ),
      session,
      '/contratos',
    );
  }

  Future<void> createProviderCompany(Map<String, dynamic> body) async {
    await _apiClient.postMap('empresas-prestadoras', body: body);
  }

  Future<void> createClientCompany(Map<String, dynamic> body) async {
    await _apiClient.postMap('clientes', body: body);
  }

  Future<void> createContract(Map<String, dynamic> body) async {
    await _apiClient.postMap('contratos', body: body);
  }

  Future<List<_EntitySelectOption>> loadContractTypes() async {
    await _apiClient.ensureDevelopmentSession();
    final data = await _apiClient.getMap('contratos/tipos');
    return _apiMapList(data['items']).map(_contractTypeOptionFromApi).toList();
  }

  Future<List<_EntitySelectOption>> loadContractModels() async {
    await _apiClient.ensureDevelopmentSession();
    final data = await _apiClient.getMap('contratos/modelos');
    return _apiMapList(data['items']).map(_contractModelOptionFromApi).toList();
  }

  Future<void> createContractType(Map<String, dynamic> body) async {
    await _apiClient.postMap('contratos/tipos', body: body);
  }

  Future<void> updateContractType(
    String publicId,
    Map<String, dynamic> body,
  ) async {
    await _apiClient.patchMap('contratos/tipos/$publicId', body: body);
  }

  Future<void> removeContractType(String publicId) async {
    await _apiClient.deleteMap('contratos/tipos/$publicId');
  }

  Future<void> createContractModel(Map<String, dynamic> body) async {
    await _apiClient.postMap('contratos/modelos', body: body);
  }

  Future<void> updateContractModel(
    String publicId,
    Map<String, dynamic> body,
  ) async {
    await _apiClient.patchMap('contratos/modelos/$publicId', body: body);
  }

  Future<void> removeContractModel(String publicId) async {
    await _apiClient.deleteMap('contratos/modelos/$publicId');
  }

  Future<void> createContractDocument(
    String contractPublicId,
    Map<String, dynamic> body,
  ) async {
    await _apiClient.postMap(
      'contratos/$contractPublicId/documentos',
      body: body,
    );
  }

  Future<void> updateContractDocument(
    String documentPublicId,
    Map<String, dynamic> body,
  ) async {
    await _apiClient.patchMap(
      'contratos/documentos/$documentPublicId',
      body: body,
    );
  }

  Future<void> removeContractDocument(String documentPublicId) async {
    await _apiClient.deleteMap('contratos/documentos/$documentPublicId');
  }

  Future<_ContractLookupData> loadContractLookups() async {
    await _apiClient.ensureDevelopmentSession();
    final results = await Future.wait([
      _safeItems(
        'empresas-prestadoras',
        query: const {'page': '1', 'perPage': '100'},
      ),
      _safeItems('clientes', query: const {'page': '1', 'perPage': '100'}),
      _safeItems('contratos/tipos'),
      _safeItems('contratos/modelos'),
    ]);

    return _ContractLookupData(
      providerCompanies: results[0].map(_providerOptionFromApi).toList(),
      clientCompanies: results[1].map(_clientOptionFromApi).toList(),
      contractTypes: results[2].map(_contractTypeOptionFromApi).toList(),
      contractModels: results[3].map(_contractModelOptionFromApi).toList(),
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

class _EntityWorkspaceRuntimeData {
  const _EntityWorkspaceRuntimeData({
    required this.data,
    required this.sourceLabel,
    required this.isLive,
    required this.isLoading,
    this.session,
    this.errorMessage,
  });

  factory _EntityWorkspaceRuntimeData.mock(
    _EntityWorkspaceData data, {
    String? errorMessage,
  }) {
    return _EntityWorkspaceRuntimeData(
      data: data,
      sourceLabel: errorMessage == null ? 'preview local' : 'fallback local',
      isLive: false,
      isLoading: false,
      errorMessage: errorMessage,
    );
  }

  factory _EntityWorkspaceRuntimeData.live(
    _EntityWorkspaceData data,
    _SessionSnapshot session,
    String endpointLabel,
  ) {
    return _EntityWorkspaceRuntimeData(
      data: data,
      sourceLabel: 'API real | $endpointLabel',
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

  _EntityWorkspaceRuntimeData copyWith({bool? isLoading}) {
    final loading = isLoading ?? this.isLoading;
    return _EntityWorkspaceRuntimeData(
      data: data,
      sourceLabel: loading ? 'sincronizando API' : sourceLabel,
      isLive: isLive,
      isLoading: loading,
      session: session,
      errorMessage: loading ? null : errorMessage,
    );
  }
}

class _ContractLookupData {
  const _ContractLookupData({
    required this.providerCompanies,
    required this.clientCompanies,
    required this.contractTypes,
    required this.contractModels,
  });

  final List<_EntitySelectOption> providerCompanies;
  final List<_EntitySelectOption> clientCompanies;
  final List<_EntitySelectOption> contractTypes;
  final List<_EntitySelectOption> contractModels;
}

class _EntitySelectOption {
  const _EntitySelectOption({
    required this.publicId,
    required this.label,
    this.description = '',
    this.status = '',
    this.parentPublicId = '',
  });

  final String publicId;
  final String label;
  final String description;
  final String status;
  final String parentPublicId;
}

Map<String, String?> _entityListQuery(String search) {
  final trimmed = search.trim();
  return {
    'page': '1',
    'perPage': '24',
    'search': trimmed.isEmpty ? null : trimmed,
  };
}

_EntityItem _providerCompanyItemFromApi(
  Map<String, dynamic> company,
  List<Map<String, dynamic>> contracts,
) {
  final publicId = _apiText(company['publicId']);
  final legalName = _apiText(
    company['legalName'],
    fallback: 'Prestadora sem razao social',
  );
  final tradeName = _apiText(company['tradeName']);
  final title = tradeName.isNotEmpty ? tradeName : legalName;
  final status = _apiText(company['status'], fallback: 'ACTIVE');
  final color = _entityStatusColor(status);
  final notes = _apiText(company['notes']);
  final relatedContracts = contracts
      .where(
        (contract) =>
            _apiText(_apiMap(contract['providerCompany'])['publicId']) ==
            publicId,
      )
      .toList();
  final clientNames = relatedContracts
      .map((contract) => _apiText(_apiMap(contract['clientCompany'])['name']))
      .where((name) => name.isNotEmpty)
      .toSet()
      .toList();
  final contractCount = max(
    _apiInt(company['contractCount']),
    relatedContracts.length,
  );
  final linkCount = _apiInt(company['linkCount']);
  final occurrenceCount = _apiInt(company['occurrenceCount']);
  final contacts = _apiMap(company['contactsJson']);

  return _EntityItem(
    publicId: publicId,
    title: title,
    subtitle: notes.isNotEmpty
        ? notes
        : 'Prestadora com ${_pluralCount(contractCount, 'contrato', 'contratos')} no recorte atual.',
    meta:
        '${_entityStatusLabel(status)} | ${_documentLabel(company['document'])} | ${_pluralCount(linkCount, 'vinculo', 'vinculos')}',
    status: _entityStatusLabel(status),
    icon: Icons.apartment_outlined,
    color: color,
    detailSummary:
        'Detalhe carregado do backend para sustentar consulta de prestadora, contratos conectados e filas operacionais sem sair do workspace.',
    relations: [
      'Razao social: $legalName',
      if (tradeName.isNotEmpty) 'Nome fantasia: $tradeName',
      'Documento: ${_documentLabel(company['document'])}',
      'Status de dominio: $status',
      'Contratos conectados: ${_pluralCount(contractCount, 'contrato', 'contratos')}',
      'Vinculos carregados: ${_pluralCount(linkCount, 'vinculo', 'vinculos')}',
      'Ocorrencias relacionadas: ${_pluralCount(occurrenceCount, 'ocorrencia', 'ocorrencias')}',
      if (clientNames.isNotEmpty)
        'Clientes conectados: ${clientNames.take(4).join(', ')}',
      if (contacts.isNotEmpty) 'Contatos: ${_entityJsonSummary(contacts)}',
      'Atualizado em: ${_apiLongDate(company['updatedAt'])}',
    ],
  );
}

_EntityItem _clientCompanyItemFromApi(
  Map<String, dynamic> client,
  List<Map<String, dynamic>> contracts,
) {
  final publicId = _apiText(client['publicId']);
  final name = _apiText(client['name'], fallback: 'Cliente sem nome');
  final clientType = _apiText(client['clientType'], fallback: 'CLIENTE');
  final status = _apiText(client['status'], fallback: 'ACTIVE');
  final color = _entityStatusColor(status);
  final contactName = _apiText(client['contactName']);
  final address = _apiMap(client['addressJson']);
  final relatedContracts = contracts
      .where(
        (contract) =>
            _apiText(_apiMap(contract['clientCompany'])['publicId']) ==
            publicId,
      )
      .toList();
  final providerNames = relatedContracts
      .map((contract) {
        final provider = _apiMap(contract['providerCompany']);
        return _apiText(
          provider['tradeName'],
          fallback: _apiText(provider['legalName']),
        );
      })
      .where((name) => name.isNotEmpty)
      .toSet()
      .toList();

  return _EntityItem(
    publicId: publicId,
    title: name,
    subtitle: contactName.isEmpty
        ? 'Carteira $clientType carregada da API.'
        : 'Contato principal: $contactName.',
    meta:
        '${_entityStatusLabel(status)} | ${_documentLabel(client['document'])} | ${_pluralCount(relatedContracts.length, 'contrato', 'contratos')}',
    status: _entityStatusLabel(status),
    icon: Icons.business_outlined,
    color: color,
    detailSummary:
        'Detalhe carregado da API de clientes, enriquecido no front com contratos ja disponiveis enquanto o backend nao entrega relacoes agregadas nativas.',
    relations: [
      'Tipo de cliente: $clientType',
      'Documento: ${_documentLabel(client['document'])}',
      'Status de dominio: $status',
      if (contactName.isNotEmpty) 'Contato principal: $contactName',
      if (address.isNotEmpty) 'Endereco: ${_entityJsonSummary(address)}',
      'Contratos no recorte: ${_pluralCount(relatedContracts.length, 'contrato', 'contratos')}',
      if (providerNames.isNotEmpty)
        'Prestadoras conectadas: ${providerNames.take(4).join(', ')}',
      'Atualizado em: ${_apiLongDate(client['updatedAt'])}',
      'Proximo backend: detalhe de cliente com prestadoras ativas, historicas e pessoas impactadas.',
    ],
  );
}

_EntityItem _contractItemFromApi(Map<String, dynamic> contract) {
  final publicId = _apiText(contract['publicId']);
  final provider = _apiMap(contract['providerCompany']);
  final client = _apiMap(contract['clientCompany']);
  final providerName = _apiText(
    provider['tradeName'],
    fallback: _apiText(
      provider['legalName'],
      fallback: 'Prestadora nao informada',
    ),
  );
  final clientName = _apiText(
    client['name'],
    fallback: 'Cliente nao informado',
  );
  final status = _apiText(contract['status'], fallback: 'ACTIVE');
  final color = _entityStatusColor(status);
  final startsAt = _apiLongDate(contract['startsAt']);
  final endsAt = _apiLongDate(contract['endsAt']);
  final notes = _apiText(contract['notes']);
  final contractType = _apiMap(contract['contractType']);
  final contractModel = _apiMap(contract['contractModel']);
  final typeName = _apiText(
    contractType['name'],
    fallback: 'tipo nao definido',
  );
  final modelName = _apiText(contractModel['name']);
  final documents = _apiMapList(
    contract['documents'],
  ).map(_contractDocumentFromApi).toList(growable: false);

  return _EntityItem(
    publicId: publicId,
    title: modelName.isEmpty ? 'Contrato $publicId' : modelName,
    subtitle: notes.isEmpty ? '$providerName atende $clientName.' : notes,
    meta:
        '${_entityStatusLabel(status)} | $typeName | inicio $startsAt | ${_pluralCount(documents.length, 'documento', 'documentos')}',
    status: _entityStatusLabel(status),
    icon: Icons.description_outlined,
    color: color,
    detailSummary:
        'Contrato carregado da API com cliente, prestadora, tipo, modelo reutilizavel e documentos proprios. Usar o mesmo modelo em empresas diferentes nao cria relacao entre elas.',
    relations: [
      'Tipo de contrato: $typeName',
      if (modelName.isNotEmpty) 'Modelo reutilizavel: $modelName',
      if (_apiText(contractModel['defaultSchedule']).isNotEmpty)
        'Escala padrao do modelo: ${_apiText(contractModel['defaultSchedule'])}',
      'Prestadora: $providerName',
      'Prestadora publicId: ${_apiText(provider['publicId'], fallback: 'nao informado')}',
      'Cliente: $clientName',
      'Cliente publicId: ${_apiText(client['publicId'], fallback: 'nao informado')}',
      'Tipo de cliente: ${_apiText(client['clientType'], fallback: 'nao informado')}',
      'Inicio: $startsAt',
      'Fim: $endsAt',
      'Status de dominio: $status',
      if (notes.isNotEmpty) 'Notas: $notes',
      'Atualizado em: ${_apiLongDate(contract['updatedAt'])}',
    ],
    attachments: documents,
  );
}

_EntitySelectOption _providerOptionFromApi(Map<String, dynamic> company) {
  final legalName = _apiText(company['legalName']);
  final tradeName = _apiText(company['tradeName'], fallback: legalName);
  return _EntitySelectOption(
    publicId: _apiText(company['publicId']),
    label: tradeName,
    description: legalName,
  );
}

_EntitySelectOption _clientOptionFromApi(Map<String, dynamic> client) {
  return _EntitySelectOption(
    publicId: _apiText(client['publicId']),
    label: _apiText(client['name'], fallback: 'Cliente sem nome'),
    description: _apiText(client['clientType']),
  );
}

_EntitySelectOption _contractTypeOptionFromApi(Map<String, dynamic> type) {
  return _EntitySelectOption(
    publicId: _apiText(type['publicId']),
    label: _apiText(type['name'], fallback: 'Tipo sem nome'),
    description: _apiText(type['description']),
    status: _apiText(type['status'], fallback: 'ACTIVE'),
  );
}

_EntitySelectOption _contractModelOptionFromApi(Map<String, dynamic> model) {
  final type = _apiMap(model['contractType']);
  return _EntitySelectOption(
    publicId: _apiText(model['publicId']),
    label: _apiText(model['name'], fallback: 'Modelo sem nome'),
    description: _apiText(
      model['defaultSchedule'],
      fallback: _apiText(model['description']),
    ),
    status: _apiText(model['status'], fallback: 'ACTIVE'),
    parentPublicId: _apiText(type['publicId']),
  );
}

_AttachmentRecord _contractDocumentFromApi(Map<String, dynamic> document) {
  final externalLink = _apiText(document['externalLink']);
  final fileName = _apiText(document['fileName']);
  final physicalLocation = _apiText(document['physicalLocation']);
  final summaryParts = [
    if (fileName.isNotEmpty) fileName,
    if (externalLink.isNotEmpty) externalLink,
    if (physicalLocation.isNotEmpty) physicalLocation,
  ];

  return _AttachmentRecord(
    publicId: _apiText(document['publicId']),
    title: _apiText(document['title'], fallback: 'Documento de contrato'),
    classification: _attachmentClassificationFromApi(
      _apiText(document['classification']),
    ),
    summary: summaryParts.isEmpty
        ? _apiText(
            document['notes'],
            fallback: 'Documento vinculado ao contrato.',
          )
        : summaryParts.join(' | '),
    status: _apiText(document['status'], fallback: 'ACTIVE').toLowerCase(),
    updatedAtLabel: 'atualizado em ${_apiLongDate(document['updatedAt'])}',
    accessPolicy: _apiReturnedContentAccessPolicy,
    mimeType: _apiText(document['mimeType']),
    externalLink: externalLink,
    physicalLocation: physicalLocation,
    canEdit: true,
    canDelete: true,
  );
}

String _entityWorkspaceRuntimeErrorMessage(Object error, String moduleLabel) {
  if (error is _ApiException) {
    return 'API indisponivel para $moduleLabel (${error.code}). Mantive o preview local sem quebrar a pagina.';
  }
  return 'Nao foi possivel sincronizar $moduleLabel com a API. Mantive o preview local.';
}

String _entityStatusLabel(String status) {
  final normalized = status.trim().toUpperCase();
  return switch (normalized) {
    'ACTIVE' => 'ativo',
    'INACTIVE' => 'inativo',
    'SUSPENDED' => 'suspenso',
    'DRAFT' => 'rascunho',
    'EXPIRED' => 'encerrado',
    _ => status.trim().isEmpty ? 'sem status' : status.trim().toLowerCase(),
  };
}

Color _entityStatusColor(String status) {
  final normalized = status.trim().toUpperCase();
  return switch (normalized) {
    'ACTIVE' => _tealColor,
    'SUSPENDED' || 'EXPIRED' => _roseColor,
    'DRAFT' => _amberColor,
    'INACTIVE' => _slateColor,
    _ => _slateColor,
  };
}

String _documentLabel(Object? value) {
  return _apiText(value, fallback: 'documento nao informado');
}

String _pluralCount(int count, String singular, String plural) {
  return '$count ${count == 1 ? singular : plural}';
}

String _entityJsonSummary(Map<String, dynamic> data) {
  final parts = <String>[];
  for (final entry in data.entries) {
    final value = _apiText(entry.value);
    if (value.isNotEmpty) {
      parts.add('${entry.key}: $value');
    }
    if (parts.length == 3) {
      break;
    }
  }
  return parts.isEmpty ? 'dados complementares informados' : parts.join(' | ');
}
