import '../models/deck.dart';
import '../models/match_record.dart';
import '../models/settings_state.dart';

abstract class IContentRepository {
  Future<Deck> loadDeck(String deckId);
  Future<List<DeckInfo>> listDecks();
  Future<void> clearCache();
}

abstract class ISettingsRepository {
  SettingsState load();
  Future<void> save(SettingsState settings);
}

abstract class IHistoryRepository {
  Future<void> add(MatchRecord record);
  List<MatchRecord> getAll();
  Future<void> clear();
}
