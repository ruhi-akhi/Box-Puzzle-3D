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
  int initialPathCount = 0;
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
    // Dynamically scale grid size based on level. Growth continues past
    // level 70 (instead of flattening out) so very high "Super Hard" levels
    // keep getting visibly denser, matching the original game.
    if (level == 1) {
      gridWidth = 4;
      gridHeight = 4;
    } else if (level < 4) {
      gridWidth = 6;
      gridHeight = 7;
    } else if (level < 8) {
      gridWidth = 7;
      gridHeight = 8;
    } else if (level < 15) {
      gridWidth = 8;
      gridHeight = 9;
    } else if (level < 24) {
      gridWidth = 9;
      gridHeight = 10;
    } else if (level < 35) {
      gridWidth = 9;
      gridHeight = 11;
    } else if (level < 45) {
      gridWidth = 10;
      gridHeight = 12;
    } else if (level < 55) {
      gridWidth = 11;
      gridHeight = 13;
    } else if (level < 70) {
      gridWidth = 12;
      gridHeight = 15;
    } else if (level < 90) {
      gridWidth = 13;
      gridHeight = 16;
    } else if (level < 120) {
      gridWidth = 14;
      gridHeight = 17;
    } else {
      gridWidth = 15;
      gridHeight = 18;
    }

    final int boundaryCapacity = gridWidth * 2 + gridHeight * 2 - 4;

    int pathCount;
    if (level == 1) {
      pathCount = 5;
    } else if (level == 2) {
      pathCount = 8;
    } else if (level == 3) {
      pathCount = 10;
    } else {
      // Pack most of the boundary with starting points so the board fills
      // up on all 4 sides instead of leaving big empty patches, getting
      // denser (and more tangled) as the level climbs.
      final double fraction = level < 8
          ? 0.55
          : level < 15
              ? 0.65
              : level < 35
                  ? 0.78
                  : 0.9;
      pathCount = (boundaryCapacity * fraction).round();
    }
    if (pathCount > 48) pathCount = 48;
    if (pathCount > boundaryCapacity - 2) pathCount = boundaryCapacity - 2;

    int minLen;
    int maxLen;
    if (level == 1) {
      minLen = 3;
      maxLen = 4;
    } else if (level == 2) {
      minLen = 3;
      maxLen = 5;
    } else if (level < 8) {
      minLen = 4;
      maxLen = 6;
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

        // Spread starting points across the whole boundary (all 4 sides,
        // corners included) instead of favoring the middle of each edge,
        // so the board packs evenly all the way around.
        final start = boundaryPoints[rand.nextInt(boundaryPoints.length)];

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

          // Turn more aggressively past the tutorial levels so paths coil
          // and weave into each other instead of running in long straight
          // stretches.
          final double straightChance = level <= 3 ? 0.3 : 0.15;

          GridPoint chosenDir;
          if (previousDir != null && neighborDirs.contains(previousDir) && rand.nextDouble() < straightChance) {
            // Occasionally keep going straight
            chosenDir = previousDir;
          } else {
            // Prefer turning so paths coil and interlock instead of running straight
            List<GridPoint> turnDirs =
                previousDir == null ? neighborDirs : neighborDirs.where((d) => d != previousDir).toList();
            if (turnDirs.isEmpty) turnDirs = neighborDirs;
            chosenDir = turnDirs[rand.nextInt(turnDirs.length)];
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
    initialPathCount = paths.length;
    notifyListeners();
  }

  double get progressPercent {
    if (initialPathCount == 0) return 1.0;
    final progress = (initialPathCount - paths.length) / initialPathCount;
    return progress.clamp(0.0, 1.0);
  }

  // Removing a currently-clear path only clears cells, so it can never block
  // another path. That means a greedy sweep (no backtracking needed) always
  // finds a valid removal order if one exists.
  bool isLevelSolvable(List<PathModel> candidatePaths) {
    if (candidatePaths.isEmpty) return true;
    final remaining = candidatePaths.map((path) => path.copyWith()).toList();

    bool removedAny = true;
    while (remaining.isNotEmpty && removedAny) {
      removedAny = false;
      for (final path in List<PathModel>.from(remaining)) {
        if (_canRemovePath(path, remaining)) {
          remaining.remove(path);
          removedAny = true;
        }
      }
    }

    return remaining.isEmpty;
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
