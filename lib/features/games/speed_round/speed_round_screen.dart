import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../data/providers/content_provider.dart';
import '../../../data/providers/game_session_provider.dart';
import '../../../data/providers/settings_provider.dart';
import '../../../data/providers/sound_provider.dart';
import '../../../shared/widgets/answer_feedback.dart';
import '../../../shared/widgets/async_state.dart';
import '../../../shared/widgets/score_board.dart';
import '../../../shared/widgets/timer_bar.dart';
import '../../../shared/widgets/true_false_buttons.dart';
import 'speed_round_controller.dart';

class SpeedRoundScreen extends ConsumerStatefulWidget {
  const SpeedRoundScreen({super.key});

  @override
  ConsumerState<SpeedRoundScreen> createState() => _SpeedRoundScreenState();
}

class _SpeedRoundScreenState extends ConsumerState<SpeedRoundScreen>
    with WidgetsBindingObserver {
  static const int _totalSeconds = 5;

  Timer? _timer;
  int _remainingSeconds = _totalSeconds;
  bool _showPauseOverlay = false;
  AnswerFeedbackState _feedbackState = AnswerFeedbackState.neutral;
  String _feedbackMessage = 'Answer true or false';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(speedRoundControllerProvider.notifier).reset();
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
    if (!ref.read(speedRoundControllerProvider).isAnswered && timersEnabled) {
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
          ? session.speedRoundPlayerOneIds
          : session.speedRoundPlayerTwoIds;
      final items = ids.isEmpty
          ? deck.vocabularyItems.take(10).toList()
          : ids
              .map(
                (id) => deck.vocabularyItems.firstWhere((item) => item.id == id),
              )
              .toList();
      final direction = session.currentPlayer == 1
          ? session.playerOne.direction
          : session.playerTwo.direction;
      ref
          .read(speedRoundControllerProvider.notifier)
          .initialize(items, direction);
      if (!mounted) return;
      setState(() {
        _feedbackState = AnswerFeedbackState.neutral;
        _feedbackMessage = 'Answer true or false';
      });
      _startTimer();
    });
  }

  void _handleTimeout() {
    final controller = ref.read(speedRoundControllerProvider.notifier);
    if (ref.read(speedRoundControllerProvider).isAnswered) return;
    final soundEnabled = ref.read(settingsProvider).soundEnabled;
    ref.read(soundProvider).playError(soundEnabled);
    controller.markTimeout();
    setState(() {
      _feedbackState = AnswerFeedbackState.incorrect;
      _feedbackMessage = "Time's up! 0 points.";
    });
    _advanceAfterDelay(pointsAwarded: 0);
  }

  void _handleAnswer(bool answer) {
    final controller = ref.read(speedRoundControllerProvider.notifier);
    if (ref.read(speedRoundControllerProvider).isAnswered) return;
    final points = controller.submitAnswer(answer);
    final soundEnabled = ref.read(settingsProvider).soundEnabled;
    if (points > 0) {
      ref.read(soundProvider).playSuccess(soundEnabled);
    } else {
      ref.read(soundProvider).playError(soundEnabled);
    }

    final question = ref.read(speedRoundControllerProvider).currentQuestion;
    setState(() {
      _feedbackState = points > 0
          ? AnswerFeedbackState.correct
          : AnswerFeedbackState.incorrect;
      _feedbackMessage = points > 0
          ? 'Correct! +5 points.'
          : 'Incorrect. Correct: ${question.actualTranslation}';
    });
    _advanceAfterDelay(pointsAwarded: points);
  }

  void _advanceAfterDelay({required int pointsAwarded}) {
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      _nextQuestionOrEnd(pointsAwarded: pointsAwarded);
    });
  }

  void _nextQuestionOrEnd({required int pointsAwarded}) {
    final session = ref.read(gameSessionProvider);
    final controller = ref.read(speedRoundControllerProvider.notifier);
    final state = ref.read(speedRoundControllerProvider);

    ref
        .read(gameSessionProvider.notifier)
        .addScore(player: session.currentPlayer, points: pointsAwarded);

    final nextIndex = state.currentIndex + 1;
    ref
        .read(gameSessionProvider.notifier)
        .setSpeedRoundIndex(player: session.currentPlayer, index: nextIndex);

    if (nextIndex >= state.questions.length) {
      ref
          .read(gameSessionProvider.notifier)
          .completeSpeedRoundForPlayer(session.currentPlayer);
      final updated = ref.read(gameSessionProvider);
      if (updated.status == SessionStatus.completed) {
        context.go(resultsRoute);
        return;
      }
      final nextRoute = updated.currentGame == GameType.speedRound
          ? transitionRoute
          : duelRoute;
      context.go(nextRoute);
      return;
    }

    controller.nextQuestion();
    setState(() {
      _feedbackState = AnswerFeedbackState.neutral;
      _feedbackMessage = 'Answer true or false';
    });
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final deckAsync = ref.watch(deckProvider);
    final session = ref.watch(gameSessionProvider);
    final controllerState = ref.watch(speedRoundControllerProvider);
    final questionCount = controllerState.questions.length;

    return deckAsync.when(
      data: (_) {
        if (questionCount == 0) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final question = controllerState.currentQuestion;
        return Scaffold(
          appBar: AppBar(title: const Text('Speed Round')),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ScoreBoard(
                      playerOne: session.playerOneName,
                      playerTwo: session.playerTwoName,
                      playerOneScore: session.playerOneScore,
                      playerTwoScore: session.playerTwoScore,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Question ${controllerState.currentIndex + 1} of ${controllerState.questions.length}',
                    ),
                    const SizedBox(height: 8),
                    TimerBar(
                      remainingSeconds: _remainingSeconds,
                      totalSeconds: _totalSeconds,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                question.sourceText,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text('='),
                              const SizedBox(height: 8),
                              Text(
                                question.displayedTranslation,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'True or false?',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TrueFalseButtons(
                      enabled: !controllerState.isAnswered,
                      selectedAnswer: controllerState.answers.isEmpty
                          ? null
                          : controllerState.answers[controllerState.currentIndex],
                      onTrue: () => _handleAnswer(true),
                      onFalse: () => _handleAnswer(false),
                    ),
                    const SizedBox(height: 16),
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
        appBar: AppBar(title: const Text('Speed Round')),
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
