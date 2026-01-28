# Language Duel MVP - Content & Language Specification

**Version:** 2.0
**Last Updated:** 2026-01-28
**Document Owner:** Content/Language Agent
**Project:** Language Duel - Competitive Language Learning Game
**Mode:** Single-phone hot-seat (two players share one device)
**Languages:** Greek (el) <-> Catalan (ca), A1-A2 levels (CEFR)
**Content:** 7 vocabulary decks with 100+ items total

---

## Table of Contents

1. [Available Decks](#1-available-decks)
2. [JSON Schema for Content Items](#2-json-schema-for-content-items)
3. [Distractor Generation Rules](#3-distractor-generation-rules)
4. [Content Validation Checklist](#4-content-validation-checklist)
5. [Phonetic & Pronunciation Notes](#5-phonetic--pronunciation-notes)
6. [Future Expansion Guidelines](#6-future-expansion-guidelines)

---

## 1. Available Decks

The app includes 7 content decks spanning A1 and A2 CEFR levels:

| Deck ID | Name | Level | Items | Description |
|---------|------|-------|-------|-------------|
| `greetings` | Greetings / Χαιρετισμοί / Salutacions | A1 | 30 | Basic greetings, farewells, pleasantries |
| `numbers` | Numbers / Αριθμοί / Números | A1 | ~20 | Numbers 1-20 and basic counting phrases |
| `colors` | Colors / Χρώματα / Colors | A1 | 16 | Common colors and simple color phrases |
| `family` | Family / Οικογένεια / Família | A1 | ~20 | Family members and relationships |
| `travel_basics_a1` | Travel Basics / Βασικά Ταξιδιού / Viatge Bàsic | A1 | ~25 | Essential travel vocabulary |
| `travel_instructions_a2` | Travel Instructions / Οδηγίες Ταξιδιού / Instruccions de Viatge | A2 | ~35 | Directions, transportation, complex phrases |
| `house_cleaning_a2` | House & Cleaning / Σπίτι & Καθαριότητα / Casa i Neteja | A2 | ~25 | Household items and cleaning tasks |

### Deck File Locations

All decks are stored in `assets/data/`:
```
assets/data/
  greetings_deck.json
  numbers_deck.json
  colors_deck.json
  family_deck.json
  travel_basics_a1_deck.json
  travel_instructions_a2_deck.json
  house_cleaning_a2_deck.json
```

### Deck Selection in App

- A1 decks are unlocked by default
- A2 decks are available but marked as more challenging
- Future decks can be added by creating JSON files following the schema

---

## 2. JSON Schema for Content Items

### 1.1 Schema Overview

The content schema is designed to support:
- Bidirectional learning (Greek to Catalan AND Catalan to Greek)
- Both vocabulary items (single words) and phrases (for reordering)
- Rich metadata for game mechanics and learning support
- Extensibility for future language pairs and content types

### 1.2 Complete JSON Schema Definition

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://languageduel.app/schemas/deck.json",
  "title": "Language Duel Deck Schema",
  "description": "Schema for Language Duel vocabulary and phrase decks",
  "type": "object",
  "required": ["deckId", "deckName", "version", "languagePair", "level", "items"],
  "properties": {
    "deckId": {
      "type": "string",
      "description": "Unique identifier for the deck",
      "pattern": "^[a-z0-9_]+$"
    },
    "deckName": {
      "$ref": "#/definitions/LocalizedString",
      "description": "Human-readable deck name in both languages"
    },
    "version": {
      "type": "string",
      "description": "Semantic version of the deck content",
      "pattern": "^\\d+\\.\\d+\\.\\d+$"
    },
    "languagePair": {
      "$ref": "#/definitions/LanguagePair"
    },
    "level": {
      "type": "string",
      "enum": ["A1", "A2", "B1", "B2", "C1", "C2"],
      "description": "CEFR level of the content"
    },
    "description": {
      "$ref": "#/definitions/LocalizedString",
      "description": "Brief description of the deck content"
    },
    "itemCount": {
      "type": "integer",
      "minimum": 1,
      "description": "Total number of items in the deck"
    },
    "items": {
      "type": "array",
      "items": {
        "$ref": "#/definitions/ContentItem"
      },
      "minItems": 10,
      "description": "Array of content items (vocabulary and phrases)"
    },
    "metadata": {
      "type": "object",
      "properties": {
        "author": { "type": "string" },
        "createdAt": { "type": "string", "format": "date-time" },
        "updatedAt": { "type": "string", "format": "date-time" },
        "tags": {
          "type": "array",
          "items": { "type": "string" }
        }
      }
    }
  },
  "definitions": {
    "LocalizedString": {
      "type": "object",
      "required": ["el", "ca"],
      "properties": {
        "el": {
          "type": "string",
          "description": "Greek text (in Greek script)"
        },
        "ca": {
          "type": "string",
          "description": "Catalan text"
        }
      },
      "additionalProperties": {
        "type": "string",
        "description": "Additional language codes as needed"
      }
    },
    "LanguagePair": {
      "type": "object",
      "required": ["source", "target"],
      "properties": {
        "source": {
          "type": "string",
          "description": "ISO 639-1 code for source language",
          "pattern": "^[a-z]{2}$"
        },
        "target": {
          "type": "string",
          "description": "ISO 639-1 code for target language",
          "pattern": "^[a-z]{2}$"
        }
      }
    },
    "ContentItem": {
      "type": "object",
      "required": ["id", "type", "greek", "catalan", "category", "difficulty"],
      "properties": {
        "id": {
          "type": "string",
          "description": "Unique identifier within the deck",
          "pattern": "^[a-z0-9_]+$"
        },
        "type": {
          "type": "string",
          "enum": ["vocabulary", "phrase"],
          "description": "Item type: single word or multi-word phrase"
        },
        "greek": {
          "$ref": "#/definitions/GreekEntry",
          "description": "Greek language data"
        },
        "catalan": {
          "$ref": "#/definitions/CatalanEntry",
          "description": "Catalan language data"
        },
        "category": {
          "type": "string",
          "description": "Semantic category for distractor grouping",
          "enum": [
            "greeting_morning",
            "greeting_afternoon",
            "greeting_evening",
            "greeting_general",
            "farewell",
            "pleasantry",
            "question_wellbeing",
            "question_identity",
            "response_positive",
            "response_negative",
            "politeness",
            "introduction"
          ]
        },
        "difficulty": {
          "type": "integer",
          "minimum": 1,
          "maximum": 3,
          "description": "1=easy, 2=medium, 3=harder (within A1)"
        },
        "tags": {
          "type": "array",
          "items": { "type": "string" },
          "description": "Additional tags for filtering/grouping"
        },
        "notes": {
          "type": "string",
          "description": "Cultural or usage notes for the item"
        },
        "formalityLevel": {
          "type": "string",
          "enum": ["formal", "informal", "neutral"],
          "description": "Register/formality of the expression"
        },
        "wordBreakdown": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/WordBreakdownEntry"
          },
          "description": "Word-by-word breakdown for phrases (required for type=phrase)"
        },
        "distractorHints": {
          "type": "object",
          "properties": {
            "semanticSiblings": {
              "type": "array",
              "items": { "type": "string" },
              "description": "IDs of semantically related items for distractors"
            },
            "confusionPairs": {
              "type": "array",
              "items": { "type": "string" },
              "description": "IDs of commonly confused items"
            },
            "exclude": {
              "type": "array",
              "items": { "type": "string" },
              "description": "IDs that should NOT be used as distractors"
            }
          }
        }
      },
      "allOf": [
        {
          "if": {
            "properties": { "type": { "const": "phrase" } }
          },
          "then": {
            "required": ["wordBreakdown"]
          }
        }
      ]
    },
    "GreekEntry": {
      "type": "object",
      "required": ["text", "romanization", "phonetic"],
      "properties": {
        "text": {
          "type": "string",
          "description": "Greek text in Greek script (e.g., Καλημέρα)"
        },
        "romanization": {
          "type": "string",
          "description": "Romanized Greek (e.g., Kalimera)"
        },
        "phonetic": {
          "type": "string",
          "description": "Phonetic pronunciation guide (e.g., kah-lee-MEH-rah)"
        },
        "ipa": {
          "type": "string",
          "description": "IPA transcription (optional)"
        }
      }
    },
    "CatalanEntry": {
      "type": "object",
      "required": ["text", "phonetic"],
      "properties": {
        "text": {
          "type": "string",
          "description": "Catalan text"
        },
        "phonetic": {
          "type": "string",
          "description": "Phonetic pronunciation guide"
        },
        "ipa": {
          "type": "string",
          "description": "IPA transcription (optional)"
        }
      }
    },
    "WordBreakdownEntry": {
      "type": "object",
      "required": ["position", "greek", "catalan"],
      "properties": {
        "position": {
          "type": "integer",
          "minimum": 0,
          "description": "Word position in the phrase (0-indexed)"
        },
        "greek": {
          "type": "object",
          "required": ["word", "romanization"],
          "properties": {
            "word": {
              "type": "string",
              "description": "Greek word in Greek script"
            },
            "romanization": {
              "type": "string",
              "description": "Romanized Greek word"
            },
            "meaning": {
              "type": "string",
              "description": "Literal meaning in English (for internal reference)"
            }
          }
        },
        "catalan": {
          "type": "object",
          "required": ["word"],
          "properties": {
            "word": {
              "type": "string",
              "description": "Catalan word"
            },
            "meaning": {
              "type": "string",
              "description": "Literal meaning in English (for internal reference)"
            }
          }
        }
      }
    }
  }
}
```

### 1.3 Schema Field Reference

#### Deck-Level Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `deckId` | string | Yes | Unique identifier (e.g., "greetings_el_ca_a1") |
| `deckName` | LocalizedString | Yes | Display name in both languages |
| `version` | string | Yes | Semantic version (e.g., "1.0.0") |
| `languagePair` | LanguagePair | Yes | Source and target language codes |
| `level` | enum | Yes | CEFR level (A1-C2) |
| `description` | LocalizedString | No | Deck description |
| `itemCount` | integer | No | Number of items (computed) |
| `items` | array | Yes | Content items array |
| `metadata` | object | No | Author, timestamps, tags |

#### Item-Level Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | Yes | Unique ID within deck |
| `type` | enum | Yes | "vocabulary" or "phrase" |
| `greek` | GreekEntry | Yes | Greek language data |
| `catalan` | CatalanEntry | Yes | Catalan language data |
| `category` | enum | Yes | Semantic category |
| `difficulty` | integer | Yes | 1-3 (easy to harder) |
| `tags` | array | No | Additional categorization |
| `notes` | string | No | Cultural/usage notes |
| `formalityLevel` | enum | No | formal/informal/neutral |
| `wordBreakdown` | array | For phrases | Word-by-word translation |
| `distractorHints` | object | No | Hints for distractor generation |

### 1.4 Example Content Item (Vocabulary)

```json
{
  "id": "hello_general",
  "type": "vocabulary",
  "greek": {
    "text": "Γεια",
    "romanization": "Yia",
    "phonetic": "YAH",
    "ipa": "/ja/"
  },
  "catalan": {
    "text": "Hola",
    "phonetic": "OH-lah",
    "ipa": "/ˈɔ.la/"
  },
  "category": "greeting_general",
  "difficulty": 1,
  "tags": ["informal", "common", "casual"],
  "formalityLevel": "informal",
  "notes": "The most common informal greeting in both languages"
}
```

### 1.5 Example Content Item (Phrase with Word Breakdown)

```json
{
  "id": "how_are_you_informal",
  "type": "phrase",
  "greek": {
    "text": "Τι κάνεις;",
    "romanization": "Ti kanis?",
    "phonetic": "tee KAH-nees"
  },
  "catalan": {
    "text": "Com estas?",
    "phonetic": "kohm ehs-TAHS"
  },
  "category": "question_wellbeing",
  "difficulty": 2,
  "tags": ["informal", "question", "common"],
  "formalityLevel": "informal",
  "wordBreakdown": [
    {
      "position": 0,
      "greek": { "word": "Τι", "romanization": "Ti", "meaning": "what" },
      "catalan": { "word": "Com", "meaning": "how" }
    },
    {
      "position": 1,
      "greek": { "word": "κάνεις", "romanization": "kanis", "meaning": "you do" },
      "catalan": { "word": "estas", "meaning": "are you" }
    }
  ],
  "notes": "Literal: Greek asks 'What do you do?' while Catalan asks 'How are you?'"
}
```

---

## 3. Distractor Generation Rules

### 2.1 Overview

Distractors (wrong answer options) must be carefully selected to:
- Provide meaningful learning opportunities
- Avoid offensive or nonsensical combinations
- Maintain appropriate challenge level
- Test genuine knowledge rather than guessing

### 2.2 Semantic Groupings

Items are organized into semantic groups. Distractors should preferentially come from the same or related groups.

#### Primary Semantic Groups

| Group ID | Category | Items Should Include |
|----------|----------|---------------------|
| `TIME_GREETINGS` | Time-based greetings | good morning, good afternoon, good evening, good night |
| `GENERAL_GREETINGS` | Casual hellos | hello, hi, hey |
| `FAREWELLS` | Goodbyes | goodbye, bye, see you, see you later |
| `WELLBEING_Q` | Wellbeing questions | how are you?, how's it going? |
| `WELLBEING_R` | Wellbeing responses | I'm fine, very well, not bad |
| `INTRODUCTIONS` | Meeting people | nice to meet you, my name is, pleased to meet you |
| `POLITENESS` | Polite expressions | please, thank you, you're welcome, excuse me |

#### Distractor Selection Priority

```
1. SAME CATEGORY (highest priority)
   - If answer is "Good morning" → use "Good afternoon", "Good evening", "Good night"

2. RELATED CATEGORY (second priority)
   - If answer is "Hello" → use other greetings OR simple farewells

3. SAME DIFFICULTY LEVEL (third priority)
   - Match difficulty to avoid "obviously wrong" options

4. SAME DECK (fallback)
   - Any item from the current deck if above criteria insufficient
```

### 2.3 Common Confusion Pairs

These pairs are specifically recommended as distractors for each other:

#### Greek-Catalan Confusion Pairs

| Item 1 | Item 2 | Reason |
|--------|--------|--------|
| Καλημέρα (Good morning) | Καλησπέρα (Good evening) | Similar structure |
| Καληνύχτα (Good night) | Καλησπέρα (Good evening) | Evening/night confusion |
| Ναι (Yes) | Όχι (No) | Opposite meanings |
| Παρακαλώ (Please/You're welcome) | Ευχαριστώ (Thank you) | Often paired together |
| Τι κάνεις; (How are you? - informal) | Τι κάνετε; (How are you? - formal) | Formality confusion |
| Γεια (Hello/Bye - informal) | Γεια σου (Hello/Bye - informal emphatic) | Related forms |

#### Catalan Confusion Pairs

| Item 1 | Item 2 | Reason |
|--------|--------|--------|
| Bon dia (Good morning) | Bona nit (Good night) | Time-based |
| Bona tarda (Good afternoon) | Bona nit (Good night) | Time-based |
| Si (Yes) | No (No) | Opposites |
| Si us plau (Please - formal) | Per favor (Please - informal) | Same meaning, different register |
| Adeu (Goodbye) | Fins despres (See you later) | Both farewells |

### 2.4 Phrase Distractor Rules

For Phrase Builder, distractors are individual words shown out of order. Special rules apply:

#### Word Selection for Scrambling

1. **All words must be present** - No fake words added
2. **Minimum 2 words** - Single-word phrases cannot be scrambled
3. **Maximum 5 words** - Keep A1-appropriate complexity
4. **Preserve punctuation** - Question marks, etc. stay with final word

#### Scrambling Constraints

```
GOOD scramble: "estas Com" for "Com estas"
BAD scramble:  "Com estas" (same as correct - not allowed)
```

### 2.5 Exclusion Rules (What NOT to Use)

#### Never Use as Distractors

| Rule | Reason | Example |
|------|--------|---------|
| Same word with different capitalization | Too similar | "hola" vs "Hola" |
| Words that sound identical | Unfair | Homophones |
| Words differing by one letter | Typo appearance | "bon" vs "bona" in isolation |
| Culturally sensitive combinations | Offensive risk | See below |
| Items from different CEFR levels | Difficulty mismatch | A2 words in A1 quiz |

#### Offensive Combination Prevention

NEVER create answer sets where wrong combinations could form:
- Insults or profanity
- Politically sensitive phrases
- Religious offensive content
- Culturally inappropriate expressions

**Validation Rule:** Review all 4-option combinations for any potentially offensive readings when taken together.

### 2.6 Distractor Generation Algorithm

```python
def generate_distractors(correct_item, deck, count=3):
    distractors = []

    # Step 1: Same category items
    same_category = [item for item in deck
                     if item.category == correct_item.category
                     and item.id != correct_item.id]
    distractors.extend(shuffle(same_category)[:count])

    # Step 2: Fill with confusion pairs if defined
    if len(distractors) < count and correct_item.distractorHints:
        confusion_ids = correct_item.distractorHints.confusionPairs or []
        confusion_items = [item for item in deck if item.id in confusion_ids]
        remaining = count - len(distractors)
        distractors.extend(shuffle(confusion_items)[:remaining])

    # Step 3: Fill with same difficulty items
    if len(distractors) < count:
        same_difficulty = [item for item in deck
                          if item.difficulty == correct_item.difficulty
                          and item.id != correct_item.id
                          and item not in distractors]
        remaining = count - len(distractors)
        distractors.extend(shuffle(same_difficulty)[:remaining])

    # Step 4: Fill with any remaining deck items
    if len(distractors) < count:
        others = [item for item in deck
                  if item.id != correct_item.id
                  and item not in distractors]
        remaining = count - len(distractors)
        distractors.extend(shuffle(others)[:remaining])

    # Step 5: Validate no excluded items
    if correct_item.distractorHints and correct_item.distractorHints.exclude:
        distractors = [d for d in distractors
                       if d.id not in correct_item.distractorHints.exclude]

    return distractors[:count]
```

---

## 4. Content Validation Checklist

### 3.1 Pre-Publication Checklist

Use this checklist before any content deck is published:

#### A1 CEFR Level Appropriateness

- [ ] All vocabulary items are from CEFR A1 word lists
- [ ] Phrases use only simple sentence structures
- [ ] No complex grammar (subjunctive, conditional beyond basics)
- [ ] Maximum phrase length is 5 words
- [ ] All content represents high-frequency, everyday language
- [ ] Verb forms are limited to present tense and simple imperatives
- [ ] No idiomatic expressions requiring cultural knowledge

#### Translation Accuracy

- [ ] All Greek text reviewed by native Greek speaker
- [ ] All Catalan text reviewed by native Catalan speaker
- [ ] Romanization follows standard Greek romanization (ELOT 743 or equivalent)
- [ ] Phonetic guides accurately represent pronunciation
- [ ] Word-by-word breakdowns align correctly
- [ ] Bidirectional translations verified (Greek->Catalan AND Catalan->Greek)
- [ ] Context-appropriate translations (not just dictionary definitions)

#### Cultural Appropriateness

- [ ] Formal/informal registers correctly labeled
- [ ] Cultural notes provided where conventions differ
- [ ] No culturally insensitive content
- [ ] Regional variations noted where relevant
- [ ] Expressions appropriate for general audiences
- [ ] No gender-biased or stereotypical content

#### Offensive Combination Prevention

- [ ] All 4-option multiple choice sets reviewed for offensive combinations
- [ ] No profanity or vulgar terms in any form
- [ ] No words that form profanity when combined
- [ ] Religious terms handled respectfully
- [ ] Political neutrality maintained
- [ ] No slurs, insults, or derogatory terms

#### Gameplay Variety

- [ ] Minimum 10 vocabulary items per deck
- [ ] Minimum 6 phrases suitable for Phrase Builder
- [ ] At least 3 items per difficulty level (1, 2, 3)
- [ ] Multiple semantic categories represented
- [ ] Both formal and informal variants included where appropriate
- [ ] Questions, statements, and exclamations balanced

#### Difficulty Distribution

- [ ] Difficulty 1 (Easy): 40-50% of items (12-15 items for 30-item deck)
- [ ] Difficulty 2 (Medium): 30-40% of items (9-12 items)
- [ ] Difficulty 3 (Harder): 15-25% of items (5-7 items)
- [ ] Difficulty levels consistently applied
- [ ] Progression from common to less common words

### 3.2 Technical Validation

- [ ] JSON passes schema validation
- [ ] All required fields present
- [ ] All IDs unique within deck
- [ ] All category values from allowed enum
- [ ] All difficulty values in range 1-3
- [ ] Greek text uses Greek Unicode characters (not romanization)
- [ ] No empty strings for required fields
- [ ] Word breakdown count matches phrase word count

### 3.3 Quality Metrics

| Metric | Target | Minimum |
|--------|--------|---------|
| Items per deck | 30 | 20 |
| Vocabulary items | 15-18 | 12 |
| Phrases | 12-15 | 8 |
| Categories covered | 6+ | 4 |
| Difficulty 1 items | 40-50% | 35% |
| Difficulty 3 items | 15-25% | 10% |
| Items with cultural notes | 20%+ | 10% |

---

## 5. Phonetic & Pronunciation Notes

Grammar lessons use IPA for pronunciation hints (stored in the `romanization` field of grammar JSON) and can be toggled in the lesson view. Deck content continues to use romanization plus the beginner-friendly `phonetic` field.

### 4.1 Greek Pronunciation Guide

#### Greek Alphabet Reference

| Letter | Name | Sound | Example | Notes |
|--------|------|-------|---------|-------|
| Α α | alpha | /a/ | "ah" as in "father" | Open front vowel |
| Β β | beta | /v/ | "v" as in "very" | NOT like English "b" |
| Γ γ | gamma | /ɣ/ or /j/ | Soft "g" or "y" | Before ε, ι sounds like "y" |
| Δ δ | delta | /ð/ | "th" as in "this" | Voiced dental fricative |
| Ε ε | epsilon | /e/ | "e" as in "bed" | Short e sound |
| Ζ ζ | zeta | /z/ | "z" as in "zoo" | |
| Η η | eta | /i/ | "ee" as in "see" | Same as ι in Modern Greek |
| Θ θ | theta | /θ/ | "th" as in "think" | Voiceless dental fricative |
| Ι ι | iota | /i/ | "ee" as in "see" | |
| Κ κ | kappa | /k/ | "k" as in "key" | |
| Λ λ | lambda | /l/ | "l" as in "love" | |
| Μ μ | mu | /m/ | "m" as in "mother" | |
| Ν ν | nu | /n/ | "n" as in "no" | |
| Ξ ξ | xi | /ks/ | "x" as in "box" | |
| Ο ο | omicron | /o/ | "o" as in "more" | Short o sound |
| Π π | pi | /p/ | "p" as in "pen" | |
| Ρ ρ | rho | /r/ | Rolled "r" | Trilled or tapped |
| Σ σ/ς | sigma | /s/ | "s" as in "sun" | ς used at word end |
| Τ τ | tau | /t/ | "t" as in "top" | |
| Υ υ | upsilon | /i/ | "ee" as in "see" | Same as ι in Modern Greek |
| Φ φ | phi | /f/ | "f" as in "fun" | |
| Χ χ | chi | /x/ or /ç/ | German "ch" | Varies by following vowel |
| Ψ ψ | psi | /ps/ | "ps" as in "lips" | |
| Ω ω | omega | /o/ | "o" as in "more" | Same as ο in Modern Greek |

#### Greek Vowel Combinations (Digraphs)

| Combination | Sound | Example |
|-------------|-------|---------|
| αι | /e/ | "e" as in "bed" |
| ει | /i/ | "ee" as in "see" |
| οι | /i/ | "ee" as in "see" |
| ου | /u/ | "oo" as in "food" |
| αυ | /af/ or /av/ | Before voiceless: /af/; before voiced: /av/ |
| ευ | /ef/ or /ev/ | Before voiceless: /ef/; before voiced: /ev/ |

#### Greek Consonant Combinations

| Combination | Sound | Example |
|-------------|-------|---------|
| μπ | /b/ (initial) or /mb/ (medial) | "b" or "mb" |
| ντ | /d/ (initial) or /nd/ (medial) | "d" or "nd" |
| γκ | /g/ (initial) or /ŋg/ (medial) | "g" or "ng" |
| τσ | /ts/ | "ts" as in "cats" |
| τζ | /dz/ | "dz" as in "adze" |

### 4.2 Catalan Pronunciation Guide

#### Key Catalan Sounds

| Letter/Combo | Sound | Example | Notes |
|--------------|-------|---------|-------|
| a (stressed) | /a/ | "ah" | Open a |
| a (unstressed) | /ə/ | "uh" (schwa) | Neutral vowel |
| e (stressed open) | /ɛ/ | "eh" as in "bed" | |
| e (stressed close) | /e/ | "ay" (shorter) | |
| e (unstressed) | /ə/ | "uh" (schwa) | |
| i | /i/ | "ee" | |
| o (stressed open) | /ɔ/ | "aw" as in "caught" | |
| o (stressed close) | /o/ | "oh" | |
| o (unstressed) | /u/ | "oo" | Eastern Catalan |
| u | /u/ | "oo" | |
| c (before e, i) | /s/ | "s" | |
| c (elsewhere) | /k/ | "k" | |
| g (before e, i) | /ʒ/ | "zh" as in "measure" | |
| g (elsewhere) | /g/ | "g" as in "go" | |
| j | /ʒ/ | "zh" | |
| ll | /ʎ/ | Similar to "ly" | Palatal lateral |
| ny | /ɲ/ | "ny" as in "canyon" | |
| r (initial) | /r/ | Trilled | |
| r (medial single) | /ɾ/ | Tapped | |
| rr | /r/ | Trilled | |
| s (between vowels) | /z/ | "z" | |
| ss | /s/ | "s" | |
| x | /ʃ/ | "sh" | |
| tx | /tʃ/ | "ch" as in "church" | |
| ig (word final) | /tʃ/ | "ch" | |

#### Catalan Stress Rules

1. Words ending in vowel, -s, -en, -in: stress on second-to-last syllable
2. Words ending in consonant (except -s, -en, -in): stress on last syllable
3. Exceptions marked with accent: é, è, í, ó, ò, ú, à

### 4.3 Common Pitfalls: Greek Speakers Learning Catalan

| Challenge | Greek Habit | Catalan Reality | Tip |
|-----------|-------------|-----------------|-----|
| Vowel reduction | All vowels pronounced clearly | Unstressed e, a become schwa (ə) | Practice "bona" as /ˈbo.nə/ not /ˈbo.na/ |
| The "j" sound | No equivalent | /ʒ/ as in "measure" | Practice with "jo" (I) |
| The "ny" sound | Similar to νι | Catalan /ɲ/ more palatalized | Practice "Catalunya" |
| Double letters | No gemination | ll, rr have distinct sounds | "ll" = /ʎ/, not /l/ |
| Final consonants | Often dropped | Must be pronounced | "Adeu" - pronounce the 'u' |
| R sounds | Single tap | Initial r is trilled like rr | Practice "Ramon" |

### 4.4 Common Pitfalls: Catalan Speakers Learning Greek

| Challenge | Catalan Habit | Greek Reality | Tip |
|-----------|---------------|---------------|-----|
| The γ (gamma) | No equivalent | /ɣ/ is voiced velar fricative | Like "g" but with friction |
| The δ (delta) | Similar to Catalan "d" | Always /ð/ like English "this" | Tongue between teeth |
| The χ (chi) | Similar to "j" sound | German "ch" /x/ | Rougher, back of throat |
| Vowel combinations | Single sounds | Greek diphthongs predictable | Learn αι, ει, οι, ου rules |
| Stress patterns | Predictable | Variable, marked with accent | Watch for accent marks (΄) |
| The β (beta) | Expecting "b" | Always /v/ in Modern Greek | Like English "v" |
| Double consonants | Have meaning | μπ, ντ, γκ = b, d, g sounds | These create voiced stops |

### 4.5 Phonetic Notation System

For this project, we use a simplified phonetic notation accessible to beginners:

#### Notation Conventions

| Symbol | Meaning | Example |
|--------|---------|---------|
| CAPS | Stressed syllable | kah-lee-MEH-rah |
| - | Syllable boundary | bon-DEE-ah |
| ah | Open a as in "father" | |
| ay | Long a as in "say" | |
| ee | Long e as in "see" | |
| eh | Short e as in "bed" | |
| oh | Long o as in "no" | |
| oo | Long u as in "food" | |
| uh | Schwa (unstressed) | |
| th | Voiceless as in "think" | |
| dh | Voiced as in "this" | |
| kh | German "ch" sound | |
| zh | As in "measure" | |
| ny | As in "canyon" | |

---

## 6. Future Expansion Guidelines

### 5.1 Adding New Vocabulary to Existing Decks

#### Process

1. **Identify Gap:** Review deck for missing common vocabulary
2. **Research:** Verify A1 appropriateness using CEFR word lists
3. **Draft Entry:** Create JSON entry following schema
4. **Validation:** Run through validation checklist
5. **Review:** Native speaker review for both languages
6. **Integration:** Add to deck, update version number

#### Required Fields Checklist

```json
{
  "id": "unique_snake_case_id",
  "type": "vocabulary",
  "greek": {
    "text": "Greek script required",
    "romanization": "Standard romanization",
    "phonetic": "Beginner-friendly pronunciation"
  },
  "catalan": {
    "text": "Catalan text",
    "phonetic": "Beginner-friendly pronunciation"
  },
  "category": "from_allowed_enum",
  "difficulty": 1
}
```

#### Version Numbering

- **Patch (x.x.1):** Fix typos, update phonetics
- **Minor (x.1.0):** Add 1-5 new items
- **Major (1.0.0):** Significant restructuring or 10+ new items

### 5.2 Creating New Decks

#### Recommended Deck Topics for A1 Level

| Deck Name | Estimated Items | Priority |
|-----------|-----------------|----------|
| Numbers (0-100) | 25-30 | High |
| Colors | 15-20 | High |
| Days & Months | 20-25 | High |
| Family Members | 20-25 | Medium |
| Food & Drinks | 30-40 | Medium |
| Weather | 15-20 | Medium |
| Body Parts | 20-25 | Low |
| Clothing | 20-25 | Low |
| Transportation | 15-20 | Low |

#### New Deck Template

```json
{
  "deckId": "topic_el_ca_a1",
  "deckName": {
    "el": "Greek Name",
    "ca": "Catalan Name"
  },
  "version": "1.0.0",
  "languagePair": {
    "source": "el",
    "target": "ca"
  },
  "level": "A1",
  "description": {
    "el": "Greek description",
    "ca": "Catalan description"
  },
  "items": [],
  "metadata": {
    "author": "Content Team",
    "createdAt": "ISO-8601 date",
    "tags": ["topic", "a1"]
  }
}
```

### 5.3 Adding New Language Pairs

#### Supported Language Code Format

Use ISO 639-1 two-letter codes:

| Language | Code |
|----------|------|
| Greek | el |
| Catalan | ca |
| Spanish | es |
| English | en |
| French | fr |
| German | de |
| Italian | it |
| Portuguese | pt |

#### Schema Modifications for New Languages

1. Add new language entry type (e.g., `SpanishEntry`)
2. Update `LocalizedString` to include new language code
3. Define pronunciation guide conventions for new language
4. Create language-specific confusion pairs documentation

#### File Naming Convention

```
{topic}_{source}_{target}_{level}.json

Examples:
- greetings_el_ca_a1.json (Greek-Catalan A1 Greetings)
- greetings_el_es_a1.json (Greek-Spanish A1 Greetings)
- numbers_ca_en_a1.json (Catalan-English A1 Numbers)
```

### 5.4 Content Quality Standards

#### Linguistic Standards

| Criterion | Requirement |
|-----------|-------------|
| Native Review | All content reviewed by native speaker of each language |
| CEFR Alignment | Vocabulary from official CEFR A1 lists |
| Modern Usage | Contemporary, commonly used expressions |
| Regional Neutrality | Avoid regional-specific terms unless noted |
| Register Balance | Include both formal and informal where applicable |

#### Technical Standards

| Criterion | Requirement |
|-----------|-------------|
| Schema Compliance | 100% valid against JSON schema |
| Unicode | Proper Unicode encoding for all scripts |
| Completeness | All required fields populated |
| Consistency | Consistent formatting across deck |
| Testing | All items tested in game context |

#### Quality Assurance Process

```
1. Content Creation
   ├── Draft content in spreadsheet
   ├── Self-review against checklist
   └── Export to JSON

2. Technical Review
   ├── Schema validation
   ├── Automated checks (empty fields, valid enums)
   └── Format consistency

3. Linguistic Review
   ├── Native Greek speaker review
   ├── Native Catalan speaker review
   └── Cross-check translations

4. Gameplay Testing
   ├── Test all items in Vocab Flash Duel
   ├── Test all phrases in Phrase Builder
   └── Verify distractor quality

5. Publication
   ├── Update version number
   ├── Update metadata timestamps
   └── Deploy to application
```

### 5.5 Localization Guidelines

#### UI Strings vs Content

- **UI Strings:** Interface text (buttons, labels) - managed separately
- **Content:** Learning material (vocabulary, phrases) - in deck JSON

#### Adding UI Language Support

For new UI languages, create localization files following Flutter's l10n conventions:

```
lib/l10n/
  ├── app_el.arb  (Greek UI)
  ├── app_ca.arb  (Catalan UI)
  └── app_en.arb  (English UI - fallback)
```

---

## Appendix A: Category Definitions

### Complete Category Taxonomy

| Category ID | Description | Example Items |
|-------------|-------------|---------------|
| `greeting_morning` | Morning-specific greetings | Good morning |
| `greeting_afternoon` | Afternoon greetings | Good afternoon |
| `greeting_evening` | Evening greetings | Good evening |
| `greeting_general` | Time-neutral greetings | Hello, Hi |
| `farewell` | Parting expressions | Goodbye, See you |
| `pleasantry` | Social niceties | How are you?, Fine thanks |
| `question_wellbeing` | Questions about state | How are you? |
| `question_identity` | Questions about identity | What's your name? |
| `response_positive` | Positive responses | Yes, I'm fine, Great |
| `response_negative` | Negative responses | No, Not so good |
| `politeness` | Polite expressions | Please, Thank you |
| `introduction` | Self-introduction | My name is..., Nice to meet you |

---

## Appendix B: Difficulty Level Criteria

### Difficulty 1 (Easy)

- Single words or 2-word phrases
- Highest frequency vocabulary (top 100 words)
- Cognates or near-cognates between languages
- Words with clear pronunciation
- No grammatical complexity

**Examples:** Hello, Goodbye, Yes, No, Thank you

### Difficulty 2 (Medium)

- 2-3 word phrases
- Common but slightly less frequent
- May require word order awareness
- Basic question forms
- Simple formality distinctions

**Examples:** How are you?, Good morning, See you later

### Difficulty 3 (Harder within A1)

- 3-5 word phrases
- Less common but still A1 appropriate
- Require understanding of full phrase
- More nuanced social situations
- Formal register expressions

**Examples:** Pleased to meet you, Could you repeat that?

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-26 | Content/Language Agent | Initial document creation |

---

*This document serves as the authoritative reference for content creation and language standards in the Language Duel MVP. All content must comply with these specifications.*
