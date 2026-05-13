part of '../../app/app.dart';

class _EntityMarker extends StatelessWidget {
  const _EntityMarker({
    required this.identity,
    this.size = 22,
    this.semanticLabel,
    this.selected = false,
  });

  final EntityVisualIdentity identity;
  final double size;
  final String? semanticLabel;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final label =
        semanticLabel ?? '${identity.typeLabel} ${identity.entityId}'.trim();
    final markerSize = size * 0.90;
    return Semantics(
      label: label,
      image: true,
      child: Tooltip(
        message: label,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Opacity(
              opacity: selected ? 0.94 : 0.90,
              child: SizedBox(
                width: markerSize,
                height: markerSize,
                child: CustomPaint(
                  painter: _EntityMarkerPainter(
                    identity: identity,
                    selected: selected,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EntityBadge extends StatelessWidget {
  const _EntityBadge({
    required this.identity,
    required this.label,
    this.typeLabel,
    this.size = 24,
    this.maxWidth = 260,
  });

  final EntityVisualIdentity identity;
  final String label;
  final String? typeLabel;
  final double size;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final displayType = typeLabel ?? identity.typeLabel;
    final markerLabel = '$displayType: $label';
    return Tooltip(
      message: markerLabel,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _EntityMarker(
              identity: identity,
              size: size,
              semanticLabel: markerLabel,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: _inkColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntityChip extends StatelessWidget {
  const _EntityChip({
    required this.identity,
    required this.label,
    this.typeLabel,
    this.maxWidth = 220,
  });

  final EntityVisualIdentity identity;
  final String label;
  final String? typeLabel;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final color = identity.primaryColor;
    final displayType = typeLabel ?? identity.typeLabel;
    final markerLabel = '$displayType: $label';
    return Tooltip(
      message: markerLabel,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _EntityMarker(
              identity: identity,
              size: 16,
              semanticLabel: markerLabel,
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisualIdentityLegend extends StatelessWidget {
  const _VisualIdentityLegend({
    required this.entries,
    this.maxEntryWidth = 190,
    this.dense = false,
  });

  final List<_VisualIdentityLegendEntry> entries;
  final double maxEntryWidth;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: dense ? 8 : 10,
      runSpacing: dense ? 8 : 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final entry in entries)
          _VisualIdentityLegendChip(
            entry: entry,
            maxWidth: maxEntryWidth,
            dense: dense,
          ),
      ],
    );
  }
}

class _VisualIdentityLegendEntry {
  const _VisualIdentityLegendEntry({
    required this.identity,
    required this.label,
    this.count,
    this.selected = false,
    this.onTap,
  });

  final EntityVisualIdentity identity;
  final String label;
  final int? count;
  final bool selected;
  final VoidCallback? onTap;
}

class _VisualIdentityLegendChip extends StatelessWidget {
  const _VisualIdentityLegendChip({
    required this.entry,
    required this.maxWidth,
    required this.dense,
  });

  final _VisualIdentityLegendEntry entry;
  final double maxWidth;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final color = entry.identity.primaryColor;
    final label = entry.count == null
        ? entry.label
        : '${entry.label} ${entry.count}';
    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 9 : 11,
        vertical: dense ? 7 : 8,
      ),
      decoration: BoxDecoration(
        color: entry.selected
            ? color.withValues(alpha: 0.15)
            : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: entry.selected ? 0.44 : 0.18),
          width: entry.selected ? 1.3 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _EntityMarker(
            identity: entry.identity,
            size: dense ? 15 : 17,
            selected: entry.selected,
            semanticLabel: entry.label,
          ),
          SizedBox(width: dense ? 6 : 7),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );

    if (entry.onTap == null) {
      return Tooltip(message: entry.label, child: content);
    }

    return Tooltip(
      message: entry.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: entry.onTap,
          borderRadius: BorderRadius.circular(999),
          child: content,
        ),
      ),
    );
  }
}

class _VisualIdentityPickerResult {
  const _VisualIdentityPickerResult.save(this.identity) : reset = false;
  const _VisualIdentityPickerResult.reset() : identity = null, reset = true;

  final EntityVisualIdentity? identity;
  final bool reset;
}

class _VisualIdentityPickerDialog extends StatefulWidget {
  const _VisualIdentityPickerDialog({
    required this.currentIdentity,
    required this.entityLabel,
    required this.existingIdentities,
  });

  final EntityVisualIdentity currentIdentity;
  final String entityLabel;
  final List<EntityVisualIdentity> existingIdentities;

  @override
  State<_VisualIdentityPickerDialog> createState() =>
      _VisualIdentityPickerDialogState();
}

class _VisualIdentityPickerDialogState
    extends State<_VisualIdentityPickerDialog> {
  late EntityVisualIdentity _selectedIdentity;
  late final List<EntityVisualIdentity> _suggestions;

  @override
  void initState() {
    super.initState();
    _selectedIdentity = widget.currentIdentity.copyWith(isCustom: true);
    _suggestions = VisualIdentityGenerator.suggestionsForEntity(
      projectId: widget.currentIdentity.projectId,
      entityType: widget.currentIdentity.entityType,
      entityId: widget.currentIdentity.entityId,
      displayName: widget.entityLabel,
      count: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final warning = _visualIdentityWarning(
      identity: _selectedIdentity,
      existingIdentities: widget.existingIdentities,
    );

    return AlertDialog(
      title: const Text('Identidade visual'),
      content: SizedBox(
        width: min(MediaQuery.sizeOf(context).width - 48, 620),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EntityBadge(
                identity: _selectedIdentity,
                label: widget.entityLabel,
                typeLabel: _selectedIdentity.typeLabel,
                size: 28,
                maxWidth: 520,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _Tag(
                    label: _visualShapeLabel(_selectedIdentity.shape),
                    icon: Icons.category_outlined,
                    color: _selectedIdentity.primaryColor,
                    background: _selectedIdentity.primaryColor.withValues(
                      alpha: 0.10,
                    ),
                  ),
                  _Tag(
                    label: _visualPatternLabel(_selectedIdentity.pattern),
                    icon: Icons.texture_outlined,
                    color: _slateColor,
                    background: _slateColor.withValues(alpha: 0.10),
                  ),
                  _Tag(
                    label: visualIdentityColorToHex(
                      _selectedIdentity.primaryColor,
                    ),
                    icon: Icons.palette_outlined,
                    color: _selectedIdentity.primaryColor,
                    background: _selectedIdentity.primaryColor.withValues(
                      alpha: 0.10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text('Opcoes', style: theme.textTheme.titleMedium),
              const SizedBox(height: 10),
              _VisualIdentityPicker(
                selectedIdentity: _selectedIdentity,
                suggestions: _suggestions,
                onChanged: (identity) {
                  setState(() {
                    _selectedIdentity = identity.copyWith(isCustom: true);
                  });
                },
              ),
              if (warning != null) ...[
                const SizedBox(height: 14),
                _VisualIdentityNotice(message: warning),
              ],
              const SizedBox(height: 14),
              Text(
                'A personalizacao fica salva neste dispositivo ate o backend expor visual_identities.',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: _mutedColor,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(
            context,
          ).pop(const _VisualIdentityPickerResult.reset()),
          child: const Text('Automatico'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(
            context,
          ).pop(_VisualIdentityPickerResult.save(_selectedIdentity)),
          child: const Text('Salvar visual'),
        ),
      ],
    );
  }
}

class _VisualIdentityPicker extends StatelessWidget {
  const _VisualIdentityPicker({
    required this.selectedIdentity,
    required this.suggestions,
    required this.onChanged,
  });

  final EntityVisualIdentity selectedIdentity;
  final List<EntityVisualIdentity> suggestions;
  final ValueChanged<EntityVisualIdentity> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final identity in suggestions)
          _VisualIdentityOption(
            identity: identity,
            selected: _sameVisualIdentityChoice(identity, selectedIdentity),
            onTap: () => onChanged(identity),
          ),
      ],
    );
  }
}

class _VisualIdentityOption extends StatelessWidget {
  const _VisualIdentityOption({
    required this.identity,
    required this.selected,
    required this.onTap,
  });

  final EntityVisualIdentity identity;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = identity.primaryColor;
    final label = visualIdentityColorToHex(color);
    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 92,
            height: 78,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: selected
                  ? color.withValues(alpha: 0.13)
                  : Colors.white.withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? color : _lineColor,
                width: selected ? 1.6 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _EntityMarker(
                  identity: identity,
                  size: 32,
                  selected: selected,
                  semanticLabel: label,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VisualIdentityNotice extends StatelessWidget {
  const _VisualIdentityNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _amberColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _amberColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 18, color: _amberColor),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: _inkColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntityMarkerPainter extends CustomPainter {
  const _EntityMarkerPainter({required this.identity, required this.selected});

  final EntityVisualIdentity identity;
  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _shapePath(identity.shape, size);
    final bounds = path.getBounds();
    final fillPaint = Paint()..style = PaintingStyle.fill;

    if (identity.pattern == VisualPattern.gradient &&
        identity.secondaryColors.isNotEmpty) {
      fillPaint.shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [identity.primaryColor, identity.secondaryColors.first],
      ).createShader(bounds);
    } else {
      fillPaint.color = identity.primaryColor;
    }

    canvas.drawPath(path, fillPaint);

    if (identity.pattern == VisualPattern.dots) {
      _drawDots(canvas, path, size);
    } else if (identity.pattern == VisualPattern.organicBlobs) {
      _drawOrganicBlobs(canvas, path, size);
    } else if (identity.pattern == VisualPattern.waves) {
      _drawWaves(canvas, path, size);
    } else if (identity.pattern == VisualPattern.mosaic) {
      _drawMosaic(canvas, path, size);
    }

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = selected ? 2.2 : 1.2
      ..color = selected
          ? identity.primaryColor
          : Colors.white.withValues(alpha: 0.86);
    canvas.drawPath(path, strokePaint);

    final outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = const Color(0xFF182521).withValues(alpha: 0.12);
    canvas.drawPath(path, outerPaint);
  }

  Path _shapePath(VisualShape shape, Size size) {
    return switch (shape) {
      VisualShape.hexagon => _polygonPath(size, sides: 6, rotation: pi / 6),
      VisualShape.pentagon => _polygonPath(size, sides: 5, rotation: -pi / 2),
      VisualShape.flatDiamond => _flatDiamondPath(size),
      VisualShape.square => Path()..addRect(_markerRect(size)),
      VisualShape.circle => Path()..addOval(_markerRect(size)),
      VisualShape.triangle => _polygonPath(size, sides: 3, rotation: -pi / 2),
      VisualShape.shield => _shieldPath(size),
    };
  }

  Rect _markerRect(Size size) {
    final inset = max(1.0, size.shortestSide * 0.06);
    return Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );
  }

  Path _polygonPath(Size size, {required int sides, required double rotation}) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.44;
    final path = Path();
    for (var index = 0; index < sides; index += 1) {
      final angle = rotation + (pi * 2 * index / sides);
      final point = center + Offset(cos(angle), sin(angle)) * radius;
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path..close();
  }

  Path _flatDiamondPath(Size size) {
    final rect = _markerRect(size);
    final center = rect.center;
    final halfWidth = rect.width * 0.48;
    final halfHeight = rect.height * 0.27;
    return Path()
      ..moveTo(center.dx, center.dy - halfHeight)
      ..lineTo(center.dx + halfWidth, center.dy)
      ..lineTo(center.dx, center.dy + halfHeight)
      ..lineTo(center.dx - halfWidth, center.dy)
      ..close();
  }

  Path _shieldPath(Size size) {
    final rect = _markerRect(size);
    return Path()
      ..moveTo(rect.left + rect.width * 0.50, rect.top)
      ..lineTo(rect.right, rect.top + rect.height * 0.18)
      ..lineTo(rect.right - rect.width * 0.12, rect.top + rect.height * 0.68)
      ..lineTo(rect.left + rect.width * 0.50, rect.bottom)
      ..lineTo(rect.left + rect.width * 0.12, rect.top + rect.height * 0.68)
      ..lineTo(rect.left, rect.top + rect.height * 0.18)
      ..close();
  }

  void _drawDots(Canvas canvas, Path path, Size size) {
    canvas.save();
    canvas.clipPath(path);
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color =
          (identity.secondaryColors.isEmpty
                  ? const Color(0xFFE7ECEA)
                  : identity.secondaryColors.first)
              .withValues(alpha: 0.95);
    final step = max(4.0, size.shortestSide * 0.28);
    final radius = max(1.0, size.shortestSide * 0.055);
    for (var y = step * 0.55; y < size.height; y += step) {
      for (var x = step * 0.55; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), radius, dotPaint);
      }
    }
    canvas.restore();
  }

  void _drawOrganicBlobs(Canvas canvas, Path path, Size size) {
    canvas.save();
    canvas.clipPath(path);
    final colors = [identity.primaryColor, ...identity.secondaryColors];
    for (var index = 0; index < min(4, colors.length); index += 1) {
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = colors[index].withValues(alpha: index == 0 ? 0.34 : 0.72);
      final dx =
          size.width * (0.18 + ((identity.variantIndex + index * 7) % 7) / 10);
      final dy =
          size.height * (0.18 + ((identity.variantIndex + index * 5) % 6) / 10);
      final blobSize = size.shortestSide * (0.34 + index * 0.08);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(dx, dy),
          width: blobSize * 1.25,
          height: blobSize,
        ),
        paint,
      );
    }
    canvas.restore();
  }

