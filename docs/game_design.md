# Language Duel MVP - Game Design Document

**Version:** 1.0
**Last Updated:** 2026-01-26
**Document Owner:** Game Design Agent
**Project:** Language Duel - Competitive Language Learning Game
**Mode:** Single-phone hot-seat (two players share one device)
**Languages:** Greek <-> Catalan, A1 beginner level
**Content:** "Greetings" deck (~30 vocabulary items and short phrases)

---

## Table of Contents

1. [Vocab Flash Duel - Complete Game Design](#1-vocab-flash-duel---complete-game-design)
2. [Phrase Builder (Reorder) - Complete Game Design](#2-phrase-builder-reorder---complete-game-design)
3. [Overall Scoring System](#3-overall-scoring-system)
4. [Round & Match Structure](#4-round--match-structure)
5. [Win/Loss/Tie Conditions](#5-winlosstie-conditions)
6. [Difficulty Balancing for A1 Learners](#6-difficulty-balancing-for-a1-learners)

---

## 1. Vocab Flash Duel - Complete Game Design

### 1.1 Core Mechanics

**Overview:** Players are shown a word or short phrase in their source language and must select the correct translation from four multiple-choice options.

**Step-by-Step Flow:**

1. **Question Display:** A word/phrase appears in the source language (the language the player is learning FROM)
2. **Options Appear:** Four answer options in the target language (the language the player is learning TO)
3. **Timer Starts:** A 10-second countdown begins immediately
4. **Player Selection:** Player taps one of the four options
5. **Immediate Feedback:** Visual and textual feedback shows correct/incorrect status
6. **Score Update:** Points are calculated and displayed
7. **Next Question:** After 2-second feedback display, the next question loads
8. **Repeat:** Steps 1-7 repeat for all 5 questions

### 1.2 Question Format

**Source Word Display:**
```
┌─────────────────────────────────────┐
│                                     │
│         "Kalimera"                  │   <- Source word (larger font)
│         Καλημέρα                    │   <- Original script (if applicable)
│                                     │
│     [pronunciation hint optional]   │   <- "kah-lee-MEH-rah"
│                                     │
└─────────────────────────────────────┘
```

**Answer Options Layout:**
```
┌─────────────────────────────────────┐
│  ┌─────────────────────────────┐    │
│  │     A) Bon dia               │    │  <- Option tiles
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │     B) Bona nit              │    │
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │     C) Adeu                  │    │
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │     D) Hola                  │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

### 1.3 Distractor Logic (Wrong Answer Generation)

**Distractor Selection Algorithm:**

| Priority | Distractor Type | Description | Example |
|----------|----------------|-------------|---------|
| 1st | **Semantic Siblings** | Words from the same category (e.g., other greetings) | If answer is "Good morning", distractors could be "Good night", "Good afternoon", "Hello" |
| 2nd | **Phonetic Confusion** | Words that sound similar in the target language | Similar starting sounds or syllable patterns |
| 3rd | **Same Deck** | Other items from the current content deck | Random items from "Greetings" deck |
| 4th | **Random Fallback** | Any remaining items if needed | Used only if insufficient items in category |

**Distractor Selection Rules:**

1. **Never repeat:** Distractors must be unique and different from the correct answer
2. **Consistent direction:** All distractors must be in the same target language as the correct answer
3. **Similar length:** Prefer distractors of similar word length to avoid "longest answer is correct" bias
4. **Difficulty matching:** For A1, avoid obscure words as distractors; use familiar vocabulary
5. **Position randomization:** Correct answer position is randomized (A/B/C/D) for each question

**Distractor Generation Pseudocode:**
```
function generateDistractors(correctItem, deck):
    distractors = []

    // Step 1: Try semantic siblings
    siblings = deck.filter(item =>
        item.category == correctItem.category AND
        item.id != correctItem.id
    )
    distractors.addUpTo(siblings.shuffle(), 3)

    // Step 2: Fill remaining with other deck items
    if distractors.length < 3:
        others = deck.filter(item =>
            item.id != correctItem.id AND
            item NOT IN distractors
        )
        distractors.addUpTo(others.shuffle(), 3 - distractors.length)

    // Step 3: Combine and shuffle with correct answer
    allOptions = [correctItem, ...distractors]
    return allOptions.shuffle()
```

### 1.4 Timer Rules

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| Duration | **10 seconds** | Long enough for reading, short enough for pressure |
| Visual Display | Circular countdown + numeric display | Clear visibility during play |
| Warning Threshold | **3 seconds remaining** | Visual pulse/color change (yellow to red) |
| Timeout Behavior | Auto-submit as wrong answer | No partial credit for timeout |
| Timer Start | When question fully rendered | Ensures fairness across devices |

**Timer States:**
- **Green (10-4 sec):** Normal state, relaxed color
- **Yellow (3-2 sec):** Warning state, pulsing animation
- **Red (1-0 sec):** Critical state, faster pulse, urgent visual

### 1.5 Scoring System

**Base Points:**

| Outcome | Points | Description |
|---------|--------|-------------|
| Correct Answer | **+10 points** | Base reward for correct selection |
| Wrong Answer | **0 points** | No penalty, no deduction |
| Timeout | **0 points** | Treated as wrong answer |

**Speed Bonus:**

| Time Remaining | Speed Bonus | Total with Base |
|----------------|-------------|-----------------|
| 8-10 sec (answered in 0-2s) | **+5 points** | 15 points |
| 5-7 sec (answered in 3-5s) | **+3 points** | 13 points |
| 3-4 sec (answered in 6-7s) | **+1 point** | 11 points |
| 0-2 sec (answered in 8-10s) | **+0 points** | 10 points |

**Speed Bonus Formula:**
```
function calculateSpeedBonus(timeRemaining):
    if timeRemaining >= 8:
        return 5   // Lightning fast
    else if timeRemaining >= 5:
        return 3   // Quick
    else if timeRemaining >= 3:
        return 1   // Reasonable
    else:
        return 0   // Slow (but still correct)
```

**Maximum Points per Question:** 15 (10 base + 5 speed bonus)
**Maximum Points per Round (5 questions):** 75 points

### 1.6 Difficulty Curve

**Within a Single Round:**

For the MVP, questions are presented in **random order** within the round. No explicit difficulty progression is implemented for the Greetings deck.

**Rationale:**
- A1 content is uniformly beginner-friendly
- Random order ensures fairness between players (same content pool)
- Keeps implementation simple for MVP

**Future Enhancement (Post-MVP):**
```
Question 1-2: Easy (single words, high frequency)
Question 3-4: Medium (common phrases, 2-3 words)
Question 5: Harder (longer phrases, less common)
```

### 1.7 Questions Per Round

| Parameter | Value |
|-----------|-------|
| Questions per player per game | **5** |
| Total questions per Vocab Flash Duel round | **10** (5 per player) |
| Question pool size needed | Minimum 10 unique items |
| Repeat prevention | No repeats within a single duel |

**Question Selection Algorithm:**
1. Shuffle the entire deck
2. Select first 10 unique items for the duel
3. Assign questions 1-5 to Player 1
4. Assign questions 6-10 to Player 2
5. Each player sees different questions (fairness through equivalence, not identical content)

---

## 2. Phrase Builder (Reorder) - Complete Game Design

### 2.1 Core Mechanics

**Overview:** Players see a phrase in their source language and a set of scrambled word tiles in the target language. They must arrange the tiles in the correct order to form the translation.

**Step-by-Step Flow:**

1. **Phrase Display:** Source phrase appears at the top of the screen
2. **Scrambled Tiles:** Word tiles appear in a randomized, incorrect order
3. **Timer Starts:** A 30-second countdown begins
4. **Player Interaction:** Player drags tiles to reorder them
5. **Submit or Timeout:** Player taps "Submit" or timer expires
6. **Validation:** System checks the arranged order against correct answer
7. **Feedback Display:** Shows score, correct order, and which words were misplaced
8. **Next Phrase:** After 3-second feedback, next phrase loads
9. **Repeat:** Steps 1-8 repeat for all 3 phrases

### 2.2 Phrase Selection Criteria

**Phrase Requirements for A1 Level:**

| Criteria | Requirement | Examples |
|----------|-------------|----------|
| Word Count | **2-5 words** | "Good morning" (2), "How are you?" (3), "Nice to meet you" (4) |
| Complexity | Simple sentence structure | Subject-verb, greetings, basic questions |
| Vocabulary | High-frequency A1 words | Common greetings, pleasantries |
| Grammar | Minimal grammar complexity | No complex tenses, no subjunctive |

**Phrase Selection from Greetings Deck:**

| Word Count | Quantity per Duel | Examples |
|------------|-------------------|----------|
| 2 words | 2 phrases | "Bon dia" (Good morning), "Bona nit" (Good night) |
| 3 words | 2 phrases | "Com estas tu?" (How are you?) |
| 4-5 words | 2 phrases | "Encantat de coneixer-te" (Nice to meet you) |

**Total phrases needed:** 6 unique phrases (3 per player)

### 2.3 Scrambling Algorithm

**Requirements:**
1. The scrambled order must NEVER match the correct order
2. Scrambling should appear random but be deterministic for reproducibility
3. All words must be present (no additions or removals)

**Scrambling Algorithm:**
```
function scramblePhrase(words):
    if words.length <= 1:
        return words  // Cannot scramble single word

    scrambled = words.copy()
    attempts = 0
    maxAttempts = 100

    while scrambled == words AND attempts < maxAttempts:
        scrambled = fisherYatesShuffle(scrambled)
        attempts++

    // Fallback: If still matching (rare), swap first two elements
    if scrambled == words:
        swap(scrambled[0], scrambled[1])

    return scrambled

function fisherYatesShuffle(array):
    for i from array.length - 1 down to 1:
        j = randomInt(0, i)
        swap(array[i], array[j])
    return array
```

**Visual Presentation:**
```
Source Phrase: "Kalinikta" (Good night)

Scrambled Tiles:
┌─────────┐  ┌─────────┐
│  nit    │  │  Bona   │
└─────────┘  └─────────┘

Correct Order:
┌─────────┐  ┌─────────┐
│  Bona   │  │  nit    │
└─────────┘  └─────────┘
```

### 2.4 Validation Logic

**Exact Match Validation:**
```
function validateOrder(userOrder, correctOrder):
    if userOrder.length != correctOrder.length:
        return { valid: false, score: 0 }

    correctPositions = 0
    for i from 0 to userOrder.length - 1:
        if userOrder[i] == correctOrder[i]:
            correctPositions++

    isFullyCorrect = (correctPositions == correctOrder.length)

    return {
        valid: isFullyCorrect,
        correctPositions: correctPositions,
        totalPositions: correctOrder.length,
        percentage: correctPositions / correctOrder.length
    }
```

### 2.5 Partial Credit System

**Scoring Based on Correct Positions:**

| Accuracy | Points Awarded | Example (4-word phrase) |
|----------|---------------|-------------------------|
| 100% correct | **20 points** (full) | All 4 words in correct position |
| 75% correct | **15 points** | 3 of 4 words correct |
| 50% correct | **10 points** | 2 of 4 words correct |
| 25% correct | **5 points** | 1 of 4 words correct |
| 0% correct | **0 points** | No words in correct position |

**Partial Credit Formula:**
```
function calculatePhraseScore(correctPositions, totalPositions):
    percentage = correctPositions / totalPositions
    baseScore = 20  // Maximum base score

    return floor(baseScore * percentage)
```

**Rounding:** Always round DOWN (floor) to avoid fractional points.

**Examples:**

| Phrase | Correct/Total | Percentage | Raw Score | Final Score |
|--------|---------------|------------|-----------|-------------|
| 3-word phrase | 3/3 | 100% | 20.0 | 20 |
| 3-word phrase | 2/3 | 66.7% | 13.3 | 13 |
| 4-word phrase | 3/4 | 75% | 15.0 | 15 |
| 5-word phrase | 2/5 | 40% | 8.0 | 8 |

### 2.6 Timer Rules

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| Duration | **30 seconds** | Enough time to read, think, and arrange |
| Visual Display | Horizontal progress bar + numeric countdown | Clear visibility |
| Warning Threshold | **10 seconds remaining** | Bar turns yellow, then red at 5 sec |
| Timeout Behavior | Auto-submit current arrangement | Partial credit possible |
| Timer Start | When tiles are fully rendered and interactive | Ensures fairness |

**Timer States:**
- **Green (30-11 sec):** Normal state, calm progress
- **Yellow (10-6 sec):** Warning state, bar pulses gently
- **Red (5-0 sec):** Critical state, urgent visual, faster pulse

### 2.7 Scoring System

**Base Scoring:**

| Outcome | Points | Description |
|---------|--------|-------------|
| Perfect Answer | **20 points** | All words in correct position |
| Partial Answer | **1-19 points** | Proportional to correct positions |
| No Correct Positions | **0 points** | Complete failure |

**Time Bonus:**

| Time Remaining | Time Bonus | Max Total |
|----------------|------------|-----------|
| 20-30 sec (answered in 0-10s) | **+5 points** | 25 points |
| 10-19 sec (answered in 11-20s) | **+2 points** | 22 points |
| 0-9 sec (answered in 21-30s) | **+0 points** | 20 points |

**Time Bonus Formula:**
```
function calculateTimeBonus(timeRemaining):
    if timeRemaining >= 20:
        return 5   // Very fast completion
    else if timeRemaining >= 10:
        return 2   // Good pace
    else:
        return 0   // Slow (but submitted)
```

**Note:** Time bonus is only awarded for 100% correct answers. Partial answers do not receive time bonus.

**Maximum Points per Phrase:** 25 (20 base + 5 time bonus)
**Maximum Points per Round (3 phrases):** 75 points

### 2.8 Hint System (Optional Feature)

**Hint Mechanics:**

| Hint Type | Description | Cost | Benefit |
|-----------|-------------|------|---------|
| **First Word Hint** | Reveals the first word in correct position | -3 points | First tile locks in place |
| **Any Word Hint** | Reveals one random incorrect word's position | -2 points | One tile snaps to correct spot |

**Hint Rules:**
1. Maximum 1 hint per phrase
2. Hint cost is deducted from final phrase score
3. Hint cannot result in negative score (minimum 0)
4. Hint button disabled if using it would provide no benefit (e.g., already correct)

**Hint UI:**
```
┌─────────────────────────────────────┐
│  [Hint: Show First Word] (-3 pts)   │
└─────────────────────────────────────┘
```

**Implementation Note:** For MVP, the hint system is OPTIONAL. Can be added post-launch based on user feedback. If excluded, phrase scores remain as calculated without hint deductions.

---

## 3. Overall Scoring System

### 3.1 Complete Point Value Breakdown

#### Vocab Flash Duel Points

| Action | Points | Condition |
|--------|--------|-----------|
| Correct answer | +10 | Base points |
| Speed bonus (fast) | +5 | Answered in 0-2 seconds |
| Speed bonus (quick) | +3 | Answered in 3-5 seconds |
| Speed bonus (okay) | +1 | Answered in 6-7 seconds |
| Wrong answer | 0 | No penalty |
| Timeout | 0 | No penalty |

#### Phrase Builder Points

| Action | Points | Condition |
|--------|--------|-----------|
| Perfect phrase | +20 | 100% words correct |
| Partial phrase | +1 to +19 | Proportional to correctness |
| Time bonus (very fast) | +5 | Completed in <10 sec, 100% correct |
| Time bonus (good) | +2 | Completed in 10-20 sec, 100% correct |
| Hint used | -3 or -2 | Deducted from phrase score |

### 3.2 Speed Bonus Formula

**Vocab Flash Duel:**
```
speedBonus =
    if (10 - elapsedSeconds) >= 8: 5
    else if (10 - elapsedSeconds) >= 5: 3
    else if (10 - elapsedSeconds) >= 3: 1
    else: 0

totalQuestionScore = (isCorrect ? 10 : 0) + (isCorrect ? speedBonus : 0)
```

**Phrase Builder:**
```
timeBonus =
    if (30 - elapsedSeconds) >= 20 AND isPerfect: 5
    else if (30 - elapsedSeconds) >= 10 AND isPerfect: 2
    else: 0

totalPhraseScore = baseScore + timeBonus - hintCost
```

**Speed Bonus Examples:**

| Game | Time Taken | Correct? | Base | Bonus | Total |
|------|------------|----------|------|-------|-------|
| Vocab Flash | 1.5 sec | Yes | 10 | +5 | 15 |
| Vocab Flash | 4 sec | Yes | 10 | +3 | 13 |
| Vocab Flash | 7 sec | Yes | 10 | +1 | 11 |
| Vocab Flash | 9 sec | Yes | 10 | +0 | 10 |
| Vocab Flash | Any | No | 0 | 0 | 0 |
| Phrase Builder | 8 sec | 100% | 20 | +5 | 25 |
| Phrase Builder | 15 sec | 100% | 20 | +2 | 22 |
| Phrase Builder | 25 sec | 100% | 20 | +0 | 20 |
| Phrase Builder | 12 sec | 75% | 15 | +0 | 15 |

### 3.3 Streak Bonuses (Optional Enhancement)

**For MVP:** Streak bonuses are NOT included to keep scoring simple and transparent.

**Future Enhancement (Post-MVP):**

| Streak Length | Bonus | Description |
|---------------|-------|-------------|
| 3 correct in a row | +2 | "Hat Trick" |
| 5 correct in a row | +5 | "On Fire" |

### 3.4 Score Display

**During Gameplay:**

| Moment | What's Shown | Duration |
|--------|--------------|----------|
| After each answer | Points earned for that question | 2 seconds |
| After each turn | Player's round subtotal | On transition screen |
| During mini-game | Running total (both players) | Always visible in header |

**Score Display Format:**
```
┌─────────────────────────────────────┐
│  Maria: 45       |      Pedro: 38  │
└─────────────────────────────────────┘
```

**Feedback Display After Answer:**
```
┌─────────────────────────────────────┐
│          CORRECT!                   │
│                                     │
│          +10 points                 │
│          +3 speed bonus             │
│          ─────────────              │
│          = 13 points                │
│                                     │
│     Total: 58 points                │
└─────────────────────────────────────┘
```

### 3.5 Final Score Calculation

**Formula:**
```
FinalScore = VocabFlashScore + PhraseBuilderScore

Where:
- VocabFlashScore = Sum of all 5 question scores (0-75 possible)
- PhraseBuilderScore = Sum of all 3 phrase scores (0-75 possible)

Maximum possible score per player: 150 points
```

**Score Breakdown on Results Screen:**

| Player | Vocab Flash | Phrase Builder | Total |
|--------|-------------|----------------|-------|
| Maria | 52 pts | 48 pts | **100 pts** |
| Pedro | 45 pts | 55 pts | **100 pts** |

---

## 4. Round & Match Structure

### 4.1 Match Format

**Definition of Terms:**
- **Match:** A complete game session between two players
- **Mini-game:** A specific game type (Vocab Flash Duel or Phrase Builder)
- **Turn:** One player's complete set of questions within a mini-game

**Match Structure:**
```
┌─────────────────────────────────────────────────────────────────────┐
│                        COMPLETE MATCH                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  MINI-GAME 1: VOCAB FLASH DUEL                              │   │
│  │  ┌───────────────────┐    ┌───────────────────┐            │   │
│  │  │ Player 1 Turn     │ -> │ Player 2 Turn     │            │   │
│  │  │ 5 questions       │    │ 5 questions       │            │   │
│  │  └───────────────────┘    └───────────────────┘            │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              |                                      │
│                              v                                      │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  MINI-GAME TRANSITION                                       │   │
│  │  Show current standings, brief break                        │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              |                                      │
│                              v                                      │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  MINI-GAME 2: PHRASE BUILDER                                │   │
│  │  ┌───────────────────┐    ┌───────────────────┐            │   │
│  │  │ Player 1 Turn     │ -> │ Player 2 Turn     │            │   │
│  │  │ 3 phrases         │    │ 3 phrases         │            │   │
│  │  └───────────────────┘    └───────────────────┘            │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              |                                      │
│                              v                                      │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  RESULTS SCREEN                                             │   │
│  │  Final scores, winner announcement, play again option       │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 4.2 Round Structure

| Mini-Game | Questions/Phrases per Player | Total per Mini-Game | Time Estimate |
|-----------|------------------------------|---------------------|---------------|
| Vocab Flash Duel | 5 questions | 10 questions | ~3-4 minutes |
| Phrase Builder | 3 phrases | 6 phrases | ~4-5 minutes |
| **Total Match** | 8 items per player | 16 items | **~8-10 minutes** |

### 4.3 Turn Order

**First Player Determination:**
- **MVP:** Player 1 (entered first in setup) always goes first in the first mini-game
- **Fairness Swap:** Player 2 goes first in the second mini-game

**Turn Order Sequence:**
```
Mini-Game 1 (Vocab Flash):
  1. Player 1: 5 questions
  2. [Turn Transition Screen]
  3. Player 2: 5 questions

Mini-Game 2 (Phrase Builder):
  1. Player 2: 3 phrases     <- Order swapped for fairness
  2. [Turn Transition Screen]
  3. Player 1: 3 phrases
```

**Turn Transition Protocol:**
1. Current player completes their turn
2. "Pass the phone to [Other Player Name]" screen appears
3. Previous answers are hidden (privacy)
4. New player taps "I'm Ready" button
5. 3-second countdown before questions begin

### 4.4 Mini-Game Sequence

| Order | Mini-Game | Rationale |
|-------|-----------|-----------|
| 1st | Vocab Flash Duel | Easier, builds confidence, warm-up |
| 2nd | Phrase Builder | More challenging, climactic finish |

**Rationale for Order:**
- Starting with vocabulary gives players time to get comfortable
- Multiple-choice is cognitively easier than construction
- Building to phrase construction creates narrative arc
- Phrase Builder's higher time limit (30s vs 10s) allows catch-up potential

### 4.5 Fairness Considerations

**Content Fairness:**
1. **Different questions, equivalent difficulty:** Players do not see the same questions, but questions are drawn from the same pool with similar difficulty distribution
2. **No repeat advantage:** If a word appears in Vocab Flash, it may appear in Phrase Builder, but this benefits both players equally
3. **Randomization:** Question order within each turn is randomized

**Position Fairness:**
1. **Turn order swap:** First player advantage in Mini-Game 1 is balanced by second player going first in Mini-Game 2
2. **Score visibility:** Both players can see current scores, so the second player knows what they need to beat (acceptable for hot-seat)

**Time Fairness:**
1. **Consistent timers:** Same time limits for both players
2. **Device consistency:** Both players use the same device, eliminating hardware advantage

**Question Pool Fairness:**
```
Total Greetings Deck: ~30 items
Vocab Flash needs: 10 unique items (5 per player)
Phrase Builder needs: 6 phrases (3 per player)

Items are assigned:
- Player 1 Vocab: Items 1-5 (shuffled)
- Player 2 Vocab: Items 6-10 (shuffled)
- Player 1 Phrases: Phrases 1-3 (shuffled)
- Player 2 Phrases: Phrases 4-6 (shuffled)

Both players get unique content, preventing memorization advantage.
```

---

## 5. Win/Loss/Tie Conditions

### 5.1 Winner Determination

**Primary Rule:** The player with the higher total score wins.

```
if Player1.totalScore > Player2.totalScore:
    winner = Player1
else if Player2.totalScore > Player1.totalScore:
    winner = Player2
else:
    result = TIE
```

**Victory Display:**
```
┌─────────────────────────────────────┐
│                                     │
│           WINNER!                   │
│                                     │
│        [Player Avatar]              │
│                                     │
│           MARIA                     │
│                                     │
│         105 points                  │
│                                     │
│    vs Pedro's 98 points             │
│                                     │
└─────────────────────────────────────┘
```

### 5.2 Tiebreaker Rules

**MVP Approach:** Ties are celebrated, not broken.

**If scores are equal:**
1. Display "IT'S A TIE!" with celebration animation
2. Show both players as co-winners
3. No sudden death or tiebreaker questions

**Tie Display:**
```
┌─────────────────────────────────────┐
│                                     │
│         IT'S A TIE!                │
│                                     │
│    [Player 1]    [Player 2]        │
│      Maria         Pedro           │
│                                     │
│        100    =    100             │
│       points      points           │
│                                     │
│      Both of you win!              │
│                                     │
└─────────────────────────────────────┘
```

**Rationale:**
- Learning is the real goal; ties celebrate mutual achievement
- Avoids prolonging gameplay unnecessarily
- Reduces competitive pressure for A1 learners
- Keeps match time predictable

**Future Enhancement (Post-MVP):**
Optional tiebreaker modes:
- Sudden death: One question each, first to answer correctly wins
- Speed comparison: Who completed faster in total across both games

### 5.3 Edge Cases

#### Edge Case 1: Both Players Score Zero

| Scenario | Handling |
|----------|----------|
| Both players answer all questions wrong | Display as tie (0-0) with encouraging message |
| Message | "A perfect tie! Let's learn together next time!" |

#### Edge Case 2: Player Disconnects / Leaves

| Scenario | Handling |
|----------|----------|
| App backgrounded during timer | Timer continues; auto-submit on return if expired |
| App force-quit mid-game | MVP: Game state lost, must restart |
| Future: Game state persisted | Resume from last completed question |

#### Edge Case 3: Identical Names Entered

| Scenario | Handling |
|----------|----------|
| Both players enter "Maria" | Allow it; use "Maria (P1)" and "Maria (P2)" for display |
| Alternative | Prevent identical names with validation message |

#### Edge Case 4: Very Fast Completion

| Scenario | Handling |
|----------|----------|
| Player answers all questions in <30 seconds total | Award all earned points; proceed normally |
| Both players very fast | Shorter game is fine; speed bonuses reward skill |

#### Edge Case 5: Timer Edge (Exactly 0)

| Scenario | Handling |
|----------|----------|
| Answer submitted at exactly 0.0 seconds | Accept as valid answer (edge-inclusive) |
| Timer hits 0 while animating tap | Accept if tap registered before timeout callback |

#### Edge Case 6: Network Issues (Future Online Mode)

| Scenario | Handling |
|----------|----------|
| MVP is local-only | No network considerations needed |
| Future online mode | Implement reconnection grace period |

---

## 6. Difficulty Balancing for A1 Learners

### 6.1 Beginner-Friendly Design Principles

**Principle 1: Forgiveness Over Punishment**
- No negative points for wrong answers
- Timeout results in 0, not penalty
- Partial credit in Phrase Builder rewards effort

**Principle 2: Generous Time Limits**
- 10 seconds per vocabulary question (ample for reading)
- 30 seconds per phrase (enough to think and arrange)
- Warning indicators before timeout

**Principle 3: Clear Visual Feedback**
- Large, readable fonts (minimum 18sp for content)
- High contrast colors
- Obvious tap targets (minimum 48dp)

**Principle 4: Recognition Over Recall**
- Multiple choice (recognize correct answer) vs. free typing (recall exact spelling)
- Rearranging (recognize word order) vs. constructing (recall all words)

### 6.2 Feedback Design

**Correct Answer Feedback:**
```
┌─────────────────────────────────────┐
│                                     │
│         ✓ CORRECT!                 │
│                                     │
│         "Bon dia"                   │
│          means                      │
│        "Kalimera"                   │
│         (Good morning)              │
│                                     │
│         +13 points                  │
│                                     │
└─────────────────────────────────────┘
```

**Wrong Answer Feedback:**
```
┌─────────────────────────────────────┐
│                                     │
│         Not quite!                  │
│                                     │
│     You selected: "Adeu"            │
│                                     │
│     Correct answer: "Bon dia"       │
│                                     │
│     "Kalimera" = "Bon dia"          │
│        (Good morning)               │
│                                     │
│     Keep going! You've got this!    │
│                                     │
└─────────────────────────────────────┘
```

**Key Feedback Elements:**
1. **Neutral tone for wrong answers:** "Not quite!" instead of "Wrong!"
2. **Always show correct answer:** Learning opportunity, not just judgment
3. **Include translation in both directions:** Reinforces the correct pairing
4. **Encouraging message:** "Keep going!" or "You're learning!"

### 6.3 Encouragement Mechanics

**During Gameplay:**

| Situation | Encouragement |
|-----------|---------------|
| First correct answer | "Great start!" |
| Correct after wrong | "Nice comeback!" |
| Fast answer | "Lightning fast!" |
| Slow but correct | "Take your time - you got it!" |
| Multiple wrong in a row | "You're learning! Keep trying!" |
| Near miss (close answer) | "So close! [Correct answer] is similar" |

**End of Turn:**

| Score Range | Message |
|-------------|---------|
| 80%+ correct | "Excellent work!" |
| 60-79% correct | "Good job!" |
| 40-59% correct | "Nice effort! Practice makes perfect." |
| Below 40% | "Great try! You're building your vocabulary!" |

**End of Match (for losing player):**

| Margin | Message |
|--------|---------|
| Lost by <10 points | "So close! A true duel!" |
| Lost by 10-30 points | "Great competition! Ready for a rematch?" |
| Lost by >30 points | "Great practice! You learned a lot today!" |

### 6.4 Learning Reinforcement

**Spaced Repetition Hints (Future):**
For MVP, we focus on immediate reinforcement:

**Immediate Reinforcement Strategies:**

| Strategy | Implementation |
|----------|----------------|
| **Show correct answer always** | Even when correct, display the pairing |
| **Bilingual display** | Source + target + transliteration when helpful |
| **Visual association** | Consistent color coding (Greek = blue, Catalan = orange) |
| **Audio hooks** | Prepared for future audio pronunciation |

**Within-Game Reinforcement:**
- Words that appear in Vocab Flash may appear in Phrase Builder
- Seeing the same word in different contexts aids retention
- Example: "Hola" in vocab, "Hola, com estas?" in phrase builder

**Post-Game Reinforcement (Future Enhancement):**
```
┌─────────────────────────────────────┐
│     Words You're Learning           │
│                                     │
│  ┌─────────┐  ┌─────────┐          │
│  │ Kalimera │  │ Bon dia │          │
│  │  ───>    │  │  ───>   │          │
│  │ Bon dia  │  │ Kalimera │          │
│  └─────────┘  └─────────┘          │
│       3/3         2/3              │
│                                     │
│     Tap to review                   │
└─────────────────────────────────────┘
```

### 6.5 A1-Specific Accommodations

| Accommodation | Description |
|---------------|-------------|
| **No grammar complexity** | Phrases use simple structure |
| **High-frequency words** | Only common greetings/phrases |
| **Phonetic aids** | Transliteration provided for non-Latin scripts |
| **Cultural context** | Brief cultural notes where relevant |
| **No slang** | Standard language only for beginners |
| **Clear word boundaries** | Each word is a distinct, tappable tile |

**Phonetic Display Example:**
```
Greek: Καλημέρα
Romanization: Kalimera
Pronunciation: kah-lee-MEH-rah

Catalan: Bon dia
Pronunciation: bon DEE-ah
```

---

## Appendix A: Scoring Quick Reference

### Vocab Flash Duel

| Outcome | Base | Speed Bonus | Max |
|---------|------|-------------|-----|
| Correct (0-2s) | 10 | +5 | 15 |
| Correct (3-5s) | 10 | +3 | 13 |
| Correct (6-7s) | 10 | +1 | 11 |
| Correct (8-10s) | 10 | +0 | 10 |
| Wrong/Timeout | 0 | 0 | 0 |

**Per player per game: 5 questions = 0-75 points possible**

### Phrase Builder

| Outcome | Base | Time Bonus | Max |
|---------|------|------------|-----|
| 100% correct (<10s) | 20 | +5 | 25 |
| 100% correct (10-20s) | 20 | +2 | 22 |
| 100% correct (>20s) | 20 | +0 | 20 |
| 75% correct | 15 | 0 | 15 |
| 50% correct | 10 | 0 | 10 |
| 25% correct | 5 | 0 | 5 |

**Per player per game: 3 phrases = 0-75 points possible**

### Match Total

| Game | Max per Player |
|------|----------------|
| Vocab Flash | 75 |
| Phrase Builder | 75 |
| **Total** | **150** |

---

## Appendix B: Implementation Checklist

### Vocab Flash Duel
- [ ] Question display with source word
- [ ] Four option buttons with randomized positions
- [ ] 10-second countdown timer with visual states
- [ ] Answer validation and immediate feedback
- [ ] Speed bonus calculation
- [ ] Score tracking and display
- [ ] 5-question round management
- [ ] Distractor generation from same deck

### Phrase Builder
- [ ] Phrase display with source sentence
- [ ] Draggable word tiles
- [ ] 30-second countdown timer
- [ ] Scrambling algorithm (never correct order)
- [ ] Order validation with position tracking
- [ ] Partial credit calculation
- [ ] Time bonus for perfect answers
- [ ] 3-phrase round management
- [ ] Optional: Hint system

### Scoring System
- [ ] Real-time score updates
- [ ] Speed/time bonus calculations
- [ ] Score display in header
- [ ] Post-answer score breakdown
- [ ] Final score aggregation

### Match Flow
- [ ] Turn transition screens with privacy
- [ ] Mini-game transition with standings
- [ ] Turn order management (swap for game 2)
- [ ] Results screen with winner/tie display
- [ ] Play again functionality

### UX/Feedback
- [ ] Correct answer celebration
- [ ] Wrong answer encouragement
- [ ] Always show correct answer
- [ ] Encouraging messages
- [ ] Timer warning states

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-26 | Game Design Agent | Initial document creation |

---

*This document serves as the authoritative reference for game mechanics in the Language Duel MVP. All implementation decisions should align with these specifications. Any deviations should be documented and approved.*
