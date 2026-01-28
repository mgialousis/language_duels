import 'package:flutter_test/flutter_test.dart';
import 'package:language_duels/data/models/content_item.dart';
import 'package:language_duels/data/models/player.dart';
import 'package:language_duels/features/games/spelling_bee/spelling_controller.dart';
import 'package:language_duels/features/games/spelling_bee/spelling_validator.dart';

ContentItem _item(int index, {String category = 'greetings'}) {
  return ContentItem(
    id: 'item_$index',
    type: 'vocab',
    category: category,
    difficulty: 1,
    greek: LanguageEntry(text: 'GR$index', romanization: 'gr$index'),
    catalan: LanguageEntry(text: 'CA$index'),
    words: const [],
  );
}

void main() {
  test('SpellingBeeController initializes with 5 questions', () {
    final items = List.generate(8, (index) => _item(index));
    final controller = SpellingBeeController();

    controller.initialize(items, LanguageDirection.greekToCatalan);

    expect(controller.state.questions.length, 5);
    expect(controller.state.currentIndex, 0);
    expect(controller.state.isComplete, false);
  });

  test('submitAnswer awards perfect score with time bonus', () {
    final items = List.generate(5, (index) => _item(index));
    final controller = SpellingBeeController();

    controller.initialize(items, LanguageDirection.greekToCatalan);
    controller.updateInput('CA0');
    final points = controller.submitAnswer(remainingSeconds: 16);

    expect(points, 20);
    expect(controller.state.isSubmitted, true);
    expect(controller.state.result, SpellingResult.perfect);
    expect(controller.state.pointsEarned, 20);
    expect(controller.state.score, 20);
  });

  test('submitTimeout marks answer wrong and nextQuestion completes round', () {
    final items = List.generate(5, (index) => _item(index));
    final controller = SpellingBeeController();

    controller.initialize(items, LanguageDirection.greekToCatalan);

    final timeoutPoints = controller.submitTimeout();
    expect(timeoutPoints, 0);
    expect(controller.state.isSubmitted, true);
    expect(controller.state.result, SpellingResult.wrong);

    for (var i = 0; i < 5; i++) {
      controller.nextQuestion();
    }

    expect(controller.state.isComplete, true);
  });
}
