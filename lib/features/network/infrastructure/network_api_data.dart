part of '../../../app/app.dart';

class _NetworkApiRepository {
  _NetworkApiRepository({_ApiClient? apiClient})
    : _apiClient = apiClient ?? _ApiClient();

  final _ApiClient _apiClient;

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

    return _NetworkGraphPayload.fromMap(data);
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

  factory _NetworkRuntimeData.mock({String? errorMessage}) {
    return _NetworkRuntimeData(
      payload: _networkGraphContractPreview,
      sourceLabel: errorMessage == null ? 'preview local' : 'fallback local',
      isLive: false,
      isLoading: false,
      errorMessage: errorMessage,
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

String? _networkQueryList(Iterable<String> values) {
  final normalized = values
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toSet()
      .toList();

  return normalized.isEmpty ? null : normalized.join(',');
}

String _networkRuntimeErrorMessage(Object error) {
  if (error is _ApiException) {
    return 'API indisponivel para Network (${error.code}). Mantive o preview local.';
  }
  return 'Nao foi possivel sincronizar Network com a API. Mantive o preview local.';
}
