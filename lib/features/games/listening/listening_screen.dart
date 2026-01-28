import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../data/providers/audio_provider.dart';
import '../../../data/providers/content_provider.dart';
import '../../../data/providers/game_session_provider.dart';
import '../../../data/providers/settings_provider.dart';
import '../../../data/providers/sound_provider.dart';
import '../../../shared/widgets/answer_feedback.dart';
import '../../../shared/widgets/async_state.dart';
import '../../../shared/widgets/audio_play_button.dart';
import '../../../shared/widgets/option_tile.dart';
import '../../../shared/widgets/score_board.dart';
import '../../../shared/widgets/timer_bar.dart';
import 'listening_controller.dart';

class ListeningChallengeScreen extends ConsumerStatefulWidget {
  const ListeningChallengeScreen({super.key});

  @override
  ConsumerState<ListeningChallengeScreen> createState() =>
      _ListeningChallengeScreenState();
}

class _ListeningChallengeScreenState
    extends ConsumerState<ListeningChallengeScreen>
    with WidgetsBindingObserver {
  static const int _totalSeconds = 10;

  Timer? _timer;
  int _remainingSeconds = _totalSeconds;
  bool _showPauseOverlay = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.listen<ListeningState>(listeningControllerProvider,
        (previous, next) {
      if (next.questions.isEmpty) return;
      if (!next.hasPlayedAudio) {
        _playAudio(next.currentQuestion);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(listeningControllerProvider.notifier).reset();
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
    if (!ref.read(listeningControllerProvider).isAnswered && timersEnabled) {
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
          ? session.listeningPlayerOneIds
          : session.listeningPlayerTwoIds;
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
          .read(listeningControllerProvider.notifier)
          .initialize(items, direction);
      if (!mounted) return;
      _startTimer();
    });
  }

  Future<void> _playAudio(ListeningQuestion question) async {
    final audioService = ref.read(audioServiceProvider);
    if (!audioService.isAvailable) {
      ref.read(listeningControllerProvider.notifier).markAudioPlayed();
      return;
    }
    await audioService.speak(question.audioText, question.audioLanguage);
    if (!mounted) return;
    ref.read(listeningControllerProvider.notifier).markAudioPlayed();
  }

  void _handleTimeout() {
    if (ref.read(listeningControllerProvider).isAnswered) return;
    final soundEnabled = ref.read(settingsProvider).soundEnabled;
    ref.read(soundProvider).playError(soundEnabled);
    ref.read(listeningControllerProvider.notifier).markTimeout();
    _advanceAfterDelay(pointsAwarded: 0);
  }

  void _handleAnswer(int index) {
    final controller = ref.read(listeningControllerProvider.notifier);
    if (ref.read(listeningControllerProvider).isAnswered) return;
    final points =
        controller.submitAnswer(index, remainingSeconds: _remainingSeconds);
    final soundEnabled = ref.read(settingsProvider).soundEnabled;
    if (points > 0) {
      ref.read(soundProvider).playSuccess(soundEnabled);
    } else {
      ref.read(soundProvider).playError(soundEnabled);
    }
    _advanceAfterDelay(pointsAwarded: points);
  }

  void _advanceAfterDelay({required int pointsAwarded}) {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      _nextQuestionOrEnd(pointsAwarded: pointsAwarded);
    });
  }

  void _nextQuestionOrEnd({required int pointsAwarded}) {
    final session = ref.read(gameSessionProvider);
    final state = ref.read(listeningControllerProvider);

    ref
        .read(gameSessionProvider.notifier)
        .addScore(player: session.currentPlayer, points: pointsAwarded);

    final nextIndex = state.currentIndex + 1;
    ref
        .read(gameSessionProvider.notifier)
        .setListeningIndex(player: session.currentPlayer, index: nextIndex);

    if (nextIndex >= state.questions.length) {
      ref
          .read(gameSessionProvider.notifier)
          .completeListeningForPlayer(session.currentPlayer);
      final updated = ref.read(gameSessionProvider);
      if (updated.status == SessionStatus.completed) {
        context.go(resultsRoute);
        return;
      }
      final nextRoute = updated.currentGame == GameType.listening
          ? transitionRoute
          : duelRoute;
      context.go(nextRoute);
      return;
    }

    ref.read(listeningControllerProvider.notifier).nextQuestion();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final deckAsync = ref.watch(deckProvider);
    final session = ref.watch(gameSessionProvider);
    final state = ref.watch(listeningControllerProvider);
    final audioService = ref.watch(audioServiceProvider);

    return deckAsync.when(
      data: (_) {
        if (state.questions.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final question = state.currentQuestion;
        final isAudioAvailable = audioService.isAvailable;
        return Scaffold(
          appBar: AppBar(title: const Text('Listening Challenge')),
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
                            const Text('Listen and choose the answer'),
                            const SizedBox(height: 8),
                            AudioPlayButton(
                              text: question.audioText,
                              languageCode: question.audioLanguage,
                              showReplayCost: true,
                              onReplay: () => ref
                                  .read(listeningControllerProvider.notifier)
                                  .markReplay(),
                            ),
                            if (!isAudioAvailable) ...[
                              const SizedBox(height: 8),
                              Text(
                                question.audioText,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        itemCount: question.options.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          return OptionTile(
                            label: question.options[index],
                            onPressed: state.isAnswered
                                ? null
                                : () => _handleAnswer(index),
                          );
                        },
                      ),
                    ),
                    AnswerFeedback(
                      message: state.feedbackMessage,
                      state: state.feedbackState,
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
        appBar: AppBar(title: const Text('Listening Challenge')),
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
