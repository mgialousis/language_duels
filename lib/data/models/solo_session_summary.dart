import 'package:equatable/equatable.dart';

import 'player.dart';

enum SoloMode { timed, relaxed, srsReview }

enum SoloGameType {
  vocabFlash,
  phraseBuilder,
  mixed,
  speedRound,
  matchMadness,
  spellingBee,
  listening,
}

class SoloSessionSummary extends Equatable {
  final String id;
  final String deckId;
  final SoloMode mode;
  final SoloGameType gameType;
  final bool timerEnabled;
  final LanguageDirection direction;
  final DateTime startedAt;
  final int durationSeconds;
  final int totalQuestions;
  final int correctCount;
  final int score;

  const SoloSessionSummary({
    required this.id,
    required this.deckId,
    required this.mode,
    required this.gameType,
    required this.timerEnabled,
    required this.direction,
    required this.startedAt,
    required this.durationSeconds,
    required this.totalQuestions,
    required this.correctCount,
    required this.score,
  });

  double get accuracy =>
      totalQuestions > 0 ? correctCount / totalQuestions : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deckId': deckId,
      'mode': mode.name,
      'gameType': gameType.name,
      'timerEnabled': timerEnabled,
      'direction': direction.name,
      'startedAt': startedAt.toIso8601String(),
      'durationSeconds': durationSeconds,
      'totalQuestions': totalQuestions,
      'correctCount': correctCount,
      'score': score,
    };
  }

  factory SoloSessionSummary.fromJson(Map<String, dynamic> json) {
    return SoloSessionSummary(
      id: json['id'] as String,
      deckId: json['deckId'] as String,
      mode: SoloMode.values.byName(
        (json['mode'] as String?) ?? SoloMode.timed.name,
      ),
      gameType: SoloGameType.values.byName(
        (json['gameType'] as String?) ?? SoloGameType.vocabFlash.name,
      ),
      timerEnabled: json['timerEnabled'] as bool? ?? true,
      direction: LanguageDirection.values.byName(
        (json['direction'] as String?) ?? LanguageDirection.greekToCatalan.name,
      ),
      startedAt: DateTime.parse(json['startedAt'] as String),
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      correctCount: json['correctCount'] as int? ?? 0,
      score: json['score'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        id,
        deckId,
        mode,
        gameType,
        timerEnabled,
        direction,
        startedAt,
        durationSeconds,
        totalQuestions,
        correctCount,
        score,
      ];
}
