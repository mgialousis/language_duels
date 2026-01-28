import 'package:equatable/equatable.dart';

import 'deck_progress.dart';

class LearnerProfile extends Equatable {
  final String ownerId;
  final DateTime createdAt;
  final int totalReviews;
  final int currentStreak;
  final DateTime? lastPracticeDate;
  final int longestStreak;
  final Map<String, DeckProgress> deckProgress;

  const LearnerProfile({
    required this.ownerId,
    required this.createdAt,
    this.totalReviews = 0,
    this.currentStreak = 0,
    this.lastPracticeDate,
    this.longestStreak = 0,
    this.deckProgress = const {},
  });

  factory LearnerProfile.create() {
    return LearnerProfile(
      ownerId: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
    );
  }

  bool get practicedToday {
    if (lastPracticeDate == null) return false;
    final now = DateTime.now();
    return lastPracticeDate!.year == now.year &&
        lastPracticeDate!.month == now.month &&
        lastPracticeDate!.day == now.day;
  }

  double get overallMastery {
    if (deckProgress.isEmpty) return 0.0;
    final total = deckProgress.values.fold<double>(
      0.0,
      (sum, progress) => sum + progress.masteryPercentage,
    );
    return total / deckProgress.length;
  }

  double get overallLearning {
    if (deckProgress.isEmpty) return 0.0;
    final total = deckProgress.values.fold<double>(
      0.0,
      (sum, progress) => sum + progress.learningPercentage,
    );
    return total / deckProgress.length;
  }

  LearnerProfile copyWith({
    String? ownerId,
    DateTime? createdAt,
    int? totalReviews,
    int? currentStreak,
    DateTime? lastPracticeDate,
    int? longestStreak,
    Map<String, DeckProgress>? deckProgress,
  }) {
    return LearnerProfile(
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      totalReviews: totalReviews ?? this.totalReviews,
      currentStreak: currentStreak ?? this.currentStreak,
      lastPracticeDate: lastPracticeDate ?? this.lastPracticeDate,
      longestStreak: longestStreak ?? this.longestStreak,
      deckProgress: deckProgress ?? this.deckProgress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'totalReviews': totalReviews,
      'currentStreak': currentStreak,
      'lastPracticeDate': lastPracticeDate?.toIso8601String(),
      'longestStreak': longestStreak,
      'deckProgress': deckProgress.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };
  }

  factory LearnerProfile.fromJson(Map<String, dynamic> json) {
    final progressJson =
        (json['deckProgress'] as Map<String, dynamic>?) ?? {};
    return LearnerProfile(
      ownerId: json['ownerId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      totalReviews: json['totalReviews'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      lastPracticeDate: json['lastPracticeDate'] == null
          ? null
          : DateTime.parse(json['lastPracticeDate'] as String),
      longestStreak: json['longestStreak'] as int? ?? 0,
      deckProgress: progressJson.map(
        (key, value) => MapEntry(
          key,
          DeckProgress.fromJson((value as Map).cast<String, dynamic>()),
        ),
      ),
    );
  }

  @override
  List<Object?> get props => [
        ownerId,
        createdAt,
        totalReviews,
        currentStreak,
        lastPracticeDate,
        longestStreak,
        deckProgress,
      ];
}
