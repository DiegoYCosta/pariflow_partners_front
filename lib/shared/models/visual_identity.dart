import 'dart:math';

import 'package:flutter/material.dart';

enum VisualEntityType {
  company,
  client,
  contract,
  position,
  category,
  group,
  user,
}

enum VisualShape {
  hexagon,
  pentagon,
  flatDiamond,
  square,
  circle,
  triangle,
  shield,
}

enum VisualPattern { solid, dots, gradient, organicBlobs, waves, mosaic }

class EntityVisualIdentity {
  const EntityVisualIdentity({
    this.projectId = 'default',
    required this.entityType,
    required this.entityId,
    required this.shape,
    required this.primaryColor,
    required this.pattern,
    required this.variantIndex,
    this.secondaryColors = const [],
    this.isCustom = false,
  });

  final String projectId;
  final VisualEntityType entityType;
  final String entityId;
  final VisualShape shape;
  final Color primaryColor;
  final List<Color> secondaryColors;
  final VisualPattern pattern;
  final int variantIndex;
  final bool isCustom;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! EntityVisualIdentity) {
      return false;
    }
    if (secondaryColors.length != other.secondaryColors.length) {
      return false;
    }
    for (var index = 0; index < secondaryColors.length; index += 1) {
      if (secondaryColors[index] != other.secondaryColors[index]) {
        return false;
      }
    }
    return projectId == other.projectId &&
        entityType == other.entityType &&
        entityId == other.entityId &&
        shape == other.shape &&
        primaryColor == other.primaryColor &&
        pattern == other.pattern &&
        variantIndex == other.variantIndex &&
        isCustom == other.isCustom;
  }

  @override
  int get hashCode => Object.hash(
    projectId,
    entityType,
    entityId,
    shape,
    primaryColor,
    Object.hashAll(secondaryColors),
    pattern,
    variantIndex,
    isCustom,
  );

  String get typeLabel {
    return switch (entityType) {
      VisualEntityType.company => 'Empresa',
      VisualEntityType.client => 'Cliente',
      VisualEntityType.contract => 'Contrato',
      VisualEntityType.position => 'Posicao',
      VisualEntityType.category => 'Categoria',
      VisualEntityType.group => 'Grupo',
      VisualEntityType.user => 'Usuario',
    };
  }

  EntityVisualIdentity copyWith({
    String? projectId,
    VisualEntityType? entityType,
    String? entityId,
    VisualShape? shape,
    Color? primaryColor,
    List<Color>? secondaryColors,
    VisualPattern? pattern,
    int? variantIndex,
    bool? isCustom,
  }) {
    return EntityVisualIdentity(
      projectId: projectId ?? this.projectId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      shape: shape ?? this.shape,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColors: secondaryColors ?? this.secondaryColors,
      pattern: pattern ?? this.pattern,
      variantIndex: variantIndex ?? this.variantIndex,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'entityType': entityType.name,
      'entityId': entityId,
      'shape': shape.name,
      'primaryColor': visualIdentityColorToHex(primaryColor),
      'secondaryColors': [
        for (final color in secondaryColors) visualIdentityColorToHex(color),
      ],
      'pattern': pattern.name,
      'variantIndex': variantIndex,
      'isCustom': isCustom,
    };
  }

  static EntityVisualIdentity? tryFromJson(Map<String, dynamic> json) {
    final entityType = _enumByName(
      VisualEntityType.values,
      '${json['entityType'] ?? ''}',
    );
    final shape = _enumByName(VisualShape.values, '${json['shape'] ?? ''}');
    final pattern = _enumByName(
      VisualPattern.values,
      '${json['pattern'] ?? ''}',
    );
    final primaryColor = visualIdentityColorFromHex(
      '${json['primaryColor'] ?? ''}',
    );
    if (entityType == null ||
        shape == null ||
        pattern == null ||
        primaryColor == null) {
      return null;
    }

    final rawSecondaryColors = json['secondaryColors'];
    final secondaryColors = <Color>[];
    if (rawSecondaryColors is List) {
      for (final value in rawSecondaryColors) {
        final color = visualIdentityColorFromHex('$value');
        if (color != null) {
          secondaryColors.add(color);
        }
      }
    }

    return EntityVisualIdentity(
      projectId: '${json['projectId'] ?? 'default'}',
      entityType: entityType,
      entityId: '${json['entityId'] ?? ''}',
      shape: shape,
      primaryColor: primaryColor,
      secondaryColors: secondaryColors,
      pattern: pattern,
      variantIndex: json['variantIndex'] is int
          ? json['variantIndex'] as int
          : int.tryParse('${json['variantIndex'] ?? '0'}') ?? 0,
      isCustom: json['isCustom'] == true,
    );
  }
}

