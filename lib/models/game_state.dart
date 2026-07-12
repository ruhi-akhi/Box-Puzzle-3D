import 'dart:async';
import 'package:flutter/material.dart';
import 'path_model.dart';

enum GameStatus { playing, victory, defeat }

class GameState extends ChangeNotifier {
  int currentLevel = 1;
  int lives = 3;
  final int maxLives = 3;
  String currentSkin = 'worms'; // 'classic' or 'worms'
  GameStatus status = GameStatus.playing;

  int gridWidth = 6;
  int gridHeight = 8;
  List<PathModel> paths = [];
  bool isAnimating = false;

  GameState() {
    loadLevel(currentLevel);
  }

  void setSkin(String skin) {
    currentSkin = skin;
    notifyListeners();
  }

  void nextLevel() {
    currentLevel++;
    loadLevel(currentLevel);
  }

  void restartLevel() {
    loadLevel(currentLevel);
  }

  // Load a level configuration
  void loadLevel(int level) {
    status = GameStatus.playing;
    lives = maxLives;
    isAnimating = false;

    // We define some handcrafted levels, and generate procedurally for high levels
    if (level == 1) {
      gridWidth = 4;
      gridHeight = 4;
      paths = [
        PathModel(
          id: '1',
          color: Colors.red,
          points: [
            const GridPoint(0, 1),
            const GridPoint(1, 1),
            const GridPoint(2, 1),
            const GridPoint(3, 1), // exits Right
          ],
        ),
        PathModel(
          id: '2',
          color: Colors.blue,
          points: [
            const GridPoint(2, 3),
            const GridPoint(2, 2),
            const GridPoint(2, 1),
            const GridPoint(2, 0), // exits Up (blocks 1 if 1 moves first)
          ],
        ),
      ];
    } else if (level == 2) {
      gridWidth = 4;
      gridHeight = 5;
      paths = [
        PathModel(
          id: '1',
          color: Colors.purple,
          points: [
            const GridPoint(0, 1),
            const GridPoint(1, 1),
            const GridPoint(2, 1),
            const GridPoint(2, 0), // Up
          ],
        ),
        PathModel(
          id: '2',
          color: Colors.orange,
          points: [
            const GridPoint(3, 3),
            const GridPoint(2, 3),
            const GridPoint(1, 3),
            const GridPoint(1, 4), // Down
          ],
        ),
        PathModel(
          id: '3',
          color: Colors.green,
          points: [
            const GridPoint(0, 2),
            const GridPoint(1, 2),
            const GridPoint(2, 2),
            const GridPoint(3, 2), // Right
          ],
        ),
      ];
    } else if (level == 3) {
      gridWidth = 5;
      gridHeight = 6;
      paths = [
        PathModel(
          id: '1',
          color: Colors.red,
          points: [
            const GridPoint(0, 0),
            const GridPoint(1, 0),
            const GridPoint(1, 1),
            const GridPoint(1, 2),
            const GridPoint(0, 2), // Left
          ],
        ),
        PathModel(
          id: '2',
          color: Colors.blue,
          points: [
            const GridPoint(4, 5),
            const GridPoint(3, 5),
            const GridPoint(2, 5),
            const GridPoint(2, 4),
            const GridPoint(2, 3),
            const GridPoint(1, 3), // Left
          ],
        ),
        PathModel(
          id: '3',
          color: Colors.amber,
          points: [
            const GridPoint(3, 1),
            const GridPoint(3, 2),
            const GridPoint(3, 3),
            const GridPoint(4, 3), // Right
          ],
        ),
        PathModel(
          id: '4',
          color: Colors.green,
          points: [
            const GridPoint(4, 0),
            const GridPoint(4, 1),
            const GridPoint(4, 2),
            const GridPoint(4, 3),
            const GridPoint(4, 4), // Down
          ],
        ),
      ];
    } else {
      // Procedural level generation for endless levels
      generateProceduralLevel(level);
    }
    notifyListeners();
  }

