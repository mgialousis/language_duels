import 'package:equatable/equatable.dart';

enum SRSState { newItem, learning, mastered, relearning }

class SRSItem extends Equatable {
  final String itemId;
  final String deckId;
  final int repetitions;
  final double easeFactor;
  final int intervalDays;
  final DateTime nextReviewDate;
  final DateTime lastReviewDate;
  final int totalReviews;
  final int correctReviews;
  final SRSState state;
  final int wrongStreak;
  final int resetCount;

  const SRSItem({
    required this.itemId,
    required this.deckId,
    this.repetitions = 0,
    this.easeFactor = 2.5,
    this.intervalDays = 0,
    required this.nextReviewDate,
    required this.lastReviewDate,
    this.totalReviews = 0,
    this.correctReviews = 0,
    this.state = SRSState.newItem,
    this.wrongStreak = 0,
    this.resetCount = 0,
  });

  factory SRSItem.newItem(String itemId, String deckId) {
    final now = DateTime.now();
    return SRSItem(
      itemId: itemId,
      deckId: deckId,
      nextReviewDate: now,
      lastReviewDate: now,
    );
  }

  bool get isDue => !DateTime.now().isBefore(nextReviewDate);

  bool get isWeak =>
      easeFactor < 1.8 || wrongStreak >= 3 || resetCount >= 2;

  bool get isMastered => intervalDays >= 21 && state == SRSState.mastered;

  double get accuracy =>
      totalReviews > 0 ? correctReviews / totalReviews : 0.0;

  SRSItem copyWith({
    int? repetitions,
    double? easeFactor,
    int? intervalDays,
    DateTime? nextReviewDate,
    DateTime? lastReviewDate,
    int? totalReviews,
    int? correctReviews,
    SRSState? state,
    int? wrongStreak,
    int? resetCount,
  }) {
    return SRSItem(
      itemId: itemId,
      deckId: deckId,
      repetitions: repetitions ?? this.repetitions,
      easeFactor: easeFactor ?? this.easeFactor,
      intervalDays: intervalDays ?? this.intervalDays,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      lastReviewDate: lastReviewDate ?? this.lastReviewDate,
      totalReviews: totalReviews ?? this.totalReviews,
      correctReviews: correctReviews ?? this.correctReviews,
      state: state ?? this.state,
      wrongStreak: wrongStreak ?? this.wrongStreak,
      resetCount: resetCount ?? this.resetCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'deckId': deckId,
      'repetitions': repetitions,
      'easeFactor': easeFactor,
      'intervalDays': intervalDays,
      'nextReviewDate': nextReviewDate.toIso8601String(),
      'lastReviewDate': lastReviewDate.toIso8601String(),
      'totalReviews': totalReviews,
      'correctReviews': correctReviews,
      'state': state.name,
      'wrongStreak': wrongStreak,
      'resetCount': resetCount,
    };
  }

  factory SRSItem.fromJson(Map<String, dynamic> json) {
    return SRSItem(
      itemId: json['itemId'] as String,
      deckId: json['deckId'] as String,
      repetitions: json['repetitions'] as int? ?? 0,
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      intervalDays: json['intervalDays'] as int? ?? 0,
      nextReviewDate: DateTime.parse(json['nextReviewDate'] as String),
      lastReviewDate: DateTime.parse(json['lastReviewDate'] as String),
      totalReviews: json['totalReviews'] as int? ?? 0,
      correctReviews: json['correctReviews'] as int? ?? 0,
      state: SRSState.values.byName(
        (json['state'] as String?) ?? SRSState.newItem.name,
      ),
      wrongStreak: json['wrongStreak'] as int? ?? 0,
      resetCount: json['resetCount'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        itemId,
        deckId,
        repetitions,
        easeFactor,
        intervalDays,
        nextReviewDate,
        lastReviewDate,
        totalReviews,
        correctReviews,
        state,
        wrongStreak,
        resetCount,
      ];
}
