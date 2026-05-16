part of '../../../app/app.dart';

class _NetworkApiRepository {
  _NetworkApiRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<_NetworkGraphPayload> loadGraph({
    required String periodPreset,
    required Iterable<String> rootCompanyPublicIds,
    required Iterable<String> clientCompanyPublicIds,
    required Iterable<String> contractStatuses,
    required Iterable<String> employeeStatuses,
    required bool includeHistorical,
    required bool includeIndirect,
    required String search,
    required String focusPublicId,
  }) async {
    await _apiClient.ensureDevelopmentSession();
    final data = await _apiClient.getMap(
      'network/graph',
      query: {
        'periodPreset': periodPreset,
        'rootCompanyPublicIds': _networkQueryList(rootCompanyPublicIds),
        'clientCompanyPublicIds': _networkQueryList(clientCompanyPublicIds),
        'contractStatuses': _networkQueryList(contractStatuses),
        'employeeStatuses': _networkQueryList(employeeStatuses),
        'includeHistorical': '$includeHistorical',
        'includeIndirect': '$includeIndirect',
        'search': search.trim().isEmpty ? null : search.trim(),
        'focusPublicId': focusPublicId.trim().isEmpty ? null : focusPublicId,
      },
    );

    await Future.wait([
      VisualIdentityLocalStore.instance.loadForType(
        entityType: VisualEntityType.company,
      ),
      VisualIdentityLocalStore.instance.loadForType(
        entityType: VisualEntityType.client,
      ),
      VisualIdentityLocalStore.instance.loadForType(
        entityType: VisualEntityType.contract,
      ),
      VisualIdentityLocalStore.instance.loadForType(
        entityType: VisualEntityType.position,
      ),
      VisualIdentityLocalStore.instance.loadForType(
        entityType: VisualEntityType.user,
      ),
    ]);

    return _NetworkGraphPayload.fromMap(data);
  }

  Future<_NetworkTimelinePayload> loadTimeline({
    required String periodPreset,
    required Iterable<String> rootCompanyPublicIds,
    required Iterable<String> clientCompanyPublicIds,
    required Iterable<String> contractStatuses,
    required Iterable<String> employeeStatuses,
    required bool includeHistorical,
    required String search,
    required String focusCompanyPublicId,
    required String focusCompanyType,
  }) async {
    await _apiClient.ensureDevelopmentSession();
    final data = await _apiClient.getMap(
      'network/timeline',
      query: {
        'periodPreset': periodPreset,
        'rootCompanyPublicIds': _networkQueryList(rootCompanyPublicIds),
        'clientCompanyPublicIds': _networkQueryList(clientCompanyPublicIds),
        'contractStatuses': _networkQueryList(contractStatuses),
        'employeeStatuses': _networkQueryList(employeeStatuses),
        'includeHistorical': '$includeHistorical',
        'includeMoves': 'true',
        'includeOperationalEvents': 'true',
        'search': search.trim().isEmpty ? null : search.trim(),
        'focusCompanyPublicId': focusCompanyPublicId.trim().isEmpty
            ? null
            : focusCompanyPublicId,
        'focusCompanyType': focusCompanyType.trim().isEmpty
            ? null
            : focusCompanyType,
      },
    );

    return _NetworkTimelinePayload.fromMap(data);
  }
}

class _NetworkRuntimeData {
  const _NetworkRuntimeData({
    required this.payload,
    required this.sourceLabel,
    required this.isLive,
    required this.isLoading,
    this.errorMessage,
  });

  factory _NetworkRuntimeData.initial() {
    return const _NetworkRuntimeData(
      payload: _emptyNetworkGraphPayload,
      sourceLabel: 'aguardando API',
      isLive: false,
      isLoading: false,
    );
  }

  factory _NetworkRuntimeData.empty({required String message}) {
    return _NetworkRuntimeData(
      payload: _emptyNetworkGraphPayload,
      sourceLabel: 'API real | /network/graph',
      isLive: true,
      isLoading: false,
      errorMessage: message,
    );
  }

  factory _NetworkRuntimeData.unavailable({required String message}) {
    return _NetworkRuntimeData(
      payload: _emptyNetworkGraphPayload,
      sourceLabel: 'API indisponivel',
      isLive: false,
      isLoading: false,
      errorMessage: message,
    );
  }

  factory _NetworkRuntimeData.live(_NetworkGraphPayload payload) {
    return _NetworkRuntimeData(
      payload: payload,
      sourceLabel: 'API real | /network/graph',
      isLive: true,
      isLoading: false,
    );
  }

  final _NetworkGraphPayload payload;
  final String sourceLabel;
  final bool isLive;
  final bool isLoading;
  final String? errorMessage;

