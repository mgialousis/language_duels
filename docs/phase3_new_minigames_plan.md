# Phase 3: New Mini-Games - Implementation Plan

**Version:** 1.0
**Created:** 2026-01-27
**Duration:** 3-4 weeks
**Prerequisites:** Phase 1 (Polish), Phase 4 (Audio) for Listening Challenge
**Status:** Planning

---

## Table of Contents

1. [Overview & Goals](#1-overview--goals)
2. [Mini-Game Specifications](#2-mini-game-specifications)
3. [Shared Components](#3-shared-components)
4. [Data Models](#4-data-models)
5. [UI/UX Specifications](#5-uiux-specifications)
6. [Game Selection System](#6-game-selection-system)
7. [Implementation Tasks](#7-implementation-tasks)
8. [Testing Strategy](#8-testing-strategy)

---

## 1. Overview & Goals

### 1.1 Problem Statement

Currently, Language Duel has only 2 mini-games (Vocab Flash and Phrase Builder). This limits:
- Variety in gameplay (users may get bored)
- Learning modalities covered (only recognition and construction)
- Competitive strategies (limited ways to win)
- Replay value

### 1.2 Goals

| Goal | Success Metric |
|------|----------------|
| Add gameplay variety | 4 new mini-games playable |
| Cover more learning modalities | Listening, spelling, speed recall, association |
| Increase engagement | 20% increase in session length |
| Maintain balance | All games viable in competition |
| Keep it fun | User feedback rating ≥ 4.0 |

### 1.3 New Mini-Games Overview

| Game | Type | Timer | Skills Tested | Difficulty |
|------|------|-------|---------------|------------|
| **Speed Round** | True/False | 5s × 10 | Quick recall, decision making | Easy |
| **Match Madness** | Pair matching | 45s total | Association, memory | Medium |
| **Listening Challenge** | Audio → Text | 10s | Listening comprehension | Medium |
| **Spelling Bee** | Text → Type | 20s | Spelling, production | Hard |

### 1.4 Implementation Order

| Order | Game | Rationale | Dependencies |
|-------|------|-----------|--------------|
| 1 | Speed Round | Simplest, no new mechanics | None |
| 2 | Match Madness | Medium complexity, engaging | None |
| 3 | Spelling Bee | Keyboard handling | None |
| 4 | Listening Challenge | Requires TTS | Phase 4 (Audio) |

### 1.5 User Stories

```
US-1: As a player, I want more mini-game options so duels feel
      fresh and varied.

US-2: As a competitive player, I want games that test different
      skills so I can find my strengths.

US-3: As a learner, I want to practice listening so I can
      understand spoken language.

US-4: As a learner, I want to practice spelling so I can
      write correctly in the target language.

US-5: As a player, I want fast-paced games for quick sessions.
```

---

## 2. Mini-Game Specifications

### 2.1 Speed Round

#### 2.1.1 Concept

Rapid-fire true/false questions testing if a word-translation pair is correct. Players must make quick decisions under time pressure.

#### 2.1.2 Mechanics

**Question Format:**
```
┌─────────────────────────────────────────┐
│                                         │
│         "Καλημέρα" = "Bon dia"          │
│                                         │
│              TRUE or FALSE?             │
│                                         │
└─────────────────────────────────────────┘
```

**Rules:**
- 10 questions per player turn
- 5 seconds per question
- 50% true pairs, 50% false pairs (randomized)
- False pairs use plausible distractors (semantic siblings)
- No answer review between questions (keeps pace fast)
- Summary shown after all 10 questions

**Generation Logic:**
```dart
class SpeedRoundQuestion {
  final String sourceText;
  final String displayedTranslation;
  final bool isCorrect;
  final String actualTranslation; // For false pairs, show in summary

  factory SpeedRoundQuestion.generate(ContentItem item, List<ContentItem> pool, bool makeCorrect) {
    if (makeCorrect) {
      return SpeedRoundQuestion(
        sourceText: item.greek.text,
        displayedTranslation: item.catalan.text,
        isCorrect: true,
        actualTranslation: item.catalan.text,
      );
    } else {
      // Pick distractor from same category
      final distractor = _pickDistractor(item, pool);
      return SpeedRoundQuestion(
        sourceText: item.greek.text,
        displayedTranslation: distractor.catalan.text,
        isCorrect: false,
        actualTranslation: item.catalan.text,
      );
    }
  }
}
```

#### 2.1.3 Scoring

| Outcome | Points | Notes |
|---------|--------|-------|
| Correct | +5 | No speed bonus (already time-pressured) |
| Wrong | 0 | No penalty |
| Timeout | 0 | Counts as wrong |

**Maximum per round:** 50 points (10 × 5)

#### 2.1.4 Difficulty Variants

| Level | Timer | Question Count |
|-------|-------|----------------|
| Easy | 6 seconds | 10 |
| Normal | 5 seconds | 10 |
| Hard | 4 seconds | 10 |

#### 2.1.5 False Pair Generation Rules

**Priority for distractors:**
1. Same category (greeting → greeting, color → color)
2. Similar difficulty level
3. Similar word length
4. Never use the correct answer

**Avoid:**
- Translations that are obviously wrong (different category)
- Very long translations paired with short source words
- Same distractor appearing twice in a session

---

### 2.2 Match Madness

#### 2.2.1 Concept

Connect 6 source words with their 6 translations before time runs out. Tests association and visual scanning under pressure.

#### 2.2.2 Mechanics

**Layout:**
```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   SOURCE (Greek)              TARGET (Catalan)              │
│                                                             │
│   ┌─────────────┐             ┌─────────────┐               │
│   │  Καλημέρα   │             │   Adeu      │               │
│   └─────────────┘             └─────────────┘               │
│                                                             │
│   ┌─────────────┐             ┌─────────────┐               │
│   │   Αντίο     │             │  Bon dia    │               │
│   └─────────────┘             └─────────────┘               │
│                                                             │
│   ┌─────────────┐             ┌─────────────┐               │
│   │  Ευχαριστώ  │             │   Hola      │               │
│   └─────────────┘             └─────────────┘               │
│                                                             │
│   ┌─────────────┐             ┌─────────────┐               │
│   │    Γεια     │             │  Gràcies    │               │
│   └─────────────┘             └─────────────┘               │
│                                                             │
│   ┌─────────────┐             ┌─────────────┐               │
│   │  Παρακαλώ   │             │  Si us plau │               │
│   └─────────────┘             └─────────────┘               │
│                                                             │
│   ┌─────────────┐             ┌─────────────┐               │
│   │    Ναι      │             │     Sí      │               │
│   └─────────────┘             └─────────────┘               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Rules:**
- 6 pairs to match per round
- 45 seconds total time
- Tap source word, then tap matching target
- Correct match: both tiles disappear with animation
- Wrong match: both tiles shake, brief red flash, try again
- No penalty for wrong attempts (just wastes time)
- Round ends when all matched OR time runs out

**Selection State:**
```dart
enum MatchSelectionState {
  none,           // Nothing selected
  sourceSelected, // Source word highlighted, waiting for target
  matched,        // Pair matched, animating out
  wrong,          // Wrong pair, showing error feedback
}
```

#### 2.2.3 Scoring

| Outcome | Points | Notes |
|---------|--------|-------|
| Correct match | +3 | Per pair |
| Time bonus | +1 per 5s remaining | Only if all 6 matched |
| Incomplete | 0 for unmatched | Partial credit for matches made |

**Scoring Formula:**
```dart
int calculateMatchMadnessScore(int matchedPairs, int secondsRemaining) {
  int baseScore = matchedPairs * 3; // 0-18 points

  // Time bonus only if completed all 6
  int timeBonus = 0;
  if (matchedPairs == 6) {
    timeBonus = secondsRemaining ~/ 5; // +1 per 5 seconds
  }

  return baseScore + timeBonus;
}
```

**Maximum per round:** ~27 points (18 base + 9 time bonus if done in <1 sec)
**Realistic maximum:** ~24 points (18 base + 6 time bonus)

#### 2.2.4 Visual Feedback

| State | Visual |
|-------|--------|
| Unselected | Default card style |
| Source selected | Blue highlight, elevated |
| Correct match | Green flash, scale down, fade out |
| Wrong match | Red flash, horizontal shake |
| Matched (gone) | Empty space or collapsed |

#### 2.2.5 Pair Selection

**Rules for selecting 6 pairs:**
1. All from same deck
2. Mix of difficulties (2 easy, 2 medium, 2 hard)
3. No duplicate translations (avoid confusion)
4. Shuffle both columns independently

---

### 2.3 Listening Challenge

#### 2.3.1 Concept

Hear a word or phrase spoken aloud, then select the correct written form from multiple options. Tests listening comprehension and reading recognition.

#### 2.3.2 Mechanics

**Flow:**
```
1. Audio plays automatically (source language)
2. 4 written options appear (target language)
3. Player selects answer
4. Feedback shown
5. Next question
```

**Question Format:**
```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│                        🔊 [Playing...]                      │
│                                                             │
│                   "Kalimera" (audio plays)                  │
│                                                             │
│                     [🔊 Replay] (-2 pts)                    │
│                                                             │
│   ┌─────────────────────────────────────────────────────┐   │
│   │                    Bon dia                          │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                             │
│   ┌─────────────────────────────────────────────────────┐   │
│   │                    Bona nit                         │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                             │
│   ┌─────────────────────────────────────────────────────┐   │
│   │                    Adeu                             │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                             │
│   ┌─────────────────────────────────────────────────────┐   │
│   │                    Hola                             │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Rules:**
- 5 questions per player turn (same as Vocab Flash)
- 10 seconds per question (timer starts after audio plays)
- Audio plays once automatically
- Optional replay costs 2 points
- 4 answer options (1 correct, 3 distractors)
- Direction: Listen in source → Read in target

#### 2.3.3 Scoring

| Outcome | Points | Notes |
|---------|--------|-------|
| Correct (no replay) | +10 | Base points |
| Correct (with replay) | +8 | -2 for replay |
| Speed bonus | +1 to +5 | Same tiers as Vocab Flash |
| Wrong | 0 | No penalty |
| Timeout | 0 | - |

**Maximum per round:** 75 points (same as Vocab Flash)

#### 2.3.4 Audio Integration

**Dependencies:**
- Phase 4 (Audio & Pronunciation) must be complete
- TTS service for Greek and Catalan
- Audio playback controls

**Audio Service Interface:**
```dart
abstract class IAudioService {
  Future<void> speak(String text, String languageCode);
  Future<void> stop();
  bool get isPlaying;
}
```

**Fallback:**
If TTS unavailable for a language:
- Show romanization/phonetic hint instead
- Display warning: "Audio not available for this language"
- Game still playable but less effective

#### 2.3.5 Distractor Selection

Same rules as Vocab Flash:
1. Semantic siblings first
2. Same category
3. Similar difficulty
4. Never repeat in same round

---

### 2.4 Spelling Bee

#### 2.4.1 Concept

See (and optionally hear) a word in the source language, then type the correct translation. Tests active production and spelling accuracy.

#### 2.4.2 Mechanics

**Flow:**
```
1. Source word displayed (with optional audio)
2. Text input field appears
3. Player types translation
4. Submit or timeout
5. Feedback with correct spelling
```

**Question Format:**
```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│                    Translate to Catalan:                    │
│                                                             │
│                       "Καλημέρα"                            │
│                      (Kalimera)                             │
│                        [🔊]                                 │
│                                                             │
│   ┌─────────────────────────────────────────────────────┐   │
│   │                                                     │   │
│   │  Type your answer: Bon di_                          │   │
│   │                                                     │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                             │
│   Hint: 2 words, 7 letters total                           │
│                                                             │
│              ┌────────────────────────┐                     │
│              │        SUBMIT          │                     │
│              └────────────────────────┘                     │
│                                                             │
│                      ⏱️ 0:15                                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Rules:**
- 5 questions per player turn
- 20 seconds per question
- On-screen keyboard or device keyboard
- Case-insensitive matching
- Accent-tolerant matching (partial credit)
- Hint shows word count and total letters

#### 2.4.3 Answer Validation

```dart
class SpellingValidator {
  static SpellingResult validate(String userAnswer, String correctAnswer) {
    final normalizedUser = _normalize(userAnswer);
    final normalizedCorrect = _normalize(correctAnswer);

    if (normalizedUser == normalizedCorrect) {
      return SpellingResult.perfect;
    }

    // Check without accents
    final userNoAccents = _removeAccents(normalizedUser);
    final correctNoAccents = _removeAccents(normalizedCorrect);

    if (userNoAccents == correctNoAccents) {
      return SpellingResult.accentError;
    }

    // Calculate similarity (Levenshtein distance)
    final distance = _levenshteinDistance(normalizedUser, normalizedCorrect);
    final similarity = 1 - (distance / correctAnswer.length);

    if (similarity >= 0.8) {
      return SpellingResult.minorError; // 1-2 character mistakes
    } else if (similarity >= 0.5) {
      return SpellingResult.majorError; // Recognizable attempt
    } else {
      return SpellingResult.wrong; // Too different
    }
  }

  static String _normalize(String s) {
    return s.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String _removeAccents(String s) {
    // Map accented characters to base characters
    const accents = 'àáâãäåèéêëìíîïòóôõöùúûüñç';
    const base =    'aaaaaaeeeeiiiioooooouuuunc';
    // ... implementation
    return s;
  }
}

enum SpellingResult {
  perfect,     // Exact match
  accentError, // Only accent mistakes
  minorError,  // 1-2 character mistakes
  majorError,  // Recognizable but significant errors
  wrong,       // Completely wrong
}
```

#### 2.4.4 Scoring

| Result | Points | Feedback |
|--------|--------|----------|
| Perfect | +15 | "Perfect! ✓" |
| Accent error | +12 | "Almost! Watch the accents: [correct]" |
| Minor error (1-2 chars) | +8 | "Close! Correct spelling: [correct]" |
| Major error | +3 | "Keep practicing! Answer: [correct]" |
| Wrong | 0 | "The answer was: [correct]" |
| Timeout | 0 | "Time's up! Answer: [correct]" |

**Speed Bonus (only for Perfect):**
| Time Remaining | Bonus |
|----------------|-------|
| 15-20s | +5 |
| 10-14s | +3 |
| 5-9s | +1 |
| 0-4s | +0 |

**Maximum per round:** 100 points (5 × 20 with speed bonus)
**Realistic maximum:** ~75-85 points

#### 2.4.5 Keyboard Handling

**Requirements:**
- Auto-focus text field when question appears
- Show keyboard immediately
- Support special characters (Greek: ά, έ, ή, etc. / Catalan: à, é, ç, etc.)
- Clear button to reset input
- Submit on Enter/Done key

**Special Character Input:**
```dart
// Option 1: Device keyboard with language support
// - Requires user to have Greek/Catalan keyboard installed

// Option 2: Custom character bar for special characters
class SpecialCharacterBar extends StatelessWidget {
  final String language; // 'el' or 'ca'
  final Function(String) onCharacterTap;

  List<String> get characters {
    return switch (language) {
      'el' => ['ά', 'έ', 'ή', 'ί', 'ό', 'ύ', 'ώ', 'ς'],
      'ca' => ['à', 'è', 'é', 'í', 'ï', 'ò', 'ó', 'ú', 'ü', 'ç', 'l·l'],
      _ => [],
    };
  }
}
```

#### 2.4.6 Difficulty Considerations

**A1 Level Accommodations:**
- Show word count hint
- Show letter count hint
- Generous partial credit
- 20 seconds is plenty for short words

**Item Selection for Spelling Bee:**
- Prefer shorter words (≤8 characters)
- Avoid complex phrases (stick to vocabulary type)
- Mix difficulties: 2 easy, 2 medium, 1 hard

---

## 3. Shared Components

### 3.1 Base Mini-Game Controller

```dart
// lib/features/games/base/mini_game_controller.dart

abstract class MiniGameController<TState> extends StateNotifier<TState> {
  MiniGameController(super.initialState);

  /// Initialize the game with content
  void initialize(List<ContentItem> items, LanguageDirection direction);

  /// Process an answer and return points earned
  int submitAnswer(dynamic answer);

  /// Move to next question (if applicable)
  void nextQuestion();

  /// Check if the game round is complete
  bool get isComplete;

  /// Get current score
  int get currentScore;

  /// Reset for new round
  void reset();
}
```

### 3.2 Mini-Game Result Model

```dart
// lib/data/models/mini_game_result.dart

class MiniGameResult {
  final MiniGameType gameType;
  final int playerNumber;
  final int score;
  final int maxPossibleScore;
  final int questionsCorrect;
  final int questionsTotal;
  final Duration timeTaken;
  final List<QuestionResult> questionResults;

  double get accuracy => questionsTotal > 0
      ? questionsCorrect / questionsTotal
      : 0.0;

  double get scorePercentage => maxPossibleScore > 0
      ? score / maxPossibleScore
      : 0.0;
}
```

### 3.3 Mini-Game Type Enum Update

```dart
// lib/data/models/mini_game_type.dart

enum MiniGameType {
  vocabFlash(
    displayName: 'Vocab Flash',
    description: 'Multiple choice vocabulary',
    icon: Icons.flash_on,
    questionsPerRound: 5,
    maxPointsPerRound: 75,
    estimatedSeconds: 60,
  ),
  phraseBuilder(
    displayName: 'Phrase Builder',
    description: 'Arrange words in order',
    icon: Icons.sort,
    questionsPerRound: 3,
    maxPointsPerRound: 75,
    estimatedSeconds: 120,
  ),
  speedRound(
    displayName: 'Speed Round',
    description: 'True or false - fast!',
    icon: Icons.speed,
    questionsPerRound: 10,
    maxPointsPerRound: 50,
    estimatedSeconds: 60,
  ),
  matchMadness(
    displayName: 'Match Madness',
    description: 'Connect the pairs',
    icon: Icons.compare_arrows,
    questionsPerRound: 6, // pairs
    maxPointsPerRound: 27,
    estimatedSeconds: 45,
  ),
  listeningChallenge(
    displayName: 'Listening Challenge',
    description: 'Hear and identify',
    icon: Icons.hearing,
    questionsPerRound: 5,
    maxPointsPerRound: 75,
    estimatedSeconds: 60,
    requiresAudio: true,
  ),
  spellingBee(
    displayName: 'Spelling Bee',
    description: 'Type the translation',
    icon: Icons.keyboard,
    questionsPerRound: 5,
    maxPointsPerRound: 100,
    estimatedSeconds: 120,
  );

  final String displayName;
  final String description;
  final IconData icon;
  final int questionsPerRound;
  final int maxPointsPerRound;
  final int estimatedSeconds;
  final bool requiresAudio;

  const MiniGameType({
    required this.displayName,
    required this.description,
    required this.icon,
    required this.questionsPerRound,
    required this.maxPointsPerRound,
    required this.estimatedSeconds,
    this.requiresAudio = false,
  });
}
```

### 3.4 Shared Widgets

#### 3.4.1 TrueFalseButtons

```dart
// lib/shared/widgets/true_false_buttons.dart

class TrueFalseButtons extends StatelessWidget {
  final VoidCallback onTrue;
  final VoidCallback onFalse;
  final bool enabled;
  final bool? selectedAnswer; // null = none, true/false = selected

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _AnswerButton(
            label: 'TRUE',
            color: Colors.green,
            onPressed: enabled ? onTrue : null,
            isSelected: selectedAnswer == true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _AnswerButton(
            label: 'FALSE',
            color: Colors.red,
            onPressed: enabled ? onFalse : null,
            isSelected: selectedAnswer == false,
          ),
        ),
      ],
    );
  }
}
```

#### 3.4.2 MatchTile

```dart
// lib/shared/widgets/match_tile.dart

class MatchTile extends StatelessWidget {
  final String text;
  final MatchTileState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor, width: 2),
        boxShadow: state == MatchTileState.selected
            ? [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8)]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: state == MatchTileState.matched ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: state == MatchTileState.matched
                    ? Colors.grey
                    : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum MatchTileState {
  idle,
  selected,
  matched,
  wrong,
}
```

#### 3.4.3 SpellingInput

```dart
// lib/shared/widgets/spelling_input.dart

class SpellingInput extends StatefulWidget {
  final String targetLanguage;
  final Function(String) onSubmit;
  final bool enabled;
  final String? hint;

  @override
  State<SpellingInput> createState() => _SpellingInputState();
}

class _SpellingInputState extends State<SpellingInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus when widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24),
          decoration: InputDecoration(
            hintText: widget.hint ?? 'Type your answer...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => _controller.clear(),
            ),
          ),
          onSubmitted: widget.onSubmit,
        ),
        const SizedBox(height: 8),
        SpecialCharacterBar(
          language: widget.targetLanguage,
          onCharacterTap: (char) {
            _controller.text += char;
            _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: _controller.text.length),
            );
          },
        ),
      ],
    );
  }
}
```

#### 3.4.4 AudioPlayButton

```dart
// lib/shared/widgets/audio_play_button.dart

