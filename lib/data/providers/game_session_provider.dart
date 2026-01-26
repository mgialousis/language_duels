import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/content_item.dart';
import '../models/deck.dart';
import '../models/match_record.dart';
import '../models/player.dart';
import '../repositories/session_storage.dart';
import 'session_storage_provider.dart';
import 'history_provider.dart';

enum GameType { vocab, phrase }

enum SessionStatus { notStarted, inProgress, completed }

class GameSessionState {
  final String playerOneName;
  final String playerTwoName;
  final LanguageDirection playerOneDirection;
  final LanguageDirection playerTwoDirection;
  final int playerOneScore;
  final int playerTwoScore;
  final int vocabPlayerOneScore;
  final int vocabPlayerTwoScore;
  final int phrasePlayerOneScore;
  final int phrasePlayerTwoScore;
  final GameType currentGame;
  final int currentPlayer;
  final List<String> vocabPlayerOneIds;
  final List<String> vocabPlayerTwoIds;
  final List<String> phrasePlayerOneIds;
  final List<String> phrasePlayerTwoIds;
  final int vocabPlayerOneIndex;
  final int vocabPlayerTwoIndex;
  final int phrasePlayerOneIndex;
  final int phrasePlayerTwoIndex;
  final bool vocabPlayerOneDone;
  final bool vocabPlayerTwoDone;
  final bool phrasePlayerOneDone;
  final bool phrasePlayerTwoDone;
  final SessionStatus status;

  const GameSessionState({
    required this.playerOneName,
    required this.playerTwoName,
    required this.playerOneDirection,
    required this.playerTwoDirection,
    required this.playerOneScore,
    required this.playerTwoScore,
    required this.vocabPlayerOneScore,
    required this.vocabPlayerTwoScore,
    required this.phrasePlayerOneScore,
    required this.phrasePlayerTwoScore,
    required this.currentGame,
    required this.currentPlayer,
    required this.vocabPlayerOneIds,
    required this.vocabPlayerTwoIds,
    required this.phrasePlayerOneIds,
    required this.phrasePlayerTwoIds,
    required this.vocabPlayerOneIndex,
    required this.vocabPlayerTwoIndex,
    required this.phrasePlayerOneIndex,
    required this.phrasePlayerTwoIndex,
    required this.vocabPlayerOneDone,
    required this.vocabPlayerTwoDone,
    required this.phrasePlayerOneDone,
    required this.phrasePlayerTwoDone,
    required this.status,
  });

  Player get playerOne =>
      Player(name: playerOneName, direction: playerOneDirection);
  Player get playerTwo =>
      Player(name: playerTwoName, direction: playerTwoDirection);

  GameSessionState copyWith({
    String? playerOneName,
    String? playerTwoName,
    LanguageDirection? playerOneDirection,
    LanguageDirection? playerTwoDirection,
    int? playerOneScore,
    int? playerTwoScore,
    int? vocabPlayerOneScore,
    int? vocabPlayerTwoScore,
    int? phrasePlayerOneScore,
    int? phrasePlayerTwoScore,
    GameType? currentGame,
    int? currentPlayer,
    List<String>? vocabPlayerOneIds,
    List<String>? vocabPlayerTwoIds,
    List<String>? phrasePlayerOneIds,
    List<String>? phrasePlayerTwoIds,
    int? vocabPlayerOneIndex,
    int? vocabPlayerTwoIndex,
    int? phrasePlayerOneIndex,
    int? phrasePlayerTwoIndex,
    bool? vocabPlayerOneDone,
    bool? vocabPlayerTwoDone,
    bool? phrasePlayerOneDone,
    bool? phrasePlayerTwoDone,
    SessionStatus? status,
  }) {
    return GameSessionState(
      playerOneName: playerOneName ?? this.playerOneName,
      playerTwoName: playerTwoName ?? this.playerTwoName,
      playerOneDirection: playerOneDirection ?? this.playerOneDirection,
      playerTwoDirection: playerTwoDirection ?? this.playerTwoDirection,
      playerOneScore: playerOneScore ?? this.playerOneScore,
      playerTwoScore: playerTwoScore ?? this.playerTwoScore,
      vocabPlayerOneScore: vocabPlayerOneScore ?? this.vocabPlayerOneScore,
      vocabPlayerTwoScore: vocabPlayerTwoScore ?? this.vocabPlayerTwoScore,
      phrasePlayerOneScore: phrasePlayerOneScore ?? this.phrasePlayerOneScore,
      phrasePlayerTwoScore: phrasePlayerTwoScore ?? this.phrasePlayerTwoScore,
      currentGame: currentGame ?? this.currentGame,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      vocabPlayerOneIds: vocabPlayerOneIds ?? this.vocabPlayerOneIds,
      vocabPlayerTwoIds: vocabPlayerTwoIds ?? this.vocabPlayerTwoIds,
      phrasePlayerOneIds: phrasePlayerOneIds ?? this.phrasePlayerOneIds,
      phrasePlayerTwoIds: phrasePlayerTwoIds ?? this.phrasePlayerTwoIds,
      vocabPlayerOneIndex: vocabPlayerOneIndex ?? this.vocabPlayerOneIndex,
      vocabPlayerTwoIndex: vocabPlayerTwoIndex ?? this.vocabPlayerTwoIndex,
      phrasePlayerOneIndex: phrasePlayerOneIndex ?? this.phrasePlayerOneIndex,
      phrasePlayerTwoIndex: phrasePlayerTwoIndex ?? this.phrasePlayerTwoIndex,
      vocabPlayerOneDone: vocabPlayerOneDone ?? this.vocabPlayerOneDone,
      vocabPlayerTwoDone: vocabPlayerTwoDone ?? this.vocabPlayerTwoDone,
      phrasePlayerOneDone: phrasePlayerOneDone ?? this.phrasePlayerOneDone,
      phrasePlayerTwoDone: phrasePlayerTwoDone ?? this.phrasePlayerTwoDone,
      status: status ?? this.status,
    );
  }

