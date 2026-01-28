import 'dart:math';

import 'package:riverpod/legacy.dart';

const _noChange = Object();

class MatchPair {
  final String id;
  final String sourceText;
  final String targetText;
  final bool isMatched;

  const MatchPair({
    required this.id,
    required this.sourceText,
    required this.targetText,
    this.isMatched = false,
  });

  MatchPair copyWith({bool? isMatched}) {
    return MatchPair(
      id: id,
      sourceText: sourceText,
      targetText: targetText,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}

enum MatchFeedback { correct, wrong }

enum MatchAttemptResult { matched, wrong, ignored }

class MatchMadnessState {
  final List<MatchPair> pairs;
  final List<String> sourceOrder;
  final List<String> targetOrder;
  final String? selectedSourceId;
  final String? selectedTargetId;
  final String? wrongSourceId;
  final String? wrongTargetId;
  final MatchFeedback? feedback;
  final int matchedCount;
  final int score;
  final bool isComplete;

  const MatchMadnessState({
    required this.pairs,
    required this.sourceOrder,
    required this.targetOrder,
    this.selectedSourceId,
    this.selectedTargetId,
    this.wrongSourceId,
    this.wrongTargetId,
    this.feedback,
    this.matchedCount = 0,
    this.score = 0,
    this.isComplete = false,
  });

  MatchMadnessState copyWith({
    List<MatchPair>? pairs,
    List<String>? sourceOrder,
    List<String>? targetOrder,
    Object? selectedSourceId = _noChange,
    Object? selectedTargetId = _noChange,
    Object? wrongSourceId = _noChange,
    Object? wrongTargetId = _noChange,
    Object? feedback = _noChange,
    int? matchedCount,
    int? score,
    bool? isComplete,
  }) {
    return MatchMadnessState(
      pairs: pairs ?? this.pairs,
      sourceOrder: sourceOrder ?? this.sourceOrder,
      targetOrder: targetOrder ?? this.targetOrder,
      selectedSourceId: selectedSourceId == _noChange
          ? this.selectedSourceId
          : selectedSourceId as String?,
      selectedTargetId: selectedTargetId == _noChange
          ? this.selectedTargetId
          : selectedTargetId as String?,
      wrongSourceId: wrongSourceId == _noChange
          ? this.wrongSourceId
          : wrongSourceId as String?,
      wrongTargetId: wrongTargetId == _noChange
          ? this.wrongTargetId
          : wrongTargetId as String?,
      feedback: feedback == _noChange
          ? this.feedback
          : feedback as MatchFeedback?,
      matchedCount: matchedCount ?? this.matchedCount,
      score: score ?? this.score,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  MatchPair pairForId(String id) => pairs.firstWhere((pair) => pair.id == id);
}

class MatchMadnessController extends StateNotifier<MatchMadnessState> {
  MatchMadnessController()
      : super(
          const MatchMadnessState(
            pairs: [],
            sourceOrder: [],
            targetOrder: [],
          ),
        );

  void initialize(List<MatchPair> pairs) {
    final random = Random();
    final sourceOrder = pairs.map((pair) => pair.id).toList()..shuffle(random);
    final targetOrder = pairs.map((pair) => pair.id).toList()..shuffle(random);
    state = MatchMadnessState(
      pairs: pairs,
      sourceOrder: sourceOrder,
      targetOrder: targetOrder,
    );
  }

  void selectSource(String id) {
    if (state.isComplete || state.pairForId(id).isMatched) return;
    state = state.copyWith(
      selectedSourceId: id,
      wrongSourceId: null,
      wrongTargetId: null,
      feedback: null,
    );
  }

  MatchAttemptResult selectTarget(String id) {
    if (state.isComplete || state.pairForId(id).isMatched) {
      return MatchAttemptResult.ignored;
    }
    final selectedSourceId = state.selectedSourceId;
    if (selectedSourceId == null) {
      state = state.copyWith(
        selectedTargetId: id,
        wrongSourceId: null,
        wrongTargetId: null,
        feedback: null,
      );
      return MatchAttemptResult.ignored;
    }

    if (selectedSourceId == id) {
      final updatedPairs = state.pairs
          .map(
            (pair) => pair.id == id ? pair.copyWith(isMatched: true) : pair,
          )
          .toList();
      final matchedCount = state.matchedCount + 1;
      state = state.copyWith(
        pairs: updatedPairs,
        matchedCount: matchedCount,
        score: state.score + 3,
        feedback: MatchFeedback.correct,
        selectedSourceId: null,
        selectedTargetId: null,
        wrongSourceId: null,
        wrongTargetId: null,
      );
      if (matchedCount >= updatedPairs.length) {
        state = state.copyWith(isComplete: true);
      }
      return MatchAttemptResult.matched;
    }

    state = state.copyWith(
      feedback: MatchFeedback.wrong,
      wrongSourceId: selectedSourceId,
      wrongTargetId: id,
      selectedSourceId: null,
      selectedTargetId: null,
    );

    Future.delayed(const Duration(milliseconds: 350), () {
      // Only clear if still in wrong state (controller may have been disposed)
      if (state.wrongSourceId != null || state.wrongTargetId != null) {
        state = state.copyWith(
          wrongSourceId: null,
          wrongTargetId: null,
          feedback: null,
        );
      }
    });

    return MatchAttemptResult.wrong;
  }

  void applyTimeBonus(int bonus) {
    if (bonus <= 0) return;
    state = state.copyWith(score: state.score + bonus);
  }

  void reset() {
    state = const MatchMadnessState(
      pairs: [],
      sourceOrder: [],
      targetOrder: [],
    );
  }
}

final matchMadnessControllerProvider =
    StateNotifierProvider<MatchMadnessController, MatchMadnessState>((ref) {
      return MatchMadnessController();
    });
