import 'package:riverpod/legacy.dart';

import '../../data/models/content_item.dart';
import '../../data/models/player.dart';
import '../../data/models/deck_progress.dart';
import '../../data/models/solo_session_summary.dart';
import '../../data/models/srs_item.dart';
import '../../data/providers/learner_provider.dart';
import '../../data/providers/solo_history_provider.dart';
import '../../data/providers/srs_provider.dart';
import '../../data/services/srs_service.dart';

class SoloQuestionResult {
  final String itemId;
  final bool isCorrect;
  final int points;
  final int responseTimeMs;
  final DateTime answeredAt;

  const SoloQuestionResult({
    required this.itemId,
    required this.isCorrect,
    required this.points,
    required this.responseTimeMs,
    required this.answeredAt,
  });
}

class SoloPracticeState {
  final List<ContentItem> items;
  final int currentIndex;
  final SoloMode mode;
  final SoloGameType gameType;
  final LanguageDirection direction;
  final bool timerEnabled;
  final String deckId;
  final List<SoloQuestionResult> results;
  final DateTime startedAt;
  final bool isComplete;
  final bool showingFeedback;
  final bool? lastAnswerCorrect;

  const SoloPracticeState({
    required this.items,
    this.currentIndex = 0,
    required this.mode,
    required this.gameType,
    required this.direction,
    required this.timerEnabled,
    required this.deckId,
    this.results = const [],
    required this.startedAt,
    this.isComplete = false,
    this.showingFeedback = false,
    this.lastAnswerCorrect,
  });

  ContentItem get currentItem => items[currentIndex];
  int get totalQuestions => items.length;
  int get correctCount => results.where((r) => r.isCorrect).length;
  int get totalScore => results.fold(0, (sum, r) => sum + r.points);
  double get accuracy =>
      results.isEmpty ? 0.0 : correctCount / results.length;
  bool get hasMoreQuestions => currentIndex < items.length - 1;

  SoloPracticeState copyWith({
    List<ContentItem>? items,
    int? currentIndex,
    SoloMode? mode,
    SoloGameType? gameType,
    LanguageDirection? direction,
    bool? timerEnabled,
    String? deckId,
    List<SoloQuestionResult>? results,
    DateTime? startedAt,
    bool? isComplete,
    bool? showingFeedback,
    bool? lastAnswerCorrect,
  }) {
    return SoloPracticeState(
      items: items ?? this.items,
      currentIndex: currentIndex ?? this.currentIndex,
      mode: mode ?? this.mode,
      gameType: gameType ?? this.gameType,
      direction: direction ?? this.direction,
      timerEnabled: timerEnabled ?? this.timerEnabled,
      deckId: deckId ?? this.deckId,
      results: results ?? this.results,
      startedAt: startedAt ?? this.startedAt,
      isComplete: isComplete ?? this.isComplete,
      showingFeedback: showingFeedback ?? this.showingFeedback,
      lastAnswerCorrect: lastAnswerCorrect ?? this.lastAnswerCorrect,
    );
  }
}

class SoloPracticeController extends StateNotifier<SoloPracticeState> {
  SoloPracticeController({
    required List<ContentItem> items,
    required SoloMode mode,
    required SoloGameType gameType,
    required LanguageDirection direction,
    required String deckId,
    required this.srsService,
    required this.srsController,
    required this.learnerController,
    required this.soloHistoryController,
    required Map<String, SRSItem> srsItems,
  }) : super(SoloPracticeState(
          items: items,
          mode: mode,
          gameType: gameType,
          direction: direction,
          timerEnabled: mode == SoloMode.timed,
          deckId: deckId,
          startedAt: DateTime.now(),
        )) {
    _srsItems = Map<String, SRSItem>.from(srsItems);
  }

  final SrsService srsService;
  final SrsController srsController;
  final LearnerProfileController learnerController;
  final SoloHistoryController soloHistoryController;
  late final Map<String, SRSItem> _srsItems;

  static const int timerMs = 10000; // 10 seconds for vocab flash

  void submitAnswer({
    required bool isCorrect,
    required int responseTimeMs,
    required int points,
  }) {
    final itemId = state.currentItem.id;

    // Add result
    final result = SoloQuestionResult(
      itemId: itemId,
      isCorrect: isCorrect,
      points: points,
      responseTimeMs: responseTimeMs,
      answeredAt: DateTime.now(),
    );

    // Process SRS update
    _processSrsUpdate(itemId, isCorrect, responseTimeMs);

    // Update state with feedback
    state = state.copyWith(
      results: [...state.results, result],
      showingFeedback: true,
      lastAnswerCorrect: isCorrect,
    );
  }

  void _processSrsUpdate(String itemId, bool isCorrect, int responseTimeMs) {
    var item = _srsItems[itemId];
    item ??= SRSItem.newItem(itemId, state.deckId);
    final quality = srsService.calculateQuality(
      isCorrect,
      responseTimeMs,
      state.timerEnabled ? timerMs : 0,
    );
    final updated = srsService.processReview(item, quality, responseTimeMs);
    _srsItems[itemId] = updated;
    srsController.saveItem(updated);
  }

