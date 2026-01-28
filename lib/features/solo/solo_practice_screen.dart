import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../data/models/content_item.dart';
import '../../data/models/deck.dart';
import '../../data/models/player.dart';
import '../../data/models/solo_session_summary.dart';
import '../../data/providers/content_provider.dart';
import '../../data/providers/settings_provider.dart';
import '../../data/providers/sound_provider.dart';
import '../../data/providers/srs_provider.dart';
import '../../data/providers/audio_provider.dart';
import '../../shared/widgets/answer_feedback.dart';
import '../../shared/widgets/duel_button.dart';
import '../../shared/widgets/flash_card.dart';
import '../../shared/widgets/option_tile.dart';
import '../../shared/widgets/true_false_buttons.dart';
import '../../shared/widgets/spelling_input.dart';
import '../../shared/widgets/audio_play_button.dart';
import '../../shared/widgets/submit_bar.dart';
import '../../shared/widgets/timer_bar.dart';
import '../../shared/widgets/async_state.dart';
import '../../shared/widgets/word_tile.dart';
import '../games/match_madness/match_madness_controller.dart';
import '../../shared/widgets/match_tile.dart';
import '../games/spelling_bee/spelling_validator.dart';
import 'solo_practice_controller.dart';

class SoloPracticeScreen extends ConsumerStatefulWidget {
  const SoloPracticeScreen({super.key});

  @override
  ConsumerState<SoloPracticeScreen> createState() => _SoloPracticeScreenState();
}