class AudioPlayButton extends ConsumerWidget {
  final String text;
  final String languageCode;
  final double size;
  final bool showReplayCost;
  final int replayCost;
  final VoidCallback? onReplay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioService = ref.watch(audioServiceProvider);
    final isPlaying = ref.watch(audioPlayingProvider);

    return Column(
      children: [
        IconButton(
          iconSize: size,
          icon: Icon(
            isPlaying ? Icons.volume_up : Icons.volume_up_outlined,
            color: isPlaying ? Theme.of(context).primaryColor : null,
          ),
          onPressed: () async {
            onReplay?.call();
            await audioService.speak(text, languageCode);
          },
        ),
        if (showReplayCost)
          Text(
            '(-$replayCost pts)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
      ],
    );
  }
}
```

---

## 4. Data Models

### 4.1 Speed Round Models

```dart
// lib/features/games/speed_round/speed_round_state.dart

class SpeedRoundQuestion {
  final String sourceText;
  final String displayedTranslation;
  final bool isCorrect;
  final String actualTranslation;

  const SpeedRoundQuestion({
    required this.sourceText,
    required this.displayedTranslation,
    required this.isCorrect,
    required this.actualTranslation,
  });
}

class SpeedRoundState {
  final List<SpeedRoundQuestion> questions;
  final int currentIndex;
  final List<bool?> answers; // null = not answered, true/false = player's answer
  final int score;
  final bool isComplete;

