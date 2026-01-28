import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../data/models/player.dart';
import '../../../data/providers/content_provider.dart';
import '../../../data/providers/game_session_provider.dart';
import '../../../data/providers/settings_provider.dart';
import '../../../data/providers/sound_provider.dart';
import '../../../shared/widgets/answer_feedback.dart';
import '../../../shared/widgets/async_state.dart';
import '../../../shared/widgets/score_board.dart';
import '../../../shared/widgets/spelling_input.dart';
import '../../../shared/widgets/timer_bar.dart';
import 'spelling_controller.dart';
import 'spelling_validator.dart';

class SpellingBeeScreen extends ConsumerStatefulWidget {
  const SpellingBeeScreen({super.key});

  @override
  ConsumerState<SpellingBeeScreen> createState() => _SpellingBeeScreenState();
}

class _SpellingBeeScreenState extends ConsumerState<SpellingBeeScreen>
    with WidgetsBindingObserver {
  static const int _totalSeconds = 20;

  Timer? _timer;
  int _remainingSeconds = _totalSeconds;
  bool _showPauseOverlay = false;
  AnswerFeedbackState _feedbackState = AnswerFeedbackState.neutral;
  String _feedbackMessage = 'Type the translation and submit.';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(spellingBeeControllerProvider.notifier).reset();
      _prepareQuestions();
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
    if (!ref.read(spellingBeeControllerProvider).isSubmitted && timersEnabled) {
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

  void _prepareQuestions() {
    final deckAsync = ref.read(deckProvider);
    final session = ref.read(gameSessionProvider);
    deckAsync.whenData((deck) {
      final ids = session.currentPlayer == 1
          ? session.spellingBeePlayerOneIds
          : session.spellingBeePlayerTwoIds;
      final items = ids.isEmpty
          ? deck.vocabularyItems.take(5).toList()
          : ids
              .map(
                (id) => deck.vocabularyItems.firstWhere((item) => item.id == id),
              )
              .toList();
      final direction = session.currentPlayer == 1
          ? session.playerOne.direction
          : session.playerTwo.direction;
      ref
          .read(spellingBeeControllerProvider.notifier)
          .initialize(items, direction);
      if (!mounted) return;
      setState(() {
        _feedbackState = AnswerFeedbackState.neutral;
        _feedbackMessage = 'Type the translation and submit.';
      });
      _startTimer();
    });
  }

  void _handleTimeout() {
    final controller = ref.read(spellingBeeControllerProvider.notifier);
    if (ref.read(spellingBeeControllerProvider).isSubmitted) return;
    controller.submitTimeout();
    final soundEnabled = ref.read(settingsProvider).soundEnabled;
    ref.read(soundProvider).playError(soundEnabled);
    final correct =
        ref.read(spellingBeeControllerProvider).currentQuestion.correctAnswer;
    setState(() {
      _feedbackState = AnswerFeedbackState.incorrect;
      _feedbackMessage = "Time's up! Answer: $correct";
    });
    _advanceAfterDelay(pointsAwarded: 0);
  }

  void _handleSubmit() {
    final controller = ref.read(spellingBeeControllerProvider.notifier);
    if (ref.read(spellingBeeControllerProvider).isSubmitted) return;
    final points = controller.submitAnswer(remainingSeconds: _remainingSeconds);
    final result = ref.read(spellingBeeControllerProvider).result;
    final correct =
        ref.read(spellingBeeControllerProvider).currentQuestion.correctAnswer;
    final soundEnabled = ref.read(settingsProvider).soundEnabled;
    if (points > 0) {
      ref.read(soundProvider).playSuccess(soundEnabled);
    } else {
      ref.read(soundProvider).playError(soundEnabled);
    }

    setState(() {
      _feedbackState =
          result == SpellingResult.perfect || result == SpellingResult.accentError
              ? AnswerFeedbackState.correct
              : AnswerFeedbackState.incorrect;
      _feedbackMessage = switch (result) {
        SpellingResult.perfect => 'Perfect! +$points points.',
        SpellingResult.accentError =>
          'Almost! Watch the accents: $correct',
        SpellingResult.minorError => 'Close! Correct: $correct',
        SpellingResult.majorError => 'Keep practicing! Answer: $correct',
        SpellingResult.wrong => 'The answer was: $correct',
        null => 'The answer was: $correct',
      };
    });
    _advanceAfterDelay(pointsAwarded: points);
  }

  void _advanceAfterDelay({required int pointsAwarded}) {
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      _nextQuestionOrEnd(pointsAwarded: pointsAwarded);
    });
  }

  void _nextQuestionOrEnd({required int pointsAwarded}) {
    final session = ref.read(gameSessionProvider);
    final controller = ref.read(spellingBeeControllerProvider.notifier);
    final state = ref.read(spellingBeeControllerProvider);

    ref
        .read(gameSessionProvider.notifier)
        .addScore(player: session.currentPlayer, points: pointsAwarded);

    final nextIndex = state.currentIndex + 1;
    ref
        .read(gameSessionProvider.notifier)
        .setSpellingBeeIndex(player: session.currentPlayer, index: nextIndex);

    if (nextIndex >= state.questions.length) {
      ref
          .read(gameSessionProvider.notifier)
          .completeSpellingBeeForPlayer(session.currentPlayer);
      final updated = ref.read(gameSessionProvider);
      if (updated.status == SessionStatus.completed) {
        context.go(resultsRoute);
        return;
      }
      final nextRoute = updated.currentGame == GameType.spellingBee
          ? transitionRoute
          : duelRoute;
      context.go(nextRoute);
      return;
    }

    controller.nextQuestion();
    setState(() {
      _feedbackState = AnswerFeedbackState.neutral;
      _feedbackMessage = 'Type the translation and submit.';
    });
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final deckAsync = ref.watch(deckProvider);
    final session = ref.watch(gameSessionProvider);
    final state = ref.watch(spellingBeeControllerProvider);

    return deckAsync.when(
      data: (_) {
        if (state.questions.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final question = state.currentQuestion;
        final direction = session.currentPlayer == 1
            ? session.playerOne.direction
            : session.playerTwo.direction;
        final targetLanguage =
            direction == LanguageDirection.greekToCatalan ? 'ca' : 'el';

        return Scaffold(
          appBar: AppBar(title: const Text('Spelling Bee')),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ScoreBoard(
                      playerOne: session.playerOneName,
                      playerTwo: session.playerTwoName,
                      playerOneScore: session.playerOneScore,
                      playerTwoScore: session.playerTwoScore,
                    ),
                    const SizedBox(height: 12),
                    TimerBar(
                      remainingSeconds: _remainingSeconds,
                      totalSeconds: _totalSeconds,
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Text(
                              'Translate:',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              question.sourceText,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (question.sourceRomanization.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                question.sourceRomanization,
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              '${question.wordCount} words · ${question.letterCount} letters',
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SpellingInput(
                      key: ValueKey('spelling-input-${state.currentIndex}'),
                      targetLanguage: targetLanguage,
                      enabled: !state.isSubmitted,
                      hint: 'Type your answer...',
                      onChanged: (value) => ref
                          .read(spellingBeeControllerProvider.notifier)
                          .updateInput(value),
                      onSubmit: (_) => _handleSubmit(),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: state.isSubmitted ? null : _handleSubmit,
                      child: const Text('Submit'),
                    ),
                    const SizedBox(height: 12),
                    AnswerFeedback(
                      message: _feedbackMessage,
                      state: _feedbackState,
                    ),
                  ],
                ),
              ),
              if (_showPauseOverlay)
                Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Paused',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text('Tap to continue the round.'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _resumeGame,
                            child: const Text('Resume'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Spelling Bee')),
        body: ErrorState(
          title: 'Unable to load deck',
          message: error.toString(),
          actionLabel: 'Back',
          onRetry: () => context.go(duelRoute),
        ),
      ),
    );
  }
}
