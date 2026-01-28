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

enum GameType {
  vocab,
  phrase,
  speedRound,
  matchMadness,
  spellingBee,
  listening,
}

const List<GameType> defaultGameOrder = [
  GameType.vocab,
  GameType.phrase,
  GameType.speedRound,
  GameType.matchMadness,
  GameType.spellingBee,
];

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
  final int speedRoundPlayerOneScore;
  final int speedRoundPlayerTwoScore;
  final int matchMadnessPlayerOneScore;
  final int matchMadnessPlayerTwoScore;
  final int spellingBeePlayerOneScore;
  final int spellingBeePlayerTwoScore;
  final int listeningPlayerOneScore;
  final int listeningPlayerTwoScore;
  final GameType currentGame;
  final List<GameType> gameOrder;
  final int currentGameIndex;
  final int currentPlayer;
  final List<String> vocabPlayerOneIds;
  final List<String> vocabPlayerTwoIds;
  final List<String> phrasePlayerOneIds;
  final List<String> phrasePlayerTwoIds;
  final List<String> speedRoundPlayerOneIds;
  final List<String> speedRoundPlayerTwoIds;
  final List<String> matchMadnessPlayerOneIds;
  final List<String> matchMadnessPlayerTwoIds;
  final List<String> spellingBeePlayerOneIds;
  final List<String> spellingBeePlayerTwoIds;
  final List<String> listeningPlayerOneIds;
  final List<String> listeningPlayerTwoIds;
  final int vocabPlayerOneIndex;
  final int vocabPlayerTwoIndex;
  final int phrasePlayerOneIndex;
  final int phrasePlayerTwoIndex;
  final int speedRoundPlayerOneIndex;
  final int speedRoundPlayerTwoIndex;
  final int spellingBeePlayerOneIndex;
  final int spellingBeePlayerTwoIndex;
  final int listeningPlayerOneIndex;
  final int listeningPlayerTwoIndex;
  final bool vocabPlayerOneDone;
  final bool vocabPlayerTwoDone;
  final bool phrasePlayerOneDone;
  final bool phrasePlayerTwoDone;
  final bool speedRoundPlayerOneDone;
  final bool speedRoundPlayerTwoDone;
  final bool matchMadnessPlayerOneDone;
  final bool matchMadnessPlayerTwoDone;
  final bool spellingBeePlayerOneDone;
  final bool spellingBeePlayerTwoDone;
  final bool listeningPlayerOneDone;
  final bool listeningPlayerTwoDone;
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
    required this.speedRoundPlayerOneScore,
    required this.speedRoundPlayerTwoScore,
    required this.matchMadnessPlayerOneScore,
    required this.matchMadnessPlayerTwoScore,
    required this.spellingBeePlayerOneScore,
    required this.spellingBeePlayerTwoScore,
    required this.listeningPlayerOneScore,
    required this.listeningPlayerTwoScore,
    required this.currentGame,
    required this.gameOrder,
    required this.currentGameIndex,
    required this.currentPlayer,
    required this.vocabPlayerOneIds,
    required this.vocabPlayerTwoIds,
    required this.phrasePlayerOneIds,
    required this.phrasePlayerTwoIds,
    required this.speedRoundPlayerOneIds,
    required this.speedRoundPlayerTwoIds,
    required this.matchMadnessPlayerOneIds,
    required this.matchMadnessPlayerTwoIds,
    required this.spellingBeePlayerOneIds,
    required this.spellingBeePlayerTwoIds,
    required this.listeningPlayerOneIds,
    required this.listeningPlayerTwoIds,
    required this.vocabPlayerOneIndex,
    required this.vocabPlayerTwoIndex,
    required this.phrasePlayerOneIndex,
    required this.phrasePlayerTwoIndex,
    required this.speedRoundPlayerOneIndex,
    required this.speedRoundPlayerTwoIndex,
    required this.spellingBeePlayerOneIndex,
    required this.spellingBeePlayerTwoIndex,
    required this.listeningPlayerOneIndex,
    required this.listeningPlayerTwoIndex,
    required this.vocabPlayerOneDone,
    required this.vocabPlayerTwoDone,
    required this.phrasePlayerOneDone,
    required this.phrasePlayerTwoDone,
    required this.speedRoundPlayerOneDone,
    required this.speedRoundPlayerTwoDone,
    required this.matchMadnessPlayerOneDone,
    required this.matchMadnessPlayerTwoDone,
    required this.spellingBeePlayerOneDone,
    required this.spellingBeePlayerTwoDone,
    required this.listeningPlayerOneDone,
    required this.listeningPlayerTwoDone,
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
    int? speedRoundPlayerOneScore,
    int? speedRoundPlayerTwoScore,
    int? matchMadnessPlayerOneScore,
    int? matchMadnessPlayerTwoScore,
    int? spellingBeePlayerOneScore,
    int? spellingBeePlayerTwoScore,
    int? listeningPlayerOneScore,
    int? listeningPlayerTwoScore,
    GameType? currentGame,
    List<GameType>? gameOrder,
    int? currentGameIndex,
    int? currentPlayer,
    List<String>? vocabPlayerOneIds,
    List<String>? vocabPlayerTwoIds,
    List<String>? phrasePlayerOneIds,
    List<String>? phrasePlayerTwoIds,
    List<String>? speedRoundPlayerOneIds,
    List<String>? speedRoundPlayerTwoIds,
    List<String>? matchMadnessPlayerOneIds,
    List<String>? matchMadnessPlayerTwoIds,
    List<String>? spellingBeePlayerOneIds,
    List<String>? spellingBeePlayerTwoIds,
    List<String>? listeningPlayerOneIds,
    List<String>? listeningPlayerTwoIds,
    int? vocabPlayerOneIndex,
    int? vocabPlayerTwoIndex,
    int? phrasePlayerOneIndex,
    int? phrasePlayerTwoIndex,
    int? speedRoundPlayerOneIndex,
    int? speedRoundPlayerTwoIndex,
    int? spellingBeePlayerOneIndex,
    int? spellingBeePlayerTwoIndex,
    int? listeningPlayerOneIndex,
    int? listeningPlayerTwoIndex,
    bool? vocabPlayerOneDone,
    bool? vocabPlayerTwoDone,
    bool? phrasePlayerOneDone,
    bool? phrasePlayerTwoDone,
    bool? speedRoundPlayerOneDone,
    bool? speedRoundPlayerTwoDone,
    bool? matchMadnessPlayerOneDone,
    bool? matchMadnessPlayerTwoDone,
    bool? spellingBeePlayerOneDone,
    bool? spellingBeePlayerTwoDone,
    bool? listeningPlayerOneDone,
    bool? listeningPlayerTwoDone,
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
      speedRoundPlayerOneScore:
          speedRoundPlayerOneScore ?? this.speedRoundPlayerOneScore,
      speedRoundPlayerTwoScore:
          speedRoundPlayerTwoScore ?? this.speedRoundPlayerTwoScore,
      matchMadnessPlayerOneScore:
          matchMadnessPlayerOneScore ?? this.matchMadnessPlayerOneScore,
      matchMadnessPlayerTwoScore:
          matchMadnessPlayerTwoScore ?? this.matchMadnessPlayerTwoScore,
      spellingBeePlayerOneScore:
          spellingBeePlayerOneScore ?? this.spellingBeePlayerOneScore,
      spellingBeePlayerTwoScore:
          spellingBeePlayerTwoScore ?? this.spellingBeePlayerTwoScore,
      listeningPlayerOneScore:
          listeningPlayerOneScore ?? this.listeningPlayerOneScore,
      listeningPlayerTwoScore:
          listeningPlayerTwoScore ?? this.listeningPlayerTwoScore,
      currentGame: currentGame ?? this.currentGame,
      gameOrder: gameOrder ?? this.gameOrder,
      currentGameIndex: currentGameIndex ?? this.currentGameIndex,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      vocabPlayerOneIds: vocabPlayerOneIds ?? this.vocabPlayerOneIds,
      vocabPlayerTwoIds: vocabPlayerTwoIds ?? this.vocabPlayerTwoIds,
      phrasePlayerOneIds: phrasePlayerOneIds ?? this.phrasePlayerOneIds,
      phrasePlayerTwoIds: phrasePlayerTwoIds ?? this.phrasePlayerTwoIds,
      speedRoundPlayerOneIds:
          speedRoundPlayerOneIds ?? this.speedRoundPlayerOneIds,
      speedRoundPlayerTwoIds:
          speedRoundPlayerTwoIds ?? this.speedRoundPlayerTwoIds,
      matchMadnessPlayerOneIds:
          matchMadnessPlayerOneIds ?? this.matchMadnessPlayerOneIds,
      matchMadnessPlayerTwoIds:
          matchMadnessPlayerTwoIds ?? this.matchMadnessPlayerTwoIds,
      spellingBeePlayerOneIds:
          spellingBeePlayerOneIds ?? this.spellingBeePlayerOneIds,
      spellingBeePlayerTwoIds:
          spellingBeePlayerTwoIds ?? this.spellingBeePlayerTwoIds,
      listeningPlayerOneIds:
          listeningPlayerOneIds ?? this.listeningPlayerOneIds,
      listeningPlayerTwoIds:
          listeningPlayerTwoIds ?? this.listeningPlayerTwoIds,
      vocabPlayerOneIndex: vocabPlayerOneIndex ?? this.vocabPlayerOneIndex,
      vocabPlayerTwoIndex: vocabPlayerTwoIndex ?? this.vocabPlayerTwoIndex,
      phrasePlayerOneIndex: phrasePlayerOneIndex ?? this.phrasePlayerOneIndex,
      phrasePlayerTwoIndex: phrasePlayerTwoIndex ?? this.phrasePlayerTwoIndex,
      speedRoundPlayerOneIndex:
          speedRoundPlayerOneIndex ?? this.speedRoundPlayerOneIndex,
      speedRoundPlayerTwoIndex:
          speedRoundPlayerTwoIndex ?? this.speedRoundPlayerTwoIndex,
      spellingBeePlayerOneIndex:
          spellingBeePlayerOneIndex ?? this.spellingBeePlayerOneIndex,
      spellingBeePlayerTwoIndex:
          spellingBeePlayerTwoIndex ?? this.spellingBeePlayerTwoIndex,
      listeningPlayerOneIndex:
          listeningPlayerOneIndex ?? this.listeningPlayerOneIndex,
      listeningPlayerTwoIndex:
          listeningPlayerTwoIndex ?? this.listeningPlayerTwoIndex,
      vocabPlayerOneDone: vocabPlayerOneDone ?? this.vocabPlayerOneDone,
      vocabPlayerTwoDone: vocabPlayerTwoDone ?? this.vocabPlayerTwoDone,
      phrasePlayerOneDone: phrasePlayerOneDone ?? this.phrasePlayerOneDone,
      phrasePlayerTwoDone: phrasePlayerTwoDone ?? this.phrasePlayerTwoDone,
      speedRoundPlayerOneDone:
          speedRoundPlayerOneDone ?? this.speedRoundPlayerOneDone,
      speedRoundPlayerTwoDone:
          speedRoundPlayerTwoDone ?? this.speedRoundPlayerTwoDone,
      matchMadnessPlayerOneDone:
          matchMadnessPlayerOneDone ?? this.matchMadnessPlayerOneDone,
      matchMadnessPlayerTwoDone:
          matchMadnessPlayerTwoDone ?? this.matchMadnessPlayerTwoDone,
      spellingBeePlayerOneDone:
          spellingBeePlayerOneDone ?? this.spellingBeePlayerOneDone,
      spellingBeePlayerTwoDone:
          spellingBeePlayerTwoDone ?? this.spellingBeePlayerTwoDone,
      listeningPlayerOneDone:
          listeningPlayerOneDone ?? this.listeningPlayerOneDone,
      listeningPlayerTwoDone:
          listeningPlayerTwoDone ?? this.listeningPlayerTwoDone,
      status: status ?? this.status,
    );
  }

  bool get vocabComplete => vocabPlayerOneDone && vocabPlayerTwoDone;
  bool get phraseComplete => phrasePlayerOneDone && phrasePlayerTwoDone;
  bool get speedRoundComplete =>
      speedRoundPlayerOneDone && speedRoundPlayerTwoDone;
  bool get matchMadnessComplete =>
      matchMadnessPlayerOneDone && matchMadnessPlayerTwoDone;
  bool get spellingBeeComplete =>
      spellingBeePlayerOneDone && spellingBeePlayerTwoDone;
  bool get listeningComplete =>
      listeningPlayerOneDone && listeningPlayerTwoDone;

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
      'speedRoundPlayerOneScore': speedRoundPlayerOneScore,
      'speedRoundPlayerTwoScore': speedRoundPlayerTwoScore,
      'matchMadnessPlayerOneScore': matchMadnessPlayerOneScore,
      'matchMadnessPlayerTwoScore': matchMadnessPlayerTwoScore,
      'spellingBeePlayerOneScore': spellingBeePlayerOneScore,
      'spellingBeePlayerTwoScore': spellingBeePlayerTwoScore,
      'listeningPlayerOneScore': listeningPlayerOneScore,
      'listeningPlayerTwoScore': listeningPlayerTwoScore,
      'currentGame': currentGame.name,
      'gameOrder': gameOrder.map((game) => game.name).toList(),
      'currentGameIndex': currentGameIndex,
      'currentPlayer': currentPlayer,
      'vocabPlayerOneIds': vocabPlayerOneIds,
      'vocabPlayerTwoIds': vocabPlayerTwoIds,
      'phrasePlayerOneIds': phrasePlayerOneIds,
      'phrasePlayerTwoIds': phrasePlayerTwoIds,
      'speedRoundPlayerOneIds': speedRoundPlayerOneIds,
      'speedRoundPlayerTwoIds': speedRoundPlayerTwoIds,
      'matchMadnessPlayerOneIds': matchMadnessPlayerOneIds,
      'matchMadnessPlayerTwoIds': matchMadnessPlayerTwoIds,
      'spellingBeePlayerOneIds': spellingBeePlayerOneIds,
      'spellingBeePlayerTwoIds': spellingBeePlayerTwoIds,
      'listeningPlayerOneIds': listeningPlayerOneIds,
      'listeningPlayerTwoIds': listeningPlayerTwoIds,
      'vocabPlayerOneIndex': vocabPlayerOneIndex,
      'vocabPlayerTwoIndex': vocabPlayerTwoIndex,
      'phrasePlayerOneIndex': phrasePlayerOneIndex,
      'phrasePlayerTwoIndex': phrasePlayerTwoIndex,
      'speedRoundPlayerOneIndex': speedRoundPlayerOneIndex,
      'speedRoundPlayerTwoIndex': speedRoundPlayerTwoIndex,
      'spellingBeePlayerOneIndex': spellingBeePlayerOneIndex,
      'spellingBeePlayerTwoIndex': spellingBeePlayerTwoIndex,
      'listeningPlayerOneIndex': listeningPlayerOneIndex,
      'listeningPlayerTwoIndex': listeningPlayerTwoIndex,
      'vocabPlayerOneDone': vocabPlayerOneDone,
      'vocabPlayerTwoDone': vocabPlayerTwoDone,
      'phrasePlayerOneDone': phrasePlayerOneDone,
      'phrasePlayerTwoDone': phrasePlayerTwoDone,
      'speedRoundPlayerOneDone': speedRoundPlayerOneDone,
      'speedRoundPlayerTwoDone': speedRoundPlayerTwoDone,
      'matchMadnessPlayerOneDone': matchMadnessPlayerOneDone,
      'matchMadnessPlayerTwoDone': matchMadnessPlayerTwoDone,
      'spellingBeePlayerOneDone': spellingBeePlayerOneDone,
      'spellingBeePlayerTwoDone': spellingBeePlayerTwoDone,
      'listeningPlayerOneDone': listeningPlayerOneDone,
      'listeningPlayerTwoDone': listeningPlayerTwoDone,
      'status': status.name,
    };
  }

  factory GameSessionState.fromJson(Map<String, dynamic> json) {
    final currentGame = GameType.values.byName(json['currentGame'] as String);
    final gameOrderNames = (json['gameOrder'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList();
    final resolvedOrder = (gameOrderNames == null || gameOrderNames.isEmpty)
        ? const [GameType.vocab, GameType.phrase]
        : gameOrderNames
            .map((name) => GameType.values.byName(name))
            .toList();
    final resolvedIndex =
        (json['currentGameIndex'] as int?) ?? resolvedOrder.indexOf(currentGame);
    final safeIndex = resolvedIndex < 0 ? 0 : resolvedIndex;
    final boundedIndex = safeIndex.clamp(0, resolvedOrder.length - 1);

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
      speedRoundPlayerOneScore:
          (json['speedRoundPlayerOneScore'] ?? 0) as int,
      speedRoundPlayerTwoScore:
          (json['speedRoundPlayerTwoScore'] ?? 0) as int,
      matchMadnessPlayerOneScore:
          (json['matchMadnessPlayerOneScore'] ?? 0) as int,
      matchMadnessPlayerTwoScore:
          (json['matchMadnessPlayerTwoScore'] ?? 0) as int,
      spellingBeePlayerOneScore:
          (json['spellingBeePlayerOneScore'] ?? 0) as int,
      spellingBeePlayerTwoScore:
          (json['spellingBeePlayerTwoScore'] ?? 0) as int,
      listeningPlayerOneScore:
          (json['listeningPlayerOneScore'] ?? 0) as int,
      listeningPlayerTwoScore:
          (json['listeningPlayerTwoScore'] ?? 0) as int,
      currentGame: currentGame,
      gameOrder: resolvedOrder,
      currentGameIndex: boundedIndex,
      currentPlayer: json['currentPlayer'] as int,
      vocabPlayerOneIds: (json['vocabPlayerOneIds'] as List<dynamic>)
          .cast<String>(),
      vocabPlayerTwoIds: (json['vocabPlayerTwoIds'] as List<dynamic>)
          .cast<String>(),
      phrasePlayerOneIds: (json['phrasePlayerOneIds'] as List<dynamic>)
          .cast<String>(),
      phrasePlayerTwoIds: (json['phrasePlayerTwoIds'] as List<dynamic>)
          .cast<String>(),
      speedRoundPlayerOneIds:
          (json['speedRoundPlayerOneIds'] as List<dynamic>? ?? const [])
              .cast<String>(),
      speedRoundPlayerTwoIds:
          (json['speedRoundPlayerTwoIds'] as List<dynamic>? ?? const [])
              .cast<String>(),
      matchMadnessPlayerOneIds:
          (json['matchMadnessPlayerOneIds'] as List<dynamic>? ?? const [])
              .cast<String>(),
      matchMadnessPlayerTwoIds:
          (json['matchMadnessPlayerTwoIds'] as List<dynamic>? ?? const [])
              .cast<String>(),
      spellingBeePlayerOneIds:
          (json['spellingBeePlayerOneIds'] as List<dynamic>? ?? const [])
              .cast<String>(),
      spellingBeePlayerTwoIds:
          (json['spellingBeePlayerTwoIds'] as List<dynamic>? ?? const [])
              .cast<String>(),
      listeningPlayerOneIds:
          (json['listeningPlayerOneIds'] as List<dynamic>? ?? const [])
              .cast<String>(),
      listeningPlayerTwoIds:
          (json['listeningPlayerTwoIds'] as List<dynamic>? ?? const [])
              .cast<String>(),
      vocabPlayerOneIndex: (json['vocabPlayerOneIndex'] ?? 0) as int,
      vocabPlayerTwoIndex: (json['vocabPlayerTwoIndex'] ?? 0) as int,
      phrasePlayerOneIndex: (json['phrasePlayerOneIndex'] ?? 0) as int,
      phrasePlayerTwoIndex: (json['phrasePlayerTwoIndex'] ?? 0) as int,
      speedRoundPlayerOneIndex:
          (json['speedRoundPlayerOneIndex'] ?? 0) as int,
      speedRoundPlayerTwoIndex:
          (json['speedRoundPlayerTwoIndex'] ?? 0) as int,
      spellingBeePlayerOneIndex:
          (json['spellingBeePlayerOneIndex'] ?? 0) as int,
      spellingBeePlayerTwoIndex:
          (json['spellingBeePlayerTwoIndex'] ?? 0) as int,
      listeningPlayerOneIndex:
          (json['listeningPlayerOneIndex'] ?? 0) as int,
      listeningPlayerTwoIndex:
          (json['listeningPlayerTwoIndex'] ?? 0) as int,
      vocabPlayerOneDone: json['vocabPlayerOneDone'] as bool,
      vocabPlayerTwoDone: json['vocabPlayerTwoDone'] as bool,
      phrasePlayerOneDone: json['phrasePlayerOneDone'] as bool,
      phrasePlayerTwoDone: json['phrasePlayerTwoDone'] as bool,
      speedRoundPlayerOneDone:
          (json['speedRoundPlayerOneDone'] ?? false) as bool,
      speedRoundPlayerTwoDone:
          (json['speedRoundPlayerTwoDone'] ?? false) as bool,
      matchMadnessPlayerOneDone:
          (json['matchMadnessPlayerOneDone'] ?? false) as bool,
      matchMadnessPlayerTwoDone:
          (json['matchMadnessPlayerTwoDone'] ?? false) as bool,
      spellingBeePlayerOneDone:
          (json['spellingBeePlayerOneDone'] ?? false) as bool,
      spellingBeePlayerTwoDone:
          (json['spellingBeePlayerTwoDone'] ?? false) as bool,
      listeningPlayerOneDone:
          (json['listeningPlayerOneDone'] ?? false) as bool,
      listeningPlayerTwoDone:
          (json['listeningPlayerTwoDone'] ?? false) as bool,
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
          speedRoundPlayerOneScore: 0,
          speedRoundPlayerTwoScore: 0,
          matchMadnessPlayerOneScore: 0,
          matchMadnessPlayerTwoScore: 0,
          spellingBeePlayerOneScore: 0,
          spellingBeePlayerTwoScore: 0,
          listeningPlayerOneScore: 0,
          listeningPlayerTwoScore: 0,
          currentGame: GameType.vocab,
          gameOrder: defaultGameOrder,
          currentGameIndex: 0,
          currentPlayer: 1,
          vocabPlayerOneIds: [],
          vocabPlayerTwoIds: [],
          phrasePlayerOneIds: [],
          phrasePlayerTwoIds: [],
          speedRoundPlayerOneIds: [],
          speedRoundPlayerTwoIds: [],
          matchMadnessPlayerOneIds: [],
          matchMadnessPlayerTwoIds: [],
          spellingBeePlayerOneIds: [],
          spellingBeePlayerTwoIds: [],
          listeningPlayerOneIds: [],
          listeningPlayerTwoIds: [],
          vocabPlayerOneIndex: 0,
          vocabPlayerTwoIndex: 0,
          phrasePlayerOneIndex: 0,
          phrasePlayerTwoIndex: 0,
          speedRoundPlayerOneIndex: 0,
          speedRoundPlayerTwoIndex: 0,
          spellingBeePlayerOneIndex: 0,
          spellingBeePlayerTwoIndex: 0,
          listeningPlayerOneIndex: 0,
          listeningPlayerTwoIndex: 0,
          vocabPlayerOneDone: false,
          vocabPlayerTwoDone: false,
          phrasePlayerOneDone: false,
          phrasePlayerTwoDone: false,
          speedRoundPlayerOneDone: false,
          speedRoundPlayerTwoDone: false,
          matchMadnessPlayerOneDone: false,
          matchMadnessPlayerTwoDone: false,
          spellingBeePlayerOneDone: false,
          spellingBeePlayerTwoDone: false,
          listeningPlayerOneDone: false,
          listeningPlayerTwoDone: false,
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
    List<GameType>? gameOrder,
  }) {
    final resolvedOrder = (gameOrder == null || gameOrder.isEmpty)
        ? defaultGameOrder
        : List<GameType>.from(gameOrder);
    final vocabItems = _pickItems(deck.vocabularyItems, 10);
    final phraseItems = _pickItems(deck.phraseItems, 6);
    final speedItems = _pickItems(deck.vocabularyItems, 20);
    final matchItems = _pickItems(deck.vocabularyItems, 12);
    final spellingItems = _pickItems(deck.vocabularyItems, 10);
    final listeningItems = _pickItems(deck.vocabularyItems, 10);

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
      speedRoundPlayerOneScore: 0,
      speedRoundPlayerTwoScore: 0,
      matchMadnessPlayerOneScore: 0,
      matchMadnessPlayerTwoScore: 0,
      spellingBeePlayerOneScore: 0,
      spellingBeePlayerTwoScore: 0,
      listeningPlayerOneScore: 0,
      listeningPlayerTwoScore: 0,
      currentGame: resolvedOrder.first,
      gameOrder: resolvedOrder,
      currentGameIndex: 0,
      currentPlayer: 1,
      vocabPlayerOneIds: vocabItems.take(5).map((i) => i.id).toList(),
      vocabPlayerTwoIds: vocabItems.skip(5).take(5).map((i) => i.id).toList(),
      phrasePlayerOneIds: phraseItems.take(3).map((i) => i.id).toList(),
      phrasePlayerTwoIds: phraseItems.skip(3).take(3).map((i) => i.id).toList(),
      speedRoundPlayerOneIds:
          speedItems.take(10).map((i) => i.id).toList(),
      speedRoundPlayerTwoIds:
          speedItems.skip(10).take(10).map((i) => i.id).toList(),
      matchMadnessPlayerOneIds:
          matchItems.take(6).map((i) => i.id).toList(),
      matchMadnessPlayerTwoIds:
          matchItems.skip(6).take(6).map((i) => i.id).toList(),
      spellingBeePlayerOneIds:
          spellingItems.take(5).map((i) => i.id).toList(),
      spellingBeePlayerTwoIds:
          spellingItems.skip(5).take(5).map((i) => i.id).toList(),
      listeningPlayerOneIds:
          listeningItems.take(5).map((i) => i.id).toList(),
      listeningPlayerTwoIds:
          listeningItems.skip(5).take(5).map((i) => i.id).toList(),
      vocabPlayerOneIndex: 0,
      vocabPlayerTwoIndex: 0,
      phrasePlayerOneIndex: 0,
      phrasePlayerTwoIndex: 0,
      speedRoundPlayerOneIndex: 0,
      speedRoundPlayerTwoIndex: 0,
      spellingBeePlayerOneIndex: 0,
      spellingBeePlayerTwoIndex: 0,
      listeningPlayerOneIndex: 0,
      listeningPlayerTwoIndex: 0,
      vocabPlayerOneDone: false,
      vocabPlayerTwoDone: false,
      phrasePlayerOneDone: false,
      phrasePlayerTwoDone: false,
      speedRoundPlayerOneDone: false,
      speedRoundPlayerTwoDone: false,
      matchMadnessPlayerOneDone: false,
      matchMadnessPlayerTwoDone: false,
      spellingBeePlayerOneDone: false,
      spellingBeePlayerTwoDone: false,
      listeningPlayerOneDone: false,
      listeningPlayerTwoDone: false,
      status: SessionStatus.inProgress,
    );
    _persist();
  }

  void addScore({required int player, required int points}) {
    if (player == 1) {
      final vocabScore = state.vocabPlayerOneScore +
          (state.currentGame == GameType.vocab ? points : 0);
      final phraseScore = state.phrasePlayerOneScore +
          (state.currentGame == GameType.phrase ? points : 0);
      final speedScore = state.speedRoundPlayerOneScore +
          (state.currentGame == GameType.speedRound ? points : 0);
      final matchScore = state.matchMadnessPlayerOneScore +
          (state.currentGame == GameType.matchMadness ? points : 0);
      final spellingScore = state.spellingBeePlayerOneScore +
          (state.currentGame == GameType.spellingBee ? points : 0);
      final listeningScore = state.listeningPlayerOneScore +
          (state.currentGame == GameType.listening ? points : 0);
      state = state.copyWith(
        playerOneScore: state.playerOneScore + points,
        vocabPlayerOneScore: vocabScore,
        phrasePlayerOneScore: phraseScore,
        speedRoundPlayerOneScore: speedScore,
        matchMadnessPlayerOneScore: matchScore,
        spellingBeePlayerOneScore: spellingScore,
        listeningPlayerOneScore: listeningScore,
      );
    } else {
      final vocabScore = state.vocabPlayerTwoScore +
          (state.currentGame == GameType.vocab ? points : 0);
      final phraseScore = state.phrasePlayerTwoScore +
          (state.currentGame == GameType.phrase ? points : 0);
      final speedScore = state.speedRoundPlayerTwoScore +
          (state.currentGame == GameType.speedRound ? points : 0);
      final matchScore = state.matchMadnessPlayerTwoScore +
          (state.currentGame == GameType.matchMadness ? points : 0);
      final spellingScore = state.spellingBeePlayerTwoScore +
          (state.currentGame == GameType.spellingBee ? points : 0);
      final listeningScore = state.listeningPlayerTwoScore +
          (state.currentGame == GameType.listening ? points : 0);
      state = state.copyWith(
        playerTwoScore: state.playerTwoScore + points,
        vocabPlayerTwoScore: vocabScore,
        phrasePlayerTwoScore: phraseScore,
        speedRoundPlayerTwoScore: speedScore,
        matchMadnessPlayerTwoScore: matchScore,
        spellingBeePlayerTwoScore: spellingScore,
        listeningPlayerTwoScore: listeningScore,
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
    _advanceAfterGame(GameType.vocab);
    _persist();
  }

  void completePhraseForPlayer(int player) {
    if (player == 1) {
      state = state.copyWith(phrasePlayerOneDone: true);
    } else {
      state = state.copyWith(phrasePlayerTwoDone: true);
    }
    _advanceAfterGame(GameType.phrase);
    _persist();
  }

  void completeSpeedRoundForPlayer(int player) {
    if (player == 1) {
      state = state.copyWith(speedRoundPlayerOneDone: true);
    } else {
      state = state.copyWith(speedRoundPlayerTwoDone: true);
    }
    _advanceAfterGame(GameType.speedRound);
    _persist();
  }

  void completeMatchMadnessForPlayer(int player) {
    if (player == 1) {
      state = state.copyWith(matchMadnessPlayerOneDone: true);
    } else {
      state = state.copyWith(matchMadnessPlayerTwoDone: true);
    }
    _advanceAfterGame(GameType.matchMadness);
    _persist();
  }

  void completeSpellingBeeForPlayer(int player) {
    if (player == 1) {
      state = state.copyWith(spellingBeePlayerOneDone: true);
    } else {
      state = state.copyWith(spellingBeePlayerTwoDone: true);
    }
    _advanceAfterGame(GameType.spellingBee);
    _persist();
  }

  void completeListeningForPlayer(int player) {
    if (player == 1) {
      state = state.copyWith(listeningPlayerOneDone: true);
    } else {
      state = state.copyWith(listeningPlayerTwoDone: true);
    }
    _advanceAfterGame(GameType.listening);
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

  void ensureVocabIds(Deck deck) {
    if (deck.vocabularyItems.isEmpty) return;
    final validIds = deck.vocabularyItems.map((item) => item.id).toSet();
    final playerOneValid =
        state.vocabPlayerOneIds.where(validIds.contains).toList();
    final playerTwoValid =
        state.vocabPlayerTwoIds.where(validIds.contains).toList();
    if (playerOneValid.length == 5 && playerTwoValid.length == 5) {
      return;
    }
    final vocabItems = _pickItems(deck.vocabularyItems, 10);
    state = state.copyWith(
      vocabPlayerOneIds: vocabItems.take(5).map((i) => i.id).toList(),
      vocabPlayerTwoIds: vocabItems.skip(5).take(5).map((i) => i.id).toList(),
      vocabPlayerOneIndex: state.vocabPlayerOneIndex.clamp(0, 4),
      vocabPlayerTwoIndex: state.vocabPlayerTwoIndex.clamp(0, 4),
    );
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

  void setSpeedRoundIndex({required int player, required int index}) {
    if (player == 1) {
      state = state.copyWith(speedRoundPlayerOneIndex: index);
    } else {
      state = state.copyWith(speedRoundPlayerTwoIndex: index);
    }
    _persist();
  }

  void setSpellingBeeIndex({required int player, required int index}) {
    if (player == 1) {
      state = state.copyWith(spellingBeePlayerOneIndex: index);
    } else {
      state = state.copyWith(spellingBeePlayerTwoIndex: index);
    }
    _persist();
  }

  void setListeningIndex({required int player, required int index}) {
    if (player == 1) {
      state = state.copyWith(listeningPlayerOneIndex: index);
    } else {
      state = state.copyWith(listeningPlayerTwoIndex: index);
    }
    _persist();
  }

  void _advanceAfterGame(GameType gameType) {
    // Prevent duplicate match saves if session already completed
    if (state.status == SessionStatus.completed) return;

    final gameComplete = switch (gameType) {
      GameType.vocab => state.vocabComplete,
      GameType.phrase => state.phraseComplete,
      GameType.speedRound => state.speedRoundComplete,
      GameType.matchMadness => state.matchMadnessComplete,
      GameType.spellingBee => state.spellingBeeComplete,
      GameType.listening => state.listeningComplete,
    };

    if (gameComplete) {
      final nextIndex = state.currentGameIndex + 1;
      if (nextIndex >= state.gameOrder.length) {
        _saveMatch();
        state = state.copyWith(status: SessionStatus.completed);
        unawaited(_storage.clearSession());
      } else {
        state = state.copyWith(
          currentGameIndex: nextIndex,
          currentGame: state.gameOrder[nextIndex],
        );
      }
      return;
    }

    state = state.copyWith(currentPlayer: state.currentPlayer == 1 ? 2 : 1);
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
      speedRoundPlayerOneScore: 0,
      speedRoundPlayerTwoScore: 0,
      matchMadnessPlayerOneScore: 0,
      matchMadnessPlayerTwoScore: 0,
      spellingBeePlayerOneScore: 0,
      spellingBeePlayerTwoScore: 0,
      currentGame: defaultGameOrder.first,
      gameOrder: defaultGameOrder,
      currentGameIndex: 0,
      currentPlayer: 1,
      vocabPlayerOneIds: [],
      vocabPlayerTwoIds: [],
      phrasePlayerOneIds: [],
      phrasePlayerTwoIds: [],
      speedRoundPlayerOneIds: [],
      speedRoundPlayerTwoIds: [],
      matchMadnessPlayerOneIds: [],
      matchMadnessPlayerTwoIds: [],
      spellingBeePlayerOneIds: [],
      spellingBeePlayerTwoIds: [],
      listeningPlayerOneIds: [],
      listeningPlayerTwoIds: [],
      vocabPlayerOneIndex: 0,
      vocabPlayerTwoIndex: 0,
      phrasePlayerOneIndex: 0,
      phrasePlayerTwoIndex: 0,
      speedRoundPlayerOneIndex: 0,
      speedRoundPlayerTwoIndex: 0,
      spellingBeePlayerOneIndex: 0,
      spellingBeePlayerTwoIndex: 0,
      listeningPlayerOneIndex: 0,
      listeningPlayerTwoIndex: 0,
      vocabPlayerOneDone: false,
      vocabPlayerTwoDone: false,
      phrasePlayerOneDone: false,
      phrasePlayerTwoDone: false,
      speedRoundPlayerOneDone: false,
      speedRoundPlayerTwoDone: false,
      matchMadnessPlayerOneDone: false,
      matchMadnessPlayerTwoDone: false,
      spellingBeePlayerOneDone: false,
      spellingBeePlayerTwoDone: false,
      listeningPlayerOneDone: false,
      listeningPlayerTwoDone: false,
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
