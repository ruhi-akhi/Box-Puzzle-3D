import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/path_model.dart';

class BoardPainter extends CustomPainter {
  final List<PathModel> paths;
  final int gridWidth;
  final int gridHeight;
  final String skin; // 'classic' or 'worms'

  BoardPainter({
    required this.paths,
    required this.gridWidth,
    required this.gridHeight,
    required this.skin,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double cellSize = size.width / gridWidth;

    _paintDottedBackground(canvas, size);

    // Draw each path
    for (var path in paths) {
      // Calculate slide offsets and animation modifiers
      double slide = path.slideProgress;
      double bump = path.bumpProgress;

      // Handle Bump/Shake Offset
      Offset bumpOffset = Offset.zero;
      if (path.state == PathState.bumping && path.collisionPoint != null) {
        final dir = path.exitDirection;
        // Bump moves forward slightly and then bounces back
        double amount = math.sin(bump * math.pi) * 0.25;
        bumpOffset = Offset(dir.x * amount * cellSize, dir.y * amount * cellSize);
      }

      if (skin == 'worms') {
        _paintWorm(canvas, path, slide, cellSize, bumpOffset);
      } else {
        _paintClassicArrow(canvas, path, slide, cellSize, bumpOffset);
      }
    }
  }

  void _paintDottedBackground(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = (skin == 'worms' ? const Color(0xFF81C784) : const Color(0xFF6D4C41))
          .withOpacity(0.22)
      ..style = PaintingStyle.fill;

    const double spacing = 12.0;
    const double dotRadius = 0.9;

    for (double y = spacing / 2; y < size.height; y += spacing) {
      for (double x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
      }
    }
  }

  void _paintWorm(Canvas canvas, PathModel path, double slide, double cellSize, Offset bumpOffset) {
    int startIdx = slide.floor();
    if (startIdx >= path.length) return;

    // Draw Worm Body segments (from tail to head)
    double bodyRadius = cellSize * 0.38;

    for (int i = startIdx; i < path.length; i++) {
      // Interpolated position for segment `i`
      Offset pos = path.getSegmentOffset(i, slide, cellSize) + bumpOffset;

      // Draw segment shadow/border
      final shadowPaint = Paint()..color = Colors.black.withOpacity(0.15);
      canvas.drawCircle(pos + const Offset(1, 2), bodyRadius, shadowPaint);

      // Draw segment body
      final bodyPaint = Paint()
        ..color = path.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, bodyRadius, bodyPaint);

      // Draw lighter highlights inside segments to make them look 3D/glossy
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos - Offset(bodyRadius * 0.25, bodyRadius * 0.25), bodyRadius * 0.35, highlightPaint);

      // If it's the head segment, draw cute eyes!
      if (i == path.length - 1) {
        _drawWormEyes(canvas, pos, path.exitDirection, bodyRadius);
      }
    }
  }

  void _drawWormEyes(Canvas canvas, Offset headPos, GridPoint direction, double headRadius) {
    // Determine eye offsets based on movement direction
    Offset eyeOffset1 = Offset.zero;
    Offset eyeOffset2 = Offset.zero;

    double offsetMultiplier = headRadius * 0.4;
    double eyeSize = headRadius * 0.3;
    double pupilSize = eyeSize * 0.5;

    if (direction.x > 0) {
      // Moving Right
      eyeOffset1 = Offset(offsetMultiplier, -offsetMultiplier);
      eyeOffset2 = Offset(offsetMultiplier, offsetMultiplier);
    } else if (direction.x < 0) {
      // Moving Left
      eyeOffset1 = Offset(-offsetMultiplier, -offsetMultiplier);
      eyeOffset2 = Offset(-offsetMultiplier, offsetMultiplier);
    } else if (direction.y > 0) {
      // Moving Down
      eyeOffset1 = Offset(-offsetMultiplier, offsetMultiplier);
      eyeOffset2 = Offset(offsetMultiplier, offsetMultiplier);
    } else {
      // Moving Up (default)
      eyeOffset1 = Offset(-offsetMultiplier, -offsetMultiplier);
      eyeOffset2 = Offset(offsetMultiplier, -offsetMultiplier);
    }

    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final pupilPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Draw Whites of eyes
    canvas.drawCircle(headPos + eyeOffset1, eyeSize, eyePaint);
    canvas.drawCircle(headPos + eyeOffset2, eyeSize, eyePaint);

    // Draw Pupils (slightly looking in the direction of movement)
    Offset pupilLook = Offset(direction.x.toDouble(), direction.y.toDouble()) * (eyeSize * 0.25);
    canvas.drawCircle(headPos + eyeOffset1 + pupilLook, pupilSize, pupilPaint);
    canvas.drawCircle(headPos + eyeOffset2 + pupilLook, pupilSize, pupilPaint);
  }

  void _paintClassicArrow(Canvas canvas, PathModel path, double slide, double cellSize, Offset bumpOffset) {
    int startIdx = slide.floor();
    if (startIdx >= path.length) return;

    // Draw each snake with a shadow underneath so the trail reads as a
    // single connected 3D ribbon resting on the board.
    for (int i = startIdx; i < path.length; i++) {
      Offset center = path.getSegmentOffset(i, slide, cellSize) + bumpOffset;

      GridPoint dir;
      if (i < path.length - 1) {
        final cur = path.points[i];
        final nxt = path.points[i + 1];
        dir = GridPoint(nxt.x - cur.x, nxt.y - cur.y);
      } else {
        dir = path.exitDirection;
      }

      _drawFilledArrow(canvas, center + const Offset(1, 2), dir, Colors.black.withOpacity(0.15), cellSize);
      _drawFilledArrow(canvas, center, dir, path.color, cellSize);
    }
  }

  // Draws a filled arrow that fills its own cell and reaches into the
  // neighbouring cell, so consecutive pieces of the same snake chain
  // together with no visible gap between them.
  void _drawFilledArrow(Canvas canvas, Offset center, GridPoint direction, Color color, double cellSize) {
    final f = Offset(direction.x.toDouble(), direction.y.toDouble());
    final s = Offset(-f.dy, f.dx);

    // Overshoot the cell boundary by ~6% so abutting arrows overlap and
    // anti-aliasing never leaves a hairline gap between pieces.
    final double total = cellSize * 0.53;
    final double headLen = cellSize * 0.42;
    final double bodyHalfW = cellSize * 0.22;
    final double headHalfW = cellSize * 0.30;

    final Offset rearPos = center - f * total;
    final Offset frontPos = center + f * (total - headLen);
    final Offset tip = center + f * total;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(rearPos.dx + s.dx * bodyHalfW, rearPos.dy + s.dy * bodyHalfW)
      ..lineTo(rearPos.dx - s.dx * bodyHalfW, rearPos.dy - s.dy * bodyHalfW)
      ..lineTo(frontPos.dx - s.dx * headHalfW, frontPos.dy - s.dy * headHalfW)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(frontPos.dx + s.dx * headHalfW, frontPos.dy + s.dy * headHalfW)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) => true;
}