class VisualIdentityGenerator {
  const VisualIdentityGenerator._();

  static EntityVisualIdentity forEntity({
    required VisualEntityType entityType,
    required String entityId,
    String projectId = 'default',
    String displayName = '',
  }) {
    final stableEntityKey = entityId.trim().isEmpty
        ? displayName.trim()
        : entityId.trim();
    final stableSeed = _stableHash(
      '$projectId|${entityType.name}|$stableEntityKey',
    );
    final variantIndex = stableSeed % 97;

    return _identityForVariant(
      projectId: projectId,
      entityType: entityType,
      entityId: entityId,
      variantIndex: variantIndex,
      seed: stableSeed,
      isCustom: false,
    );
  }

  static EntityVisualIdentity forVariant({
    required VisualEntityType entityType,
    required String entityId,
    required int variantIndex,
    String projectId = 'default',
    String displayName = '',
    bool isCustom = true,
  }) {
    final stableEntityKey = entityId.trim().isEmpty
        ? displayName.trim()
        : entityId.trim();
    final stableSeed = _stableHash(
      '$projectId|${entityType.name}|$stableEntityKey|$variantIndex',
    );

    return _identityForVariant(
      projectId: projectId,
      entityType: entityType,
      entityId: entityId,
      variantIndex: variantIndex,
      seed: stableSeed,
      isCustom: isCustom,
    );
  }

  static List<EntityVisualIdentity> suggestionsForEntity({
    required VisualEntityType entityType,
    required String entityId,
    String projectId = 'default',
    String displayName = '',
    int count = 7,
  }) {
    final stableEntityKey = entityId.trim().isEmpty
        ? displayName.trim()
        : entityId.trim();
    final stableSeed = _stableHash(
      '$projectId|${entityType.name}|$stableEntityKey',
    );
    final baseVariantIndex = stableSeed % 97;
    final safeCount = count < 1 ? 1 : count;

    return [
      for (var index = 0; index < safeCount; index += 1)
        _identityForVariant(
          projectId: projectId,
          entityType: entityType,
          entityId: entityId,
          variantIndex: baseVariantIndex + index,
          seed: stableSeed + (index * 0x1F123BB5),
          isCustom: true,
        ),
    ];
  }

  static VisualShape shapeForType(VisualEntityType entityType) {
    return switch (entityType) {
      VisualEntityType.company => VisualShape.hexagon,
      VisualEntityType.client => VisualShape.pentagon,
      VisualEntityType.contract => VisualShape.flatDiamond,
      VisualEntityType.position => VisualShape.square,
      VisualEntityType.category => VisualShape.circle,
      VisualEntityType.group => VisualShape.triangle,
      VisualEntityType.user => VisualShape.circle,
    };
  }

  static VisualPattern patternForType(VisualEntityType entityType) {
    return switch (entityType) {
      VisualEntityType.company => VisualPattern.solid,
      VisualEntityType.client => VisualPattern.solid,
      VisualEntityType.contract => VisualPattern.dots,
      VisualEntityType.position => VisualPattern.gradient,
      VisualEntityType.category => VisualPattern.organicBlobs,
      VisualEntityType.group => VisualPattern.solid,
      VisualEntityType.user => VisualPattern.solid,
    };
  }

