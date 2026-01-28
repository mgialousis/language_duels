import 'package:riverpod/legacy.dart';

import '../../../data/models/grammar_exercise.dart';
import '../../games/spelling_bee/spelling_validator.dart';

class GrammarExerciseState {
  final List<GrammarExercise> exercises;
  final int currentIndex;
  final bool isSubmitted;
  final bool? isCorrect;
  final int score;
  final Object? userAnswer;
  final bool isComplete;

  const GrammarExerciseState({
    required this.exercises,
    this.currentIndex = 0,
    this.isSubmitted = false,
    this.isCorrect,
    this.score = 0,
    this.userAnswer,
    this.isComplete = false,
  });

  GrammarExercise get currentExercise => exercises[currentIndex];

  GrammarExerciseState copyWith({
    List<GrammarExercise>? exercises,
    int? currentIndex,
    bool? isSubmitted,
    bool? isCorrect,
    int? score,
    Object? userAnswer,
    bool? isComplete,
  }) {
    return GrammarExerciseState(
      exercises: exercises ?? this.exercises,
      currentIndex: currentIndex ?? this.currentIndex,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      isCorrect: isCorrect,
      score: score ?? this.score,
      userAnswer: userAnswer ?? this.userAnswer,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

class GrammarExerciseController extends StateNotifier<GrammarExerciseState> {
  GrammarExerciseController() : super(const GrammarExerciseState(exercises: []));

  void initialize(List<GrammarExercise> exercises) {
    state = GrammarExerciseState(exercises: exercises);
  }

  void updateAnswer(Object? value) {
    if (state.isSubmitted) return;
    state = state.copyWith(userAnswer: value);
  }

  void submitAnswer(Object? answer) {
    if (state.isSubmitted) return;
    final exercise = state.currentExercise;
    final isCorrect = _isAnswerCorrect(exercise, answer);
    final points = isCorrect ? 10 : 0;
    state = state.copyWith(
      isSubmitted: true,
      isCorrect: isCorrect,
      score: state.score + points,
      userAnswer: answer,
    );
  }

  void nextExercise() {
    final nextIndex = state.currentIndex + 1;
    if (nextIndex >= state.exercises.length) {
      state = state.copyWith(
        isComplete: true,
        isSubmitted: false,
      );
    } else {
      state = state.copyWith(
        currentIndex: nextIndex,
        isSubmitted: false,
        isCorrect: null,
        userAnswer: null,
      );
    }
  }

  bool _isAnswerCorrect(GrammarExercise exercise, Object? answer) {
    switch (exercise.type) {
      case GrammarExerciseType.matching:
        return _isMatchingCorrect(exercise, answer);
      case GrammarExerciseType.conjugation:
      case GrammarExerciseType.tableCompletion:
        return _isConjugationCorrect(exercise, answer);
      case GrammarExerciseType.fillBlank:
      case GrammarExerciseType.multipleChoice:
      case GrammarExerciseType.translation:
      case GrammarExerciseType.errorCorrection:
      case GrammarExerciseType.transformation:
        return _isStringCorrect(exercise, answer);
    }
  }

  bool _isMatchingCorrect(GrammarExercise exercise, Object? answer) {
    if (exercise.pairs == null || exercise.pairs!.isEmpty) {
      return _isStringCorrect(exercise, answer);
    }
    if (answer is! Map) return false;
    for (final pair in exercise.pairs!) {
      final userValue = answer[pair.left];
      if (userValue is! String) return false;
      if (!_matches(userValue, pair.right)) return false;
    }
    return true;
  }

  bool _isConjugationCorrect(GrammarExercise exercise, Object? answer) {
    if (exercise.conjugations == null || exercise.conjugations!.isEmpty) {
      return _isStringCorrect(exercise, answer);
    }
    if (answer is! Map) return false;
    for (final item in exercise.conjugations!) {
      final userValue = answer[item.label];
      if (userValue is! String) return false;
      final candidates = <String>{item.answer};
      if (item.acceptableAnswers != null) {
        candidates.addAll(item.acceptableAnswers!);
      }
      var match = false;
      for (final candidate in candidates) {
        if (_matches(userValue, candidate)) {
          match = true;
          break;
        }
      }
      if (!match) return false;
    }
    return true;
  }

  bool _isStringCorrect(GrammarExercise exercise, Object? answer) {
    if (answer is! String) return false;
    final normalized = answer.trim();
    final candidates = <String>{exercise.correctAnswer};
    if (exercise.acceptableAnswers != null) {
      candidates.addAll(exercise.acceptableAnswers!);
    }

    for (final candidate in candidates) {
      if (_matches(normalized, candidate)) {
        return true;
      }
    }
    return false;
  }

  bool _matches(String userAnswer, String candidate) {
    final result = SpellingValidator.validate(userAnswer, candidate);
    return result == SpellingResult.perfect ||
        result == SpellingResult.accentError;
  }
}

final grammarExerciseControllerProvider = StateNotifierProvider.autoDispose<
    GrammarExerciseController, GrammarExerciseState>((ref) {
  return GrammarExerciseController();
});
