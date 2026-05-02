part of '../../../../app/app.dart';

class _NetworkLinkPainter extends CustomPainter {
  _NetworkLinkPainter({
    required this.nodes,
    required this.edges,
    required this.focusNodeId,
    required this.pulseNodeId,
    required this.pulseAnimation,
    required this.pulseEdgeKey,
    required this.pulseEdgeOrigin,
  }) : super(repaint: pulseAnimation);

  final List<_GraphNode> nodes;
  final List<_GraphEdge> edges;
  final String focusNodeId;
  final String? pulseNodeId;
  final Animation<double> pulseAnimation;
  final String? pulseEdgeKey;
  final double pulseEdgeOrigin;

  @override
  void paint(Canvas canvas, Size size) {
    final positions = <String, Offset>{};

    for (final node in nodes) {
      final nodeSize = _graphNodeCardSize(node);
      final normalizedX = (node.position.x + 1) / 2;
      final normalizedY = (node.position.y + 1) / 2;
      positions[node.id] = Offset(
        (size.width - nodeSize.width) * normalizedX + (nodeSize.width / 2),
        (size.height - nodeSize.height) * normalizedY + (nodeSize.height / 2),
      );
    }

    final relatedIds = _relatedNodeIds(focusNodeId, edges);

    for (final edge in edges) {
      final from = positions[edge.from];
      final to = positions[edge.to];
      if (from == null || to == null) {
        continue;
      }

      final isFocusedConnection =
          edge.from == focusNodeId || edge.to == focusNodeId;

      final controlX = (from.dx + to.dx) / 2;
      final path = Path()
        ..moveTo(from.dx, from.dy)
        ..quadraticBezierTo(controlX, (from.dy + to.dy) / 2, to.dx, to.dy);

      final strokePaint = Paint()
        ..color = edge.type.color.withValues(
          alpha: isFocusedConnection
              ? 0.72
              : relatedIds.isEmpty
              ? 0.22
              : 0.12,
        )
        ..strokeWidth = isFocusedConnection ? 3.2 : 2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      if (edge.type.dashed) {
        _drawDashedPath(canvas, path, strokePaint);
      } else {
        canvas.drawPath(path, strokePaint);
      }

      if (pulseEdgeKey == _graphEdgeKey(edge) && pulseAnimation.value > 0) {
        _paintEdgeRipple(canvas, path, edge: edge, origin: pulseEdgeOrigin);
      }

      final originNodeId = pulseNodeId;
      if (originNodeId != null &&
          pulseAnimation.value > 0 &&
          (edge.from == originNodeId || edge.to == originNodeId)) {
        _paintPulse(canvas, path, edge: edge, reverse: edge.to == originNodeId);
      }
    }
  }

  void _paintEdgeRipple(
    Canvas canvas,
    Path path, {
    required _GraphEdge edge,
    required double origin,
  }) {
    final metricIterator = path.computeMetrics().iterator;
    if (!metricIterator.moveNext()) {
      return;
    }

    final metric = metricIterator.current;
    final spread = Curves.easeOutCubic.transform(pulseAnimation.value);
    final fade = Curves.easeOut.transform(1 - pulseAnimation.value);
    final centerOffset = metric.length * origin.clamp(0.0, 1.0);
    final radius = metric.length * (0.03 + (spread * 0.36)).clamp(0.03, 0.40);
    final start = max(0.0, centerOffset - radius);
    final end = min(metric.length, centerOffset + radius);
    final ripplePath = metric.extractPath(start, end);
    final rippleColor = Color.lerp(edge.type.color, Colors.white, 0.52)!;

    final washPaint = Paint()
      ..color = rippleColor.withValues(alpha: 0.12 + fade * 0.18)
      ..strokeWidth = 4.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
    if (edge.type.dashed) {
      _drawDashedPath(canvas, path, washPaint);
    } else {
      canvas.drawPath(path, washPaint);
    }

    final glowPaint = Paint()
      ..color = rippleColor.withValues(alpha: 0.22 + fade * 0.30)
      ..strokeWidth = 7.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);
    canvas.drawPath(ripplePath, glowPaint);

