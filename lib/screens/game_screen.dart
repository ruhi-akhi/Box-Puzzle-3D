import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_state.dart';
import '../models/path_model.dart';
import '../widgets/board_painter.dart';
import '../widgets/exit_dialog.dart';

class GameScreen extends StatefulWidget {
  final GameState gameState;

  const GameScreen({super.key, required this.gameState});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    widget.gameState.addListener(_onStateChange);
  }

  @override
  void dispose() {
    widget.gameState.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  Future<bool> _onWillPop() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ExitDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final gs = widget.gameState;
    final isWormSkin = gs.currentSkin == 'worms';

    // Calculate level progress (percentage of paths cleared)
    double progress = gs.progressPercent * 100.0;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: isWormSkin
            ? const Color(0xFFC8E6C9) // Green lawn background for worms skin
            : const Color(0xFFFAF6EE), // Cream background for arrows
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Stack(
              children: [
                // Main Content
                SafeArea(
                  child: Column(
                    children: [
                      // Header Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Color(0xFF4E3629), size: 28),
                              onPressed: () async {
                                if (await _onWillPop()) {
                                  if (mounted) Navigator.of(context).pop();
                                }
                              },
                            ),
                            Column(
                              children: [
                                Text(
                                  'Level ${gs.currentLevel}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF4E3629),
                                  ),
                                ),
                                Text(
                                  gs.currentLevel > 3 ? 'Super Hard' : 'Normal',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.palette, color: Color(0xFF4E3629), size: 26),
                                  onPressed: () {
                                    gs.setSkin(isWormSkin ? 'classic' : 'worms');
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.refresh, color: Color(0xFF4E3629), size: 26),
                                  onPressed: () {
                                    gs.restartLevel();
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      ),

                      // Lives and Progress Bar Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Lives (Drops / Hearts)
                            Row(
                              children: List.generate(gs.maxLives, (index) {
                                bool hasLife = index < gs.lives;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6.0),
                                  child: Icon(
                                    isWormSkin ? Icons.favorite : Icons.water_drop,
                                    color: hasLife
                                        ? (isWormSkin ? Colors.red : Colors.blue)
                                        : Colors.grey.shade400,
                                    size: 28,
                                  ),
                                );
                              }),
                            ),
                            // Progress Bar
                            Row(
                              children: [
                                Container(
                                  width: 120,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: progress / 100.0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isWormSkin ? Colors.green : const Color(0xFFC78443),
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${progress.toInt()}%',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF4E3629),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Game Grid Board (Fits perfectly using LayoutBuilder)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              double maxW = constraints.maxWidth;
                              double maxH = constraints.maxHeight;

                              // We fit aspect ratio (width / height) inside (maxW, maxH)
                              double boardW = maxW;
                              double boardH = boardW * (gs.gridHeight / gs.gridWidth);

                              if (boardH > maxH) {
                                boardH = maxH;
                                boardW = boardH * (gs.gridWidth / gs.gridHeight);
                              }

                              double cellSize = boardW / gs.gridWidth;

                              return Center(
                                child: Container(
                                  width: boardW,
                                  height: boardH,
                                  decoration: BoxDecoration(
                                    color: isWormSkin
                                        ? const Color(0xFFA5D6A7).withOpacity(0.5)
                                        : const Color(0xFFEFEBE9),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFF4E3629).withOpacity(0.15),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: GestureDetector(
                                    onTapUp: (details) {
                                      double dx = details.localPosition.dx;
                                      double dy = details.localPosition.dy;
                                      int col = (dx / cellSize).floor();
                                      int row = (dy / cellSize).floor();

                                      if (col >= 0 && col < gs.gridWidth && row >= 0 && row < gs.gridHeight) {
                                        gs.handleTap(GridPoint(col, row));
                                      }
                                    },
                                    child: CustomPaint(
                                      painter: BoardPainter(
                                        paths: gs.paths,
                                        gridWidth: gs.gridWidth,
                                        gridHeight: gs.gridHeight,
                                        skin: gs.currentSkin,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Quick Hint Footer
                      Text(
                        'Tap arrows/worms to clear the board!',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4E3629).withOpacity(0.7),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // Victory Overlay
                if (gs.status == GameStatus.victory) _buildVictoryOverlay(context, gs),

                // Defeat Overlay
                if (gs.status == GameStatus.defeat) _buildDefeatOverlay(context, gs),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVictoryOverlay(BuildContext context, GameState gs) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF6EE),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, size: 72, color: Colors.orange),
                const SizedBox(height: 16),
                Text(
                  'Success!',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4E3629),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You successfully cleared the board!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    gs.nextLevel();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC78443),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Next Level',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefeatOverlay(BuildContext context, GameState gs) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF6EE),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sentiment_very_dissatisfied, size: 72, color: Colors.redAccent),
                const SizedBox(height: 16),
                Text(
                  'Game Over!',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4E3629),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You ran out of lives. Try again!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    gs.restartLevel();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC78443),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Try Again',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
