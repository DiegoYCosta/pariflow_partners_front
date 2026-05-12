import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:http/http.dart' as http;

import '../../firebase_options.dart';
import 'api_http_client.dart';

class ApiClient {
  ApiClient({http.Client? httpClient, String? baseUrl})
    : _httpClient = httpClient ?? createApiHttpClient(),
      baseUrl = baseUrl ?? _defaultApiBaseUrl;

  final http.Client _httpClient;
  final String baseUrl;
  static String? _accessToken;
  static SessionSnapshot? _session;
  static DateTime? _accessTokenRefreshAt;

  bool get hasSession => _accessToken != null;

  Future<SessionSnapshot> ensureDevelopmentSession() async {
    if (_session != null &&
        _accessToken != null &&
        (_accessTokenRefreshAt == null ||
            DateTime.now().isBefore(_accessTokenRefreshAt!))) {
      return _session!;
    }

    if (await _tryRefreshSession()) {
      return _session!;
    }

    final firebaseIdToken = await _currentFirebaseIdToken();
    final previewToken = previewFirebaseIdToken;

    if (firebaseIdToken != null) {
      try {
        return _exchangeSession(firebaseIdToken);
      } on ApiException {
        if (previewToken == null) {
          rethrow;
        }
      }
    }

    if (previewToken == null) {
      throw const ApiException(
        statusCode: 0,
        code: 'AUTH_NOT_CONFIGURED',
        message:
            'Sessao Firebase nao encontrada e o token local esta desativado.',
      );
    }

    return _exchangeSession(previewToken);
  }

  Future<SessionSnapshot> _exchangeSession(String firebaseIdToken) async {
    final data = await postMap(
      'auth/session/exchange',
      body: {'firebaseIdToken': firebaseIdToken},
      requiresAuth: false,
    );
    final session = SessionSnapshot.fromMap(data);
    _storeSession(session);
    return session;
  }

  Future<void> logout({bool signOutFirebase = true}) async {
    try {
      await _httpClient.post(
        _uri('auth/logout'),
        headers: _headers(requiresAuth: false),
        body: '{}',
      );
    } catch (_) {
      // Logout local ainda precisa limpar estado mesmo se a API estiver fora.
    } finally {
      _clearSession();
    }

    if (!signOutFirebase ||
        !DefaultFirebaseOptions.isConfiguredForCurrentPlatform ||
        Firebase.apps.isEmpty) {
      return;
    }

    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseException {
      // A sessao interna ja foi limpa. Firebase pode estar indisponivel em dev.
    }
  }

  Future<Map<String, dynamic>> getMap(
    String path, {
    Map<String, String?> query = const {},
    bool requiresAuth = true,
  }) async {
    final response = await _sendWithOptionalRefresh(
      () => _httpClient.get(
        _uri(path, query: query),
        headers: _headers(requiresAuth: requiresAuth),
      ),
      requiresAuth: requiresAuth,
    );

    return _decodeMap(response);
  }

  Future<Map<String, dynamic>> postMap(
    String path, {
    required Map<String, dynamic> body,
    bool requiresAuth = true,
  }) async {
    final response = await _sendWithOptionalRefresh(
      () => _httpClient.post(
        _uri(path),
        headers: _headers(requiresAuth: requiresAuth),
        body: jsonEncode(body),
      ),
      requiresAuth: requiresAuth,
    );

    return _decodeMap(response);
  }

  Future<Map<String, dynamic>> patchMap(
    String path, {
    required Map<String, dynamic> body,
    bool requiresAuth = true,
  }) async {
    final response = await _sendWithOptionalRefresh(
      () => _httpClient.patch(
        _uri(path),
        headers: _headers(requiresAuth: requiresAuth),
        body: jsonEncode(body),
      ),
      requiresAuth: requiresAuth,
    );

    return _decodeMap(response);
  }

  Future<Map<String, dynamic>> deleteMap(
    String path, {
    bool requiresAuth = true,
  }) async {
    final response = await _sendWithOptionalRefresh(
      () => _httpClient.delete(
        _uri(path),
        headers: _headers(requiresAuth: requiresAuth),
      ),
      requiresAuth: requiresAuth,
    );

    return _decodeMap(response);
  }

  Future<http.Response> _sendWithOptionalRefresh(
    Future<http.Response> Function() send, {
    required bool requiresAuth,
  }) async {
    if (!requiresAuth) {
      return send();
    }

    await ensureDevelopmentSession();
    var response = await send();
    if (response.statusCode != 401) {
      return response;
    }

    if (await _tryRefreshSession()) {
      response = await send();
    }
    return response;
  }

  Future<bool> _tryRefreshSession() async {
    try {
      final response = await _httpClient.post(
        _uri('auth/refresh'),
        headers: _headers(requiresAuth: false),
        body: '{}',
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        _clearSession();
        return false;
      }

      final session = SessionSnapshot.fromMap(_decodeMap(response));
      _storeSession(session);
      return true;
    } catch (_) {
      _clearSession();
      return false;
    }
  }

