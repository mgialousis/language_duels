import 'package:flutter_test/flutter_test.dart';
import 'package:language_duels/features/games/match_madness/match_madness_controller.dart';

void main() {
  test('MatchMadnessController marks correct matches and scores', () {
    final controller = MatchMadnessController();
    final pairs = [
      const MatchPair(id: 'a', sourceText: 'A', targetText: 'AA'),
      const MatchPair(id: 'b', sourceText: 'B', targetText: 'BB'),
    ];

    controller.initialize(pairs);

    controller.selectSource('a');
    final result = controller.selectTarget('a');

    expect(result, MatchAttemptResult.matched);
    expect(controller.state.matchedCount, 1);
    expect(controller.state.score, 3);
  });
}
