import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:language_duels/data/models/deck.dart';
import 'package:language_duels/data/models/srs_item.dart';
import 'package:language_duels/data/providers/content_provider.dart';
import 'package:language_duels/data/providers/progress_provider.dart';
import 'package:language_duels/data/providers/srs_provider.dart';
import 'package:language_duels/data/repositories/interfaces.dart';

void main() {
  test('deckProgressListProvider aggregates totals correctly', () async {
    final decks = [
      DeckInfo(
        id: 'deck1',
        name: const LocalizedString(en: 'Deck 1'),
        description: const LocalizedString(en: 'desc'),
        level: 'A1',
        itemCount: 5,
      ),
      DeckInfo(
        id: 'deck2',
        name: const LocalizedString(en: 'Deck 2'),
        description: const LocalizedString(en: 'desc'),
        level: 'A1',
        itemCount: 3,
      ),
    ];

    final srsItems = {
      'a': SRSItem(
        itemId: 'a',
        deckId: 'deck1',
        repetitions: 3,
        intervalDays: 21,
        nextReviewDate: DateTime.now(),
        lastReviewDate: DateTime.now(),
        totalReviews: 3,
        correctReviews: 3,
        state: SRSState.mastered,
      ),
      'b': SRSItem(
        itemId: 'b',
        deckId: 'deck1',
        repetitions: 1,
        intervalDays: 1,
        nextReviewDate: DateTime.now(),
        lastReviewDate: DateTime.now(),
        totalReviews: 1,
        correctReviews: 0,
        state: SRSState.learning,
      ),
      'c': SRSItem(
        itemId: 'c',
        deckId: 'deck2',
        repetitions: 2,
        intervalDays: 6,
        nextReviewDate: DateTime.now(),
        lastReviewDate: DateTime.now(),
        totalReviews: 2,
        correctReviews: 2,
        state: SRSState.learning,
      ),
    };

    final container = ProviderContainer(
      overrides: [
        deckListProvider.overrideWith((ref) async => decks),
        srsItemsProvider.overrideWith(
          (ref) => SrsController(_FakeSrsRepository(srsItems)),
        ),
      ],
    );

    await container.read(deckListProvider.future);
    await Future<void>.delayed(Duration.zero);

    final progressAsync = container.read(deckProgressListProvider);
    expect(progressAsync.hasValue, true);
    final progress = progressAsync.value!;
    final deck1 = progress.firstWhere((p) => p.deckId == 'deck1');
    final deck2 = progress.firstWhere((p) => p.deckId == 'deck2');

    expect(deck1.totalItems, 5);
    expect(deck1.itemsSeen, 2);
    expect(deck1.itemsMastered, 1);
    expect(deck1.correctCount, 3);
    expect(deck1.totalAttempts, 4);

    expect(deck2.totalItems, 3);
    expect(deck2.itemsSeen, 1);
    expect(deck2.itemsMastered, 0);
    expect(deck2.correctCount, 2);
    expect(deck2.totalAttempts, 2);
  });
}

class _FakeSrsRepository implements ISrsRepository {
  _FakeSrsRepository(this._items);

  final Map<String, SRSItem> _items;

  @override
  Map<String, SRSItem> loadAll() => _items;

  @override
  Future<void> saveAll(Iterable<SRSItem> items) async {}

  @override
  Future<void> saveItem(SRSItem item) async {}

  @override
  Future<void> clear() async {}
}