  void _drawWaves(Canvas canvas, Path path, Size size) {
    canvas.save();
    canvas.clipPath(path);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(1.0, size.shortestSide * 0.08)
      ..color = Colors.white.withValues(alpha: 0.36);
    for (var y = size.height * 0.20; y < size.height; y += size.height * 0.28) {
      final wave = Path()..moveTo(0, y);
      wave.cubicTo(
        size.width * 0.30,
        y - size.height * 0.18,
        size.width * 0.64,
        y + size.height * 0.18,
        size.width,
        y,
      );
      canvas.drawPath(wave, paint);
    }
    canvas.restore();
  }

  void _drawMosaic(Canvas canvas, Path path, Size size) {
    canvas.save();
    canvas.clipPath(path);
    final colors = identity.secondaryColors.isEmpty
        ? [Colors.white.withValues(alpha: 0.26)]
        : identity.secondaryColors;
    final cell = size.shortestSide / 3;
    for (var row = 0; row < 3; row += 1) {
      for (var col = 0; col < 3; col += 1) {
        final color = colors[(row + col) % colors.length];
        canvas.drawRect(
          Rect.fromLTWH(col * cell, row * cell, cell, cell),
          Paint()..color = color.withValues(alpha: 0.34),
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _EntityMarkerPainter oldDelegate) {
    return oldDelegate.identity != identity || oldDelegate.selected != selected;
  }
}

Future<bool> _editVisualIdentityForItem({
  required BuildContext context,
  required _EntityItem item,
  required List<_EntityItem> projectItems,
}) async {
  final currentIdentity = _visualIdentityForEntityItem(item);
  final result = await showDialog<_VisualIdentityPickerResult>(
    context: context,
    builder: (context) => _VisualIdentityPickerDialog(
      currentIdentity: currentIdentity,
      entityLabel: item.title,
      existingIdentities: _visualIdentitiesForEntityItems(projectItems),
    ),
  );

  if (result == null) {
    return false;
  }

  if (result.reset) {
    await VisualIdentityLocalStore.instance.remove(
      projectId: currentIdentity.projectId,
      entityType: currentIdentity.entityType,
      entityId: currentIdentity.entityId,
    );
  } else if (result.identity case final identity?) {
    await VisualIdentityLocalStore.instance.save(
      identity.copyWith(
        projectId: currentIdentity.projectId,
        entityType: currentIdentity.entityType,
        entityId: currentIdentity.entityId,
        shape: VisualIdentityGenerator.shapeForType(currentIdentity.entityType),
        pattern: VisualIdentityGenerator.patternForType(
          currentIdentity.entityType,
        ),
        isCustom: true,
      ),
    );
  }

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.reset
              ? 'Identidade visual automatica restaurada.'
              : 'Identidade visual salva neste dispositivo.',
        ),
      ),
    );
  }
  return true;
}

