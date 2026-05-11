part of '../../app/app.dart';

class _ReportsApiRepository {
  _ReportsApiRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<_ReportExecutionResult> executeReport({
    required _CrmReportTemplate template,
    required Map<String, String> filters,
    required Set<String> requiredFilters,
    required Set<String> optionalFilters,
    required String delivery,
    required String frequency,
  }) async {
    final data = await _apiClient.postMap(
      'relatorios/executar',
      body: {
        'templateId': template.id,
        'filters': filters,
        'requiredFilters': requiredFilters.toList(growable: false),
        'optionalFilters': optionalFilters.toList(growable: false),
        'delivery': delivery,
        'frequency': frequency,
      },
    );

    return _ReportExecutionResult.fromMap(data);
  }
}

class _ReportExecutionResult {
  const _ReportExecutionResult({
    required this.templateId,
    required this.title,
    required this.family,
    required this.status,
    required this.generatedAt,
    required this.requestedBy,
    required this.metadata,
    required this.delivery,
    required this.frequency,
    required this.metrics,
    required this.columns,
    required this.rows,
    required this.csv,
    required this.notes,
  });

  factory _ReportExecutionResult.fromMap(Map<String, dynamic> map) {
    return _ReportExecutionResult(
      templateId: _apiText(map['templateId']),
      title: _apiText(map['title'], fallback: 'Relatorio'),
      family: _apiText(map['family']),
      status: _apiText(map['status'], fallback: 'planned'),
      generatedAt: _apiText(map['generatedAt']),
      requestedBy: _apiText(map['requestedBy']),
      metadata: _ReportMetadata.fromMap(
        _apiMap(map['metadata']),
        fallbackGeneratedAt: _apiText(map['generatedAt']),
        fallbackRequestedBy: _apiText(map['requestedBy']),
      ),
      delivery: _apiText(map['delivery'], fallback: 'Painel'),
      frequency: _apiText(map['frequency'], fallback: 'Manual'),
      metrics: [
        for (final metric in _apiMapList(map['metrics']))
          _ReportMetric.fromMap(metric),
      ],
      columns: [
        for (final column in _apiMapList(map['columns']))
          _ReportColumn.fromMap(column),
      ],
      rows: _apiMapList(map['rows']),
      csv: _apiText(map['csv']),
      notes: [
        for (final note in (map['notes'] as List? ?? const [])) _apiText(note),
      ].where((note) => note.isNotEmpty).toList(growable: false),
    );
  }

  final String templateId;
  final String title;
  final String family;
  final String status;
  final String generatedAt;
  final String requestedBy;
  final _ReportMetadata metadata;
  final String delivery;
  final String frequency;
  final List<_ReportMetric> metrics;
  final List<_ReportColumn> columns;
  final List<Map<String, dynamic>> rows;
  final String csv;
  final List<String> notes;

  bool get isReady => status.toLowerCase() == 'ready';
  bool get hasRows => rows.isNotEmpty && columns.isNotEmpty;
}

class _ReportMetadata {
  const _ReportMetadata({
    required this.generatedAt,
    required this.generatedAtLabel,
    required this.generatedByName,
    required this.generatedByPublicId,
    required this.generatedByEmail,
    required this.linkedCompanyName,
    required this.linkedCompanyPublicId,
    required this.linkedCompanyType,
    required this.permissionLevel,
    required this.permissionProfiles,
  });

  factory _ReportMetadata.fromMap(
    Map<String, dynamic> map, {
    required String fallbackGeneratedAt,
    required String fallbackRequestedBy,
  }) {
    final generatedBy = _apiMap(map['generatedBy']);
    final linkedCompany = _apiMap(map['linkedCompany']);
    final permission = _apiMap(map['permission']);
    final profiles = permission['profiles'];

    return _ReportMetadata(
      generatedAt: _apiText(map['generatedAt'], fallback: fallbackGeneratedAt),
      generatedAtLabel: _reportGeneratedAtLabel(
        _apiText(map['generatedAt'], fallback: fallbackGeneratedAt),
      ),
      generatedByName: _apiText(
        generatedBy['name'],
        fallback: fallbackRequestedBy.isEmpty ? 'Usuario' : fallbackRequestedBy,
      ),
      generatedByPublicId: _apiText(generatedBy['publicId']),
      generatedByEmail: _apiText(generatedBy['email']),
      linkedCompanyName: _apiText(linkedCompany['name']),
      linkedCompanyPublicId: _apiText(linkedCompany['publicId']),
      linkedCompanyType: _apiText(linkedCompany['type']),
      permissionLevel: _apiText(permission['level'], fallback: 'Autenticado'),
      permissionProfiles: [
        if (profiles is List)
          for (final profile in profiles)
            if (_apiText(profile).isNotEmpty) _apiText(profile),
      ],
    );
  }

  final String generatedAt;
  final String generatedAtLabel;
  final String generatedByName;
  final String generatedByPublicId;
  final String generatedByEmail;
  final String linkedCompanyName;
  final String linkedCompanyPublicId;
  final String linkedCompanyType;
  final String permissionLevel;
  final List<String> permissionProfiles;

  bool get hasLinkedCompany =>
      linkedCompanyName.isNotEmpty || linkedCompanyPublicId.isNotEmpty;

  String get generatedByLabel {
    if (generatedByPublicId.isEmpty) {
      return generatedByName;
    }
    return '$generatedByName ($generatedByPublicId)';
  }

  String get linkedCompanyLabel {
    if (!hasLinkedCompany) {
      return 'Empresa nao vinculada';
    }
    if (linkedCompanyPublicId.isEmpty) {
      return linkedCompanyName;
    }
    return '$linkedCompanyName ($linkedCompanyPublicId)';
  }

  String get permissionLabel {
    final profileText = permissionProfiles.take(2).join(', ');
    return profileText.isEmpty
        ? permissionLevel
        : '$permissionLevel - $profileText';
  }
}

class _ReportMetric {
  const _ReportMetric({required this.label, required this.value});

  factory _ReportMetric.fromMap(Map<String, dynamic> map) {
    return _ReportMetric(
      label: _apiText(map['label'], fallback: 'Metrica'),
      value: _apiText(map['value'], fallback: '0'),
    );
  }

  final String label;
  final String value;
}

class _ReportColumn {
  const _ReportColumn({required this.keyName, required this.label});

  factory _ReportColumn.fromMap(Map<String, dynamic> map) {
    return _ReportColumn(
      keyName: _apiText(map['key']),
      label: _apiText(map['label'], fallback: 'Coluna'),
    );
  }

  final String keyName;
  final String label;
}

String _reportGeneratedAtLabel(String value) {
  final parsed = DateTime.tryParse(value)?.toLocal();
  if (parsed == null) {
    return value.isEmpty ? 'Gerado agora' : value;
  }
  final day = parsed.day.toString().padLeft(2, '0');
  final month = parsed.month.toString().padLeft(2, '0');
  final hour = parsed.hour.toString().padLeft(2, '0');
  final minute = parsed.minute.toString().padLeft(2, '0');
  final second = parsed.second.toString().padLeft(2, '0');
  return '$day/$month/${parsed.year} $hour:$minute:$second';
}
