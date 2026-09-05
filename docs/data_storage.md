# Language Duel MVP - Data Storage & Local Persistence Specification

> **Historical document:** This records the original persistence design and is
> kept for project context. The implementation has since evolved. Treat the
> models, repositories, providers, Hive adapters, and migration service under
> `lib/data/` as the current source of truth.

**Version:** 1.0
**Last Updated:** 2026-01-26
**Document Owner:** Local Storage/Data Agent
**Project:** Language Duel - Competitive Language Learning Game
**Mode:** Single-phone hot-seat (two players share one device)
**Tech Stack:** Flutter with Riverpod, Hive/Isar for local storage
**Languages:** Greek <-> Catalan, A1 beginner level

---

## Table of Contents

1. [Data Models (Dart Classes)](#1-data-models-dart-classes)
2. [Hive/Isar Schema Definitions](#2-hiveisar-schema-definitions)
3. [Content Loading Strategy](#3-content-loading-strategy)
4. [Match History Persistence](#4-match-history-persistence-optional-mvp)
5. [Settings Storage](#5-settings-storage)
6. [Repository Interfaces](#6-repository-interfaces)

---

## 1. Data Models (Dart Classes)

### 1.1 Overview

All data models follow these conventions:
- **Immutability**: All models use `final` fields with `copyWith` methods
- **Serialization**: JSON serialization via `json_serializable` or `freezed`
- **Equality**: Value comparison via `Equatable`
- **Type Safety**: Strong typing with enums for fixed values

### 1.2 Language Model

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'language.g.dart';

/// Represents a supported language in the application.
///
/// Each language has a code (ISO 639-1), display name, and optional
/// script direction information for RTL languages.
@JsonSerializable()
class Language extends Equatable {
  /// ISO 639-1 language code (e.g., 'el' for Greek, 'ca' for Catalan)
  final String code;

  /// Display name in the native language (e.g., 'Ελληνικά', 'Catala')
  final String nativeName;

  /// Display name in English (e.g., 'Greek', 'Catalan')
  final String englishName;

  /// Script direction: 'ltr' (left-to-right) or 'rtl' (right-to-left)
  final ScriptDirection scriptDirection;

  /// Whether this language uses a non-Latin script
  final bool usesNonLatinScript;

  const Language({
    required this.code,
    required this.nativeName,
    required this.englishName,
    this.scriptDirection = ScriptDirection.ltr,
    this.usesNonLatinScript = false,
  });

  /// Predefined Greek language
  static const greek = Language(
    code: 'el',
    nativeName: 'Ελληνικά',
    englishName: 'Greek',
    scriptDirection: ScriptDirection.ltr,
    usesNonLatinScript: true,
  );

  /// Predefined Catalan language
  static const catalan = Language(
    code: 'ca',
    nativeName: 'Catala',
    englishName: 'Catalan',
    scriptDirection: ScriptDirection.ltr,
    usesNonLatinScript: false,
  );

  factory Language.fromJson(Map<String, dynamic> json) =>
      _$LanguageFromJson(json);

  Map<String, dynamic> toJson() => _$LanguageToJson(this);

  Language copyWith({
    String? code,
    String? nativeName,
    String? englishName,
    ScriptDirection? scriptDirection,
    bool? usesNonLatinScript,
  }) {
    return Language(
      code: code ?? this.code,
      nativeName: nativeName ?? this.nativeName,
      englishName: englishName ?? this.englishName,
      scriptDirection: scriptDirection ?? this.scriptDirection,
      usesNonLatinScript: usesNonLatinScript ?? this.usesNonLatinScript,
    );
  }

  @override
  List<Object?> get props => [
        code,
        nativeName,
        englishName,
        scriptDirection,
        usesNonLatinScript,
      ];
}

/// Script direction for text rendering
enum ScriptDirection {
  @JsonValue('ltr')
  ltr,
  @JsonValue('rtl')
  rtl,
}
```

### 1.3 Content Item Models

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'content_item.g.dart';

/// Type of content item in a deck
enum ContentItemType {
  @JsonValue('vocabulary')
  vocabulary,
  @JsonValue('phrase')
  phrase,
}

/// Category for semantic grouping and distractor generation
enum ContentCategory {
  @JsonValue('greeting')
  greeting,
  @JsonValue('greeting_morning')
  greetingMorning,
  @JsonValue('greeting_afternoon')
  greetingAfternoon,
  @JsonValue('greeting_evening')
  greetingEvening,
  @JsonValue('greeting_general')
  greetingGeneral,
  @JsonValue('farewell')
  farewell,
  @JsonValue('pleasantry')
  pleasantry,
  @JsonValue('question')
  question,
  @JsonValue('question_wellbeing')
  questionWellbeing,
  @JsonValue('question_identity')
  questionIdentity,
  @JsonValue('response_positive')
  responsePositive,
  @JsonValue('response_negative')
  responseNegative,
  @JsonValue('politeness')
  politeness,
  @JsonValue('introduction')
  introduction,
}

/// Formality level of an expression
enum FormalityLevel {
  @JsonValue('formal')
  formal,
  @JsonValue('informal')
  informal,
  @JsonValue('neutral')
  neutral,
}

/// Greek language entry with text, romanization, and phonetic guide
@JsonSerializable()
class GreekEntry extends Equatable {
  /// Greek text in Greek script (e.g., 'Καλημέρα')
  final String text;

  /// Romanized Greek (e.g., 'Kalimera')
  final String romanization;

  /// Phonetic pronunciation guide (e.g., 'kah-lee-MEH-rah')
  final String phonetic;

  /// IPA transcription (optional)
  final String? ipa;

  const GreekEntry({
    required this.text,
    required this.romanization,
    required this.phonetic,
    this.ipa,
  });

  factory GreekEntry.fromJson(Map<String, dynamic> json) =>
      _$GreekEntryFromJson(json);

  Map<String, dynamic> toJson() => _$GreekEntryToJson(this);

  GreekEntry copyWith({
    String? text,
    String? romanization,
    String? phonetic,
    String? ipa,
  }) {
    return GreekEntry(
      text: text ?? this.text,
      romanization: romanization ?? this.romanization,
      phonetic: phonetic ?? this.phonetic,
      ipa: ipa ?? this.ipa,
    );
  }

  @override
  List<Object?> get props => [text, romanization, phonetic, ipa];
}

/// Catalan language entry with text and phonetic guide
@JsonSerializable()
class CatalanEntry extends Equatable {
  /// Catalan text
  final String text;

  /// Phonetic pronunciation guide (e.g., 'bon DEE-ah')
  final String phonetic;

  /// IPA transcription (optional)
  final String? ipa;

  const CatalanEntry({
    required this.text,
    required this.phonetic,
    this.ipa,
  });

  factory CatalanEntry.fromJson(Map<String, dynamic> json) =>
      _$CatalanEntryFromJson(json);

  Map<String, dynamic> toJson() => _$CatalanEntryToJson(this);

  CatalanEntry copyWith({
    String? text,
    String? phonetic,
    String? ipa,
  }) {
    return CatalanEntry(
      text: text ?? this.text,
      phonetic: phonetic ?? this.phonetic,
      ipa: ipa ?? this.ipa,
    );
  }

  @override
  List<Object?> get props => [text, phonetic, ipa];
}

/// Word breakdown entry for phrase items
@JsonSerializable()
class WordBreakdown extends Equatable {
  /// Position in the phrase (0-indexed)
  final int position;

  /// Greek word with romanization
  final WordBreakdownGreek greek;

  /// Catalan word
  final WordBreakdownCatalan catalan;

  const WordBreakdown({
    required this.position,
    required this.greek,
    required this.catalan,
  });

  factory WordBreakdown.fromJson(Map<String, dynamic> json) =>
      _$WordBreakdownFromJson(json);

  Map<String, dynamic> toJson() => _$WordBreakdownToJson(this);

  WordBreakdown copyWith({
    int? position,
    WordBreakdownGreek? greek,
    WordBreakdownCatalan? catalan,
  }) {
    return WordBreakdown(
      position: position ?? this.position,
      greek: greek ?? this.greek,
      catalan: catalan ?? this.catalan,
    );
  }

  @override
  List<Object?> get props => [position, greek, catalan];
}

@JsonSerializable()
class WordBreakdownGreek extends Equatable {
  final String word;
  final String? romanization;
  final String? meaning;

  const WordBreakdownGreek({
    required this.word,
    this.romanization,
    this.meaning,
  });

  factory WordBreakdownGreek.fromJson(Map<String, dynamic> json) =>
      _$WordBreakdownGreekFromJson(json);

  Map<String, dynamic> toJson() => _$WordBreakdownGreekToJson(this);

  @override
  List<Object?> get props => [word, romanization, meaning];
}

@JsonSerializable()
class WordBreakdownCatalan extends Equatable {
  final String word;
  final String? meaning;

  const WordBreakdownCatalan({
    required this.word,
    this.meaning,
  });

  factory WordBreakdownCatalan.fromJson(Map<String, dynamic> json) =>
      _$WordBreakdownCatalanFromJson(json);

  Map<String, dynamic> toJson() => _$WordBreakdownCatalanToJson(this);

  @override
  List<Object?> get props => [word, meaning];
}

/// Hints for distractor generation
@JsonSerializable()
class DistractorHints extends Equatable {
  /// IDs of semantically related items for distractors
  final List<String>? semanticSiblings;

  /// IDs of commonly confused items
  final List<String>? confusionPairs;

  /// IDs that should NOT be used as distractors
  final List<String>? exclude;

  const DistractorHints({
    this.semanticSiblings,
    this.confusionPairs,
    this.exclude,
  });

  factory DistractorHints.fromJson(Map<String, dynamic> json) =>
      _$DistractorHintsFromJson(json);

  Map<String, dynamic> toJson() => _$DistractorHintsToJson(this);

  @override
  List<Object?> get props => [semanticSiblings, confusionPairs, exclude];
}

/// A single content item (vocabulary word or phrase) in a deck
@JsonSerializable()
class ContentItem extends Equatable {
  /// Unique identifier within the deck
  final String id;

  /// Item type: vocabulary or phrase
  final ContentItemType type;

  /// Greek language data
  final GreekEntry greek;

  /// Catalan language data
  final CatalanEntry catalan;

  /// Semantic category for distractor grouping
  final ContentCategory category;

  /// Difficulty level: 1 (easy), 2 (medium), 3 (harder)
  final int difficulty;

  /// Additional tags for filtering/grouping
  final List<String>? tags;

  /// Cultural or usage notes
  final String? notes;

  /// Formality level of the expression
  final FormalityLevel? formalityLevel;

  /// Word-by-word breakdown for phrases
  /// Required when type == ContentItemType.phrase
  final List<WordBreakdown>? wordBreakdown;

  /// Simplified word list for phrase builder (greek -> catalan mapping)
  final List<Map<String, String>>? words;

  /// Hints for distractor generation
  final DistractorHints? distractorHints;

  const ContentItem({
    required this.id,
    required this.type,
    required this.greek,
    required this.catalan,
    required this.category,
    required this.difficulty,
    this.tags,
    this.notes,
    this.formalityLevel,
    this.wordBreakdown,
    this.words,
    this.distractorHints,
  });

  /// Check if this item is a phrase (has word breakdown)
  bool get isPhrase => type == ContentItemType.phrase;

  /// Check if this item is vocabulary
  bool get isVocabulary => type == ContentItemType.vocabulary;

  /// Get the word count for phrases
  int get wordCount => words?.length ?? wordBreakdown?.length ?? 1;

  factory ContentItem.fromJson(Map<String, dynamic> json) =>
      _$ContentItemFromJson(json);

  Map<String, dynamic> toJson() => _$ContentItemToJson(this);

  ContentItem copyWith({
    String? id,
    ContentItemType? type,
    GreekEntry? greek,
    CatalanEntry? catalan,
    ContentCategory? category,
    int? difficulty,
    List<String>? tags,
    String? notes,
    FormalityLevel? formalityLevel,
    List<WordBreakdown>? wordBreakdown,
    List<Map<String, String>>? words,
    DistractorHints? distractorHints,
  }) {
    return ContentItem(
      id: id ?? this.id,
      type: type ?? this.type,
      greek: greek ?? this.greek,
      catalan: catalan ?? this.catalan,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      formalityLevel: formalityLevel ?? this.formalityLevel,
      wordBreakdown: wordBreakdown ?? this.wordBreakdown,
      words: words ?? this.words,
      distractorHints: distractorHints ?? this.distractorHints,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        greek,
        catalan,
        category,
        difficulty,
        tags,
        notes,
        formalityLevel,
        wordBreakdown,
        words,
        distractorHints,
      ];
}
```

### 1.4 Deck Model

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'deck.g.dart';

/// CEFR language proficiency levels
enum CEFRLevel {
  @JsonValue('A1')
  a1,
  @JsonValue('A2')
  a2,
  @JsonValue('B1')
  b1,
  @JsonValue('B2')
  b2,
  @JsonValue('C1')
  c1,
  @JsonValue('C2')
  c2,
}

/// Localized string with translations in multiple languages
@JsonSerializable()
class LocalizedString extends Equatable {
  final String? en;
  final String? el;
  final String? ca;

  const LocalizedString({
    this.en,
    this.el,
    this.ca,
  });

  /// Get the string in the specified language, with fallback to English
  String getForLanguage(String languageCode) {
    switch (languageCode) {
      case 'el':
        return el ?? en ?? '';
      case 'ca':
        return ca ?? en ?? '';
      default:
        return en ?? '';
    }
  }

  factory LocalizedString.fromJson(Map<String, dynamic> json) =>
      _$LocalizedStringFromJson(json);

  Map<String, dynamic> toJson() => _$LocalizedStringToJson(this);

  @override
  List<Object?> get props => [en, el, ca];
}

/// Language pair definition
@JsonSerializable()
class LanguagePair extends Equatable {
  /// Source language ISO 639-1 code
  final String source;

  /// Target language ISO 639-1 code
  final String target;

  const LanguagePair({
    required this.source,
    required this.target,
  });

  /// Reverse the language pair
  LanguagePair get reversed => LanguagePair(source: target, target: source);

  factory LanguagePair.fromJson(Map<String, dynamic> json) =>
      _$LanguagePairFromJson(json);

  Map<String, dynamic> toJson() => _$LanguagePairToJson(this);

  @override
  List<Object?> get props => [source, target];
}

/// Deck metadata
@JsonSerializable()
class DeckMetadata extends Equatable {
  final String? author;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String>? tags;

  const DeckMetadata({
    this.author,
    this.createdAt,
    this.updatedAt,
    this.tags,
  });

  factory DeckMetadata.fromJson(Map<String, dynamic> json) =>
      _$DeckMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$DeckMetadataToJson(this);

  @override
  List<Object?> get props => [author, createdAt, updatedAt, tags];
}

/// Deck info (without items) for listing purposes
@JsonSerializable()
class DeckInfo extends Equatable {
  final String id;
  final LocalizedString name;
  final LocalizedString? description;
  final CEFRLevel level;
  final int itemCount;

  const DeckInfo({
    required this.id,
    required this.name,
    this.description,
    required this.level,
    required this.itemCount,
  });

  factory DeckInfo.fromJson(Map<String, dynamic> json) =>
      _$DeckInfoFromJson(json);

  Map<String, dynamic> toJson() => _$DeckInfoToJson(this);

  @override
  List<Object?> get props => [id, name, description, level, itemCount];
}

/// A complete deck containing vocabulary and phrases
@JsonSerializable()
class Deck extends Equatable {
  /// Unique identifier for the deck
  final String id;

  /// Human-readable deck name in multiple languages
  final LocalizedString name;

  /// Brief description of the deck content
  final LocalizedString? description;

  /// CEFR level of the content
  final CEFRLevel level;

  /// Total number of items in the deck
  final int itemCount;

  /// Semantic version of the deck content
  final String? version;

  /// Source and target language codes
  final LanguagePair? languagePair;

  /// All content items in the deck
  final List<ContentItem> items;

  /// Optional metadata
  final DeckMetadata? metadata;

  const Deck({
    required this.id,
    required this.name,
    this.description,
    required this.level,
    required this.itemCount,
    this.version,
    this.languagePair,
    required this.items,
    this.metadata,
  });

  /// Get only vocabulary items
  List<ContentItem> get vocabularyItems =>
      items.where((item) => item.isVocabulary).toList();

  /// Get only phrase items
  List<ContentItem> get phraseItems =>
      items.where((item) => item.isPhrase).toList();

  /// Get items by difficulty level
  List<ContentItem> getItemsByDifficulty(int difficulty) =>
      items.where((item) => item.difficulty == difficulty).toList();

  /// Get items by category
  List<ContentItem> getItemsByCategory(ContentCategory category) =>
      items.where((item) => item.category == category).toList();

  /// Get deck info (without items) for listing
  DeckInfo get info => DeckInfo(
        id: id,
        name: name,
        description: description,
        level: level,
        itemCount: itemCount,
      );

  factory Deck.fromJson(Map<String, dynamic> json) => _$DeckFromJson(json);

  Map<String, dynamic> toJson() => _$DeckToJson(this);

  Deck copyWith({
    String? id,
    LocalizedString? name,
    LocalizedString? description,
    CEFRLevel? level,
    int? itemCount,
    String? version,
    LanguagePair? languagePair,
    List<ContentItem>? items,
    DeckMetadata? metadata,
  }) {
    return Deck(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      level: level ?? this.level,
      itemCount: itemCount ?? this.itemCount,
      version: version ?? this.version,
      languagePair: languagePair ?? this.languagePair,
      items: items ?? this.items,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        level,
        itemCount,
        version,
        languagePair,
        items,
        metadata,
      ];
}
```

### 1.5 Player Model

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'player.g.dart';

/// Direction of language learning for a player
enum LanguageDirection {
  /// Learning from Greek to Catalan (Greek speakers learning Catalan)
  greekToCatalan,
  /// Learning from Catalan to Greek (Catalan speakers learning Greek)
  catalanToGreek,
}

/// Represents a player in the game
@JsonSerializable()
class Player extends Equatable {
  /// Unique identifier for the player (generated UUID)
  final String id;

  /// Player's display name
  final String name;

  /// The language direction assigned to this player
  final LanguageDirection languageDirection;

  /// Current total score in the game session
  final int score;

  /// Player number (1 or 2) for display purposes
  final int playerNumber;

  const Player({
    required this.id,
    required this.name,
    required this.languageDirection,
    this.score = 0,
    required this.playerNumber,
  });

  /// Create a new player with auto-generated ID
  factory Player.create({
    required String name,
    required LanguageDirection languageDirection,
    required int playerNumber,
  }) {
    return Player(
      id: const Uuid().v4(),
      name: name,
      languageDirection: languageDirection,
      score: 0,
      playerNumber: playerNumber,
    );
  }

  /// Get the source language code for this player
  String get sourceLanguageCode =>
      languageDirection == LanguageDirection.greekToCatalan ? 'el' : 'ca';

  /// Get the target language code for this player
  String get targetLanguageCode =>
      languageDirection == LanguageDirection.greekToCatalan ? 'ca' : 'el';

  /// Add points to the player's score
  Player addScore(int points) => copyWith(score: score + points);

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerToJson(this);

  Player copyWith({
    String? id,
    String? name,
    LanguageDirection? languageDirection,
    int? score,
    int? playerNumber,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      languageDirection: languageDirection ?? this.languageDirection,
      score: score ?? this.score,
      playerNumber: playerNumber ?? this.playerNumber,
    );
  }

  @override
  List<Object?> get props => [id, name, languageDirection, score, playerNumber];
}
```

### 1.6 Game Session Models

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'game_session.g.dart';

/// Type of mini-game
enum MiniGameType {
  @JsonValue('vocab_flash')
  vocabFlash,
  @JsonValue('phrase_builder')
  phraseBuilder,
}

/// Current phase of the game session
enum GamePhase {
  /// Initial setup phase
  setup,
  /// Deck selection phase
  deckSelection,
  /// Player turn transition
  turnTransition,
  /// Active gameplay
  playing,
  /// Mini-game transition (between vocab flash and phrase builder)
  miniGameTransition,
  /// Results display
  results,
  /// Game completed
  completed,
}

/// Result of a single question/answer
@JsonSerializable()
class QuestionResult extends Equatable {
  /// The content item ID that was asked
  final String contentItemId;

  /// Whether the answer was correct
  final bool isCorrect;

  /// The answer the player selected (for vocab) or arranged (for phrase)
  final String? selectedAnswer;

  /// Time taken to answer in milliseconds
  final int timeTakenMs;

  /// Base points earned
  final int basePoints;

  /// Speed/time bonus points earned
  final int bonusPoints;

  /// Total points for this question
  int get totalPoints => basePoints + bonusPoints;

  const QuestionResult({
    required this.contentItemId,
    required this.isCorrect,
    this.selectedAnswer,
    required this.timeTakenMs,
    required this.basePoints,
    required this.bonusPoints,
  });

  factory QuestionResult.fromJson(Map<String, dynamic> json) =>
      _$QuestionResultFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionResultToJson(this);

  @override
  List<Object?> get props => [
        contentItemId,
        isCorrect,
        selectedAnswer,
        timeTakenMs,
        basePoints,
        bonusPoints,
      ];
}

/// Result of a phrase builder question with partial credit support
@JsonSerializable()
class PhraseBuilderResult extends Equatable {
  /// The content item ID that was asked
  final String contentItemId;

  /// The order the player arranged the words
  final List<String> arrangedWords;

  /// The correct order of words
  final List<String> correctOrder;

  /// Number of words in correct position
  final int correctPositions;

  /// Total number of words
  final int totalWords;

  /// Percentage correct (0.0 to 1.0)
  double get percentageCorrect =>
      totalWords > 0 ? correctPositions / totalWords : 0.0;

  /// Whether perfectly correct
  bool get isPerfect => correctPositions == totalWords;

  /// Time taken to answer in milliseconds
  final int timeTakenMs;

  /// Base points earned (proportional to correctness)
  final int basePoints;

  /// Time bonus (only for perfect answers)
  final int bonusPoints;

  /// Hint cost deducted (if hint was used)
  final int hintCost;

  /// Total points for this phrase
  int get totalPoints => basePoints + bonusPoints - hintCost;

  const PhraseBuilderResult({
    required this.contentItemId,
    required this.arrangedWords,
    required this.correctOrder,
    required this.correctPositions,
    required this.totalWords,
    required this.timeTakenMs,
    required this.basePoints,
    required this.bonusPoints,
    this.hintCost = 0,
  });

  factory PhraseBuilderResult.fromJson(Map<String, dynamic> json) =>
      _$PhraseBuilderResultFromJson(json);

  Map<String, dynamic> toJson() => _$PhraseBuilderResultToJson(this);

  @override
  List<Object?> get props => [
        contentItemId,
        arrangedWords,
        correctOrder,
        correctPositions,
        totalWords,
        timeTakenMs,
        basePoints,
        bonusPoints,
        hintCost,
      ];
}

/// A player's turn within a mini-game
@JsonSerializable()
class PlayerTurn extends Equatable {
  /// Player ID
  final String playerId;

  /// Results for vocab flash questions
  final List<QuestionResult> vocabResults;

  /// Results for phrase builder questions
  final List<PhraseBuilderResult> phraseResults;

  /// Total score for this turn
  int get totalScore {
    final vocabScore =
        vocabResults.fold(0, (sum, r) => sum + r.totalPoints);
    final phraseScore =
        phraseResults.fold(0, (sum, r) => sum + r.totalPoints);
    return vocabScore + phraseScore;
  }

  const PlayerTurn({
    required this.playerId,
    this.vocabResults = const [],
    this.phraseResults = const [],
  });

  /// Add a vocab flash result
  PlayerTurn addVocabResult(QuestionResult result) => copyWith(
        vocabResults: [...vocabResults, result],
      );

  /// Add a phrase builder result
  PlayerTurn addPhraseResult(PhraseBuilderResult result) => copyWith(
        phraseResults: [...phraseResults, result],
      );

  factory PlayerTurn.fromJson(Map<String, dynamic> json) =>
      _$PlayerTurnFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerTurnToJson(this);

  PlayerTurn copyWith({
    String? playerId,
    List<QuestionResult>? vocabResults,
    List<PhraseBuilderResult>? phraseResults,
  }) {
    return PlayerTurn(
      playerId: playerId ?? this.playerId,
      vocabResults: vocabResults ?? this.vocabResults,
      phraseResults: phraseResults ?? this.phraseResults,
    );
  }

  @override
  List<Object?> get props => [playerId, vocabResults, phraseResults];
}

/// Progress within a mini-game round
@JsonSerializable()
class MiniGameProgress extends Equatable {
  /// Type of mini-game
  final MiniGameType type;

  /// Current question index (0-based)
  final int currentQuestionIndex;

  /// Total questions in this mini-game for current player
  final int totalQuestions;

  /// Content item IDs assigned for this mini-game
  final List<String> assignedItemIds;

  /// Whether this mini-game is completed
  bool get isCompleted => currentQuestionIndex >= totalQuestions;

  const MiniGameProgress({
    required this.type,
    this.currentQuestionIndex = 0,
    required this.totalQuestions,
    required this.assignedItemIds,
  });

  /// Move to next question
  MiniGameProgress nextQuestion() => copyWith(
        currentQuestionIndex: currentQuestionIndex + 1,
      );

  factory MiniGameProgress.fromJson(Map<String, dynamic> json) =>
      _$MiniGameProgressFromJson(json);

  Map<String, dynamic> toJson() => _$MiniGameProgressToJson(this);

  MiniGameProgress copyWith({
    MiniGameType? type,
    int? currentQuestionIndex,
    int? totalQuestions,
    List<String>? assignedItemIds,
  }) {
    return MiniGameProgress(
      type: type ?? this.type,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      assignedItemIds: assignedItemIds ?? this.assignedItemIds,
    );
  }

  @override
  List<Object?> get props =>
      [type, currentQuestionIndex, totalQuestions, assignedItemIds];
}

/// Complete game session state
@JsonSerializable()
class GameSession extends Equatable {
  /// Unique session identifier
  final String id;

  /// When the session started
  final DateTime startedAt;

  /// When the session ended (null if in progress)
  final DateTime? endedAt;

  /// Selected deck ID
  final String deckId;

  /// Player 1
  final Player player1;

  /// Player 2
  final Player player2;

  /// Current game phase
  final GamePhase phase;

  /// Current active player (1 or 2)
  final int currentPlayerNumber;

  /// Current mini-game type
  final MiniGameType currentMiniGame;

  /// Progress in current mini-game
  final MiniGameProgress? miniGameProgress;

  /// Player 1's turn data
  final PlayerTurn player1Turn;

  /// Player 2's turn data
  final PlayerTurn player2Turn;

  const GameSession({
    required this.id,
    required this.startedAt,
    this.endedAt,
    required this.deckId,
    required this.player1,
    required this.player2,
    this.phase = GamePhase.setup,
    this.currentPlayerNumber = 1,
    this.currentMiniGame = MiniGameType.vocabFlash,
    this.miniGameProgress,
    required this.player1Turn,
    required this.player2Turn,
  });

  /// Create a new game session
  factory GameSession.create({
    required String deckId,
    required Player player1,
    required Player player2,
  }) {
    return GameSession(
      id: const Uuid().v4(),
      startedAt: DateTime.now(),
      deckId: deckId,
      player1: player1,
      player2: player2,
      phase: GamePhase.playing,
      player1Turn: PlayerTurn(playerId: player1.id),
      player2Turn: PlayerTurn(playerId: player2.id),
    );
  }

  /// Get current player
  Player get currentPlayer =>
      currentPlayerNumber == 1 ? player1 : player2;

  /// Get current player's turn
  PlayerTurn get currentTurn =>
      currentPlayerNumber == 1 ? player1Turn : player2Turn;

  /// Get player 1's total score
  int get player1Score => player1Turn.totalScore;

  /// Get player 2's total score
  int get player2Score => player2Turn.totalScore;

  /// Check if game is completed
  bool get isCompleted => phase == GamePhase.completed;

  /// Get the winner (null if tie or not completed)
  Player? get winner {
    if (!isCompleted) return null;
    if (player1Score > player2Score) return player1;
    if (player2Score > player1Score) return player2;
    return null; // Tie
  }

  /// Check if result is a tie
  bool get isTie => isCompleted && player1Score == player2Score;

  factory GameSession.fromJson(Map<String, dynamic> json) =>
      _$GameSessionFromJson(json);

  Map<String, dynamic> toJson() => _$GameSessionToJson(this);

  GameSession copyWith({
    String? id,
    DateTime? startedAt,
    DateTime? endedAt,
    String? deckId,
    Player? player1,
    Player? player2,
    GamePhase? phase,
    int? currentPlayerNumber,
    MiniGameType? currentMiniGame,
    MiniGameProgress? miniGameProgress,
    PlayerTurn? player1Turn,
    PlayerTurn? player2Turn,
  }) {
    return GameSession(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      deckId: deckId ?? this.deckId,
      player1: player1 ?? this.player1,
      player2: player2 ?? this.player2,
      phase: phase ?? this.phase,
      currentPlayerNumber: currentPlayerNumber ?? this.currentPlayerNumber,
      currentMiniGame: currentMiniGame ?? this.currentMiniGame,
      miniGameProgress: miniGameProgress ?? this.miniGameProgress,
      player1Turn: player1Turn ?? this.player1Turn,
      player2Turn: player2Turn ?? this.player2Turn,
    );
  }

  @override
  List<Object?> get props => [
        id,
        startedAt,
        endedAt,
        deckId,
        player1,
        player2,
        phase,
        currentPlayerNumber,
        currentMiniGame,
        miniGameProgress,
        player1Turn,
        player2Turn,
      ];
}
```

### 1.7 Game Settings Model

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'game_settings.g.dart';

/// Theme mode for the application
enum ThemeMode {
  @JsonValue('light')
  light,
  @JsonValue('dark')
  dark,
  @JsonValue('system')
  system,
}

/// Application settings stored locally
@JsonSerializable()
class GameSettings extends Equatable {
  /// Theme preference
  final ThemeMode themeMode;

  /// Sound effects enabled
  final bool soundEnabled;

  /// Background music enabled
  final bool musicEnabled;

  /// Haptic feedback enabled
  final bool hapticEnabled;

  /// Show pronunciation hints
  final bool showPronunciationHints;

  /// Show romanization for Greek text
  final bool showRomanization;

  /// Default language pair source
  final String? defaultSourceLanguage;

  /// Default language pair target
  final String? defaultTargetLanguage;

  /// Last used player 1 name (convenience)
  final String? lastPlayer1Name;

  /// Last used player 2 name (convenience)
  final String? lastPlayer2Name;

  /// Last selected deck ID
  final String? lastSelectedDeckId;

  /// Vocab flash timer duration in seconds (default 10)
  final int vocabTimerSeconds;

  /// Phrase builder timer duration in seconds (default 30)
  final int phraseTimerSeconds;

  /// Number of vocab questions per player (default 5)
  final int vocabQuestionsPerPlayer;

  /// Number of phrases per player (default 3)
  final int phrasesPerPlayer;

  /// Tutorial completed flag
  final bool tutorialCompleted;

  /// First launch timestamp
  final DateTime? firstLaunchAt;

  /// Total games played (for analytics)
  final int totalGamesPlayed;

  const GameSettings({
    this.themeMode = ThemeMode.system,
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.hapticEnabled = true,
    this.showPronunciationHints = true,
    this.showRomanization = true,
    this.defaultSourceLanguage,
    this.defaultTargetLanguage,
    this.lastPlayer1Name,
    this.lastPlayer2Name,
    this.lastSelectedDeckId,
    this.vocabTimerSeconds = 10,
    this.phraseTimerSeconds = 30,
    this.vocabQuestionsPerPlayer = 5,
    this.phrasesPerPlayer = 3,
    this.tutorialCompleted = false,
    this.firstLaunchAt,
    this.totalGamesPlayed = 0,
  });

  /// Default settings
  static const GameSettings defaults = GameSettings();

  factory GameSettings.fromJson(Map<String, dynamic> json) =>
      _$GameSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$GameSettingsToJson(this);

  GameSettings copyWith({
    ThemeMode? themeMode,
    bool? soundEnabled,
    bool? musicEnabled,
    bool? hapticEnabled,
    bool? showPronunciationHints,
    bool? showRomanization,
    String? defaultSourceLanguage,
    String? defaultTargetLanguage,
    String? lastPlayer1Name,
    String? lastPlayer2Name,
    String? lastSelectedDeckId,
    int? vocabTimerSeconds,
    int? phraseTimerSeconds,
    int? vocabQuestionsPerPlayer,
    int? phrasesPerPlayer,
    bool? tutorialCompleted,
    DateTime? firstLaunchAt,
    int? totalGamesPlayed,
  }) {
    return GameSettings(
      themeMode: themeMode ?? this.themeMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      showPronunciationHints:
          showPronunciationHints ?? this.showPronunciationHints,
      showRomanization: showRomanization ?? this.showRomanization,
      defaultSourceLanguage:
          defaultSourceLanguage ?? this.defaultSourceLanguage,
      defaultTargetLanguage:
          defaultTargetLanguage ?? this.defaultTargetLanguage,
      lastPlayer1Name: lastPlayer1Name ?? this.lastPlayer1Name,
      lastPlayer2Name: lastPlayer2Name ?? this.lastPlayer2Name,
      lastSelectedDeckId: lastSelectedDeckId ?? this.lastSelectedDeckId,
      vocabTimerSeconds: vocabTimerSeconds ?? this.vocabTimerSeconds,
      phraseTimerSeconds: phraseTimerSeconds ?? this.phraseTimerSeconds,
      vocabQuestionsPerPlayer:
          vocabQuestionsPerPlayer ?? this.vocabQuestionsPerPlayer,
      phrasesPerPlayer: phrasesPerPlayer ?? this.phrasesPerPlayer,
      tutorialCompleted: tutorialCompleted ?? this.tutorialCompleted,
      firstLaunchAt: firstLaunchAt ?? this.firstLaunchAt,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        soundEnabled,
        musicEnabled,
        hapticEnabled,
        showPronunciationHints,
        showRomanization,
        defaultSourceLanguage,
        defaultTargetLanguage,
        lastPlayer1Name,
        lastPlayer2Name,
        lastSelectedDeckId,
        vocabTimerSeconds,
        phraseTimerSeconds,
        vocabQuestionsPerPlayer,
        phrasesPerPlayer,
        tutorialCompleted,
        firstLaunchAt,
        totalGamesPlayed,
      ];
}
```

### 1.8 Match History Model

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'match_history.g.dart';

/// Summary of a player's performance in a match
@JsonSerializable()
class PlayerMatchSummary extends Equatable {
  /// Player name
  final String name;

  /// Language direction played
  final LanguageDirection languageDirection;

  /// Total score
  final int totalScore;

  /// Vocab flash score
  final int vocabScore;

  /// Phrase builder score
  final int phraseScore;

  /// Number of correct vocab answers
  final int vocabCorrect;

  /// Total vocab questions
  final int vocabTotal;

  /// Number of perfect phrases
  final int phrasePerfect;

  /// Total phrases
  final int phraseTotal;

  /// Average response time in milliseconds
  final int avgResponseTimeMs;

  const PlayerMatchSummary({
    required this.name,
    required this.languageDirection,
    required this.totalScore,
    required this.vocabScore,
    required this.phraseScore,
    required this.vocabCorrect,
    required this.vocabTotal,
    required this.phrasePerfect,
    required this.phraseTotal,
    required this.avgResponseTimeMs,
  });

  /// Vocab accuracy percentage
  double get vocabAccuracy =>
      vocabTotal > 0 ? vocabCorrect / vocabTotal : 0.0;

  /// Phrase perfect percentage
  double get phrasePerfectRate =>
      phraseTotal > 0 ? phrasePerfect / phraseTotal : 0.0;

  factory PlayerMatchSummary.fromJson(Map<String, dynamic> json) =>
      _$PlayerMatchSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerMatchSummaryToJson(this);

  @override
  List<Object?> get props => [
        name,
        languageDirection,
        totalScore,
        vocabScore,
        phraseScore,
        vocabCorrect,
        vocabTotal,
        phrasePerfect,
        phraseTotal,
        avgResponseTimeMs,
      ];
}

/// Match outcome
enum MatchOutcome {
  @JsonValue('player1_win')
  player1Win,
  @JsonValue('player2_win')
  player2Win,
  @JsonValue('tie')
  tie,
}

/// A completed match record for history
@JsonSerializable()
class MatchRecord extends Equatable {
  /// Unique match identifier
  final String id;

  /// When the match was played
  final DateTime playedAt;

  /// Duration of the match in seconds
  final int durationSeconds;

  /// Deck ID used
  final String deckId;

  /// Deck name (cached for display without loading deck)
  final String deckName;

  /// Player 1 summary
  final PlayerMatchSummary player1;

  /// Player 2 summary
  final PlayerMatchSummary player2;

  /// Match outcome
  final MatchOutcome outcome;

  /// Score difference (absolute value)
  final int scoreDifference;

  const MatchRecord({
    required this.id,
    required this.playedAt,
    required this.durationSeconds,
    required this.deckId,
    required this.deckName,
    required this.player1,
    required this.player2,
    required this.outcome,
    required this.scoreDifference,
  });

  /// Create from a completed game session
  factory MatchRecord.fromGameSession(
    GameSession session,
    String deckName,
  ) {
    final p1VocabCorrect =
        session.player1Turn.vocabResults.where((r) => r.isCorrect).length;
    final p2VocabCorrect =
        session.player2Turn.vocabResults.where((r) => r.isCorrect).length;
    final p1PhrasePerfect =
        session.player1Turn.phraseResults.where((r) => r.isPerfect).length;
    final p2PhrasePerfect =
        session.player2Turn.phraseResults.where((r) => r.isPerfect).length;

    final p1AvgTime = _calculateAvgTime(
      session.player1Turn.vocabResults.map((r) => r.timeTakenMs).toList(),
      session.player1Turn.phraseResults.map((r) => r.timeTakenMs).toList(),
    );
    final p2AvgTime = _calculateAvgTime(
      session.player2Turn.vocabResults.map((r) => r.timeTakenMs).toList(),
      session.player2Turn.phraseResults.map((r) => r.timeTakenMs).toList(),
    );

    final p1Score = session.player1Score;
    final p2Score = session.player2Score;

    MatchOutcome outcome;
    if (p1Score > p2Score) {
      outcome = MatchOutcome.player1Win;
    } else if (p2Score > p1Score) {
      outcome = MatchOutcome.player2Win;
    } else {
      outcome = MatchOutcome.tie;
    }

    return MatchRecord(
      id: session.id,
      playedAt: session.startedAt,
      durationSeconds: session.endedAt != null
          ? session.endedAt!.difference(session.startedAt).inSeconds
          : 0,
      deckId: session.deckId,
      deckName: deckName,
      player1: PlayerMatchSummary(
        name: session.player1.name,
        languageDirection: session.player1.languageDirection,
        totalScore: p1Score,
        vocabScore: session.player1Turn.vocabResults
            .fold(0, (sum, r) => sum + r.totalPoints),
        phraseScore: session.player1Turn.phraseResults
            .fold(0, (sum, r) => sum + r.totalPoints),
        vocabCorrect: p1VocabCorrect,
        vocabTotal: session.player1Turn.vocabResults.length,
        phrasePerfect: p1PhrasePerfect,
        phraseTotal: session.player1Turn.phraseResults.length,
        avgResponseTimeMs: p1AvgTime,
      ),
      player2: PlayerMatchSummary(
        name: session.player2.name,
        languageDirection: session.player2.languageDirection,
        totalScore: p2Score,
        vocabScore: session.player2Turn.vocabResults
            .fold(0, (sum, r) => sum + r.totalPoints),
        phraseScore: session.player2Turn.phraseResults
            .fold(0, (sum, r) => sum + r.totalPoints),
        vocabCorrect: p2VocabCorrect,
        vocabTotal: session.player2Turn.vocabResults.length,
        phrasePerfect: p2PhrasePerfect,
        phraseTotal: session.player2Turn.phraseResults.length,
        avgResponseTimeMs: p2AvgTime,
      ),
      outcome: outcome,
      scoreDifference: (p1Score - p2Score).abs(),
    );
  }

  static int _calculateAvgTime(List<int> vocabTimes, List<int> phraseTimes) {
    final allTimes = [...vocabTimes, ...phraseTimes];
    if (allTimes.isEmpty) return 0;
    return allTimes.reduce((a, b) => a + b) ~/ allTimes.length;
  }

  /// Get winner name (null if tie)
  String? get winnerName {
    switch (outcome) {
      case MatchOutcome.player1Win:
        return player1.name;
      case MatchOutcome.player2Win:
        return player2.name;
      case MatchOutcome.tie:
        return null;
    }
  }

  factory MatchRecord.fromJson(Map<String, dynamic> json) =>
      _$MatchRecordFromJson(json);

  Map<String, dynamic> toJson() => _$MatchRecordToJson(this);

  @override
  List<Object?> get props => [
        id,
        playedAt,
        durationSeconds,
        deckId,
        deckName,
        player1,
        player2,
        outcome,
        scoreDifference,
      ];
}

/// Aggregated player statistics
@JsonSerializable()
class PlayerStats extends Equatable {
  /// Player name (used as identifier)
  final String name;

  /// Total matches played
  final int totalMatches;

  /// Matches won
  final int wins;

  /// Matches lost
  final int losses;

  /// Matches tied
  final int ties;

  /// Total points scored across all matches
  final int totalPoints;

  /// Highest single match score
  final int highestScore;

  /// Total correct vocab answers
  final int totalVocabCorrect;

  /// Total vocab questions answered
  final int totalVocabAttempted;

  /// Total perfect phrases
  final int totalPhrasePerfect;

  /// Total phrases attempted
  final int totalPhrasesAttempted;

  /// Last played timestamp
  final DateTime? lastPlayedAt;

  const PlayerStats({
    required this.name,
    this.totalMatches = 0,
    this.wins = 0,
    this.losses = 0,
    this.ties = 0,
    this.totalPoints = 0,
    this.highestScore = 0,
    this.totalVocabCorrect = 0,
    this.totalVocabAttempted = 0,
    this.totalPhrasePerfect = 0,
    this.totalPhrasesAttempted = 0,
    this.lastPlayedAt,
  });

  /// Win rate as percentage
  double get winRate => totalMatches > 0 ? wins / totalMatches : 0.0;

  /// Average points per match
  double get avgPointsPerMatch =>
      totalMatches > 0 ? totalPoints / totalMatches : 0.0;

  /// Overall vocab accuracy
  double get vocabAccuracy =>
      totalVocabAttempted > 0 ? totalVocabCorrect / totalVocabAttempted : 0.0;

  /// Overall phrase perfect rate
  double get phrasePerfectRate => totalPhrasesAttempted > 0
      ? totalPhrasePerfect / totalPhrasesAttempted
      : 0.0;

  /// Update stats with a new match result
  PlayerStats updateWithMatch(PlayerMatchSummary summary, MatchOutcome outcome,
      String playerName, int playerNumber) {
    final isPlayer1 = playerNumber == 1;
    final isWin = (isPlayer1 && outcome == MatchOutcome.player1Win) ||
        (!isPlayer1 && outcome == MatchOutcome.player2Win);
    final isLoss = (isPlayer1 && outcome == MatchOutcome.player2Win) ||
        (!isPlayer1 && outcome == MatchOutcome.player1Win);

    return copyWith(
      totalMatches: totalMatches + 1,
      wins: wins + (isWin ? 1 : 0),
      losses: losses + (isLoss ? 1 : 0),
      ties: ties + (outcome == MatchOutcome.tie ? 1 : 0),
      totalPoints: totalPoints + summary.totalScore,
      highestScore: summary.totalScore > highestScore
          ? summary.totalScore
          : highestScore,
      totalVocabCorrect: totalVocabCorrect + summary.vocabCorrect,
      totalVocabAttempted: totalVocabAttempted + summary.vocabTotal,
      totalPhrasePerfect: totalPhrasePerfect + summary.phrasePerfect,
      totalPhrasesAttempted: totalPhrasesAttempted + summary.phraseTotal,
      lastPlayedAt: DateTime.now(),
    );
  }

  factory PlayerStats.fromJson(Map<String, dynamic> json) =>
      _$PlayerStatsFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerStatsToJson(this);

  PlayerStats copyWith({
    String? name,
    int? totalMatches,
    int? wins,
    int? losses,
    int? ties,
    int? totalPoints,
    int? highestScore,
    int? totalVocabCorrect,
    int? totalVocabAttempted,
    int? totalPhrasePerfect,
    int? totalPhrasesAttempted,
    DateTime? lastPlayedAt,
  }) {
    return PlayerStats(
      name: name ?? this.name,
      totalMatches: totalMatches ?? this.totalMatches,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      ties: ties ?? this.ties,
      totalPoints: totalPoints ?? this.totalPoints,
      highestScore: highestScore ?? this.highestScore,
      totalVocabCorrect: totalVocabCorrect ?? this.totalVocabCorrect,
      totalVocabAttempted: totalVocabAttempted ?? this.totalVocabAttempted,
      totalPhrasePerfect: totalPhrasePerfect ?? this.totalPhrasePerfect,
      totalPhrasesAttempted:
          totalPhrasesAttempted ?? this.totalPhrasesAttempted,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  @override
  List<Object?> get props => [
        name,
        totalMatches,
        wins,
        losses,
        ties,
        totalPoints,
        highestScore,
        totalVocabCorrect,
        totalVocabAttempted,
        totalPhrasePerfect,
        totalPhrasesAttempted,
        lastPlayedAt,
      ];
}
```

---

## 2. Hive/Isar Schema Definitions

### 2.1 Storage Strategy Overview

For the MVP, we use **Hive** for local persistence due to its simplicity, performance, and Flutter-native design. Hive is ideal for:
- Key-value storage (settings)
- Object storage (match history, cached content)
- No SQL complexity needed for MVP scope

**Alternative for Future:** Isar could be considered post-MVP for more complex queries and relationships.

### 2.2 Hive Box Organization

```dart
/// Hive box names and organization
class HiveBoxes {
  /// Settings box - stores GameSettings
  static const String settings = 'settings_box';

  /// Match history box - stores MatchRecord objects
  static const String matchHistory = 'match_history_box';

  /// Player stats box - stores PlayerStats keyed by player name
  static const String playerStats = 'player_stats_box';

  /// Deck cache box - stores parsed Deck objects for faster loading
  static const String deckCache = 'deck_cache_box';

  /// Current game session box - for game state persistence
  static const String currentSession = 'current_session_box';
}
```

### 2.3 Hive Type Adapters

```dart
import 'package:hive/hive.dart';

// Type IDs for Hive adapters (must be unique and stable)
class HiveTypeIds {
  static const int gameSettings = 0;
  static const int themeMode = 1;
  static const int matchRecord = 2;
  static const int playerMatchSummary = 3;
  static const int matchOutcome = 4;
  static const int languageDirection = 5;
  static const int playerStats = 6;
  static const int deck = 7;
  static const int contentItem = 8;
  static const int greekEntry = 9;
  static const int catalanEntry = 10;
  static const int contentItemType = 11;
  static const int contentCategory = 12;
  static const int cefrLevel = 13;
  static const int localizedString = 14;
  static const int gameSession = 15;
}

/// Adapter for ThemeMode enum
class ThemeModeAdapter extends TypeAdapter<ThemeMode> {
  @override
  final int typeId = HiveTypeIds.themeMode;

  @override
  ThemeMode read(BinaryReader reader) {
    return ThemeMode.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, ThemeMode obj) {
    writer.writeByte(obj.index);
  }
}

/// Adapter for LanguageDirection enum
class LanguageDirectionAdapter extends TypeAdapter<LanguageDirection> {
  @override
  final int typeId = HiveTypeIds.languageDirection;

  @override
  LanguageDirection read(BinaryReader reader) {
    return LanguageDirection.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, LanguageDirection obj) {
    writer.writeByte(obj.index);
  }
}

/// Adapter for MatchOutcome enum
class MatchOutcomeAdapter extends TypeAdapter<MatchOutcome> {
  @override
  final int typeId = HiveTypeIds.matchOutcome;

  @override
  MatchOutcome read(BinaryReader reader) {
    return MatchOutcome.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, MatchOutcome obj) {
    writer.writeByte(obj.index);
  }
}

// Additional adapters would be generated using hive_generator
// Run: flutter pub run build_runner build
```

### 2.4 Hive Initialization

```dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// Initialize Hive and register all type adapters
class HiveInitializer {
  static Future<void> initialize() async {
    // Initialize Hive with Flutter support
    await Hive.initFlutter();

    // Register type adapters
    _registerAdapters();

    // Open required boxes
    await _openBoxes();
  }

  static void _registerAdapters() {
    // Register enum adapters
    Hive.registerAdapter(ThemeModeAdapter());
    Hive.registerAdapter(LanguageDirectionAdapter());
    Hive.registerAdapter(MatchOutcomeAdapter());

    // Register model adapters (generated by hive_generator)
    Hive.registerAdapter(GameSettingsAdapter());
    Hive.registerAdapter(MatchRecordAdapter());
    Hive.registerAdapter(PlayerMatchSummaryAdapter());
    Hive.registerAdapter(PlayerStatsAdapter());
    // Add more adapters as needed
  }

  static Future<void> _openBoxes() async {
    // Open settings box
    await Hive.openBox<GameSettings>(HiveBoxes.settings);

    // Open match history box
    await Hive.openBox<MatchRecord>(HiveBoxes.matchHistory);

    // Open player stats box
    await Hive.openBox<PlayerStats>(HiveBoxes.playerStats);

    // Open current session box (lazy loaded when needed)
    // await Hive.openLazyBox<GameSession>(HiveBoxes.currentSession);
  }

  /// Close all Hive boxes (call on app termination)
  static Future<void> close() async {
    await Hive.close();
  }
}
```

### 2.5 Storage Keys

```dart
/// Keys used for storing single objects in Hive boxes
class HiveKeys {
  /// Key for the single GameSettings object
  static const String settings = 'app_settings';

  /// Key for the current in-progress game session
  static const String currentSession = 'current_game_session';
}
```

### 2.6 Lazy Loading Considerations

```dart
/// Lazy box management for large data
class LazyBoxManager {
  static LazyBox<Deck>? _deckCacheBox;
  static LazyBox<GameSession>? _sessionBox;

  /// Get deck cache box (lazy loaded)
  static Future<LazyBox<Deck>> getDeckCacheBox() async {
    _deckCacheBox ??= await Hive.openLazyBox<Deck>(HiveBoxes.deckCache);
    return _deckCacheBox!;
  }

  /// Get current session box (lazy loaded)
  static Future<LazyBox<GameSession>> getSessionBox() async {
    _sessionBox ??= await Hive.openLazyBox<GameSession>(HiveBoxes.currentSession);
    return _sessionBox!;
  }

  /// Get a deck from cache
  static Future<Deck?> getCachedDeck(String deckId) async {
    final box = await getDeckCacheBox();
    return box.get(deckId);
  }

  /// Cache a deck
  static Future<void> cacheDeck(Deck deck) async {
    final box = await getDeckCacheBox();
    await box.put(deck.id, deck);
  }
}
```

---

## 3. Content Loading Strategy

### 3.1 Overview

Content loading follows a three-tier strategy:
1. **Asset Loading**: Primary source from bundled JSON files
2. **Cache Layer**: Parsed content cached in Hive for faster subsequent loads
3. **Future: Remote Loading**: Dynamic content updates (post-MVP)

### 3.2 Asset Structure

```
assets/
  data/
    decks/
      greetings_deck.json     # Bundled deck content
      numbers_deck.json       # Future decks
    manifest.json             # List of available decks
```

### 3.3 Content Loader Implementation

```dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Exception thrown when content loading fails
class ContentLoadException implements Exception {
  final String message;
  final dynamic originalError;

  ContentLoadException(this.message, [this.originalError]);

  @override
  String toString() => 'ContentLoadException: $message';
}

/// Validation result for content
class ContentValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const ContentValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });

  factory ContentValidationResult.valid() =>
      const ContentValidationResult(isValid: true);

  factory ContentValidationResult.invalid(List<String> errors) =>
      ContentValidationResult(isValid: false, errors: errors);
}

/// Content loader for bundled JSON assets
class ContentLoader {
  static const String _assetBasePath = 'assets/data';
  static const String _manifestPath = '$_assetBasePath/manifest.json';

  /// Load the deck manifest (list of available decks)
  Future<List<DeckInfo>> loadDeckManifest() async {
    try {
      final jsonString = await rootBundle.loadString(_manifestPath);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final decksJson = jsonData['decks'] as List<dynamic>;

      return decksJson
          .map((d) => DeckInfo.fromJson(d as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ContentLoadException('Failed to load deck manifest', e);
    }
  }

  /// Load a specific deck by ID
  Future<Deck> loadDeck(String deckId) async {
    // Try cache first
    final cached = await LazyBoxManager.getCachedDeck(deckId);
    if (cached != null) {
      return cached;
    }

    // Load from assets
    try {
      final jsonString = await rootBundle.loadString(
        '$_assetBasePath/${deckId}_deck.json',
      );
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      // Parse the deck structure (handles nested 'deck' and 'items')
      final deck = _parseDeckJson(jsonData);

      // Validate the deck
      final validation = validateDeck(deck);
      if (!validation.isValid) {
        throw ContentLoadException(
          'Deck validation failed: ${validation.errors.join(", ")}',
        );
      }

      // Cache for future use
      await LazyBoxManager.cacheDeck(deck);

      return deck;
    } catch (e) {
      if (e is ContentLoadException) rethrow;
      throw ContentLoadException('Failed to load deck: $deckId', e);
    }
  }

  /// Parse the JSON structure into a Deck object
  Deck _parseDeckJson(Map<String, dynamic> jsonData) {
    // Handle structure: { "deck": {...}, "items": [...] }
    final deckMeta = jsonData['deck'] as Map<String, dynamic>?;
    final itemsJson = jsonData['items'] as List<dynamic>?;

    if (deckMeta == null || itemsJson == null) {
      throw ContentLoadException('Invalid deck JSON structure');
    }

    final items = itemsJson
        .map((i) => ContentItem.fromJson(i as Map<String, dynamic>))
        .toList();

    return Deck(
      id: deckMeta['id'] as String,
      name: LocalizedString.fromJson(deckMeta['name'] as Map<String, dynamic>),
      description: deckMeta['description'] != null
          ? LocalizedString.fromJson(
              deckMeta['description'] as Map<String, dynamic>)
          : null,
      level: _parseCEFRLevel(deckMeta['level'] as String),
      itemCount: deckMeta['itemCount'] as int? ?? items.length,
      items: items,
    );
  }

  /// Parse CEFR level string to enum
  CEFRLevel _parseCEFRLevel(String level) {
    switch (level.toUpperCase()) {
      case 'A1':
        return CEFRLevel.a1;
      case 'A2':
        return CEFRLevel.a2;
      case 'B1':
        return CEFRLevel.b1;
      case 'B2':
        return CEFRLevel.b2;
      case 'C1':
        return CEFRLevel.c1;
      case 'C2':
        return CEFRLevel.c2;
      default:
        return CEFRLevel.a1;
    }
  }

  /// Validate a deck's content
  ContentValidationResult validateDeck(Deck deck) {
    final errors = <String>[];
    final warnings = <String>[];

    // Check minimum item count
    if (deck.items.length < 10) {
      errors.add('Deck must have at least 10 items');
    }

    // Check for duplicate IDs
    final ids = deck.items.map((i) => i.id).toSet();
    if (ids.length != deck.items.length) {
      errors.add('Deck contains duplicate item IDs');
    }

    // Validate each item
    for (final item in deck.items) {
      final itemErrors = _validateItem(item);
      errors.addAll(itemErrors);
    }

    // Check for phrase items (required for phrase builder)
    final phraseCount = deck.phraseItems.length;
    if (phraseCount < 6) {
      warnings.add('Deck has only $phraseCount phrases; 6 recommended');
    }

    // Check difficulty distribution
    final easyCount = deck.getItemsByDifficulty(1).length;
    if (easyCount < 3) {
      warnings.add('Deck has few easy (difficulty 1) items');
    }

    return ContentValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Validate a single content item
  List<String> _validateItem(ContentItem item) {
    final errors = <String>[];

    // Check required fields
    if (item.id.isEmpty) {
      errors.add('Item has empty ID');
    }
    if (item.greek.text.isEmpty) {
      errors.add('Item ${item.id} has empty Greek text');
    }
    if (item.catalan.text.isEmpty) {
      errors.add('Item ${item.id} has empty Catalan text');
    }

    // Check difficulty range
    if (item.difficulty < 1 || item.difficulty > 3) {
      errors.add('Item ${item.id} has invalid difficulty: ${item.difficulty}');
    }

    // Check phrase items have word breakdown
    if (item.isPhrase && item.words == null && item.wordBreakdown == null) {
      errors.add('Phrase item ${item.id} missing word breakdown');
    }

    return errors;
  }

  /// Preload all decks into cache (call during app startup)
  Future<void> preloadDecks() async {
    try {
      final manifest = await loadDeckManifest();
      for (final deckInfo in manifest) {
        await loadDeck(deckInfo.id);
      }
    } catch (e) {
      // Log error but don't fail - decks can be loaded on demand
      print('Warning: Failed to preload decks: $e');
    }
  }

  /// Clear the deck cache
  Future<void> clearCache() async {
    final box = await LazyBoxManager.getDeckCacheBox();
    await box.clear();
  }
}
```

### 3.4 Content Provider (Riverpod Integration)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the content loader
final contentLoaderProvider = Provider<ContentLoader>((ref) {
  return ContentLoader();
});

/// Provider for the deck manifest
final deckManifestProvider = FutureProvider<List<DeckInfo>>((ref) async {
  final loader = ref.watch(contentLoaderProvider);
  return loader.loadDeckManifest();
});

/// Provider for a specific deck by ID
final deckProvider = FutureProvider.family<Deck, String>((ref, deckId) async {
  final loader = ref.watch(contentLoaderProvider);
  return loader.loadDeck(deckId);
});

/// Provider for vocabulary items from a deck
final vocabItemsProvider =
    FutureProvider.family<List<ContentItem>, String>((ref, deckId) async {
  final deck = await ref.watch(deckProvider(deckId).future);
  return deck.vocabularyItems;
});

/// Provider for phrase items from a deck
final phraseItemsProvider =
    FutureProvider.family<List<ContentItem>, String>((ref, deckId) async {
  final deck = await ref.watch(deckProvider(deckId).future);
  return deck.phraseItems;
});
```

### 3.5 Error Handling

```dart
/// Error handler for content loading with user-friendly messages
class ContentErrorHandler {
  /// Get user-friendly error message
  static String getUserMessage(Object error) {
    if (error is ContentLoadException) {
      if (error.message.contains('manifest')) {
        return 'Unable to load available decks. Please restart the app.';
      }
      if (error.message.contains('validation')) {
        return 'This deck has a problem. Please try another deck.';
      }
      return 'Unable to load content. Please check your connection.';
    }
    return 'Something went wrong. Please try again.';
  }

  /// Check if error is recoverable
  static bool isRecoverable(Object error) {
    if (error is ContentLoadException) {
      // Validation errors are not recoverable
      return !error.message.contains('validation');
    }
    return true;
  }
}
```

---

## 4. Match History Persistence (Optional MVP)

### 4.1 Overview

Match history persistence is **optional for MVP** but the schema is designed for future implementation. This section provides the complete design for storing:
- Individual match records
- Player statistics aggregations
- Leaderboard data

### 4.2 History Repository Implementation

```dart
/// Repository for match history operations
class MatchHistoryRepository {
  static const int _maxHistorySize = 100; // Keep last 100 matches

  /// Get the match history box
  Box<MatchRecord> get _historyBox =>
      Hive.box<MatchRecord>(HiveBoxes.matchHistory);

  /// Get the player stats box
  Box<PlayerStats> get _statsBox =>
      Hive.box<PlayerStats>(HiveBoxes.playerStats);

  /// Save a completed match
  Future<void> saveMatch(MatchRecord match) async {
    // Save the match record
    await _historyBox.put(match.id, match);

    // Update player stats
    await _updatePlayerStats(match);

    // Prune old records if needed
    await _pruneHistory();
  }

  /// Update player statistics after a match
  Future<void> _updatePlayerStats(MatchRecord match) async {
    // Update player 1 stats
    final p1Stats = _statsBox.get(match.player1.name) ??
        PlayerStats(name: match.player1.name);
    final updatedP1Stats =
        p1Stats.updateWithMatch(match.player1, match.outcome, match.player1.name, 1);
    await _statsBox.put(match.player1.name, updatedP1Stats);

    // Update player 2 stats
    final p2Stats = _statsBox.get(match.player2.name) ??
        PlayerStats(name: match.player2.name);
    final updatedP2Stats =
        p2Stats.updateWithMatch(match.player2, match.outcome, match.player2.name, 2);
    await _statsBox.put(match.player2.name, updatedP2Stats);
  }

  /// Prune old history to maintain max size
  Future<void> _pruneHistory() async {
    if (_historyBox.length > _maxHistorySize) {
      final allMatches = _historyBox.values.toList()
        ..sort((a, b) => b.playedAt.compareTo(a.playedAt));

      // Keep only the most recent matches
      final toDelete = allMatches.skip(_maxHistorySize);
      for (final match in toDelete) {
        await _historyBox.delete(match.id);
      }
    }
  }

  /// Get all match history sorted by date (newest first)
  List<MatchRecord> getAllMatches() {
    return _historyBox.values.toList()
      ..sort((a, b) => b.playedAt.compareTo(a.playedAt));
  }

  /// Get match history for a specific player
  List<MatchRecord> getMatchesForPlayer(String playerName) {
    return _historyBox.values
        .where((m) =>
            m.player1.name == playerName || m.player2.name == playerName)
        .toList()
      ..sort((a, b) => b.playedAt.compareTo(a.playedAt));
  }

  /// Get recent matches (last N)
  List<MatchRecord> getRecentMatches(int count) {
    return getAllMatches().take(count).toList();
  }

  /// Get stats for a player
  PlayerStats? getPlayerStats(String playerName) {
    return _statsBox.get(playerName);
  }

  /// Get all player stats sorted by win rate
  List<PlayerStats> getLeaderboard() {
    return _statsBox.values.toList()
      ..sort((a, b) => b.winRate.compareTo(a.winRate));
  }

  /// Get a specific match by ID
  MatchRecord? getMatch(String matchId) {
    return _historyBox.get(matchId);
  }

  /// Delete a match from history
  Future<void> deleteMatch(String matchId) async {
    await _historyBox.delete(matchId);
  }

  /// Clear all history and stats
  Future<void> clearAllHistory() async {
    await _historyBox.clear();
    await _statsBox.clear();
  }

  /// Export history as JSON (for backup/sharing)
  String exportAsJson() {
    final matches = getAllMatches();
    final stats = _statsBox.values.toList();

    return json.encode({
      'exportedAt': DateTime.now().toIso8601String(),
      'matches': matches.map((m) => m.toJson()).toList(),
      'playerStats': stats.map((s) => s.toJson()).toList(),
    });
  }
}
```

### 4.3 History Provider (Riverpod)

```dart
/// Provider for match history repository
final matchHistoryRepositoryProvider = Provider<MatchHistoryRepository>((ref) {
  return MatchHistoryRepository();
});

/// Provider for all matches
final allMatchesProvider = Provider<List<MatchRecord>>((ref) {
  final repo = ref.watch(matchHistoryRepositoryProvider);
  return repo.getAllMatches();
});

/// Provider for recent matches
final recentMatchesProvider =
    Provider.family<List<MatchRecord>, int>((ref, count) {
  final repo = ref.watch(matchHistoryRepositoryProvider);
  return repo.getRecentMatches(count);
});

/// Provider for player stats
final playerStatsProvider =
    Provider.family<PlayerStats?, String>((ref, playerName) {
  final repo = ref.watch(matchHistoryRepositoryProvider);
  return repo.getPlayerStats(playerName);
});

/// Provider for leaderboard
final leaderboardProvider = Provider<List<PlayerStats>>((ref) {
  final repo = ref.watch(matchHistoryRepositoryProvider);
  return repo.getLeaderboard();
});
```

---

## 5. Settings Storage

### 5.1 Settings Repository Implementation

```dart
/// Repository for application settings
class SettingsRepository {
  /// Get the settings box
  Box<GameSettings> get _settingsBox =>
      Hive.box<GameSettings>(HiveBoxes.settings);

  /// Get current settings
  GameSettings getSettings() {
    return _settingsBox.get(HiveKeys.settings) ?? GameSettings.defaults;
  }

  /// Save settings
  Future<void> saveSettings(GameSettings settings) async {
    await _settingsBox.put(HiveKeys.settings, settings);
  }

  /// Update specific setting
  Future<GameSettings> updateSettings(
      GameSettings Function(GameSettings) updater) async {
    final current = getSettings();
    final updated = updater(current);
    await saveSettings(updated);
    return updated;
  }

  /// Reset to defaults
  Future<void> resetToDefaults() async {
    await saveSettings(GameSettings.defaults.copyWith(
      // Preserve some values
      firstLaunchAt: getSettings().firstLaunchAt,
      totalGamesPlayed: getSettings().totalGamesPlayed,
    ));
  }

  /// Update theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    await updateSettings((s) => s.copyWith(themeMode: mode));
  }

  /// Update sound enabled
  Future<void> setSoundEnabled(bool enabled) async {
    await updateSettings((s) => s.copyWith(soundEnabled: enabled));
  }

  /// Update music enabled
  Future<void> setMusicEnabled(bool enabled) async {
    await updateSettings((s) => s.copyWith(musicEnabled: enabled));
  }

  /// Save last used player names
  Future<void> saveLastPlayerNames(String player1, String player2) async {
    await updateSettings((s) => s.copyWith(
          lastPlayer1Name: player1,
          lastPlayer2Name: player2,
        ));
  }

  /// Save last selected deck
  Future<void> saveLastDeck(String deckId) async {
    await updateSettings((s) => s.copyWith(lastSelectedDeckId: deckId));
  }

  /// Mark tutorial as completed
  Future<void> completeTutorial() async {
    await updateSettings((s) => s.copyWith(tutorialCompleted: true));
  }

  /// Increment games played counter
  Future<void> incrementGamesPlayed() async {
    await updateSettings(
        (s) => s.copyWith(totalGamesPlayed: s.totalGamesPlayed + 1));
  }

  /// Record first launch if not already set
  Future<void> recordFirstLaunchIfNeeded() async {
    final settings = getSettings();
    if (settings.firstLaunchAt == null) {
      await updateSettings((s) => s.copyWith(firstLaunchAt: DateTime.now()));
    }
  }
}
```

### 5.2 Settings Provider (Riverpod)

```dart
/// Provider for settings repository
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

/// State notifier for settings
class SettingsNotifier extends StateNotifier<GameSettings> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(_repository.getSettings());

  Future<void> setThemeMode(ThemeMode mode) async {
    await _repository.setThemeMode(mode);
    state = _repository.getSettings();
  }

  Future<void> setSoundEnabled(bool enabled) async {
    await _repository.setSoundEnabled(enabled);
    state = _repository.getSettings();
  }

  Future<void> setMusicEnabled(bool enabled) async {
    await _repository.setMusicEnabled(enabled);
    state = _repository.getSettings();
  }

  Future<void> savePlayerNames(String player1, String player2) async {
    await _repository.saveLastPlayerNames(player1, player2);
    state = _repository.getSettings();
  }

  Future<void> saveLastDeck(String deckId) async {
    await _repository.saveLastDeck(deckId);
    state = _repository.getSettings();
  }

  Future<void> completeTutorial() async {
    await _repository.completeTutorial();
    state = _repository.getSettings();
  }

  Future<void> incrementGamesPlayed() async {
    await _repository.incrementGamesPlayed();
    state = _repository.getSettings();
  }

  Future<void> resetToDefaults() async {
    await _repository.resetToDefaults();
    state = _repository.getSettings();
  }
}

/// Provider for settings state
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, GameSettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repository);
});

/// Provider for theme mode
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(settingsProvider).themeMode;
});

/// Provider for sound enabled
final soundEnabledProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).soundEnabled;
});
```

---

## 6. Repository Interfaces

### 6.1 Content Repository Interface

```dart
/// Abstract interface for content repository
/// Enables easy mocking for tests and future implementations
abstract class IContentRepository {
  /// Load the list of available decks
  Future<List<DeckInfo>> getAvailableDecks();

  /// Load a specific deck by ID
  Future<Deck> getDeck(String deckId);

  /// Get vocabulary items from a deck
  Future<List<ContentItem>> getVocabularyItems(String deckId);

  /// Get phrase items from a deck
  Future<List<ContentItem>> getPhraseItems(String deckId);

  /// Get items by difficulty
  Future<List<ContentItem>> getItemsByDifficulty(String deckId, int difficulty);

  /// Validate a deck
  ContentValidationResult validateDeck(Deck deck);

  /// Clear cache
  Future<void> clearCache();
}

/// Implementation of content repository
class ContentRepository implements IContentRepository {
  final ContentLoader _loader;

  ContentRepository({ContentLoader? loader}) : _loader = loader ?? ContentLoader();

  @override
  Future<List<DeckInfo>> getAvailableDecks() => _loader.loadDeckManifest();

  @override
  Future<Deck> getDeck(String deckId) => _loader.loadDeck(deckId);

  @override
  Future<List<ContentItem>> getVocabularyItems(String deckId) async {
    final deck = await getDeck(deckId);
    return deck.vocabularyItems;
  }

  @override
  Future<List<ContentItem>> getPhraseItems(String deckId) async {
    final deck = await getDeck(deckId);
    return deck.phraseItems;
  }

  @override
  Future<List<ContentItem>> getItemsByDifficulty(
      String deckId, int difficulty) async {
    final deck = await getDeck(deckId);
    return deck.getItemsByDifficulty(difficulty);
  }

  @override
  ContentValidationResult validateDeck(Deck deck) => _loader.validateDeck(deck);

  @override
  Future<void> clearCache() => _loader.clearCache();
}
```

### 6.2 Game Repository Interface

```dart
/// Abstract interface for game state repository
abstract class IGameRepository {
  /// Save current game session
  Future<void> saveSession(GameSession session);

  /// Load current game session (if any)
  Future<GameSession?> loadSession();

  /// Delete current game session
  Future<void> deleteSession();

  /// Check if there's a saved session
  Future<bool> hasActiveSession();

  /// Create a new game session
  GameSession createSession({
    required String deckId,
    required Player player1,
    required Player player2,
  });
}

/// Implementation of game repository
class GameRepository implements IGameRepository {
  @override
  Future<void> saveSession(GameSession session) async {
    final box = await LazyBoxManager.getSessionBox();
    await box.put(HiveKeys.currentSession, session);
  }

  @override
  Future<GameSession?> loadSession() async {
    final box = await LazyBoxManager.getSessionBox();
    return box.get(HiveKeys.currentSession);
  }

  @override
  Future<void> deleteSession() async {
    final box = await LazyBoxManager.getSessionBox();
    await box.delete(HiveKeys.currentSession);
  }

  @override
  Future<bool> hasActiveSession() async {
    final session = await loadSession();
    return session != null && !session.isCompleted;
  }

  @override
  GameSession createSession({
    required String deckId,
    required Player player1,
    required Player player2,
  }) {
    return GameSession.create(
      deckId: deckId,
      player1: player1,
      player2: player2,
    );
  }
}
```

### 6.3 Settings Repository Interface

```dart
/// Abstract interface for settings repository
abstract class ISettingsRepository {
  /// Get current settings
  GameSettings getSettings();

  /// Save settings
  Future<void> saveSettings(GameSettings settings);

  /// Update theme mode
  Future<void> setThemeMode(ThemeMode mode);

  /// Update sound enabled
  Future<void> setSoundEnabled(bool enabled);

  /// Update music enabled
  Future<void> setMusicEnabled(bool enabled);

  /// Save last used player names
  Future<void> saveLastPlayerNames(String player1, String player2);

  /// Save last selected deck
  Future<void> saveLastDeck(String deckId);

  /// Mark tutorial completed
  Future<void> completeTutorial();

  /// Increment games played
  Future<void> incrementGamesPlayed();

  /// Reset to defaults
  Future<void> resetToDefaults();
}

// SettingsRepository already implements this interface
```

### 6.4 History Repository Interface

```dart
/// Abstract interface for match history repository
abstract class IHistoryRepository {
  /// Save a completed match
  Future<void> saveMatch(MatchRecord match);

  /// Get all matches
  List<MatchRecord> getAllMatches();

  /// Get matches for a specific player
  List<MatchRecord> getMatchesForPlayer(String playerName);

  /// Get recent matches
  List<MatchRecord> getRecentMatches(int count);

  /// Get player stats
  PlayerStats? getPlayerStats(String playerName);

  /// Get leaderboard
  List<PlayerStats> getLeaderboard();

  /// Get specific match
  MatchRecord? getMatch(String matchId);

  /// Delete a match
  Future<void> deleteMatch(String matchId);

  /// Clear all history
  Future<void> clearAllHistory();

  /// Export as JSON
  String exportAsJson();
}

// MatchHistoryRepository already implements this interface
```

### 6.5 Dependency Injection Setup

```dart
/// Provider container for repository injection
final contentRepositoryProvider = Provider<IContentRepository>((ref) {
  return ContentRepository();
});

final gameRepositoryProvider = Provider<IGameRepository>((ref) {
  return GameRepository();
});

final settingsRepositoryInterfaceProvider = Provider<ISettingsRepository>((ref) {
  return ref.watch(settingsRepositoryProvider);
});

final historyRepositoryInterfaceProvider = Provider<IHistoryRepository>((ref) {
  return ref.watch(matchHistoryRepositoryProvider);
});
```

### 6.6 Testing Support

```dart
/// Mock implementations for testing

class MockContentRepository implements IContentRepository {
  final List<DeckInfo> _mockDecks;
  final Map<String, Deck> _mockDeckData;

  MockContentRepository({
    List<DeckInfo>? decks,
    Map<String, Deck>? deckData,
  })  : _mockDecks = decks ?? [],
        _mockDeckData = deckData ?? {};

  @override
  Future<List<DeckInfo>> getAvailableDecks() async => _mockDecks;

  @override
  Future<Deck> getDeck(String deckId) async {
    final deck = _mockDeckData[deckId];
    if (deck == null) {
      throw ContentLoadException('Deck not found: $deckId');
    }
    return deck;
  }

  @override
  Future<List<ContentItem>> getVocabularyItems(String deckId) async {
    final deck = await getDeck(deckId);
    return deck.vocabularyItems;
  }

  @override
  Future<List<ContentItem>> getPhraseItems(String deckId) async {
    final deck = await getDeck(deckId);
    return deck.phraseItems;
  }

  @override
  Future<List<ContentItem>> getItemsByDifficulty(
      String deckId, int difficulty) async {
    final deck = await getDeck(deckId);
    return deck.getItemsByDifficulty(difficulty);
  }

  @override
  ContentValidationResult validateDeck(Deck deck) =>
      ContentValidationResult.valid();

  @override
  Future<void> clearCache() async {}
}

class MockSettingsRepository implements ISettingsRepository {
  GameSettings _settings = GameSettings.defaults;

  @override
  GameSettings getSettings() => _settings;

  @override
  Future<void> saveSettings(GameSettings settings) async {
    _settings = settings;
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    _settings = _settings.copyWith(themeMode: mode);
  }

  @override
  Future<void> setSoundEnabled(bool enabled) async {
    _settings = _settings.copyWith(soundEnabled: enabled);
  }

  @override
  Future<void> setMusicEnabled(bool enabled) async {
    _settings = _settings.copyWith(musicEnabled: enabled);
  }

  @override
  Future<void> saveLastPlayerNames(String player1, String player2) async {
    _settings = _settings.copyWith(
      lastPlayer1Name: player1,
      lastPlayer2Name: player2,
    );
  }

  @override
  Future<void> saveLastDeck(String deckId) async {
    _settings = _settings.copyWith(lastSelectedDeckId: deckId);
  }

  @override
  Future<void> completeTutorial() async {
    _settings = _settings.copyWith(tutorialCompleted: true);
  }

  @override
  Future<void> incrementGamesPlayed() async {
    _settings = _settings.copyWith(
      totalGamesPlayed: _settings.totalGamesPlayed + 1,
    );
  }

  @override
  Future<void> resetToDefaults() async {
    _settings = GameSettings.defaults;
  }
}
```

---

## Appendix A: File Structure

```
lib/
  data/
    models/
      language.dart
      language.g.dart
      content_item.dart
      content_item.g.dart
      deck.dart
      deck.g.dart
      player.dart
      player.g.dart
      game_session.dart
      game_session.g.dart
      game_settings.dart
      game_settings.g.dart
      match_history.dart
      match_history.g.dart
    repositories/
      content_repository.dart
      game_repository.dart
      settings_repository.dart
      history_repository.dart
      interfaces/
        i_content_repository.dart
        i_game_repository.dart
        i_settings_repository.dart
        i_history_repository.dart
    providers/
      content_providers.dart
      game_providers.dart
      settings_providers.dart
      history_providers.dart
    services/
      content_loader.dart
      hive_initializer.dart
      hive_boxes.dart
      hive_adapters.dart
    exceptions/
      content_load_exception.dart
```

---

## Appendix B: Package Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  # State management
  flutter_riverpod: ^2.4.0

  # Local storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Code generation
  json_annotation: ^4.8.1
  equatable: ^2.0.5
  uuid: ^4.2.1

dev_dependencies:
  # Code generators
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
  hive_generator: ^2.0.1
```

---

## Appendix C: Hive Annotations for Code Generation

When using `hive_generator`, annotate classes like this:

```dart
import 'package:hive/hive.dart';

part 'game_settings.g.dart';

@HiveType(typeId: HiveTypeIds.gameSettings)
class GameSettings extends HiveObject {
  @HiveField(0)
  final ThemeMode themeMode;

  @HiveField(1)
  final bool soundEnabled;

  // ... etc
}
```

Run code generation:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-26 | Local Storage/Data Agent | Initial document creation |

---

*This document serves as the authoritative reference for data models, storage schemas, and repository interfaces in the Language Duel MVP. All implementation decisions should align with these specifications.*
