import 'package:flutter_test/flutter_test.dart';
import 'package:language_duels/data/models/content_item.dart';
import 'package:language_duels/data/models/player.dart';
import 'package:language_duels/features/games/listening/listening_controller.dart';

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
  test('ListeningController builds 5 questions with options', () {
    final items = List.generate(12, (index) => _item(index));
    final controller = ListeningController();

    controller.initialize(items, LanguageDirection.greekToCatalan);
    final state = controller.state;

    expect(state.questions.length, 5);
    for (final question in state.questions) {
      expect(question.options.length, greaterThanOrEqualTo(2));
      expect(question.options, contains(question.correctAnswer));
    }
  });
}
