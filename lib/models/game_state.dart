import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'path_model.dart';

enum GameStatus { playing, victory, defeat }

class GameState extends ChangeNotifier {
  int currentLevel = 65;
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
            const GridPoint(2, 0), // exits Up
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
    // Dynamically scale grid size based on level
    if (level < 5) {
      gridWidth = 4;
      gridHeight = 5;
    } else if (level < 15) {
      gridWidth = 5;
      gridHeight = 6;
    } else if (level < 30) {
      gridWidth = 6;
      gridHeight = 8;
    } else if (level < 60) {
      gridWidth = 8;
      gridHeight = 10;
    } else {
      // Extremely hard levels! Scaling up to a highly winding maze
      gridWidth = 9;
      gridHeight = 11;
    }

    paths = [];
    final occupied = <GridPoint>{};

    // Number of paths scales with level
    int pathCount = 3 + (level ~/ 5);
    if (pathCount > 24) pathCount = 24; // Cap for layout space

    // Max length of each path scales with level
    int minLen = 3;
    int maxLen = 3 + (level ~/ 12);
    if (maxLen > 9) maxLen = 9; // Cap path length to prevent locking

    final rand = math.Random(level * 31); // Seeded random for deterministic level design

    // Curated high quality colors for paths
    List<Color> colors = [
      Colors.redAccent,
      Colors.blueAccent,
      Colors.greenAccent[700]!,
      Colors.orangeAccent[700]!,
      Colors.purpleAccent,
      Colors.teal,
      Colors.pinkAccent,
      Colors.indigoAccent,
      Colors.amber[800]!,
      Colors.cyan[800]!,
      Colors.deepOrange,
      Colors.lime[900]!,
    ];

    // Generate paths using reverse slide-in method (guarantees solvability)
    for (int pIdx = 0; pIdx < pathCount; pIdx++) {
      // Get all unoccupied boundary points
      List<GridPoint> boundaryPoints = [];
      for (int x = 0; x < gridWidth; x++) {
        if (!occupied.contains(GridPoint(x, 0))) boundaryPoints.add(GridPoint(x, 0));
        if (!occupied.contains(GridPoint(x, gridHeight - 1))) boundaryPoints.add(GridPoint(x, gridHeight - 1));
      }
      for (int y = 0; y < gridHeight; y++) {
        if (!occupied.contains(GridPoint(0, y))) boundaryPoints.add(GridPoint(0, y));
        if (!occupied.contains(GridPoint(gridWidth - 1, y))) boundaryPoints.add(GridPoint(gridWidth - 1, y));
      }

      if (boundaryPoints.isEmpty) break;
      GridPoint start = boundaryPoints[rand.nextInt(boundaryPoints.length)];

      List<GridPoint> pathPts = [start];
      occupied.add(start);

      int targetLen = minLen + rand.nextInt(maxLen - minLen + 1);
      GridPoint current = start;

      for (int l = 1; l < targetLen; l++) {
        List<GridPoint> neighbors = [];
        List<GridPoint> dirs = [
          const GridPoint(1, 0),
          const GridPoint(-1, 0),
          const GridPoint(0, 1),
          const GridPoint(0, -1),
        ];

        for (var d in dirs) {
          GridPoint n = current + d;
          if (n.x >= 0 && n.x < gridWidth && n.y >= 0 && n.y < gridHeight) {
            if (!occupied.contains(n)) {
              neighbors.add(n);
            }
          }
        }

        if (neighbors.isEmpty) break;

        // Choose a random neighbor to continue path
        GridPoint next = neighbors[rand.nextInt(neighbors.length)];
        pathPts.add(next);
        occupied.add(next);
        current = next;
      }

      if (pathPts.length >= 2) {
        // Reverse because we generated from Head to Tail
        List<GridPoint> pointsFromTailToHead = pathPts.reversed.toList();

        paths.add(PathModel(
          id: 'gen_$level\_$pIdx',
          points: pointsFromTailToHead,
          color: colors[pIdx % colors.length],
        ));
      }
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