  void nextQuestion() {
    if (state.hasMoreQuestions) {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        showingFeedback: false,
        lastAnswerCorrect: null,
      );
    } else {
      state = state.copyWith(
        isComplete: true,
        showingFeedback: false,
      );
    }
  }

  Future<SoloSessionSummary> completeSession() async {
    final now = DateTime.now();
    final duration = now.difference(state.startedAt);

    final summary = SoloSessionSummary(
      id: now.millisecondsSinceEpoch.toString(),
      deckId: state.items.isNotEmpty ? state.deckId : '',
      mode: state.mode,
      gameType: state.gameType,
      timerEnabled: state.timerEnabled,
      direction: state.direction,
      startedAt: state.startedAt,
      durationSeconds: duration.inSeconds,
      totalQuestions: state.totalQuestions,
      correctCount: state.correctCount,
      score: state.totalScore,
    );

    // Save to history
    await soloHistoryController.addSession(summary);

    // Update learner profile
    await _updateLearnerProfile();

    return summary;
  }

  Future<void> _updateLearnerProfile() async {
    final profileAsync = learnerController.state;
    final profile = profileAsync.value;
    if (profile == null) return;

    final now = DateTime.now();
    final lastPractice = profile.lastPracticeDate;

    // Check if streak continues or resets
    int newStreak = profile.currentStreak;
    if (lastPractice != null) {
      final daysSinceLast = _calendarDayDiff(lastPractice, now);
      if (daysSinceLast == 0) {
        // Same day, no change
      } else if (daysSinceLast == 1) {
        // Next day, streak continues
        newStreak += 1;
      } else {
        // Missed days, reset streak
        newStreak = 1;
      }
    } else {
      newStreak = 1;
    }

    final updatedDeckProgress = _computeDeckProgress();

    final updatedProfile = profile.copyWith(
      totalReviews: profile.totalReviews + state.results.length,
      currentStreak: newStreak,
      longestStreak:
          newStreak > profile.longestStreak ? newStreak : profile.longestStreak,
      lastPracticeDate: now,
      deckProgress: {
        ...profile.deckProgress,
        state.deckId: updatedDeckProgress,
      },
    );

    await learnerController.save(updatedProfile);
  }

  DeckProgress _computeDeckProgress() {
    final itemsForDeck =
        _srsItems.values.where((item) => item.deckId == state.deckId).toList();
    final totalItems = itemsForDeck.length;
    final itemsSeen = itemsForDeck.where((item) => item.totalReviews > 0).length;
    final itemsMastered = itemsForDeck.where((item) => item.isMastered).length;
    final correctCount =
        itemsForDeck.fold<int>(0, (sum, item) => sum + item.correctReviews);
    final totalAttempts =
        itemsForDeck.fold<int>(0, (sum, item) => sum + item.totalReviews);
    DateTime? lastPracticed;
    for (final item in itemsForDeck) {
      if (item.totalReviews == 0) continue;
      if (lastPracticed == null ||
          item.lastReviewDate.isAfter(lastPracticed)) {
        lastPracticed = item.lastReviewDate;
      }
    }
    return DeckProgress(
      deckId: state.deckId,
      itemsSeen: itemsSeen,
      itemsMastered: itemsMastered,
      totalItems: totalItems,
      correctCount: correctCount,
      totalAttempts: totalAttempts,
      lastPracticed: lastPracticed,
    );
  }

  int _calendarDayDiff(DateTime from, DateTime to) {
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    return end.difference(start).inDays;
  }
}

final soloPracticeProvider = StateNotifierProvider.autoDispose
    .family<SoloPracticeController, SoloPracticeState, SoloPracticeConfig>(
  (ref, config) {
    final srsService = SrsService();
    final srsController = ref.read(srsItemsProvider.notifier);
    final learnerController = ref.read(learnerProfileProvider.notifier);
    final soloHistoryController = ref.read(soloHistoryProvider.notifier);
    final srsItems = ref.read(srsItemsProvider).value ?? {};

    return SoloPracticeController(
      items: config.items,
      mode: config.mode,
      gameType: config.gameType,
      direction: config.direction,
      deckId: config.deckId,
      srsService: srsService,
      srsController: srsController,
      learnerController: learnerController,
      soloHistoryController: soloHistoryController,
      srsItems: srsItems,
    );
  },
);

class SoloPracticeConfig {
  final List<ContentItem> items;
  final SoloMode mode;
  final SoloGameType gameType;
  final LanguageDirection direction;
  final String deckId;

  const SoloPracticeConfig({
    required this.items,
    required this.mode,
    required this.gameType,
    required this.direction,
    required this.deckId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SoloPracticeConfig &&
        other.mode == mode &&
        other.gameType == gameType &&
        other.direction == direction &&
        other.deckId == deckId;
  }

  @override
  int get hashCode =>
      mode.hashCode ^ gameType.hashCode ^ direction.hashCode ^ deckId.hashCode;
}
