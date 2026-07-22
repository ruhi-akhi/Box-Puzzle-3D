import 'package:flutter_test/flutter_test.dart';
import 'package:box_puzzle_3d/models/game_state.dart';

void main() {
  test('procedural levels generate quickly up to level 150', () {
    final gs = GameState();
    final sw = Stopwatch()..start();
    for (int level = 1; level <= 150; level++) {
      gs.generateProceduralLevel(level);
      expect(gs.paths.isNotEmpty, true, reason: 'level $level produced no paths');
    }
    sw.stop();
    // ignore: avoid_print
    print('Generated levels 1-150 in ${sw.elapsedMilliseconds}ms');
    expect(sw.elapsedMilliseconds < 20000, true,
        reason: 'level generation took too long: ${sw.elapsedMilliseconds}ms');
  });
}