  _NetworkRuntimeData copyWith({
    _NetworkGraphPayload? payload,
    bool? isLoading,
    String? errorMessage,
  }) {
    final loading = isLoading ?? this.isLoading;
    return _NetworkRuntimeData(
      payload: payload ?? this.payload,
      sourceLabel: loading ? 'sincronizando Network' : sourceLabel,
      isLive: isLive,
      isLoading: loading,
      errorMessage: loading ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class _NetworkTimelineRuntimeData {
  const _NetworkTimelineRuntimeData({
    required this.payload,
    required this.sourceLabel,
    required this.isLive,
    required this.isLoading,
    this.errorMessage,
  });

  factory _NetworkTimelineRuntimeData.initial() {
    return const _NetworkTimelineRuntimeData(
      payload: _emptyNetworkTimelinePayload,
      sourceLabel: 'aguardando timeline',
      isLive: false,
      isLoading: false,
    );
  }

  factory _NetworkTimelineRuntimeData.live(_NetworkTimelinePayload payload) {
    return _NetworkTimelineRuntimeData(
      payload: payload,
      sourceLabel: 'API real | /network/timeline',
      isLive: true,
      isLoading: false,
    );
  }

  factory _NetworkTimelineRuntimeData.unavailable({required String message}) {
    return _NetworkTimelineRuntimeData(
      payload: _emptyNetworkTimelinePayload,
      sourceLabel: 'timeline indisponivel',
      isLive: false,
      isLoading: false,
      errorMessage: message,
    );
  }

  final _NetworkTimelinePayload payload;
  final String sourceLabel;
  final bool isLive;
  final bool isLoading;
  final String? errorMessage;

  _NetworkTimelineRuntimeData copyWith({
    _NetworkTimelinePayload? payload,
    bool? isLoading,
    String? errorMessage,
  }) {
    final loading = isLoading ?? this.isLoading;
    return _NetworkTimelineRuntimeData(
      payload: payload ?? this.payload,
      sourceLabel: loading ? 'sincronizando timeline' : sourceLabel,
      isLive: isLive,
      isLoading: loading,
      errorMessage: loading ? null : errorMessage ?? this.errorMessage,
    );
  }
}

String? _networkQueryList(Iterable<String> values) {
  final normalized = values
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toSet()
      .toList();

  return normalized.isEmpty ? null : normalized.join(',');
}

String _networkRuntimeErrorMessage(Object error) {
  if (error is ApiException) {
    return 'API indisponivel para Network (${error.code}). Nenhum dado mock foi carregado.';
  }
  return 'Nao foi possivel sincronizar Network com a API. Nenhum dado mock foi carregado.';
}

String _networkTimelineRuntimeErrorMessage(Object error) {
  if (error is ApiException) {
    return 'Timeline indisponivel (${error.code}). O grafo atual foi preservado.';
  }
  return 'Nao foi possivel sincronizar a timeline. O grafo atual foi preservado.';
}

const _emptyNetworkGraphPayload = _NetworkGraphPayload(
  period: _NetworkGraphPeriod(preset: '1y', from: '', to: ''),
  lanes: [
    _NetworkGraphLane.rootCompany,
    _NetworkGraphLane.clientCompany,
    _NetworkGraphLane.contract,
    _NetworkGraphLane.position,
    _NetworkGraphLane.employee,
  ],
  nodes: [],
  edges: [],
  filters: _NetworkGraphFilters(
    search: '',
    applied: _NetworkGraphAppliedFilters(
      periodPreset: '1y',
      rootCompanyPublicIds: [],
      clientCompanyPublicIds: [],
      contractStatuses: [],
      employeeStatuses: [],
      includeHistorical: true,
      includeIndirect: false,
    ),
    available: _NetworkGraphAvailableFilters(
      periodPresets: ['6m', '1y', '2y', 'all'],
      rootCompanies: [],
      clientCompanies: [],
      contractStatuses: ['active', 'expired', 'suspended'],
      employeeStatuses: ['active', 'dismissed', 'historical'],
      relationshipStates: ['active', 'historical', 'indirect'],
    ),
  ),
  legend: _NetworkGraphLegend(
    relationshipStates: [
      _NetworkGraphLegendEntry(value: 'active', label: 'Ativo'),
      _NetworkGraphLegendEntry(value: 'historical', label: 'Historico'),
      _NetworkGraphLegendEntry(value: 'indirect', label: 'Indireto'),
    ],
  ),
  focus: _NetworkGraphFocus(),
  meta: _NetworkGraphMeta(traceId: ''),
);

const _emptyNetworkTimelinePayload = _NetworkTimelinePayload(
  period: _NetworkGraphPeriod(preset: '1y', from: '', to: ''),
  focus: _NetworkTimelineFocus(),
  contracts: [],
  collaborators: [],
  events: [],
  currentSnapshot: _NetworkTimelineCurrentSnapshot(
    contracts: [],
    positions: [],
    collaborators: [],
  ),
  legend: _NetworkTimelineLegend(eventTypes: [], relationshipStates: []),
  warnings: [],
  meta: _NetworkGraphMeta(traceId: ''),
);
