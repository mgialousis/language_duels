# Phase 2: Solo Mode & Learning Features - Implementation Plan

**Version:** 1.0
**Created:** 2026-01-27
**Duration:** 2-4 weeks
**Prerequisites:** Phase 1 (Polish & Analytics) - can run in parallel
**Status:** In Progress (features implemented; QA pending)

---

## Table of Contents

0. [Implementation Status](#0-implementation-status)
1. [Overview & Goals](#1-overview--goals)
2. [Feature Specifications](#2-feature-specifications)
3. [Data Models](#3-data-models)
4. [Spaced Repetition Algorithm](#4-spaced-repetition-algorithm)
5. [UI/UX Specifications](#5-uiux-specifications)
6. [Implementation Tasks](#6-implementation-tasks)
7. [Testing Strategy](#7-testing-strategy)
8. [Migration & Rollout](#8-migration--rollout)

---

## 0. Implementation Status

**As of:** 2026-01-27

- [x] Solo Hub / Setup / Practice / Results screens
- [x] SRS Review + Weak Words flow
- [x] Progress dashboard + recent sessions on Solo Hub
- [x] Solo History screen + route
- [x] Phrase Builder + Mixed modes in Solo Practice
- [x] Unit/integration tests for core solo flow
- [x] Widget tests for all solo screens
- [ ] Manual QA checklist pass
- [ ] Docs/README final update

## 1. Overview & Goals

### 1.1 Problem Statement

Currently, Language Duel requires two players (hot-seat mode). Users who want to:
- Practice alone before challenging friends
- Review vocabulary at their own pace
- Track their learning progress over time
- Focus on words they struggle with

...have no way to do so within the app.

### 1.2 Goals

| Goal | Success Metric |
|------|----------------|
| Enable solo practice | Users can complete solo sessions |
| Implement effective learning | 70%+ retention rate at 7 days |
| Track progress | Users can see mastery % per deck |
| Target weak areas | Weak words identified and reviewable |
| Increase engagement | 2x session frequency per user |

### 1.3 Non-Goals (Out of Scope)

- Online leaderboards (Phase 5)
- Audio pronunciation (Phase 4)
- New mini-games (Phase 3)
- Gamification/achievements (Phase 7)

### 1.4 User Stories

```
US-1: As a learner, I want to practice vocabulary alone so I can
      improve without needing a partner.

US-2: As a learner, I want the app to track which words I know well
      and which I struggle with, so I can focus my practice.

US-3: As a learner, I want to see my progress over time so I feel
      motivated to continue learning.

US-4: As a learner, I want to review only my weak words so I can
      efficiently improve my weakest areas.

US-5: As a returning user, I want the app to remind me which words
      are due for review based on spaced repetition.
```

---

## 2. Feature Specifications

### 2.1 Solo Practice Mode

**Description:** Single-player practice sessions using existing mini-games without competitive elements.

**Modes:**

| Mode | Description | Timer | Use Case |
|------|-------------|-------|----------|
| **Timed Practice** | Same as duel mode, but solo | Yes (10s/30s) | Simulate duel conditions |
| **Relaxed Practice** | No time pressure | No | Stress-free learning |
| **SRS Review** | Algorithm-selected items due for review | Optional | Optimal retention |

**Session Configuration:**
```
Solo Session Settings:
├── Deck selection (single deck)
├── Mini-game selection (Vocab Flash / Phrase Builder / Both)
├── Mode (Timed / Relaxed / SRS Review)
├── Question count (5 / 10 / 15 / All due)
└── Direction (Greek→Catalan / Catalan→Greek / Mixed)
```

**Differences from Duel Mode:**

| Aspect | Duel Mode | Solo Mode |
|--------|-----------|-----------|
| Players | 2 | 1 |
| Turn transitions | Yes | No |
| Opponent score | Visible | N/A |
| Timer | Always on | Optional |
| Session length | Fixed (5+3 per game) | Configurable |
| End screen | Winner/loser | Personal stats |

### 2.2 Spaced Repetition System (SRS)

**Description:** Algorithm that schedules vocabulary review at optimal intervals to maximize long-term retention while minimizing review time.

**Core Concept:**
- New items: Review frequently (1 day, then 3 days, then 7 days...)
- Known items: Review less often (2 weeks, 1 month, 3 months...)
- Forgotten items: Reset to frequent review

**Item States:**

```
┌─────────────┐     Correct      ┌─────────────┐
│    NEW      │ ───────────────► │  LEARNING   │
│ (never seen)│                  │ (interval<21d)│
└─────────────┘                  └──────┬──────┘
                                        │
                                   Correct (interval≥21d)
                                        │
                                        ▼
                                 ┌─────────────┐
                    Wrong        │   MASTERED  │
              ┌─────────────────│ (interval≥21d)│
              │                  └─────────────┘
              ▼                         │
       ┌─────────────┐                  │ Wrong
       │  RELEARNING │ ◄────────────────┘
       │ (reset to 1d)│
       └─────────────┘
```

**Review Queue Priority:**
1. Overdue items (past nextReviewDate)
2. Due today
3. New items (limited per session)

### 2.3 Progress Tracking

**Tracked Metrics:**

| Metric | Scope | Description |
|--------|-------|-------------|
| Items seen | Per deck | Count of unique items attempted |
| Mastery % | Per deck | % of items with interval ≥ 21 days |
| Accuracy | Per deck, overall | % correct over last 7/30 days |
| Streak | Overall | Consecutive days with ≥1 review |
| Total reviews | Overall | Lifetime review count |
| Time spent | Per session, overall | Minutes practiced |

**Progress Levels (per deck):**

| Level | Criteria | Badge |
|-------|----------|-------|
| Beginner | 0-25% mastered | 🌱 |
| Intermediate | 26-50% mastered | 🌿 |
| Advanced | 51-75% mastered | 🌳 |
| Expert | 76-99% mastered | ⭐ |
| Master | 100% mastered | 👑 |

### 2.4 Weak Words Review

**Identification Criteria:**
A word is "weak" if ANY of:
- Ease factor < 1.8 (struggled multiple times)
- Answered incorrectly in last 3 attempts
- Interval reset to 1 day 2+ times

**Weak Words Mode:**
- Pulls weak items across ALL decks
- Minimum 5 items to start session
- Focused practice without new items
- Extra feedback (shows both translations, phonetics)

---

## 3. Data Models

### 3.1 New Models

```dart
// lib/data/models/learner_profile.dart

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'learner_profile.g.dart';

/// Represents a learner's overall progress and statistics
@HiveType(typeId: 20)
class LearnerProfile extends Equatable {
  @HiveField(0)
  final String ownerId; // Unique identifier (local UUID or future user ID)

  @HiveField(1)
  final DateTime createdAt;

  @HiveField(2)
  final int totalReviews; // Lifetime review count

  @HiveField(3)
  final int currentStreak; // Consecutive days practiced

  @HiveField(4)
  final DateTime? lastPracticeDate;

  @HiveField(5)
  final int longestStreak; // Personal best streak

  @HiveField(6)
  final Map<String, DeckProgress> deckProgress; // deckId -> progress

  const LearnerProfile({
    required this.ownerId,
    required this.createdAt,
    this.totalReviews = 0,
    this.currentStreak = 0,
    this.lastPracticeDate,
    this.longestStreak = 0,
    this.deckProgress = const {},
  });

  factory LearnerProfile.create() {
    return LearnerProfile(
      ownerId: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
    );
  }

  /// Check if user practiced today
  bool get practicedToday {
    if (lastPracticeDate == null) return false;
    final now = DateTime.now();
    return lastPracticeDate!.year == now.year &&
           lastPracticeDate!.month == now.month &&
           lastPracticeDate!.day == now.day;
  }

  /// Calculate overall mastery across all decks
  double get overallMastery {
    if (deckProgress.isEmpty) return 0.0;
    final total = deckProgress.values.fold<double>(
      0.0, (sum, dp) => sum + dp.masteryPercentage);
    return total / deckProgress.length;
  }

  LearnerProfile copyWith({
    String? ownerId,
    DateTime? createdAt,
    int? totalReviews,
    int? currentStreak,
    DateTime? lastPracticeDate,
    int? longestStreak,
    Map<String, DeckProgress>? deckProgress,
  }) {
    return LearnerProfile(
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      totalReviews: totalReviews ?? this.totalReviews,
      currentStreak: currentStreak ?? this.currentStreak,
      lastPracticeDate: lastPracticeDate ?? this.lastPracticeDate,
      longestStreak: longestStreak ?? this.longestStreak,
      deckProgress: deckProgress ?? this.deckProgress,
    );
  }

  @override
  List<Object?> get props => [
    ownerId, createdAt, totalReviews, currentStreak,
    lastPracticeDate, longestStreak, deckProgress
  ];
}
```

```dart
// lib/data/models/deck_progress.dart

@HiveType(typeId: 21)
class DeckProgress extends Equatable {
  @HiveField(0)
  final String deckId;

  @HiveField(1)
  final int itemsSeen; // Unique items attempted

  @HiveField(2)
  final int itemsMastered; // Items with interval >= 21 days

  @HiveField(3)
  final int totalItems; // Total items in deck

  @HiveField(4)
  final int correctCount; // Lifetime correct answers

  @HiveField(5)
  final int totalAttempts; // Lifetime attempts

  @HiveField(6)
  final DateTime? lastPracticed;

  const DeckProgress({
    required this.deckId,
    this.itemsSeen = 0,
    this.itemsMastered = 0,
    required this.totalItems,
    this.correctCount = 0,
    this.totalAttempts = 0,
    this.lastPracticed,
  });

  double get masteryPercentage =>
      totalItems > 0 ? (itemsMastered / totalItems) * 100 : 0.0;

  double get accuracy =>
      totalAttempts > 0 ? (correctCount / totalAttempts) * 100 : 0.0;

  String get progressLevel {
    final pct = masteryPercentage;
    if (pct >= 100) return 'master';
    if (pct >= 76) return 'expert';
    if (pct >= 51) return 'advanced';
    if (pct >= 26) return 'intermediate';
    return 'beginner';
  }

  DeckProgress copyWith({
    String? deckId,
    int? itemsSeen,
    int? itemsMastered,
    int? totalItems,
    int? correctCount,
    int? totalAttempts,
    DateTime? lastPracticed,
  }) {
    return DeckProgress(
      deckId: deckId ?? this.deckId,
      itemsSeen: itemsSeen ?? this.itemsSeen,
      itemsMastered: itemsMastered ?? this.itemsMastered,
      totalItems: totalItems ?? this.totalItems,
      correctCount: correctCount ?? this.correctCount,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      lastPracticed: lastPracticed ?? this.lastPracticed,
    );
  }

  @override
  List<Object?> get props => [
    deckId, itemsSeen, itemsMastered, totalItems,
    correctCount, totalAttempts, lastPracticed
  ];
}
```

```dart
// lib/data/models/srs_item.dart

@HiveType(typeId: 22)
class SRSItem extends Equatable {
  @HiveField(0)
  final String itemId; // ContentItem ID

  @HiveField(1)
  final String deckId;

  @HiveField(2)
  final int repetitions; // Consecutive correct answers

  @HiveField(3)
  final double easeFactor; // 1.3 - 2.5, affects interval growth

  @HiveField(4)
  final int intervalDays; // Days until next review

  @HiveField(5)
  final DateTime nextReviewDate;

  @HiveField(6)
  final DateTime lastReviewDate;

  @HiveField(7)
  final int totalReviews;

  @HiveField(8)
  final int correctReviews;

  @HiveField(9)
  final SRSState state;

  @HiveField(10)
  final int wrongStreak; // Consecutive wrong answers

  @HiveField(11)
  final int resetCount; // Times interval reset to 1 day

  const SRSItem({
    required this.itemId,
    required this.deckId,
    this.repetitions = 0,
    this.easeFactor = 2.5,
    this.intervalDays = 0,
    required this.nextReviewDate,
    required this.lastReviewDate,
    this.totalReviews = 0,
    this.correctReviews = 0,
    this.state = SRSState.newItem,
    this.wrongStreak = 0,
    this.resetCount = 0,
  });

  factory SRSItem.newItem(String itemId, String deckId) {
    final now = DateTime.now();
    return SRSItem(
      itemId: itemId,
      deckId: deckId,
      nextReviewDate: now,
      lastReviewDate: now,
    );
  }

  bool get isDue => !DateTime.now().isBefore(nextReviewDate);

  bool get isWeak =>
      easeFactor < 1.8 || wrongStreak >= 3 || resetCount >= 2;

  bool get isMastered => intervalDays >= 21 && state == SRSState.mastered;

  double get accuracy =>
      totalReviews > 0 ? correctReviews / totalReviews : 0.0;

  @override
  List<Object?> get props => [
    itemId, deckId, repetitions, easeFactor, intervalDays,
    nextReviewDate, lastReviewDate, totalReviews, correctReviews, state,
    wrongStreak, resetCount
  ];
}

@HiveType(typeId: 23)
enum SRSState {
  @HiveField(0)
  newItem,      // Never reviewed

  @HiveField(1)
  learning,     // Interval < 21 days

  @HiveField(2)
  mastered,     // Interval >= 21 days

  @HiveField(3)
  relearning,   // Was mastered, got wrong, reset
}
```

```dart
// lib/data/models/solo_session.dart

class SoloSession {
  final String ownerId;
  final String deckId;
  final SoloMode mode;
  final MiniGameType gameType;
  final bool timerEnabled;
  final LanguageDirection direction;
  final DateTime startedAt;
  final List<SoloQuestionResult> results;

  const SoloSession({
    required this.ownerId,
    required this.deckId,
    required this.mode,
    required this.gameType,
    required this.timerEnabled,
    required this.direction,
    required this.startedAt,
    this.results = const [],
  });

  int get totalQuestions => results.length;
  int get correctCount => results.where((r) => r.isCorrect).length;
  int get totalScore => results.fold(0, (sum, r) => sum + r.points);
  double get accuracy => totalQuestions > 0 ? correctCount / totalQuestions : 0.0;
  Duration get duration => DateTime.now().difference(startedAt);
}

enum SoloMode {
  timed,      // With timer, like duel
  relaxed,    // No timer
  srsReview,  // Algorithm-selected items
}

class SoloQuestionResult {
  final String itemId;
  final bool isCorrect;
  final int points;
  final int responseTimeMs;
  final DateTime answeredAt;

  const SoloQuestionResult({
    required this.itemId,
    required this.isCorrect,
    required this.points,
    required this.responseTimeMs,
    required this.answeredAt,
  });
}
```

### 3.2 Storage Schema

**New Hive Boxes:**

| Box Name | Type | Key | Description |
|----------|------|-----|-------------|
| `learner_profile` | `LearnerProfile` | `'profile'` | Single profile object |
| `srs_items` | `SRSItem` | `itemId` | SRS state per content item |
| `solo_history` | `SoloSessionSummary` | auto-increment | Past solo sessions |

**Hive Type IDs:**

| Type ID | Model |
|---------|-------|
| 20 | LearnerProfile |
| 21 | DeckProgress |
| 22 | SRSItem |
| 23 | SRSState (enum) |
| 24 | SoloSessionSummary |

### 3.3 Provider Architecture

```dart
// lib/data/providers/learner_provider.dart

/// Provider for learner profile
final learnerProfileProvider =
    StateNotifierProvider<LearnerProfileNotifier, LearnerProfile>((ref) {
  return LearnerProfileNotifier(ref.watch(learnerStorageProvider));
});

/// Provider for SRS items
final srsItemsProvider =
    StateNotifierProvider<SRSNotifier, Map<String, SRSItem>>((ref) {
  return SRSNotifier(ref.watch(srsStorageProvider));
});

/// Provider for items due for review
final dueItemsProvider = Provider.family<List<SRSItem>, String>((ref, deckId) {
  final allItems = ref.watch(srsItemsProvider);
  return allItems.values
      .where((item) => item.deckId == deckId && item.isDue)
      .toList()
    ..sort((a, b) => a.nextReviewDate.compareTo(b.nextReviewDate));
});

/// Provider for weak items across all decks
final weakItemsProvider = Provider<List<SRSItem>>((ref) {
  final allItems = ref.watch(srsItemsProvider);
  return allItems.values.where((item) => item.isWeak).toList();
});

/// Provider for deck progress
final deckProgressProvider = Provider.family<DeckProgress?, String>((ref, deckId) {
  final profile = ref.watch(learnerProfileProvider);
  return profile.deckProgress[deckId];
});

/// Provider for overall stats
final learnerStatsProvider = Provider<LearnerStats>((ref) {
  final profile = ref.watch(learnerProfileProvider);
  final srsItems = ref.watch(srsItemsProvider);

  return LearnerStats(
    totalReviews: profile.totalReviews,
    currentStreak: profile.currentStreak,
    overallMastery: profile.overallMastery,
    dueToday: srsItems.values.where((i) => i.isDue).length,
    weakCount: srsItems.values.where((i) => i.isWeak).length,
  );
});
```

---

## 4. Spaced Repetition Algorithm

### 4.1 Algorithm: Modified SM-2

Based on the SuperMemo SM-2 algorithm with adjustments for language learning.

```dart
// lib/data/services/srs_service.dart

class SRSService {
  /// Quality ratings (0-5 scale, we use simplified 0-3)
  /// 0 = Complete failure (timeout, no answer)
  /// 1 = Wrong answer
  /// 2 = Correct with hesitation (slow)
  /// 3 = Perfect recall (fast and correct)

  static const double _minEaseFactor = 1.3;
  static const double _defaultEaseFactor = 2.5;
  static const int _masteryThreshold = 21; // days

  /// Process a review result and return updated SRS item
  SRSItem processReview(SRSItem item, int quality, int responseTimeMs) {
    final now = DateTime.now();
    final isCorrect = quality >= 2;

    int newRepetitions;
    double newEaseFactor;
    int newInterval;
    SRSState newState;

    if (isCorrect) {
      // Correct answer
      newRepetitions = item.repetitions + 1;

      // Update ease factor based on quality
      // EF' = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
      // Simplified for our 0-3 scale:
      final qualityAdjusted = quality + 2; // Map 0-3 to 2-5
      newEaseFactor = item.easeFactor +
          (0.1 - (5 - qualityAdjusted) * (0.08 + (5 - qualityAdjusted) * 0.02));
      newEaseFactor = newEaseFactor.clamp(_minEaseFactor, 3.0);

      // Calculate new interval
      if (newRepetitions == 1) {
        newInterval = 1; // First correct: review tomorrow
      } else if (newRepetitions == 2) {
        newInterval = 6; // Second correct: review in 6 days
      } else {
        newInterval = (item.intervalDays * newEaseFactor).round();
      }

      // Cap interval at 180 days
      newInterval = newInterval.clamp(1, 180);

      // Determine state
      newState = newInterval >= _masteryThreshold
          ? SRSState.mastered
          : SRSState.learning;

    } else {
      // Wrong answer - reset to relearning
      newRepetitions = 0;
      newInterval = 1; // Review tomorrow

      // Decrease ease factor for wrong answers
      newEaseFactor = (item.easeFactor - 0.2).clamp(_minEaseFactor, 3.0);

      newState = item.state == SRSState.mastered
          ? SRSState.relearning
          : SRSState.learning;
    }

    return SRSItem(
      itemId: item.itemId,
      deckId: item.deckId,
      repetitions: newRepetitions,
      easeFactor: newEaseFactor,
      intervalDays: newInterval,
      nextReviewDate: now.add(Duration(days: newInterval)),
      lastReviewDate: now,
      totalReviews: item.totalReviews + 1,
      correctReviews: item.correctReviews + (isCorrect ? 1 : 0),
      state: newState,
      wrongStreak: isCorrect ? 0 : item.wrongStreak + 1,
      resetCount: isCorrect ? item.resetCount : item.resetCount + 1,
    );
  }

  /// Determine quality rating based on correctness and response time
  int calculateQuality(bool isCorrect, int responseTimeMs, int timerMs) {
    if (!isCorrect) {
      return responseTimeMs == 0 ? 0 : 1; // 0 = timeout, 1 = wrong
    }

    if (timerMs == 0) {
      return 2; // Relaxed mode: correct counts as hesitation
    }

    // Correct answer - check speed
    final responseRatio = responseTimeMs / timerMs;
    if (responseRatio < 0.3) {
      return 3; // Fast and correct = perfect
    } else {
      return 2; // Correct but slow = hesitation
    }
  }

  /// Get items due for review, sorted by priority
  List<SRSItem> getDueItems(List<SRSItem> items, {int limit = 20}) {
    final now = DateTime.now();

    // Separate by priority
    final overdue = <SRSItem>[];
    final dueToday = <SRSItem>[];
    final newItems = <SRSItem>[];

    for (final item in items) {
      if (item.state == SRSState.newItem) {
        newItems.add(item);
      } else if (item.nextReviewDate.isBefore(now.subtract(Duration(days: 1)))) {
        overdue.add(item);
      } else if (item.isDue) {
        dueToday.add(item);
      }
    }

    // Sort by urgency
    overdue.sort((a, b) => a.nextReviewDate.compareTo(b.nextReviewDate));
    dueToday.sort((a, b) => a.easeFactor.compareTo(b.easeFactor)); // Harder first

    // Combine with priority: overdue > due today > new (limited)
    final result = <SRSItem>[];
    result.addAll(overdue.take(limit));

    if (result.length < limit) {
      result.addAll(dueToday.take(limit - result.length));
    }

    // Add new items only if we have capacity (max 5 new per session)
    if (result.length < limit) {
      final newLimit = (limit - result.length).clamp(0, 5);
      result.addAll(newItems.take(newLimit));
    }

    return result.take(limit).toList();
  }
}
```

### 4.2 Interval Progression Example

| Review # | Result | Ease Factor | Interval | Next Review |
|----------|--------|-------------|----------|-------------|
| 1 | ✅ Correct | 2.5 | 1 day | Tomorrow |
| 2 | ✅ Correct | 2.6 | 6 days | +6 days |
| 3 | ✅ Correct | 2.6 | 16 days | +16 days |
| 4 | ❌ Wrong | 2.4 | 1 day | Tomorrow |
| 5 | ✅ Correct | 2.5 | 1 day | Tomorrow |
| 6 | ✅ Correct | 2.6 | 6 days | +6 days |
| 7 | ✅ Correct | 2.6 | 16 days | +16 days |
| 8 | ✅ Correct | 2.6 | 42 days | +42 days → MASTERED |

---

## 5. UI/UX Specifications

### 5.1 New Screens

| Screen | Route | Description |
|--------|-------|-------------|
| Solo Hub | `/solo` | Entry point for solo practice |
| Solo Setup | `/solo/setup` | Configure solo session |
| Solo Practice | `/solo/practice` | Active practice session |
| Solo Results | `/solo/results` | Session summary |
| Progress Dashboard | `/progress` | Overall learning progress |
| Weak Words | `/weak` | Review weak items |

### 5.2 Navigation Flow

```
Home Screen
├── [Solo Practice] ──► Solo Hub (/solo)
│                       ├── [Quick Review] ──► Solo Practice (SRS mode)
│                       ├── [Practice Deck] ──► Solo Setup ──► Solo Practice
│                       └── [Weak Words] ──► Weak Words Screen
│
├── [Progress] ──► Progress Dashboard (/progress)
│                  ├── Overall stats
│                  ├── Per-deck progress
│                  └── [Deck] ──► Deck detail (future)
│
└── [Start Duel] ──► (existing duel flow)
```

### 5.3 Screen Wireframes

#### 5.3.1 Solo Hub Screen

```
┌─────────────────────────────────────────────────────────────────┐
│  [<]                    SOLO PRACTICE                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│     ┌───────────────────────────────────────────────────┐       │
│     │  🔥 5-day streak                  📊 68% mastery  │       │
│     └───────────────────────────────────────────────────┘       │
│                                                                 │
│     ┌───────────────────────────────────────────────────┐       │
│     │                                                   │       │
│     │  📚 QUICK REVIEW                                  │       │
│     │                                                   │       │
│     │  12 items due today                               │       │
│     │  Estimated time: 5 min                            │       │
│     │                                                   │       │
│     │              [Start Review]                       │       │
│     │                                                   │       │
│     └───────────────────────────────────────────────────┘       │
│                                                                 │
│     ┌───────────────────────────────────────────────────┐       │
│     │                                                   │       │
│     │  🎯 PRACTICE A DECK                               │       │
│     │                                                   │       │
│     │  Choose a deck and practice mode                  │       │
│     │                                                   │       │
│     │              [Choose Deck]                        │       │
│     │                                                   │       │
│     └───────────────────────────────────────────────────┘       │
│                                                                 │
│     ┌───────────────────────────────────────────────────┐       │
│     │                                                   │       │
│     │  ⚠️ WEAK WORDS                                    │       │
│     │                                                   │       │
│     │  8 words need extra practice                      │       │
│     │                                                   │       │
│     │              [Review Weak Words]                  │       │
│     │                                                   │       │
│     └───────────────────────────────────────────────────┘       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

#### 5.3.2 Solo Setup Screen

```
┌─────────────────────────────────────────────────────────────────┐
│  [<]                   PRACTICE SETUP                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  DECK                                                           │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  Greetings                                            [▼] │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                 │
│  MINI-GAME                                                      │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │   Vocab Flash   │  │ Phrase Builder  │  │      Both       │  │
│  │       ✓         │  │                 │  │                 │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
│                                                                 │
│  MODE                                                           │
│  ┌─────────────────┐  ┌─────────────────┐                       │
│  │     Timed       │  │    Relaxed      │                       │
│  │  (with timer)   │  │  (no pressure)  │                       │
│  │       ✓         │  │                 │                       │
│  └─────────────────┘  └─────────────────┘                       │
│                                                                 │
│  QUESTIONS                                                      │
│  ┌───────┐  ┌───────┐  ┌───────┐  ┌───────┐                     │
│  │   5   │  │  10   │  │  15   │  │  All  │                     │
│  │       │  │   ✓   │  │       │  │       │                     │
│  └───────┘  └───────┘  └───────┘  └───────┘                     │
│                                                                 │
│  DIRECTION                                                      │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │  Greek → Catalan│  │ Catalan → Greek │  │      Mixed      │  │
│  │       ✓         │  │                 │  │                 │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
│                                                                 │
│                                                                 │
│              ┌─────────────────────────────┐                    │
│              │       START PRACTICE        │                    │
│              └─────────────────────────────┘                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

#### 5.3.3 Solo Results Screen

```
┌─────────────────────────────────────────────────────────────────┐
│                      PRACTICE COMPLETE                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                          ⭐                                      │
│                       Great job!                                │
│                                                                 │
│     ┌───────────────────────────────────────────────────┐       │
│     │                                                   │       │
│     │   Score:          85 points                       │       │
│     │   Accuracy:       8/10 (80%)                      │       │
│     │   Time:           3:42                            │       │
│     │                                                   │       │
│     └───────────────────────────────────────────────────┘       │
│                                                                 │
│     ┌───────────────────────────────────────────────────┐       │
│     │  PROGRESS UPDATE                                  │       │
│     │                                                   │       │
│     │  Greetings: 42% → 45% mastered (+3%)              │       │
│     │  🔥 Streak: 5 days                                │       │
│     │  📚 Total reviews: 156                            │       │
│     │                                                   │       │
│     └───────────────────────────────────────────────────┘       │
│                                                                 │
│     ┌───────────────────────────────────────────────────┐       │
│     │  ITEMS TO REVIEW AGAIN                            │       │
│     │                                                   │       │
│     │  • Καλησπέρα (answered incorrectly)               │       │
│     │  • Πώς σε λένε; (took too long)                   │       │
│     │                                                   │       │
│     └───────────────────────────────────────────────────┘       │
│                                                                 │
│     ┌─────────────────┐      ┌─────────────────┐                │
│     │  Practice Again │      │   Back to Home  │                │
│     └─────────────────┘      └─────────────────┘                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

#### 5.3.4 Progress Dashboard Screen

```
┌─────────────────────────────────────────────────────────────────┐
│  [<]                    MY PROGRESS                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│     ┌───────────────────────────────────────────────────┐       │
│     │                                                   │       │
│     │  OVERALL MASTERY                                  │       │
│     │                                                   │       │
│     │  [████████████░░░░░░░░░░░░] 52%                   │       │
│     │                                                   │       │
│     │  🔥 7-day streak    📚 234 reviews    ✅ 76% acc  │       │
│     │                                                   │       │
│     └───────────────────────────────────────────────────┘       │
│                                                                 │
│     DECK PROGRESS                                               │
│                                                                 │
│     ┌───────────────────────────────────────────────────┐       │
│     │  👑 Greetings                           92%       │       │
│     │  [████████████████████████████░░░]                │       │
│     │  28/30 mastered • Last: Today                     │       │
│     └───────────────────────────────────────────────────┘       │
│                                                                 │
│     ┌───────────────────────────────────────────────────┐       │
│     │  ⭐ Colors                              75%       │       │
│     │  [██████████████████████░░░░░░░░]                 │       │
│     │  12/16 mastered • Last: Yesterday                 │       │
│     └───────────────────────────────────────────────────┘       │
│                                                                 │
│     ┌───────────────────────────────────────────────────┐       │
│     │  🌿 Numbers                             45%       │       │
│     │  [█████████████░░░░░░░░░░░░░░░]                   │       │
│     │  9/20 mastered • Last: 3 days ago                 │       │
│     └───────────────────────────────────────────────────┘       │
│                                                                 │
│     ┌───────────────────────────────────────────────────┐       │
│     │  🌱 Family                              12%       │       │
│     │  [████░░░░░░░░░░░░░░░░░░░░░░░░]                   │       │
│     │  2/20 mastered • Last: 1 week ago                 │       │
│     └───────────────────────────────────────────────────┘       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 5.4 Home Screen Updates

Add new entry points to existing home screen:

```
┌─────────────────────────────────────────────────────────────────┐
│                      LANGUAGE DUEL                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                      [App Logo]                                 │
│                   Greek ↔ Catalan                               │
│                                                                 │
│     ┌─────────────────────────────────────────┐                 │
│     │            START NEW DUEL               │                 │
│     └─────────────────────────────────────────┘                 │
│                                                                 │
│     ┌─────────────────────────────────────────┐                 │
│     │            SOLO PRACTICE                │  ← NEW          │
│     │         12 items due today              │                 │
│     └─────────────────────────────────────────┘                 │
│                                                                 │
│     ┌─────────────────────────────────────────┐                 │
│     │            MY PROGRESS                  │  ← NEW          │
│     │           52% overall • 🔥 7            │                 │
│     └─────────────────────────────────────────┘                 │
│                                                                 │
│     ┌───────────────┐     ┌───────────────┐                     │
│     │    History    │     │   Settings    │                     │
│     └───────────────┘     └───────────────┘                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 6. Implementation Tasks

### 6.1 Task Breakdown

#### Sprint 1: Foundation (Week 1)

| ID | Task | Estimate | Dependencies | Priority |
|----|------|----------|--------------|----------|
| S1-01 | Create LearnerProfile model + Hive adapter | 2h | - | P0 |
| S1-02 | Create DeckProgress model + Hive adapter | 1h | - | P0 |
| S1-03 | Create SRSItem model + Hive adapter | 2h | - | P0 |
| S1-04 | Create SoloSession model | 1h | - | P0 |
| S1-05 | Implement SRSService (algorithm) | 4h | S1-03 | P0 |
| S1-06 | Create LearnerStorageRepository | 2h | S1-01, S1-02 | P0 |
| S1-07 | Create SRSStorageRepository | 2h | S1-03 | P0 |
| S1-08 | Create learnerProfileProvider | 2h | S1-06 | P0 |
| S1-09 | Create srsItemsProvider + derived providers | 3h | S1-07 | P0 |
| S1-10 | Write unit tests for SRS algorithm | 3h | S1-05 | P0 |
| S1-11 | Initialize SRS items for existing decks | 2h | S1-07 | P1 |

**Sprint 1 Total: ~24 hours**

#### Sprint 2: Solo Mode UI (Week 2)

| ID | Task | Estimate | Dependencies | Priority |
|----|------|----------|--------------|----------|
| S2-01 | Create SoloHubScreen | 4h | S1-08, S1-09 | P0 |
| S2-02 | Create SoloSetupScreen | 3h | - | P0 |
| S2-03 | Create SoloPracticeScreen (Vocab Flash) | 4h | S2-02 | P0 |
| S2-04 | Create SoloPracticeScreen (Phrase Builder) | 4h | S2-02 | P0 |
| S2-05 | Create SoloResultsScreen | 3h | S2-03, S2-04 | P0 |
| S2-06 | Add solo routes to go_router | 1h | S2-01 | P0 |
| S2-07 | Integrate SRS processing into practice flow | 4h | S1-05, S2-03 | P0 |
| S2-08 | Update HomeScreen with solo entry point | 2h | S2-01 | P0 |
| S2-09 | Add relaxed mode (no timer) toggle | 2h | S2-03 | P1 |
| S2-10 | Widget tests for solo screens | 4h | S2-01-S2-05 | P1 |

**Sprint 2 Total: ~31 hours**

#### Sprint 3: Progress & Polish (Week 3)

| ID | Task | Estimate | Dependencies | Priority |
|----|------|----------|--------------|----------|
| S3-01 | Create ProgressDashboardScreen | 4h | S1-08 | P0 |
| S3-02 | Create DeckProgressCard widget | 2h | S3-01 | P0 |
| S3-03 | Create WeakWordsScreen | 3h | S1-09 | P0 |
| S3-04 | Implement streak tracking logic | 2h | S1-01 | P0 |
| S3-05 | Add progress route to go_router | 1h | S3-01 | P0 |
| S3-06 | Update HomeScreen with progress summary | 2h | S3-01 | P0 |
| S3-07 | Add animations (progress bars, level badges) | 3h | S3-01, S3-02 | P1 |
| S3-08 | Implement "due today" notification logic | 2h | S1-09 | P1 |
| S3-09 | Integration tests for complete solo flow | 4h | All | P1 |
| S3-10 | Documentation update | 2h | All | P2 |

**Sprint 3 Total: ~25 hours**

#### Sprint 4: Buffer & QA (Week 4 - if needed)

| ID | Task | Estimate | Dependencies | Priority |
|----|------|----------|--------------|----------|
| S4-01 | Bug fixes from testing | 8h | All | P0 |
| S4-02 | Performance optimization | 4h | All | P1 |
| S4-03 | UX refinements based on feedback | 4h | All | P1 |
| S4-04 | Additional test coverage | 4h | All | P2 |

**Sprint 4 Total: ~20 hours**

### 6.2 Dependency Graph

```
Week 1 (Foundation):
S1-01 ──┬──► S1-06 ──► S1-08 ──┐
S1-02 ──┘                      │
                               ├──► S2-01 (Solo Hub)
S1-03 ──┬──► S1-05 ──► S1-10   │
        │         │            │
        └──► S1-07 ──► S1-09 ──┘
                  │
                  └──► S1-11

Week 2 (Solo UI):
S1-08, S1-09 ──► S2-01 ──► S2-06 ──► S2-08
                    │
S2-02 ──┬──► S2-03 ─┴─► S2-05
        │       │
        └──► S2-04 ──┘
                │
S1-05 ──────────┴──► S2-07

Week 3 (Progress):
S1-08 ──► S3-01 ──► S3-02
              │
              └──► S3-05 ──► S3-06
                      │
S1-09 ──► S3-03 ──────┘
    │
    └──► S3-08

S1-01 ──► S3-04
```

### 6.3 Definition of Done

**Feature complete when:**
- [ ] All P0 tasks completed
- [ ] Unit tests passing (>80% coverage on SRS logic)
- [ ] Widget tests for all new screens
- [ ] Integration test for complete solo flow
- [ ] Manual QA checklist completed
- [ ] No P0/P1 bugs open
- [ ] Documentation updated

---

## 7. Testing Strategy

### 7.1 Unit Tests

**SRS Algorithm (Critical):**
```dart
// test/srs_service_test.dart

void main() {
  group('SRSService', () {
    late SRSService service;

    setUp(() {
      service = SRSService();
    });

    test('first correct answer sets interval to 1 day', () {
      final item = SRSItem.newItem('item1', 'deck1');
      final updated = service.processReview(item, 3, 2000);

      expect(updated.intervalDays, 1);
      expect(updated.repetitions, 1);
      expect(updated.state, SRSState.learning);
    });

    test('second correct answer sets interval to 6 days', () {
      final item = SRSItem(
        itemId: 'item1',
        deckId: 'deck1',
        repetitions: 1,
        intervalDays: 1,
        easeFactor: 2.5,
        nextReviewDate: DateTime.now(),
        lastReviewDate: DateTime.now().subtract(Duration(days: 1)),
      );
      final updated = service.processReview(item, 3, 2000);

      expect(updated.intervalDays, 6);
      expect(updated.repetitions, 2);
    });

    test('wrong answer resets to interval 1', () {
      final item = SRSItem(
        itemId: 'item1',
        deckId: 'deck1',
        repetitions: 5,
        intervalDays: 30,
        easeFactor: 2.5,
        state: SRSState.mastered,
        nextReviewDate: DateTime.now(),
        lastReviewDate: DateTime.now().subtract(Duration(days: 30)),
      );
      final updated = service.processReview(item, 1, 5000);

      expect(updated.intervalDays, 1);
      expect(updated.repetitions, 0);
      expect(updated.state, SRSState.relearning);
    });

    test('mastery achieved at 21+ days interval', () {
      final item = SRSItem(
        itemId: 'item1',
        deckId: 'deck1',
        repetitions: 3,
        intervalDays: 16,
        easeFactor: 2.6,
        state: SRSState.learning,
        nextReviewDate: DateTime.now(),
        lastReviewDate: DateTime.now().subtract(Duration(days: 16)),
      );
      final updated = service.processReview(item, 3, 2000);

      expect(updated.intervalDays, greaterThanOrEqualTo(21));
      expect(updated.state, SRSState.mastered);
    });

    test('ease factor decreases on wrong answer', () {
      final item = SRSItem.newItem('item1', 'deck1');
      final updated = service.processReview(item, 1, 5000);

      expect(updated.easeFactor, lessThan(2.5));
    });

    test('ease factor never goes below 1.3', () {
      var item = SRSItem.newItem('item1', 'deck1');

      // Get wrong 10 times
      for (int i = 0; i < 10; i++) {
        item = service.processReview(item, 1, 5000);
      }

      expect(item.easeFactor, greaterThanOrEqualTo(1.3));
    });
  });
}
```

### 7.2 Widget Tests

```dart
// test/solo_hub_screen_test.dart

void main() {
  group('SoloHubScreen', () {
    testWidgets('shows due items count', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dueItemsProvider('greetings').overrideWithValue([
              SRSItem.newItem('1', 'greetings'),
              SRSItem.newItem('2', 'greetings'),
            ]),
          ],
          child: MaterialApp(home: SoloHubScreen()),
        ),
      );

      expect(find.text('2 items due today'), findsOneWidget);
    });

    testWidgets('shows streak count', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            learnerProfileProvider.overrideWithValue(
              LearnerProfile.create().copyWith(currentStreak: 5),
            ),
          ],
          child: MaterialApp(home: SoloHubScreen()),
        ),
      );

      expect(find.text('🔥 5-day streak'), findsOneWidget);
    });

    testWidgets('navigates to setup on Practice Deck tap', (tester) async {
      // ... navigation test
    });
  });
}
```

### 7.3 Integration Tests

```dart
// integration_test/solo_flow_test.dart

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('complete solo practice flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Navigate to solo
    await tester.tap(find.text('Solo Practice'));
    await tester.pumpAndSettle();

    // Start quick review
    await tester.tap(find.text('Start Review'));
    await tester.pumpAndSettle();

    // Answer 5 questions
    for (int i = 0; i < 5; i++) {
      // Tap first option (may be right or wrong)
      await tester.tap(find.byType(OptionTile).first);
      await tester.pumpAndSettle();
      await tester.pump(Duration(seconds: 2)); // Wait for feedback
      await tester.pumpAndSettle();
    }

    // Verify results screen
    expect(find.text('PRACTICE COMPLETE'), findsOneWidget);
    expect(find.textContaining('Accuracy'), findsOneWidget);

    // Verify SRS was updated
    // (check via provider state or storage)
  });
}
```

### 7.4 Manual QA Checklist

- [ ] Solo Hub shows correct due count
- [ ] Solo Hub shows correct streak
- [ ] Practice deck selection works for all decks
- [ ] Timed mode has working timer
- [ ] Relaxed mode has no timer
- [ ] SRS Review mode pulls due items
- [ ] Correct answers update SRS (check next review date)
- [ ] Wrong answers reset SRS interval
- [ ] Results screen shows accurate stats
- [ ] Progress dashboard shows all decks
- [ ] Mastery percentages are accurate
- [ ] Weak words identified correctly
- [ ] Weak words review mode works
- [ ] Streak increments on daily practice
- [ ] Streak resets after missed day
- [ ] Back navigation works correctly
- [ ] Data persists after app restart

---

## 8. Migration & Rollout

### 8.1 Data Migration

**For existing users:**
- On first launch after update, initialize LearnerProfile
- Create SRSItem entries for all items in all decks (state: newItem)
- No existing progress to migrate (fresh start)

```dart
// lib/data/services/migration_service.dart