  const SpeedRoundState({
    required this.questions,
    this.currentIndex = 0,
    this.answers = const [],
    this.score = 0,
    this.isComplete = false,
  });

  SpeedRoundQuestion get currentQuestion => questions[currentIndex];
  int get correctCount => answers.where((a) => a == questions[answers.indexOf(a)].isCorrect).length;

  SpeedRoundState copyWith({
    List<SpeedRoundQuestion>? questions,
    int? currentIndex,
    List<bool?>? answers,
    int? score,
    bool? isComplete,
  }) {
    return SpeedRoundState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      score: score ?? this.score,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}
```

### 4.2 Match Madness Models

```dart
// lib/features/games/match_madness/match_madness_state.dart

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

class MatchMadnessState {
  final List<MatchPair> pairs;
  final List<String> sourceOrder;  // Shuffled order of source items
  final List<String> targetOrder;  // Shuffled order of target items
  final String? selectedSourceId;
  final String? selectedTargetId;
  final MatchFeedback? feedback;   // Current feedback state
  final int matchedCount;
  final int wrongAttempts;
  final int score;
  final bool isComplete;

  const MatchMadnessState({
    required this.pairs,
    required this.sourceOrder,
    required this.targetOrder,
    this.selectedSourceId,
    this.selectedTargetId,
    this.feedback,
    this.matchedCount = 0,
    this.wrongAttempts = 0,
    this.score = 0,
    this.isComplete = false,
  });

