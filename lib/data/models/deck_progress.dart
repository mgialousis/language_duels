import 'package:equatable/equatable.dart';

class DeckProgress extends Equatable {
  final String deckId;
  final int itemsSeen;
  final int itemsMastered;
  final int totalItems;
  final int correctCount;
  final int totalAttempts;
  final DateTime? lastPracticed;

  const DeckProgress({
    required this.deckId,
    this.itemsSeen = 0,
    this.itemsMastered = 0,
    required this.totalItems,
    this.correctCount = 0,
    this.totalAttempts = 0,
    this.lastPracticed,
  });

  double get masteryPercentage =>
      totalItems > 0 ? (itemsMastered / totalItems) * 100 : 0.0;

  double get learningPercentage =>
      totalItems > 0 ? (itemsSeen / totalItems) * 100 : 0.0;

  double get accuracy =>
      totalAttempts > 0 ? (correctCount / totalAttempts) * 100 : 0.0;

  String get progressLevel {
    final pct = masteryPercentage;
    if (pct >= 100) return 'master';
    if (pct >= 76) return 'expert';
    if (pct >= 51) return 'advanced';
    if (pct >= 26) return 'intermediate';
    return 'beginner';
  }

  DeckProgress copyWith({
    String? deckId,
    int? itemsSeen,
    int? itemsMastered,
    int? totalItems,
    int? correctCount,
    int? totalAttempts,
    DateTime? lastPracticed,
  }) {
    return DeckProgress(
      deckId: deckId ?? this.deckId,
      itemsSeen: itemsSeen ?? this.itemsSeen,
      itemsMastered: itemsMastered ?? this.itemsMastered,
      totalItems: totalItems ?? this.totalItems,
      correctCount: correctCount ?? this.correctCount,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      lastPracticed: lastPracticed ?? this.lastPracticed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deckId': deckId,
      'itemsSeen': itemsSeen,
      'itemsMastered': itemsMastered,
      'totalItems': totalItems,
      'correctCount': correctCount,
      'totalAttempts': totalAttempts,
      'lastPracticed': lastPracticed?.toIso8601String(),
    };
  }

  factory DeckProgress.fromJson(Map<String, dynamic> json) {
    return DeckProgress(
      deckId: json['deckId'] as String,
      itemsSeen: json['itemsSeen'] as int? ?? 0,
      itemsMastered: json['itemsMastered'] as int? ?? 0,
      totalItems: json['totalItems'] as int? ?? 0,
      correctCount: json['correctCount'] as int? ?? 0,
      totalAttempts: json['totalAttempts'] as int? ?? 0,
      lastPracticed: json['lastPracticed'] == null
          ? null
          : DateTime.parse(json['lastPracticed'] as String),
    );
  }

  @override
  List<Object?> get props => [
        deckId,
        itemsSeen,
        itemsMastered,
        totalItems,
        correctCount,
        totalAttempts,
        lastPracticed,
      ];
}
