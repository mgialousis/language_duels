import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/deck_progress.dart';
import '../models/srs_item.dart';
import 'content_provider.dart';
import 'srs_provider.dart';

final deckProgressListProvider =
    Provider<AsyncValue<List<DeckProgress>>>((ref) {
  final decksAsync = ref.watch(deckListProvider);
  final srsAsync = ref.watch(srsItemsProvider);

  if (decksAsync.isLoading || srsAsync.isLoading) {
    return const AsyncValue.loading();
  }
  if (decksAsync.hasError) {
    return AsyncValue.error(
      decksAsync.error!,
      decksAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (srsAsync.hasError) {
    return AsyncValue.error(
      srsAsync.error!,
      srsAsync.stackTrace ?? StackTrace.current,
    );
  }

  final decks = decksAsync.value ?? [];
  final srsItems = srsAsync.value ?? <String, SRSItem>{};

  final progress = <DeckProgress>[];
  for (final deck in decks) {
    final itemsForDeck = srsItems.values
        .where((item) => item.deckId == deck.id)
        .toList();
    final totalItems =
        deck.itemCount > 0 ? deck.itemCount : itemsForDeck.length;
    final itemsSeen = itemsForDeck.where((item) => item.totalReviews > 0).length;
    final itemsMastered = itemsForDeck.where((item) => item.isMastered).length;
    final correctCount =
        itemsForDeck.fold<int>(0, (sum, item) => sum + item.correctReviews);
    final totalAttempts =
        itemsForDeck.fold<int>(0, (sum, item) => sum + item.totalReviews);
    DateTime? lastPracticed;
    for (final item in itemsForDeck) {
      if (item.totalReviews == 0) continue;
      if (lastPracticed == null ||
          item.lastReviewDate.isAfter(lastPracticed)) {
        lastPracticed = item.lastReviewDate;
      }
    }
    progress.add(
      DeckProgress(
        deckId: deck.id,
        itemsSeen: itemsSeen,
        itemsMastered: itemsMastered,
        totalItems: totalItems,
        correctCount: correctCount,
        totalAttempts: totalAttempts,
        lastPracticed: lastPracticed,
      ),
    );
  }

  return AsyncValue.data(progress);
});
