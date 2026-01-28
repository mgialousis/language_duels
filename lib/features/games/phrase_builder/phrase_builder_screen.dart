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
import '../../../features/games/phrase_builder/phrase_builder_controller.dart';
import '../../../shared/widgets/answer_feedback.dart';
import '../../../shared/widgets/duel_button.dart';
import '../../../shared/widgets/score_board.dart';
import '../../../shared/widgets/submit_bar.dart';
import '../../../shared/widgets/timer_bar.dart';
import '../../../shared/widgets/word_tile.dart';
import '../../../shared/widgets/async_state.dart';

class PhraseBuilderScreen extends ConsumerStatefulWidget {
  const PhraseBuilderScreen({super.key});

  @override
  ConsumerState<PhraseBuilderScreen> createState() =>
      _PhraseBuilderScreenState();
}

class _PhraseBuilderScreenState extends ConsumerState<PhraseBuilderScreen>
    with WidgetsBindingObserver {
  static const int _totalSeconds = 30;
  static const int _phrasesPerPlayer = 3;

  Timer? _timer;
  int _remainingSeconds = _totalSeconds;
  int _phraseIndex = 0;
  bool _showPauseOverlay = false;
  List<WordToken> _currentWords = [];
  List<String> _targetWords = [];
  ContentItem? _currentItem;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(phraseBuilderControllerProvider.notifier).reset();
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
    if (!ref.read(phraseBuilderControllerProvider).isSubmitted &&
        timersEnabled) {
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
    if (ref.read(phraseBuilderControllerProvider).isSubmitted) return;
    _submitAnswer(autoSubmit: true);
  }

  void _preparePhrase() {
    final deckAsync = ref.read(deckProvider);
    final session = ref.read(gameSessionProvider);
    final timersEnabled = ref.read(settingsProvider).timersEnabled;
    final controller = ref.read(phraseBuilderControllerProvider.notifier);
    deckAsync.whenData((deck) {
      _phraseIndex = _currentIndexForPlayer(session);
      controller.setPhraseIndex(_phraseIndex);
      if (_phraseIndex >= _phrasesPerPlayer) {
        ref
            .read(gameSessionProvider.notifier)
            .completePhraseForPlayer(session.currentPlayer);
        final updated = ref.read(gameSessionProvider);
        if (updated.status == SessionStatus.completed) {
          if (mounted) {
            context.go(resultsRoute);
          }
          return;
        }
        final nextRoute =
            updated.currentGame == GameType.phrase ? transitionRoute : duelRoute;
        if (mounted) {
          context.go(nextRoute);
        }
        return;
      }
      final ids = session.currentPlayer == 1
          ? session.phrasePlayerOneIds
          : session.phrasePlayerTwoIds;
      final phraseItems = ids
          .map((id) => deck.items.firstWhere((item) => item.id == id))
          .toList();
      final safeIndex = _phraseIndex.clamp(0, phraseItems.length - 1);
      final current = phraseItems[safeIndex];
      final player = session.currentPlayer == 1
          ? session.playerOne
          : session.playerTwo;
      final targetWords = _getTargetWords(current, player.direction);
      final tokens = _buildTokens(targetWords);
      final scrambled = _scrambleWords(tokens);

      if (!mounted) return;
      setState(() {
        _currentItem = current;
        _targetWords = targetWords;
        _currentWords = scrambled;
        controller.setSubmitted(false);
        controller.setHintUsed(false);
        controller.setFeedback(
          AnswerFeedbackState.neutral,
          'Reorder the words and submit',
        );
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

  List<String> _getTargetWords(ContentItem item, LanguageDirection direction) {
    final fromWords = item.words;
    if (fromWords.isNotEmpty) {
      final list = fromWords
          .map(
            (w) => direction == LanguageDirection.greekToCatalan
                ? w.catalan
                : w.greek,
          )
          .where((w) => w.trim().isNotEmpty)
          .toList();
      if (list.isNotEmpty) {
        return list;
      }
    }

    final fallbackText = direction == LanguageDirection.greekToCatalan
        ? item.catalan.text
        : item.greek.text;
    final split = fallbackText
        .split(' ')
        .where((w) => w.trim().isNotEmpty)
        .toList();
    return split.isNotEmpty ? split : [fallbackText];
  }

  List<WordToken> _buildTokens(List<String> words) {
    return [
      for (int i = 0; i < words.length; i++)
        WordToken(id: 'w$i-${words[i]}', text: words[i]),
    ];
  }

  List<WordToken> _scrambleWords(List<WordToken> words) {
    if (words.length <= 1) return words;
    final random = Random();
    var scrambled = [...words];
    int attempts = 0;
    while (attempts < 10 &&
        _listEquals(_tokenTexts(scrambled), _tokenTexts(words))) {
      scrambled.shuffle(random);
      attempts++;
    }
    if (_listEquals(_tokenTexts(scrambled), _tokenTexts(words))) {
      final temp = scrambled[0];
      scrambled[0] = scrambled[1];
      scrambled[1] = temp;
    }
    return scrambled;
  }

  void _submitAnswer({bool autoSubmit = false}) {
    final controller = ref.read(phraseBuilderControllerProvider.notifier);
    final state = ref.read(phraseBuilderControllerProvider);
    if (state.isSubmitted) return;
    _timer?.cancel();

    final total = _targetWords.length;
    int correctPositions = 0;
    for (int i = 0; i < total; i++) {
      if (i < _currentWords.length &&
          _currentWords[i].text == _targetWords[i]) {
        correctPositions++;
      }
    }

    final baseScore = ((20 * correctPositions) / total).floor();
    final isPerfect = correctPositions == total;
    final timersEnabled = ref.read(settingsProvider).timersEnabled;
    final timeBonus = timersEnabled && isPerfect
        ? (_remainingSeconds >= 20 ? 5 : (_remainingSeconds >= 10 ? 2 : 0))
        : 0;
    final hintCost = state.hintUsed ? 3 : 0;
    final pointsAwarded =
        (baseScore + timeBonus - hintCost).clamp(0, 9999).toInt();

    final correctPhrase = _targetWords.join(' ');
    final encouragement = _encouragement(isPerfect);
    final soundEnabled = ref.read(settingsProvider).soundEnabled;
    final soundService = ref.read(soundProvider);
    if (isPerfect) {
      soundService.playSuccess(soundEnabled);
    } else {
      soundService.playError(soundEnabled);
    }
    setState(() {
      controller.setSubmitted(true);
      controller.setFeedback(
        isPerfect ? AnswerFeedbackState.correct : AnswerFeedbackState.incorrect,
        isPerfect
            ? 'Perfect! $encouragement\nCorrect: $correctPhrase\n+$pointsAwarded points'
            : 'Not quite. $encouragement\nCorrect: $correctPhrase',
      );
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      _nextPhraseOrEnd(pointsAwarded: pointsAwarded);
    });
  }

  void _useHint() {
    final controller = ref.read(phraseBuilderControllerProvider.notifier);
    if (ref.read(phraseBuilderControllerProvider).hintUsed ||
        _targetWords.isEmpty) {
      return;
    }
    final soundEnabled = ref.read(settingsProvider).soundEnabled;
    ref.read(soundProvider).playTap(soundEnabled);
    final first = _targetWords.first;
    final index = _currentWords.indexWhere((token) => token.text == first);
    if (index == -1) return;
    setState(() {
      final token = _currentWords.removeAt(index);
      _currentWords.insert(0, token);
      controller.setHintUsed(true);
    });
  }

  String _encouragement(bool isCorrect) {
    final random = Random();
    const correctMessages = [
      'Great job!',
      'Nice work!',
      'Excellent!',
      'You nailed it!',
    ];
    const wrongMessages = [
      'Keep trying!',
      "You're learning!",
      'Nice effort!',
      'Stay with it!',
    ];
    final list = isCorrect ? correctMessages : wrongMessages;
    return list[random.nextInt(list.length)];
  }

  void _nextPhraseOrEnd({required int pointsAwarded}) {
    final session = ref.read(gameSessionProvider);
    final controller = ref.read(phraseBuilderControllerProvider.notifier);
    ref
        .read(gameSessionProvider.notifier)
        .addScore(player: session.currentPlayer, points: pointsAwarded);

    final nextIndex = ref.read(phraseBuilderControllerProvider).phraseIndex + 1;
    ref
        .read(gameSessionProvider.notifier)
        .setPhraseIndex(player: session.currentPlayer, index: nextIndex);

    if (nextIndex >= _phrasesPerPlayer) {
      ref
          .read(gameSessionProvider.notifier)
          .completePhraseForPlayer(session.currentPlayer);
      final updated = ref.read(gameSessionProvider);
      if (updated.status == SessionStatus.completed) {
        context.go(resultsRoute);
        return;
      }
      final nextRoute =
          updated.currentGame == GameType.phrase ? transitionRoute : duelRoute;
      context.go(nextRoute);
      return;
    }

    setState(() {
      controller.setPhraseIndex(nextIndex);
      controller.setSubmitted(false);
      controller.setFeedback(
        AnswerFeedbackState.neutral,
        'Reorder the words and submit',
      );
    });
    _preparePhrase();
  }

  int _currentIndexForPlayer(GameSessionState session) {
    return session.currentPlayer == 1
        ? session.phrasePlayerOneIndex
        : session.phrasePlayerTwoIndex;
  }

  List<String> _tokenTexts(List<WordToken> tokens) =>
      tokens.map((token) => token.text).toList();

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(gameSessionProvider);
    final deckAsync = ref.watch(deckProvider);
    final phraseState = ref.watch(phraseBuilderControllerProvider);

    return deckAsync.when(
      data: (_) {
        if (_currentItem == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _preparePhrase());
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
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            appBar: AppBar(title: const Text('Phrase Builder')),
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
                          warningThreshold: 10,
                          criticalThreshold: 5,
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (_currentItem != null)
                        Text(
                          sourceIsGreek
                              ? _currentItem!.greek.text
                              : _currentItem!.catalan.text,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ReorderableListView(
                          buildDefaultDragHandles: false,
                          onReorder: (oldIndex, newIndex) {
                            if (phraseState.isSubmitted) return;
                            if (phraseState.hintUsed &&
                                (oldIndex == 0 || newIndex == 0)) {
                              return;
                            }
                            setState(() {
                              if (newIndex > oldIndex) {
                                newIndex -= 1;
                              }
                              final item = _currentWords.removeAt(oldIndex);
                              _currentWords.insert(newIndex, item);
                            });
                          },
                          children: [
                            for (
                              int index = 0;
                              index < _currentWords.length;
                              index++
                            )
                              WordTile(
                                key: ValueKey(_currentWords[index].id),
                                text: _currentWords[index].text,
                                locked: phraseState.hintUsed && index == 0,
                                dragHandle: ReorderableDragStartListener(
                                  index: index,
                                  child: const Icon(Icons.drag_handle),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      AnswerFeedback(
                        message: phraseState.feedbackMessage,
                        state: phraseState.feedbackState,
                      ),
                      const SizedBox(height: 12),
                      SubmitBar(
                        hintEnabled:
                            !phraseState.isSubmitted && !phraseState.hintUsed,
                        onHint: _useHint,
                        submitEnabled: !phraseState.isSubmitted,
                        onSubmit: _submitAnswer,
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

class WordToken {
  final String id;
  final String text;

  const WordToken({required this.id, required this.text});
}
