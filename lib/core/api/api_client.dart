part of '../../app/app.dart';

class _ApiClient {
  _ApiClient({http.Client? httpClient, String? baseUrl})
    : _httpClient = httpClient ?? http.Client(),
      baseUrl = baseUrl ?? _defaultApiBaseUrl;

  final http.Client _httpClient;
  final String baseUrl;
  String? _accessToken;
  _SessionSnapshot? _session;

  bool get hasSession => _accessToken != null;

  Future<_SessionSnapshot> ensureDevelopmentSession() async {
    if (_session != null && _accessToken != null) {
      return _session!;
    }

    final data = await postMap(
      'auth/session/exchange',
      body: const {'firebaseIdToken': 'dev-token'},
      requiresAuth: false,
    );
    final session = _SessionSnapshot.fromMap(data);
    _session = session;
    _accessToken = session.accessToken;
    return session;
  }

  Future<Map<String, dynamic>> getMap(
    String path, {
    Map<String, String?> query = const {},
    bool requiresAuth = true,
  }) async {
    if (requiresAuth) {
      await ensureDevelopmentSession();
    }

    final response = await _httpClient.get(
      _uri(path, query: query),
      headers: _headers(requiresAuth: requiresAuth),
    );

    return _decodeMap(response);
  }

  Future<Map<String, dynamic>> postMap(
    String path, {
    required Map<String, dynamic> body,
    bool requiresAuth = true,
  }) async {
    if (requiresAuth) {
      await ensureDevelopmentSession();
    }

    final response = await _httpClient.post(
      _uri(path),
      headers: _headers(requiresAuth: requiresAuth),
      body: jsonEncode(body),
    );

    return _decodeMap(response);
  }

  Future<Map<String, dynamic>> patchMap(
    String path, {
    required Map<String, dynamic> body,
    bool requiresAuth = true,
  }) async {
    if (requiresAuth) {
      await ensureDevelopmentSession();
    }

    final response = await _httpClient.patch(
      _uri(path),
      headers: _headers(requiresAuth: requiresAuth),
      body: jsonEncode(body),
    );

    return _decodeMap(response);
  }

  Future<Map<String, dynamic>> deleteMap(
    String path, {
    bool requiresAuth = true,
  }) async {
    if (requiresAuth) {
      await ensureDevelopmentSession();
    }

    final response = await _httpClient.delete(
      _uri(path),
      headers: _headers(requiresAuth: requiresAuth),
    );

    return _decodeMap(response);
  }

  Uri _uri(String path, {Map<String, String?> query = const {}}) {
    final base = Uri.parse(baseUrl);
    final cleanQuery = <String, String>{};
    for (final entry in query.entries) {
      final value = entry.value;
      if (value != null && value.isNotEmpty) {
        cleanQuery[entry.key] = value;
      }
    }

    return base.replace(
      pathSegments: [
        ...base.pathSegments.where((segment) => segment.isNotEmpty),
        ...path.split('/').where((segment) => segment.isNotEmpty),
      ],
      queryParameters: cleanQuery.isEmpty ? null : cleanQuery,
    );
  }

  Map<String, String> _headers({required bool requiresAuth}) {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (requiresAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    return headers;
  }

  Map<String, dynamic> _decodeMap(http.Response response) {
    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body);

    if (decoded is! Map) {
      throw _ApiException(
        statusCode: response.statusCode,
        code: 'INVALID_RESPONSE',
        message: 'A API retornou um corpo inesperado.',
      );
    }

    final envelope = decoded.cast<String, dynamic>();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = envelope['data'];
      if (data is Map) {
        return data.cast<String, dynamic>();
      }
      if (data == null && envelope.isNotEmpty) {
        return envelope;
      }
      return <String, dynamic>{};
    }

    final error = envelope['error'];
    if (error is Map) {
      final errorMap = error.cast<String, dynamic>();
      throw _ApiException(
        statusCode: response.statusCode,
        code: '${errorMap['code'] ?? 'API_ERROR'}',
        message: '${errorMap['message'] ?? 'Falha na API.'}',
        traceId: errorMap['traceId'] == null ? null : '${errorMap['traceId']}',
      );
    }

    throw _ApiException(
      statusCode: response.statusCode,
      code: 'HTTP_${response.statusCode}',
      message: 'Falha HTTP ${response.statusCode}.',
    );
  }
}

class _SessionSnapshot {
  const _SessionSnapshot({
    required this.accessToken,
    required this.userPublicId,
    required this.userName,
    required this.securityContext,
    required this.profiles,
    required this.audienceGroups,
  });

  factory _SessionSnapshot.fromMap(Map<String, dynamic> map) {
    final user = (map['user'] as Map?)?.cast<String, dynamic>() ?? const {};

    return _SessionSnapshot(
      accessToken: '${map['accessToken'] ?? ''}',
      userPublicId: '${user['publicId'] ?? ''}',
      userName: '${user['nome'] ?? user['name'] ?? user['email'] ?? 'Sessao'}',
      securityContext: '${map['securityContext'] ?? 'authenticated'}',
      profiles: [
        for (final profile in (map['profiles'] as List? ?? const []))
          '$profile',
      ],
      audienceGroups: [
        for (final group in (map['audienceGroups'] as List? ?? const []))
          '$group',
      ],
    );
  }

  final String accessToken;
  final String userPublicId;
  final String userName;
  final String securityContext;
  final List<String> profiles;
  final List<String> audienceGroups;
}

class _ApiException implements Exception {
  const _ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
    this.traceId,
  });

  final int statusCode;
  final String code;
  final String message;
  final String? traceId;

  @override
  String toString() {
    final suffix = traceId == null ? '' : ' traceId=$traceId';
    return '[$statusCode/$code] $message$suffix';
  }
}

String get _defaultApiBaseUrl {
  const configured = String.fromEnvironment('PARIFLOW_API_BASE_URL');
  if (configured.isNotEmpty) {
    return configured;
  }

  if (kIsWeb) {
    return 'http://localhost:3000/api/v1';
  }

  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:3000/api/v1';
  }

  return 'http://localhost:3000/api/v1';
}
