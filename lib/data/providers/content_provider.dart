import 'package:riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';

import '../models/deck.dart';
import '../repositories/content_repository.dart';
import '../repositories/interfaces.dart';

final contentRepositoryProvider = Provider<IContentRepository>((ref) {
  return ContentRepository();
});

final selectedDeckProvider = StateProvider<String>((ref) => 'greetings');

final deckListProvider = FutureProvider<List<DeckInfo>>((ref) async {
  final repo = ref.read(contentRepositoryProvider);
  return repo.listDecks();
});

final deckProvider = FutureProvider<Deck>((ref) async {
  final repo = ref.read(contentRepositoryProvider);
  final deckId = ref.watch(selectedDeckProvider);
  return repo.loadDeck(deckId);
});

final allDecksProvider = FutureProvider<List<Deck>>((ref) async {
  final repo = ref.read(contentRepositoryProvider);
  final infos = await repo.listDecks();
  final decks = <Deck>[];
  for (final info in infos) {
    decks.add(await repo.loadDeck(info.id));
  }
  return decks;
});

final decksByIdsProvider =
    FutureProvider.family<List<Deck>, List<String>>((ref, ids) async {
  final repo = ref.read(contentRepositoryProvider);
  final decks = <Deck>[];
  for (final id in ids) {
    decks.add(await repo.loadDeck(id));
  }
  return decks;
});