  bool isPairMatched(String id) => pairs.firstWhere((p) => p.id == id).isMatched;
}

enum MatchFeedback {
  correct,
  wrong,
}
```

### 4.3 Listening Challenge Models

```dart
// lib/features/games/listening/listening_state.dart

class ListeningQuestion {
  final String itemId;
  final String audioText;        // Text to speak (source language)
  final String audioLanguage;    // Language code for TTS
  final String correctAnswer;    // Written form (target language)
  final List<String> options;    // 4 options including correct
  final int correctIndex;

  const ListeningQuestion({
    required this.itemId,
    required this.audioText,
    required this.audioLanguage,
    required this.correctAnswer,
    required this.options,
    required this.correctIndex,
  });
}

class ListeningState {
  final List<ListeningQuestion> questions;
  final int currentIndex;
  final bool hasPlayedAudio;
  final int replayCount;
  final int? selectedIndex;
  final bool isAnswered;
  final AnswerFeedbackState feedbackState;
  final String feedbackMessage;
  final int score;
  final bool isComplete;

  const ListeningState({
    required this.questions,
    this.currentIndex = 0,
    this.hasPlayedAudio = false,
    this.replayCount = 0,
    this.selectedIndex,
    this.isAnswered = false,
    this.feedbackState = AnswerFeedbackState.neutral,
    this.feedbackMessage = '',
    this.score = 0,
    this.isComplete = false,
  });

