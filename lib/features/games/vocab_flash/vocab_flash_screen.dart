import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../data/models/content_item.dart';
import '../../../data/models/player.dart';
import '../../../data/providers/content_provider.dart';
import '../../../data/providers/game_session_provider.dart';
import '../../../data/providers/settings_provider.dart';
import '../../../data/providers/sound_provider.dart';
import '../../../features/games/vocab_flash/vocab_flash_controller.dart';
import '../../../shared/widgets/answer_feedback.dart';
import '../../../shared/widgets/duel_button.dart';
import '../../../shared/widgets/flash_card.dart';
import '../../../shared/widgets/option_tile.dart';
import '../../../shared/widgets/score_board.dart';
import '../../../shared/widgets/timer_bar.dart';
import '../../../shared/widgets/async_state.dart';

class VocabFlashScreen extends ConsumerStatefulWidget {
  const VocabFlashScreen({super.key});

  @override
  ConsumerState<VocabFlashScreen> createState() => _VocabFlashScreenState();
}

class _VocabFlashScreenState extends ConsumerState<VocabFlashScreen>
    with WidgetsBindingObserver {
  static const int _totalSeconds = 10;
  static const int _questionsPerPlayer = 5;

  Timer? _timer;
  int _remainingSeconds = _totalSeconds;
  bool _showPauseOverlay = false;
  List<ContentItem> _options = [];
  ContentItem? _currentItem;
  final Map<String, List<String>> _confusionPairs = const {
    'greet_001': ['greet_002', 'greet_003', 'greet_004'],
    'greet_002': ['greet_001', 'greet_003', 'greet_004'],
    'greet_003': ['greet_001', 'greet_002', 'greet_004'],
    'greet_004': ['greet_001', 'greet_002', 'greet_003'],
    'greet_008': ['greet_009'],
    'greet_009': ['greet_008'],
    'greet_010': ['greet_011', 'greet_012'],
    'greet_011': ['greet_010', 'greet_012'],
    'greet_019': ['greet_020'],
    'greet_020': ['greet_019'],
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(vocabFlashControllerProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _pauseGame();
    }
  }

  void _pauseGame() {
    if (_showPauseOverlay) return;
    _timer?.cancel();
    setState(() => _showPauseOverlay = true);
  }

  void _resumeGame() {
    final timersEnabled = ref.read(settingsProvider).timersEnabled;
    setState(() => _showPauseOverlay = false);
    if (!ref.read(vocabFlashControllerProvider).isAnswered && timersEnabled) {
      _startTimer();
    }
  }

  void _startTimer() {
    final timersEnabled = ref.read(settingsProvider).timersEnabled;
    if (!timersEnabled) {
      _timer?.cancel();
      _remainingSeconds = _totalSeconds;
      return;
    }
    _timer?.cancel();
    _remainingSeconds = _totalSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        _handleTimeout();
      } else {
        setState(() {
          _remainingSeconds -= 1;
        });
      }
    });
  }

  void _handleTimeout() {
    final controller = ref.read(vocabFlashControllerProvider.notifier);
    if (ref.read(vocabFlashControllerProvider).isAnswered) {
      return;
    }
    final soundEnabled = ref.read(settingsProvider).soundEnabled;
    ref.read(soundProvider).playError(soundEnabled);
    final correct = _currentItem;
    setState(() {
      controller.setAnswered(true);
      controller.setFeedback(
        AnswerFeedbackState.incorrect,
        correct == null
            ? 'Time\'s up! 0 points.'
            : "Time's up! Correct: ${_formatAnswer(correct)}",
      );
    });
    _advanceAfterDelay(pointsAwarded: 0);
  }

  void _advanceAfterDelay({required int pointsAwarded}) {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      _nextQuestionOrEnd(pointsAwarded: pointsAwarded);
    });
  }

  void _nextQuestionOrEnd({required int pointsAwarded}) {
    final session = ref.read(gameSessionProvider);
    final controller = ref.read(vocabFlashControllerProvider.notifier);
    ref
        .read(gameSessionProvider.notifier)
        .addScore(player: session.currentPlayer, points: pointsAwarded);

    final nextIndex = ref.read(vocabFlashControllerProvider).questionIndex + 1;
    ref
        .read(gameSessionProvider.notifier)
        .setVocabIndex(player: session.currentPlayer, index: nextIndex);

    if (nextIndex >= _questionsPerPlayer) {
      ref
          .read(gameSessionProvider.notifier)
          .completeVocabForPlayer(session.currentPlayer);
      final updated = ref.read(gameSessionProvider);
      if (updated.status == SessionStatus.completed) {
        context.go(resultsRoute);
        return;
      }
      final nextRoute =
          updated.currentGame == GameType.vocab ? transitionRoute : duelRoute;
      context.go(nextRoute);
      return;
    }

    controller.setQuestionIndex(nextIndex);
    controller.setAnswered(false);
    controller.setFeedback(
      AnswerFeedbackState.neutral,
      'Select the correct translation',
    );
    _prepareQuestion();
  }

  void _prepareQuestion() {
    final deckAsync = ref.read(deckProvider);
    final session = ref.read(gameSessionProvider);
    final timersEnabled = ref.read(settingsProvider).timersEnabled;
    final controller = ref.read(vocabFlashControllerProvider.notifier);
    deckAsync.whenData((deck) {
      ref.read(gameSessionProvider.notifier).ensureVocabIds(deck);
      final refreshedSession = ref.read(gameSessionProvider);
      final currentIndex = _currentIndexForPlayer(refreshedSession);
      controller.setQuestionIndex(currentIndex);
      if (currentIndex >= _questionsPerPlayer) {
        ref
            .read(gameSessionProvider.notifier)
            .completeVocabForPlayer(session.currentPlayer);
        final updated = ref.read(gameSessionProvider);
        if (updated.status == SessionStatus.completed) {
          if (mounted) {
            context.go(resultsRoute);
          }
          return;
        }
        final nextRoute =
            updated.currentGame == GameType.vocab ? transitionRoute : duelRoute;
        if (mounted) {
          context.go(nextRoute);
        }
        return;
      }
      final ids = refreshedSession.currentPlayer == 1
          ? refreshedSession.vocabPlayerOneIds
          : refreshedSession.vocabPlayerTwoIds;
      final itemsById = {
        for (final item in deck.items) item.id: item,
      };
      final questionItems = ids
          .map((id) => itemsById[id])
          .whereType<ContentItem>()
          .toList();
      if (questionItems.isEmpty) {
        return;
      }
      final safeIndex = currentIndex.clamp(0, questionItems.length - 1);
      final current = questionItems[safeIndex];
      final targetIsGreek = refreshedSession.currentPlayer == 1
          ? refreshedSession.playerOne.direction ==
              LanguageDirection.catalanToGreek
          : refreshedSession.playerTwo.direction ==
              LanguageDirection.catalanToGreek;
      final options = _buildOptions(
        current,
        deck.vocabularyItems,
        targetIsGreek,
      );
      if (!mounted) return;
      setState(() {
        _currentItem = current;
        _options = options;
        if (!timersEnabled) {
          _timer?.cancel();
          _remainingSeconds = _totalSeconds;
        }
      });
      if (timersEnabled) {
        _startTimer();
      }
    });
  }

  int _currentIndexForPlayer(GameSessionState session) {
    return session.currentPlayer == 1
        ? session.vocabPlayerOneIndex
        : session.vocabPlayerTwoIndex;
  }

  List<ContentItem> _buildOptions(
    ContentItem correct,
    List<ContentItem> pool,
    bool targetIsGreek,
  ) {
    final random = Random();
    String targetText(ContentItem item) =>
        targetIsGreek ? item.greek.text : item.catalan.text;

    final sameCategory = pool
        .where(
          (item) => item.category == correct.category && item.id != correct.id,
        )
        .toList()
      ..shuffle(random);

    final confusionIds = _confusionPairs[correct.id] ?? const [];
    final confusionItems = confusionIds
        .map(
          (id) =>
              pool.firstWhere((item) => item.id == id, orElse: () => correct),
        )
        .where((item) => item.id != correct.id)
        .toList()
      ..shuffle(random);

    final sameDifficulty = pool
        .where(
          (item) => item.difficulty == correct.difficulty && item.id != correct.id,
        )
        .toList()
      ..shuffle(random);

    final others = pool.where((item) => item.id != correct.id).toList()
      ..shuffle(random);

    final correctLength = targetText(correct).length;
    bool similarLength(ContentItem item) {
      final diff = (targetText(item).length - correctLength).abs();
      return diff <= 3;
    }

    final options = <ContentItem>[correct];
    final usedTexts = {targetText(correct)};

    void addIfUnique(ContentItem item) {
      final text = targetText(item);
      if (!usedTexts.contains(text) && options.length < 4) {
        options.add(item);
        usedTexts.add(text);
      }
    }

    for (final item in sameCategory) {
      if (similarLength(item)) {
        addIfUnique(item);
      }
    }
    for (final item in confusionItems) {
      if (similarLength(item)) {
        addIfUnique(item);
      }
    }
    for (final item in sameDifficulty) {
      if (similarLength(item)) {
        addIfUnique(item);
      }
    }
    for (final item in sameCategory) {
      addIfUnique(item);
    }
    for (final item in confusionItems) {
      addIfUnique(item);
    }
    for (final item in sameDifficulty) {
      addIfUnique(item);
    }
    for (final item in others) {
      addIfUnique(item);
    }

    options.shuffle(random);
    return options;
  }

  void _selectOption(ContentItem option) {
    final controller = ref.read(vocabFlashControllerProvider.notifier);
    if (ref.read(vocabFlashControllerProvider).isAnswered ||
        _currentItem == null) {
      return;
    }
    _timer?.cancel();

    final isCorrect = option.id == _currentItem!.id;
    final soundEnabled = ref.read(settingsProvider).soundEnabled;
    final soundService = ref.read(soundProvider);
    if (isCorrect) {
      soundService.playSuccess(soundEnabled);
    } else {
      soundService.playError(soundEnabled);
    }
    final timersEnabled = ref.read(settingsProvider).timersEnabled;
    final speedBonus =
        timersEnabled ? _calculateSpeedBonus(_remainingSeconds) : 0;
    final pointsAwarded = isCorrect ? 10 + speedBonus : 0;
    final encouragement = _encouragement(isCorrect);

    setState(() {
      controller.setAnswered(true);
      final correctAnswer = _formatAnswer(_currentItem!);
      controller.setFeedback(
        isCorrect ? AnswerFeedbackState.correct : AnswerFeedbackState.incorrect,
        isCorrect
            ? 'Correct! $encouragement\nAnswer: $correctAnswer\n+$pointsAwarded points'
            : 'Not quite. $encouragement\nCorrect: $correctAnswer',
      );
    });

    _advanceAfterDelay(pointsAwarded: pointsAwarded);
  }

  String _encouragement(bool isCorrect) {
    final random = Random();
    const correctMessages = [
      'Great job!',
      'Nice work!',
      'Solid answer!',
      'You got it!',
    ];
    const wrongMessages = [
      'Keep going!',
      "You’re learning!",
      'Nice try!',
      'Stay focused!',
    ];
    final list = isCorrect ? correctMessages : wrongMessages;
    return list[random.nextInt(list.length)];
  }

  int _calculateSpeedBonus(int remainingSeconds) {
    if (remainingSeconds >= 8) return 5;
    if (remainingSeconds >= 5) return 3;
    if (remainingSeconds >= 3) return 1;
    return 0;
  }

  String _formatAnswer(ContentItem item) {
    final session = ref.read(gameSessionProvider);
    final player = session.currentPlayer == 1
        ? session.playerOne
        : session.playerTwo;
    final targetIsGreek = player.direction == LanguageDirection.catalanToGreek;
    return targetIsGreek ? item.greek.text : item.catalan.text;
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(gameSessionProvider);
    final deckAsync = ref.watch(deckProvider);
    final vocabState = ref.watch(vocabFlashControllerProvider);

    return deckAsync.when(
      data: (_) {
        if (_currentItem == null) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _prepareQuestion(),
          );
        }

        final player = session.currentPlayer == 1
            ? session.playerOne
            : session.playerTwo;
        final sourceIsGreek =
            player.direction == LanguageDirection.greekToCatalan;
        final timersEnabled =
            ref.watch(settingsProvider.select((s) => s.timersEnabled));

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final shouldPop = await _confirmExit(context);
            if (shouldPop && context.mounted) {
              context.go(duelRoute);
            }
          },
          child: Scaffold(
            appBar: AppBar(title: const Text('Vocab Flash Duel')),
            body: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ScoreBoard(
                        playerOne: session.playerOneName,
                        playerTwo: session.playerTwoName,
                        playerOneScore: session.playerOneScore,
                        playerTwoScore: session.playerTwoScore,
                      ),
                      if (timersEnabled) ...[
                        const SizedBox(height: 12),
                        TimerBar(
                          totalSeconds: _totalSeconds,
                          remainingSeconds: _remainingSeconds,
                          warningThreshold: 3,
                          criticalThreshold: 1,
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (_currentItem != null)
                        FlashCard(
                          text: sourceIsGreek
                              ? _currentItem!.greek.text
                              : _currentItem!.catalan.text,
                          romanization: sourceIsGreek
                              ? _currentItem!.greek.romanization
                              : null,
                          phonetic:
                              sourceIsGreek ? _currentItem!.greek.phonetic : null,
                        ),
                      const SizedBox(height: 16),
                      for (final option in _options)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: OptionTile(
                            label: sourceIsGreek
                                ? option.catalan.text
                                : option.greek.text,
                            onPressed:
                                vocabState.isAnswered
                                    ? null
                                    : () => _selectOption(option),
                          ),
                        ),
                      const SizedBox(height: 12),
                      AnswerFeedback(
                        message: vocabState.feedbackMessage,
                        state: vocabState.feedbackState,
                      ),
                    ],
                  ),
                ),
                if (_showPauseOverlay)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      child: Center(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.pause_circle, size: 48),
                                const SizedBox(height: 12),
                                const Text(
                                  'Game paused',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                DuelButton(
                                  label: 'Resume',
                                  onPressed: _resumeGame,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: LoadingState(message: 'Loading deck...')),
      error: (error, _) => Scaffold(
        body: ErrorState(
          title: 'Deck unavailable',
          message: 'Please try again.',
          onRetry: () => ref.refresh(deckProvider),
        ),
      ),
    );
  }

  Future<bool> _confirmExit(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quit duel?'),
        content: const Text('Your current match will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(gameSessionProvider.notifier).reset();
              Navigator.of(context).pop(true);
            },
            child: const Text('Quit'),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }
}
