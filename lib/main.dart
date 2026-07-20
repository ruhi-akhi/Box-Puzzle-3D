import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/game_state.dart';
import 'screens/home_screen.dart';
import 'services/audio_manager.dart';

void main() {
  runApp(const AmazeGoApp());
}

class AmazeGoApp extends StatefulWidget {
  const AmazeGoApp({super.key});

  @override
  State<AmazeGoApp> createState() => _AmazeGoAppState();
}

class _AmazeGoAppState extends State<AmazeGoApp> {
  late final GameState _gameState;
  late final AudioManager _audioManager;
  bool _musicStarted = false;

  @override
  void initState() {
    super.initState();
    _gameState = GameState();
    _audioManager = AudioManager();
  }

  Future<void> _startBackgroundMusicOnce() async {
    // Browsers block audio autoplay until the user has interacted with the
    // page, so start music on first tap instead of at app boot.
    if (_musicStarted) return;
    _musicStarted = true;
    try {
      await _audioManager.playBackgroundMusic('music/background_music.wav');
    } catch (e) {
      // Audio system will handle the error
    }
  }

  @override
  void dispose() {
    _audioManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _gameState,
      builder: (context, _) {
        return MaterialApp(
          title: 'Amaze GO!',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFC78443),
              background: _gameState.currentSkin == 'worms'
                  ? const Color(0xFFC8E6C9)
                  : const Color(0xFFFAF6EE),
            ),
            textTheme: GoogleFonts.outfitTextTheme(
              Theme.of(context).textTheme,
            ),
          ),
          home: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => _startBackgroundMusicOnce(),
            child: HomeScreen(gameState: _gameState, audioManager: _audioManager),
          ),
        );
      },
    );
  }
}