  bool get vocabComplete => vocabPlayerOneDone && vocabPlayerTwoDone;
  bool get phraseComplete => phrasePlayerOneDone && phrasePlayerTwoDone;

  Map<String, dynamic> toJson() {
    return {
      'playerOneName': playerOneName,
      'playerTwoName': playerTwoName,
      'playerOneDirection': playerOneDirection.name,
      'playerTwoDirection': playerTwoDirection.name,
      'playerOneScore': playerOneScore,
      'playerTwoScore': playerTwoScore,
      'vocabPlayerOneScore': vocabPlayerOneScore,
      'vocabPlayerTwoScore': vocabPlayerTwoScore,
      'phrasePlayerOneScore': phrasePlayerOneScore,
      'phrasePlayerTwoScore': phrasePlayerTwoScore,
      'currentGame': currentGame.name,
      'currentPlayer': currentPlayer,
      'vocabPlayerOneIds': vocabPlayerOneIds,
      'vocabPlayerTwoIds': vocabPlayerTwoIds,
      'phrasePlayerOneIds': phrasePlayerOneIds,
      'phrasePlayerTwoIds': phrasePlayerTwoIds,
      'vocabPlayerOneIndex': vocabPlayerOneIndex,
      'vocabPlayerTwoIndex': vocabPlayerTwoIndex,
      'phrasePlayerOneIndex': phrasePlayerOneIndex,
      'phrasePlayerTwoIndex': phrasePlayerTwoIndex,
      'vocabPlayerOneDone': vocabPlayerOneDone,
      'vocabPlayerTwoDone': vocabPlayerTwoDone,
      'phrasePlayerOneDone': phrasePlayerOneDone,
      'phrasePlayerTwoDone': phrasePlayerTwoDone,
      'status': status.name,
    };
  }

  factory GameSessionState.fromJson(Map<String, dynamic> json) {
    return GameSessionState(
      playerOneName: json['playerOneName'] as String,
      playerTwoName: json['playerTwoName'] as String,
      playerOneDirection: LanguageDirection.values.byName(
        json['playerOneDirection'] as String,
      ),
      playerTwoDirection: LanguageDirection.values.byName(
        json['playerTwoDirection'] as String,
      ),
      playerOneScore: json['playerOneScore'] as int,
      playerTwoScore: json['playerTwoScore'] as int,
      vocabPlayerOneScore: (json['vocabPlayerOneScore'] ?? 0) as int,
      vocabPlayerTwoScore: (json['vocabPlayerTwoScore'] ?? 0) as int,
      phrasePlayerOneScore: (json['phrasePlayerOneScore'] ?? 0) as int,
      phrasePlayerTwoScore: (json['phrasePlayerTwoScore'] ?? 0) as int,
      currentGame: GameType.values.byName(json['currentGame'] as String),
      currentPlayer: json['currentPlayer'] as int,
      vocabPlayerOneIds: (json['vocabPlayerOneIds'] as List<dynamic>)
          .cast<String>(),
      vocabPlayerTwoIds: (json['vocabPlayerTwoIds'] as List<dynamic>)
          .cast<String>(),
      phrasePlayerOneIds: (json['phrasePlayerOneIds'] as List<dynamic>)
          .cast<String>(),
      phrasePlayerTwoIds: (json['phrasePlayerTwoIds'] as List<dynamic>)
          .cast<String>(),
      vocabPlayerOneIndex: (json['vocabPlayerOneIndex'] ?? 0) as int,
      vocabPlayerTwoIndex: (json['vocabPlayerTwoIndex'] ?? 0) as int,
      phrasePlayerOneIndex: (json['phrasePlayerOneIndex'] ?? 0) as int,
      phrasePlayerTwoIndex: (json['phrasePlayerTwoIndex'] ?? 0) as int,
      vocabPlayerOneDone: json['vocabPlayerOneDone'] as bool,
      vocabPlayerTwoDone: json['vocabPlayerTwoDone'] as bool,
      phrasePlayerOneDone: json['phrasePlayerOneDone'] as bool,
      phrasePlayerTwoDone: json['phrasePlayerTwoDone'] as bool,
      status: SessionStatus.values.byName(json['status'] as String),
    );
  }
}