EntityVisualIdentity _visualIdentityForEntityItem(_EntityItem item) {
  return item.visualIdentity ??
      VisualIdentityGenerator.forEntity(
        entityType: VisualEntityType.category,
        entityId: item.publicId,
        displayName: item.title,
      );
}

List<EntityVisualIdentity> _visualIdentitiesForEntityItems(
  List<_EntityItem> items,
) {
  return [for (final item in items) _visualIdentityForEntityItem(item)];
}

EntityVisualIdentity _visualIdentityForContractPosition(
  _ContractPositionRecord position,
) {
  return VisualIdentityGenerator.forEntity(
    entityType: VisualEntityType.position,
    entityId: position.publicId,
    displayName: position.name,
  );
}

EntityVisualIdentity _visualIdentityForNetworkNode(_NetworkGraphNode node) {
  final entityType = _visualEntityTypeForNetworkLane(node.lane);
  final cachedIdentity = VisualIdentityLocalStore.instance.cached(
    entityType: entityType,
    entityId: node.publicId,
  );
  if (cachedIdentity != null) {
    return cachedIdentity;
  }

  return VisualIdentityGenerator.forEntity(
    entityType: entityType,
    entityId: node.publicId,
    displayName: node.displayName,
  );
}

EntityVisualIdentity _visualIdentityForNetworkLane(_NetworkGraphLane lane) {
  return VisualIdentityGenerator.forEntity(
    entityType: _visualEntityTypeForNetworkLane(lane),
    entityId: lane.name,
    displayName: _laneLabel(lane),
  );
}

