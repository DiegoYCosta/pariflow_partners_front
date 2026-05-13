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
    required this.entityType,
    required this.entityId,
    required this.shape,
    required this.primaryColor,
    required this.pattern,
    required this.variantIndex,
    this.secondaryColors = const [],
    this.isCustom = false,
  });

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
    return entityType == other.entityType &&
        entityId == other.entityId &&
        shape == other.shape &&
        primaryColor == other.primaryColor &&
        pattern == other.pattern &&
        variantIndex == other.variantIndex &&
        isCustom == other.isCustom;
  }

  @override
  int get hashCode => Object.hash(
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

    return switch (entityType) {
      VisualEntityType.company => _identityFromPalette(
        entityType: entityType,
        entityId: entityId,
        shape: VisualShape.hexagon,
        pattern: VisualPattern.solid,
        palette: _companyPalette,
        variantIndex: variantIndex,
      ),
      VisualEntityType.client => _identityFromPalette(
        entityType: entityType,
        entityId: entityId,
        shape: VisualShape.pentagon,
        pattern: VisualPattern.solid,
        palette: _clientPalette,
        variantIndex: variantIndex,
      ),
      VisualEntityType.contract => _identityFromPalette(
        entityType: entityType,
        entityId: entityId,
        shape: VisualShape.flatDiamond,
        pattern: VisualPattern.dots,
        palette: _contractPalette,
        secondaryColors: const [Color(0xFFE7ECEA)],
        variantIndex: variantIndex,
      ),
      VisualEntityType.position => _positionIdentity(
        entityId: entityId,
        variantIndex: variantIndex,
      ),
      VisualEntityType.category => _categoryIdentity(
        entityId: entityId,
        seed: stableSeed,
        variantIndex: variantIndex,
      ),
      VisualEntityType.group => _identityFromPalette(
        entityType: entityType,
        entityId: entityId,
        shape: VisualShape.triangle,
        pattern: VisualPattern.solid,
        palette: _groupPalette,
        secondaryColors: const [Color(0xFFB88A35)],
        variantIndex: variantIndex,
      ),
      VisualEntityType.user => _identityFromPalette(
        entityType: entityType,
        entityId: entityId,
        shape: VisualShape.circle,
        pattern: VisualPattern.solid,
        palette: _userPalette,
        variantIndex: variantIndex,
      ),
    };
  }

  static EntityVisualIdentity _identityFromPalette({
    required VisualEntityType entityType,
    required String entityId,
    required VisualShape shape,
    required VisualPattern pattern,
    required List<Color> palette,
    required int variantIndex,
    List<Color> secondaryColors = const [],
  }) {
    return EntityVisualIdentity(
      entityType: entityType,
      entityId: entityId,
      shape: shape,
      primaryColor: _paletteColor(palette, variantIndex),
      secondaryColors: secondaryColors,
      pattern: pattern,
      variantIndex: variantIndex,
    );
  }

  static EntityVisualIdentity _positionIdentity({
    required String entityId,
    required int variantIndex,
  }) {
    final cold = _paletteColor(_positionColdPalette, variantIndex);
    final warm = _paletteColor(_positionWarmPalette, variantIndex ~/ 2);
    return EntityVisualIdentity(
      entityType: VisualEntityType.position,
      entityId: entityId,
      shape: VisualShape.square,
      primaryColor: cold,
      secondaryColors: [warm],
      pattern: VisualPattern.gradient,
      variantIndex: variantIndex,
    );
  }

  static EntityVisualIdentity _categoryIdentity({
    required String entityId,
    required int seed,
    required int variantIndex,
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
      entityType: VisualEntityType.category,
      entityId: entityId,
      shape: VisualShape.circle,
      primaryColor: colors.first,
      secondaryColors: colors.skip(1).toList(growable: false),
      pattern: VisualPattern.organicBlobs,
      variantIndex: variantIndex,
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
