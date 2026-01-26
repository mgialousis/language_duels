import 'package:flutter_riverpod/flutter_riverpod.dart';

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
