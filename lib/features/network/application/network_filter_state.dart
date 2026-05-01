part of '../../../app/app.dart';

enum _DismissedPeriod { sixMonths, oneYear, twoYears, fiveYears, allTime }

enum _NetworkZoomPreset { overview, reading, focus, detail }

enum _NetworkMapControlMode { guided, direct }

extension on _DismissedPeriod {
  String get label => switch (this) {
    _DismissedPeriod.sixMonths => '6 meses',
    _DismissedPeriod.oneYear => '1 ano',
    _DismissedPeriod.twoYears => '2 anos',
    _DismissedPeriod.fiveYears => '5 anos',
    _DismissedPeriod.allTime => 'todo o periodo',
  };

  String get summary => switch (this) {
    _DismissedPeriod.sixMonths => 'desligados ate 6 meses',
    _DismissedPeriod.oneYear => 'desligados ate 1 ano',
    _DismissedPeriod.twoYears => 'desligados ate 2 anos',
    _DismissedPeriod.fiveYears => 'desligados ate 5 anos',
    _DismissedPeriod.allTime => 'desligados de todo o periodo',
  };

  int? get maxDays => switch (this) {
    _DismissedPeriod.sixMonths => 183,
    _DismissedPeriod.oneYear => 365,
    _DismissedPeriod.twoYears => 730,
    _DismissedPeriod.fiveYears => 1825,
    _DismissedPeriod.allTime => null,
  };
}

extension on _NetworkZoomPreset {
  String get label => switch (this) {
    _NetworkZoomPreset.overview => 'geral',
    _NetworkZoomPreset.reading => 'leitura',
    _NetworkZoomPreset.focus => 'foco',
    _NetworkZoomPreset.detail => 'detalhe',
  };

  double get multiplier => switch (this) {
    _NetworkZoomPreset.overview => 1,
    _NetworkZoomPreset.reading => 1.12,
    _NetworkZoomPreset.focus => 1.32,
    _NetworkZoomPreset.detail => 1.56,
  };
}

extension on _NetworkMapControlMode {
  String get label => switch (this) {
    _NetworkMapControlMode.guided => 'mouse guiado',
    _NetworkMapControlMode.direct => 'explorar com mouse',
  };
}

class _NetworkFilterState {
  const _NetworkFilterState({
    this.dismissedDays = 45,
    this.dismissedPeriod,
    this.hiddenRootCompanyIds = const {},
    this.selectedSectors = const {},
    this.selectedJobTitles = const {},
    this.selectedTenureBands = const {},
    this.selectedGenders = const {},
    this.selectedRaces = const {},
    this.requireWarnings,
  });

  static const _unset = Object();

  final int dismissedDays;
  final _DismissedPeriod? dismissedPeriod;
  final Set<String> hiddenRootCompanyIds;
  final Set<String> selectedSectors;
  final Set<String> selectedJobTitles;
  final Set<String> selectedTenureBands;
  final Set<String> selectedGenders;
  final Set<String> selectedRaces;
  final bool? requireWarnings;

  bool get usesCustomDismissedWindow => dismissedPeriod == null;

  int? get maxDismissedDays => dismissedPeriod?.maxDays ?? dismissedDays;

  String get dismissedWindowLabel =>
      dismissedPeriod?.label ?? '$dismissedDays dias';

  String get dismissedWindowSummary =>
      dismissedPeriod?.summary ?? 'desligados ate $dismissedDays dias';

  _NetworkFilterState copyWith({
    int? dismissedDays,
    Object? dismissedPeriod = _unset,
    Set<String>? hiddenRootCompanyIds,
    Set<String>? selectedSectors,
    Set<String>? selectedJobTitles,
    Set<String>? selectedTenureBands,
    Set<String>? selectedGenders,
    Set<String>? selectedRaces,
    Object? requireWarnings = _unset,
  }) {
    return _NetworkFilterState(
      dismissedDays: dismissedDays ?? this.dismissedDays,
      dismissedPeriod: dismissedPeriod == _unset
          ? this.dismissedPeriod
          : dismissedPeriod as _DismissedPeriod?,
      hiddenRootCompanyIds: hiddenRootCompanyIds ?? this.hiddenRootCompanyIds,
      selectedSectors: selectedSectors ?? this.selectedSectors,
      selectedJobTitles: selectedJobTitles ?? this.selectedJobTitles,
      selectedTenureBands: selectedTenureBands ?? this.selectedTenureBands,
      selectedGenders: selectedGenders ?? this.selectedGenders,
      selectedRaces: selectedRaces ?? this.selectedRaces,
      requireWarnings: requireWarnings == _unset
          ? this.requireWarnings
          : requireWarnings as bool?,
    );
  }
}