  void generateProceduralLevel(int level) {
    gridWidth = 6;
    gridHeight = 8;
    paths = [];

    // Let's create a few hardcoded paths for higher levels so it's guaranteed solvable and fun
    // Level 6/Spring Battle theme-like winding paths
    if (level % 2 == 0) {
      paths = [
        PathModel(
          id: 'p1',
          color: Colors.red,
          points: [
            const GridPoint(1, 1),
            const GridPoint(1, 2),
            const GridPoint(2, 2),
            const GridPoint(2, 1),
            const GridPoint(3, 1),
            const GridPoint(4, 1),
            const GridPoint(4, 0), // Up
          ],
        ),
        PathModel(
          id: 'p2',
          color: Colors.blue,
          points: [
            const GridPoint(0, 4),
            const GridPoint(1, 4),
            const GridPoint(1, 3),
            const GridPoint(2, 3),
            const GridPoint(3, 3),
            const GridPoint(3, 4),
            const GridPoint(3, 5), // Down
          ],
        ),
        PathModel(
          id: 'p3',
          color: Colors.green,
          points: [
            const GridPoint(5, 5),
            const GridPoint(4, 5),
            const GridPoint(4, 4),
            const GridPoint(4, 3),
            const GridPoint(5, 3), // Right
          ],
        ),
        PathModel(
          id: 'p4',
          color: Colors.purple,
          points: [
            const GridPoint(2, 6),
            const GridPoint(2, 5),
            const GridPoint(1, 5),
            const GridPoint(0, 5), // Left
          ],
        ),
        PathModel(
          id: 'p5',
          color: Colors.orange,
          points: [
            const GridPoint(0, 0),
            const GridPoint(1, 0),
            const GridPoint(2, 0),
            const GridPoint(3, 0), // Right
          ],
        ),
      ];
    } else {
      // Winding maze of arrows
      paths = [
        PathModel(
          id: 'w1',
          color: Colors.teal,
          points: [
            const GridPoint(1, 0),
            const GridPoint(1, 1),
            const GridPoint(1, 2),
            const GridPoint(2, 2),
            const GridPoint(3, 2),
            const GridPoint(3, 1),
            const GridPoint(3, 0), // Up
          ],
        ),
        PathModel(
          id: 'w2',
          color: Colors.pink,
          points: [
            const GridPoint(4, 4),
            const GridPoint(3, 4),
            const GridPoint(2, 4),
            const GridPoint(1, 4),
            const GridPoint(0, 4), // Left
          ],
        ),
        PathModel(
          id: 'w3',
          color: Colors.indigo,
          points: [
            const GridPoint(2, 5),
            const GridPoint(3, 5),
            const GridPoint(4, 5),
            const GridPoint(5, 5), // Right
          ],
        ),
        PathModel(
          id: 'w4',
          color: Colors.amber,
          points: [
            const GridPoint(0, 2),
            const GridPoint(0, 3),
            const GridPoint(1, 3),
            const GridPoint(2, 3),
            const GridPoint(2, 2), // Up
          ],
        ),
      ];
    }
  }

  // Find if a tap hit a segment of any path
  PathModel? findPathAt(GridPoint point) {
    for (var path in paths) {
      if (path.state == PathState.idle) {
        if (path.getOccupiedCells().contains(point)) {
          return path;
        }
      }
    }
    return null;
  }

  // Trigger path sliding or bumping
  void handleTap(GridPoint point) {
    if (isAnimating || status != GameStatus.playing) return;

    final path = findPathAt(point);
    if (path == null) return;

    // Check collision along exit trajectory
    final exitDir = path.exitDirection;
    final otherOccupied = <GridPoint>{};
    for (var p in paths) {
      if (p.id != path.id) {
        otherOccupied.addAll(p.getOccupiedCells());
      }
    }

    GridPoint? collisionPt;
    GridPoint current = path.head + exitDir;

    // Trace exit line to find if anything is blocking
    while (current.x >= 0 && current.x < gridWidth && current.y >= 0 && current.y < gridHeight) {
      if (otherOccupied.contains(current)) {
        collisionPt = current;
        break;
      }
      current = current + exitDir;
    }

    isAnimating = true;

    if (collisionPt != null) {
      // Path is blocked! Play bump/shake animation
      path.state = PathState.bumping;
      path.collisionPoint = collisionPt;
      path.bumpProgress = 0.0;
      notifyListeners();

      Timer.periodic(const Duration(milliseconds: 16), (timer) {
        if (path.bumpProgress >= 1.0) {
          timer.cancel();
          path.state = PathState.idle;
          path.bumpProgress = 0.0;
          path.collisionPoint = null;
          isAnimating = false;
          
          // Deduct life
          lives--;
          if (lives <= 0) {
            status = GameStatus.defeat;
          }
          notifyListeners();
        } else {
          path.bumpProgress += 0.08;
          notifyListeners();
        }
      });
    } else {
      // Path is clear! Slide out completely
      path.state = PathState.slidingOut;
      path.slideProgress = 0.0;
      notifyListeners();

      // Total steps is path length + max grid dimension to fully clear screen
      final double totalTarget = (path.length + (gridWidth > gridHeight ? gridWidth : gridHeight)).toDouble() + 2;

      Timer.periodic(const Duration(milliseconds: 16), (timer) {
        if (path.slideProgress >= totalTarget) {
          timer.cancel();
          paths.remove(path);
          isAnimating = false;

          // Check Win Condition
          if (paths.isEmpty) {
            status = GameStatus.victory;
          }
          notifyListeners();
        } else {
          path.slideProgress += 0.25;
          notifyListeners();
        }
      });
    }
  }
}
