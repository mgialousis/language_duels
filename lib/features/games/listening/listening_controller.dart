import 'dart:math';

import 'package:riverpod/legacy.dart';

import '../../../data/models/content_item.dart';
import '../../../data/models/player.dart';
import '../../../shared/widgets/answer_feedback.dart';

class ListeningQuestion {
  final String itemId;
  final String audioText;
  final String audioLanguage;
  final String correctAnswer;
  final List<String> options;
  final int correctIndex;

  const ListeningQuestion({
    required this.itemId,
    required this.audioText,
    required this.audioLanguage,
    required this.correctAnswer,
    required this.options,
    required this.correctIndex,
  });
}

class ListeningState {
  final List<ListeningQuestion> questions;
  final int currentIndex;
  final bool hasPlayedAudio;
  final int replayCount;
  final int? selectedIndex;
  final bool isAnswered;
  final AnswerFeedbackState feedbackState;
  final String feedbackMessage;
  final int score;
  final bool isComplete;

  const ListeningState({
    required this.questions,
    this.currentIndex = 0,
    this.hasPlayedAudio = false,
    this.replayCount = 0,
    this.selectedIndex,
    this.isAnswered = false,
    this.feedbackState = AnswerFeedbackState.neutral,
    this.feedbackMessage = 'Listen and choose the correct answer.',
    this.score = 0,
    this.isComplete = false,
  });

  ListeningQuestion get currentQuestion => questions[currentIndex];

  ListeningState copyWith({
    List<ListeningQuestion>? questions,
    int? currentIndex,
    bool? hasPlayedAudio,
    int? replayCount,
    int? selectedIndex,
    bool? isAnswered,
    AnswerFeedbackState? feedbackState,
    String? feedbackMessage,
    int? score,
    bool? isComplete,
  }) {
    return ListeningState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      hasPlayedAudio: hasPlayedAudio ?? this.hasPlayedAudio,
      replayCount: replayCount ?? this.replayCount,
      selectedIndex: selectedIndex,
      isAnswered: isAnswered ?? this.isAnswered,
      feedbackState: feedbackState ?? this.feedbackState,
      feedbackMessage: feedbackMessage ?? this.feedbackMessage,
      score: score ?? this.score,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

class ListeningController extends StateNotifier<ListeningState> {
  ListeningController() : super(const ListeningState(questions: []));

  static const int questionsPerRound = 5;

  void initialize(List<ContentItem> items, LanguageDirection direction) {
    final random = Random();
    final pool = [...items]..shuffle(random);
    final selected = pool.take(questionsPerRound).toList();

    String sourceText(ContentItem item) => direction == LanguageDirection.greekToCatalan
        ? item.greek.text
        : item.catalan.text;

    String targetText(ContentItem item) => direction == LanguageDirection.greekToCatalan
        ? item.catalan.text
        : item.greek.text;

    String audioLanguage(LanguageDirection direction) =>
        direction == LanguageDirection.greekToCatalan ? 'el' : 'ca';

    List<String> buildOptions(ContentItem correct) {
      final options = <String>[targetText(correct)];
      final sameCategory = pool
          .where(
            (item) => item.category == correct.category && item.id != correct.id,
          )
          .toList()
        ..shuffle(random);
      for (final item in sameCategory) {
        if (options.length >= 4) break;
        final candidate = targetText(item);
        if (!options.contains(candidate)) {
          options.add(candidate);
        }
      }
      final others = pool.where((item) => item.id != correct.id).toList()
        ..shuffle(random);
      for (final item in others) {
        if (options.length >= 4) break;
        final candidate = targetText(item);
        if (!options.contains(candidate)) {
          options.add(candidate);
        }
      }
      options.shuffle(random);
      return options;
    }

    final questions = selected.map((item) {
      final options = buildOptions(item);
      final correctIndex = options.indexOf(targetText(item));
      return ListeningQuestion(
        itemId: item.id,
        audioText: sourceText(item),
        audioLanguage: audioLanguage(direction),
        correctAnswer: targetText(item),
        options: options,
        correctIndex: correctIndex,
      );
    }).toList();

    state = ListeningState(questions: questions);
  }

  void markAudioPlayed() {
    if (state.hasPlayedAudio) return;
    state = state.copyWith(hasPlayedAudio: true);
  }

  void markReplay() {
    state = state.copyWith(replayCount: state.replayCount + 1);
  }

  int submitAnswer(int index, {required int remainingSeconds}) {
    if (state.isAnswered) return 0;
    final isCorrect = index == state.currentQuestion.correctIndex;
    final replayPenalty = state.replayCount > 0 ? 2 : 0;
    final speedBonus = isCorrect ? _speedBonus(remainingSeconds) : 0;
    final points = isCorrect ? 10 + speedBonus - replayPenalty : 0;

    state = state.copyWith(
      selectedIndex: index,
      isAnswered: true,
      score: state.score + points,
      feedbackState:
          isCorrect ? AnswerFeedbackState.correct : AnswerFeedbackState.incorrect,
      feedbackMessage: isCorrect
          ? 'Correct! +$points points.'
          : 'Not quite. Correct: ${state.currentQuestion.correctAnswer}',
    );
    return points;
  }

  void markTimeout() {
    if (state.isAnswered) return;
    state = state.copyWith(
      isAnswered: true,
      feedbackState: AnswerFeedbackState.incorrect,
      feedbackMessage: "Time's up! Correct: ${state.currentQuestion.correctAnswer}",
    );
  }

  void nextQuestion() {
    final nextIndex = state.currentIndex + 1;
    if (nextIndex >= state.questions.length) {
      state = state.copyWith(isComplete: true);
    } else {
      state = state.copyWith(
        currentIndex: nextIndex,
        selectedIndex: null,
        isAnswered: false,
        replayCount: 0,
        hasPlayedAudio: false,
        feedbackState: AnswerFeedbackState.neutral,
        feedbackMessage: 'Listen and choose the correct answer.',
      );
    }
  }

  void reset() {
    state = const ListeningState(questions: []);
  }

  int _speedBonus(int remainingSeconds) {
    if (remainingSeconds >= 8) return 5;
    if (remainingSeconds >= 5) return 3;
    if (remainingSeconds >= 2) return 1;
    return 0;
  }
}

final listeningControllerProvider =
    StateNotifierProvider<ListeningController, ListeningState>((ref) {
      return ListeningController();
    });
