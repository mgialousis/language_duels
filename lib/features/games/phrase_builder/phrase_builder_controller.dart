import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/answer_feedback.dart';

class PhraseBuilderState {
  final int phraseIndex;
  final bool isSubmitted;
  final AnswerFeedbackState feedbackState;
  final String feedbackMessage;
  final bool hintUsed;
  final bool isComplete;

  const PhraseBuilderState({
    required this.phraseIndex,
    required this.isSubmitted,
    required this.feedbackState,
    required this.feedbackMessage,
    required this.hintUsed,
    required this.isComplete,
  });

  PhraseBuilderState copyWith({
    int? phraseIndex,
    bool? isSubmitted,
    AnswerFeedbackState? feedbackState,
    String? feedbackMessage,
    bool? hintUsed,
    bool? isComplete,
  }) {
    return PhraseBuilderState(
      phraseIndex: phraseIndex ?? this.phraseIndex,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      feedbackState: feedbackState ?? this.feedbackState,
      feedbackMessage: feedbackMessage ?? this.feedbackMessage,
      hintUsed: hintUsed ?? this.hintUsed,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

class PhraseBuilderController extends StateNotifier<PhraseBuilderState> {
  PhraseBuilderController()
    : super(
        const PhraseBuilderState(
          phraseIndex: 0,
          isSubmitted: false,
          feedbackState: AnswerFeedbackState.neutral,
          feedbackMessage: 'Reorder the words and submit',
          hintUsed: false,
          isComplete: false,
        ),
      );

  void nextPhrase() {
    final nextIndex = state.phraseIndex + 1;
    if (nextIndex >= 3) {
      state = state.copyWith(isComplete: true);
    } else {
      state = state.copyWith(phraseIndex: nextIndex);
    }
  }

  void setPhraseIndex(int index) {
    state = state.copyWith(phraseIndex: index);
  }

  void setSubmitted(bool value) {
    state = state.copyWith(isSubmitted: value);
  }

  void setFeedback(AnswerFeedbackState feedbackState, String message) {
    state = state.copyWith(
      feedbackState: feedbackState,
      feedbackMessage: message,
    );
  }

  void setHintUsed(bool value) {
    state = state.copyWith(hintUsed: value);
  }

  void reset() {
    state = const PhraseBuilderState(
      phraseIndex: 0,
      isSubmitted: false,
      feedbackState: AnswerFeedbackState.neutral,
      feedbackMessage: 'Reorder the words and submit',
      hintUsed: false,
      isComplete: false,
    );
  }
}

final phraseBuilderControllerProvider =
    StateNotifierProvider<PhraseBuilderController, PhraseBuilderState>((ref) {
      return PhraseBuilderController();
    });