  static EntityVisualIdentity _identityForVariant({
    required String projectId,
    required VisualEntityType entityType,
    required String entityId,
    required int variantIndex,
    required int seed,
    required bool isCustom,
  }) {
    return switch (entityType) {
      VisualEntityType.company => _identityFromPalette(
        projectId: projectId,
        entityType: entityType,
        entityId: entityId,
        shape: VisualShape.hexagon,
        pattern: VisualPattern.solid,
        palette: _companyPalette,
        variantIndex: variantIndex,
        isCustom: isCustom,
      ),
      VisualEntityType.client => _identityFromPalette(
        projectId: projectId,
        entityType: entityType,
        entityId: entityId,
        shape: VisualShape.pentagon,
        pattern: VisualPattern.solid,
        palette: _clientPalette,
        variantIndex: variantIndex,
        isCustom: isCustom,
      ),
      VisualEntityType.contract => _identityFromPalette(
        projectId: projectId,
        entityType: entityType,
        entityId: entityId,
        shape: VisualShape.flatDiamond,
        pattern: VisualPattern.dots,
        palette: _contractPalette,
        secondaryColors: const [Color(0xFFE7ECEA)],
        variantIndex: variantIndex,
        isCustom: isCustom,
      ),
      VisualEntityType.position => _positionIdentity(
        projectId: projectId,
        entityId: entityId,
        variantIndex: variantIndex,
        isCustom: isCustom,
      ),
      VisualEntityType.category => _categoryIdentity(
        projectId: projectId,
        entityId: entityId,
        seed: seed,
        variantIndex: variantIndex,
        isCustom: isCustom,
      ),
      VisualEntityType.group => _identityFromPalette(
        projectId: projectId,
        entityType: entityType,
        entityId: entityId,
        shape: VisualShape.triangle,
        pattern: VisualPattern.solid,
        palette: _groupPalette,
        secondaryColors: const [Color(0xFFB88A35)],
        variantIndex: variantIndex,
        isCustom: isCustom,
      ),
      VisualEntityType.user => _identityFromPalette(
        projectId: projectId,
        entityType: entityType,
        entityId: entityId,
        shape: VisualShape.circle,
        pattern: VisualPattern.solid,
        palette: _userPalette,
        variantIndex: variantIndex,
        isCustom: isCustom,
      ),
    };
  }

  static EntityVisualIdentity _identityFromPalette({
    required String projectId,
    required VisualEntityType entityType,
    required String entityId,
    required VisualShape shape,
    required VisualPattern pattern,
    required List<Color> palette,
    required int variantIndex,
    required bool isCustom,
    List<Color> secondaryColors = const [],
  }) {
    return EntityVisualIdentity(
      projectId: projectId,
      entityType: entityType,
      entityId: entityId,
      shape: shape,
      primaryColor: _paletteColor(palette, variantIndex),
      secondaryColors: secondaryColors,
      pattern: pattern,
      variantIndex: variantIndex,
      isCustom: isCustom,
    );
  }

  static EntityVisualIdentity _positionIdentity({
    required String projectId,
    required String entityId,
    required int variantIndex,
    required bool isCustom,
  }) {
    final cold = _paletteColor(_positionColdPalette, variantIndex);
    final warm = _paletteColor(_positionWarmPalette, variantIndex ~/ 2);
    return EntityVisualIdentity(
      projectId: projectId,
      entityType: VisualEntityType.position,
      entityId: entityId,
      shape: VisualShape.square,
      primaryColor: cold,
      secondaryColors: [warm],
      pattern: VisualPattern.gradient,
      variantIndex: variantIndex,
      isCustom: isCustom,
    );
  }

  static EntityVisualIdentity _categoryIdentity({
    required String projectId,
    required String entityId,
    required int seed,
    required int variantIndex,
    required bool isCustom,
  }) {
    final random = Random(seed);
    final colors = <Color>[];
    while (colors.length < 3) {
      final candidate =
          _categoryPalette[random.nextInt(_categoryPalette.length)];
      if (!colors.contains(candidate)) {
        colors.add(candidate);
      }
    }
    return EntityVisualIdentity(
      projectId: projectId,
      entityType: VisualEntityType.category,
      entityId: entityId,
      shape: VisualShape.circle,
      primaryColor: colors.first,
      secondaryColors: colors.skip(1).toList(growable: false),
      pattern: VisualPattern.organicBlobs,
      variantIndex: variantIndex,
      isCustom: isCustom,
    );
  }