EntityVisualIdentity _visualIdentityForTimelineLink(_TimelineRecordLink link) {
  final entityType = _visualEntityTypeForTimelineLink(link.entityType);
  final entityId = link.entityPublicId.isEmpty
      ? '${link.entityType}:${link.labelSnapshot}'
      : link.entityPublicId;
  final cachedIdentity = VisualIdentityLocalStore.instance.cached(
    entityType: entityType,
    entityId: entityId,
  );
  if (cachedIdentity != null) {
    return cachedIdentity;
  }

  return VisualIdentityGenerator.forEntity(
    entityType: entityType,
    entityId: entityId,
    displayName: link.labelSnapshot,
  );
}

VisualEntityType _visualEntityTypeForNetworkLane(_NetworkGraphLane lane) {
  return switch (lane) {
    _NetworkGraphLane.rootCompany => VisualEntityType.company,
    _NetworkGraphLane.clientCompany => VisualEntityType.client,
    _NetworkGraphLane.contract => VisualEntityType.contract,
    _NetworkGraphLane.position => VisualEntityType.position,
    _NetworkGraphLane.employee => VisualEntityType.user,
  };
}

VisualEntityType _visualEntityTypeForTimelineLink(String type) {
  return switch (type.toUpperCase()) {
    'PROVIDER_COMPANY' => VisualEntityType.company,
    'CLIENT_COMPANY' => VisualEntityType.client,
    'CONTRACT' || 'CONTRACT_TEXT' => VisualEntityType.contract,
    'PERSON' => VisualEntityType.user,
    'GROUP' => VisualEntityType.group,
    'CITY' || 'OTHER' => VisualEntityType.category,
    _ => VisualEntityType.category,
  };
}

