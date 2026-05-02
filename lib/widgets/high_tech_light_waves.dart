import 'dart:math';

import 'package:flutter/material.dart';

class HighTechLightWaves extends StatefulWidget {
  const HighTechLightWaves({
    super.key,
    this.primaryColor = const Color(0xFF0F766E),
    this.accentColor = const Color(0xFFBF6B2D),
    this.numberOfWaves = 5,
    this.waveAmplitude = 0.15,
    this.waveFrequency = 0.05,
    this.waveSpeed = 0.005,
    this.pulseSpeedMultiplier = 2.0,
    this.pulseSize = 10.0,
    this.enablePointerInteraction = true,
  });

  final Color primaryColor;
  final Color accentColor;
  final int numberOfWaves;
  final double waveAmplitude;
  final double waveFrequency;
  final double waveSpeed;
  final double pulseSpeedMultiplier;
  final double pulseSize;
  final bool enablePointerInteraction;

  @override
  State<HighTechLightWaves> createState() => _HighTechLightWavesState();
}

class _HighTechLightWavesState extends State<HighTechLightWaves>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _hoverController;
  late final List<_WaveBundleData> _waves;
  final Random _random = Random(18);
  Offset _hoverPosition = const Offset(0.72, 0.70);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      reverseDuration: const Duration(milliseconds: 540),
    );

    _waves = List.generate(widget.numberOfWaves, (index) {
      final normalizedIndex = widget.numberOfWaves == 1
          ? 1.0
          : index / (widget.numberOfWaves - 1);
      final colorMix = index % 3 == 1
          ? 0.76
          : 0.08 + _random.nextDouble() * 0.16;

      return _WaveBundleData(
        depth: normalizedIndex,
        baseYOffset:
            0.42 + (normalizedIndex * 0.42) + (_random.nextDouble() * 0.04),
        amplitude:
            widget.waveAmplitude *
            (1.9 + _random.nextDouble() * 0.9) *
            (0.88 + normalizedIndex * 0.34),
        frequency:
            1.0 + widget.waveFrequency * (7.0 + _random.nextDouble() * 5.0),
        speed: widget.waveSpeed * (56.0 + _random.nextDouble() * 28.0),
        phase: _random.nextDouble() * 2 * pi,
        humpCenter: 0.28 + _random.nextDouble() * 0.42,
        humpWidth: 0.14 + _random.nextDouble() * 0.10,
        slope: -0.55 + _random.nextDouble() * 1.10,
        color: Color.lerp(widget.primaryColor, widget.accentColor, colorMix)!,
        strandCount: 4 + _random.nextInt(normalizedIndex > 0.6 ? 4 : 3),
        strandSpacing: 0.010 + _random.nextDouble() * 0.010,
        pulseOffset: _random.nextDouble(),
        pulseSpeed:
            widget.pulseSpeedMultiplier * (0.54 + _random.nextDouble() * 0.58),
      );
    });
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableSize = Size(
          constraints.hasBoundedWidth ? constraints.maxWidth : 0,
          constraints.hasBoundedHeight ? constraints.maxHeight : 0,
        );

        final painterChild = AnimatedBuilder(
          animation: Listenable.merge([_controller, _hoverController]),
          builder: (context, _) {
            return CustomPaint(
              painter: _HighTechLightWavesPainter(
                animationValue: _controller.value,
                waves: _waves,
                pulseSize: widget.pulseSize,
                interactionPosition: _hoverPosition,
                interactionStrength: Curves.easeOutCubic.transform(
                  _hoverController.value,
                ),
              ),
              child: const SizedBox.expand(),
            );
          },
        );

        if (!widget.enablePointerInteraction) {
          return painterChild;
        }

        return MouseRegion(
          opaque: false,
          onEnter: (event) {
            _updateHoverPosition(event.localPosition, availableSize);
            _hoverController.forward();
          },
          onHover: (event) {
            _updateHoverPosition(event.localPosition, availableSize);
            if (_hoverController.status != AnimationStatus.forward &&
                _hoverController.value < 1) {
              _hoverController.forward();
            }
          },
          onExit: (_) {
            _hoverController.reverse();
          },
          child: painterChild,
        );
      },
    );
  }

  void _updateHoverPosition(Offset localPosition, Size availableSize) {
    if (availableSize.width <= 0 || availableSize.height <= 0) {
      return;
    }

    final next = Offset(
      (localPosition.dx / availableSize.width).clamp(0.0, 1.0),
      (localPosition.dy / availableSize.height).clamp(0.0, 1.0),
    );

    if ((next.dx - _hoverPosition.dx).abs() < 0.003 &&
        (next.dy - _hoverPosition.dy).abs() < 0.003) {
      return;
    }

    _hoverPosition = next;
  }
}

