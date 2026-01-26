import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/answer_feedback.dart';

class VocabFlashState {
  final int questionIndex;
  final bool isAnswered;
  final AnswerFeedbackState feedbackState;
  final String feedbackMessage;
  final bool isComplete;

  const VocabFlashState({
    required this.questionIndex,
    required this.isAnswered,
    required this.feedbackState,
    required this.feedbackMessage,
    required this.isComplete,
  });

  VocabFlashState copyWith({
    int? questionIndex,
    bool? isAnswered,
    AnswerFeedbackState? feedbackState,
    String? feedbackMessage,
    bool? isComplete,
  }) {
    return VocabFlashState(
      questionIndex: questionIndex ?? this.questionIndex,
      isAnswered: isAnswered ?? this.isAnswered,
      feedbackState: feedbackState ?? this.feedbackState,
      feedbackMessage: feedbackMessage ?? this.feedbackMessage,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

class VocabFlashController extends StateNotifier<VocabFlashState> {
  VocabFlashController()
    : super(
        const VocabFlashState(
          questionIndex: 0,
          isAnswered: false,
          feedbackState: AnswerFeedbackState.neutral,
          feedbackMessage: 'Select the correct translation',
          isComplete: false,
        ),
      );

  void nextQuestion() {
    final nextIndex = state.questionIndex + 1;
    if (nextIndex >= 5) {
      state = state.copyWith(isComplete: true);
    } else {
      state = state.copyWith(questionIndex: nextIndex);
    }
  }

  void setQuestionIndex(int index) {
    state = state.copyWith(questionIndex: index);
  }

  void setAnswered(bool value) {
    state = state.copyWith(isAnswered: value);
  }

  void setFeedback(AnswerFeedbackState feedbackState, String message) {
    state = state.copyWith(
      feedbackState: feedbackState,
      feedbackMessage: message,
    );
  }

  void reset() {
    state = const VocabFlashState(
      questionIndex: 0,
      isAnswered: false,
      feedbackState: AnswerFeedbackState.neutral,
      feedbackMessage: 'Select the correct translation',
      isComplete: false,
    );
  }
}

final vocabFlashControllerProvider =
    StateNotifierProvider<VocabFlashController, VocabFlashState>((ref) {
      return VocabFlashController();
    });