List<_VisualIdentityLegendEntry> _legendEntriesForEntityItems(
  List<_EntityItem> items,
) {
  final countsByType = <VisualEntityType, int>{};
  for (final item in items) {
    final identity = _visualIdentityForEntityItem(item);
    countsByType[identity.entityType] =
        (countsByType[identity.entityType] ?? 0) + 1;
  }

  final order = [
    VisualEntityType.company,
    VisualEntityType.client,
    VisualEntityType.contract,
    VisualEntityType.position,
    VisualEntityType.user,
    VisualEntityType.group,
    VisualEntityType.category,
  ];
  return [
    for (final type in order)
      if (countsByType[type] case final count?)
        if (VisualIdentityGenerator.forEntity(
              entityType: type,
              entityId: type.name,
            )
            case final identity)
          _VisualIdentityLegendEntry(
            identity: identity,
            label: identity.typeLabel,
            count: count,
          ),
  ];
}

bool _sameVisualIdentityChoice(
  EntityVisualIdentity first,
  EntityVisualIdentity second,
) {
  if (first.shape != second.shape ||
      first.pattern != second.pattern ||
      first.primaryColor != second.primaryColor ||
      first.secondaryColors.length != second.secondaryColors.length) {
    return false;
  }
  for (var index = 0; index < first.secondaryColors.length; index += 1) {
    if (first.secondaryColors[index] != second.secondaryColors[index]) {
      return false;
    }
  }
  return true;
}

