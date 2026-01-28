# Phase 4: Grammar & Theory Module - Implementation Plan

**Version:** 1.0
**Created:** 2026-01-28
**Duration:** 4-6 weeks
**Target Languages:** Greek (primary), Catalan (secondary)
**Level:** A1-A2 (CEFR)
**Status:** In Progress

---

## Table of Contents

1. [Overview & Goals](#1-overview--goals)
2. [A1-A2 Greek Grammar Scope](#2-a1-a2-greek-grammar-scope)
3. [Data Models](#3-data-models)
4. [Content Structure](#4-content-structure)
5. [UI/UX Specifications](#5-uiux-specifications)
6. [Exercise Types](#6-exercise-types)
7. [Integration with Existing Systems](#7-integration-with-existing-systems)
8. [Implementation Tasks](#8-implementation-tasks)
9. [Testing Strategy](#9-testing-strategy)
10. [Content Creation Guidelines](#10-content-creation-guidelines)

---

## 0. Notes & Improvements

- **Reuse existing LocalizedString**: use the current `LocalizedString` in `lib/data/models/deck.dart` for all grammar JSON to avoid duplicate models.
- **SRS integration**: either extend `SRSItem` with an optional `itemType` (default `vocabulary`) + migration, or store grammar reviews in a separate box to avoid breaking existing data.
- **Markdown rendering**: lesson explanation assumes markdown; add `flutter_markdown` (or a simple custom renderer) in Sprint 2 UI.
- **Answer tolerance**: exercises should use the same tolerant validation as Spelling Bee (case-insensitive + accent-tolerant + multiple acceptable answers).
- **JSON schema clarity**: standardize `type` fields for grammar exercises (string enum of `GrammarExerciseType.name`).
- **Content reuse**: prioritize examples drawn from existing A1/A2 decks to keep vocabulary aligned.

---

## 0.1 Implementation Progress (Live)

### Foundation (Sprint 1)
- [x] G1-01 Create GrammarLesson model
- [x] G1-02 Create GrammarExplanation model
- [x] G1-03 Create GrammarTable model
- [x] G1-04 Create GrammarExample model
- [x] G1-05 Create GrammarExercise model
- [x] G1-06 Create GrammarProgress model
- [ ] G1-07 Create Hive adapters for grammar models
- [x] G1-08 Create IGrammarRepository interface
- [x] G1-09 Implement GrammarStorage repository
- [x] G1-10 Create grammarLessonsProvider
- [x] G1-11 Create grammarProgressProvider
- [ ] G1-12 Unit tests for models

### Content & UI Shell (Sprint 2)
- [x] G2-01 Create grammar_index.json
- [x] G2-02 Create A1 Lesson: Είμαι (verb to be)
- [ ] G2-03 Create A1 Lesson: Έχω (verb to have)
- [ ] G2-04 Create A1 Lesson: Definite articles
- [x] G2-05 Add grammar routes to go_router
- [x] G2-06 Create GrammarHubScreen
- [x] G2-07 Create LessonListScreen
- [x] G2-08 Update HomeScreen with grammar entry

### Lesson UI (Sprint 3)
- [x] G3-01 Create LessonViewScreen
- [x] G3-02 Create ExplanationTab widget
- [x] G3-03 Create GrammarTableWidget
- [x] G3-04 Create ExamplesTab widget
- [x] G3-05 Create GrammarExampleCard widget
- [x] G3-06 Add romanization toggle
- [ ] G3-07 Widget tests for lesson UI

### Exercise System (Sprint 4)
- [x] G4-01 Create GrammarExerciseController
- [x] G4-02 Create ExerciseScreen shell
- [x] G4-03 Implement FillBlankExercise widget (input flow)
- [x] G4-04 Implement MultipleChoiceExercise widget
- [x] G4-05 Implement ConjugationExercise widget
- [x] G4-06 Implement MatchingExercise widget
- [x] G4-07 Create ExerciseResultsScreen
- [ ] G4-08 Integrate with SRS system
- [ ] G4-09 Exercise controller tests

## 1. Overview & Goals

### 1.1 Problem Statement

The app currently focuses on vocabulary and phrase learning through games, but lacks:
- Explicit grammar instruction and explanations
- Systematic teaching of grammatical rules
- Conjugation practice for verbs
- Article and gender agreement training
- Theory reference for learners

Learners need structured grammar knowledge to progress beyond basic vocabulary memorization.

### 1.2 Goals

| Goal | Success Metric |
|------|----------------|
| Teach A1-A2 Greek grammar systematically | 15+ grammar lessons available |
| Enable verb conjugation mastery | Users can conjugate 10 core verbs |
| Provide interactive grammar exercises | 5+ exercise types implemented |
| Track grammar learning progress | SRS integration for grammar items |
| Support self-paced learning | Lesson + Practice + Review flow |

### 1.3 Target User Stories

```
US-1: As a learner, I want to understand Greek verb conjugations so I can
      form correct sentences.

US-2: As a learner, I want to learn when to use different Greek articles
      (ο, η, το) so I can match them with nouns correctly.

US-3: As a learner, I want reference tables I can consult while practicing
      vocabulary so I remember the patterns.

US-4: As a learner, I want exercises that test my grammar knowledge so I
      can identify and fix my weak areas.

US-5: As a returning learner, I want the app to remind me which grammar
      concepts I need to review based on my performance.
```

### 1.4 Non-Goals (Out of Scope)

- B1+ grammar (complex tenses, subjunctive mood)
- Writing composition assessment
- Speech/pronunciation of grammar
- Detailed linguistic explanations (keep it practical)

---

## 2. A1-A2 Greek Grammar Scope

### 2.1 A1 Grammar Topics (Beginner)

| ID | Topic | Subtopics | Priority |
|----|-------|-----------|----------|
| A1-G01 | **Verb "To Be" (Είμαι)** | Present tense conjugation, usage patterns | P0 |
| A1-G02 | **Verb "To Have" (Έχω)** | Present tense conjugation, possession | P0 |
| A1-G03 | **Definite Articles** | ο/η/το (masc/fem/neut), plural forms | P0 |
| A1-G04 | **Indefinite Articles** | ένας/μία/ένα, when to use | P0 |
| A1-G05 | **Personal Pronouns** | εγώ, εσύ, αυτός/αυτή/αυτό, etc. | P0 |
| A1-G06 | **Noun Gender** | Recognizing masculine/feminine/neuter | P1 |
| A1-G07 | **Basic Adjective Agreement** | Adjective endings matching noun gender | P1 |
| A1-G08 | **Question Words** | Τι, Ποιος, Πού, Πότε, Πώς, Γιατί | P1 |
| A1-G09 | **Negation** | δεν/δε + verb patterns | P1 |
| A1-G10 | **Numbers 1-20** | Cardinal numbers, gender agreement | P2 |

### 2.2 A2 Grammar Topics (Elementary)

| ID | Topic | Subtopics | Priority |
|----|-------|-----------|----------|
| A2-G01 | **Present Tense Verbs** | Regular -ω and -ώ conjugations | P0 |
| A2-G02 | **Common Irregular Verbs** | θέλω, πάω, λέω, τρώω, πίνω | P0 |
| A2-G03 | **Accusative Case** | Direct objects, article changes | P1 |
| A2-G04 | **Genitive Case** | Possession, article changes | P1 |
| A2-G05 | **Possessive Pronouns** | μου, σου, του/της, μας, σας, τους | P1 |
| A2-G06 | **Object Pronouns** | με, σε, τον/την/το, etc. | P1 |
| A2-G07 | **Prepositions** | σε, από, με, για, χωρίς | P2 |
| A2-G08 | **Past Tense Intro** | Simple past of είμαι, έχω | P2 |
| A2-G09 | **Future Tense Intro** | θα + verb construction | P2 |
| A2-G10 | **Numbers 20-100** | Tens and compound numbers | P2 |

### 2.3 Verb Conjugation Tables

#### Είμαι (To Be) - Present Tense

| Person | Singular | Plural |
|--------|----------|--------|
| 1st | είμαι (I am) | είμαστε (we are) |
| 2nd | είσαι (you are) | είστε (you are) |
| 3rd | είναι (he/she/it is) | είναι (they are) |

#### Έχω (To Have) - Present Tense

| Person | Singular | Plural |
|--------|----------|--------|
| 1st | έχω (I have) | έχουμε (we have) |
| 2nd | έχεις (you have) | έχετε (you have) |
| 3rd | έχει (he/she/it has) | έχουν (they have) |

#### Regular -ω Verb Pattern (e.g., γράφω - to write)

| Person | Singular | Plural |
|--------|----------|--------|
| 1st | γράφω | γράφουμε |
| 2nd | γράφεις | γράφετε |
| 3rd | γράφει | γράφουν |

### 2.4 Article System

#### Definite Articles

| Gender | Singular Nom. | Singular Acc. | Plural Nom. | Plural Acc. |
|--------|---------------|---------------|-------------|-------------|
| Masculine | ο | τον | οι | τους |
| Feminine | η | την | οι | τις |
| Neuter | το | το | τα | τα |

#### Indefinite Articles

| Gender | Nominative | Accusative |
|--------|------------|------------|
| Masculine | ένας | έναν |
| Feminine | μία/μια | μία/μια |
| Neuter | ένα | ένα |

---

## 3. Data Models

### 3.1 New Model: GrammarLesson

**File:** `lib/data/models/grammar_lesson.dart`

```dart
import 'package:equatable/equatable.dart';

/// Represents a single grammar lesson with explanation, examples, and exercises
class GrammarLesson extends Equatable {
  final String id;                    // e.g., "a1_g01_verb_to_be"
  final String category;              // e.g., "verb_conjugation"
  final String subcategory;           // e.g., "present_tense"
  final String level;                 // "A1" or "A2"
  final int order;                    // Display order within level
  final LocalizedString title;        // Lesson title
  final LocalizedString description;  // Brief description
  final GrammarExplanation explanation;
  final List<GrammarTable>? tables;   // Conjugation/declension tables
  final List<GrammarExample> examples;
  final List<GrammarExercise> exercises;
  final List<String> prerequisites;   // IDs of lessons to complete first
  final List<String> tags;            // For filtering/searching

  const GrammarLesson({
    required this.id,
    required this.category,
    required this.subcategory,
    required this.level,
    required this.order,
    required this.title,
    required this.description,
    required this.explanation,
    this.tables,
    required this.examples,
    required this.exercises,
    this.prerequisites = const [],
    this.tags = const [],
  });

  @override
  List<Object?> get props => [id, category, level, order];

  factory GrammarLesson.fromJson(Map<String, dynamic> json) {
    // Implementation
  }

  Map<String, dynamic> toJson() {
    // Implementation
  }
}
```

### 3.2 GrammarExplanation Model

```dart
/// The theory/explanation section of a grammar lesson
class GrammarExplanation extends Equatable {
  final LocalizedString content;      // Main explanation text (supports markdown)
  final List<LocalizedString> rules;  // Key rules to remember
  final List<LocalizedString>? tips;  // Learning tips
  final List<LocalizedString>? commonMistakes; // What to avoid

  const GrammarExplanation({
    required this.content,
    required this.rules,
    this.tips,
    this.commonMistakes,
  });

  @override
  List<Object?> get props => [content, rules];
}
```

### 3.3 GrammarTable Model

```dart
/// A conjugation or declension table
class GrammarTable extends Equatable {
  final LocalizedString title;        // e.g., "Present Tense of Είμαι"
  final List<String> columnHeaders;   // e.g., ["Singular", "Plural"]
  final List<String> rowHeaders;      // e.g., ["1st Person", "2nd Person", "3rd Person"]
  final List<List<GrammarTableCell>> cells;
  final String? footnote;             // Optional note below table

  const GrammarTable({
    required this.title,
    required this.columnHeaders,
    required this.rowHeaders,
    required this.cells,
    this.footnote,
  });

  @override
  List<Object?> get props => [title, cells];
}

class GrammarTableCell extends Equatable {
  final String greek;
  final String romanization;
  final String translation;
  final bool isHighlighted;           // For emphasis

  const GrammarTableCell({
    required this.greek,
    required this.romanization,
    required this.translation,
    this.isHighlighted = false,
  });

  @override
  List<Object?> get props => [greek, translation];
}
```

### 3.4 GrammarExample Model

```dart
/// An example sentence demonstrating the grammar concept
class GrammarExample extends Equatable {
  final String id;
  final String greek;
  final String romanization;
  final String catalan;
  final String? englishLiteral;       // Word-for-word translation
  final List<GrammarHighlight>? highlights; // Parts to emphasize

  const GrammarExample({
    required this.id,
    required this.greek,
    required this.romanization,
    required this.catalan,
    this.englishLiteral,
    this.highlights,
  });

  @override
  List<Object?> get props => [id, greek];
}

class GrammarHighlight {
  final int startIndex;
  final int endIndex;
  final String explanation;           // Why this part is highlighted

  const GrammarHighlight({
    required this.startIndex,
    required this.endIndex,
    required this.explanation,
  });
}
```

### 3.5 GrammarExercise Model

```dart
/// An interactive exercise to practice the grammar concept
class GrammarExercise extends Equatable {
  final String id;
  final GrammarExerciseType type;
  final int difficulty;               // 1-3
  final LocalizedString instruction;  // What to do
  final String prompt;                // The question/sentence
  final String? promptRomanization;
  final String correctAnswer;
  final List<String>? options;        // For multiple choice
  final List<String>? acceptableAnswers; // Alternative correct answers
  final LocalizedString? explanation; // Why the answer is correct
  final String? hint;                 // Optional hint

  const GrammarExercise({
    required this.id,
    required this.type,
    required this.difficulty,
    required this.instruction,
    required this.prompt,
    this.promptRomanization,
    required this.correctAnswer,
    this.options,
    this.acceptableAnswers,
    this.explanation,
    this.hint,
  });

  @override
  List<Object?> get props => [id, type, prompt];
}

enum GrammarExerciseType {
  fillBlank,          // Complete the sentence
  multipleChoice,     // Select correct option
  conjugation,        // Conjugate the verb
  transformation,     // Change form (e.g., singular to plural)
  matching,           // Match items
  errorCorrection,    // Find and fix the error
  translation,        // Translate with grammar focus
  tableCompletion,    // Fill in conjugation table
}
```

### 3.6 GrammarProgress Model

```dart
/// Tracks user progress through grammar lessons
class GrammarProgress extends Equatable {
  final String lessonId;
  final bool isUnlocked;
  final bool explanationRead;
  final int exercisesCompleted;
  final int exercisesTotal;
  final double accuracy;              // 0.0 to 1.0
  final DateTime? lastPracticed;
  final int reviewCount;
  final GrammarMasteryLevel masteryLevel;

  const GrammarProgress({
    required this.lessonId,
    this.isUnlocked = false,
    this.explanationRead = false,
    this.exercisesCompleted = 0,
    this.exercisesTotal = 0,
    this.accuracy = 0.0,
    this.lastPracticed,
    this.reviewCount = 0,
    this.masteryLevel = GrammarMasteryLevel.notStarted,
  });

  @override
  List<Object?> get props => [lessonId, masteryLevel];
}

enum GrammarMasteryLevel {
  notStarted,         // Haven't begun
  learning,           // Read explanation, starting exercises
  practicing,         // Working through exercises
  reviewing,          // Completed once, in review cycle
  mastered,           // High accuracy, infrequent review needed
}
```

---

## 4. Content Structure

### 4.1 File Organization

```
assets/
  data/
    grammar/
      grammar_index.json              # Index of all lessons
      a1/
        a1_g01_verb_to_be.json        # Είμαι lesson
        a1_g02_verb_to_have.json      # Έχω lesson
        a1_g03_definite_articles.json
        a1_g04_indefinite_articles.json
        a1_g05_personal_pronouns.json
        a1_g06_noun_gender.json
        a1_g07_adjective_agreement.json
        a1_g08_question_words.json
        a1_g09_negation.json
        a1_g10_numbers_1_20.json
      a2/
        a2_g01_present_verbs.json
        a2_g02_irregular_verbs.json
        ... (more lessons)
```

### 4.2 Grammar Index JSON

**File:** `assets/data/grammar/grammar_index.json`

```json
{
  "version": "1.0.0",
  "lastUpdated": "2026-01-28",
  "levels": [
    {
      "id": "A1",
      "name": {
        "en": "A1 - Beginner",
        "el": "A1 - Αρχάριος",
        "ca": "A1 - Principiant"
      },
      "lessons": [
        {
          "id": "a1_g01_verb_to_be",
          "file": "a1/a1_g01_verb_to_be.json",
          "category": "verb_conjugation",
          "order": 1,
          "prerequisites": []
        },
        {
          "id": "a1_g02_verb_to_have",
          "file": "a1/a1_g02_verb_to_have.json",
          "category": "verb_conjugation",
          "order": 2,
          "prerequisites": ["a1_g01_verb_to_be"]
        },
        {
          "id": "a1_g03_definite_articles",
          "file": "a1/a1_g03_definite_articles.json",
          "category": "articles",
          "order": 3,
          "prerequisites": []
        }
      ]
    },
    {
      "id": "A2",
      "name": {
        "en": "A2 - Elementary",
        "el": "A2 - Στοιχειώδης",
        "ca": "A2 - Elemental"
      },
      "lessons": [
        // A2 lessons
      ]
    }
  ],
  "categories": [
    {
      "id": "verb_conjugation",
      "name": { "en": "Verb Conjugation", "el": "Κλίση Ρημάτων", "ca": "Conjugació de Verbs" },
      "icon": "verb_icon"
    },
    {
      "id": "articles",
      "name": { "en": "Articles", "el": "Άρθρα", "ca": "Articles" },
      "icon": "article_icon"
    },
    {
      "id": "pronouns",
      "name": { "en": "Pronouns", "el": "Αντωνυμίες", "ca": "Pronoms" },
      "icon": "pronoun_icon"
    },
    {
      "id": "nouns",
      "name": { "en": "Nouns & Gender", "el": "Ουσιαστικά & Γένος", "ca": "Substantius i Gènere" },
      "icon": "noun_icon"
    },
    {
      "id": "adjectives",
      "name": { "en": "Adjectives", "el": "Επίθετα", "ca": "Adjectius" },
      "icon": "adjective_icon"
    },
    {
      "id": "syntax",
      "name": { "en": "Sentence Structure", "el": "Σύνταξη", "ca": "Sintaxi" },
      "icon": "syntax_icon"
    }
  ]
}
```

### 4.3 Sample Lesson JSON

**File:** `assets/data/grammar/a1/a1_g01_verb_to_be.json`

```json
{
  "id": "a1_g01_verb_to_be",
  "category": "verb_conjugation",
  "subcategory": "present_tense",
  "level": "A1",
  "order": 1,
  "title": {
    "en": "The Verb \"To Be\" (Είμαι)",
    "el": "Το Ρήμα «Είμαι»",
    "ca": "El Verb \"Ser\" (Είμαι)"
  },
  "description": {
    "en": "Learn to conjugate the most essential Greek verb",
    "el": "Μάθε να κλίνεις το πιο βασικό ελληνικό ρήμα",
    "ca": "Aprèn a conjugar el verb grec més essencial"
  },
  "explanation": {
    "content": {
      "en": "The verb **είμαι** (to be) is one of the most important verbs in Greek. Unlike many Greek verbs, it's irregular and must be memorized. It's used to:\n\n- Describe who or what someone/something is\n- Express states and conditions\n- Indicate location\n- Form certain tenses with other verbs",
      "el": "Το ρήμα **είμαι** είναι ένα από τα πιο σημαντικά ρήματα στα ελληνικά...",
      "ca": "El verb **είμαι** (ser) és un dels verbs més importants en grec..."
    },
    "rules": [
      {
        "en": "The 3rd person singular and plural are the same: είναι",
        "el": "Το τρίτο πρόσωπο ενικού και πληθυντικού είναι ίδιο: είναι",
        "ca": "La 3a persona singular i plural són iguals: είναι"
      },
      {
        "en": "Greek doesn't require subject pronouns - the verb ending shows who is speaking",
        "el": "Τα ελληνικά δεν απαιτούν υποκείμενο - η κατάληξη δείχνει ποιος μιλάει",
        "ca": "El grec no requereix pronoms subjecte - la terminació mostra qui parla"
      },
      {
        "en": "Use είμαι + adjective to describe states: Είμαι χαρούμενος (I am happy)",
        "el": "Χρησιμοποίησε είμαι + επίθετο για καταστάσεις: Είμαι χαρούμενος",
        "ca": "Utilitza είμαι + adjectiu per descriure estats: Είμαι χαρούμενος (Estic content)"
      }
    ],
    "tips": [
      {
        "en": "Practice by describing yourself and others: Είμαι μαθητής (I am a student)",
        "el": "Εξάσκησε περιγράφοντας τον εαυτό σου: Είμαι μαθητής",
        "ca": "Practica descrivint-te a tu mateix: Είμαι μαθητής (Sóc estudiant)"
      }
    ],
    "commonMistakes": [
      {
        "en": "Don't confuse είναι (is/are) with έχει (has) - they sound similar to beginners",
        "el": "Μη μπερδεύεις το είναι με το έχει",
        "ca": "No confonguis είναι (és/són) amb έχει (té)"
      }
    ]
  },
  "tables": [
    {
      "title": {
        "en": "Present Tense of Είμαι",
        "el": "Ενεστώτας του Είμαι",
        "ca": "Present d'Είμαι"
      },
      "columnHeaders": ["Singular", "Plural"],
      "rowHeaders": ["1st Person", "2nd Person", "3rd Person"],
      "cells": [
        [
          {"greek": "είμαι", "romanization": "íme", "translation": "I am"},
          {"greek": "είμαστε", "romanization": "ímaste", "translation": "we are"}
        ],
        [
          {"greek": "είσαι", "romanization": "íse", "translation": "you are"},
          {"greek": "είστε", "romanization": "íste", "translation": "you are (pl/formal)"}
        ],
        [
          {"greek": "είναι", "romanization": "íne", "translation": "he/she/it is"},
          {"greek": "είναι", "romanization": "íne", "translation": "they are", "isHighlighted": true}
        ]
      ],
      "footnote": "Note: 3rd person singular and plural are identical"
    }
  ],
  "examples": [
    {
      "id": "ex_001",
      "greek": "Είμαι μαθητής.",
      "romanization": "Íme mathitís.",
      "catalan": "Sóc estudiant.",
      "englishLiteral": "Am student.",
      "highlights": [
        {"startIndex": 0, "endIndex": 5, "explanation": "The verb 'to be' conjugated for I"}
      ]
    },
    {
      "id": "ex_002",
      "greek": "Εσύ είσαι από την Ελλάδα;",
      "romanization": "Esí íse apó tin Elláda?",
      "catalan": "Tu ets de Grècia?",
      "englishLiteral": "You are from the Greece?"
    },
    {
      "id": "ex_003",
      "greek": "Αυτοί είναι φίλοι μου.",
      "romanization": "Aftí íne fíli mu.",
      "catalan": "Ells són amics meus.",
      "englishLiteral": "They are friends my."
    },
    {
      "id": "ex_004",
      "greek": "Πού είστε;",
      "romanization": "Pu íste?",
      "catalan": "On sou?",
      "englishLiteral": "Where are-you (plural)?"
    }
  ],
  "exercises": [
    {
      "id": "a1_g01_ex01",
      "type": "fillBlank",
      "difficulty": 1,
      "instruction": {
        "en": "Complete with the correct form of είμαι",
        "el": "Συμπλήρωσε με τη σωστή μορφή του είμαι",
        "ca": "Completa amb la forma correcta d'είμαι"
      },
      "prompt": "Εγώ ___ δάσκαλος.",
      "promptRomanization": "Egó ___ dáskalos.",
      "correctAnswer": "είμαι",
      "acceptableAnswers": ["ειμαι"],
      "explanation": {
        "en": "With εγώ (I), we use είμαι",
        "el": "Με το εγώ χρησιμοποιούμε είμαι",
        "ca": "Amb εγώ (jo), utilitzem είμαι"
      },
      "hint": "First person singular"
    },
    {
      "id": "a1_g01_ex02",
      "type": "multipleChoice",
      "difficulty": 1,
      "instruction": {
        "en": "Select the correct verb form",
        "el": "Επίλεξε τη σωστή μορφή του ρήματος",
        "ca": "Selecciona la forma verbal correcta"
      },
      "prompt": "Αυτή ___ γιατρός.",
      "promptRomanization": "Aftí ___ yatrós.",
      "correctAnswer": "είναι",
      "options": ["είμαι", "είσαι", "είναι", "είμαστε"],
      "explanation": {
        "en": "Αυτή (she) requires the 3rd person singular: είναι",
        "el": "Το αυτή απαιτεί τρίτο πρόσωπο ενικού: είναι",
        "ca": "Αυτή (ella) requereix la 3a persona singular: είναι"
      }
    },
    {
      "id": "a1_g01_ex03",
      "type": "conjugation",
      "difficulty": 2,
      "instruction": {
        "en": "Conjugate είμαι for the given subject",
        "el": "Κλίνε το είμαι για το δοσμένο υποκείμενο",
        "ca": "Conjuga είμαι per al subjecte donat"
      },
      "prompt": "εμείς",
      "correctAnswer": "είμαστε",
      "acceptableAnswers": ["ειμαστε"],
      "explanation": {
        "en": "εμείς (we) → είμαστε",
        "el": "εμείς → είμαστε",
        "ca": "εμείς (nosaltres) → είμαστε"
      }
    },
    {
      "id": "a1_g01_ex04",
      "type": "matching",
      "difficulty": 1,
      "instruction": {
        "en": "Match the subject pronoun with the correct verb form",
        "el": "Αντιστοίχισε την αντωνυμία με τη σωστή μορφή ρήματος",
        "ca": "Relaciona el pronom subjecte amb la forma verbal correcta"
      },
      "prompt": "Match: εγώ, εσύ, αυτός, εμείς, αυτοί",
      "correctAnswer": "εγώ→είμαι, εσύ→είσαι, αυτός→είναι, εμείς→είμαστε, αυτοί→είναι",
      "options": ["είμαι", "είσαι", "είναι", "είμαστε", "είστε"]
    },
    {
      "id": "a1_g01_ex05",
      "type": "translation",
      "difficulty": 2,
      "instruction": {
        "en": "Translate to Greek (focus on the verb)",
        "el": "Μετάφρασε στα ελληνικά (επικεντρώσου στο ρήμα)",
        "ca": "Tradueix al grec (centra't en el verb)"
      },
      "prompt": "We are students.",
      "correctAnswer": "Είμαστε μαθητές.",
      "acceptableAnswers": ["Εμείς είμαστε μαθητές.", "Ειμαστε μαθητες"],
      "explanation": {
        "en": "We = εμείς/implied → είμαστε; students = μαθητές",
        "el": "We = εμείς → είμαστε; students = μαθητές",
        "ca": "We = nosaltres → είμαστε; students = μαθητές"
      }
    },
    {
      "id": "a1_g01_ex06",
      "type": "errorCorrection",
      "difficulty": 3,
      "instruction": {
        "en": "Find and correct the error in this sentence",
        "el": "Βρες και διόρθωσε το λάθος σε αυτή την πρόταση",
        "ca": "Troba i corregeix l'error en aquesta frase"
      },
      "prompt": "Εσύ είμαι χαρούμενος.",
      "promptRomanization": "Esí íme charúmenos.",
      "correctAnswer": "Εσύ είσαι χαρούμενος.",
      "explanation": {
        "en": "With εσύ (you), we need είσαι, not είμαι",
        "el": "Με το εσύ χρειαζόμαστε είσαι, όχι είμαι",
        "ca": "Amb εσύ (tu), necessitem είσαι, no είμαι"
      }
    },
    {
      "id": "a1_g01_ex07",
      "type": "tableCompletion",
      "difficulty": 3,
      "instruction": {
        "en": "Complete the conjugation table for είμαι",
        "el": "Συμπλήρωσε τον πίνακα κλίσης του είμαι",
        "ca": "Completa la taula de conjugació d'είμαι"
      },
      "prompt": "Fill in: 1st sing: ?, 2nd sing: ?, 3rd sing: ?, 1st pl: ?, 2nd pl: ?, 3rd pl: ?",
      "correctAnswer": "είμαι, είσαι, είναι, είμαστε, είστε, είναι"
    }
  ],
  "prerequisites": [],
  "tags": ["verb", "to-be", "essential", "irregular", "present-tense"]
}
```

---

## 5. UI/UX Specifications

### 5.1 New Screens

| Screen | Route | Description |
|--------|-------|-------------|
| Grammar Hub | `/grammar` | Entry point with level/category overview |
| Lesson List | `/grammar/level/:level` | Lessons for A1 or A2 |
| Lesson View | `/grammar/lesson/:id` | Full lesson with explanation, tables, examples |
| Exercise Mode | `/grammar/lesson/:id/practice` | Interactive exercises |
| Conjugation Drill | `/grammar/conjugation` | Quick conjugation practice |
| Grammar Reference | `/grammar/reference` | Quick lookup tables |

### 5.2 Screen Wireframes

#### 5.2.1 Grammar Hub Screen

```
+-------------------------------------------------------------+
|  [<]                   GRAMMAR & THEORY                     |
+-------------------------------------------------------------+
|                                                             |
|  Your Progress                                              |
|  +-----------------------------------------------------+   |
|  |  [=========>          ] 35% Complete                |   |
|  |  5 of 14 lessons mastered                           |   |
|  +-----------------------------------------------------+   |
|                                                             |
|  +-- A1 - Beginner ----------------------------------+     |
|  |                                                    |     |
|  |  [Verb Icon] Verb Conjugation          3/4        |     |
|  |    - Είμαι (To Be)           [Mastered checkmark] |     |
|  |    - Έχω (To Have)           [In Progress]        |     |
|  |    - Regular Verbs           [Locked]             |     |
|  |                                                    |     |
|  |  [Article Icon] Articles               0/2        |     |
|  |    - Definite Articles       [Not Started]        |     |
|  |    - Indefinite Articles     [Locked]             |     |
|  |                                                    |     |
|  +----------------------------------------------------+     |
|                                                             |
|  +-- A2 - Elementary --------------------------------+     |
|  |  [Locked] Complete A1 to unlock                   |     |
|  +----------------------------------------------------+     |
|                                                             |
|  Quick Actions                                              |
|  +-------------------+  +-------------------+               |
|  | Conjugation Drill |  | Grammar Reference |               |
|  +-------------------+  +-------------------+               |
|                                                             |
+-------------------------------------------------------------+
```

#### 5.2.2 Lesson View Screen

```
+-------------------------------------------------------------+
|  [<]              THE VERB "TO BE" (Είμαι)                  |
+-------------------------------------------------------------+
|                                                             |
|  [Tab: Explanation] [Tab: Tables] [Tab: Examples]           |
|  =========================================================  |
|                                                             |
|  The verb **είμαι** (to be) is one of the most             |
|  important verbs in Greek. Unlike many Greek verbs,        |
|  it's irregular and must be memorized.                     |
|                                                             |
|  KEY RULES                                                  |
|  +-----------------------------------------------------+   |
|  | 1. The 3rd person singular and plural are the same  |   |
|  | 2. Greek doesn't require subject pronouns           |   |
|  | 3. Use είμαι + adjective to describe states         |   |
|  +-----------------------------------------------------+   |
|                                                             |
|  TIP: Practice by describing yourself!                     |
|                                                             |
|  COMMON MISTAKES                                            |
|  - Don't confuse είναι with έχει                           |
|                                                             |
|                                                             |
|  +-----------------------------------------------------+   |
|  |              [Start Exercises (7)]                  |   |
|  +-----------------------------------------------------+   |
|                                                             |
+-------------------------------------------------------------+
```

#### 5.2.3 Exercise Screen

```
+-------------------------------------------------------------+
|  [<]              EXERCISE 3 OF 7              [Pause]      |
+-------------------------------------------------------------+
|                                                             |
|  Progress: [====>                  ] 2/7                    |
|                                                             |
|  Complete with the correct form of είμαι:                   |
|                                                             |
|  +-----------------------------------------------------+   |
|  |                                                     |   |
|  |         Εγώ _______ δάσκαλος.                       |   |
|  |         (Egó _______ dáskalos.)                     |   |
|  |                                                     |   |
|  +-----------------------------------------------------+   |
|                                                             |
|  +-----------------------------------------------------+   |
|  |  Type your answer:                                  |   |
|  |  [________________________]                         |   |
|  |                                                     |   |
|  |  [ε] [ί] [α] [μ] [Special Greek Characters]        |   |
|  +-----------------------------------------------------+   |
|                                                             |
|  [Hint]                            [Check Answer]           |
|                                                             |
+-------------------------------------------------------------+
```

#### 5.2.4 Conjugation Table Tab

```
+-------------------------------------------------------------+
|  [Tab: Explanation] [Tab: Tables] [Tab: Examples]           |
|                     ==========                              |
|                                                             |
|  PRESENT TENSE OF ΕΙΜΑΙ                                     |
|  +-------------------------+-------------------------+      |
|  |                         | Singular    | Plural    |      |
|  +-------------------------+-------------+-----------+      |
|  | 1st Person              | είμαι       | είμαστε   |      |
|  |                         | (íme)       | (ímaste)  |      |
|  |                         | I am        | we are    |      |
|  +-------------------------+-------------+-----------+      |
|  | 2nd Person              | είσαι       | είστε     |      |
|  |                         | (íse)       | (íste)    |      |
|  |                         | you are     | you are   |      |
|  +-------------------------+-------------+-----------+      |
|  | 3rd Person              | είναι       | είναι*    |      |
|  |                         | (íne)       | (íne)     |      |
|  |                         | he/she is   | they are  |      |
|  +-------------------------+-------------+-----------+      |
|                                                             |
|  * Note: 3rd person singular and plural are identical       |
|                                                             |
|  [Copy Table]                    [Practice This Table]      |
|                                                             |
+-------------------------------------------------------------+
```

### 5.3 Navigation Flow

```
Home Screen
    |
    +---> [Grammar & Theory] ---> Grammar Hub (/grammar)
                                      |
                                      +---> Lesson List (by level)
                                      |         |
                                      |         +---> Lesson View
                                      |                   |
                                      |                   +---> [Explanation Tab]
                                      |                   +---> [Tables Tab]
                                      |                   +---> [Examples Tab]
                                      |                   +---> [Start Exercises]
                                      |                              |
                                      |                              +---> Exercise Mode
                                      |                                        |
                                      |                                        +---> Results
                                      |
                                      +---> Conjugation Drill (quick practice)
                                      |
                                      +---> Grammar Reference (lookup)
```

### 5.4 Home Screen Addition

Add Grammar entry point after Solo Practice button:

```dart
// In home_screen.dart
OutlinedButton(
  onPressed: () => context.push(grammarRoute),
  child: Column(
    children: [
      const Text('Grammar & Theory'),
      Text(
        '5/14 lessons completed',
        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
      ),
    ],
  ),
),
```

---

## 6. Exercise Types

### 6.1 Fill in the Blank

**Purpose:** Test recall of specific forms
**Input:** Text field with Greek keyboard support
**Validation:** Exact match or acceptable alternatives (accent tolerance)

```
Prompt: "Εσύ ___ από την Ελλάδα."
Answer: "είσαι"
```

### 6.2 Multiple Choice

**Purpose:** Recognition of correct forms
**Input:** Tap to select from 4 options
**Feedback:** Immediate with explanation

```
Prompt: "Αυτοί ___ φίλοι."
Options: [είμαι] [είσαι] [είναι] [είμαστε]
Correct: είναι
```

### 6.3 Conjugation Drill

**Purpose:** Rapid conjugation practice
**Input:** Given pronoun, type verb form
**Mode:** Timed or untimed

```
Prompt: "είμαι → εμείς"
Answer: "είμαστε"
```

### 6.4 Transformation

**Purpose:** Practice changing forms
**Types:** Singular↔Plural, Person changes

```
Prompt: "Change to plural: Είμαι χαρούμενος."
Answer: "Είμαστε χαρούμενοι."
```

### 6.5 Matching

**Purpose:** Associate related items
**Format:** Drag-drop or tap pairs

```
Match pronouns to verb forms:
εγώ -------- είμαι
εσύ -------- είσαι
αυτός ------ είναι
```

### 6.6 Error Correction

**Purpose:** Identify and fix grammatical errors
**Input:** Rewrite the sentence correctly

```
Prompt: "Εσύ είμαι χαρούμενος." (incorrect)
Answer: "Εσύ είσαι χαρούμενος."
```

### 6.7 Translation

**Purpose:** Apply grammar in context
**Direction:** Catalan/English → Greek

```
Prompt: "We are students." (Translate to Greek)
Answer: "Είμαστε μαθητές."
```

### 6.8 Table Completion

**Purpose:** Test systematic knowledge
**Input:** Fill in missing cells of conjugation table

```
Complete the table:
        | Singular | Plural
1st     | ?        | είμαστε
2nd     | είσαι    | ?
3rd     | ?        | είναι
```

---

## 7. Integration with Existing Systems

### 7.1 SRS Integration

Extend the existing SRS system to track grammar exercises:

```dart
// Update SRSItem model to support grammar
class SRSItem {
  // Existing fields...
  final String itemId;      // Can be grammar_exercise_id
  final String deckId;      // "grammar_a1" or "grammar_a2"
  final String itemType;    // NEW: "vocabulary", "phrase", "grammar"
  // ... SRS algorithm fields
}

// New provider for grammar SRS items
final grammarSrsItemsProvider = Provider<List<SRSItem>>((ref) {
  final items = ref.watch(srsItemsProvider).value ?? {};
  return items.values
      .where((item) => item.itemType == 'grammar')
      .toList();
});

final dueGrammarExercisesProvider = Provider<List<SRSItem>>((ref) {
  final items = ref.watch(grammarSrsItemsProvider);
  return items.where((item) => item.isDue).toList();
});
```

### 7.2 Progress Tracking

```dart
// New provider for grammar progress
final grammarProgressProvider =
    StateNotifierProvider<GrammarProgressController, Map<String, GrammarProgress>>(
  (ref) => GrammarProgressController(ref.read(grammarStorageProvider)),
);

// Computed progress stats
final grammarStatsProvider = Provider<GrammarStats>((ref) {
  final progress = ref.watch(grammarProgressProvider);

  final totalLessons = progress.length;
  final completed = progress.values.where((p) =>
      p.masteryLevel == GrammarMasteryLevel.mastered).length;
  final inProgress = progress.values.where((p) =>
      p.masteryLevel == GrammarMasteryLevel.practicing).length;

  return GrammarStats(
    totalLessons: totalLessons,
    completedLessons: completed,
    inProgressLessons: inProgress,
    overallMastery: totalLessons > 0 ? completed / totalLessons : 0,
  );
});
```

### 7.3 Storage

```dart
// Hive adapter for grammar progress
@HiveType(typeId: 27)
class GrammarProgressAdapter extends TypeAdapter<GrammarProgress> {
  // Implementation
}

// Repository interface
abstract class IGrammarRepository {
  Map<String, GrammarProgress> loadAllProgress();
  Future<void> saveProgress(GrammarProgress progress);
  List<GrammarLesson> loadLessons(String level);
  GrammarLesson? loadLesson(String id);
}
```

### 7.4 Learner Profile Extension

```dart
// Add to LearnerProfile
class LearnerProfile {
  // Existing fields...
  final int grammarLessonsCompleted;      // NEW
  final int grammarExercisesCompleted;    // NEW
  final double grammarAccuracy;           // NEW
  final Map<String, int> grammarCategoryProgress; // NEW: category → lessons done
}
```

---

## 8. Implementation Tasks

### 8.1 Sprint 1: Foundation (Week 1)

| ID | Task | Estimate | Priority |
|----|------|----------|----------|
| G1-01 | Create GrammarLesson model | 2h | P0 |
| G1-02 | Create GrammarExplanation model | 1h | P0 |
| G1-03 | Create GrammarTable model | 1h | P0 |
| G1-04 | Create GrammarExample model | 1h | P0 |
| G1-05 | Create GrammarExercise model | 2h | P0 |
| G1-06 | Create GrammarProgress model | 1h | P0 |
| G1-07 | Create Hive adapters for grammar models | 2h | P0 |
| G1-08 | Create IGrammarRepository interface | 1h | P0 |
| G1-09 | Implement GrammarStorage repository | 3h | P0 |
| G1-10 | Create grammarLessonsProvider | 2h | P0 |
| G1-11 | Create grammarProgressProvider | 2h | P0 |
| G1-12 | Unit tests for models | 3h | P1 |

**Sprint 1 Total: ~21 hours**

### 8.2 Sprint 2: Content & UI Shell (Week 2)

| ID | Task | Estimate | Priority |
|----|------|----------|----------|
| G2-01 | Create grammar_index.json | 2h | P0 |
| G2-02 | Create A1 Lesson: Είμαι (verb to be) | 4h | P0 |
| G2-03 | Create A1 Lesson: Έχω (verb to have) | 3h | P0 |
| G2-04 | Create A1 Lesson: Definite articles | 3h | P0 |
| G2-05 | Add grammar routes to go_router | 1h | P0 |
| G2-06 | Create GrammarHubScreen | 4h | P0 |
| G2-07 | Create LessonListScreen | 2h | P0 |
| G2-08 | Update HomeScreen with grammar entry | 1h | P0 |

**Sprint 2 Total: ~20 hours**

### 8.3 Sprint 3: Lesson UI (Week 3)

| ID | Task | Estimate | Priority |
|----|------|----------|----------|
| G3-01 | Create LessonViewScreen | 4h | P0 |
| G3-02 | Create ExplanationTab widget | 2h | P0 |
| G3-03 | Create GrammarTableWidget | 3h | P0 |
| G3-04 | Create ExamplesTab widget | 2h | P0 |
| G3-05 | Create GrammarExampleCard widget | 2h | P1 |
| G3-06 | Add romanization toggle | 1h | P1 |
| G3-07 | Widget tests for lesson UI | 3h | P1 |

**Sprint 3 Total: ~17 hours**

### 8.4 Sprint 4: Exercise System (Week 4)

| ID | Task | Estimate | Priority |
|----|------|----------|----------|
| G4-01 | Create GrammarExerciseController | 4h | P0 |
| G4-02 | Create ExerciseScreen shell | 3h | P0 |
| G4-03 | Implement FillBlankExercise widget | 3h | P0 |
| G4-04 | Implement MultipleChoiceExercise widget | 2h | P0 |
| G4-05 | Implement ConjugationExercise widget | 3h | P0 |
| G4-06 | Implement MatchingExercise widget | 3h | P1 |
| G4-07 | Create ExerciseResultsScreen | 2h | P0 |
| G4-08 | Integrate with SRS system | 3h | P0 |
| G4-09 | Exercise controller tests | 3h | P1 |

**Sprint 4 Total: ~26 hours**

### 8.5 Sprint 5: Polish & More Content (Weeks 5-6)

| ID | Task | Estimate | Priority |
|----|------|----------|----------|
| G5-01 | Implement ErrorCorrectionExercise | 2h | P1 |
| G5-02 | Implement TranslationExercise | 2h | P1 |
| G5-03 | Implement TableCompletionExercise | 3h | P1 |
| G5-04 | Create ConjugationDrillScreen | 4h | P1 |
| G5-05 | Create GrammarReferenceScreen | 3h | P2 |
| G5-06 | Create remaining A1 lessons (5 more) | 15h | P1 |
| G5-07 | Create A2 lessons (5 initial) | 15h | P2 |
| G5-08 | Add animations and polish | 4h | P2 |
| G5-09 | Integration tests | 4h | P1 |
| G5-10 | Documentation | 2h | P2 |

**Sprint 5 Total: ~54 hours**

### 8.6 Summary

| Sprint | Focus | Hours | Cumulative |
|--------|-------|-------|------------|
| 1 | Foundation (Models, Storage) | 21h | 21h |
| 2 | Content & UI Shell | 20h | 41h |
| 3 | Lesson UI | 17h | 58h |
| 4 | Exercise System | 26h | 84h |
| 5 | Polish & Content | 54h | 138h |

**Total Estimated: ~138 hours (4-6 weeks)**

---

## 9. Testing Strategy

### 9.1 Unit Tests

```dart
// test/grammar_lesson_test.dart
void main() {
  group('GrammarLesson', () {
    test('fromJson parses correctly', () {
      final json = {...};
      final lesson = GrammarLesson.fromJson(json);
      expect(lesson.id, 'a1_g01_verb_to_be');
      expect(lesson.exercises.length, 7);
    });

    test('exercises have valid types', () {
      final lesson = GrammarLesson.fromJson(sampleJson);
      for (final ex in lesson.exercises) {
        expect(GrammarExerciseType.values, contains(ex.type));
      }
    });
  });
}

// test/grammar_exercise_controller_test.dart
void main() {
  group('GrammarExerciseController', () {
    test('submitAnswer scores correctly', () {
      final controller = GrammarExerciseController(exercises);
      controller.submitAnswer('είμαι');
      expect(controller.state.isCorrect, true);
      expect(controller.state.score, greaterThan(0));
    });

    test('acceptable answers are accepted', () {
      final controller = GrammarExerciseController(exercises);
      controller.submitAnswer('ειμαι'); // without accent
      expect(controller.state.isCorrect, true);
    });
  });
}
```

### 9.2 Widget Tests

```dart
// test/grammar_hub_screen_test.dart
void main() {
  testWidgets('Grammar hub shows progress', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          grammarProgressProvider.overrideWithValue({
            'a1_g01': GrammarProgress(lessonId: 'a1_g01', masteryLevel: GrammarMasteryLevel.mastered),
          }),
        ],
        child: const MaterialApp(home: GrammarHubScreen()),
      ),
    );

    expect(find.text('1/14 lessons completed'), findsOneWidget);
  });
}
```

### 9.3 Manual Testing Checklist

- [ ] Grammar hub loads with correct progress
- [ ] Lesson list shows prerequisites correctly
- [ ] Locked lessons cannot be accessed
- [ ] Lesson explanation renders markdown
- [ ] Conjugation tables display correctly
- [ ] Examples show Greek, romanization, and translation
- [ ] Fill-blank exercises accept correct answers
- [ ] Multiple choice highlights selection
- [ ] Matching exercises work with drag-drop/tap
- [ ] Exercise results update progress
- [ ] SRS schedules review for weak exercises
- [ ] Progress persists after app restart

---

## 10. Content Creation Guidelines

### 10.1 Lesson Writing Standards

1. **Explanations** should be:
   - Concise (200-400 words max)
   - Practical, not linguistic theory
   - Include 3-5 key rules
   - Provide 1-2 learning tips
   - Warn about 1-2 common mistakes

2. **Examples** should:
   - Use vocabulary from existing decks when possible
   - Progress from simple to complex
   - Include romanization for all Greek
   - Highlight the grammar point being taught

3. **Exercises** should:
   - Start easy (difficulty 1) and progress
   - Include 6-10 exercises per lesson
   - Cover all presented forms
   - Provide explanations for answers

### 10.2 Greek Text Standards

- Always include romanization for learners
- Use standard Modern Greek (Demotic)
- Accent marks are required (but tolerate missing in answers)
- Use appropriate register (formal/informal as marked)

### 10.3 Difficulty Guidelines

| Difficulty | Description | Example |
|------------|-------------|---------|
| 1 (Easy) | Direct application of one rule | "Εγώ ___ δάσκαλος" |
| 2 (Medium) | Choose between similar forms | "Αυτοί ___ φίλοι" (είναι vs έχουν) |
| 3 (Hard) | Multiple rules or transformation | Error correction, full translations |

---

## 11. Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Lessons created | 15+ (10 A1, 5 A2) | Content count |
| Exercises per lesson | 6-10 | Content audit |
| Exercise completion rate | >70% | Analytics |
| Average accuracy | >75% after 3 attempts | Progress tracking |
| Grammar section usage | >30% of users try it | Analytics |
| Retention at 7 days | >60% for grammar users | Cohort analysis |

---

## 12. Future Extensions (Out of Scope)

- Audio pronunciation of examples
- Grammar in duel mode (grammar battle)
- User-generated grammar notes
- Spaced writing practice
- B1 grammar topics
- Other languages (Catalan grammar for Greek speakers)

---

## Appendix A: File Structure

```
lib/
  data/
    models/
      grammar_lesson.dart           # GrammarLesson, GrammarExplanation
      grammar_exercise.dart         # GrammarExercise, GrammarExerciseType
      grammar_progress.dart         # GrammarProgress, GrammarMasteryLevel
    repositories/
      grammar_storage.dart          # Hive storage for grammar
      interfaces.dart               # Add IGrammarRepository
    providers/
      grammar_provider.dart         # Grammar-related providers
  features/
    grammar/
      grammar_hub_screen.dart       # Main entry point
      lesson_list_screen.dart       # Lessons by level
      lesson_view_screen.dart       # Full lesson with tabs
      exercise_screen.dart          # Exercise flow
      exercise_results_screen.dart  # Results summary
      conjugation_drill_screen.dart # Quick drill mode
      grammar_reference_screen.dart # Lookup tables
      widgets/
        explanation_tab.dart
        grammar_table_widget.dart
        examples_tab.dart
        fill_blank_exercise.dart
        multiple_choice_exercise.dart
        conjugation_exercise.dart
        matching_exercise.dart
        error_correction_exercise.dart
        translation_exercise.dart
        table_completion_exercise.dart
      controllers/
        grammar_exercise_controller.dart

assets/
  data/
    grammar/
      grammar_index.json
      a1/
        a1_g01_verb_to_be.json
        a1_g02_verb_to_have.json
        a1_g03_definite_articles.json
        a1_g04_indefinite_articles.json
        a1_g05_personal_pronouns.json
        ... (more A1 lessons)
      a2/
        a2_g01_present_verbs.json
        ... (more A2 lessons)

test/
  grammar_lesson_test.dart
  grammar_exercise_controller_test.dart
  grammar_hub_screen_test.dart
  grammar_progress_test.dart
```

---

## Appendix B: Conjugation Quick Reference

### Essential A1 Verbs

| Verb | Meaning | Pattern |
|------|---------|---------|
| είμαι | to be | Irregular |
| έχω | to have | Regular -ω |
| κάνω | to do/make | Regular -ω |
| θέλω | to want | Regular -ω |
| μπορώ | to be able | Regular -ώ |
| πάω | to go | Irregular |

### Regular -ω Endings

| Person | Singular | Plural |
|--------|----------|--------|
| 1st | -ω | -ουμε |
| 2nd | -εις | -ετε |
| 3rd | -ει | -ουν |

### Regular -ώ Endings (stressed)

| Person | Singular | Plural |
|--------|----------|--------|
| 1st | -ώ | -ούμε |
| 2nd | -άς | -άτε |
| 3rd | -ά / -άει | -ούν / -άνε |
