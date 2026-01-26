# Language Duel MVP - Flutter Engineering Specification

**Version:** 2.0
**Last Updated:** 2026-01-27
**Document Owner:** Flutter Engineering Agent
**Project:** Language Duel - Competitive Language Learning Game
**Mode:** Single-phone hot-seat (two players share one device)
**Tech Stack:** Flutter 3.10+, Riverpod, go_router, Hive

---

## Table of Contents

1. [Folder Structure & Module Organization](#1-folder-structure--module-organization)
2. [Dependencies](#2-dependencies)
3. [Data Models](#3-data-models)
4. [Riverpod Provider Architecture](#4-riverpod-provider-architecture)
5. [Repository Layer](#5-repository-layer)
6. [Screen Widget Specs & Navigation Flow](#6-screen-widget-specs--navigation-flow)
7. [Widget Component Library](#7-widget-component-library)
8. [Animation Patterns](#8-animation-patterns)
9. [Sound Service](#9-sound-service)
10. [Platform-Specific Considerations](#10-platform-specific-considerations)

---

## 1. Folder Structure & Module Organization

```
lib/
  main.dart                     # App entry point, Hive init, orientation lock
  app/
    app.dart                    # MaterialApp.router with theme binding
    theme.dart                  # Light/dark theme definitions (Material 3)
    routes.dart                 # go_router configuration with all routes
  data/
    models/
      content_item.dart         # ContentItem, LanguageEntry, ContentWord
      deck.dart                 # Deck, DeckInfo, LocalizedString
      match_record.dart         # MatchRecord for history persistence
      player.dart               # Player model with LanguageDirection enum
      settings_state.dart       # SettingsState (theme, sound, timers)
    providers/
      content_provider.dart     # Deck loading and selection providers
      game_session_provider.dart # Full game session state management
      history_provider.dart     # Match history state
      session_storage_provider.dart # Session persistence provider
      settings_provider.dart    # App settings state
      setup_provider.dart       # Player setup state (names, directions)
      sound_provider.dart       # Sound service provider
    repositories/
      content_repository.dart   # Deck loading from JSON assets
      history_storage.dart      # Hive-based match history storage
      interfaces.dart           # Repository interfaces (IContentRepository, etc.)
      session_storage.dart      # Hive-based session persistence
      settings_storage.dart     # Hive-based settings persistence
    hive_adapters.dart          # TypeAdapters for SettingsState, MatchRecord
  features/
    home/
      home_screen.dart          # Main menu with resume, new duel, history, settings
    setup/
      player_setup_screen.dart  # Player names and language direction setup
      deck_select_screen.dart   # Deck selection with locked deck previews
    duel/
      duel_hub_screen.dart      # Round info, scores, next mini-game CTA
      turn_transition_screen.dart # Privacy screen between player turns
    games/
      vocab_flash/
        vocab_flash_screen.dart     # Vocab Flash mini-game UI
        vocab_flash_controller.dart # VocabFlashState + VocabFlashController
      phrase_builder/
        phrase_builder_screen.dart     # Phrase Builder mini-game UI
        phrase_builder_controller.dart # PhraseBuilderState + PhraseBuilderController
    results/
      results_screen.dart       # Final scores, winner/tie, score breakdown
    history/
      history_screen.dart       # Match history list
    settings/
      settings_screen.dart      # Theme, sound, timer settings
  shared/
    widgets/
      answer_feedback.dart      # Feedback display (correct/incorrect/neutral)
      async_state.dart          # LoadingState, ErrorState widgets
      duel_button.dart          # Primary CTA button with sound
      flash_card.dart           # Source word display with romanization
      option_tile.dart          # MCQ option button
      score_board.dart          # Two-player score display
      submit_bar.dart           # Submit + hint actions
      timer_bar.dart            # Animated countdown bar
      word_tile.dart            # Reorderable word tile
    animations/
      duel_animations.dart      # Reusable animation utilities
    services/
      sound_service.dart        # System sound playback
```

### Module Principles

- **Feature-first organization**: Each feature folder contains screens and their associated controllers
- **Shared widgets**: Only truly reusable UI components live in `shared/widgets/`
- **Game logic separation**: All game logic resides in controllers/providers, not in widgets
- **Repository pattern**: Data access is abstracted behind interfaces for testability
- **Provider-based DI**: All dependencies injected via Riverpod providers

---

## 2. Dependencies

### Production Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  equatable: ^2.0.5      # Value equality for models (immutable state)
  flutter_riverpod: ^2.4.0  # State management and dependency injection
  go_router: ^14.0.0     # Declarative routing with deep linking support
  hive: ^2.2.3           # Fast, lightweight NoSQL database
  hive_flutter: ^1.1.0   # Flutter integration for Hive
  cupertino_icons: ^1.0.8  # iOS-style icons
```

### Development Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  flutter_launcher_icons: ^0.13.1  # App icon generation
  flutter_lints: ^6.0.0  # Lint rules for code quality
```

### Dependency Rationale

| Package | Purpose |
|---------|---------|
| `equatable` | Enables value equality for all model classes, essential for proper state comparison in Riverpod |
| `flutter_riverpod` | Provides compile-time safe, testable state management with excellent Flutter integration |
| `go_router` | Declarative routing with support for deep linking, redirects, and route guards |
| `hive` / `hive_flutter` | Lightweight key-value database for offline-first persistence without SQL complexity |

---

## 3. Data Models

### Player

```dart
// lib/data/models/player.dart
enum LanguageDirection { greekToCatalan, catalanToGreek }

class Player extends Equatable {
  final String name;
  final LanguageDirection direction;

  String get sourceCode => direction == LanguageDirection.greekToCatalan ? 'el' : 'ca';
  String get targetCode => direction == LanguageDirection.greekToCatalan ? 'ca' : 'el';
}
```

### ContentItem

```dart
// lib/data/models/content_item.dart
class LanguageEntry extends Equatable {
  final String text;
  final String? romanization;  // For Greek text
  final String? phonetic;
}

class ContentWord extends Equatable {
  final String greek;
  final String catalan;
}

class ContentItem extends Equatable {
  final String id;
  final String type;       // 'word' or 'phrase'
  final String category;
  final int difficulty;
  final LanguageEntry greek;
  final LanguageEntry catalan;
  final List<ContentWord> words;  // Word breakdown for phrases

  bool get isPhrase => type == 'phrase';
}
```

### Deck

```dart
// lib/data/models/deck.dart
class LocalizedString extends Equatable {
  final String? en;
  final String? el;
  final String? ca;
  String get defaultText => en ?? el ?? ca ?? '';
}

class DeckInfo extends Equatable {
  final String id;
  final LocalizedString name;
  final LocalizedString description;
  final String level;      // 'A1', 'A2', etc.
  final int itemCount;
}

class Deck extends Equatable {
  final DeckInfo info;
  final List<ContentItem> items;

  List<ContentItem> get vocabularyItems => items.where((i) => !i.isPhrase).toList();
  List<ContentItem> get phraseItems => items.where((i) => i.isPhrase).toList();
}
```

### SettingsState

```dart
// lib/data/models/settings_state.dart
class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final bool soundEnabled;
  final bool timersEnabled;

  static const defaults = SettingsState(
    themeMode: ThemeMode.system,
    soundEnabled: true,
    timersEnabled: true,
  );
}
```

### MatchRecord

```dart
// lib/data/models/match_record.dart
class MatchRecord extends Equatable {
  final String id;
  final String playerOneName;
  final String playerTwoName;
  final int playerOneScore;
  final int playerTwoScore;
  final DateTime playedAt;
}
```

---

## 4. Riverpod Provider Architecture

### Provider Hierarchy

```
App-Level Providers (singleton lifetime)
├── settingsProvider          - App settings (theme, sound, timers)
├── settingsStorageProvider   - Settings persistence
├── contentRepositoryProvider - Deck loading interface
├── soundProvider             - Sound playback service
└── goRouterProvider          - Navigation router

Session-Level Providers (duel lifetime)
├── gameSessionProvider       - Full duel state (scores, players, progress)
├── sessionStorageProvider    - Session persistence
├── savedSessionProvider      - Async session restoration
└── historyProvider           - Match history list

Setup Providers (setup flow lifetime)
├── playerOneNameProvider     - Player 1 name input
├── playerTwoNameProvider     - Player 2 name input
├── playerOneDirectionProvider - Player 1 learning direction
├── playerTwoDirectionProvider - Player 2 learning direction
└── selectedDeckProvider      - Currently selected deck ID

Content Providers (deck lifetime)
├── deckListProvider          - All available decks (async)
└── deckProvider              - Currently loaded deck (async)

Mini-Game Providers (round lifetime)
├── vocabFlashControllerProvider  - Vocab Flash round state
└── phraseBuilderControllerProvider - Phrase Builder round state
```

### Key Provider Definitions

#### gameSessionProvider

```dart
// lib/data/providers/game_session_provider.dart

enum GameType { vocab, phrase }
enum SessionStatus { notStarted, inProgress, completed }

class GameSessionState {
  final String playerOneName, playerTwoName;
  final LanguageDirection playerOneDirection, playerTwoDirection;
  final int playerOneScore, playerTwoScore;
  final int vocabPlayerOneScore, vocabPlayerTwoScore;
  final int phrasePlayerOneScore, phrasePlayerTwoScore;
  final GameType currentGame;
  final int currentPlayer;  // 1 or 2
  final List<String> vocabPlayerOneIds, vocabPlayerTwoIds;
  final List<String> phrasePlayerOneIds, phrasePlayerTwoIds;
  final int vocabPlayerOneIndex, vocabPlayerTwoIndex;
  final int phrasePlayerOneIndex, phrasePlayerTwoIndex;
  final bool vocabPlayerOneDone, vocabPlayerTwoDone;
  final bool phrasePlayerOneDone, phrasePlayerTwoDone;
  final SessionStatus status;

  bool get vocabComplete => vocabPlayerOneDone && vocabPlayerTwoDone;
  bool get phraseComplete => phrasePlayerOneDone && phrasePlayerTwoDone;
}

class GameSessionController extends StateNotifier<GameSessionState> {
  void startSession({...});      // Initialize new duel
  void addScore({player, points});  // Add points to player
  void completeVocabForPlayer(player);  // Mark vocab done
  void completePhraseForPlayer(player); // Mark phrase done
  void setVocabIndex({player, index});  // Track question progress
  void setPhraseIndex({player, index}); // Track phrase progress
  void restoreSession(GameSessionState); // Resume saved session
  void reset();                  // Clear session
}

final gameSessionProvider = StateNotifierProvider<GameSessionController, GameSessionState>(...);
```

#### contentProvider

```dart
// lib/data/providers/content_provider.dart

final contentRepositoryProvider = Provider<IContentRepository>(...);
final selectedDeckProvider = StateProvider<String>((ref) => 'greetings');
final deckListProvider = FutureProvider<List<DeckInfo>>(...);
final deckProvider = FutureProvider<Deck>(...);  // Watches selectedDeckProvider
```

#### settingsProvider

```dart
// lib/data/providers/settings_provider.dart

class SettingsController extends StateNotifier<SettingsState> {
  Future<void> setThemeMode(ThemeMode mode);
  Future<void> setSoundEnabled(bool enabled);
  Future<void> setTimersEnabled(bool enabled);
}

final settingsProvider = StateNotifierProvider<SettingsController, SettingsState>(...);
```

#### vocabFlashControllerProvider

```dart
// lib/features/games/vocab_flash/vocab_flash_controller.dart

class VocabFlashState {
  final int questionIndex;
  final bool isAnswered;
  final AnswerFeedbackState feedbackState;
  final String feedbackMessage;
  final bool isComplete;
}

class VocabFlashController extends StateNotifier<VocabFlashState> {
  void nextQuestion();
  void setQuestionIndex(int index);
  void setAnswered(bool value);
  void setFeedback(AnswerFeedbackState state, String message);
  void reset();
}
```

#### phraseBuilderControllerProvider

```dart
// lib/features/games/phrase_builder/phrase_builder_controller.dart

class PhraseBuilderState {
  final int phraseIndex;
  final bool isSubmitted;
  final AnswerFeedbackState feedbackState;
  final String feedbackMessage;
  final bool hintUsed;
  final bool isComplete;
}

class PhraseBuilderController extends StateNotifier<PhraseBuilderState> {
  void nextPhrase();
  void setPhraseIndex(int index);
  void setSubmitted(bool value);
  void setFeedback(AnswerFeedbackState state, String message);
  void setHintUsed(bool value);
  void reset();
}
```

### State Flow Diagram

```
User Input -> Provider Action -> State Update -> UI Rebuild

Example: Answer Selection in Vocab Flash
1. User taps OptionTile
2. VocabFlashScreen._selectOption() called
3. VocabFlashController.setAnswered(true) updates state
4. VocabFlashController.setFeedback(...) updates feedback
5. GameSessionController.addScore(...) updates session
6. UI rebuilds showing feedback
7. Timer advances to next question or transitions
```

---

## 5. Repository Layer

### Interfaces

```dart
// lib/data/repositories/interfaces.dart

abstract class IContentRepository {
  Future<Deck> loadDeck(String deckId);
  Future<List<DeckInfo>> listDecks();
}

abstract class ISettingsRepository {
  SettingsState load();
  Future<void> save(SettingsState settings);
}

abstract class IHistoryRepository {
  Future<void> add(MatchRecord record);
  List<MatchRecord> getAll();
  Future<void> clear();
}
```

### ContentRepository

```dart
// lib/data/repositories/content_repository.dart

class ContentRepository implements IContentRepository {
  static const Map<String, String> _deckAssets = {
    'greetings': 'assets/data/greetings_deck.json',
    'numbers': 'assets/data/numbers_deck.json',
    'colors': 'assets/data/colors_deck.json',
    'family': 'assets/data/family_deck.json',
    'travel_basics_a1': 'assets/data/travel_basics_a1_deck.json',
    'travel_interactions_a2': 'assets/data/travel_instructions_a2_deck.json',
    'house_cleaning_a2': 'assets/data/house_cleaning_a2_deck.json',
  };

  // Loads from assets with Hive caching
  @override
  Future<Deck> loadDeck(String deckId) async {...}

  @override
  Future<List<DeckInfo>> listDecks() async {...}
}
```

### Hive Adapters

```dart
// lib/data/hive_adapters.dart

class SettingsStateAdapter extends TypeAdapter<SettingsState> {
  @override final int typeId = 1;
  // Binary serialization for SettingsState
}

class MatchRecordAdapter extends TypeAdapter<MatchRecord> {
  @override final int typeId = 2;
  // Binary serialization for MatchRecord
}
```

### Initialization

```dart
// lib/main.dart

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Hive.initFlutter();

  // Register adapters only if not already registered
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(SettingsStateAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(MatchRecordAdapter());
  }

  // Open boxes before app starts
  await Hive.openBox<dynamic>('session');
  await Hive.openBox<dynamic>('settings');
  await Hive.openBox<dynamic>('history');

  runApp(const ProviderScope(child: App()));
}
```

---

## 6. Screen Widget Specs & Navigation Flow

### Route Configuration

```dart
// lib/app/routes.dart

const String homeRoute = '/';
const String setupRoute = '/setup';
const String deckRoute = '/deck';
const String duelRoute = '/duel';
const String vocabRoute = '/vocab';
const String phraseRoute = '/phrase';
const String transitionRoute = '/transition';
const String resultsRoute = '/results';
const String historyRoute = '/history';
const String settingsRoute = '/settings';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: homeRoute,
    routes: [...],
    errorBuilder: (context, state) => Scaffold(...),
  );
});
```

### Navigation Flow

```
HomeScreen (/)
    ├── [Start New Duel] -> PlayerSetupScreen (/setup)
    │                           └── [Continue] -> DeckSelectScreen (/deck)
    │                                                 └── [Start Duel] -> DuelHubScreen (/duel)
    │
    ├── [Resume Duel] -> VocabFlashScreen or PhraseBuilderScreen or DuelHubScreen
    │
    ├── [Match History] -> HistoryScreen (/history)
    │
    └── [Settings] -> SettingsScreen (/settings)

DuelHubScreen (/duel)
    └── [Start Game] -> VocabFlashScreen (/vocab) or PhraseBuilderScreen (/phrase)

VocabFlashScreen (/vocab)
    ├── [Complete Turn] -> TurnTransitionScreen (/transition)
    │                           └── [I'm Ready] -> DuelHubScreen (/duel)
    └── [Both Complete] -> DuelHubScreen (/duel)

PhraseBuilderScreen (/phrase)
    ├── [Complete Turn] -> TurnTransitionScreen (/transition)
    │                           └── [I'm Ready] -> DuelHubScreen (/duel)
    └── [Both Complete] -> ResultsScreen (/results)

ResultsScreen (/results)
    ├── [Play Again] -> DeckSelectScreen (/deck)
    └── [Back to Home] -> HomeScreen (/)
```

### Screen Specifications

#### HomeScreen

**Route:** `/`
**Providers:** `savedSessionProvider`, `gameSessionProvider`, `historyProvider`
**Purpose:** Main menu with game entry points

| Element | Behavior |
|---------|----------|
| App Logo | Displays Language Duel branding |
| Resume Duel | Appears if saved session exists; restores session and navigates to appropriate screen |
| Start New Duel | Navigates to PlayerSetupScreen |
| Match History | Navigates to HistoryScreen |
| Settings | Navigates to SettingsScreen |
| How to Play | Shows dialog explaining gameplay |

#### PlayerSetupScreen

**Route:** `/setup`
**Providers:** `playerOneNameProvider`, `playerTwoNameProvider`, `playerOneDirectionProvider`, `playerTwoDirectionProvider`
**Purpose:** Configure player names and learning directions

| Element | Behavior |
|---------|----------|
| Player 1 Card | Name input (max 20 chars) + language dropdown |
| Player 2 Card | Name input (max 20 chars) + language dropdown |
| Continue Button | Validates names non-empty, non-duplicate; navigates to DeckSelectScreen |

**Validation:**
- Names must be non-empty
- Names must be 20 characters or less
- Player names must be different
- Language directions are mutually exclusive (if P1 learns Catalan, P2 learns Greek)

#### DeckSelectScreen

**Route:** `/deck`
**Providers:** `deckListProvider`, `selectedDeckProvider`, `deckProvider`, `gameSessionProvider`, setup providers
**Purpose:** Choose content deck for the duel

| Element | Behavior |
|---------|----------|
| Available Decks | ListView of DeckInfo cards with icon, name, level, item count |
| Selection | Tap to select; checkmark indicates current selection |
| Locked Decks | "Coming Soon" section with disabled cards |
| Start Duel | Loads deck, initializes session, navigates to DuelHubScreen |

**Available Decks (7 total):**
- Greetings (A1)
- Numbers (A1)
- Colors (A1)
- Family (A1)
- Travel Basics (A1)
- Travel Instructions (A2)
- House Cleaning (A2)

#### DuelHubScreen

**Route:** `/duel`
**Providers:** `gameSessionProvider`
**Purpose:** Central hub showing scores and next mini-game

| Element | Behavior |
|---------|----------|
| ScoreBoard | Shows both player names and current scores |
| Round Info | "Round 1 of 2" or "Round 2 of 2" |
| Current Player | Shows whose turn is next |
| Next Game Label | "Vocab Flash Duel" or "Phrase Builder" |
| Start Button | Navigates to VocabFlashScreen or PhraseBuilderScreen |

#### VocabFlashScreen

**Route:** `/vocab`
**Providers:** `gameSessionProvider`, `deckProvider`, `vocabFlashControllerProvider`, `settingsProvider`, `soundProvider`
**Purpose:** Multiple-choice vocabulary quiz

| Element | Behavior |
|---------|----------|
| ScoreBoard | Real-time score display |
| TimerBar | 10-second countdown (if timers enabled) |
| FlashCard | Source word with romanization/phonetic |
| OptionTiles | 4 MCQ options; one correct |
| AnswerFeedback | Shows result after answer |
| Pause Overlay | Appears when app backgrounded |

**Game Logic:**
- 5 questions per player
- 10 seconds per question (configurable)
- Base score: 10 points per correct answer
- Speed bonus: +5 (8+ sec), +3 (5-7 sec), +1 (3-4 sec)
- Smart distractor selection based on category, difficulty, confusion pairs

#### PhraseBuilderScreen

**Route:** `/phrase`
**Providers:** `gameSessionProvider`, `deckProvider`, `phraseBuilderControllerProvider`, `settingsProvider`, `soundProvider`
**Purpose:** Word reordering puzzle

| Element | Behavior |
|---------|----------|
| ScoreBoard | Real-time score display |
| TimerBar | 30-second countdown (if timers enabled) |
| Source Phrase | Target language phrase to translate |
| WordTiles | ReorderableListView of scrambled words |
| AnswerFeedback | Shows result after submission |
| SubmitBar | Hint button + Submit button |
| Pause Overlay | Appears when app backgrounded |

**Game Logic:**
- 3 phrases per player
- 30 seconds per phrase (configurable)
- Partial scoring: (20 * correct_positions / total_words)
- Time bonus: +5 (20+ sec), +2 (10-19 sec) for perfect answers
- Hint cost: -3 points (locks first word in place)

#### TurnTransitionScreen

**Route:** `/transition`
**Providers:** `gameSessionProvider`
**Purpose:** Privacy screen between player turns

| Element | Behavior |
|---------|----------|
| Background Color | Blue (Player 1) or Orange (Player 2) |
| Pass Message | "Pass the phone to [PlayerName]" |
| Handoff Icon | Animated horizontal swap icon |
| Ready Button | Starts 3-second countdown, then navigates to DuelHubScreen |

#### ResultsScreen

**Route:** `/results`
**Providers:** `gameSessionProvider`, `historyProvider`
**Purpose:** Final scores and game summary

| Element | Behavior |
|---------|----------|
| Result Banner | "Winner: [Name]" or "It's a tie!" |
| Score Comparison | Side-by-side final scores |
| Breakdown | Per-game scores (Vocab Flash, Phrase Builder) |
| Play Again | Resets session, navigates to DeckSelectScreen |
| Clear History | Clears all match records |
| Back to Home | Navigates to HomeScreen |

#### HistoryScreen

**Route:** `/history`
**Providers:** `historyProvider`
**Purpose:** View past match results

| Element | Behavior |
|---------|----------|
| Empty State | "No matches yet" message |
| Match Cards | Timestamp, player scores, winner/tie result |

#### SettingsScreen

**Route:** `/settings`
**Providers:** `settingsProvider`
**Purpose:** Configure app preferences

| Element | Behavior |
|---------|----------|
| Theme Selector | System / Light / Dark segmented button |
| Sound Toggle | Enable/disable sound effects |
| Timers Toggle | Enable/disable countdown timers and speed bonuses |

---

## 7. Widget Component Library

### ScoreBoard

**File:** `lib/shared/widgets/score_board.dart`
**Purpose:** Displays both players' scores during gameplay

```dart
const ScoreBoard({
  required String playerOne,
  required String playerTwo,
  int playerOneScore = 0,
  int playerTwoScore = 0,
});
```

**Features:**
- Animated score changes (scale transition)
- Respects `MediaQuery.disableAnimations`
- Semantic labels for accessibility

### TimerBar

**File:** `lib/shared/widgets/timer_bar.dart`
**Purpose:** Visual countdown with urgency feedback

```dart
const TimerBar({
  required int totalSeconds,
  required int remainingSeconds,
  int warningThreshold = 3,
  int criticalThreshold = 1,
});
```

**Features:**
- Color changes: Green -> Orange (warning) -> Red (critical)
- Pulse animation at warning/critical thresholds
- Respects reduced motion preferences
- Semantic labels for screen readers

### DuelButton

**File:** `lib/shared/widgets/duel_button.dart`
**Purpose:** Primary call-to-action button

```dart
const DuelButton({
  required String label,
  VoidCallback? onPressed,
});
```

**Features:**
- Full-width elevated button
- Plays tap sound when pressed (if sound enabled)
- Disabled state when `onPressed` is null

### FlashCard

**File:** `lib/shared/widgets/flash_card.dart`
**Purpose:** Displays source word/phrase with pronunciation aids

```dart
const FlashCard({
  required String text,
  String? romanization,
  String? phonetic,
});
```

**Features:**
- Large, prominent text display
- Optional romanization/phonetic subtitle
- Semantic labeling for accessibility

### OptionTile

**File:** `lib/shared/widgets/option_tile.dart`
**Purpose:** Multiple-choice answer option

```dart
const OptionTile({
  required String label,
  VoidCallback? onPressed,
});
```

**Features:**
- Outlined button style
- Left-aligned text
- Plays tap sound when pressed
- Disabled state support

### WordTile

**File:** `lib/shared/widgets/word_tile.dart`
**Purpose:** Draggable word tile for phrase reordering

```dart
const WordTile({
  required String text,
  bool locked = false,
  Widget? dragHandle,
});
```

**Features:**
- Card with ListTile layout
- Lock icon when hint used (first word)
- Drag handle for reordering
- Semantic labels

### AnswerFeedback

**File:** `lib/shared/widgets/answer_feedback.dart`
**Purpose:** Shows answer correctness and feedback message

```dart
enum AnswerFeedbackState { neutral, correct, incorrect }

const AnswerFeedback({
  required String message,
  required AnswerFeedbackState state,
});
```

**Features:**
- Animated background color changes
- State-specific icons (info, check, cancel)
- Animated text transitions

### SubmitBar

**File:** `lib/shared/widgets/submit_bar.dart`
**Purpose:** Hint and submit actions for Phrase Builder

```dart
const SubmitBar({
  required bool hintEnabled,
  required VoidCallback? onHint,
  required bool submitEnabled,
  required VoidCallback? onSubmit,
});
```

**Features:**
- Hint button with point cost label
- Full-width submit button
- Sound effects on press

### LoadingState / ErrorState

**File:** `lib/shared/widgets/async_state.dart`
**Purpose:** Standard loading and error UI

```dart
const LoadingState({String message = 'Loading...'});

const ErrorState({
  String title = 'Something went wrong',
  required String message,
  String actionLabel = 'Try again',
  VoidCallback? onRetry,
});
```

---

## 8. Animation Patterns

### DuelAnimations

**File:** `lib/shared/animations/duel_animations.dart`

```dart
class DuelAnimations {
  static Widget fadeScale(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.96, end: 1.0).animate(animation),
        child: child,
      ),
    );
  }
}
```

**Usage:** Used with `AnimatedSwitcher.transitionBuilder` for smooth content transitions

### Page Transitions

Configured in `theme.dart`:

```dart
pageTransitionsTheme: const PageTransitionsTheme(
  builders: {
    TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
  },
),
```

### Animation Guidelines

| Context | Animation | Duration |
|---------|-----------|----------|
| Page transitions | Platform-native | 300ms |
| Answer feedback | Background color + icon | 250ms |
| Score updates | Scale transition | 300ms |
| Timer warning | Pulse scale | 400ms |
| Turn transition fade | Opacity | 300ms |
| Handoff icon | Horizontal oscillation | 1400ms (looping) |

**Accessibility:** All animations respect `MediaQuery.disableAnimations` for users with motion sensitivity

---

## 9. Sound Service

**File:** `lib/shared/services/sound_service.dart`

```dart
class SoundService {
  const SoundService();

  void playTap(bool enabled) {
    if (!enabled) return;
    SystemSound.play(SystemSoundType.click);
  }

  void playSuccess(bool enabled) {
    if (!enabled) return;
    SystemSound.play(SystemSoundType.alert);
  }

  void playError(bool enabled) {
    if (!enabled) return;
    SystemSound.play(SystemSoundType.alert);
  }
}
```

**Provider:**

```dart
// lib/data/providers/sound_provider.dart
final soundProvider = Provider<SoundService>((ref) => const SoundService());
```

**Note:** Currently uses system sounds. Custom audio files can be added in future iterations.

---

## 10. Platform-Specific Considerations

### Orientation Lock

```dart
// main.dart
await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
```

MVP is locked to portrait mode for optimal hot-seat gameplay.

### Android

- **Material 3 theming** via `useMaterial3: true`
- **Page transitions:** `FadeUpwardsPageTransitionsBuilder`
- **Back button handling:** `PopScope` with confirmation dialogs during gameplay
- **Target SDK:** Configured in `android/app/build.gradle`

### iOS

- **Safe areas:** All screens use `SafeArea` widget
- **Notch/home indicator:** Respected via SafeArea padding
- **Page transitions:** `CupertinoPageTransitionsBuilder`
- **App icon:** Generated via flutter_launcher_icons with `remove_alpha_ios: true`

### Theme Configuration

```dart
// lib/app/theme.dart

class AppTheme {
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1C7C54),  // Brand green
    );
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF7F4EF),  // Warm off-white
      // ...
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1C7C54),
      brightness: Brightness.dark,
    );
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF151513),  // Deep dark
      // ...
    );
  }
}
```

### Accessibility

- **Semantic labels:** All interactive widgets have descriptive labels
- **Text scaling:** UI tested up to 200% text scale
- **Tap targets:** Minimum 48dp touch targets
- **Reduced motion:** Animations respect `MediaQuery.disableAnimations`
- **Color contrast:** Material 3 color scheme provides accessible contrast ratios

### Offline-First

- **No network dependencies:** All content bundled in assets
- **Hive persistence:** Settings, session, and history stored locally
- **Session restoration:** Interrupted games can be resumed from HomeScreen

### Content Decks

Located in `assets/data/`:

| Deck | Level | Description |
|------|-------|-------------|
| greetings_deck.json | A1 | Basic greetings and introductions |
| numbers_deck.json | A1 | Numbers and counting |
| colors_deck.json | A1 | Colors and descriptions |
| family_deck.json | A1 | Family members and relationships |
| travel_basics_a1_deck.json | A1 | Basic travel vocabulary |
| travel_instructions_a2_deck.json | A2 | Travel directions and instructions |
| house_cleaning_a2_deck.json | A2 | Household and cleaning vocabulary |

---

*This document defines the complete Flutter engineering architecture for the Language Duel MVP. All implementation follows these specifications.*
