part of '../../../app/app.dart';

enum _GraphNodeKind { company, contract, person }

enum _GraphEdgeType { portfolio, origin, scope, allocation, dismissal, history }

extension on _GraphEdgeType {
  String get label => switch (this) {
    _GraphEdgeType.portfolio => 'carteira empresarial',
    _GraphEdgeType.origin => 'vinculo de origem',
    _GraphEdgeType.scope => 'escopo contratual',
    _GraphEdgeType.allocation => 'alocacao ativa',
    _GraphEdgeType.dismissal => 'desligamento recente',
    _GraphEdgeType.history => 'passagem anterior',
  };

  Color get color => switch (this) {
    _GraphEdgeType.portfolio => _slateColor,
    _GraphEdgeType.origin => _deepTealColor,
    _GraphEdgeType.scope => _amberColor,
    _GraphEdgeType.allocation => _tealColor,
    _GraphEdgeType.dismissal => _roseColor,
    _GraphEdgeType.history => _slateColor,
  };

  bool get dashed => switch (this) {
    _GraphEdgeType.portfolio => false,
    _GraphEdgeType.origin => true,
    _GraphEdgeType.scope => false,
    _GraphEdgeType.allocation => false,
    _GraphEdgeType.dismissal => true,
    _GraphEdgeType.history => true,
  };
}

class _GraphNode {
  const _GraphNode({
    required this.id,
    required this.kind,
    required this.rootCompanyId,
    required this.label,
    required this.subtitle,
    required this.miniLabel,
    required this.position,
    required this.status,
    required this.color,
    required this.icon,
    required this.highlights,
    this.sector,
    this.jobTitle,
    this.gender,
    this.race,
    this.tenureMonths,
    this.hasWarnings = false,
    this.isRoot = false,
    this.dismissedDaysAgo,
  });

  final String id;
  final _GraphNodeKind kind;
  final String rootCompanyId;
  final String label;
  final String subtitle;
  final String miniLabel;
  final Alignment position;
  final String status;
  final Color color;
  final IconData icon;
  final List<String> highlights;
  final String? sector;
  final String? jobTitle;
  final String? gender;
  final String? race;
  final int? tenureMonths;
  final bool hasWarnings;
  final bool isRoot;
  final int? dismissedDaysAgo;

  String get kindLabel => switch (kind) {
    _GraphNodeKind.company => isRoot ? 'empresa-raiz' : 'empresa-cliente',
    _GraphNodeKind.contract => 'contrato',
    _GraphNodeKind.person => 'funcionario',
  };

  String? get tenureBand {
    if (tenureMonths == null) {
      return null;
    }
    if (tenureMonths! < 12) {
      return 'ate 1 ano';
    }
    if (tenureMonths! < 36) {
      return '1 a 3 anos';
    }
    if (tenureMonths! < 60) {
      return '3 a 5 anos';
    }
    return '5 anos ou mais';
  }

  _GraphNode copyWith({Alignment? position}) {
    return _GraphNode(
      id: id,
      kind: kind,
      rootCompanyId: rootCompanyId,
      label: label,
      subtitle: subtitle,
      miniLabel: miniLabel,
      position: position ?? this.position,
      status: status,
      color: color,
      icon: icon,
      highlights: highlights,
      sector: sector,
      jobTitle: jobTitle,
      gender: gender,
      race: race,
      tenureMonths: tenureMonths,
      hasWarnings: hasWarnings,
      isRoot: isRoot,
      dismissedDaysAgo: dismissedDaysAgo,
    );
  }
}

class _GraphEdge {
  const _GraphEdge({
    required this.from,
    required this.to,
    required this.type,
    required this.detail,
  });

  final String from;
  final String to;
  final _GraphEdgeType type;
  final String detail;
}

class _GraphConnectionDetail {
  const _GraphConnectionDetail({required this.node, required this.edge});

  final _GraphNode node;
  final _GraphEdge edge;
}

class _NetworkFacetData {
  const _NetworkFacetData({
    required this.rootCompanies,
    required this.sectors,
    required this.jobTitles,
    required this.tenureBands,
    required this.genders,
    required this.races,
    required this.hasRecordsWithWarnings,
    required this.hasRecordsWithoutWarnings,
  });

  final List<_GraphNode> rootCompanies;
  final List<String> sectors;
  final List<String> jobTitles;
  final List<String> tenureBands;
  final List<String> genders;
  final List<String> races;
  final bool hasRecordsWithWarnings;
  final bool hasRecordsWithoutWarnings;
}

