import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/content_item.dart';
import '../../../data/models/player.dart';
import 'spelling_validator.dart';

class SpellingQuestion {
  final String itemId;
  final String sourceText;
  final String sourceRomanization;
  final String correctAnswer;
  final int wordCount;
  final int letterCount;

  const SpellingQuestion({
    required this.itemId,
    required this.sourceText,
    required this.sourceRomanization,
    required this.correctAnswer,
    required this.wordCount,
    required this.letterCount,
  });

  factory SpellingQuestion.fromItem(
    ContentItem item,
    LanguageDirection direction,
  ) {
    final source = direction == LanguageDirection.greekToCatalan
        ? item.greek
        : item.catalan;
    final target = direction == LanguageDirection.greekToCatalan
        ? item.catalan.text
        : item.greek.text;

    return SpellingQuestion(
      itemId: item.id,
      sourceText: source.text,
      sourceRomanization: source.romanization ?? '',
      correctAnswer: target,
      wordCount: target.trim().split(RegExp(r'\s+')).length,
      letterCount: target.replaceAll(' ', '').length,
    );
  }
}

class SpellingState {
  final List<SpellingQuestion> questions;
  final int currentIndex;
  final String userInput;
  final bool isSubmitted;
  final SpellingResult? result;
  final int pointsEarned;
  final int score;
  final bool isComplete;

  const SpellingState({
    required this.questions,
    this.currentIndex = 0,
    this.userInput = '',
    this.isSubmitted = false,
    this.result,
    this.pointsEarned = 0,
    this.score = 0,
    this.isComplete = false,
  });

  SpellingQuestion get currentQuestion => questions[currentIndex];

  SpellingState copyWith({
    List<SpellingQuestion>? questions,
    int? currentIndex,
    String? userInput,
    bool? isSubmitted,
    SpellingResult? result,
    int? pointsEarned,
    int? score,
    bool? isComplete,
  }) {
    return SpellingState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      userInput: userInput ?? this.userInput,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      result: result,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      score: score ?? this.score,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

class SpellingBeeController extends StateNotifier<SpellingState> {
  SpellingBeeController() : super(const SpellingState(questions: []));

  static const int questionsPerRound = 5;

  void initialize(List<ContentItem> items, LanguageDirection direction) {
    final selected = items.take(questionsPerRound).toList();
    final questions = selected
        .map((item) => SpellingQuestion.fromItem(item, direction))
        .toList();
    state = SpellingState(questions: questions);
  }

  void updateInput(String value) {
    if (state.isSubmitted) return;
    state = state.copyWith(userInput: value);
  }

  int submitAnswer({required int remainingSeconds}) {
    if (state.isSubmitted) return 0;
    final result = SpellingValidator.validate(
      state.userInput,
      state.currentQuestion.correctAnswer,
    );

    final points = _pointsForResult(result, remainingSeconds);
    state = state.copyWith(
      isSubmitted: true,
      result: result,
      pointsEarned: points,
      score: state.score + points,
    );
    return points;
  }

  int submitTimeout() {
    if (state.isSubmitted) return 0;
    state = state.copyWith(
      isSubmitted: true,
      result: SpellingResult.wrong,
      pointsEarned: 0,
    );
    return 0;
  }

  void nextQuestion() {
    final nextIndex = state.currentIndex + 1;
    if (nextIndex >= state.questions.length) {
      state = state.copyWith(isComplete: true);
    } else {
      state = state.copyWith(
        currentIndex: nextIndex,
        userInput: '',
        isSubmitted: false,
        result: null,
        pointsEarned: 0,
      );
    }
  }

  int _pointsForResult(SpellingResult result, int remainingSeconds) {
    final base = switch (result) {
      SpellingResult.perfect => 15,
      SpellingResult.accentError => 12,
      SpellingResult.minorError => 8,
      SpellingResult.majorError => 3,
      SpellingResult.wrong => 0,
    };

    if (result != SpellingResult.perfect) return base;

    if (remainingSeconds >= 15) return base + 5;
    if (remainingSeconds >= 10) return base + 3;
    if (remainingSeconds >= 5) return base + 1;
    return base;
  }

  void reset() {
    state = const SpellingState(questions: []);
  }
}

final spellingBeeControllerProvider =
    StateNotifierProvider<SpellingBeeController, SpellingState>((ref) {
      return SpellingBeeController();
    });