  ListeningQuestion get currentQuestion => questions[currentIndex];
  int get replayCost => replayCount > 0 ? 2 : 0; // First play is free
}
```

### 4.4 Spelling Bee Models

```dart
// lib/features/games/spelling/spelling_state.dart

class SpellingQuestion {
  final String itemId;
  final String sourceText;
  final String sourceRomanization;
  final String correctAnswer;
  final int wordCount;
  final int letterCount;

  const SpellingQuestion({
    required this.itemId,
    required this.sourceText,
    required this.sourceRomanization,
    required this.correctAnswer,
    required this.wordCount,
    required this.letterCount,
  });

  factory SpellingQuestion.fromItem(ContentItem item, LanguageDirection direction) {
    final source = direction == LanguageDirection.greekToCatalan
        ? item.greek
        : item.catalan;
    final target = direction == LanguageDirection.greekToCatalan
        ? item.catalan.text
        : item.greek.text;

    return SpellingQuestion(
      itemId: item.id,
      sourceText: source.text,
      sourceRomanization: source.romanization ?? '',
      correctAnswer: target,
      wordCount: target.split(' ').length,
      letterCount: target.replaceAll(' ', '').length,
    );
  }
}

class SpellingState {
  final List<SpellingQuestion> questions;
  final int currentIndex;
  final String userInput;
  final bool isSubmitted;
  final SpellingResult? result;
  final int pointsEarned;
  final int score;
  final bool isComplete;

  const SpellingState({
    required this.questions,
    this.currentIndex = 0,
    this.userInput = '',
    this.isSubmitted = false,
    this.result,
    this.pointsEarned = 0,
    this.score = 0,
    this.isComplete = false,
  });