class _SoloPracticeScreenState extends ConsumerState<SoloPracticeScreen>
    with WidgetsBindingObserver {
  static const int _vocabSeconds = 10;
  static const int _phraseSeconds = 30;
  static const int _speedSeconds = 5;
  static const int _listeningSeconds = 10;
  static const int _spellingSeconds = 20;
  static const int _matchSeconds = 45;

  Timer? _timer;
  int _remainingSeconds = _vocabSeconds;
  int _questionTotalSeconds = _vocabSeconds;
  bool _showPauseOverlay = false;
  List<ContentItem> _options = [];
  DateTime? _questionStartTime;
  List<WordToken> _phraseWords = [];
  List<String> _phraseTargetWords = [];
  bool _phraseHintUsed = false;
  String _speedDisplayedTranslation = '';
  bool _speedIsCorrect = true;
  bool? _speedSelectedAnswer;
  bool _listeningReplayUsed = false;
  String _spellingInput = '';
  bool _matchRoundFinished = false;
  SoloGameType _activeGameType = SoloGameType.vocabFlash;
  int _mixedRotationIndex = 0;
  List<SoloGameType> _mixedRotation = const [];

  // Session config
  String? _deckId;
  SoloMode _mode = SoloMode.timed;
  SoloGameType _gameType = SoloGameType.vocabFlash;
  LanguageDirection _direction = LanguageDirection.greekToCatalan;
  int? _questionCount;
  bool _initialized = false;
  bool _selectedDeckSynced = false;
  SoloPracticeConfig? _config;
  bool _weakWordsOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    setState(() => _showPauseOverlay = false);
    if (_config != null) {
      final practiceState = ref.read(soloPracticeProvider(_config!));
      if (!practiceState.showingFeedback && practiceState.timerEnabled) {
        _startTimer();
      }
    }
  }

  void _scheduleSelectedDeckSync() {
    if (_selectedDeckSynced || _deckId == null) return;
    _selectedDeckSynced = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _deckId == null) return;
      final selectedDeck = ref.read(selectedDeckProvider);
      if (selectedDeck != _deckId) {
        ref.read(selectedDeckProvider.notifier).state = _deckId!;
      }
    });
  }

  void _startTimer() {
    if (_config == null) return;
    final practiceState = ref.read(soloPracticeProvider(_config!));
    if (!practiceState.timerEnabled) {
      _timer?.cancel();
      return;
    }

    _timer?.cancel();
    _remainingSeconds = _questionTotalSeconds;
    _questionStartTime = DateTime.now();
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
    if (_config == null) return;
    final controller = ref.read(soloPracticeProvider(_config!).notifier);
    final practiceState = ref.read(soloPracticeProvider(_config!));

    if (practiceState.showingFeedback) return;

    if (_activeGameType == SoloGameType.matchMadness) {
      _finishMatchRound(allMatched: false);
      return;
    }

    if (_activeGameType == SoloGameType.spellingBee) {
      _submitSpellingAnswer(autoSubmit: true);
      return;
    }

    if (_activeGameType == SoloGameType.speedRound) {
      _submitSpeedAnswer(null);
      return;
    }

    if (_activeGameType == SoloGameType.listening) {
      _submitListeningAnswer(null);
      return;
    }

    if (_activeGameType == SoloGameType.phraseBuilder) {
      _submitPhraseAnswer(autoSubmit: true);
    } else {
      final soundEnabled = ref.read(settingsProvider).soundEnabled;
      ref.read(soundProvider).playError(soundEnabled);
      controller.submitAnswer(
        isCorrect: false,
        responseTimeMs: 0,
        points: 0,
      );
      _advanceAfterDelay();
    }
  }

  void _advanceAfterDelay() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted || _config == null) return;
      final controller = ref.read(soloPracticeProvider(_config!).notifier);
      final practiceState = ref.read(soloPracticeProvider(_config!));

      if (practiceState.isComplete || !practiceState.hasMoreQuestions) {
        _completeSession();
      } else {
        controller.nextQuestion();
        _prepareQuestion();
      }
    });
  }

  void _prepareQuestion() {
    if (_config == null) return;
    final practiceState = ref.read(soloPracticeProvider(_config!));
    final deckAsync = ref.read(deckProvider);

    deckAsync.whenData((deck) {
      if (!mounted) return;
      _activeGameType = _resolveActiveGameType(deck, practiceState.currentItem);
      final currentItem = practiceState.currentItem;
      final sourceIsGreek = _getSourceIsGreek();

      if (_activeGameType == SoloGameType.matchMadness) {
        final direction = _direction;
        final selected = [...deck.vocabularyItems]..shuffle();
        final pairs = selected.take(6).map((item) {
          final sourceText = direction == LanguageDirection.greekToCatalan
              ? item.greek.text
              : item.catalan.text;
          final targetText = direction == LanguageDirection.greekToCatalan
              ? item.catalan.text
              : item.greek.text;
          return MatchPair(
            id: item.id,
            sourceText: sourceText,
            targetText: targetText,
          );
        }).toList();
        ref.read(matchMadnessControllerProvider.notifier).initialize(pairs);
        setState(() {
          _matchRoundFinished = false;
          _options = [];
          _phraseWords = [];
          _phraseTargetWords = [];
          _phraseHintUsed = false;
          _questionTotalSeconds = _matchSeconds;
          _remainingSeconds = _questionTotalSeconds;
        });
      } else if (_activeGameType == SoloGameType.speedRound) {
        final random = Random();
        final pool = deck.vocabularyItems;
        final makeCorrect = random.nextBool();
        final targetIsGreek = !_getSourceIsGreek();
        ContentItem pickDistractor() {
          final sameCategory = pool
              .where(
                (item) =>
                    item.category == currentItem.category &&
                    item.id != currentItem.id,
              )
              .toList()
            ..shuffle(random);
          if (sameCategory.isNotEmpty) return sameCategory.first;
          final others = pool.where((item) => item.id != currentItem.id).toList()
            ..shuffle(random);
          return others.isNotEmpty ? others.first : currentItem;
        }

        final displayedItem = makeCorrect ? currentItem : pickDistractor();
        setState(() {
          _speedIsCorrect = makeCorrect;
          _speedSelectedAnswer = null;
          _speedDisplayedTranslation = targetIsGreek
              ? displayedItem.greek.text
              : displayedItem.catalan.text;
          _options = [];
          _phraseWords = [];
          _phraseTargetWords = [];
          _phraseHintUsed = false;
          _questionTotalSeconds = _speedSeconds;
          _remainingSeconds = _questionTotalSeconds;
        });
      } else if (_activeGameType == SoloGameType.spellingBee) {
        setState(() {
          _spellingInput = '';
          _options = [];
          _phraseWords = [];
          _phraseTargetWords = [];
          _phraseHintUsed = false;
          _questionTotalSeconds = _spellingSeconds;
          _remainingSeconds = _questionTotalSeconds;
        });
      } else if (_activeGameType == SoloGameType.listening) {
        final options = _buildOptions(
          currentItem,
          deck.vocabularyItems,
          sourceIsGreek,
          !sourceIsGreek,
        );
        setState(() {
          _options = options;
          _listeningReplayUsed = false;
          _phraseWords = [];
          _phraseTargetWords = [];
          _phraseHintUsed = false;
          _questionTotalSeconds = _listeningSeconds;
          _remainingSeconds = _questionTotalSeconds;
        });
        final audioService = ref.read(audioServiceProvider);
        if (audioService.isAvailable) {
          audioService.speak(
            sourceIsGreek
                ? currentItem.greek.text
                : currentItem.catalan.text,
            sourceIsGreek ? 'el' : 'ca',
          );
        }
      } else if (_activeGameType == SoloGameType.phraseBuilder) {
        final targetWords = _getTargetWords(currentItem, _direction);
        final tokens = _buildTokens(targetWords);
        final scrambled = _scrambleWords(tokens);
        setState(() {
          _phraseTargetWords = targetWords;
          _phraseWords = scrambled;
          _phraseHintUsed = false;
          _options = [];
          _questionTotalSeconds = _phraseSeconds;
          _remainingSeconds = _questionTotalSeconds;
        });
      } else {
        final options = _buildOptions(
          currentItem,
          deck.vocabularyItems,
          sourceIsGreek,
          !sourceIsGreek, // target is opposite of source
        );
        setState(() {
          _options = options;
          _phraseWords = [];
          _phraseTargetWords = [];
          _phraseHintUsed = false;
          _questionTotalSeconds = _vocabSeconds;
          _remainingSeconds = _questionTotalSeconds;
        });
      }

      _questionStartTime = DateTime.now();
      if (practiceState.timerEnabled) {
        _startTimer();
      }
    });
  }

  SoloGameType _resolveActiveGameType(Deck deck, ContentItem item) {
    if (_gameType != SoloGameType.mixed) {
      return _gameType;
    }

    if (item.isPhrase) {
      return SoloGameType.phraseBuilder;
    }

    final rotation = _buildMixedRotation(deck);
    if (rotation.isEmpty) {
      return SoloGameType.vocabFlash;
    }
    if (rotation.length != _mixedRotation.length) {
      _mixedRotation = rotation;
      _mixedRotationIndex = 0;
    } else {
      _mixedRotation = rotation;
    }

    final selected = _mixedRotation[_mixedRotationIndex % _mixedRotation.length];
    _mixedRotationIndex =
        (_mixedRotationIndex + 1) % _mixedRotation.length;
    return selected;
  }

  List<SoloGameType> _buildMixedRotation(Deck deck) {
    final vocabCount = deck.vocabularyItems.length;
    final rotation = <SoloGameType>[
      SoloGameType.vocabFlash,
      SoloGameType.speedRound,
      SoloGameType.spellingBee,
    ];
    if (vocabCount >= 6) {
      rotation.add(SoloGameType.matchMadness);
    }
    return rotation;
  }

  bool _getSourceIsGreek() {
    return _direction == LanguageDirection.greekToCatalan;
  }

  List<ContentItem> _buildOptions(
    ContentItem correct,
    List<ContentItem> pool,
    bool sourceIsGreek,
    bool targetIsGreek,
  ) {
    final random = Random();
    String sourceText(ContentItem item) =>
        sourceIsGreek ? item.greek.text : item.catalan.text;
    String targetText(ContentItem item) =>
        targetIsGreek ? item.greek.text : item.catalan.text;

    final filteredPool = pool
        .where(
          (item) =>
              item.id != correct.id &&
              sourceText(item) != sourceText(correct),
        )
        .toList()
      ..shuffle(random);

    final sameCategory = filteredPool
        .where(
          (item) => item.category == correct.category,
        )
        .toList()
      ..shuffle(random);

    final sameDifficulty = filteredPool
        .where(
          (item) => item.difficulty == correct.difficulty,
        )
        .toList()
      ..shuffle(random);

    final others = filteredPool;

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
    if (_config == null) return;
    final controller = ref.read(soloPracticeProvider(_config!).notifier);
    final practiceState = ref.read(soloPracticeProvider(_config!));

    if (practiceState.showingFeedback) return;

    _timer?.cancel();

    final isCorrect = option.id == practiceState.currentItem.id;
    final responseTimeMs = _questionStartTime != null
        ? DateTime.now().difference(_questionStartTime!).inMilliseconds
        : 0;

    final soundEnabled = ref.read(settingsProvider).soundEnabled;
    final soundService = ref.read(soundProvider);
    if (isCorrect) {
      soundService.playSuccess(soundEnabled);
    } else {
      soundService.playError(soundEnabled);
    }

    final speedBonus = practiceState.timerEnabled
        ? _calculateSpeedBonus(_remainingSeconds)
        : 0;
    final pointsAwarded = isCorrect ? 10 + speedBonus : 0;

    controller.submitAnswer(
      isCorrect: isCorrect,
      responseTimeMs: responseTimeMs,
      points: pointsAwarded,
    );

    _advanceAfterDelay();
  }

  void _submitSpeedAnswer(bool? answer) {
    if (_config == null) return;
    final controller = ref.read(soloPracticeProvider(_config!).notifier);
    final practiceState = ref.read(soloPracticeProvider(_config!));
    if (practiceState.showingFeedback) return;

    _timer?.cancel();
    final isCorrect = answer != null && answer == _speedIsCorrect;
    final responseTimeMs = _questionStartTime != null
        ? DateTime.now().difference(_questionStartTime!).inMilliseconds
        : 0;

    final soundEnabled = ref.read(settingsProvider).soundEnabled;
    final soundService = ref.read(soundProvider);
    if (isCorrect) {
      soundService.playSuccess(soundEnabled);
    } else {
      soundService.playError(soundEnabled);
    }

    final pointsAwarded = isCorrect ? 5 : 0;
    setState(() => _speedSelectedAnswer = answer);
    controller.submitAnswer(
      isCorrect: isCorrect,
      responseTimeMs: responseTimeMs,
      points: pointsAwarded,
    );

    _advanceAfterDelay();
  }

  void _submitListeningAnswer(ContentItem? option) {
    if (_config == null) return;
    final controller = ref.read(soloPracticeProvider(_config!).notifier);
    final practiceState = ref.read(soloPracticeProvider(_config!));
    if (practiceState.showingFeedback) return;
    _timer?.cancel();

    final isCorrect = option != null && option.id == practiceState.currentItem.id;
    final responseTimeMs = _questionStartTime != null
        ? DateTime.now().difference(_questionStartTime!).inMilliseconds
        : 0;
    final speedBonus = practiceState.timerEnabled
        ? _calculateSpeedBonus(_remainingSeconds)
        : 0;
    final replayPenalty = _listeningReplayUsed ? 2 : 0;
    final pointsAwarded = isCorrect ? max(0, 10 + speedBonus - replayPenalty) : 0;

    final soundEnabled = ref.read(settingsProvider).soundEnabled;
    final soundService = ref.read(soundProvider);
    if (isCorrect) {
      soundService.playSuccess(soundEnabled);
    } else {
      soundService.playError(soundEnabled);
    }

    controller.submitAnswer(
      isCorrect: isCorrect,
      responseTimeMs: responseTimeMs,
      points: pointsAwarded,
    );
    _advanceAfterDelay();
  }

  void _submitSpellingAnswer({bool autoSubmit = false}) {
    if (_config == null) return;
    final controller = ref.read(soloPracticeProvider(_config!).notifier);
    final practiceState = ref.read(soloPracticeProvider(_config!));
    if (practiceState.showingFeedback) return;
    _timer?.cancel();

    final result = autoSubmit
        ? SpellingResult.wrong
        : SpellingValidator.validate(
            _spellingInput,
            _getSpellingTarget(practiceState.currentItem),
          );
    final pointsAwarded = autoSubmit
        ? 0
        : _calculateSpellingPoints(result, _remainingSeconds);
    final isCorrect = result == SpellingResult.perfect ||
        result == SpellingResult.accentError;
    final responseTimeMs = _questionStartTime != null
        ? DateTime.now().difference(_questionStartTime!).inMilliseconds
        : 0;

    final soundEnabled = ref.read(settingsProvider).soundEnabled;
    final soundService = ref.read(soundProvider);
    if (isCorrect) {
      soundService.playSuccess(soundEnabled);
    } else {
      soundService.playError(soundEnabled);
    }

    controller.submitAnswer(
      isCorrect: isCorrect,
      responseTimeMs: responseTimeMs,
      points: pointsAwarded,
    );
    _advanceAfterDelay();
  }

  void _finishMatchRound({required bool allMatched}) {
    if (_config == null || _matchRoundFinished) return;
    _matchRoundFinished = true;
    _timer?.cancel();

    final controller = ref.read(soloPracticeProvider(_config!).notifier);
    final matchState = ref.read(matchMadnessControllerProvider);

    if (allMatched) {
      final bonus = _remainingSeconds ~/ 5;
      ref.read(matchMadnessControllerProvider.notifier).applyTimeBonus(bonus);
    }

    final totalScore = ref.read(matchMadnessControllerProvider).score;
    final responseTimeMs = _questionStartTime != null
        ? DateTime.now().difference(_questionStartTime!).inMilliseconds
        : 0;
    final isCorrect = matchState.matchedCount == matchState.pairs.length;

    controller.submitAnswer(
      isCorrect: isCorrect,
      responseTimeMs: responseTimeMs,
      points: totalScore,
    );
    _advanceAfterDelay();
  }

  int _calculateSpellingPoints(SpellingResult result, int remainingSeconds) {
    final base = switch (result) {
      SpellingResult.perfect => 15,
      SpellingResult.accentError => 12,
      SpellingResult.minorError => 8,
      SpellingResult.majorError => 3,
      SpellingResult.wrong => 0,
    };
    if (result != SpellingResult.perfect) return base;
    if (remainingSeconds >= 15) return base + 5;
    if (remainingSeconds >= 10) return base + 3;
    if (remainingSeconds >= 5) return base + 1;
    return base;
  }

  String _getSpellingTarget(ContentItem item) {
    return _direction == LanguageDirection.greekToCatalan
        ? item.catalan.text
        : item.greek.text;
  }

  int _calculateSpeedBonus(int remainingSeconds) {
    if (remainingSeconds >= 8) return 5;
    if (remainingSeconds >= 5) return 3;
    if (remainingSeconds >= 3) return 1;
    return 0;
  }

  int _calculatePhraseTimeBonus(int remainingSeconds, bool isPerfect) {
    if (!isPerfect) return 0;
    if (remainingSeconds >= 20) return 5;
    if (remainingSeconds >= 10) return 2;
    return 0;
  }

  void _submitPhraseAnswer({bool autoSubmit = false}) {
    if (_config == null) return;
    final controller = ref.read(soloPracticeProvider(_config!).notifier);
    final practiceState = ref.read(soloPracticeProvider(_config!));
    if (practiceState.showingFeedback) return;
    _timer?.cancel();

    final total = _phraseTargetWords.length;
    int correctPositions = 0;
    for (int i = 0; i < total; i++) {
      if (i < _phraseWords.length &&
          _phraseWords[i].text == _phraseTargetWords[i]) {
        correctPositions++;
      }
    }

    final baseScore = total == 0 ? 0 : ((20 * correctPositions) / total).floor();
    final isPerfect = correctPositions == total && total > 0;
    final timeBonus = practiceState.timerEnabled
        ? _calculatePhraseTimeBonus(_remainingSeconds, isPerfect)
        : 0;
    final hintCost = _phraseHintUsed ? 3 : 0;
    final pointsAwarded = max(0, baseScore + timeBonus - hintCost).toInt();

    final responseTimeMs = _questionStartTime != null
        ? DateTime.now().difference(_questionStartTime!).inMilliseconds
        : 0;

    final soundEnabled = ref.read(settingsProvider).soundEnabled;
    final soundService = ref.read(soundProvider);
    if (isPerfect) {
      soundService.playSuccess(soundEnabled);
    } else {
      soundService.playError(soundEnabled);
    }

    controller.submitAnswer(
      isCorrect: isPerfect,
      responseTimeMs: responseTimeMs,
      points: pointsAwarded,
    );

    _advanceAfterDelay();
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

  String _buildFeedbackMessage(
    SoloPracticeState practiceState, {
    required bool isPhrase,
    required bool isSpeed,
    required bool isSpelling,
    required bool isListening,
    required bool isMatch,
    MatchMadnessState? matchState,
  }) {
    if (practiceState.lastAnswerCorrect == true) {
      return 'Correct! +${practiceState.results.last.points} points';
    }
    if (isPhrase) {
      return 'Correct order: ${_phraseTargetWords.join(' ')}';
    }
    if (isSpeed) {
      final correct = _speedIsCorrect ? 'TRUE' : 'FALSE';
      return 'Incorrect. Answer: $correct';
    }
    if (isSpelling) {
      return 'Correct spelling: ${_getSpellingTarget(practiceState.currentItem)}';
    }
    if (isListening) {
      final correct = _getSpellingTarget(practiceState.currentItem);
      return 'Incorrect. The answer was: $correct';
    }
    if (isMatch) {
      final matched = matchState?.matchedCount ?? 0;
      final total = matchState?.pairs.length ?? 0;
      return 'Matched $matched / $total';
    }
    return 'Incorrect. The answer was: ${_getSpellingTarget(practiceState.currentItem)}';
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

  List<String> _tokenTexts(List<WordToken> tokens) {
    return tokens.map((t) => t.text).toList();
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _useHint() {
    if (_phraseHintUsed || _phraseTargetWords.isEmpty) return;
    setState(() {
      _phraseHintUsed = true;
      if (_phraseWords.isEmpty) return;
      final first = _phraseTargetWords.first;
      final index =
          _phraseWords.indexWhere((token) => token.text == first);
      if (index <= 0) return;
      final item = _phraseWords.removeAt(index);
      _phraseWords.insert(0, item);
    });
  }

  Future<void> _completeSession() async {
    if (_config == null) return;
    final controller = ref.read(soloPracticeProvider(_config!).notifier);
    final summary = await controller.completeSession();

    if (mounted) {
      context.go(soloResultsRoute, extra: summary);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<MatchMadnessState>(matchMadnessControllerProvider,
        (previous, next) {
      if (_activeGameType != SoloGameType.matchMadness) return;
      if (_matchRoundFinished) return;
      final wasComplete = previous?.isComplete ?? false;
      if (!wasComplete && next.isComplete) {
        _finishMatchRound(allMatched: true);
      }
    });

    // Parse route extras on first build
    if (!_initialized) {
      final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
      if (extra != null) {
        _deckId = extra['deckId'] as String?;
        _mode = extra['mode'] as SoloMode? ?? SoloMode.timed;
        _gameType = extra['gameType'] as SoloGameType? ?? SoloGameType.vocabFlash;
        _direction =
            extra['direction'] as LanguageDirection? ?? LanguageDirection.greekToCatalan;
        _questionCount = extra['questionCount'] as int?;
        _weakWordsOnly = extra['weakWords'] as bool? ?? false;
      }
      _initialized = true;
    }

    if (_deckId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Solo Practice')),
        body: const Center(child: Text('No deck selected')),
      );
    }

    if (_deckId != null) {
      _scheduleSelectedDeckSync();
    }

    final deckAsync = ref.watch(deckProvider);
    final srsItemsAsync = ref.watch(srsItemsProvider);

    return deckAsync.when(
      loading: () =>
          const Scaffold(body: LoadingState(message: 'Loading deck...')),
      error: (error, _) => Scaffold(
        body: ErrorState(
          title: 'Deck unavailable',
          message: 'Please try again.',
          onRetry: () => ref.refresh(deckProvider),
        ),
      ),
      data: (deck) {
        final srsItems = srsItemsAsync.value ?? {};

        // Initialize config and select items
        if (_config == null) {
          if (srsItemsAsync.isLoading) {
            return const Scaffold(
              body: LoadingState(message: 'Loading review data...'),
            );
          }
          final items = _selectItems(deck, srsItems);
          if (items.isEmpty) {
            return Scaffold(
              appBar: AppBar(title: const Text('Solo Practice')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, size: 64, color: Colors.green),
                    const SizedBox(height: 16),
                    const Text('No items to practice!'),
                    const SizedBox(height: 24),
                    DuelButton(
                      label: 'Go Back',
                      onPressed: () => context.go(soloRoute),
                    ),
                  ],
                ),
              ),
            );
          }

          _config = SoloPracticeConfig(
            items: items,
            mode: _mode,
            gameType: _gameType,
            direction: _direction,
            deckId: _deckId!,
          );

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _prepareQuestion();
          });
        }

        final practiceState = ref.watch(soloPracticeProvider(_config!));
        final sourceIsGreek = _getSourceIsGreek();
        final isPhrase = _activeGameType == SoloGameType.phraseBuilder;
        final isMatch = _activeGameType == SoloGameType.matchMadness;
        final isSpeed = _activeGameType == SoloGameType.speedRound;
        final isSpelling = _activeGameType == SoloGameType.spellingBee;
        final isListening = _activeGameType == SoloGameType.listening;
        final matchState =
            isMatch ? ref.watch(matchMadnessControllerProvider) : null;
        final warningThreshold = isMatch
            ? 10
            : isPhrase
                ? 10
                : isSpelling
                    ? 6
                    : isSpeed
                        ? 2
                        : 3;
        final criticalThreshold = isMatch
            ? 5
            : isPhrase
                ? 5
                : isSpelling
                    ? 3
                    : 1;

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
            appBar: AppBar(
              title: const Text('Solo Practice'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.pause),
                  onPressed: _pauseGame,
                ),
              ],
            ),
            body: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Progress & Score
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Q ${practiceState.currentIndex + 1}/${practiceState.totalQuestions}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Score: ${practiceState.totalScore}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (practiceState.timerEnabled) ...[
                        const SizedBox(height: 12),
                        TimerBar(
                          totalSeconds: _questionTotalSeconds,
                          remainingSeconds: _remainingSeconds,
                          warningThreshold: warningThreshold,
                          criticalThreshold: criticalThreshold,
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (isMatch) ...[
                        const Text(
                          'Match the pairs',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w600),
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: ListView.separated(
                                        itemCount:
                                            matchState?.sourceOrder.length ??
                                                0,
                                        separatorBuilder: (_, index) =>
                                            const SizedBox(height: 10),
                                        itemBuilder: (context, index) {
                                          final id =
                                              matchState!.sourceOrder[index];
                                          final pair =
                                              matchState.pairForId(id);
                                          return MatchTile(
                                            text: pair.sourceText,
                                            state: _sourceTileState(
                                              matchState,
                                              id,
                                            ),
                                            onTap: practiceState.showingFeedback
                                                ? null
                                                : () => ref
                                                    .read(
                                                      matchMadnessControllerProvider
                                                          .notifier,
                                                    )
                                                    .selectSource(id),
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: ListView.separated(
                                        itemCount:
                                            matchState?.targetOrder.length ??
                                                0,
                                        separatorBuilder: (_, index) =>
                                            const SizedBox(height: 10),
                                        itemBuilder: (context, index) {
                                          final id =
                                              matchState!.targetOrder[index];
                                          final pair =
                                              matchState.pairForId(id);
                                          return MatchTile(
                                            text: pair.targetText,
                                            state: _targetTileState(
                                              matchState,
                                              id,
                                            ),
                                            onTap: practiceState.showingFeedback
                                                ? null
                                                : () {
                                                    final result = ref
                                                        .read(
                                                          matchMadnessControllerProvider
                                                              .notifier,
                                                        )
                                                        .selectTarget(id);
                                                    final soundEnabled = ref
                                                        .read(settingsProvider)
                                                        .soundEnabled;
                                                    if (result ==
                                                        MatchAttemptResult
                                                            .matched) {
                                                      ref
                                                          .read(soundProvider)
                                                          .playSuccess(
                                                            soundEnabled,
                                                          );
                                                    } else if (result ==
                                                        MatchAttemptResult
                                                            .wrong) {
                                                      ref
                                                          .read(soundProvider)
                                                          .playError(
                                                            soundEnabled,
                                                          );
                                                    }
                                                  },
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
                        const SizedBox(height: 8),
                        Text(
                          'Matched ${matchState?.matchedCount ?? 0} / ${matchState?.pairs.length ?? 0}',
                          textAlign: TextAlign.center,
                        ),
                      ] else if (isSpeed) ...[
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Text(
                                  sourceIsGreek
                                      ? practiceState.currentItem.greek.text
                                      : practiceState.currentItem.catalan.text,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text('='),
                                const SizedBox(height: 8),
                                Text(
                                  _speedDisplayedTranslation,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TrueFalseButtons(
                          enabled: !practiceState.showingFeedback,
                          selectedAnswer: _speedSelectedAnswer,
                          onTrue: () => _submitSpeedAnswer(true),
                          onFalse: () => _submitSpeedAnswer(false),
                        ),
                      ] else ...[
                        FlashCard(
                          text: sourceIsGreek
                              ? practiceState.currentItem.greek.text
                              : practiceState.currentItem.catalan.text,
                          romanization: sourceIsGreek
                              ? practiceState.currentItem.greek.romanization
                              : null,
                          phonetic: sourceIsGreek
                              ? practiceState.currentItem.greek.phonetic
                              : null,
                        ),
                        const SizedBox(height: 16),
                        if (isListening) ...[
                          AudioPlayButton(
                            text: sourceIsGreek
                                ? practiceState.currentItem.greek.text
                                : practiceState.currentItem.catalan.text,
                            languageCode: sourceIsGreek ? 'el' : 'ca',
                            showReplayCost: true,
                            onReplay: () =>
                                setState(() => _listeningReplayUsed = true),
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (!isPhrase && !isSpelling)
                          for (final option in _options)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: OptionTile(
                                label: sourceIsGreek
                                    ? option.catalan.text
                                    : option.greek.text,
                                onPressed: practiceState.showingFeedback
                                    ? null
                                    : () => isListening
                                        ? _submitListeningAnswer(option)
                                        : _selectOption(option),
                              ),
                            ),
                        if (isSpelling) ...[
                          SpellingInput(
                            key: ValueKey('solo-spelling-${practiceState.currentIndex}'),
                            targetLanguage:
                                sourceIsGreek ? 'ca' : 'el',
                            enabled: !practiceState.showingFeedback,
                            onChanged: (value) =>
                                setState(() => _spellingInput = value),
                            onSubmit: (_) => _submitSpellingAnswer(),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: practiceState.showingFeedback
                                ? null
                                : _submitSpellingAnswer,
                            child: const Text('Submit'),
                          ),
                        ],
                        if (isPhrase)
                          Expanded(
                            child: ReorderableListView(
                              buildDefaultDragHandles: false,
                              onReorder: (oldIndex, newIndex) {
                                if (practiceState.showingFeedback) return;
                                if (_phraseHintUsed &&
                                    (oldIndex == 0 || newIndex == 0)) {
                                  return;
                                }
                                setState(() {
                                  if (newIndex > oldIndex) {
                                    newIndex -= 1;
                                  }
                                  final item = _phraseWords.removeAt(oldIndex);
                                  _phraseWords.insert(newIndex, item);
                                });
                              },
                              children: [
                                for (int index = 0;
                                    index < _phraseWords.length;
                                    index++)
                                  WordTile(
                                    key: ValueKey(_phraseWords[index].id),
                                    text: _phraseWords[index].text,
                                    locked: _phraseHintUsed && index == 0,
                                    dragHandle: ReorderableDragStartListener(
                                      index: index,
                                      child: const Icon(Icons.drag_handle),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                      const SizedBox(height: 12),
                      if (practiceState.showingFeedback)
                        AnswerFeedback(
                          message: _buildFeedbackMessage(
                            practiceState,
                            isPhrase: isPhrase,
                            isSpeed: isSpeed,
                            isSpelling: isSpelling,
                            isListening: isListening,
                            isMatch: isMatch,
                            matchState: matchState,
                          ),
                          state: practiceState.lastAnswerCorrect == true
                              ? AnswerFeedbackState.correct
                              : AnswerFeedbackState.incorrect,
                        ),
                      if (isPhrase)
                        SubmitBar(
                          hintEnabled:
                              !practiceState.showingFeedback && !_phraseHintUsed,
                          onHint: _useHint,
                          submitEnabled: !practiceState.showingFeedback,
                          onSubmit: _submitPhraseAnswer,
                        ),
                    ],
                  ),
                ),
                if (_showPauseOverlay) _buildPauseOverlay(),
              ],
            ),
          ),
        );
      },
    );
  }

  List<ContentItem> _selectItems(
    dynamic deck,
    Map<String, dynamic> srsItems,
  ) {
    final items = _poolForGameType(deck);
    final count = _questionCount ?? 10;
    if (items.isEmpty) {
      return const <ContentItem>[];
    }

    if (_mode == SoloMode.srsReview) {
      if (_weakWordsOnly) {
        final weakItems = ref.read(weakItemsProvider);
        final weakIds = weakItems.map((item) => item.itemId).toSet();
        final weakContent =
            items.where((item) => weakIds.contains(item.id)).toList();
        weakContent.shuffle();
        if (weakContent.isEmpty) {
          return const <ContentItem>[];
        }
        if (_questionCount == null) {
          return weakContent;
        }
        return weakContent.take(count.clamp(1, weakContent.length)).toList();
      }

      // Get due items for this deck
      final dueItems = ref.read(dueItemsProvider(_deckId!));
      final dueIds = dueItems.map((item) => item.itemId).toSet();
      final dueContent =
          items.where((item) => dueIds.contains(item.id)).toList();
      dueContent.shuffle();
      if (dueContent.isEmpty) {
        return const <ContentItem>[];
      }
      final maxCount = count.clamp(1, dueContent.length);
      return _questionCount == null
          ? dueContent
          : dueContent.take(maxCount).toList();
    }

    if (_gameType == SoloGameType.mixed) {
      final vocab = deck.vocabularyItems as List<ContentItem>;
      final phrases = deck.phraseItems as List<ContentItem>;
      if (vocab.isNotEmpty && phrases.isNotEmpty) {
        final total = count.clamp(1, items.length);
        var vocabCount = (total / 2).ceil();
        var phraseCount = total - vocabCount;
        if (phraseCount == 0) {
          phraseCount = 1;
          vocabCount = total - 1;
        }

        vocabCount = min(vocabCount, vocab.length);
        phraseCount = min(phraseCount, phrases.length);
        var remaining = total - (vocabCount + phraseCount);
        if (remaining > 0) {
          final vocabRemaining = vocab.length - vocabCount;
          final phraseRemaining = phrases.length - phraseCount;
          if (vocabRemaining >= phraseRemaining && vocabRemaining > 0) {
            final add = min(remaining, vocabRemaining);
            vocabCount += add;
            remaining -= add;
          }
          if (remaining > 0 && phraseRemaining > 0) {
            final add = min(remaining, phraseRemaining);
            phraseCount += add;
          }
        }

        final selected = <ContentItem>[
          ...(List<ContentItem>.from(vocab)..shuffle()).take(vocabCount),
          ...(List<ContentItem>.from(phrases)..shuffle()).take(phraseCount),
        ]..shuffle();
        return selected;
      }
    }

    // Random selection for other modes
    final shuffled = List<ContentItem>.from(items)..shuffle();
    return shuffled.take(count.clamp(1, items.length)).toList();
  }

  List<ContentItem> _poolForGameType(dynamic deck) {
    final vocab = deck.vocabularyItems as List<ContentItem>;
    final phrases = deck.phraseItems as List<ContentItem>;
    switch (_gameType) {
      case SoloGameType.vocabFlash:
        return vocab;
      case SoloGameType.phraseBuilder:
        return phrases.isNotEmpty ? phrases : vocab;
      case SoloGameType.mixed:
        return _interleaveMixed(vocab, phrases);
      case SoloGameType.speedRound:
      case SoloGameType.matchMadness:
      case SoloGameType.spellingBee:
      case SoloGameType.listening:
        return vocab;
    }
  }

  List<ContentItem> _interleaveMixed(
    List<ContentItem> vocab,
    List<ContentItem> phrases,
  ) {
    if (phrases.isEmpty) return vocab;
    if (vocab.isEmpty) return phrases;
    final shuffledVocab = [...vocab]..shuffle();
    final shuffledPhrases = [...phrases]..shuffle();
    final combined = <ContentItem>[];
    final maxLen = max(shuffledVocab.length, shuffledPhrases.length);
    for (int i = 0; i < maxLen; i++) {
      if (i < shuffledVocab.length) combined.add(shuffledVocab[i]);
      if (i < shuffledPhrases.length) combined.add(shuffledPhrases[i]);
    }
    return combined;
  }

  Widget _buildPauseOverlay() {
    return Positioned.fill(
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
                    'Practice Paused',
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
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.go(soloRoute),
                    child: const Text('Quit Practice'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmExit(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quit practice?'),
        content: const Text('Your progress will not be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
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
