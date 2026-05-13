import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/visual_identity.dart';

class VisualIdentityLocalStore {
  VisualIdentityLocalStore._();

  static final VisualIdentityLocalStore instance = VisualIdentityLocalStore._();

  final Map<String, EntityVisualIdentity> _cache = {};
  SharedPreferences? _preferences;

  Future<EntityVisualIdentity?> load({
    required VisualEntityType entityType,
    required String entityId,
    String projectId = 'default',
  }) async {
    final key = _key(
      projectId: projectId,
      entityType: entityType,
      entityId: entityId,
    );
    if (_cache.containsKey(key)) {
      return _cache[key];
    }

    final preferences = await _storage();
    final raw = preferences.getString(key);
    if (raw == null) {
      return null;
    }

    final identity = _decode(raw);
    if (identity != null) {
      _cache[key] = identity;
    }
    return identity;
  }

  EntityVisualIdentity? cached({
    required VisualEntityType entityType,
    required String entityId,
    String projectId = 'default',
  }) {
    return _cache[_key(
      projectId: projectId,
      entityType: entityType,
      entityId: entityId,
    )];
  }

  Future<Map<String, EntityVisualIdentity>> loadForType({
    required VisualEntityType entityType,
    String projectId = 'default',
  }) async {
    final preferences = await _storage();
    final prefix = _prefix(projectId: projectId, entityType: entityType);
    final identities = <String, EntityVisualIdentity>{};

    for (final key in preferences.getKeys()) {
      if (!key.startsWith(prefix)) {
        continue;
      }

      final cached = _cache[key];
      if (cached != null) {
        identities[cached.entityId] = cached;
        continue;
      }

      final raw = preferences.getString(key);
      if (raw == null) {
        continue;
      }

      final identity = _decode(raw);
      if (identity != null) {
        _cache[key] = identity;
        identities[identity.entityId] = identity;
      }
    }

    return identities;
  }

  Future<void> save(EntityVisualIdentity identity) async {
    final normalized = identity.copyWith(isCustom: true);
    final key = _key(
      projectId: normalized.projectId,
      entityType: normalized.entityType,
      entityId: normalized.entityId,
    );
    final preferences = await _storage();
    await preferences.setString(key, jsonEncode(normalized.toJson()));
    _cache[key] = normalized;
  }

  Future<void> remove({
    required VisualEntityType entityType,
    required String entityId,
    String projectId = 'default',
  }) async {
    final key = _key(
      projectId: projectId,
      entityType: entityType,
      entityId: entityId,
    );
    final preferences = await _storage();
    await preferences.remove(key);
    _cache.remove(key);
  }

  Future<SharedPreferences> _storage() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  EntityVisualIdentity? _decode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return EntityVisualIdentity.tryFromJson(
          decoded.cast<String, dynamic>(),
        );
      }
    } on FormatException {
      return null;
    }
    return null;
  }

  String _key({
    required String projectId,
    required VisualEntityType entityType,
    required String entityId,
  }) {
    return '${_prefix(projectId: projectId, entityType: entityType)}$entityId';
  }

  String _prefix({
    required String projectId,
    required VisualEntityType entityType,
  }) {
    return 'pariflow.visualIdentity.$projectId.${entityType.name}.';
  }
}
