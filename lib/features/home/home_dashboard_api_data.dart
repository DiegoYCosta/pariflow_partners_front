part of '../../app/app.dart';

class _HomeDashboardApiRepository {
  _HomeDashboardApiRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<_HomeDashboardData> load({
    _HomeDashboardQuery query = const _HomeDashboardQuery(),
  }) async {
    final data = await _apiClient.getMap(
      'dashboard/home',
      query: query.toQueryParameters(),
    );
    return _HomeDashboardData.fromMap(data);
  }
}

class _HomeDashboardQuery {
  const _HomeDashboardQuery({
    this.contractIds = const <String>{},
    this.units = const <String>{},
    this.departments = const <String>{},
    this.positions = const <String>{},
    this.regimes = const <String>{},
    this.period = const _DashboardPeriodSelection.current(),
  });

  final Set<String> contractIds;
  final Set<String> units;
  final Set<String> departments;
  final Set<String> positions;
  final Set<String> regimes;
  final _DashboardPeriodSelection period;

  Map<String, String?> toQueryParameters() {
    return {
      'contractIds': _queryList(contractIds),
      'units': _queryList(units),
      'departments': _queryList(departments),
      'positions': _queryList(positions),
      'regimes': _queryList(regimes),
      'datePreset': period.key,
      'dateFrom': _dashboardDateParam(period.start),
      'dateTo': _dashboardDateParam(period.end),
    };
  }
}

class _DashboardPeriodSelection {
  const _DashboardPeriodSelection._({
    required this.key,
    required this.label,
    required this.shortLabel,
    this.start,
    this.end,
  });

  const _DashboardPeriodSelection.current()
    : key = 'current',
      label = 'Estatisticas atuais',
      shortLabel = '30 dias',
      start = null,
      end = null;

  factory _DashboardPeriodSelection.preset(String key) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return switch (key) {
      'last30' => _DashboardPeriodSelection._(
        key: key,
        label: 'Ultimos 30 dias',
        shortLabel: '30 dias',
        start: today.subtract(const Duration(days: 30)),
        end: today,
      ),
      'last45' => _DashboardPeriodSelection._(
        key: key,
        label: 'Ultimos 45 dias',
        shortLabel: '45 dias',
        start: today.subtract(const Duration(days: 45)),
        end: today,
      ),
      'last90' => _DashboardPeriodSelection._(
        key: key,
        label: 'Ultimos 90 dias',
        shortLabel: '90 dias',
        start: today.subtract(const Duration(days: 90)),
        end: today,
      ),
      'last6m' => _DashboardPeriodSelection._(
        key: key,
        label: 'Ultimos 6 meses',
        shortLabel: '6 meses',
        start: _dashboardAddMonths(today, -6),
        end: today,
      ),
      'last1y' => _DashboardPeriodSelection._(
        key: key,
        label: 'Ultimo ano',
        shortLabel: '1 ano',
        start: _dashboardAddMonths(today, -12),
        end: today,
      ),
      'current' => const _DashboardPeriodSelection.current(),
      _ => const _DashboardPeriodSelection.current(),
    };
  }

  factory _DashboardPeriodSelection.custom(DateTime start, DateTime end) {
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);

    return _DashboardPeriodSelection._(
      key: 'custom',
      label:
          '${_dashboardDisplayDate(normalizedStart)} a ${_dashboardDisplayDate(normalizedEnd)}',
      shortLabel: 'recorte',
      start: normalizedStart,
      end: normalizedEnd,
    );
  }

  final String key;
  final String label;
  final String shortLabel;
  final DateTime? start;
  final DateTime? end;

  bool get isCurrent => key == 'current';
}

class _HomeDashboardData {
  const _HomeDashboardData({
    required this.generatedAt,
    required this.baseDate,
    required this.period,
    required this.metrics,
    required this.filters,
    required this.rows,
  });

  factory _HomeDashboardData.fromMap(Map<String, dynamic> map) {
    return _HomeDashboardData(
      generatedAt: _apiText(map['generatedAt']),
      baseDate: _apiText(map['baseDate']),
      period: _HomeDashboardPeriod.fromMap(_apiMap(map['period'])),
      metrics: _HomeDashboardMetrics.fromMap(_apiMap(map['metrics'])),
      filters: _HomeDashboardFilters.fromMap(_apiMap(map['filters'])),
      rows: [
        for (final row in _apiMapList(map['rows']))
          _HomeDashboardEmployeeRow.fromMap(row),
      ],
    );
  }

  final String generatedAt;
  final String baseDate;
  final _HomeDashboardPeriod period;
  final _HomeDashboardMetrics metrics;
  final _HomeDashboardFilters filters;
  final List<_HomeDashboardEmployeeRow> rows;
}

class _HomeDashboardPeriod {
  const _HomeDashboardPeriod({
    required this.key,
    required this.label,
    required this.shortLabel,
    required this.start,
    required this.end,
  });

  factory _HomeDashboardPeriod.fromMap(Map<String, dynamic> map) {
    return _HomeDashboardPeriod(
      key: _apiText(map['key'], fallback: 'current'),
      label: _apiText(map['label'], fallback: 'Atual'),
      shortLabel: _apiText(map['shortLabel'], fallback: '30 dias'),
      start: _apiText(map['start']),
      end: _apiText(map['end']),
    );
  }

