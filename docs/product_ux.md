# Language Duel MVP - Product & UX Specification

**Version:** 1.0
**Last Updated:** 2026-01-26
**Document Owner:** Product/UX Agent
**Project:** Language Duel - Competitive Language Learning Game
**Mode:** Single-phone hot-seat (two players share one device)
**Languages:** Greek <-> Catalan, A1 beginner level
**Tech Stack:** Flutter (Android & iOS)

---

## Table of Contents

1. [User Flow Diagram](#1-user-flow-diagram)
2. [Screen-by-Screen Wireframes](#2-screen-by-screen-wireframes)
3. [Turn Handoff UX Specification](#3-turn-handoff-ux-specification)
4. [Component Library Spec](#4-component-library-spec)
5. [Accessibility Guidelines](#5-accessibility-guidelines)
6. [Error States & Edge Cases](#6-error-states--edge-cases)

---

## 1. User Flow Diagram

### 1.1 Complete Application Flow

```
                                    ┌─────────────────────┐
                                    │    APP LAUNCH       │
                                    │   (Splash Screen)   │
                                    └──────────┬──────────┘
                                               │
                                               ▼
                                    ┌─────────────────────┐
                                    │    HOME SCREEN      │
                                    │  "Start New Duel"   │
                                    │  "How to Play"      │
                                    └──────────┬──────────┘
                                               │
                                               ▼
                                    ┌─────────────────────┐
                                    │   PLAYER SETUP      │
                                    │  Enter P1 Name      │
                                    │  Enter P2 Name      │
                                    │  Select Languages   │
                                    └──────────┬──────────┘
                                               │
                               ┌───────────────┴───────────────┐
                               │         Validation            │
                               │   Names valid? (non-empty)    │
                               └───────────────┬───────────────┘
                                       │ YES           │ NO
                                       ▼               ▼
                        ┌─────────────────────┐   ┌──────────┐
                        │   DECK SELECTION    │   │  Error   │
                        │  "Greetings" deck   │   │  Toast   │
                        │  (MVP: single deck) │   └────┬─────┘
                        └──────────┬──────────┘        │
                                   │                   │
                                   │              (return)
                                   ▼
                        ┌─────────────────────┐
                        │    DUEL HUB         │
                        │  Round X of Y       │
                        │  Current Scores     │
                        │  Current Player     │
                        └──────────┬──────────┘
                                   │
           ┌───────────────────────┴───────────────────────┐
           │                                               │
           ▼                                               ▼
┌─────────────────────┐                     ┌─────────────────────┐
│   VOCAB FLASH       │                     │   PHRASE BUILDER    │
│   DUEL SCREEN       │                     │      SCREEN         │
│  (5 Qs per player)  │                     │  (3 phrases/player) │
└──────────┬──────────┘                     └──────────┬──────────┘
           │                                           │
           │    ┌──────────────────────────────────────┘
           │    │
           ▼    ▼
┌─────────────────────┐
│  ANSWER FEEDBACK    │
│  Correct/Incorrect  │
│  Points Awarded     │
│  +Speed Bonus?      │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DECISION: More Questions?                   │
│              Current player has more questions in round?         │
└─────────────────────────────────┬───────────────────────────────┘
                          │ YES           │ NO
                          ▼               ▼
              ┌──────────────────┐  ┌─────────────────────┐
              │   Next Question  │  │  End of Player Turn │
              │   (same player)  │  └──────────┬──────────┘
              └────────┬─────────┘             │
                       │                       ▼
                  (loop back)    ┌─────────────────────────────────┐
                                 │   DECISION: More Players?       │
                                 │   Other player needs turn?      │
                                 └─────────────┬───────────────────┘
                                       │ YES           │ NO
                                       ▼               ▼
                        ┌─────────────────────┐  ┌──────────────────┐
                        │  TURN TRANSITION    │  │ DECISION:        │
                        │  "Pass to [Name]"   │  │ More Mini-games? │
                        │  Privacy Screen     │  └────────┬─────────┘
                        └──────────┬──────────┘           │
                                   │               YES    │    NO
                                   │                │     │
                                   ▼                ▼     ▼
                        ┌─────────────────────┐  ┌──────────────────┐
                        │   READY CONFIRM     │  │ RESULTS SCREEN   │
                        │  "[Name] Ready?"    │  │ Final Scores     │
                        │  [I'm Ready] btn    │  │ Winner/Tie       │
                        └──────────┬──────────┘  │ Play Again btn   │
                                   │             └────────┬─────────┘
                                   │                      │
                              (loop to                    │
                               Duel Hub)                  │
                                                         ▼
                                              ┌─────────────────────┐
                                              │  Back to Home or    │
                                              │  New Game Setup     │
                                              └─────────────────────┘
```

### 1.2 Mini-Game Flow Detail: Vocab Flash Duel

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         VOCAB FLASH DUEL FLOW                           │
└─────────────────────────────────────────────────────────────────────────┘

    ┌───────────────────┐
    │  Load Question    │
    │  from Deck        │
    └─────────┬─────────┘
              │
              ▼
    ┌───────────────────┐
    │  Display Card:    │
    │  - Source word    │
    │  - 4 options      │
    │  - Start timer    │
    └─────────┬─────────┘
              │
    ┌─────────┴─────────┐
    │                   │
    ▼                   ▼
┌───────────┐    ┌───────────────┐
│ User Taps │    │ Timer Expires │
│ an Option │    │   (10 sec)    │
└─────┬─────┘    └───────┬───────┘
      │                  │
      ▼                  ▼
┌───────────────┐  ┌───────────────┐
│ Check Answer  │  │ Auto-Submit   │
│ Calculate:    │  │ Wrong Answer  │
│ - Base pts    │  │ 0 points      │
│ - Speed bonus │  └───────┬───────┘
└───────┬───────┘          │
        │                  │
        └────────┬─────────┘
                 │
                 ▼
        ┌───────────────────┐
        │  Show Feedback:   │
        │  - Correct/Wrong  │
        │  - Points earned  │
        │  - Correct answer │
        │  (2 sec display)  │
        └─────────┬─────────┘
                  │
                  ▼
        ┌───────────────────┐
        │  Q < 5?           │─── YES ──> Loop to "Load Question"
        └─────────┬─────────┘
                  │ NO
                  ▼
        ┌───────────────────┐
        │  End Player Turn  │
        └───────────────────┘
```

### 1.3 Mini-Game Flow Detail: Phrase Builder

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        PHRASE BUILDER FLOW                              │
└─────────────────────────────────────────────────────────────────────────┘

    ┌───────────────────┐
    │  Load Phrase      │
    │  from Deck        │
    └─────────┬─────────┘
              │
              ▼
    ┌───────────────────┐
    │  Display:         │
    │  - Source phrase  │
    │  - Scrambled      │
    │    word tiles     │
    │  - Start timer    │
    └─────────┬─────────┘
              │
              ▼
    ┌───────────────────┐
    │  User Interaction │◄──────────────┐
    │  - Drag tiles     │               │
    │  - Reorder words  │               │
    └─────────┬─────────┘               │
              │                         │
    ┌─────────┴─────────┐               │
    │                   │               │
    ▼                   ▼               │
┌───────────┐    ┌───────────────┐      │
│ User Taps │    │ Timer Expires │      │
│ "Submit"  │    │   (30 sec)    │      │
└─────┬─────┘    └───────┬───────┘      │
      │                  │              │
      │                  │              │
      ▼                  ▼              │
┌───────────────────────────────┐       │
│  Validate Order               │       │
│  Calculate Score:             │       │
│  - Full correct: 20 pts       │       │
│  - Partial: % of correct pos  │       │
│  - Time bonus if < 15 sec     │       │
└─────────────┬─────────────────┘       │
              │                         │
              ▼                         │
     ┌───────────────────┐              │
     │  Show Feedback:   │              │
     │  - Score earned   │              │
     │  - Correct order  │              │
     │  (3 sec display)  │              │
     └─────────┬─────────┘              │
               │                        │
               ▼                        │
     ┌───────────────────┐              │
     │  Phrase < 3?      │─── YES ──────┘
     └─────────┬─────────┘
               │ NO
               ▼
     ┌───────────────────┐
     │  End Player Turn  │
     └───────────────────┘
```

### 1.4 Complete Game Session Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    COMPLETE DUEL SESSION                                │
│                    (Both Mini-Games, Both Players)                      │
└─────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────┐
│  MINI-GAME 1: VOCAB FLASH DUEL                                          │
│                                                                          │
│  Round 1:  P1 answers 5 questions ──> Transition ──> P2 answers 5 Qs    │
│                                                                          │
│  [P1: +45 pts]                        [P2: +35 pts]                      │
└──────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
                          ┌─────────────────┐
                          │ Mini-Game Break │
                          │ Show Standings  │
                          └────────┬────────┘
                                   │
                                   ▼
┌──────────────────────────────────────────────────────────────────────────┐
│  MINI-GAME 2: PHRASE BUILDER                                            │
│                                                                          │
│  Round 2:  P1 builds 3 phrases ──> Transition ──> P2 builds 3 phrases   │
│                                                                          │
│  [P1: +50 pts]                        [P2: +60 pts]                      │
└──────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
                          ┌─────────────────┐
                          │  FINAL RESULTS  │
                          │  P1: 95 pts     │
                          │  P2: 95 pts     │
                          │  IT'S A TIE!    │
                          └─────────────────┘
```

---

## 2. Screen-by-Screen Wireframes

### 2.1 Home Screen

```
┌─────────────────────────────────────────────────────────────────┐
│                         STATUS BAR                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                                                                 │
│                                                                 │
│                    ╔═══════════════════╗                        │
│                    ║                   ║                        │
│                    ║     [APP LOGO]    ║                        │
│                    ║                   ║                        │
│                    ╚═══════════════════╝                        │
│                                                                 │
│                      LANGUAGE DUEL                              │
│                                                                 │
│                   Greek <-> Catalan                             │
│                                                                 │
│                                                                 │
│                                                                 │
│              ┌─────────────────────────────┐                    │
│              │                             │                    │
│              │      START NEW DUEL         │                    │
│              │                             │                    │
│              └─────────────────────────────┘                    │
│                      [Primary Button]                           │
│                                                                 │
│                                                                 │
│              ┌─────────────────────────────┐                    │
│              │                             │                    │
│              │       HOW TO PLAY           │                    │
│              │                             │                    │
│              └─────────────────────────────┘                    │
│                     [Secondary Button]                          │
│                                                                 │
│                                                                 │
│                                                                 │
│                                                                 │
│─────────────────────────────────────────────────────────────────│
│                        v1.0.0 MVP                               │
└─────────────────────────────────────────────────────────────────┘
```

**Home Screen Specification:**

| Zone | Content | Details |
|------|---------|---------|
| Header | Status bar | System status bar (time, battery, etc.) |
| Body - Top | App Logo | Centered, 120x120dp, with drop shadow |
| Body - Title | App Name | "LANGUAGE DUEL" - 32sp, bold, primary color |
| Body - Subtitle | Language Pair | "Greek <-> Catalan" - 16sp, secondary color |
| Body - Center | Primary CTA | "START NEW DUEL" - Full width with 24dp margins |
| Body - Below | Secondary CTA | "HOW TO PLAY" - Outlined button style |
| Footer | Version | "v1.0.0 MVP" - 12sp, tertiary color |

**Interactions:**
- Tap "START NEW DUEL" -> Navigate to Player Setup Screen
- Tap "HOW TO PLAY" -> Show modal/bottom sheet with instructions

---

### 2.2 Player Setup Screen

```
┌─────────────────────────────────────────────────────────────────┐
│  [<]                    PLAYER SETUP                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                                                                 │
│       ┌──────────────────────────────────────────────┐          │
│       │  PLAYER 1                                    │          │
│       │                                              │          │
│       │  ┌────────────────────────────────────────┐  │          │
│       │  │                                        │  │          │
│       │  │    Enter name...                       │  │          │
│       │  │                                        │  │          │
│       │  └────────────────────────────────────────┘  │          │
│       │                                              │          │
│       │  Learning:  [Catalan ▼]                      │          │
│       │                                              │          │
│       └──────────────────────────────────────────────┘          │
│              [Player 1 Card - Blue accent]                      │
│                                                                 │
│                                                                 │
│       ┌──────────────────────────────────────────────┐          │
│       │  PLAYER 2                                    │          │
│       │                                              │          │
│       │  ┌────────────────────────────────────────┐  │          │
│       │  │                                        │  │          │
│       │  │    Enter name...                       │  │          │
│       │  │                                        │  │          │
│       │  └────────────────────────────────────────┘  │          │
│       │                                              │          │
│       │  Learning:  [Greek ▼]                        │          │
│       │                                              │          │
│       └──────────────────────────────────────────────┘          │
│              [Player 2 Card - Orange accent]                    │
│                                                                 │
│                                                                 │
│                                                                 │
│              ┌─────────────────────────────┐                    │
│              │                             │                    │
│              │        CONTINUE             │                    │
│              │                             │                    │
│              └─────────────────────────────┘                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Player Setup Screen Specification:**

| Zone | Content | Details |
|------|---------|---------|
| Header | Back button + Title | "[<] PLAYER SETUP" - 20sp, centered title |
| Body - P1 Card | Player 1 input | Card with blue left accent (4dp border) |
| P1 - Label | "PLAYER 1" | 14sp, uppercase, blue color |
| P1 - Input | Text field | Hint: "Enter name...", max 20 chars |
| P1 - Language | Dropdown | "Learning: [Catalan]" |
| Body - P2 Card | Player 2 input | Card with orange left accent (4dp border) |
| P2 - Label | "PLAYER 2" | 14sp, uppercase, orange color |
| P2 - Input | Text field | Hint: "Enter name...", max 20 chars |
| P2 - Language | Dropdown | "Learning: [Greek]" |
| Footer | Continue button | Primary button, disabled until both names entered |

**Interactions:**
- Back button -> Return to Home Screen
- Name fields -> On focus, show keyboard
- Language dropdowns -> In MVP, auto-linked (P1=Catalan means P2=Greek)
- Continue button -> Validate names, navigate to Deck Selection

**Validation Rules:**
- Name must be 1-20 characters
- Name must not be only whitespace
- Both names must be filled

---

### 2.3 Deck Selection Screen (MVP Simplified)

```
┌─────────────────────────────────────────────────────────────────┐
│  [<]                   SELECT DECK                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                                                                 │
│        Choose your vocabulary deck:                             │
│                                                                 │
│                                                                 │
│       ┌──────────────────────────────────────────────┐          │
│       │  ┌────────┐                                  │          │
│       │  │        │   GREETINGS                      │          │
│       │  │  [Hi]  │                                  │          │
│       │  │  icon  │   30 items                       │          │
│       │  │        │   A1 Beginner                    │          │
│       │  └────────┘                                  │          │
│       │                                        [✓]   │          │
│       └──────────────────────────────────────────────┘          │
│              [Selected Deck Card]                               │
│                                                                 │
│                                                                 │
│       ┌──────────────────────────────────────────────┐          │
│       │  ┌────────┐                                  │          │
│       │  │        │   NUMBERS                        │          │
│       │  │ [123]  │                                  │          │
│       │  │  icon  │   Coming Soon                    │          │
│       │  │        │                                  │          │
│       │  └────────┘                                  │          │
│       │                                     [LOCK]   │          │
│       └──────────────────────────────────────────────┘          │
│              [Locked Deck Card - Greyed out]                    │
│                                                                 │
│                                                                 │
│                                                                 │
│              ┌─────────────────────────────────────┐            │
│              │                                     │            │
│              │         START DUEL                  │            │
│              │                                     │            │
│              └─────────────────────────────────────┘            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Deck Selection Screen Specification:**

| Zone | Content | Details |
|------|---------|---------|
| Header | Back button + Title | "[<] SELECT DECK" |
| Body - Instruction | Help text | "Choose your vocabulary deck:" - 16sp |
| Body - Deck Card | Available deck | Elevated card with deck info |
| Deck - Icon | Deck visual | 64x64dp icon representing theme |
| Deck - Title | Deck name | "GREETINGS" - 18sp, bold |
| Deck - Info | Item count | "30 items" - 14sp |
| Deck - Level | Difficulty | "A1 Beginner" - 12sp, chip style |
| Deck - Selected | Checkmark | Blue checkmark when selected |
| Body - Locked | Future decks | Greyed out with lock icon, "Coming Soon" |
| Footer | Start button | "START DUEL" - Primary button |

**MVP Note:** Only "Greetings" deck is available. Other decks shown as locked to hint at future content.

---

### 2.4 Duel Hub / Game Screen

```
┌─────────────────────────────────────────────────────────────────┐
│                         DUEL IN PROGRESS                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│     ┌───────────────────────────────────────────────────┐       │
│     │    [P1 Avatar]          VS         [P2 Avatar]    │       │
│     │      Maria                           Jordi        │       │
│     │       45                              35          │       │
│     │    [Blue bg]                      [Orange bg]     │       │
│     └───────────────────────────────────────────────────┘       │
│                      [Score Display Bar]                        │
│                                                                 │
│─────────────────────────────────────────────────────────────────│
│                                                                 │
│                     ROUND 1 OF 2                                │
│                    Vocab Flash Duel                             │
│                                                                 │
│                   Question 3 of 5                               │
│                                                                 │
│─────────────────────────────────────────────────────────────────│
│                                                                 │
│                        ┌─────────┐                              │
│                        │  0:07   │                              │
│                        └─────────┘                              │
│                         [Timer]                                 │
│                                                                 │
│        ┌─────────────────────────────────────────────┐          │
│        │                                             │          │
│        │                                             │          │
│        │              Καλημέρα                       │          │
│        │                                             │          │
│        │              (kalimera)                     │          │
│        │                                             │          │
│        │                                             │          │
│        └─────────────────────────────────────────────┘          │
│                      [Flash Card]                               │
│                                                                 │
│     ┌────────────────────────┐  ┌────────────────────────┐      │
│     │                        │  │                        │      │
│     │      Bon dia           │  │      Bona nit          │      │
│     │                        │  │                        │      │
│     └────────────────────────┘  └────────────────────────┘      │
│              [Option A]                  [Option B]             │
│                                                                 │
│     ┌────────────────────────┐  ┌────────────────────────┐      │
│     │                        │  │                        │      │
│     │      Adeu              │  │      Hola              │      │
│     │                        │  │                        │      │
│     └────────────────────────┘  └────────────────────────┘      │
│              [Option C]                  [Option D]             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Duel Hub Screen Specification:**

| Zone | Content | Details |
|------|---------|---------|
| Header | Title | "DUEL IN PROGRESS" - No back button during game |
| Score Bar | Player badges | Side-by-side score cards with avatars |
| Score - P1 | Player 1 info | Name + Score, blue accent background |
| Score - P2 | Player 2 info | Name + Score, orange accent background |
| Score - VS | Separator | "VS" centered between players |
| Progress | Round info | "ROUND 1 OF 2" - Current mini-game name |
| Progress | Question | "Question 3 of 5" - Within round progress |
| Timer | Countdown | Large timer display, changes color when <3s |
| Card | Question | Source language word with phonetic hint |
| Options | 4 choices | 2x2 grid of answer buttons |

**Visual States:**
- Timer normal: Black text
- Timer warning (<3s): Red text, pulse animation
- Selected option: Highlighted border
- Current player: Their score card has glow/emphasis

---

### 2.5 Turn Transition Screen

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                                                                 │
│                                                                 │
│                                                                 │
│                                                                 │
│                                                                 │
│                    ╔═══════════════════════╗                    │
│                    ║                       ║                    │
│                    ║      PASS PHONE       ║                    │
│                    ║                       ║                    │
│                    ║          TO           ║                    │
│                    ║                       ║                    │
│                    ║        JORDI          ║                    │
│                    ║                       ║                    │
│                    ║   ┌───────────────┐   ║                    │
│                    ║   │  [Hand icon]  │   ║                    │
│                    ║   │   passing     │   ║                    │
│                    ║   └───────────────┘   ║                    │
│                    ║                       ║                    │
│                    ╚═══════════════════════╝                    │
│                      [Privacy Cover Card]                       │
│                                                                 │
│                                                                 │
│                                                                 │
│              ┌─────────────────────────────┐                    │
│              │                             │                    │
│              │      I'M READY, JORDI       │                    │
│              │                             │                    │
│              └─────────────────────────────┘                    │
│                 [Ready Button - Orange accent]                  │
│                                                                 │
│                                                                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Turn Transition Screen Specification:**

| Zone | Content | Details |
|------|---------|---------|
| Background | Privacy cover | Solid color background (no game content visible) |
| Body - Card | Transition message | Centered card with player name |
| Card - Title | "PASS PHONE" | 24sp, bold |
| Card - To | "TO" | 16sp |
| Card - Name | Next player name | 32sp, bold, player's accent color |
| Card - Icon | Hand/pass icon | 64x64dp animated handoff icon |
| Footer | Ready button | "I'M READY, [NAME]" with player's color |

**Critical Privacy Feature:** This screen completely covers all game content, preventing the previous player from seeing any answers or scores from the opponent.

---

### 2.6 Results Screen

```
┌─────────────────────────────────────────────────────────────────┐
│                         DUEL COMPLETE!                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                                                                 │
│                        ╔═════════════╗                          │
│                        ║   WINNER!   ║                          │
│                        ╚═════════════╝                          │
│                         [Trophy icon]                           │
│                                                                 │
│                                                                 │
│        ┌─────────────────────────────────────────────┐          │
│        │                                             │          │
│        │    ┌────────────┐      ┌────────────┐      │          │
│        │    │  [Avatar]  │      │  [Avatar]  │      │          │
│        │    │            │      │            │      │          │
│        │    │   Maria    │      │   Jordi    │      │          │
│        │    │            │      │            │      │          │
│        │    │    95      │      │    85      │      │          │
│        │    │   POINTS   │      │   POINTS   │      │          │
│        │    │  [WINNER]  │      │            │      │          │
│        │    └────────────┘      └────────────┘      │          │
│        │       [Blue]              [Orange]         │          │
│        │                                             │          │
│        └─────────────────────────────────────────────┘          │
│                       [Score Comparison Card]                   │
│                                                                 │
│        ┌─────────────────────────────────────────────┐          │
│        │  BREAKDOWN:                                 │          │
│        │  ──────────────────────────────────────     │          │
│        │  Vocab Flash:    Maria 45 - Jordi 35       │          │
│        │  Phrase Builder: Maria 50 - Jordi 50       │          │
│        └─────────────────────────────────────────────┘          │
│                      [Score Breakdown Card]                     │
│                                                                 │
│                                                                 │
│        ┌─────────────────────────────────────────────┐          │
│        │             PLAY AGAIN                      │          │
│        └─────────────────────────────────────────────┘          │
│                       [Primary Button]                          │
│                                                                 │
│        ┌─────────────────────────────────────────────┐          │
│        │             BACK TO HOME                    │          │
│        └─────────────────────────────────────────────┘          │
│                      [Secondary Button]                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Results Screen Specification:**

| Zone | Content | Details |
|------|---------|---------|
| Header | Title | "DUEL COMPLETE!" - 24sp, centered |
| Body - Banner | Winner announcement | "WINNER!" badge or "IT'S A TIE!" |
| Body - Icon | Trophy | 80x80dp trophy icon (or handshake for tie) |
| Body - Scores | Player comparison | Side-by-side final scores |
| Score - P1 | Player 1 final | Avatar, name, total points, WINNER badge if applicable |
| Score - P2 | Player 2 final | Avatar, name, total points |
| Body - Breakdown | Per-game scores | Collapsed/expandable score breakdown |
| Footer - Primary | Play Again | Starts new game with same players |
| Footer - Secondary | Back to Home | Returns to home screen |

**Winner Determination:**
- Higher score wins
- If tie: Display "IT'S A TIE!" with handshake icon
- Winner card gets crown/trophy overlay

---

### 2.7 Phrase Builder Game Screen

```
┌─────────────────────────────────────────────────────────────────┐
│                         DUEL IN PROGRESS                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│     ┌───────────────────────────────────────────────────┐       │
│     │    [P1 Avatar]          VS         [P2 Avatar]    │       │
│     │      Maria                           Jordi        │       │
│     │       95                              85          │       │
│     └───────────────────────────────────────────────────┘       │
│                                                                 │
│─────────────────────────────────────────────────────────────────│
│                     ROUND 2 OF 2                                │
│                    Phrase Builder                               │
│                   Phrase 2 of 3                                 │
│─────────────────────────────────────────────────────────────────│
│                                                                 │
│                        ┌─────────┐                              │
│                        │  0:22   │                              │
│                        └─────────┘                              │
│                                                                 │
│        ┌─────────────────────────────────────────────┐          │
│        │                                             │          │
│        │  Translate to Catalan:                      │          │
│        │                                             │          │
│        │        "Καλησπέρα, τι κάνεις;"             │          │
│        │         (kalispera, ti kanis?)              │          │
│        │                                             │          │
│        └─────────────────────────────────────────────┘          │
│                                                                 │
│        Build your answer:                                       │
│        ┌─────────────────────────────────────────────┐          │
│        │                                             │          │
│        │  ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐   │          │
│        │  │  com  │ │  tal? │ │       │ │       │   │          │
│        │  └───────┘ └───────┘ └───────┘ └───────┘   │          │
│        │                                             │          │
│        │           [Answer Drop Zone]                │          │
│        └─────────────────────────────────────────────┘          │
│                                                                 │
│        Available words:                                         │
│        ┌─────────────────────────────────────────────┐          │
│        │                                             │          │
│        │  ┌─────────┐  ┌─────────┐  ┌─────────┐     │          │
│        │  │ Bona    │  │ tarda,  │  │  com    │     │          │
│        │  └─────────┘  └─────────┘  └─────────┘     │          │
│        │                                             │          │
│        │  ┌─────────┐                               │          │
│        │  │  tal?   │                               │          │
│        │  └─────────┘                               │          │
│        │           [Word Tile Bank]                  │          │
│        └─────────────────────────────────────────────┘          │
│                                                                 │
│              ┌─────────────────────────────────────┐            │
│              │           SUBMIT ANSWER             │            │
│              └─────────────────────────────────────┘            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. Turn Handoff UX Specification

### 3.1 The Privacy Challenge

In hot-seat mode, preventing one player from seeing the other's performance is critical for fair gameplay. The turn handoff must:

1. **Completely obscure** the previous player's answer and result
2. **Provide clear indication** of who should now have the phone
3. **Require explicit confirmation** before showing the next question
4. **Feel smooth and intentional**, not disruptive

### 3.2 Turn Handoff Flow

```
┌──────────────────────────────────────────────────────────────────────┐
│                      TURN HANDOFF SEQUENCE                           │
└──────────────────────────────────────────────────────────────────────┘

Step 1: Answer Submitted
┌─────────────────────┐
│  Player A submits   │
│  their answer       │
│                     │
│  [Show feedback     │
│   for 2 seconds]    │
└──────────┬──────────┘
           │
           ▼
Step 2: Fade Out Animation (500ms)
┌─────────────────────┐
│  Game screen fades  │
│  to solid color     │
│  (player B's color) │
│                     │
│  [No content        │
│   visible]          │
└──────────┬──────────┘
           │
           ▼
Step 3: Privacy Screen (Hold)
┌─────────────────────┐
│  "PASS PHONE TO"    │
│  "[PLAYER B NAME]"  │
│                     │
│  Phone icon with    │
│  hand animation     │
│                     │
│  [Waiting for       │
│   ready tap]        │
└──────────┬──────────┘
           │
           │ (Player B taps "I'M READY")
           ▼
Step 4: Fade In Animation (300ms)
┌─────────────────────┐
│  Game screen fades  │
│  in with Player B's │
│  first question     │
│                     │
│  [Timer starts]     │
└─────────────────────┘
```

### 3.3 Privacy Screen Design

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  │
│  ▓                                                           ▓  │
│  ▓     ┌─────────────────────────────────────────────┐      ▓  │
│  ▓     │                                             │      ▓  │
│  ▓     │                                             │      ▓  │
│  ▓     │              PASS THE PHONE                 │      ▓  │
│  ▓     │                                             │      ▓  │
│  ▓     │                   TO                        │      ▓  │
│  ▓     │                                             │      ▓  │
│  ▓     │                 JORDI                       │      ▓  │
│  ▓     │                                             │      ▓  │
│  ▓     │            ┌───────────────┐                │      ▓  │
│  ▓     │            │     ╭──╮      │                │      ▓  │
│  ▓     │            │     │📱│  →   │                │      ▓  │
│  ▓     │            │     ╰──╯      │                │      ▓  │
│  ▓     │            └───────────────┘                │      ▓  │
│  ▓     │             [Animated phone                 │      ▓  │
│  ▓     │              passing icon]                  │      ▓  │
│  ▓     │                                             │      ▓  │
│  ▓     └─────────────────────────────────────────────┘      ▓  │
│  ▓                                                           ▓  │
│  ▓     ╔═════════════════════════════════════════════╗      ▓  │
│  ▓     ║                                             ║      ▓  │
│  ▓     ║         👆 I'M READY, JORDI!                ║      ▓  │
│  ▓     ║                                             ║      ▓  │
│  ▓     ╚═════════════════════════════════════════════╝      ▓  │
│  ▓                                                           ▓  │
│  ▓           (Make sure Maria can't see!)                   ▓  │
│  ▓                                                           ▓  │
│  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  │
│                                                                 │
│  Background: Solid color matching next player's theme           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 3.4 Ready Confirmation Flow

```
State 1: Waiting
┌──────────────────────────────────────┐
│  ╔════════════════════════════════╗  │
│  ║     I'M READY, JORDI!         ║  │
│  ║     [Normal state]            ║  │
│  ╚════════════════════════════════╝  │
│                                      │
│  Button: Elevated, player color      │
│  Interaction: Awaiting tap           │
└──────────────────────────────────────┘
         │
         │ (User taps button)
         ▼
State 2: Pressed
┌──────────────────────────────────────┐
│  ╔════════════════════════════════╗  │
│  ║     STARTING...               ║  │
│  ║     [Pressed state]           ║  │
│  ╚════════════════════════════════╝  │
│                                      │
│  Button: Depressed, ripple effect    │
│  Duration: 200ms                     │
└──────────────────────────────────────┘
         │
         │ (Transition animation)
         ▼
State 3: Transition
┌──────────────────────────────────────┐
│                                      │
│        [Fade out privacy screen]     │
│        [Fade in game screen]         │
│                                      │
│  Duration: 300ms                     │
│  Easing: ease-out                    │
└──────────────────────────────────────┘
         │
         ▼
State 4: Game Active
┌──────────────────────────────────────┐
│                                      │
│  [Next player's question visible]    │
│  [Timer starts immediately]          │
│                                      │
└──────────────────────────────────────┘
```

### 3.5 Privacy Considerations

| Risk | Mitigation |
|------|------------|
| Previous answer visible during transition | Solid color fade covers all content before showing transition screen |
| Scores visible to wrong player | Transition screen shows NO score information |
| Accidental "ready" tap | Button requires deliberate tap (no swipe, no double-tap trigger) |
| Peeking at answers | Animate phone-passing icon to encourage physical handoff |
| Previous player lingers | Add subtle text reminder "Make sure [previous player] can't see!" |

### 3.6 Animation Specifications

| Animation | Duration | Easing | Description |
|-----------|----------|--------|-------------|
| Feedback fade out | 500ms | ease-in | Game screen fades to solid color |
| Privacy screen fade in | 300ms | ease-out | Transition message appears |
| Phone icon animation | 1500ms | linear, looping | Phone moves left-to-right, suggesting handoff |
| Ready button ripple | 200ms | ease-out | Standard Material ripple effect |
| Game fade in | 300ms | ease-out | New question fades in |

---

## 4. Component Library Spec

### 4.1 Buttons

#### Primary Button (DuelPrimaryButton)

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│        Normal State:                                            │
│        ┌────────────────────────────────────────────┐           │
│        │█████████████████████████████████████████████│           │
│        │█                                          █│           │
│        │█           START NEW DUEL                 █│           │
│        │█                                          █│           │
│        │█████████████████████████████████████████████│           │
│        └────────────────────────────────────────────┘           │
│                                                                 │
│        Specs:                                                   │
│        - Height: 56dp                                           │
│        - Width: Full width - 48dp margins (24dp each side)      │
│        - Corner radius: 28dp (fully rounded)                    │
│        - Background: Primary color (#2196F3)                    │
│        - Text: White, 16sp, bold, uppercase                     │
│        - Shadow: elevation 4dp                                  │
│                                                                 │
│        Disabled State:                                          │
│        - Background: Grey (#BDBDBD)                             │
│        - Text: Dark grey (#757575)                              │
│        - Shadow: none                                           │
│                                                                 │
│        Pressed State:                                           │
│        - Background: Primary dark (#1976D2)                     │
│        - Shadow: elevation 8dp                                  │
│        - Ripple effect                                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

#### Secondary Button (DuelSecondaryButton)

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│        Normal State:                                            │
│        ┌────────────────────────────────────────────┐           │
│        │                                            │           │
│        │            HOW TO PLAY                     │           │
│        │                                            │           │
│        └────────────────────────────────────────────┘           │
│                                                                 │
│        Specs:                                                   │
│        - Height: 48dp                                           │
│        - Width: Full width - 48dp margins                       │
│        - Corner radius: 24dp                                    │
│        - Background: Transparent                                │
│        - Border: 2dp, Primary color                             │
│        - Text: Primary color, 14sp, medium                      │
│                                                                 │
│        Pressed State:                                           │
│        - Background: Primary color at 10% opacity               │
│        - Border: Primary dark                                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

#### Answer Option Button (AnswerOptionButton)

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│        Default State:                                           │
│        ┌────────────────────────────────────────────┐           │
│        │                                            │           │
│        │               Bon dia                      │           │
│        │                                            │           │
│        └────────────────────────────────────────────┘           │
│                                                                 │
│        Specs:                                                   │
│        - Height: 64dp                                           │
│        - Width: (screen width - 48dp) / 2 - 8dp gap             │
│        - Corner radius: 12dp                                    │
│        - Background: Surface (#FFFFFF)                          │
│        - Border: 1dp, Grey (#E0E0E0)                            │
│        - Text: Body1 color, 18sp, center                        │
│        - Shadow: elevation 2dp                                  │
│                                                                 │
│        Selected State:                                          │
│        - Border: 3dp, Primary color                             │
│        - Background: Primary at 5% opacity                      │
│                                                                 │
│        Correct State (after submit):                            │
│        - Background: Success green (#4CAF50)                    │
│        - Text: White                                            │
│        - Border: none                                           │
│                                                                 │
│        Incorrect State (after submit):                          │
│        - Background: Error red (#F44336)                        │
│        - Text: White                                            │
│        - Border: none                                           │
│        - Shake animation (100ms, 3 cycles)                      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 Cards

#### Flash Card (QuestionCard)

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│        ┌────────────────────────────────────────────────┐       │
│        │░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│       │
│        │░                                              ░│       │
│        │░                                              ░│       │
│        │░                 Καλημέρα                     ░│       │
│        │░                                              ░│       │
│        │░                (kalimera)                    ░│       │
│        │░                                              ░│       │
│        │░                                              ░│       │
│        │░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│       │
│        └────────────────────────────────────────────────┘       │
│                                                                 │
│        Specs:                                                   │
│        - Height: 180dp                                          │
│        - Width: Full width - 32dp margins                       │
│        - Corner radius: 16dp                                    │
│        - Background: Gradient (light blue to white)             │
│        - Shadow: elevation 4dp                                  │
│                                                                 │
│        Content:                                                 │
│        - Main text: 32sp, bold, centered                        │
│        - Phonetic hint: 16sp, italic, secondary color           │
│        - Padding: 24dp all sides                                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

#### Score Card (PlayerScoreCard)

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│        ┌────────────────────────┐                               │
│        │  ┌──────┐              │                               │
│        │  │      │   Maria      │                               │
│        │  │ [Av] │              │                               │
│        │  │      │     45       │                               │
│        │  └──────┘              │                               │
│        └────────────────────────┘                               │
│                                                                 │
│        Specs:                                                   │
│        - Width: 140dp                                           │
│        - Height: 80dp                                           │
│        - Corner radius: 12dp                                    │
│        - Background: White with left accent border              │
│        - Accent border: 4dp, player color (blue/orange)         │
│        - Shadow: elevation 2dp                                  │
│                                                                 │
│        Content:                                                 │
│        - Avatar: 40x40dp, circular, left aligned                │
│        - Name: 14sp, medium, truncate if > 10 chars             │
│        - Score: 24sp, bold, player color                        │
│                                                                 │
│        Active Player State:                                     │
│        - Outer glow: player color at 30% opacity                │
│        - Scale: 1.05x                                           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

#### Player Badge (PlayerBadge)

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│        ┌───────────────────────────┐                            │
│        │  [Avatar]   Maria         │                            │
│        │     P1      Learning: Cat │                            │
│        └───────────────────────────┘                            │
│                                                                 │
│        Specs:                                                   │
│        - Compact: 120dp x 48dp                                  │
│        - Expanded: Full width x 80dp                            │
│        - Corner radius: 8dp                                     │
│        - Background: Player color at 10%                        │
│        - Border: 2dp, player color                              │
│                                                                 │
│        Content:                                                 │
│        - Avatar: 32dp circle (compact) / 48dp (expanded)        │
│        - Name: 14sp, bold                                       │
│        - Subtitle: 12sp, secondary                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 4.3 Timer Display (GameTimer)

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│        Normal State (> 3 seconds):                              │
│                    ┌─────────────┐                              │
│                    │    0:07     │                              │
│                    └─────────────┘                              │
│                                                                 │
│        Warning State (<= 3 seconds):                            │
│                    ┌─────────────┐                              │
│                    │    0:03     │  ← Pulse animation           │
│                    └─────────────┘                              │
│                                                                 │
│        Expired State:                                           │
│                    ┌─────────────┐                              │
│                    │   TIME'S    │                              │
│                    │    UP!      │                              │
│                    └─────────────┘                              │
│                                                                 │
│        Specs:                                                   │
│        - Width: 100dp                                           │
│        - Height: 48dp                                           │
│        - Corner radius: 24dp (pill shape)                       │
│        - Background: Surface with subtle border                 │
│        - Text: 24sp, bold, monospace font                       │
│                                                                 │
│        States:                                                  │
│        - Normal: Black text                                     │
│        - Warning: Red text (#F44336), pulse scale 1.0-1.1       │
│        - Expired: Red background, white text                    │
│                                                                 │
│        Animations:                                              │
│        - Tick: Subtle scale pulse each second                   │
│        - Warning pulse: 500ms cycle                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 4.4 Score Display (ScoreDisplay)

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│        Inline Score:                                            │
│        ┌───────────────────────────────────────────────┐        │
│        │   Maria          VS          Jordi            │        │
│        │    45                         35              │        │
│        │  [Blue]                    [Orange]           │        │
│        └───────────────────────────────────────────────┘        │
│                                                                 │
│        Specs:                                                   │
│        - Height: 72dp                                           │
│        - Width: Full width                                      │
│        - Background: Surface with bottom border                 │
│        - Layout: 3-column (P1 | VS | P2)                        │
│                                                                 │
│        Score Change Animation:                                  │
│        - Number counts up from old to new value                 │
│        - Duration: 500ms                                        │
│        - Scale pop: 1.0 -> 1.2 -> 1.0                           │
│        - Color flash: Player color intensifies                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 4.5 Feedback Indicators

#### Correct Answer Indicator

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│                    ┌───────────────────┐                        │
│                    │                   │                        │
│                    │    ✓ CORRECT!     │                        │
│                    │                   │                        │
│                    │     +10 pts       │                        │
│                    │   +5 speed bonus  │                        │
│                    │                   │                        │
│                    └───────────────────┘                        │
│                                                                 │
│        Specs:                                                   │
│        - Overlay on game screen                                 │
│        - Background: Success green at 95% opacity               │
│        - Checkmark icon: 64dp, white                            │
│        - Text: 24sp "CORRECT!", 18sp points                     │
│        - Duration: 2 seconds                                    │
│                                                                 │
│        Animation:                                               │
│        - Fade in: 200ms                                         │
│        - Checkmark: Scale from 0 to 1, bounce                   │
│        - Points: Fly up animation                               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

#### Incorrect Answer Indicator

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│                    ┌───────────────────┐                        │
│                    │                   │                        │
│                    │    ✗ INCORRECT    │                        │
│                    │                   │                        │
│                    │   Correct answer: │                        │
│                    │     "Bon dia"     │                        │
│                    │                   │                        │
│                    └───────────────────┘                        │
│                                                                 │
│        Specs:                                                   │
│        - Overlay on game screen                                 │
│        - Background: Error red at 95% opacity                   │
│        - X icon: 64dp, white                                    │
│        - Shows correct answer for learning                      │
│        - Duration: 2.5 seconds (longer for learning)            │
│                                                                 │
│        Animation:                                               │
│        - Fade in: 200ms                                         │
│        - X icon: Shake animation                                │
│        - Screen: Subtle shake (100ms, 2 cycles)                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 4.6 Word Tiles (for Phrase Builder)

#### Draggable Word Tile

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│        Resting State:                                           │
│        ┌──────────────┐                                         │
│        │    Bona      │                                         │
│        └──────────────┘                                         │
│                                                                 │
│        Dragging State:                                          │
│        ┌──────────────┐                                         │
│        │    Bona      │  ← Elevated, slightly transparent       │
│        └──────────────┘                                         │
│                                                                 │
│        Placed State:                                            │
│        ┌──────────────┐                                         │
│        │    Bona      │  ← In answer zone                       │
│        └──────────────┘                                         │
│                                                                 │
│        Specs:                                                   │
│        - Height: 48dp                                           │
│        - Width: Auto (text + 24dp padding)                      │
│        - Min width: 64dp                                        │
│        - Corner radius: 8dp                                     │
│        - Background: White (bank) / Light blue (placed)         │
│        - Border: 1dp grey                                       │
│        - Text: 16sp, medium weight                              │
│        - Shadow: elevation 1dp (2dp when dragging)              │
│                                                                 │
│        Drag Behavior:                                           │
│        - Long press to initiate (300ms)                         │
│        - Or: tap to select, tap target zone to place            │
│        - Haptic feedback on pickup and drop                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

#### Drop Zone (Answer Area)

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│        Empty State:                                             │
│        ┌─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐          │
│        │                                             │          │
│        │  ┌─ ─ ─┐ ┌─ ─ ─┐ ┌─ ─ ─┐ ┌─ ─ ─┐           │          │
│        │  │  ?  │ │  ?  │ │  ?  │ │  ?  │           │          │
│        │  └─ ─ ─┘ └─ ─ ─┘ └─ ─ ─┘ └─ ─ ─┘           │          │
│        │           [Placeholder slots]               │          │
│        └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┘          │
│                                                                 │
│        Filled State:                                            │
│        ┌─────────────────────────────────────────────┐          │
│        │                                             │          │
│        │  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐       │          │
│        │  │ Bona │ │tarda,│ │ com  │ │ tal? │       │          │
│        │  └──────┘ └──────┘ └──────┘ └──────┘       │          │
│        │                                             │          │
│        └─────────────────────────────────────────────┘          │
│                                                                 │
│        Specs:                                                   │
│        - Height: 80dp (minimum)                                 │
│        - Width: Full width - 32dp margins                       │
│        - Background: Light grey (#F5F5F5)                       │
│        - Border: 2dp dashed (empty) / solid (filled)            │
│        - Corner radius: 12dp                                    │
│                                                                 │
│        Placeholder slots:                                       │
│        - Show expected number of words                          │
│        - Dashed outline, "?" text                               │
│        - Disappear as words are placed                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 4.7 Component Token Reference

| Token | Value | Usage |
|-------|-------|-------|
| `spacing.xs` | 4dp | Minimal gaps |
| `spacing.sm` | 8dp | Tight spacing |
| `spacing.md` | 16dp | Default spacing |
| `spacing.lg` | 24dp | Generous spacing |
| `spacing.xl` | 32dp | Section spacing |
| `radius.sm` | 8dp | Small elements |
| `radius.md` | 12dp | Cards, buttons |
| `radius.lg` | 16dp | Large cards |
| `radius.pill` | 9999dp | Pill shapes |
| `elevation.sm` | 2dp | Subtle lift |
| `elevation.md` | 4dp | Cards |
| `elevation.lg` | 8dp | Modals, overlays |

---

## 5. Accessibility Guidelines

### 5.1 Font Considerations for Greek Characters

```
┌─────────────────────────────────────────────────────────────────┐
│                     GREEK TYPOGRAPHY                            │
└─────────────────────────────────────────────────────────────────┘

Recommended Font Stack:
1. Primary: "Noto Sans" - Excellent Greek support
2. Fallback: "Roboto" - Good Greek characters
3. System: Platform default with Greek Unicode support

Greek Character Rendering:
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   UPPERCASE:  Α Β Γ Δ Ε Ζ Η Θ Ι Κ Λ Μ Ν Ξ Ο Π Ρ Σ Τ Υ Φ Χ Ψ Ω  │
│                                                                 │
│   lowercase:  α β γ δ ε ζ η θ ι κ λ μ ν ξ ο π ρ σ τ υ φ χ ψ ω  │
│                                                                 │
│   with accents: ά έ ή ί ό ύ ώ                                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

Special Considerations:
- Ensure font includes polytonic Greek for accented characters
- Test σ (sigma) vs ς (final sigma) rendering
- Verify proper kerning with Greek diacritics
```

### 5.2 Text Sizing Recommendations

| Element | Size | Weight | Line Height | Notes |
|---------|------|--------|-------------|-------|
| Page Title | 24sp | Bold | 1.2 | All caps for headers |
| Section Header | 20sp | SemiBold | 1.3 | Mixed case |
| Body Text | 16sp | Regular | 1.5 | Primary content |
| Flash Card Word | 32sp | Bold | 1.2 | Large for readability |
| Phonetic Hint | 14sp | Italic | 1.4 | Secondary, lighter color |
| Button Text | 16sp | Medium | 1.0 | Uppercase for primary |
| Caption | 12sp | Regular | 1.4 | Minimal use |
| Score Number | 24sp | Bold | 1.0 | Monospace preferred |

**Minimum Sizes (WCAG):**
- Body text: Never below 14sp
- Interactive labels: Never below 12sp
- All text must scale with system font size preference

### 5.3 Color Contrast Requirements

```
┌─────────────────────────────────────────────────────────────────┐
│                    COLOR PALETTE                                │
└─────────────────────────────────────────────────────────────────┘

Primary Colors:
┌──────────────┬──────────────┬──────────────┬──────────────────┐
│   Color      │   Hex        │  On White    │   On Color       │
├──────────────┼──────────────┼──────────────┼──────────────────┤
│ Primary      │ #2196F3      │ 4.5:1 ✓      │ White text       │
│ Primary Dark │ #1976D2      │ 5.9:1 ✓      │ White text       │
│ Secondary    │ #FF9800      │ 3.0:1 ✗      │ Black text       │
│ Sec. Dark    │ #F57C00      │ 3.4:1 ✗      │ Black text       │
└──────────────┴──────────────┴──────────────┴──────────────────┘

Note: Secondary orange requires black text for AA compliance

Player Colors:
┌──────────────┬──────────────┬──────────────────────────────────┐
│   Player     │   Color      │   Text Color                     │
├──────────────┼──────────────┼──────────────────────────────────┤
│ Player 1     │ #2196F3      │ White (#FFFFFF)                  │
│ Player 2     │ #FF9800      │ Black (#212121)                  │
└──────────────┴──────────────┴──────────────────────────────────┘

Feedback Colors:
┌──────────────┬──────────────┬──────────────────────────────────┐
│   State      │   Color      │   Text Color  │  Contrast        │
├──────────────┼──────────────┼───────────────┼──────────────────┤
│ Success      │ #4CAF50      │ White         │ 4.6:1 ✓          │
│ Error        │ #F44336      │ White         │ 4.5:1 ✓          │
│ Warning      │ #FFC107      │ Black         │ 3.2:1 (large)    │
│ Info         │ #2196F3      │ White         │ 4.5:1 ✓          │
└──────────────┴──────────────┴───────────────┴──────────────────┘

WCAG 2.1 AA Requirements:
- Normal text: 4.5:1 minimum
- Large text (18sp+ or 14sp+ bold): 3:1 minimum
- UI components: 3:1 minimum
```

### 5.4 Touch Target Sizes

```
┌─────────────────────────────────────────────────────────────────┐
│                    TOUCH TARGETS                                │
└─────────────────────────────────────────────────────────────────┘

Minimum Touch Target: 48dp x 48dp (recommended: 56dp x 56dp)

Component Sizes:
┌────────────────────────┬────────────────┬────────────────────────┐
│   Component            │   Min Size     │   Recommended          │
├────────────────────────┼────────────────┼────────────────────────┤
│ Primary Button         │ 48dp height    │ 56dp height            │
│ Secondary Button       │ 44dp height    │ 48dp height            │
│ Answer Option          │ 64dp height    │ 72dp height            │
│ Word Tile              │ 48dp height    │ 48dp height            │
│ Back Button            │ 48dp x 48dp    │ 48dp x 48dp            │
│ Icon Button            │ 48dp x 48dp    │ 48dp x 48dp            │
│ Dropdown               │ 48dp height    │ 56dp height            │
└────────────────────────┴────────────────┴────────────────────────┘

Spacing Between Touch Targets:
- Minimum gap: 8dp
- Recommended gap: 16dp

Visual vs Touch:
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│       ┌──────────────────────────┐                              │
│       │    ┌──────────────┐      │  ← Touch target: 56x56dp     │
│       │    │   [Icon]     │      │                              │
│       │    │    24dp      │      │  ← Visual size: 24x24dp      │
│       │    └──────────────┘      │                              │
│       └──────────────────────────┘                              │
│                                                                 │
│       Touch target can be larger than visual element            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 5.5 Screen Reader Support

```
Semantic Labels for Key Elements:
┌────────────────────────┬─────────────────────────────────────────┐
│   Element              │   Accessibility Label                   │
├────────────────────────┼─────────────────────────────────────────┤
│ Score Display          │ "Player 1 Maria: 45 points,            │
│                        │  Player 2 Jordi: 35 points"            │
├────────────────────────┼─────────────────────────────────────────┤
│ Timer                  │ "7 seconds remaining"                   │
├────────────────────────┼─────────────────────────────────────────┤
│ Flash Card             │ "Translate: Kalimera, Greek word        │
│                        │  meaning Good morning"                  │
├────────────────────────┼─────────────────────────────────────────┤
│ Answer Option          │ "Option A: Bon dia"                     │
├────────────────────────┼─────────────────────────────────────────┤
│ Word Tile              │ "Word tile: Bona. Double tap to         │
│                        │  pick up, drag to answer area"          │
├────────────────────────┼─────────────────────────────────────────┤
│ Feedback               │ "Correct! You earned 10 points          │
│                        │  plus 5 point speed bonus"              │
└────────────────────────┴─────────────────────────────────────────┘

Focus Order:
1. Score display (informational)
2. Round/question progress
3. Timer
4. Question card
5. Answer options (A, B, C, D)
6. Submit button (if applicable)
```

### 5.6 Additional Accessibility Considerations

| Requirement | Implementation |
|-------------|----------------|
| Reduce motion | Respect `prefers-reduced-motion`, simplify animations |
| High contrast | Support high contrast mode, test with system settings |
| One-handed use | Keep primary actions in lower 2/3 of screen |
| Orientation | Lock to portrait for MVP (consistent experience) |
| Text scaling | Support up to 200% text scaling |
| Voice Over | Test full flow with iOS Voice Over |
| TalkBack | Test full flow with Android TalkBack |

---

## 6. Error States & Edge Cases

### 6.1 Empty Player Names

```
┌─────────────────────────────────────────────────────────────────┐
│                     PLAYER NAME VALIDATION                      │
└─────────────────────────────────────────────────────────────────┘

Error State Display:
┌──────────────────────────────────────────────┐
│  PLAYER 1                                    │
│                                              │
│  ┌────────────────────────────────────────┐  │
│  │                                        │  │
│  │                                        │  │
│  │                                        │  │
│  └────────────────────────────────────────┘  │
│  ⚠ Please enter a name                      │
│                                              │
└──────────────────────────────────────────────┘

Validation Rules:
┌────────────────────────┬────────────────────────────────────────┐
│   Condition            │   Error Message                        │
├────────────────────────┼────────────────────────────────────────┤
│ Empty field            │ "Please enter a name"                  │
│ Whitespace only        │ "Name cannot be empty"                 │
│ Too long (>20 chars)   │ "Name must be 20 characters or less"  │
│ Same as other player   │ "Players must have different names"   │
└────────────────────────┴────────────────────────────────────────┘

UX Behavior:
- Show error on blur (when user leaves field)
- Clear error when user starts typing
- Disable Continue button until valid
- Shake animation on invalid submit attempt
- Red border on invalid field
```

### 6.2 Tie Games

```
┌─────────────────────────────────────────────────────────────────┐
│                        TIE GAME RESULT                          │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                         DUEL COMPLETE!                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                        ╔═════════════╗                          │
│                        ║  IT'S A TIE! ║                          │
│                        ╚═════════════╝                          │
│                        [Handshake icon]                         │
│                                                                 │
│        ┌─────────────────────────────────────────────┐          │
│        │                                             │          │
│        │    ┌────────────┐      ┌────────────┐      │          │
│        │    │   Maria    │      │   Jordi    │      │          │
│        │    │            │      │            │      │          │
│        │    │    95      │  =   │    95      │      │          │
│        │    │   POINTS   │      │   POINTS   │      │          │
│        │    └────────────┘      └────────────┘      │          │
│        │                                             │          │
│        └─────────────────────────────────────────────┘          │
│                                                                 │
│        ┌─────────────────────────────────────────────┐          │
│        │          REMATCH?                           │          │
│        └─────────────────────────────────────────────┘          │
│                                                                 │
│        ┌─────────────────────────────────────────────┐          │
│        │          BACK TO HOME                       │          │
│        └─────────────────────────────────────────────┘          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

Tie Handling:
- Display "IT'S A TIE!" instead of "WINNER!"
- Use handshake icon instead of trophy
- Both player cards shown equally (no winner badge)
- Primary CTA becomes "REMATCH?" to encourage replay
- Animation: Both scores pulse simultaneously
```

### 6.3 Timer Expiration

```
┌─────────────────────────────────────────────────────────────────┐
│                     TIMER EXPIRATION FLOW                       │
└─────────────────────────────────────────────────────────────────┘

Timeline:
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  10s        5s         3s         1s         0s                 │
│   │──────────│──────────│──────────│──────────│                 │
│   │          │          │          │          │                 │
│  Normal    Normal    Warning   Critical   Expired              │
│   mode      mode       mode      mode       mode                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

Visual Changes:
┌──────────────┬──────────────────────────────────────────────────┐
│   State      │   Visual Treatment                               │
├──────────────┼──────────────────────────────────────────────────┤
│ Normal       │ Black text, no animation                         │
│ (>3s)        │                                                  │
├──────────────┼──────────────────────────────────────────────────┤
│ Warning      │ Red text, pulse animation (scale 1.0-1.1)        │
│ (1-3s)       │ Optional: vibration pulse each second            │
├──────────────┼──────────────────────────────────────────────────┤
│ Critical     │ Red background, white text, fast pulse           │
│ (0-1s)       │ Countdown beep sounds (future)                   │
├──────────────┼──────────────────────────────────────────────────┤
│ Expired      │ "TIME'S UP!" displayed                           │
│ (0s)         │ Auto-submit current state (or no answer)         │
└──────────────┴──────────────────────────────────────────────────┘

Expired Behavior:
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│                    ┌───────────────────┐                        │
│                    │                   │                        │
│                    │    ⏱ TIME'S UP!   │                        │
│                    │                   │                        │
│                    │   No answer       │                        │
│                    │   submitted       │                        │
│                    │                   │                        │
│                    │   +0 points       │                        │
│                    │                   │                        │
│                    └───────────────────┘                        │
│                                                                 │
│  For Vocab Flash:                                               │
│  - Treated as incorrect answer                                  │
│  - Show correct answer                                          │
│  - Award 0 points                                               │
│                                                                 │
│  For Phrase Builder:                                            │
│  - Auto-submit current arrangement                              │
│  - Calculate partial credit if applicable                       │
│  - Award points based on submitted state                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 6.4 Network Errors (Future Consideration)

```
┌─────────────────────────────────────────────────────────────────┐
│                    NETWORK ERROR HANDLING                       │
│                    (Post-MVP, for reference)                    │
└─────────────────────────────────────────────────────────────────┘

Note: MVP is fully offline. This section documents future patterns.

Connection Lost During Game:
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│                    ┌───────────────────┐                        │
│                    │                   │                        │
│                    │   [No WiFi icon]  │                        │
│                    │                   │                        │
│                    │   Connection Lost │                        │
│                    │                   │                        │
│                    │  Don't worry!     │                        │
│                    │  Your progress    │                        │
│                    │  is saved.        │                        │
│                    │                   │                        │
│                    │  [Retry]          │                        │
│                    │                   │                        │
│                    └───────────────────┘                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

Offline Mode Fallback:
- Detect offline state
- Continue with local data
- Queue actions for sync
- Show unobtrusive "offline" indicator
- Auto-retry when connection restored
```

### 6.5 App Backgrounding Mid-Game

```
┌─────────────────────────────────────────────────────────────────┐
│                    APP BACKGROUNDING                            │
└─────────────────────────────────────────────────────────────────┘

Scenario: User receives phone call, switches apps, or locks phone

Pause Behavior:
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  App goes to background:                                        │
│  1. Timer PAUSES immediately                                    │
│  2. Current state saved to local storage                        │
│  3. No answer auto-submitted                                    │
│                                                                 │
│  App returns to foreground:                                     │
│  1. Show "paused" overlay                                       │
│  2. Require tap to resume                                       │
│  3. Timer resumes from paused state                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

Resume Screen:
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │
│  ░                                                           ░  │
│  ░                    GAME PAUSED                            ░  │
│  ░                                                           ░  │
│  ░                    ┌─────────────┐                        ░  │
│  ░                    │    ⏸️        │                        ░  │
│  ░                    │   PAUSED    │                        ░  │
│  ░                    └─────────────┘                        ░  │
│  ░                                                           ░  │
│  ░                Current turn: Maria                        ░  │
│  ░                Time remaining: 7s                         ░  │
│  ░                                                           ░  │
│  ░         ┌─────────────────────────────────┐               ░  │
│  ░         │         TAP TO RESUME           │               ░  │
│  ░         └─────────────────────────────────┘               ░  │
│  ░                                                           ░  │
│  ░         ┌─────────────────────────────────┐               ░  │
│  ░         │         QUIT GAME               │               ░  │
│  ░         └─────────────────────────────────┘               ░  │
│  ░                                                           ░  │
│  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

State Persistence (MVP Priority: P1):
┌────────────────────────┬────────────────────────────────────────┐
│   Data to Save         │   Storage Method                       │
├────────────────────────┼────────────────────────────────────────┤
│ Current player turn    │ Local JSON/Hive                        │
│ Timer remaining        │ Stored as integer seconds              │
│ Both player scores     │ Integer values                         │
│ Current round/question │ Index references                       │
│ Questions answered     │ List of question IDs                   │
│ Deck being used        │ Deck ID reference                      │
└────────────────────────┴────────────────────────────────────────┘

App Killed (Force Close):
- On next launch, detect saved game state
- Offer to resume or start fresh
- Resume restores exact state
- "Start Fresh" clears saved state

Resume Prompt:
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│              ┌─────────────────────────────────┐                │
│              │                                 │                │
│              │    Unfinished Game Found        │                │
│              │                                 │                │
│              │    Maria vs Jordi               │                │
│              │    Round 2, Question 3          │                │
│              │                                 │                │
│              │  ┌───────────────────────────┐  │                │
│              │  │       RESUME GAME         │  │                │
│              │  └───────────────────────────┘  │                │
│              │                                 │                │
│              │  ┌───────────────────────────┐  │                │
│              │  │       START NEW           │  │                │
│              │  └───────────────────────────┘  │                │
│              │                                 │                │
│              └─────────────────────────────────┘                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 6.6 Additional Edge Cases

| Edge Case | Handling |
|-----------|----------|
| **Rapid button tapping** | Debounce all buttons (300ms), disable after first tap until action completes |
| **Screen rotation** | Lock to portrait orientation for MVP |
| **System font scaling >200%** | Test all screens, allow text truncation with ellipsis if necessary |
| **Low battery warning** | No special handling; rely on system notification |
| **Accessibility services enabled** | Ensure all elements have proper labels, test with VoiceOver/TalkBack |
| **Multiple rapid back presses** | Confirm before exiting mid-game, single back goes to pause screen |
| **Screenshot taken** | No special handling (hot-seat privacy is physical, not screenshot-protected) |
| **Split screen mode** | Disable split screen if possible, or ensure minimum width of 320dp |
| **Keyboard covering input** | Scroll view adjustment to keep active input visible |
| **Name with special characters** | Allow Unicode characters, sanitize for display only |
| **Very long words in Phrase Builder** | Wrap words, minimum tile width, horizontal scroll if needed |

### 6.7 Error Message Guidelines

```
┌─────────────────────────────────────────────────────────────────┐
│                    ERROR MESSAGE TONE                           │
└─────────────────────────────────────────────────────────────────┘

Principles:
1. Be helpful, not blaming
2. Explain what happened
3. Provide clear next step
4. Use simple language

Good Examples:
┌────────────────────────┬────────────────────────────────────────┐
│   Situation            │   Message                              │
├────────────────────────┼────────────────────────────────────────┤
│ Empty name             │ "Please enter a name to continue"      │
│ Same names             │ "Players need different names"         │
│ Game load failed       │ "Couldn't load the game. Try again?"   │
│ Save failed            │ "Couldn't save progress. Try again?"   │
└────────────────────────┴────────────────────────────────────────┘

Bad Examples (avoid):
- "Error 404: Resource not found" (too technical)
- "Invalid input" (too vague)
- "You made a mistake" (blaming)
- "Something went wrong" (unhelpful)
```

---

## Appendix A: Screen Flow Summary

| Screen | Entry Points | Exit Points |
|--------|--------------|-------------|
| Home | App launch, Results "Back to Home" | Player Setup |
| Player Setup | Home "Start New Duel" | Deck Selection, Home (back) |
| Deck Selection | Player Setup "Continue" | Duel Hub, Player Setup (back) |
| Duel Hub | Deck Selection "Start Duel", Turn Transition "Ready" | Mini-game, Results |
| Turn Transition | Mini-game (after P1 turn) | Duel Hub (ready tap) |
| Results | Duel Hub (game complete) | Home, Player Setup ("Play Again") |

---

## Appendix B: Animation Reference

| Animation | Duration | Easing | Trigger |
|-----------|----------|--------|---------|
| Page transition | 300ms | ease-in-out | Navigation |
| Button press | 150ms | ease-out | User tap |
| Score increment | 500ms | ease-out | Points awarded |
| Timer pulse | 500ms | ease-in-out | <3 seconds |
| Correct answer | 400ms | bounce | Correct submission |
| Incorrect shake | 300ms | linear | Wrong submission |
| Card flip (future) | 350ms | ease-in-out | Reveal answer |
| Fade out | 200ms | ease-in | Screen exit |
| Fade in | 200ms | ease-out | Screen enter |

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-26 | Product/UX Agent | Initial document creation |

---

*This document serves as the comprehensive UX specification for the Language Duel MVP. Developers should reference this document for all UI implementation details, component specifications, and interaction patterns.*