class _WaveBundleData {
  _WaveBundleData({
    required this.depth,
    required this.baseYOffset,
    required this.amplitude,
    required this.frequency,
    required this.speed,
    required this.phase,
    required this.humpCenter,
    required this.humpWidth,
    required this.slope,
    required this.color,
    required this.strandCount,
    required this.strandSpacing,
    required this.pulseOffset,
    required this.pulseSpeed,
  });

  final double depth;
  final double baseYOffset;
  final double amplitude;
  final double frequency;
  final double speed;
  final double phase;
  final double humpCenter;
  final double humpWidth;
  final double slope;
  final Color color;
  final int strandCount;
  final double strandSpacing;
  final double pulseOffset;
  final double pulseSpeed;
}

class _HighTechLightWavesPainter extends CustomPainter {
  _HighTechLightWavesPainter({
    required this.animationValue,
    required this.waves,
    required this.pulseSize,
    required this.interactionPosition,
    required this.interactionStrength,
  });

  final double animationValue;
  final List<_WaveBundleData> waves;
  final double pulseSize;
  final Offset interactionPosition;
  final double interactionStrength;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pulsePaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18.0);

    final sortedWaves = [...waves]
      ..sort((left, right) {
        return left.depth.compareTo(right.depth);
      });

    for (final wave in sortedWaves) {
      _paintBundle(
        canvas,
        size,
        wave,
        linePaint: linePaint,
        glowPaint: glowPaint,
        pulsePaint: pulsePaint,
      );
    }
  }

  void _paintBundle(
    Canvas canvas,
    Size size,
    _WaveBundleData wave, {
    required Paint linePaint,
    required Paint glowPaint,
    required Paint pulsePaint,
  }) {
    final centerIndex = (wave.strandCount - 1) / 2;
    Path? highlightPath;

    for (var strandIndex = 0; strandIndex < wave.strandCount; strandIndex++) {
      final distanceFromCenter = strandIndex - centerIndex;
      final normalizedDistance = centerIndex == 0
          ? 0.0
          : distanceFromCenter.abs() / centerIndex;
      final strandOffset =
          distanceFromCenter *
          size.height *
          wave.strandSpacing *
          (1.08 - wave.depth * 0.28);
      final strandPath = _buildWavePath(
        size,
        wave,
        strandOffset: strandOffset,
        phaseShift: distanceFromCenter * 0.028,
      );
      final intensity = 1.0 - (normalizedDistance * 0.34);
      final interactionBoost =
          1 + (interactionStrength * (1.0 - normalizedDistance) * 0.20);
      final lineAlpha =
          (0.08 + wave.depth * 0.20) * intensity * interactionBoost;
      final glowAlpha =
          (0.05 + wave.depth * 0.14) * intensity * interactionBoost;
      final strokeWidth =
          0.70 + (wave.depth * 0.72) + ((1.0 - normalizedDistance) * 0.28);

      glowPaint
        ..color = wave.color.withValues(alpha: glowAlpha.clamp(0.0, 0.42))
        ..strokeWidth = strokeWidth + 0.90 + (interactionStrength * 0.35)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          2.8 + (wave.depth * 3.8) + (interactionStrength * 1.8),
        );
      canvas.drawPath(strandPath, glowPaint);

      linePaint
        ..color = wave.color.withValues(alpha: lineAlpha.clamp(0.0, 0.36))
        ..strokeWidth = strokeWidth;
      canvas.drawPath(strandPath, linePaint);

      if (normalizedDistance < 0.25) {
        linePaint
          ..color = Color.lerp(wave.color, Colors.white, 0.22)!.withValues(
            alpha: (0.14 + wave.depth * 0.18 + interactionStrength * 0.06)
                .clamp(0.0, 0.42),
          )
          ..strokeWidth = max(0.95, strokeWidth * 0.68);
        canvas.drawPath(strandPath, linePaint);
      }

      if (distanceFromCenter.abs() < 0.51) {
        highlightPath = strandPath;
      }
    }

    if (highlightPath == null) {
      return;
    }

    _paintPulseRun(
      canvas,
      size,
      wave,
      highlightPath,
      glowPaint: glowPaint,
      pulsePaint: pulsePaint,
    );
  }

  Path _buildWavePath(
    Size size,
    _WaveBundleData wave, {
    required double strandOffset,
    required double phaseShift,
  }) {
    final path = Path();
    const sampleCount = 112;
    final drift = animationValue * 2 * pi * wave.speed;

    for (var sample = 0; sample <= sampleCount; sample++) {
      final progress = sample / sampleCount;
      final x = size.width * progress;
      final crest =
          exp(
            -pow((progress - wave.humpCenter) / wave.humpWidth, 2).toDouble(),
          ).toDouble() *
          size.height *
          wave.amplitude *
          (1.18 + wave.depth * 0.72);
      final secondaryCrest =
          exp(
            -pow(
              (progress - (wave.humpCenter + 0.18)) / (wave.humpWidth * 1.35),
              2,
            ).toDouble(),
          ).toDouble() *
          size.height *
          wave.amplitude *
          0.24;
      final sweep =
          sin(
            progress * wave.frequency * 2 * pi +
                wave.phase +
                drift +
                phaseShift,
          ) *
          size.height *
          wave.amplitude *
          0.22;
      final tail =
          cos(
            progress * wave.frequency * pi +
                (wave.phase * 0.55) -
                (drift * 0.42) +
                phaseShift,
          ) *
          size.height *
          wave.amplitude *
          0.08;
      final hoverReach = 0.10 + (wave.depth * 0.09);
      final hoverEnvelope = interactionStrength <= 0
          ? 0.0
          : exp(
              -pow(
                (progress - interactionPosition.dx) / hoverReach,
                2,
              ).toDouble(),
            ).toDouble();
      final hoverLift =
          hoverEnvelope *
          interactionStrength *
          size.height *
          (0.018 + wave.depth * 0.014) *
          (1.08 - interactionPosition.dy * 0.55);
      final hoverShear =
          hoverEnvelope *
          interactionStrength *
          (progress - interactionPosition.dx) *
          size.height *
          0.06 *
          (0.72 + wave.depth * 0.28);
      final hoverBreath =
          sin((animationValue * 2 * pi) + wave.phase) *
          hoverEnvelope *
          interactionStrength *
          size.height *
          0.006;
      final lean = (progress - 0.5) * wave.slope * size.height * 0.14;
      final y =
          (size.height * wave.baseYOffset) -
          crest -
          secondaryCrest +
          sweep +
          tail +
          lean -
          hoverLift +
          hoverShear +
          hoverBreath +
          strandOffset;

      if (sample == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    return path;
  }

  void _paintPulseRun(
    Canvas canvas,
    Size size,
    _WaveBundleData wave,
    Path path, {
    required Paint glowPaint,
    required Paint pulsePaint,
  }) {
    final metricIterator = path.computeMetrics().iterator;
    if (!metricIterator.moveNext()) {
      return;
    }
    final metric = metricIterator.current;
    final pulseRuns = wave.depth > 0.55 ? 2 : 1;

    for (var pulseIndex = 0; pulseIndex < pulseRuns; pulseIndex++) {
      final cadence =
          (0.42 + wave.depth * 0.36 + wave.pulseSpeed * 0.14) +
          (pulseIndex * 0.18);
      final cycle =
          (animationValue * cadence + wave.pulseOffset + pulseIndex * 0.36) %
          1.0;
      final activeWindow = 0.16 + ((1.0 - wave.depth) * 0.05);
      if (cycle > activeWindow) {
        continue;
      }

      final travel = Curves.easeInOutCubic.transform(cycle / activeWindow);
      final strength = 0.42 + (sin(travel * pi) * 0.58);
      final offset = metric.length * travel;
      final tangent = metric.getTangentForOffset(offset);
      if (tangent == null) {
        continue;
      }

      final interactionBoost = interactionStrength <= 0
          ? 0.0
          : (1 - ((travel - interactionPosition.dx).abs() / 0.24)).clamp(
                  0.0,
                  1.0,
                ) *
                interactionStrength;
      final segmentLength =
          size.width *
          (0.028 + wave.depth * 0.016) *
          strength *
          (1 + interactionBoost * 0.32);
      final segmentPath = metric.extractPath(
        max(0.0, offset - segmentLength),
        min(metric.length, offset + (segmentLength * 0.24)),
      );
      final pulseColor = Color.lerp(
        wave.color,
        Colors.white,
        0.30 + interactionBoost * 0.12,
      )!;

      glowPaint
        ..color = pulseColor.withValues(
          alpha: 0.18 + wave.depth * 0.28 + interactionBoost * 0.10,
        )
        ..strokeWidth = 2.1 + wave.depth * 1.9 + interactionBoost * 0.8
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          5.0 + wave.depth * 5.0 + interactionBoost * 2.4,
        );
      canvas.drawPath(segmentPath, glowPaint);

      pulsePaint.color = pulseColor.withValues(
        alpha: 0.36 + strength * 0.26 + interactionBoost * 0.08,
      );
      canvas.drawCircle(
        tangent.position,
        pulseSize *
            (0.95 + wave.depth * 0.35) *
            strength *
            (1 + interactionBoost * 0.18),
        pulsePaint,
      );

      final corePaint = Paint()
        ..color = pulseColor.withValues(alpha: 0.94)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        tangent.position,
        max(
          1.6,
          pulseSize *
              0.20 *
              (0.9 + wave.depth * 0.24) *
              (1 + interactionBoost * 0.12),
        ),
        corePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HighTechLightWavesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.waves != waves ||
        oldDelegate.pulseSize != pulseSize ||
        oldDelegate.interactionPosition != interactionPosition ||
        oldDelegate.interactionStrength != interactionStrength;
  }
}