    final strokePaint = Paint()
      ..color = rippleColor.withValues(alpha: 0.34 + fade * 0.34)
      ..strokeWidth = 4.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(ripplePath, strokePaint);

    final leadingTangent = metric.getTangentForOffset(end);
    final trailingTangent = metric.getTangentForOffset(start);
    final headPaint = Paint()
      ..color = rippleColor.withValues(alpha: 0.20 + fade * 0.20)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14.0);
    final corePaint = Paint()
      ..color = rippleColor.withValues(alpha: 0.96)
      ..style = PaintingStyle.fill;

    if (leadingTangent != null) {
      canvas.drawCircle(leadingTangent.position, 9.5 + fade * 3.8, headPaint);
      canvas.drawCircle(leadingTangent.position, 3.0 + fade * 1.4, corePaint);
    }

    if (trailingTangent != null && (end - start) > 24) {
      canvas.drawCircle(trailingTangent.position, 9.5 + fade * 3.8, headPaint);
      canvas.drawCircle(trailingTangent.position, 3.0 + fade * 1.4, corePaint);
    }
  }

  void _paintPulse(
    Canvas canvas,
    Path path, {
    required _GraphEdge edge,
    required bool reverse,
  }) {
    final metricIterator = path.computeMetrics().iterator;
    if (!metricIterator.moveNext()) {
      return;
    }

    final metric = metricIterator.current;
    final travel = Curves.easeOutCubic.transform(pulseAnimation.value);
    final fade = Curves.easeOut.transform(1 - pulseAnimation.value);
    final glowStrength = (0.36 + (sin(travel * pi) * 0.48) + (fade * 0.24))
        .clamp(0.0, 1.0);
    final headOffset = metric.length * (reverse ? 1 - travel : travel);
    final segmentLength =
        metric.length * (0.16 + ((1 - travel) * 0.08)).clamp(0.14, 0.24);
    final start = reverse
        ? max(0.0, headOffset - (segmentLength * 0.28))
        : max(0.0, headOffset - segmentLength);
    final end = reverse
        ? min(metric.length, headOffset + segmentLength)
        : min(metric.length, headOffset + (segmentLength * 0.28));
    final segmentPath = metric.extractPath(start, end);
    final pulseColor = Color.lerp(edge.type.color, Colors.white, 0.44)!;

    final washStrength = Curves.easeOutCubic.transform(
      (1 - pulseAnimation.value).clamp(0.0, 1.0),
    );
    final washGlowPaint = Paint()
      ..color = pulseColor.withValues(alpha: 0.10 + washStrength * 0.18)
      ..strokeWidth = 5.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
    canvas.drawPath(path, washGlowPaint);

    final washStrokePaint = Paint()
      ..color = pulseColor.withValues(alpha: 0.12 + washStrength * 0.22)
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    if (edge.type.dashed) {
      _drawDashedPath(canvas, path, washStrokePaint);
    } else {
      canvas.drawPath(path, washStrokePaint);
    }

    final glowPaint = Paint()
      ..color = pulseColor.withValues(alpha: 0.24 + glowStrength * 0.34)
      ..strokeWidth = 6.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
    canvas.drawPath(segmentPath, glowPaint);

    final strokePaint = Paint()
      ..color = pulseColor.withValues(alpha: 0.34 + glowStrength * 0.42)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(segmentPath, strokePaint);

    final tangent = metric.getTangentForOffset(
      headOffset.clamp(0.0, metric.length).toDouble(),
    );
    if (tangent == null) {
      return;
    }

    final haloPaint = Paint()
      ..color = pulseColor.withValues(alpha: 0.24 + glowStrength * 0.24)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 13.0);
    canvas.drawCircle(tangent.position, 10.5 + glowStrength * 4.6, haloPaint);

    final corePaint = Paint()
      ..color = pulseColor.withValues(alpha: 0.94)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(tangent.position, 3.2 + glowStrength * 1.8, corePaint);
  }

  @override
  bool shouldRepaint(covariant _NetworkLinkPainter oldDelegate) {
    return oldDelegate.focusNodeId != focusNodeId ||
        oldDelegate.nodes != nodes ||
        oldDelegate.edges != edges ||
        oldDelegate.pulseNodeId != pulseNodeId ||
        oldDelegate.pulseEdgeKey != pulseEdgeKey ||
        oldDelegate.pulseEdgeOrigin != pulseEdgeOrigin;
  }
}

