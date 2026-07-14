import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'path_model.dart';

enum GameStatus { playing, victory, defeat }

class GameState extends ChangeNotifier {
  int currentLevel = 1;
  int lives = 3;
  final int maxLives = 3;
  String currentSkin = 'classic'; // 'classic' or 'worms'
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

    // Use the same procedural generation process for every level so the board
    // evolves naturally from easy to hard.
    generateProceduralLevel(level);
    notifyListeners();
  }

  void generateProceduralLevel(int level) {
    // Dynamically scale grid size based on level.
    if (level == 1) {
      gridWidth = 4;
      gridHeight = 4;
    } else if (level < 4) {
      gridWidth = 5;
      gridHeight = 5;
    } else if (level < 8) {
      gridWidth = 5;
      gridHeight = 6;
    } else if (level < 15) {
      gridWidth = 6;
      gridHeight = 7;
    } else if (level < 28) {
      gridWidth = 7;
      gridHeight = 8;
    } else if (level < 45) {
      gridWidth = 8;
      gridHeight = 9;
    } else if (level < 70) {
      gridWidth = 8;
      gridHeight = 10;
    } else {
      gridWidth = 9;
      gridHeight = 11;
    }

    int pathCount;
    if (level == 1) {
      pathCount = 5;
    } else if (level == 2) {
      pathCount = 10;
    } else if (level < 4) {
      pathCount = 7;
    } else if (level < 8) {
      pathCount = 8;
    } else if (level < 15) {
      pathCount = 10;
    } else if (level < 35) {
      pathCount = 10 + ((level - 15) ~/ 5);
    } else {
      pathCount = 6;
    }
    final int boundaryCapacity = gridWidth * 2 + gridHeight * 2 - 4;
    if (pathCount > 14) pathCount = 14;
    if (pathCount > boundaryCapacity) pathCount = boundaryCapacity;

    int minLen;
    int maxLen;
    if (level == 1) {
      minLen = 3;
      maxLen = 4;
    } else if (level == 2) {
      minLen = 3;
      maxLen = 4;
    } else if (level < 8) {
      minLen = 3;
      maxLen = 5;
    } else {
      minLen = 4;
      maxLen = 5 + ((level - 8) ~/ 5);
    }
    if (maxLen > (gridWidth + gridHeight - 4)) {
      maxLen = gridWidth + gridHeight - 4;
    }

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

    List<PathModel> candidatePaths = [];
    for (int attempt = 0; attempt < 250; attempt++) {
      candidatePaths = [];
      final occupied = <GridPoint>{};
      final rand = math.Random(level * 97 + attempt * 23);

      for (int pIdx = 0; pIdx < pathCount; pIdx++) {
        List<GridPoint> boundaryPoints = [];
        for (int x = 0; x < gridWidth; x++) {
          final top = GridPoint(x, 0);
          final bottom = GridPoint(x, gridHeight - 1);
          if (!occupied.contains(top)) boundaryPoints.add(top);
          if (!occupied.contains(bottom)) boundaryPoints.add(bottom);
        }
        for (int y = 0; y < gridHeight; y++) {
          final left = GridPoint(0, y);
          final right = GridPoint(gridWidth - 1, y);
          if (!occupied.contains(left)) boundaryPoints.add(left);
          if (!occupied.contains(right)) boundaryPoints.add(right);
        }

        if (boundaryPoints.isEmpty) break;

        final centerX = (gridWidth - 1) / 2.0;
        final centerY = (gridHeight - 1) / 2.0;
        boundaryPoints.sort((a, b) {
          final aDist = (a.x - centerX).abs() + (a.y - centerY).abs();
          final bDist = (b.x - centerX).abs() + (b.y - centerY).abs();
          return aDist.compareTo(bDist);
        });
        final pickRange = boundaryPoints.length.clamp(1, 6);
        final start = boundaryPoints[rand.nextInt(pickRange)];

        List<GridPoint> pathPts = [start];
        occupied.add(start);

        int targetLen = minLen + rand.nextInt(maxLen - minLen + 1);
        GridPoint current = start;
        GridPoint? previousDir;

        for (int step = 1; step < targetLen; step++) {
          List<GridPoint> neighborDirs = [];
          final dirs = [
            const GridPoint(1, 0),
            const GridPoint(-1, 0),
            const GridPoint(0, 1),
            const GridPoint(0, -1),
          ];

          for (final d in dirs) {
            final neighbor = current + d;
            if (neighbor.x >= 0 && neighbor.x < gridWidth && neighbor.y >= 0 && neighbor.y < gridHeight) {
              if (!occupied.contains(neighbor)) {
                neighborDirs.add(d);
              }
            }
          }

          if (neighborDirs.isEmpty) break;

          GridPoint chosenDir;
          if (previousDir != null && neighborDirs.contains(previousDir) && rand.nextDouble() < 0.7) {
            chosenDir = previousDir;
          } else {
            chosenDir = neighborDirs[rand.nextInt(neighborDirs.length)];
          }

          current = current + chosenDir;
          pathPts.add(current);
          occupied.add(current);
          previousDir = chosenDir;
        }

        if (pathPts.length >= 2) {
          final reversed = pathPts.reversed.toList();
          candidatePaths.add(PathModel(
            id: 'gen_$level\_$pIdx\_$attempt',
            points: reversed,
            color: colors[pIdx % colors.length],
          ));
        }
      }

      if (candidatePaths.isNotEmpty && isLevelSolvable(candidatePaths)) {
        break;
      }
    }

    paths = candidatePaths;
    if (paths.isEmpty) {
      paths = [
        PathModel(
          id: 'fallback',
          points: [
            const GridPoint(0, 1),
            const GridPoint(1, 1),
            const GridPoint(2, 1),
            const GridPoint(3, 1),
          ],
          color: Colors.blueAccent,
        ),
      ];
    }
    notifyListeners();
  }

  bool isLevelSolvable(List<PathModel> candidatePaths) {
    if (candidatePaths.isEmpty) return true;
    final remaining = candidatePaths.map((path) => path.copyWith()).toList();
    return _canSolveRemaining(remaining);
  }

  bool _canSolveRemaining(List<PathModel> remainingPaths) {
    if (remainingPaths.isEmpty) return true;

    for (final path in List<PathModel>.from(remainingPaths)) {
      if (_canRemovePath(path, remainingPaths)) {
        final nextRemaining = remainingPaths.where((candidate) => candidate.id != path.id).toList();
        if (_canSolveRemaining(nextRemaining)) {
          return true;
        }
      }
    }

    return false;
  }

  bool _canRemovePath(PathModel path, List<PathModel> remainingPaths) {
    final occupied = <GridPoint>{};
    for (final otherPath in remainingPaths) {
      if (otherPath.id == path.id) continue;
      occupied.addAll(otherPath.getOccupiedCells());
    }

    GridPoint current = path.head + path.exitDirection;
    while (current.x >= 0 && current.x < gridWidth && current.y >= 0 && current.y < gridHeight) {
      if (occupied.contains(current)) {
        return false;
      }
      current = current + path.exitDirection;
    }

    return true;
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