class MigrationService {
  final LearnerStorageRepository _learnerStorage;
  final SRSStorageRepository _srsStorage;
  final ContentRepository _contentRepo;

  Future<void> migrateToV2() async {
    // Check if migration needed
    if (await _learnerStorage.hasProfile()) return;

    // Create learner profile
    final profile = LearnerProfile.create();
    await _learnerStorage.saveProfile(profile);

    // Initialize SRS items for all decks
    final deckInfos = await _contentRepo.listDecks();
    for (final info in deckInfos) {
      final deck = await _contentRepo.loadDeck(info.id);
      for (final item in deck.items) {
        final srsItem = SRSItem.newItem(item.id, info.id);
        await _srsStorage.saveItem(srsItem);
      }
    }
  }
}
```

### 8.2 Feature Flags (Optional)

If gradual rollout desired:
```dart
class FeatureFlags {
  static bool soloModeEnabled = true;
  static bool srsEnabled = true;
  static bool progressDashboardEnabled = true;
  static bool weakWordsEnabled = true;
}
```

### 8.3 Rollout Plan

| Day | Action |
|-----|--------|
| Day 1 | Internal testing (dev team) |
| Day 2-3 | Beta testing (10-20 users) |
| Day 4 | Address critical feedback |
| Day 5 | Production release |
| Day 6-7 | Monitor analytics, hotfix if needed |

### 8.4 Success Metrics

**Week 1 post-launch:**
- [ ] 50%+ of active users try solo mode
- [ ] Average solo session length > 3 minutes
- [ ] No crash rate increase

**Week 2-4 post-launch:**
- [ ] 30%+ users return for solo practice
- [ ] Streak feature engaged by 20%+ users
- [ ] Progress dashboard viewed by 40%+ users

---

## Appendix A: File Structure Changes

```
lib/
  data/
    models/
      learner_profile.dart       ← NEW
      learner_profile.g.dart     ← GENERATED
      deck_progress.dart         ← NEW
      deck_progress.g.dart       ← GENERATED
      srs_item.dart              ← NEW
      srs_item.g.dart            ← GENERATED
      solo_session.dart          ← NEW
    providers/
      learner_provider.dart      ← NEW
      srs_provider.dart          ← NEW
      solo_session_provider.dart ← NEW
    repositories/
      learner_storage.dart       ← NEW
      srs_storage.dart           ← NEW
    services/
      srs_service.dart           ← NEW
      migration_service.dart     ← NEW
    hive_adapters.dart           ← UPDATED (add new adapters)
  features/
    solo/                        ← NEW FOLDER
      solo_hub_screen.dart
      solo_setup_screen.dart
      solo_practice_screen.dart
      solo_results_screen.dart
    progress/                    ← NEW FOLDER
      progress_dashboard_screen.dart
      deck_progress_card.dart
    weak_words/                  ← NEW FOLDER
      weak_words_screen.dart
    home/
      home_screen.dart           ← UPDATED
  app/
    routes.dart                  ← UPDATED (add new routes)
```

---

## Appendix B: Route Updates

```dart
// lib/app/routes.dart - additions

const String soloRoute = '/solo';
const String soloSetupRoute = '/solo/setup';
const String soloPracticeRoute = '/solo/practice';
const String soloResultsRoute = '/solo/results';
const String progressRoute = '/progress';
const String weakWordsRoute = '/weak';

// Add to GoRouter routes:
GoRoute(
  path: soloRoute,
  builder: (context, state) => const SoloHubScreen(),
),
GoRoute(
  path: soloSetupRoute,
  builder: (context, state) => const SoloSetupScreen(),
),
GoRoute(
  path: soloPracticeRoute,
  builder: (context, state) => const SoloPracticeScreen(),
),
GoRoute(
  path: soloResultsRoute,
  builder: (context, state) => const SoloResultsScreen(),
),
GoRoute(
  path: progressRoute,
  builder: (context, state) => const ProgressDashboardScreen(),
),
GoRoute(
  path: weakWordsRoute,
  builder: (context, state) => const WeakWordsScreen(),
),
```

---

*This plan is ready for implementation. Review with team before starting Sprint 1.*
