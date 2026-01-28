import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:language_duels/data/models/content_item.dart';
import 'package:language_duels/data/models/deck.dart';
import 'package:language_duels/data/providers/game_session_provider.dart';
import 'package:language_duels/data/providers/history_provider.dart';
import 'package:language_duels/data/providers/session_storage_provider.dart';
import 'package:language_duels/data/repositories/interfaces.dart';
import 'package:language_duels/data/repositories/session_storage.dart';
import 'package:language_duels/data/models/player.dart';
import 'package:language_duels/data/models/match_record.dart';

class FakeSessionStorage implements SessionStorage {
  Map<String, dynamic>? _stored;

  @override
  Future<void> saveSession(Map<String, dynamic> json) async {
    _stored = json;
  }

  @override
  Map<String, dynamic>? loadSession() => _stored;

  @override
  Future<void> clearSession() async {
    _stored = null;
  }
}

class FakeHistoryRepository implements IHistoryRepository {
  final List<MatchRecord> _records = [];

  @override
  List<MatchRecord> getAll() => List.unmodifiable(_records);

  @override
  Future<void> add(MatchRecord record) async {
    _records.add(record);
  }

  @override
  Future<void> clear() async {
    _records.clear();
  }
}

Deck _buildDeck() {
  final vocabItems = List.generate(
    12,
    (index) => ContentItem(
      id: 'v$index',
      type: 'vocab',
      category: 'greeting',
      difficulty: 1,
      greek: LanguageEntry(text: 'Γεια $index'),
      catalan: LanguageEntry(text: 'Hola $index'),
      words: const [],
    ),
  );
  final phraseItems = List.generate(
    6,
    (index) => ContentItem(
      id: 'p$index',
      type: 'phrase',
      category: 'greeting',
      difficulty: 1,
      greek: LanguageEntry(text: 'Καλημέρα $index'),
      catalan: LanguageEntry(text: 'Bon dia $index'),
      words: const [
        ContentWord(greek: 'Καλημέρα', catalan: 'Bon'),
        ContentWord(greek: 'σου', catalan: 'dia'),
      ],
    ),
  );

  return Deck(
    info: const DeckInfo(
      id: 'test',
      name: LocalizedString(en: 'Test'),
      description: LocalizedString(en: 'Test deck'),
      level: 'A1',
      itemCount: 18,
    ),
    items: [...vocabItems, ...phraseItems],
  );
}

void main() {
  test('startSession seeds round data and resets scores', () {
    final sessionStorage = FakeSessionStorage();
    final historyStorage = FakeHistoryRepository();
    final container = ProviderContainer(
      overrides: [
        sessionStorageProvider.overrideWithValue(sessionStorage),
        historyStorageProvider.overrideWithValue(historyStorage),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(gameSessionProvider.notifier);
    controller.startSession(
      deck: _buildDeck(),
      playerOneName: 'Alex',
      playerTwoName: 'Nina',
      playerOneDirection: LanguageDirection.greekToCatalan,
      playerTwoDirection: LanguageDirection.catalanToGreek,
    );

    final state = container.read(gameSessionProvider);
    expect(state.status, SessionStatus.inProgress);
    expect(state.playerOneScore, 0);
    expect(state.playerTwoScore, 0);
    expect(state.vocabPlayerOneIds.length, 5);
    expect(state.vocabPlayerTwoIds.length, 5);
    expect(state.phrasePlayerOneIds.length, 3);
    expect(state.phrasePlayerTwoIds.length, 3);
  });

  test('addScore updates per-game and total scores', () {
    final sessionStorage = FakeSessionStorage();
    final historyStorage = FakeHistoryRepository();
    final container = ProviderContainer(
      overrides: [
        sessionStorageProvider.overrideWithValue(sessionStorage),
        historyStorageProvider.overrideWithValue(historyStorage),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(gameSessionProvider.notifier);
    controller.startSession(
      deck: _buildDeck(),
      playerOneName: 'Alex',
      playerTwoName: 'Nina',
      playerOneDirection: LanguageDirection.greekToCatalan,
      playerTwoDirection: LanguageDirection.catalanToGreek,
    );

    controller.addScore(player: 1, points: 10);
    var state = container.read(gameSessionProvider);
    expect(state.playerOneScore, 10);
    expect(state.vocabPlayerOneScore, 10);

    controller.restoreSession(state.copyWith(currentGame: GameType.phrase));
    controller.addScore(player: 2, points: 6);
    state = container.read(gameSessionProvider);
    expect(state.playerTwoScore, 6);
    expect(state.phrasePlayerTwoScore, 6);
  });

  test('completing all rounds records match history', () async {
    final sessionStorage = FakeSessionStorage();
    final historyStorage = FakeHistoryRepository();
    final container = ProviderContainer(
      overrides: [
        sessionStorageProvider.overrideWithValue(sessionStorage),
        historyStorageProvider.overrideWithValue(historyStorage),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(gameSessionProvider.notifier);
    controller.startSession(
      deck: _buildDeck(),
      playerOneName: 'Alex',
      playerTwoName: 'Nina',
      playerOneDirection: LanguageDirection.greekToCatalan,
      playerTwoDirection: LanguageDirection.catalanToGreek,
    );

    // Complete all 6 games for both players
    controller.completeVocabForPlayer(1);
    controller.completeVocabForPlayer(2);
    controller.completePhraseForPlayer(1);
    controller.completePhraseForPlayer(2);
    controller.completeSpeedRoundForPlayer(1);
    controller.completeSpeedRoundForPlayer(2);
    controller.completeMatchMadnessForPlayer(1);
    controller.completeMatchMadnessForPlayer(2);
    controller.completeSpellingBeeForPlayer(1);
    controller.completeSpellingBeeForPlayer(2);
    controller.completeListeningForPlayer(1);
    controller.completeListeningForPlayer(2);

    final state = container.read(gameSessionProvider);
    expect(state.status, SessionStatus.completed);
    expect(historyStorage.getAll().length, 1);
    expect(sessionStorage.loadSession(), isNull);
  });
}
