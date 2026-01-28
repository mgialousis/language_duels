import '../models/deck.dart';
import '../models/grammar_lesson.dart';
import '../models/grammar_progress.dart';
import '../models/match_record.dart';
import '../models/learner_profile.dart';
import '../models/srs_item.dart';
import '../models/solo_session_summary.dart';
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

abstract class ILearnerRepository {
  LearnerProfile? load();
  Future<void> save(LearnerProfile profile);
  bool hasProfile();
  Future<void> clear();
}

abstract class ISrsRepository {
  Map<String, SRSItem> loadAll();
  Future<void> saveItem(SRSItem item);
  Future<void> saveAll(Iterable<SRSItem> items);
  Future<void> clear();
}

abstract class ISoloHistoryRepository {
  Future<void> add(SoloSessionSummary session);
  List<SoloSessionSummary> getAll();
  Future<void> clear();
}

abstract class IGrammarRepository {
  Map<String, GrammarProgress> loadAllProgress();
  Future<void> saveProgress(GrammarProgress progress);
  Future<List<GrammarLesson>> loadLessons(String level);
  Future<GrammarLesson?> loadLesson(String id);
}
