import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/game_state.dart';
import 'screens/home_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _gameState = GameState();
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
          home: HomeScreen(gameState: _gameState),
        );
      },
    );
  }
}