String? _visualIdentityWarning({
  required EntityVisualIdentity identity,
  required List<EntityVisualIdentity> existingIdentities,
}) {
  final contrastOnPaper = visualIdentityContrastRatio(
    identity.primaryColor,
    _paperColor,
  );
  if (contrastOnPaper < 2.6) {
    return 'Contraste baixo no tema claro. Escolha uma opcao mais escura.';
  }

  for (final existing in existingIdentities) {
    if (existing.entityId == identity.entityId ||
        existing.entityType != identity.entityType) {
      continue;
    }

    if (existing.primaryColor == identity.primaryColor) {
      return 'Cor ja usada por outra entidade deste tipo.';
    }

    if (_visuallyCloseColors(existing.primaryColor, identity.primaryColor)) {
      return 'Cor muito parecida com outra entidade deste tipo.';
    }
  }

  return null;
}

bool _visuallyCloseColors(Color first, Color second) {
  final firstHsl = HSLColor.fromColor(first);
  final secondHsl = HSLColor.fromColor(second);
  final hueDelta = (firstHsl.hue - secondHsl.hue).abs();
  final circularHueDelta = min(hueDelta, 360 - hueDelta);
  final saturationDelta = (firstHsl.saturation - secondHsl.saturation).abs();
  final lightnessDelta = (firstHsl.lightness - secondHsl.lightness).abs();
  return circularHueDelta < 8 &&
      saturationDelta < 0.10 &&
      lightnessDelta < 0.10;
}

String _visualShapeLabel(VisualShape shape) {
  return switch (shape) {
    VisualShape.hexagon => 'Hexagono',
    VisualShape.pentagon => 'Pentagono',
    VisualShape.flatDiamond => 'Losango',
    VisualShape.square => 'Quadrado',
    VisualShape.circle => 'Circulo',
    VisualShape.triangle => 'Triangulo',
    VisualShape.shield => 'Escudo',
  };
}

String _visualPatternLabel(VisualPattern pattern) {
  return switch (pattern) {
    VisualPattern.solid => 'Solido',
    VisualPattern.dots => 'Pontilhado',
    VisualPattern.gradient => 'Gradiente',
    VisualPattern.organicBlobs => 'Organico',
    VisualPattern.waves => 'Ondas',
    VisualPattern.mosaic => 'Mosaico',
  };
}
