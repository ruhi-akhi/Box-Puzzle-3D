import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_state.dart';
import 'game_screen.dart';

class HomeScreen extends StatelessWidget {
  final GameState gameState;

  const HomeScreen({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EE), // Elegant light cream background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Currency/Water drops
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.water_drop, color: Colors.blue, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          '${gameState.lives}',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4E3629),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Settings icon
                  IconButton(
                    icon: const Icon(Icons.settings, color: Color(0xFF4E3629), size: 28),
                    onPressed: () {
                      _showSettings(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Horizontal Cards Row (Daily Challenge & Event)
              Row(
                children: [
                  // Daily Challenge Card
                  Expanded(
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE07A5F), Color(0xFFD35230)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE07A5F).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -10,
                            bottom: -10,
                            child: Icon(
                              Icons.emoji_events,
                              size: 100,
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Daily Challenge',
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Jul 12',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                const Spacer(),
                                ElevatedButton(
                                  onPressed: () {
                                    // Start game directly
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => GameScreen(gameState: gameState),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFFD35230),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  ),
                                  child: Text(
                                    'Start',
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Event Card
                  Expanded(
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -10,
                            bottom: -10,
                            child: Icon(
                              Icons.bug_report,
                              size: 100,
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Event',
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Spring Battle',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                const Spacer(),
                                ElevatedButton(
                                  onPressed: () {
                                    gameState.setSkin('worms');
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => GameScreen(gameState: gameState),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF4CAF50),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  ),
                                  child: Text(
                                    'Play',
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Bubble hint
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4E3629),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Can you beat 59,394 players today?',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const Spacer(),

              // Game Title
              Text(
                'Amaze GO!',
                style: GoogleFonts.outfit(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF4E3629),
                  letterSpacing: 1.2,
                ),
              ),

              const Spacer(),

              // Level indicator timeline
              _buildLevelTimeline(),

              const SizedBox(height: 24),

              // Main Play Button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GameScreen(gameState: gameState),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8D5B4C), // Elegant dark red/brown button
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8D5B4C).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Play Game',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Level ${gameState.currentLevel}',
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelTimeline() {
    int centerLevel = gameState.currentLevel;
    List<int> levels = List.generate(5, (index) => centerLevel - 2 + index).where((l) => l > 0).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: levels.map((lvl) {
        bool isActive = lvl == gameState.currentLevel;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: isActive ? 44 : 36,
          height: isActive ? 44 : 36,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFE07A5F) : const Color(0xFFD7CCC8),
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFFE07A5F).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            '$lvl',
            style: GoogleFonts.outfit(
              fontSize: isActive ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : const Color(0xFF4E3629),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFAF6EE),
        title: Text(
          'Settings',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF4E3629)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.palette, color: Color(0xFF4E3629)),
              title: Text('Worm Theme (Spring Battle)', style: GoogleFonts.outfit()),
              trailing: gameState.currentSkin == 'worms' ? const Icon(Icons.check, color: Colors.green) : null,
              onTap: () {
                gameState.setSkin('worms');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_forward, color: Color(0xFF4E3629)),
              title: Text('Classic Arrow Theme', style: GoogleFonts.outfit()),
              trailing: gameState.currentSkin == 'classic' ? const Icon(Icons.check, color: Colors.green) : null,
              onTap: () {
                gameState.setSkin('classic');
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}
