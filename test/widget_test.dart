import 'package:flutter_test/flutter_test.dart';
import 'package:box_puzzle_3d/main.dart';
import 'package:box_puzzle_3d/models/game_state.dart';

void main() {
  testWidgets('Amaze GO App Smoke Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AmazeGoApp());

    // Verify that the title Amaze GO! is present
    expect(find.text('Amaze GO!'), findsOneWidget);
  });

  test('generated procedural levels stay solvable', () {
    final gameState = GameState();
    gameState.loadLevel(65);

    expect(gameState.paths, isNotEmpty);
    expect(gameState.isLevelSolvable(gameState.paths), isTrue);
  });
}
