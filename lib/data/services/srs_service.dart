import '../models/srs_item.dart';

class SrsService {
  static const double minEaseFactor = 1.3;
  static const int masteryThresholdDays = 21;

  SRSItem processReview(SRSItem item, int quality, int responseTimeMs) {
    final now = DateTime.now();
    final isCorrect = quality >= 2;

    int newRepetitions;
    double newEaseFactor;
    int newInterval;
    SRSState newState;

    if (isCorrect) {
      newRepetitions = item.repetitions + 1;

      final qualityAdjusted = quality + 2; // Map 0-3 to 2-5
      newEaseFactor = item.easeFactor +
          (0.1 - (5 - qualityAdjusted) * (0.08 + (5 - qualityAdjusted) * 0.02));
      newEaseFactor = newEaseFactor.clamp(minEaseFactor, 3.0);

      if (newRepetitions == 1) {
        newInterval = 1;
      } else if (newRepetitions == 2) {
        newInterval = 6;
      } else {
        newInterval = (item.intervalDays * newEaseFactor).round();
      }

      newInterval = newInterval.clamp(1, 180);

      newState = newInterval >= masteryThresholdDays
          ? SRSState.mastered
          : SRSState.learning;
    } else {
      newRepetitions = 0;
      newInterval = 1;
      newEaseFactor = (item.easeFactor - 0.2).clamp(minEaseFactor, 3.0);
      newState =
          item.state == SRSState.mastered ? SRSState.relearning : SRSState.learning;
    }

    return SRSItem(
      itemId: item.itemId,
      deckId: item.deckId,
      repetitions: newRepetitions,
      easeFactor: newEaseFactor,
      intervalDays: newInterval,
      nextReviewDate: now.add(Duration(days: newInterval)),
      lastReviewDate: now,
      totalReviews: item.totalReviews + 1,
      correctReviews: item.correctReviews + (isCorrect ? 1 : 0),
      state: newState,
      wrongStreak: isCorrect ? 0 : item.wrongStreak + 1,
      resetCount: isCorrect ? item.resetCount : item.resetCount + 1,
    );
  }

  int calculateQuality(bool isCorrect, int responseTimeMs, int timerMs) {
    if (!isCorrect) {
      return responseTimeMs == 0 ? 0 : 1;
    }
    if (timerMs == 0) {
      return 2;
    }
    final responseRatio = responseTimeMs / timerMs;
    return responseRatio < 0.3 ? 3 : 2;
  }

  List<SRSItem> getDueItems(List<SRSItem> items, {int limit = 20}) {
    final now = DateTime.now();

    final overdue = <SRSItem>[];
    final dueToday = <SRSItem>[];
    final newItems = <SRSItem>[];

    for (final item in items) {
      if (item.state == SRSState.newItem) {
        newItems.add(item);
      } else if (item.nextReviewDate.isBefore(now.subtract(const Duration(days: 1)))) {
        overdue.add(item);
      } else if (item.isDue) {
        dueToday.add(item);
      }
    }

    overdue.sort((a, b) => a.nextReviewDate.compareTo(b.nextReviewDate));
    dueToday.sort((a, b) => a.easeFactor.compareTo(b.easeFactor));

    final result = <SRSItem>[];
    result.addAll(overdue.take(limit));
    if (result.length < limit) {
      result.addAll(dueToday.take(limit - result.length));
    }
    if (result.length < limit) {
      final newLimit = (limit - result.length).clamp(0, 5);
      result.addAll(newItems.take(newLimit));
    }
    return result.take(limit).toList();
  }
}
