part of '../../../../app/app.dart';

class _NetworkLinkPainter extends CustomPainter {
  _NetworkLinkPainter({
    required this.nodes,
    required this.edges,
    required this.focusNodeId,
  });

  final List<_GraphNode> nodes;
  final List<_GraphEdge> edges;
  final String focusNodeId;

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
    }
  }

  @override
  bool shouldRepaint(covariant _NetworkLinkPainter oldDelegate) {
    return oldDelegate.focusNodeId != focusNodeId ||
        oldDelegate.nodes != nodes ||
        oldDelegate.edges != edges;
  }
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
