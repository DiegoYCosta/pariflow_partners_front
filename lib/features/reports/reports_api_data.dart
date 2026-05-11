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