  static Color _paletteColor(List<Color> palette, int variantIndex) {
    final base = palette[variantIndex % palette.length];
    final lot = variantIndex ~/ palette.length;
    if (lot == 0) {
      return base;
    }

    final hsl = HSLColor.fromColor(base);
    final lightnessDelta = ((lot % 4) - 1.5) * 0.035;
    final saturationDelta = lot.isEven ? 0.035 : -0.035;
    return hsl
        .withLightness(
          (hsl.lightness + lightnessDelta).clamp(0.18, 0.58).toDouble(),
        )
        .withSaturation(
          (hsl.saturation + saturationDelta).clamp(0.34, 0.82).toDouble(),
        )
        .toColor();
  }

  static int _stableHash(String value) {
    var hash = 0x811C9DC5;
    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }
    return hash;
  }
}

String visualIdentityColorToHex(Color color) {
  final value = color.toARGB32() & 0x00FFFFFF;
  return '#${value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

Color? visualIdentityColorFromHex(String value) {
  final normalized = value.trim().replaceFirst('#', '');
  if (normalized.length != 6 && normalized.length != 8) {
    return null;
  }

  final parsed = int.tryParse(normalized, radix: 16);
  if (parsed == null) {
    return null;
  }

  return Color(normalized.length == 6 ? 0xFF000000 | parsed : parsed);
}

double visualIdentityContrastRatio(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lightest = max(firstLuminance, secondLuminance);
  final darkest = min(firstLuminance, secondLuminance);
  return (lightest + 0.05) / (darkest + 0.05);
}

T? _enumByName<T extends Enum>(List<T> values, String name) {
  for (final value in values) {
    if (value.name == name) {
      return value;
    }
  }
  return null;
}

const _companyPalette = [
  Color(0xFF0F4C5C),
  Color(0xFF12355B),
  Color(0xFF1F4D3A),
  Color(0xFF3F4A2F),
  Color(0xFF2F3E46),
  Color(0xFF352B5B),
  Color(0xFF155E63),
];

const _clientPalette = [
  Color(0xFFC75C48),
  Color(0xFFB65A3C),
  Color(0xFFB7791F),
  Color(0xFFB85C24),
  Color(0xFFB5546A),
  Color(0xFFA94438),
  Color(0xFF9F741A),
];

const _contractPalette = [
  Color(0xFF2563A8),
  Color(0xFF31547A),
  Color(0xFF406A7C),
  Color(0xFF3F5D82),
  Color(0xFF2F6D73),
  Color(0xFF536A75),
  Color(0xFF4E5D8F),
];

const _positionColdPalette = [
  Color(0xFF12355B),
  Color(0xFF0F4C5C),
  Color(0xFF143C38),
  Color(0xFF2F3E46),
  Color(0xFF352B5B),
  Color(0xFF1F4D3A),
];

const _positionWarmPalette = [
  Color(0xFFBF6B2D),
  Color(0xFFC8891F),
  Color(0xFFC75C48),
  Color(0xFFB5546A),
  Color(0xFFB7791F),
  Color(0xFFA94438),
];

const _categoryPalette = [
  Color(0xFF0F766E),
  Color(0xFFBF6B2D),
  Color(0xFFA35252),
  Color(0xFF536A75),
  Color(0xFF2563A8),
  Color(0xFF7A3FC7),
  Color(0xFF2E8B57),
  Color(0xFFD79A16),
  Color(0xFFB5546A),
];

const _groupPalette = [
  Color(0xFF334155),
  Color(0xFF3F3F46),
  Color(0xFF475569),
  Color(0xFF394150),
  Color(0xFF283845),
  Color(0xFF374151),
  Color(0xFF455A64),
];

const _userPalette = [
  Color(0xFF4B5563),
  Color(0xFF5B6472),
  Color(0xFF6B5F73),
  Color(0xFF526A6D),
  Color(0xFF6A5F52),
  Color(0xFF51616F),
  Color(0xFF5C6670),
];