class GameSessionController extends StateNotifier<GameSessionState> {
  GameSessionController(this._ref)
    : super(
        const GameSessionState(
          playerOneName: 'Player 1',
          playerTwoName: 'Player 2',
          playerOneDirection: LanguageDirection.greekToCatalan,
          playerTwoDirection: LanguageDirection.catalanToGreek,
          playerOneScore: 0,
          playerTwoScore: 0,
          vocabPlayerOneScore: 0,
          vocabPlayerTwoScore: 0,
          phrasePlayerOneScore: 0,
          phrasePlayerTwoScore: 0,
          currentGame: GameType.vocab,
          currentPlayer: 1,
          vocabPlayerOneIds: [],
          vocabPlayerTwoIds: [],
          phrasePlayerOneIds: [],
          phrasePlayerTwoIds: [],
          vocabPlayerOneIndex: 0,
          vocabPlayerTwoIndex: 0,
          phrasePlayerOneIndex: 0,
          phrasePlayerTwoIndex: 0,
          vocabPlayerOneDone: false,
          vocabPlayerTwoDone: false,
          phrasePlayerOneDone: false,
          phrasePlayerTwoDone: false,
          status: SessionStatus.notStarted,
        ),
      );

  final Ref _ref;

  SessionStorage get _storage => _ref.read(sessionStorageProvider);
  HistoryController get _history => _ref.read(historyProvider.notifier);

  void startSession({
    required Deck deck,
    required String playerOneName,
    required String playerTwoName,
    required LanguageDirection playerOneDirection,
    required LanguageDirection playerTwoDirection,
  }) {
    final vocabItems = _pickItems(deck.vocabularyItems, 10);
    final phraseItems = _pickItems(deck.phraseItems, 6);

    state = state.copyWith(
      playerOneName: playerOneName,
      playerTwoName: playerTwoName,
      playerOneDirection: playerOneDirection,
      playerTwoDirection: playerTwoDirection,
      playerOneScore: 0,
      playerTwoScore: 0,
      vocabPlayerOneScore: 0,
      vocabPlayerTwoScore: 0,
      phrasePlayerOneScore: 0,
      phrasePlayerTwoScore: 0,
      currentGame: GameType.vocab,
      currentPlayer: 1,
      vocabPlayerOneIds: vocabItems.take(5).map((i) => i.id).toList(),
      vocabPlayerTwoIds: vocabItems.skip(5).take(5).map((i) => i.id).toList(),
      phrasePlayerOneIds: phraseItems.take(3).map((i) => i.id).toList(),
      phrasePlayerTwoIds: phraseItems.skip(3).take(3).map((i) => i.id).toList(),
      vocabPlayerOneIndex: 0,
      vocabPlayerTwoIndex: 0,
      phrasePlayerOneIndex: 0,
      phrasePlayerTwoIndex: 0,
      vocabPlayerOneDone: false,
      vocabPlayerTwoDone: false,
      phrasePlayerOneDone: false,
      phrasePlayerTwoDone: false,
      status: SessionStatus.inProgress,
    );
    _persist();
  }

