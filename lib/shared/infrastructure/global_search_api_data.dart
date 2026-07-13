part of '../../app/app.dart';

class _GlobalSearchApiRepository {
  _GlobalSearchApiRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<_GlobalSearchResponse> search(String query) async {
    final trimmed = query.trim();
    await _apiClient.ensureDevelopmentSession();
    final data = await _apiClient.getMap(
      'search',
      query: {'q': trimmed, 'limit': '5'},
    );
    return _GlobalSearchResponse.fromMap(data);
  }
}

class _GlobalSearchResponse {
  const _GlobalSearchResponse({
    required this.groups,
    required this.query,
    required this.authorizedTotal,
  });

  factory _GlobalSearchResponse.fromMap(Map<String, dynamic> map) {
    final meta = (map['meta'] as Map?)?.cast<String, dynamic>() ?? const {};
    return _GlobalSearchResponse(
      groups: [
        for (final group in (map['groups'] as List? ?? const []))
          if (group is Map)
            _GlobalSearchGroup.fromMap(group.cast<String, dynamic>()),
      ],
      query: '${meta['query'] ?? ''}',
      authorizedTotal: _globalSearchIntFromMap(
        meta['authorizedTotal'],
        fallback: 0,
      ),
    );
  }

  final List<_GlobalSearchGroup> groups;
  final String query;
  final int authorizedTotal;

  List<_GlobalSearchFlatItem> get flatItems {
    return [
      for (final group in groups)
        for (final item in group.items)
          _GlobalSearchFlatItem(group: group, item: item),
    ];
  }
}

class _GlobalSearchGroup {
  const _GlobalSearchGroup({
    required this.type,
    required this.label,
    required this.items,
  });

  factory _GlobalSearchGroup.fromMap(Map<String, dynamic> map) {
    return _GlobalSearchGroup(
      type: '${map['type'] ?? ''}',
      label: '${map['label'] ?? ''}',
      items: [
        for (final item in (map['items'] as List? ?? const []))
          if (item is Map)
            _GlobalSearchItem.fromMap(item.cast<String, dynamic>()),
      ],
    );
  }

  final String type;
  final String label;
  final List<_GlobalSearchItem> items;
}

class _GlobalSearchItem {
  const _GlobalSearchItem({
    required this.publicId,
    required this.title,
    required this.subtitle,
    required this.context,
    required this.routeTarget,
    required this.badges,
  });

  factory _GlobalSearchItem.fromMap(Map<String, dynamic> map) {
    final routeTarget =
        (map['routeTarget'] as Map?)?.cast<String, dynamic>() ?? const {};
    return _GlobalSearchItem(
      publicId: '${map['publicId'] ?? ''}',
      title: '${map['title'] ?? ''}',
      subtitle: '${map['subtitle'] ?? ''}',
      context: '${map['context'] ?? ''}',
      routeTarget: _GlobalSearchRouteTarget.fromMap(routeTarget),
      badges: [
        for (final badge in (map['badges'] as List? ?? const [])) '$badge',
      ],
    );
  }

  final String publicId;
  final String title;
  final String subtitle;
  final String context;
  final _GlobalSearchRouteTarget routeTarget;
  final List<String> badges;
}

class _GlobalSearchRouteTarget {
  const _GlobalSearchRouteTarget({
    required this.workspace,
    required this.publicId,
  });

  factory _GlobalSearchRouteTarget.fromMap(Map<String, dynamic> map) {
    return _GlobalSearchRouteTarget(
      workspace: '${map['workspace'] ?? ''}',
      publicId: '${map['publicId'] ?? ''}',
    );
  }

  final String workspace;
  final String publicId;
}

class _GlobalSearchFlatItem {
  const _GlobalSearchFlatItem({required this.group, required this.item});

  final _GlobalSearchGroup group;
  final _GlobalSearchItem item;
}

int _entityIndexForPreferredPublicId({
  required List<_EntityItem> items,
  required String preferredPublicId,
  required int fallbackIndex,
}) {
  if (items.isEmpty) {
    return 0;
  }

  final preferred = preferredPublicId.trim();
  if (preferred.isNotEmpty) {
    final index = items.indexWhere((item) => item.publicId == preferred);
    if (index >= 0) {
      return index;
    }
  }

  return min(max(fallbackIndex, 0), items.length - 1);
}

int _globalSearchIntFromMap(Object? value, {required int fallback}) {
  if (value is int) {
    return value;
  }
  return int.tryParse('${value ?? ''}') ?? fallback;
}