  static void _storeSession(SessionSnapshot session) {
    _session = session;
    _accessToken = session.accessToken;
    final refreshMarginSeconds = session.expiresInSeconds > 90 ? 45 : 10;
    _accessTokenRefreshAt = DateTime.now().add(
      Duration(
        seconds: (session.expiresInSeconds - refreshMarginSeconds).clamp(
          5,
          session.expiresInSeconds,
        ),
      ),
    );
  }

  static void _clearSession() {
    _session = null;
    _accessToken = null;
    _accessTokenRefreshAt = null;
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
      throw ApiException(
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
      throw ApiException(
        statusCode: response.statusCode,
        code: '${errorMap['code'] ?? 'API_ERROR'}',
        message: '${errorMap['message'] ?? 'Falha na API.'}',
        traceId: errorMap['traceId'] == null ? null : '${errorMap['traceId']}',
      );
    }

    throw ApiException(
      statusCode: response.statusCode,
      code: 'HTTP_${response.statusCode}',
      message: 'Falha HTTP ${response.statusCode}.',
    );
  }
}

Future<String?> _currentFirebaseIdToken() async {
  if (!DefaultFirebaseOptions.isConfiguredForCurrentPlatform ||
      Firebase.apps.isEmpty) {
    return null;
  }

  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }

    return user.getIdToken();
  } on FirebaseException {
    return null;
  }
}

class SessionSnapshot {
  const SessionSnapshot({
    required this.accessToken,
    required this.userPublicId,
    required this.userName,
    required this.tenantRootCompanyPublicId,
    required this.tenantRootCompanyName,
    required this.expiresInSeconds,
    required this.refreshExpiresInSeconds,
    required this.securityContext,
    required this.profiles,
    required this.audienceGroups,
  });

  factory SessionSnapshot.fromMap(Map<String, dynamic> map) {
    final user = (map['user'] as Map?)?.cast<String, dynamic>() ?? const {};
    final tenantRootCompany =
        (user['tenantRootCompany'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final tenantName =
        '${tenantRootCompany['tradeName'] ?? tenantRootCompany['legalName'] ?? ''}'
            .trim();

    return SessionSnapshot(
      accessToken: '${map['accessToken'] ?? ''}',
      userPublicId: '${user['publicId'] ?? ''}',
      userName: '${user['nome'] ?? user['name'] ?? user['email'] ?? 'Sessao'}',
      tenantRootCompanyPublicId:
          '${tenantRootCompany['publicId'] ?? ''}'.trim(),
      tenantRootCompanyName: tenantName,
      expiresInSeconds: _intFromMap(map['expiresInSeconds'], fallback: 600),
      refreshExpiresInSeconds: _intFromMap(
        map['refreshExpiresInSeconds'],
        fallback: 0,
      ),
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
  final String tenantRootCompanyPublicId;
  final String tenantRootCompanyName;
  final int expiresInSeconds;
  final int refreshExpiresInSeconds;
  final String securityContext;
  final List<String> profiles;
  final List<String> audienceGroups;

  String get tenantRootCompanyLabel {
    final parts = [
      tenantRootCompanyName,
      tenantRootCompanyPublicId,
    ].where((part) => part.isNotEmpty).toList(growable: false);
    return parts.join(' | ');
  }
}

int _intFromMap(Object? value, {required int fallback}) {
  if (value is int) {
    return value;
  }
  return int.tryParse('${value ?? ''}') ?? fallback;
}

class ApiException implements Exception {
  const ApiException({
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
    if (kReleaseMode &&
        Uri.base.hasScheme &&
        Uri.base.host.isNotEmpty &&
        Uri.base.host != 'localhost' &&
        Uri.base.host != '127.0.0.1') {
      return Uri.base.replace(path: 'api/v1', query: '').toString();
    }

    return 'http://127.0.0.1:3002/api/v1';
  }

  return 'http://3.18.213.49/api/v1';
}

String get defaultApiBaseUrl => _defaultApiBaseUrl;

String? get previewFirebaseIdToken {
  const enabled = bool.fromEnvironment(
    'PARIFLOW_ENABLE_DEV_TOKEN',
    defaultValue: false,
  );

  if (!enabled) {
    return null;
  }

  final apiBaseUri = Uri.tryParse(defaultApiBaseUrl);
  if (!kReleaseMode && _isLocalHostName(apiBaseUri?.host ?? '')) {
    return 'dev-token';
  }

  if (kIsWeb && _isLocalHostName(Uri.base.host)) {
    return 'dev-token';
  }

  return null;
}

bool _isLocalHostName(String host) {
  final normalized = host.toLowerCase();
  return normalized == 'localhost' ||
      normalized == '127.0.0.1' ||
      normalized == '::1' ||
      normalized == '[::1]';
}
