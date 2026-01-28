import 'package:equatable/equatable.dart';

enum GrammarMasteryLevel {
  notStarted,
  learning,
  practicing,
  reviewing,
  mastered,
}

class GrammarProgress extends Equatable {
  final String lessonId;
  final bool isUnlocked;
  final bool explanationRead;
  final int exercisesCompleted;
  final int exercisesTotal;
  final double accuracy;
  final DateTime? lastPracticed;
  final int reviewCount;
  final GrammarMasteryLevel masteryLevel;

  const GrammarProgress({
    required this.lessonId,
    this.isUnlocked = false,
    this.explanationRead = false,
    this.exercisesCompleted = 0,
    this.exercisesTotal = 0,
    this.accuracy = 0.0,
    this.lastPracticed,
    this.reviewCount = 0,
    this.masteryLevel = GrammarMasteryLevel.notStarted,
  });

  factory GrammarProgress.fromJson(Map<String, dynamic> json) {
    return GrammarProgress(
      lessonId: json['lessonId'] as String,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      explanationRead: json['explanationRead'] as bool? ?? false,
      exercisesCompleted: json['exercisesCompleted'] as int? ?? 0,
      exercisesTotal: json['exercisesTotal'] as int? ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      lastPracticed: json['lastPracticed'] == null
          ? null
          : DateTime.parse(json['lastPracticed'] as String),
      reviewCount: json['reviewCount'] as int? ?? 0,
      masteryLevel: GrammarMasteryLevel.values.byName(
        (json['masteryLevel'] as String?) ??
            GrammarMasteryLevel.notStarted.name,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'isUnlocked': isUnlocked,
      'explanationRead': explanationRead,
      'exercisesCompleted': exercisesCompleted,
      'exercisesTotal': exercisesTotal,
      'accuracy': accuracy,
      'lastPracticed': lastPracticed?.toIso8601String(),
      'reviewCount': reviewCount,
      'masteryLevel': masteryLevel.name,
    };
  }

  GrammarProgress copyWith({
    bool? isUnlocked,
    bool? explanationRead,
    int? exercisesCompleted,
    int? exercisesTotal,
    double? accuracy,
    DateTime? lastPracticed,
    int? reviewCount,
    GrammarMasteryLevel? masteryLevel,
  }) {
    return GrammarProgress(
      lessonId: lessonId,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      explanationRead: explanationRead ?? this.explanationRead,
      exercisesCompleted: exercisesCompleted ?? this.exercisesCompleted,
      exercisesTotal: exercisesTotal ?? this.exercisesTotal,
      accuracy: accuracy ?? this.accuracy,
      lastPracticed: lastPracticed ?? this.lastPracticed,
      reviewCount: reviewCount ?? this.reviewCount,
      masteryLevel: masteryLevel ?? this.masteryLevel,
    );
  }

  @override
  List<Object?> get props => [lessonId, masteryLevel, accuracy];
}
