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
import '../../../shared/widgets/async_state.dart';
import '../../../shared/widgets/match_tile.dart';
import '../../../shared/widgets/score_board.dart';
import '../../../shared/widgets/timer_bar.dart';
import 'match_madness_controller.dart';

class MatchMadnessScreen extends ConsumerStatefulWidget {
  const MatchMadnessScreen({super.key});

  @override
  ConsumerState<MatchMadnessScreen> createState() => _MatchMadnessScreenState();
}

class _MatchMadnessScreenState extends ConsumerState<MatchMadnessScreen>
    with WidgetsBindingObserver {
  static const int _totalSeconds = 45;

  Timer? _timer;
  int _remainingSeconds = _totalSeconds;
  bool _showPauseOverlay = false;
  bool _isFinishing = false;
  bool _listenerRegistered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(matchMadnessControllerProvider.notifier).reset();
      _prepareRound();
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
    if (timersEnabled && !_isFinishing) {
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
        _finishRound(allMatched: false);
      } else {
        setState(() {
          _remainingSeconds -= 1;
        });
      }
    });
  }

  void _prepareRound() {
    final deckAsync = ref.read(deckProvider);
    final session = ref.read(gameSessionProvider);
    deckAsync.whenData((deck) {
      final ids = session.currentPlayer == 1
          ? session.matchMadnessPlayerOneIds
          : session.matchMadnessPlayerTwoIds;
      final items = ids.isEmpty
          ? deck.vocabularyItems.take(6).toList()
          : ids
              .map(
                (id) => deck.vocabularyItems.firstWhere((item) => item.id == id),
              )
              .toList();
      final direction = session.currentPlayer == 1
          ? session.playerOne.direction
          : session.playerTwo.direction;
      final pairs = items
          .map(
            (item) => MatchPair(
              id: item.id,
              sourceText: direction == LanguageDirection.greekToCatalan
                  ? item.greek.text
                  : item.catalan.text,
              targetText: direction == LanguageDirection.greekToCatalan
                  ? item.catalan.text
                  : item.greek.text,
            ),
          )
          .toList();
      ref.read(matchMadnessControllerProvider.notifier).initialize(pairs);
      if (!mounted) return;
      _startTimer();
    });
  }

  void _handleSourceTap(String id) {
    ref.read(matchMadnessControllerProvider.notifier).selectSource(id);
  }

  void _handleTargetTap(String id) {
    final result =
        ref.read(matchMadnessControllerProvider.notifier).selectTarget(id);
    final soundEnabled = ref.read(settingsProvider).soundEnabled;
    if (result == MatchAttemptResult.matched) {
      ref.read(soundProvider).playSuccess(soundEnabled);
    } else if (result == MatchAttemptResult.wrong) {
      ref.read(soundProvider).playError(soundEnabled);
    }
  }

  void _finishRound({required bool allMatched}) {
    if (_isFinishing) return;
    _isFinishing = true;
    _timer?.cancel();

    final controller = ref.read(matchMadnessControllerProvider.notifier);
    final session = ref.read(gameSessionProvider);
    if (allMatched) {
      final bonus = _remainingSeconds ~/ 5;
      controller.applyTimeBonus(bonus);
    }
    final totalScore = ref.read(matchMadnessControllerProvider).score;
    ref
        .read(gameSessionProvider.notifier)
        .addScore(player: session.currentPlayer, points: totalScore);
    ref
        .read(gameSessionProvider.notifier)
        .completeMatchMadnessForPlayer(session.currentPlayer);

    final updated = ref.read(gameSessionProvider);
    if (updated.status == SessionStatus.completed) {
      context.go(resultsRoute);
      return;
    }
    final nextRoute = updated.currentGame == GameType.matchMadness
        ? transitionRoute
        : duelRoute;
    context.go(nextRoute);
  }

  MatchTileState _sourceTileState(MatchMadnessState state, String id) {
    if (state.pairForId(id).isMatched) return MatchTileState.matched;
    if (state.wrongSourceId == id) return MatchTileState.wrong;
    if (state.selectedSourceId == id) return MatchTileState.selected;
    return MatchTileState.idle;
  }

  MatchTileState _targetTileState(MatchMadnessState state, String id) {
    if (state.pairForId(id).isMatched) return MatchTileState.matched;
    if (state.wrongTargetId == id) return MatchTileState.wrong;
    if (state.selectedTargetId == id) return MatchTileState.selected;
    return MatchTileState.idle;
  }

  @override
  Widget build(BuildContext context) {
    if (!_listenerRegistered) {
      _listenerRegistered = true;
      ref.listen<MatchMadnessState>(matchMadnessControllerProvider,
          (previous, next) {
        if (_isFinishing) return;
        final wasComplete = previous?.isComplete ?? false;
        if (!wasComplete && next.isComplete) {
          _finishRound(allMatched: true);
        }
      });
    }
    final deckAsync = ref.watch(deckProvider);
    final session = ref.watch(gameSessionProvider);
    final gameState = ref.watch(matchMadnessControllerProvider);

    return deckAsync.when(
      data: (_) {
        if (gameState.pairs.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Match Madness')),
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
                    const SizedBox(height: 12),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                const Text(
                                  'Source',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: gameState.sourceOrder.length,
                                    separatorBuilder: (_, index) =>
                                        const SizedBox(height: 10),
                                    itemBuilder: (context, index) {
                                      final id = gameState.sourceOrder[index];
                                      final pair = gameState.pairForId(id);
                                      return MatchTile(
                                        text: pair.sourceText,
                                        state: _sourceTileState(gameState, id),
                                        onTap: () => _handleSourceTap(id),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              children: [
                                const Text(
                                  'Target',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: gameState.targetOrder.length,
                                    separatorBuilder: (_, index) =>
                                        const SizedBox(height: 10),
                                    itemBuilder: (context, index) {
                                      final id = gameState.targetOrder[index];
                                      final pair = gameState.pairForId(id);
                                      return MatchTile(
                                        text: pair.targetText,
                                        state: _targetTileState(gameState, id),
                                        onTap: () => _handleTargetTap(id),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Matched ${gameState.matchedCount} / ${gameState.pairs.length}',
                      textAlign: TextAlign.center,
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
        appBar: AppBar(title: const Text('Match Madness')),
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
