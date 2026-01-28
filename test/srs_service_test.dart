import 'package:flutter_test/flutter_test.dart';

import 'package:language_duels/data/models/srs_item.dart';
import 'package:language_duels/data/services/srs_service.dart';

void main() {
  group('SrsService', () {
    late SrsService service;

    setUp(() {
      service = SrsService();
    });

    test('first correct answer sets interval to 1 day', () {
      final item = SRSItem.newItem('item1', 'deck1');
      final updated = service.processReview(item, 3, 2000);

      expect(updated.intervalDays, 1);
      expect(updated.repetitions, 1);
      expect(updated.state, SRSState.learning);
      expect(updated.wrongStreak, 0);
    });

    test('second correct answer sets interval to 6 days', () {
      final item = SRSItem(
        itemId: 'item1',
        deckId: 'deck1',
        repetitions: 1,
        intervalDays: 1,
        easeFactor: 2.5,
        nextReviewDate: DateTime.now(),
        lastReviewDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      final updated = service.processReview(item, 3, 2000);

      expect(updated.intervalDays, 6);
      expect(updated.repetitions, 2);
    });

    test('wrong answer resets interval to 1', () {
      final item = SRSItem(
        itemId: 'item1',
        deckId: 'deck1',
        repetitions: 5,
        intervalDays: 30,
        easeFactor: 2.5,
        state: SRSState.mastered,
        nextReviewDate: DateTime.now(),
        lastReviewDate: DateTime.now().subtract(const Duration(days: 30)),
      );
      final updated = service.processReview(item, 1, 5000);

      expect(updated.intervalDays, 1);
      expect(updated.repetitions, 0);
      expect(updated.state, SRSState.relearning);
      expect(updated.wrongStreak, 1);
    });

    test('mastery achieved at 21+ days interval', () {
      final item = SRSItem(
        itemId: 'item1',
        deckId: 'deck1',
        repetitions: 3,
        intervalDays: 16,
        easeFactor: 2.6,
        state: SRSState.learning,
        nextReviewDate: DateTime.now(),
        lastReviewDate: DateTime.now().subtract(const Duration(days: 16)),
      );
      final updated = service.processReview(item, 3, 2000);

      expect(updated.intervalDays, greaterThanOrEqualTo(21));
      expect(updated.state, SRSState.mastered);
    });

    test('ease factor decreases on wrong answer', () {
      final item = SRSItem.newItem('item1', 'deck1');
      final updated = service.processReview(item, 1, 5000);

      expect(updated.easeFactor, lessThan(2.5));
    });

    test('ease factor never goes below minimum', () {
      var item = SRSItem.newItem('item1', 'deck1');
      for (var i = 0; i < 10; i += 1) {
        item = service.processReview(item, 1, 5000);
      }

      expect(item.easeFactor, greaterThanOrEqualTo(SrsService.minEaseFactor));
    });

    test('relaxed mode quality defaults to hesitation', () {
      final quality = service.calculateQuality(true, 2000, 0);
      expect(quality, 2);
    });
  });
}
