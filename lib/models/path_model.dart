import 'package:flutter/material.dart';

enum PathState { idle, slidingOut, bumping }

class GridPoint {
  final int x;
  final int y;

  const GridPoint(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridPoint && runtimeType == other.runtimeType && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  GridPoint operator +(GridPoint other) => GridPoint(x + other.x, y + other.y);
  GridPoint operator -(GridPoint other) => GridPoint(x - other.x, y - other.y);
  GridPoint operator *(int scalar) => GridPoint(x * scalar, y * scalar);

  @override
  String toString() => '($x, $y)';
}

class PathModel {
  final String id;
  final List<GridPoint> points; // From Tail (index 0) to Head (index N-1)
  final Color color;
  
  // Animation state
  PathState state;
  double slideProgress; // 0.0 to points.length + grid size (for exit)
  double bumpProgress;  // 0.0 to 1.0 back to 0.0
  GridPoint? collisionPoint;

  PathModel({
    required this.id,
    required this.points,
    required this.color,
    this.state = PathState.idle,
    this.slideProgress = 0.0,
    this.bumpProgress = 0.0,
    this.collisionPoint,
  });

  int get length => points.length;
  GridPoint get head => points.last;
  GridPoint get tail => points.first;

  // The direction the head is facing/exiting
  GridPoint get exitDirection {
    if (points.length < 2) return const GridPoint(1, 0);
    final last = points[points.length - 1];
    final prev = points[points.length - 2];
    return GridPoint(last.x - prev.x, last.y - prev.y);
  }

  // Returns list of all cells currently occupied by this path
  List<GridPoint> getOccupiedCells() {
    if (state == PathState.slidingOut) {
      // While sliding out, cells before the slide progress are freed
      List<GridPoint> occupied = [];
      for (int i = 0; i < points.length; i++) {
        if (i >= slideProgress) {
          occupied.add(getSegmentPosition(i, slideProgress));
        }
      }
      return occupied;
    }
    // Idle or bumping paths occupy all their points
    return points;
  }

  // Calculate the position of a segment at index `i` with current slide progress
  GridPoint getSegmentPosition(int index, double progress) {
    double x = index + progress;
    if (x < points.length - 1) {
      // Interpolate along the points
      int idx1 = x.floor();
      int idx2 = x.ceil();
      double t = x - idx1;
      final p1 = points[idx1];
      final p2 = points[idx2];
      return GridPoint(
        (p1.x + (p2.x - p1.x) * t).round(),
        (p1.y + (p2.y - p1.y) * t).round(),
      );
    } else {
      // Head has exited the path, moves straight in exit direction
      final dir = exitDirection;
      double overflow = x - (points.length - 1);
      return GridPoint(
        (head.x + dir.x * overflow).round(),
        (head.y + dir.y * overflow).round(),
      );
    }
  }

  // Accurate double version for drawing interpolation
  Offset getSegmentOffset(int index, double progress, double cellSize) {
    double x = index + progress;
    if (x < points.length - 1) {
      int idx1 = x.floor();
      int idx2 = x.ceil();
      double t = x - idx1;
      final p1 = points[idx1];
      final p2 = points[idx2];
      
      double doubleX = p1.x + (p2.x - p1.x) * t;
      double doubleY = p1.y + (p2.y - p1.y) * t;
      return Offset(doubleX * cellSize + cellSize / 2, doubleY * cellSize + cellSize / 2);
    } else {
      final dir = exitDirection;
      double overflow = x - (points.length - 1);
      double doubleX = head.x + dir.x * overflow;
      double doubleY = head.y + dir.y * overflow;
      return Offset(doubleX * cellSize + cellSize / 2, doubleY * cellSize + cellSize / 2);
    }
  }

  PathModel copyWith({
    PathState? state,
    double? slideProgress,
    double? bumpProgress,
    GridPoint? collisionPoint,
  }) {
    return PathModel(
      id: id,
      points: points,
      color: color,
      state: state ?? this.state,
      slideProgress: slideProgress ?? this.slideProgress,
      bumpProgress: bumpProgress ?? this.bumpProgress,
      collisionPoint: collisionPoint ?? this.collisionPoint,
    );
  }
}