  void addScore({required int player, required int points}) {
    if (player == 1) {
      state = state.copyWith(
        playerOneScore: state.playerOneScore + points,
        vocabPlayerOneScore: state.currentGame == GameType.vocab
            ? state.vocabPlayerOneScore + points
            : state.vocabPlayerOneScore,
        phrasePlayerOneScore: state.currentGame == GameType.phrase
            ? state.phrasePlayerOneScore + points
            : state.phrasePlayerOneScore,
      );
    } else {
      state = state.copyWith(
        playerTwoScore: state.playerTwoScore + points,
        vocabPlayerTwoScore: state.currentGame == GameType.vocab
            ? state.vocabPlayerTwoScore + points
            : state.vocabPlayerTwoScore,
        phrasePlayerTwoScore: state.currentGame == GameType.phrase
            ? state.phrasePlayerTwoScore + points
            : state.phrasePlayerTwoScore,
      );
    }
    _persist();
  }

  void completeVocabForPlayer(int player) {
    if (player == 1) {
      state = state.copyWith(vocabPlayerOneDone: true);
    } else {
      state = state.copyWith(vocabPlayerTwoDone: true);
    }
    _advanceAfterVocab();
    _persist();
  }

  void completePhraseForPlayer(int player) {
    if (player == 1) {
      state = state.copyWith(phrasePlayerOneDone: true);
    } else {
      state = state.copyWith(phrasePlayerTwoDone: true);
    }
    _advanceAfterPhrase();
    _persist();
  }

  void setVocabIndex({required int player, required int index}) {
    if (player == 1) {
      state = state.copyWith(vocabPlayerOneIndex: index);
    } else {
      state = state.copyWith(vocabPlayerTwoIndex: index);
    }
    _persist();
  }

  void setPhraseIndex({required int player, required int index}) {
    if (player == 1) {
      state = state.copyWith(phrasePlayerOneIndex: index);
    } else {
      state = state.copyWith(phrasePlayerTwoIndex: index);
    }
    _persist();
  }

  void _advanceAfterVocab() {
    if (state.vocabComplete) {
      state = state.copyWith(currentGame: GameType.phrase, currentPlayer: 2);
    } else {
      state = state.copyWith(currentPlayer: state.currentPlayer == 1 ? 2 : 1);
    }
  }

  void _advanceAfterPhrase() {
    if (state.phraseComplete) {
      _saveMatch();
      state = state.copyWith(status: SessionStatus.completed);
      unawaited(_storage.clearSession());
    } else {
      state = state.copyWith(currentPlayer: state.currentPlayer == 1 ? 2 : 1);
    }
  }

  void restoreSession(GameSessionState restored) {
    state = restored;
  }

  void reset() {
    state = state.copyWith(
      playerOneScore: 0,
      playerTwoScore: 0,
      vocabPlayerOneScore: 0,
      vocabPlayerTwoScore: 0,
      phrasePlayerOneScore: 0,
      phrasePlayerTwoScore: 0,
      currentGame: GameType.vocab,
      currentPlayer: 1,
      vocabPlayerOneIds: [],
      vocabPlayerTwoIds: [],
      phrasePlayerOneIds: [],
      phrasePlayerTwoIds: [],
      vocabPlayerOneIndex: 0,
      vocabPlayerTwoIndex: 0,
      phrasePlayerOneIndex: 0,
      phrasePlayerTwoIndex: 0,
      vocabPlayerOneDone: false,
      vocabPlayerTwoDone: false,
      phrasePlayerOneDone: false,
      phrasePlayerTwoDone: false,
      status: SessionStatus.notStarted,
    );
    unawaited(_storage.clearSession());
  }

  void _persist() {
    if (state.status == SessionStatus.completed ||
        state.status == SessionStatus.notStarted) {
      unawaited(_storage.clearSession());
      return;
    }
    unawaited(_storage.saveSession(state.toJson()));
  }

  void _saveMatch() {
    final record = MatchRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      playerOneName: state.playerOneName,
      playerTwoName: state.playerTwoName,
      playerOneScore: state.playerOneScore,
      playerTwoScore: state.playerTwoScore,
      playedAt: DateTime.now(),
    );
    unawaited(_history.addRecord(record));
  }

  List<ContentItem> _pickItems(List<ContentItem> items, int count) {
    final list = [...items];
    list.shuffle(Random());
    if (list.length >= count) {
      return list.take(count).toList();
    }
    return list;
  }
}

final gameSessionProvider =
    StateNotifierProvider<GameSessionController, GameSessionState>((ref) {
      return GameSessionController(ref);
    });

final savedSessionProvider = FutureProvider<GameSessionState?>((ref) async {
  final storage = ref.read(sessionStorageProvider);
  final data = storage.loadSession();
  if (data == null) return null;
  final session = GameSessionState.fromJson(data);
  if (session.status == SessionStatus.completed) return null;
  return session;
});
