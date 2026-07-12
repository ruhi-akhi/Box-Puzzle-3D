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

    // Draw Board Background Grid Lines
    final gridPaint = Paint()
      ..color = skin == 'worms'
          ? const Color(0xFF81C784).withOpacity(0.3)
          : const Color(0xFFD7CCC8).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i <= gridWidth; i++) {
      canvas.drawLine(Offset(i * cellSize, 0), Offset(i * cellSize, size.height), gridPaint);
    }
    for (int j = 0; j <= gridHeight; j++) {
      canvas.drawLine(Offset(0, j * cellSize), Offset(size.width, j * cellSize), gridPaint);
    }

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

    final linePaint = Paint()
      ..color = const Color(0xFF6D4C41) // Dark elegant brown
      ..style = PaintingStyle.stroke
      ..strokeWidth = cellSize * 0.16
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pathObj = Path();
    bool started = false;

    for (int i = startIdx; i < path.length; i++) {
      Offset pos = path.getSegmentOffset(i, slide, cellSize) + bumpOffset;
      if (!started) {
        pathObj.moveTo(pos.dx, pos.dy);
        started = true;
      } else {
        pathObj.lineTo(pos.dx, pos.dy);
      }
    }

    // Draw the main line
    canvas.drawPath(pathObj, linePaint);

    // Draw arrowhead at the head
    Offset headPos = path.getSegmentOffset(path.length - 1, slide, cellSize) + bumpOffset;
    _drawArrowHead(canvas, headPos, path.exitDirection, cellSize);
  }

  void _drawArrowHead(Canvas canvas, Offset headPos, GridPoint direction, double cellSize) {
    final arrowPaint = Paint()
      ..color = const Color(0xFF6D4C41)
      ..style = PaintingStyle.fill;

    double angle = 0.0;
    if (direction.x > 0) angle = 0.0;
    if (direction.x < 0) angle = math.pi;
    if (direction.y > 0) angle = math.pi / 2;
    if (direction.y < 0) angle = -math.pi / 2;

    double arrowSize = cellSize * 0.22;

    canvas.save();
    canvas.translate(headPos.dx, headPos.dy);
    canvas.rotate(angle);

    final path = Path()
      ..moveTo(arrowSize * 1.2, 0)
      ..lineTo(0, -arrowSize)
      ..lineTo(0, arrowSize)
      ..close();

    canvas.drawPath(path, arrowPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) => true;
}