String _graphEdgeKey(_GraphEdge edge) {
  return '${edge.from}|${edge.to}|${edge.type.name}|${edge.detail}';
}

Map<String, Offset> _graphNodeCenters(List<_GraphNode> nodes, Size size) {
  final positions = <String, Offset>{};

  for (final node in nodes) {
    final nodeSize = _graphNodeCardSize(node);
    final normalizedX = (node.position.x + 1) / 2;
    final normalizedY = (node.position.y + 1) / 2;
    positions[node.id] = Offset(
      (size.width - nodeSize.width) * normalizedX + (nodeSize.width / 2),
      (size.height - nodeSize.height) * normalizedY + (nodeSize.height / 2),
    );
  }

  return positions;
}

Path? _graphEdgePath(_GraphEdge edge, Map<String, Offset> positions) {
  final from = positions[edge.from];
  final to = positions[edge.to];
  if (from == null || to == null) {
    return null;
  }

  final controlX = (from.dx + to.dx) / 2;
  return Path()
    ..moveTo(from.dx, from.dy)
    ..quadraticBezierTo(controlX, (from.dy + to.dy) / 2, to.dx, to.dy);
}

_GraphEdgeHit? _nearestGraphEdgeHit({
  required Offset point,
  required List<_GraphNode> nodes,
  required List<_GraphEdge> edges,
  required Size canvasSize,
  double tolerance = 30,
}) {
  final positions = _graphNodeCenters(nodes, canvasSize);
  _GraphEdgeHit? bestHit;

  for (final edge in edges) {
    final path = _graphEdgePath(edge, positions);
    if (path == null) {
      continue;
    }

    final candidate = _closestPointOnPath(path, point);
    if (candidate == null || candidate.distance > tolerance) {
      continue;
    }

    if (bestHit == null || candidate.distance < bestHit.distance) {
      bestHit = _GraphEdgeHit(
        edge: edge,
        progress: candidate.progress,
        distance: candidate.distance,
      );
    }
  }

  return bestHit;
}

_GraphPathHit? _closestPointOnPath(Path path, Offset point) {
  _GraphPathHit? bestHit;

  for (final metric in path.computeMetrics()) {
    final sampleCount = max(24, (metric.length / 6).ceil());
    for (var sampleIndex = 0; sampleIndex <= sampleCount; sampleIndex++) {
      final offset = metric.length * (sampleIndex / sampleCount);
      final tangent = metric.getTangentForOffset(offset);
      if (tangent == null) {
        continue;
      }

      final distance = (tangent.position - point).distance;
      if (bestHit == null || distance < bestHit.distance) {
        bestHit = _GraphPathHit(
          progress: metric.length == 0 ? 0 : offset / metric.length,
          distance: distance,
        );
      }
    }
  }

  return bestHit;
}

class _GraphEdgeHit {
  const _GraphEdgeHit({
    required this.edge,
    required this.progress,
    required this.distance,
  });

  final _GraphEdge edge;
  final double progress;
  final double distance;
}

class _GraphPathHit {
  const _GraphPathHit({required this.progress, required this.distance});

  final double progress;
  final double distance;
}

void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
  for (final metric in path.computeMetrics()) {
    var distance = 0.0;
    const dash = 8.0;
    const gap = 6.0;

    while (distance < metric.length) {
      final next = distance + dash;
      canvas.drawPath(
        metric.extractPath(distance, next.clamp(0, metric.length).toDouble()),
        paint,
      );
      distance += dash + gap;
    }
  }
}
