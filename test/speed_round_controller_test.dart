import 'package:flutter_test/flutter_test.dart';
import 'package:language_duels/data/models/content_item.dart';
import 'package:language_duels/data/models/player.dart';
import 'package:language_duels/features/games/speed_round/speed_round_controller.dart';

ContentItem _item(int index, {String category = 'greetings'}) {
  return ContentItem(
    id: 'item_$index',
    type: 'vocab',
    category: category,
    difficulty: 1,
    greek: LanguageEntry(text: 'GR$index'),
    catalan: LanguageEntry(text: 'CA$index'),
    words: const [],
  );
}

void main() {
  test('SpeedRoundController generates 10 questions with 5 true/false', () {
    final items = List.generate(20, (index) => _item(index));
    final controller = SpeedRoundController();

    controller.initialize(items, LanguageDirection.greekToCatalan);
    final state = controller.state;

    expect(state.questions.length, 10);
    final trueCount = state.questions.where((q) => q.isCorrect).length;
    final falseCount = state.questions.where((q) => !q.isCorrect).length;
    expect(trueCount, 5);
    expect(falseCount, 5);
  });

  test('submitAnswer returns points for correct answer', () {
    final items = List.generate(10, (index) => _item(index));
    final controller = SpeedRoundController();

    controller.initialize(items, LanguageDirection.greekToCatalan);
    final question = controller.state.currentQuestion;
    final points = controller.submitAnswer(question.isCorrect);

    expect(points, 5);
    expect(controller.state.isAnswered, true);
  });
}