  SpellingQuestion get currentQuestion => questions[currentIndex];
}
```

---

## 5. UI/UX Specifications

### 5.1 Speed Round Screen

```
┌─────────────────────────────────────────────────────────────────┐
│  [Score: 25]              SPEED ROUND             [Q: 6/10]     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                          ⏱️ 4.2s                                │
│                    [████████░░░░░░░░░░░░]                       │
│                                                                 │
│     ┌───────────────────────────────────────────────────┐       │
│     │                                                   │       │
│     │                                                   │       │
│     │            "Καλησπέρα"                           │       │
│     │                  =                                │       │
│     │            "Bona tarda"                          │       │
│     │                                                   │       │
│     │                  ?                                │       │
│     │                                                   │       │
│     └───────────────────────────────────────────────────┘       │
│                                                                 │
│                                                                 │
│     ┌─────────────────┐      ┌─────────────────┐                │
│     │                 │      │                 │                │
│     │      TRUE       │      │      FALSE      │                │
│     │       ✓         │      │        ✗        │                │
│     │                 │      │                 │                │
│     └─────────────────┘      └─────────────────┘                │
│           [Green]                  [Red]                        │
│                                                                 │
│                                                                 │
│     ┌───────────────────────────────────────────────────┐       │
│     │  ● ● ● ● ● ○ ○ ○ ○ ○    Progress dots             │       │
│     └───────────────────────────────────────────────────┘       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Key Interactions:**
- Large TRUE/FALSE buttons for quick tapping
- Minimal UI to reduce cognitive load
- Progress dots show position in round
- Timer is prominent but not distracting
- Instant transition to next question (no feedback delay)

### 5.2 Match Madness Screen

```
┌─────────────────────────────────────────────────────────────────┐
│  [Score: 12]            MATCH MADNESS             ⏱️ 0:32       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│        SOURCE                           TARGET                  │
│                                                                 │
│   ┌─────────────┐                 ┌─────────────┐               │
│   │             │                 │             │               │
│   │  Καλημέρα   │                 │    Adeu     │               │
│   │   [Blue]    │                 │             │               │
│   └─────────────┘                 └─────────────┘               │
│                                                                 │
│   ┌ ─ ─ ─ ─ ─ ─ ┐                 ┌─────────────┐               │
│   │  (matched)  │                 │             │               │
│   │             │                 │   Bon dia   │               │
│   └ ─ ─ ─ ─ ─ ─ ┘                 │             │               │
│                                   └─────────────┘               │
│   ┌─────────────┐                                               │
│   │             │                 ┌ ─ ─ ─ ─ ─ ─ ┐               │
│   │  Ευχαριστώ  │                 │  (matched)  │               │
│   │             │                 │             │               │
│   └─────────────┘                 └ ─ ─ ─ ─ ─ ─ ┘               │
│                                                                 │
│   ┌─────────────┐                 ┌─────────────┐               │
│   │             │                 │             │               │
│   │    Γεια     │                 │   Gràcies   │               │
│   │             │                 │             │               │
│   └─────────────┘                 └─────────────┘               │
│                                                                 │
│                                                                 │
│     Matched: 2/6                                                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Key Interactions:**
- Tap source → highlight → tap target → validate
- Matched pairs fade out or collapse
- Wrong matches shake briefly
- Timer creates urgency
- Visual feedback immediate

### 5.3 Listening Challenge Screen

```
┌─────────────────────────────────────────────────────────────────┐
│  [Score: 35]         LISTENING CHALLENGE          [Q: 3/5]      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                          ⏱️ 7.5s                                │
│                    [████████████░░░░░░░░]                       │
│                                                                 │
│     ┌───────────────────────────────────────────────────┐       │
│     │                                                   │       │
│     │                    🔊                             │       │
│     │                                                   │       │
│     │              [Playing audio...]                   │       │
│     │                                                   │       │
│     │           ┌──────────────────────┐                │       │
│     │           │   🔊 Replay (-2 pts) │                │       │
│     │           └──────────────────────┘                │       │
│     │                                                   │       │
│     └───────────────────────────────────────────────────┘       │
│                                                                 │
│     What did you hear?                                          │
│                                                                 │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                      Bon dia                            │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                      Bona nit                           │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                        Adeu                             │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                        Hola                             │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Key Interactions:**
- Audio auto-plays on question load
- Replay button visible with cost
- Timer starts after audio finishes
- Same option tile interaction as Vocab Flash

### 5.4 Spelling Bee Screen

```
┌─────────────────────────────────────────────────────────────────┐
│  [Score: 42]            SPELLING BEE              [Q: 3/5]      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                          ⏱️ 14.2s                               │
│                    [██████████████░░░░░░]                       │
│                                                                 │
│     ┌───────────────────────────────────────────────────┐       │
│     │                                                   │       │
│     │            Translate to Catalan:                  │       │
│     │                                                   │       │
│     │                 "Καλημέρα"                        │       │
│     │                (Kalimera)                         │       │
│     │                   [🔊]                            │       │
│     │                                                   │       │
│     └───────────────────────────────────────────────────┘       │
│                                                                 │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                                                         │   │
│   │                    Bon di█                              │   │
│   │                                                         │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│   ┌───┬───┬───┬───┬───┬───┬───┬───┬───┐                         │
│   │ à │ è │ é │ í │ ï │ ò │ ó │ ú │ ç │  Special characters     │
│   └───┴───┴───┴───┴───┴───┴───┴───┴───┘                         │
│                                                                 │
│   Hint: 2 words, 6 letters                                      │
│                                                                 │
│              ┌─────────────────────────────┐                    │
│              │          SUBMIT             │                    │
│              └─────────────────────────────┘                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Key Interactions:**
- Auto-focus text field
- Special character bar for accents
- Clear hint about expected answer length
- Submit button or Enter key
- Optional audio pronunciation

### 5.5 Feedback Screens

**Speed Round Summary (shown after all 10):**
```
┌─────────────────────────────────────────────────────────────────┐
│                     SPEED ROUND COMPLETE                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                    Score: 40/50                                 │
│                    8/10 correct                                 │
│                                                                 │
│     ┌───────────────────────────────────────────────────┐       │
│     │  Results breakdown:                               │       │
│     │                                                   │       │
│     │  ✓ Καλημέρα = Bon dia                            │       │
│     │  ✓ Αντίο = Adeu                                   │       │
│     │  ✗ Ευχαριστώ = Gràcies (you said: Si us plau)    │       │
│     │  ✓ Γεια = Hola                                    │       │
│     │  ...                                              │       │
│     └───────────────────────────────────────────────────┘       │
│                                                                 │
│              ┌─────────────────────────────┐                    │
│              │         CONTINUE            │                    │
│              └─────────────────────────────┘                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 6. Game Selection System

### 6.1 Duel Mode Game Selection

**Current:** Fixed order (Vocab Flash → Phrase Builder)

**New Options:**

**Option A: Player Selection**
```
Before duel starts:
┌─────────────────────────────────────────────────────────────────┐
│                    SELECT MINI-GAMES                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   Choose 2 mini-games for this duel:                           │
│                                                                 │
│   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│   │ Vocab Flash │  │   Phrase    │  │   Speed     │             │
│   │     ✓       │  │   Builder   │  │   Round     │             │
│   └─────────────┘  └─────────────┘  └─────────────┘             │
│                                                                 │
│   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│   │   Match     │  │  Listening  │  │  Spelling   │             │
│   │   Madness   │  │     ✓       │  │    Bee      │             │
│   └─────────────┘  └─────────────┘  └─────────────┘             │
│                                                                 │
│   Selected: Vocab Flash, Listening Challenge                    │
│                                                                 │
│              ┌─────────────────────────────┐                    │
│              │       START DUEL            │                    │
│              └─────────────────────────────┘                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Option B: Random Selection**
- System picks 2 random games
- Players see selection before starting
- "Shuffle" button to re-randomize

**Option C: Classic Mode (Default)**
- Keep current fixed order
- Option in settings to enable game selection

### 6.2 Solo Mode Game Selection

Already handled in Phase 2 - player picks game type in Solo Setup.

### 6.3 Game Availability

```dart
class GameAvailability {
  static List<MiniGameType> getAvailableGames(BuildContext context) {
    final hasAudio = context.read(audioAvailableProvider);

    return MiniGameType.values.where((game) {
      if (game.requiresAudio && !hasAudio) return false;
      return true;
    }).toList();
  }
}
```

### 6.4 Balanced Scoring

**Issue:** Games have different max scores (50-100 range)

**Solution:** Normalize or accept variance

**Option A: Accept Variance**
- Some games are higher risk/reward
- Adds strategic element to game selection
- Simple to implement

**Option B: Normalize Scores**
- Convert all scores to percentage of max
- Final score = average percentage × 100
- More balanced but less intuitive

**Recommendation:** Accept variance for MVP, evaluate after user feedback.

---

## 7. Implementation Tasks

### 7.1 Sprint Breakdown

#### Sprint 1: Speed Round + Match Madness (Week 1-2)

| ID | Task | Estimate | Dependencies | Priority |
|----|------|----------|--------------|----------|
| S1-01 | Create SpeedRoundQuestion model | 1h | - | P0 |
| S1-02 | Create SpeedRoundState model | 1h | S1-01 | P0 |
| S1-03 | Implement SpeedRoundController | 4h | S1-02 | P0 |
| S1-04 | Create TrueFalseButtons widget | 2h | - | P0 |
| S1-05 | Create SpeedRoundScreen | 4h | S1-03, S1-04 | P0 |
| S1-06 | Create SpeedRoundSummaryScreen | 2h | S1-05 | P0 |
| S1-07 | Add speed round route + navigation | 1h | S1-05 | P0 |
| S1-08 | Create MatchPair model | 1h | - | P0 |
| S1-09 | Create MatchMadnessState model | 2h | S1-08 | P0 |
| S1-10 | Implement MatchMadnessController | 4h | S1-09 | P0 |
| S1-11 | Create MatchTile widget | 3h | - | P0 |
| S1-12 | Create MatchMadnessScreen | 5h | S1-10, S1-11 | P0 |
| S1-13 | Add match madness route + navigation | 1h | S1-12 | P0 |
| S1-14 | Unit tests for Speed Round logic | 2h | S1-03 | P1 |
| S1-15 | Unit tests for Match Madness logic | 2h | S1-10 | P1 |
| S1-16 | Widget tests for new screens | 3h | S1-05, S1-12 | P1 |

**Sprint 1 Total: ~38 hours**

#### Sprint 2: Spelling Bee (Week 2-3)

| ID | Task | Estimate | Dependencies | Priority |
|----|------|----------|--------------|----------|
| S2-01 | Create SpellingQuestion model | 1h | - | P0 |
| S2-02 | Create SpellingState model | 1h | S2-01 | P0 |
| S2-03 | Implement SpellingValidator | 3h | - | P0 |
| S2-04 | Implement SpellingController | 4h | S2-02, S2-03 | P0 |
| S2-05 | Create SpecialCharacterBar widget | 3h | - | P0 |
| S2-06 | Create SpellingInput widget | 3h | S2-05 | P0 |
| S2-07 | Create SpellingBeeScreen | 5h | S2-04, S2-06 | P0 |
| S2-08 | Add spelling bee route + navigation | 1h | S2-07 | P0 |
| S2-09 | Unit tests for SpellingValidator | 3h | S2-03 | P0 |
| S2-10 | Widget tests for SpellingBeeScreen | 2h | S2-07 | P1 |
| S2-11 | Keyboard handling polish | 2h | S2-07 | P1 |

**Sprint 2 Total: ~28 hours**

#### Sprint 3: Listening Challenge + Integration (Week 3-4)

| ID | Task | Estimate | Dependencies | Priority |
|----|------|----------|--------------|----------|
| S3-01 | Create ListeningQuestion model | 1h | - | P0 |
| S3-02 | Create ListeningState model | 1h | S3-01 | P0 |
| S3-03 | Implement ListeningController | 4h | S3-02, Phase 4 | P0 |
| S3-04 | Create AudioPlayButton widget | 2h | Phase 4 | P0 |
| S3-05 | Create ListeningChallengeScreen | 5h | S3-03, S3-04 | P0 |
| S3-06 | Add listening challenge route | 1h | S3-05 | P0 |
| S3-07 | Update MiniGameType enum | 1h | - | P0 |
| S3-08 | Create GameSelectionScreen | 4h | S3-07 | P1 |
| S3-09 | Update GameSessionProvider for new games | 3h | S3-07 | P0 |
| S3-10 | Integration with duel flow | 4h | S3-09 | P0 |
| S3-11 | Integration with solo flow | 3h | S3-09, Phase 2 | P0 |
| S3-12 | Update SRS processing for new games | 2h | Phase 2 | P1 |
| S3-13 | Full integration tests | 4h | All | P1 |
| S3-14 | Documentation update | 2h | All | P2 |

**Sprint 3 Total: ~37 hours**

#### Sprint 4: Buffer + QA (Week 4 - if needed)

| ID | Task | Estimate | Dependencies | Priority |
|----|------|----------|--------------|----------|
| S4-01 | Bug fixes from testing | 8h | All | P0 |
| S4-02 | Performance optimization | 4h | All | P1 |
| S4-03 | Animation polish | 4h | All | P1 |
| S4-04 | Balance testing and adjustments | 4h | All | P1 |
| S4-05 | Accessibility review | 2h | All | P1 |

**Sprint 4 Total: ~22 hours**

### 7.2 Dependency Graph

```
Week 1 (Speed Round):
S1-01 → S1-02 → S1-03 → S1-05 → S1-06 → S1-07
                   ↑
S1-04 ─────────────┘

Week 1-2 (Match Madness):
S1-08 → S1-09 → S1-10 → S1-12 → S1-13
                   ↑
S1-11 ─────────────┘

Week 2-3 (Spelling Bee):
S2-01 → S2-02 ──┬──→ S2-04 → S2-07 → S2-08
                │       ↑
S2-03 ──────────┴───────┘
                        ↑
S2-05 → S2-06 ──────────┘

Week 3-4 (Listening + Integration):
Phase 4 ──┬──→ S3-03 → S3-05 → S3-06
          │       ↑
          └──→ S3-04 ─┘

S3-07 → S3-09 → S3-10
           │
           └──→ S3-11
```

### 7.3 File Structure

```
lib/features/games/
  base/
    mini_game_controller.dart      ← NEW
    mini_game_result.dart          ← NEW
  vocab_flash/
    vocab_flash_screen.dart        (existing)
    vocab_flash_controller.dart    (existing)
  phrase_builder/
    phrase_builder_screen.dart     (existing)
    phrase_builder_controller.dart (existing)
  speed_round/                     ← NEW FOLDER
    speed_round_screen.dart
    speed_round_controller.dart
    speed_round_summary_screen.dart
  match_madness/                   ← NEW FOLDER
    match_madness_screen.dart
    match_madness_controller.dart
  spelling_bee/                    ← NEW FOLDER
    spelling_bee_screen.dart
    spelling_bee_controller.dart
    spelling_validator.dart
  listening/                       ← NEW FOLDER
    listening_screen.dart
    listening_controller.dart

lib/shared/widgets/
  true_false_buttons.dart          ← NEW
  match_tile.dart                  ← NEW
  spelling_input.dart              ← NEW
  special_character_bar.dart       ← NEW
  audio_play_button.dart           ← NEW (or with Phase 4)

lib/features/setup/
  game_selection_screen.dart       ← NEW (optional)
```

---

## 8. Testing Strategy

### 8.1 Unit Tests

#### Speed Round Logic

```dart
// test/speed_round_controller_test.dart

void main() {
  group('SpeedRoundController', () {
    late SpeedRoundController controller;

    setUp(() {
      controller = SpeedRoundController();
    });

    test('generates 10 questions with 50% true/false split', () {
      final items = _createMockItems(20);
      controller.initialize(items, LanguageDirection.greekToCatalan);

      final questions = controller.state.questions;
      expect(questions.length, 10);

      final trueCount = questions.where((q) => q.isCorrect).length;
      expect(trueCount, inInclusiveRange(4, 6)); // Allow some variance
    });

    test('correct answer awards 5 points', () {
      controller.initialize(_createMockItems(20), LanguageDirection.greekToCatalan);
      final correctAnswer = controller.state.currentQuestion.isCorrect;

      final points = controller.submitAnswer(correctAnswer);
      expect(points, 5);
    });

    test('wrong answer awards 0 points', () {
      controller.initialize(_createMockItems(20), LanguageDirection.greekToCatalan);
      final wrongAnswer = !controller.state.currentQuestion.isCorrect;

      final points = controller.submitAnswer(wrongAnswer);
      expect(points, 0);
    });

    test('completes after 10 questions', () {
      controller.initialize(_createMockItems(20), LanguageDirection.greekToCatalan);

      for (int i = 0; i < 10; i++) {
        controller.submitAnswer(true);
        if (i < 9) controller.nextQuestion();
      }

      expect(controller.state.isComplete, true);
    });
  });
}
```

#### Spelling Validator

```dart
// test/spelling_validator_test.dart

void main() {
  group('SpellingValidator', () {
    test('perfect match returns perfect', () {
      final result = SpellingValidator.validate('Bon dia', 'Bon dia');
      expect(result, SpellingResult.perfect);
    });

    test('case insensitive match returns perfect', () {
      final result = SpellingValidator.validate('bon dia', 'Bon dia');
      expect(result, SpellingResult.perfect);
    });

    test('accent error detected', () {
      final result = SpellingValidator.validate('Gracies', 'Gràcies');
      expect(result, SpellingResult.accentError);
    });

    test('minor error with 1 character difference', () {
      final result = SpellingValidator.validate('Bon dua', 'Bon dia');
      expect(result, SpellingResult.minorError);
    });

    test('major error with significant difference', () {
      final result = SpellingValidator.validate('Bona', 'Bon dia');
      expect(result, SpellingResult.majorError);
    });

    test('completely wrong answer', () {
      final result = SpellingValidator.validate('Hello', 'Bon dia');
      expect(result, SpellingResult.wrong);
    });

    test('extra whitespace is normalized', () {
      final result = SpellingValidator.validate('Bon  dia ', 'Bon dia');
      expect(result, SpellingResult.perfect);
    });
  });
}
```

#### Match Madness Logic

```dart
// test/match_madness_controller_test.dart

void main() {
  group('MatchMadnessController', () {
    test('correct match awards 3 points and marks matched', () {
      final controller = MatchMadnessController();
      controller.initialize(_createMockItems(6), LanguageDirection.greekToCatalan);

      final pair = controller.state.pairs.first;
      controller.selectSource(pair.id);
      final points = controller.selectTarget(pair.id);

      expect(points, 3);
      expect(controller.state.pairs.first.isMatched, true);
    });

    test('wrong match awards 0 points and clears selection', () {
      final controller = MatchMadnessController();
      controller.initialize(_createMockItems(6), LanguageDirection.greekToCatalan);

      final pair1 = controller.state.pairs[0];
      final pair2 = controller.state.pairs[1];

      controller.selectSource(pair1.id);
      final points = controller.selectTarget(pair2.id); // Wrong!

      expect(points, 0);
      expect(controller.state.selectedSourceId, isNull);
      expect(controller.state.wrongAttempts, 1);
    });

    test('calculates time bonus when all matched', () {
      final controller = MatchMadnessController();
      // ... simulate matching all 6 pairs

      final score = controller.calculateFinalScore(remainingSeconds: 20);
      // 18 base + 4 time bonus = 22
      expect(score, 22);
    });
  });
}
```

### 8.2 Widget Tests

```dart
// test/speed_round_screen_test.dart

void main() {
  testWidgets('displays question with true/false buttons', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Mock providers
        ],
        child: MaterialApp(home: SpeedRoundScreen()),
      ),
    );

    expect(find.text('TRUE'), findsOneWidget);
    expect(find.text('FALSE'), findsOneWidget);
    expect(find.byType(TimerBar), findsOneWidget);
  });

  testWidgets('tapping TRUE submits answer', (tester) async {
    // ... test interaction
  });
}
```

### 8.3 Integration Tests

```dart
// integration_test/mini_games_test.dart

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('complete speed round in duel', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Navigate through setup
    await _setupDuel(tester);

    // Select Speed Round (if selection enabled)
    // Play through 10 questions
    for (int i = 0; i < 10; i++) {
      await tester.tap(find.text('TRUE'));
      await tester.pumpAndSettle();
    }

    // Verify summary screen
    expect(find.text('SPEED ROUND COMPLETE'), findsOneWidget);
  });

  testWidgets('match madness completes on all matches', (tester) async {
    // ... test match madness flow
  });

  testWidgets('spelling bee accepts correct answer', (tester) async {
    // ... test spelling input
  });
}
```

### 8.4 Manual QA Checklist

**Speed Round:**
- [ ] 10 questions appear
- [ ] Timer counts down from 5 seconds
- [ ] TRUE button works
- [ ] FALSE button works
- [ ] Timeout advances to next question
- [ ] Score updates correctly
- [ ] Summary shows all answers
- [ ] 50% true/false distribution (roughly)

**Match Madness:**
- [ ] 6 pairs displayed
- [ ] Tap source → highlights
- [ ] Tap correct target → both disappear
- [ ] Tap wrong target → shake animation
- [ ] Timer counts down from 45 seconds
- [ ] Score shows per match (+3)
- [ ] Time bonus calculated correctly
- [ ] Partial completion scored correctly

**Spelling Bee:**
- [ ] Source word displayed
- [ ] Text input focuses automatically
- [ ] Special characters bar appears
- [ ] Special character tap inserts character
- [ ] Submit button works
- [ ] Enter key submits
- [ ] Timer counts down from 20 seconds
- [ ] Perfect answer → 15 points
- [ ] Accent error → 12 points
- [ ] Minor error → 8 points
- [ ] Feedback shows correct spelling

**Listening Challenge:**
- [ ] Audio plays automatically
- [ ] Replay button works
- [ ] Replay deducts points
- [ ] Timer starts after audio
- [ ] Options display correctly
- [ ] Selection works as Vocab Flash
- [ ] Fallback when TTS unavailable

**Integration:**
- [ ] All games work in duel mode
- [ ] All games work in solo mode
- [ ] Turn transitions work correctly
- [ ] Scores aggregate correctly
- [ ] SRS updates (if Phase 2 complete)

---

## Appendix A: Scoring Comparison

| Game | Questions | Time | Max Score | Avg Expected |
|------|-----------|------|-----------|--------------|
| Vocab Flash | 5 | 10s each | 75 | 50-60 |
| Phrase Builder | 3 | 30s each | 75 | 45-55 |
| Speed Round | 10 | 5s each | 50 | 35-45 |
| Match Madness | 6 pairs | 45s total | ~27 | 18-22 |
| Listening Challenge | 5 | 10s each | 75 | 45-55 |
| Spelling Bee | 5 | 20s each | 100 | 50-65 |

**Balance Notes:**
- Speed Round is lower scoring but faster
- Spelling Bee has highest ceiling but hardest
- Match Madness is quick and moderate scoring
- Listening Challenge similar to Vocab Flash

---

## Appendix B: Animation Specifications

| Animation | Duration | Easing | Description |
|-----------|----------|--------|-------------|
| Question transition (Speed) | 150ms | easeOut | Instant feel |
| Match correct | 300ms | easeInOut | Scale down + fade |
| Match wrong | 300ms | easeInOut | Horizontal shake |
| Tile selection | 200ms | easeOut | Elevation + color |
| Timer warning | 500ms | linear | Pulse/color change |
| Score popup | 400ms | bounceOut | Scale up + fade |

---

*This plan is ready for implementation. Recommend starting with Speed Round as it's the simplest new game.*
