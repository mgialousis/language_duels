import 'dart:math';

import 'package:riverpod/legacy.dart';

import '../../../data/models/content_item.dart';
import '../../../data/models/player.dart';

class SpeedRoundQuestion {
  final String sourceText;
  final String displayedTranslation;
  final bool isCorrect;
  final String actualTranslation;

  const SpeedRoundQuestion({
    required this.sourceText,
    required this.displayedTranslation,
    required this.isCorrect,
    required this.actualTranslation,
  });
}

class SpeedRoundState {
  final List<SpeedRoundQuestion> questions;
  final int currentIndex;
  final List<bool?> answers;
  final bool isAnswered;
  final bool isComplete;

  const SpeedRoundState({
    required this.questions,
    this.currentIndex = 0,
    this.answers = const [],
    this.isAnswered = false,
    this.isComplete = false,
  });

  SpeedRoundQuestion get currentQuestion => questions[currentIndex];

  SpeedRoundState copyWith({
    List<SpeedRoundQuestion>? questions,
    int? currentIndex,
    List<bool?>? answers,
    bool? isAnswered,
    bool? isComplete,
  }) {
    return SpeedRoundState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      isAnswered: isAnswered ?? this.isAnswered,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

class SpeedRoundController extends StateNotifier<SpeedRoundState> {
  SpeedRoundController() : super(const SpeedRoundState(questions: []));

  static const int questionsPerRound = 10;

  void initialize(List<ContentItem> items, LanguageDirection direction) {
    final random = Random();
    final pool = [...items]..shuffle(random);
    final selected = pool.take(questionsPerRound).toList();
    final correctness = List<bool>.generate(
      questionsPerRound,
      (index) => index < (questionsPerRound / 2),
    )..shuffle(random);

    String sourceText(ContentItem item) => direction == LanguageDirection.greekToCatalan
        ? item.greek.text
        : item.catalan.text;

    String targetText(ContentItem item) => direction == LanguageDirection.greekToCatalan
        ? item.catalan.text
        : item.greek.text;

    ContentItem pickDistractor(ContentItem item) {
      final sameCategory = pool
          .where(
            (candidate) =>
                candidate.category == item.category && candidate.id != item.id,
          )
          .toList()
        ..shuffle(random);
      if (sameCategory.isNotEmpty) return sameCategory.first;
      final others = pool.where((candidate) => candidate.id != item.id).toList();
      if (others.isEmpty) return item;
      return others[random.nextInt(others.length)];
    }

    final questions = <SpeedRoundQuestion>[];
    for (var i = 0; i < selected.length; i++) {
      final item = selected[i];
      final makeCorrect = correctness[i % correctness.length];
      if (makeCorrect) {
        questions.add(
          SpeedRoundQuestion(
            sourceText: sourceText(item),
            displayedTranslation: targetText(item),
            isCorrect: true,
            actualTranslation: targetText(item),
          ),
        );
      } else {
        final distractor = pickDistractor(item);
        questions.add(
          SpeedRoundQuestion(
            sourceText: sourceText(item),
            displayedTranslation: targetText(distractor),
            isCorrect: false,
            actualTranslation: targetText(item),
          ),
        );
      }
    }

    state = SpeedRoundState(
      questions: questions,
      answers: List<bool?>.filled(questions.length, null),
    );
  }

  int submitAnswer(bool answer) {
    if (state.isAnswered || state.isComplete) return 0;
    final isCorrect = answer == state.currentQuestion.isCorrect;
    final updatedAnswers = [...state.answers];
    updatedAnswers[state.currentIndex] = answer;
    state = state.copyWith(
      answers: updatedAnswers,
      isAnswered: true,
    );
    return isCorrect ? 5 : 0;
  }

  void markTimeout() {
    if (state.isAnswered || state.isComplete) return;
    state = state.copyWith(isAnswered: true);
  }

  void nextQuestion() {
    final nextIndex = state.currentIndex + 1;
    if (nextIndex >= state.questions.length) {
      state = state.copyWith(isComplete: true);
    } else {
      state = state.copyWith(
        currentIndex: nextIndex,
        isAnswered: false,
      );
    }
  }

  void reset() {
    state = const SpeedRoundState(questions: []);
  }
}

final speedRoundControllerProvider =
    StateNotifierProvider<SpeedRoundController, SpeedRoundState>((ref) {
      return SpeedRoundController();
    });
