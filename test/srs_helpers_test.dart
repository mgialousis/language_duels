import 'package:flutter_test/flutter_test.dart';

import 'package:language_duels/data/models/srs_item.dart';
import 'package:language_duels/data/services/srs_helpers.dart';

void main() {
  test('grammar item id helpers round trip', () {
    const lessonId = 'a1_g01_verb_to_be';
    final itemId = grammarItemId(lessonId);

    expect(itemId, 'grammar:$lessonId');
    expect(lessonIdFromGrammarItemId(itemId), lessonId);
  });

  test('grammarLessonIdFromItem handles prefixed and raw ids', () {
    final prefixed = SRSItem.newItem(
      grammarItemId('a1_g02_verb_to_have'),
      grammarDeckId,
    );
    expect(grammarLessonIdFromItem(prefixed), 'a1_g02_verb_to_have');

    final now = DateTime.now();
    final raw = SRSItem(
      itemId: 'a1_g03_definite_articles',
      deckId: grammarDeckId,
      nextReviewDate: now,
      lastReviewDate: now,
    );
    expect(grammarLessonIdFromItem(raw), 'a1_g03_definite_articles');
  });

  test('grammarLessonIdFromItem ignores non-grammar items', () {
    final item = SRSItem.newItem('greetings_1', 'greetings');

    expect(grammarLessonIdFromItem(item), isNull);
  });
}