  final String key;
  final String label;
  final String shortLabel;
  final String start;
  final String end;
}

class _HomeDashboardMetrics {
  const _HomeDashboardMetrics({
    required this.providerCompanies,
    required this.clientCompanies,
    required this.activeContracts,
    required this.activeEmployees,
    required this.newEmployees30Days,
    required this.pendingLinks,
    required this.riskItems,
  });

  factory _HomeDashboardMetrics.fromMap(Map<String, dynamic> map) {
    return _HomeDashboardMetrics(
      providerCompanies: _apiInt(map['providerCompanies']),
      clientCompanies: _apiInt(map['clientCompanies']),
      activeContracts: _apiInt(map['activeContracts']),
      activeEmployees: _apiInt(map['activeEmployees']),
      newEmployees30Days: _apiInt(map['newEmployees30Days']),
      pendingLinks: _apiInt(map['pendingLinks']),
      riskItems: _apiInt(map['riskItems']),
    );
  }

  final int providerCompanies;
  final int clientCompanies;
  final int activeContracts;
  final int activeEmployees;
  final int newEmployees30Days;
  final int pendingLinks;
  final int riskItems;
}

class _HomeDashboardFilters {
  const _HomeDashboardFilters({
    required this.contracts,
    required this.units,
    required this.departments,
    required this.positions,
    required this.regimes,
  });

  factory _HomeDashboardFilters.fromMap(Map<String, dynamic> map) {
    return _HomeDashboardFilters(
      contracts: _apiFilterOptions(map['contracts']),
      units: _apiStringList(map['units']),
      departments: _apiStringList(map['departments']),
      positions: _apiStringList(map['positions']),
      regimes: _apiStringList(map['regimes']),
    );
  }

  final List<_HomeDashboardFilterOption> contracts;
  final List<String> units;
  final List<String> departments;
  final List<String> positions;
  final List<String> regimes;
}

class _HomeDashboardFilterOption {
  const _HomeDashboardFilterOption({required this.value, required this.label});

  factory _HomeDashboardFilterOption.fromMap(Map<String, dynamic> map) {
    final value = _apiText(map['value']);
    return _HomeDashboardFilterOption(
      value: value,
      label: _apiText(map['label'], fallback: value),
    );
  }

  final String value;
  final String label;
}

class _HomeDashboardEmployeeRow {
  const _HomeDashboardEmployeeRow({
    required this.publicId,
    required this.contractPublicId,
    required this.contractLabel,
    required this.employeeName,
    required this.employeeInitials,
    required this.email,
    required this.registration,
    required this.position,
    required this.department,
    required this.unit,
    required this.admissionDate,
    required this.regime,
    required this.status,
    required this.statusLabel,
  });

  factory _HomeDashboardEmployeeRow.fromMap(Map<String, dynamic> map) {
    return _HomeDashboardEmployeeRow(
      publicId: _apiText(map['publicId']),
      contractPublicId: _apiText(map['contractPublicId']),
      contractLabel: _apiText(map['contractLabel'], fallback: 'Contrato'),
      employeeName: _apiText(map['employeeName'], fallback: 'Colaborador'),
      employeeInitials: _apiText(map['employeeInitials'], fallback: 'PF'),
      email: _apiText(map['email'], fallback: 'email nao informado'),
      registration: _apiText(map['registration'], fallback: '-'),
      position: _apiText(map['position'], fallback: 'Cargo nao informado'),
      department: _apiText(
        map['department'],
        fallback: 'Departamento nao informado',
      ),
      unit: _apiText(map['unit'], fallback: 'Unidade nao informada'),
      admissionDate: _apiText(map['admissionDate']),
      regime: _apiText(map['regime'], fallback: '-'),
      status: _apiText(map['status'], fallback: 'ACTIVE'),
      statusLabel: _apiText(map['statusLabel'], fallback: 'Ativo'),
    );
  }

  final String publicId;
  final String contractPublicId;
  final String contractLabel;
  final String employeeName;
  final String employeeInitials;
  final String email;
  final String registration;
  final String position;
  final String department;
  final String unit;
  final String admissionDate;
  final String regime;
  final String status;
  final String statusLabel;
}

List<_HomeDashboardFilterOption> _apiFilterOptions(Object? value) {
  if (value is! List) {
    return const [];
  }

  return [
    for (final item in value)
      if (item is Map)
        _HomeDashboardFilterOption.fromMap(item.cast<String, dynamic>()),
  ];
}

List<String> _apiStringList(Object? value) {
  if (value is! List) {
    return const [];
  }

  return [
    for (final item in value)
      if (_apiText(item).isNotEmpty) _apiText(item),
  ];
}

String? _queryList(Set<String> values) {
  final cleanValues =
      values
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(growable: false)
        ..sort();

  return cleanValues.isEmpty ? null : cleanValues.join(',');
}

String? _dashboardDateParam(DateTime? date) {
  if (date == null) {
    return null;
  }

  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

String _dashboardDisplayDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

DateTime _dashboardAddMonths(DateTime date, int months) {
  final targetMonth = date.month + months;
  final year = date.year + ((targetMonth - 1) ~/ 12);
  final month = ((targetMonth - 1) % 12) + 1;
  final lastDay = DateTime(year, month + 1, 0).day;
  return DateTime(year, month, min(date.day, lastDay));
}
