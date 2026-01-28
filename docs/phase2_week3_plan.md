# Phase 2 Week 3 Plan: Progress Dashboard & Polish

**Version:** 1.0
**Created:** 2026-01-27
**Duration:** ~21.5 hours
**Prerequisites:** Week 1 (Foundation) and Week 2 (Solo UI) complete
**Status:** Planning

---

## Table of Contents

1. [Status Summary](#status-summary)
2. [Week 3 Objectives](#week-3-objectives)
3. [Tasks Breakdown](#tasks-breakdown)
4. [Detailed Specifications](#detailed-specifications)
5. [Files to Create/Modify](#files-to-createmodify)
6. [Dependency Graph](#dependency-graph)
7. [Verification Plan](#verification-plan)
8. [Risk Assessment](#risk-assessment)
9. [Success Criteria](#success-criteria)

---

## Status Summary

### Week 1 (Foundation) - COMPLETE
All data models, SRS algorithm, storage, and providers implemented.

### Week 2 (UI) - 90% COMPLETE
Solo Hub, Setup, Practice, Results screens implemented. Routes added. Home screen updated.

**Week 2 Gaps:**
- S2-04: PhraseBuilder in solo practice (only VocabFlash implemented)
- S2-10: Widget tests for solo screens

**Update (2026-01-27):**
- S2-04 implemented (Phrase Builder + Mixed in solo practice)
- Solo History screen + route added
- Recent Sessions section added to Solo Hub
- Solo screen widget tests in progress

**Critical Bug Found:**
- `allDueItemsProvider` defined twice in `srs_provider.dart` (lines 60-64 and 71-75)

---

## Week 3 Objectives

Build the Progress Dashboard, add polish features, and complete testing coverage. Also address Week 2 gaps and fix the duplicate provider bug.

---

## Tasks Breakdown

### P0 - Critical Bug Fix

| ID | Task | Estimate | File |
|----|------|----------|------|
| S3-00 | Remove duplicate `allDueItemsProvider` definition | 5m | `lib/data/providers/srs_provider.dart` |

**Details:** Delete lines 71-75 which duplicate the provider definition at lines 60-64.

---

### P0 - Progress Dashboard (Sprint 3 Core)

| ID | Task | Estimate | Dependencies |
|----|------|----------|--------------|
| S3-01 | Create ProgressDashboardScreen | 3h | learnerProfileProvider |
| S3-02 | Create DeckProgressCard widget | 1.5h | S3-01 |
| S3-03 | Create SoloHistoryScreen | 2h | soloHistoryProvider |
| S3-05 | Add progress & history routes to go_router | 30m | S3-01, S3-03 |
| S3-06 | Update HomeScreen with "My Progress" button | 1h | S3-05 |

---

### P1 - Polish & Enhancements

| ID | Task | Estimate | Dependencies |
|----|------|----------|--------------|
| S3-07 | Add progress bar animations | 1.5h | S3-01, S3-02 |
| S3-08 | Add level badges to DeckProgressCard | 1h | S3-02 |
| S3-09 | Add "Recent Sessions" section to Solo Hub | 1.5h | S3-03 |
| S3-10 | Create learnerStatsProvider for convenient stats access | 1h | learnerProfileProvider |

---

### P1 - Testing (Week 2 Gap + Sprint 3)

| ID | Task | Estimate | Dependencies |
|----|------|----------|--------------|
| S3-11 | Widget tests for SoloHubScreen | 1.5h | - |
| S3-12 | Widget tests for SoloSetupScreen | 1h | - |
| S3-13 | Widget tests for SoloPracticeScreen | 2h | - |
| S3-14 | Widget tests for SoloResultsScreen | 1h | - |
| S3-15 | Widget tests for ProgressDashboardScreen | 1.5h | S3-01 |
| S3-16 | Integration test for complete solo flow | 2h | All |

---

### P2 - Documentation & Cleanup

| ID | Task | Estimate | Dependencies |
|----|------|----------|--------------|
| S3-17 | Update README with solo mode instructions | 1h | All |
| S3-18 | Add inline documentation to providers | 30m | All |

---

## Total Estimated Hours

| Priority | Tasks | Hours |
|----------|-------|-------|
| P0 | Bug fix + Dashboard core | ~8h |
| P1 | Polish + Testing | ~12h |
| P2 | Documentation | ~1.5h |
| **Total** | **18 tasks** | **~21.5h** |

---

## Detailed Specifications

### S3-01: ProgressDashboardScreen

**Route:** `/progress`

**Purpose:** Display overall learning progress across all decks with detailed statistics.

**UI Layout:**
```
+-------------------------------------------------------------+
|  [<]                    MY PROGRESS                         |
+-------------------------------------------------------------+
|                                                             |
|  +-----------------------------------------------------+    |
|  |  OVERALL MASTERY                                    |    |
|  |  [############............] 52%                     |    |
|  |                                                     |    |
|  |  fire 7-day streak   book 234 reviews   check 76% acc|   |
|  +-----------------------------------------------------+    |
|                                                             |
|  DECK PROGRESS                                              |
|                                                             |
|  +-----------------------------------------------------+    |
|  |  crown Greetings                           92%      |    |
|  |  [############################...]                  |    |
|  |  28/30 mastered - Last: Today                       |    |
|  +-----------------------------------------------------+    |
|                                                             |
|  +-----------------------------------------------------+    |
|  |  star Colors                              75%       |    |
|  |  [######################........]                   |    |
|  |  12/16 mastered - Last: Yesterday                   |    |
|  +-----------------------------------------------------+    |
|                                                             |
|  (more deck cards...)                                       |
|                                                             |
+-------------------------------------------------------------+
```

**Providers to Watch:**
- `learnerProfileProvider` - for overall stats
- `srsItemsProvider` - for per-deck mastery calculation
- `deckListProvider` - for deck names

**Key Features:**
- Animated progress bar (0-100%)
- Streak display with fire icon
- Per-deck progress cards with level badges
- "Last practiced" relative time

---

### S3-02: DeckProgressCard Widget

**File:** `lib/shared/widgets/deck_progress_card.dart`

**Props:**
```dart
class DeckProgressCard extends StatelessWidget {
  final String deckName;
  final double masteryPercentage; // 0.0 to 1.0
  final int itemsMastered;
  final int totalItems;
  final DateTime? lastPracticed;
  final VoidCallback? onTap;
}
```

**Level Badges:**

| Level | Criteria | Badge |
|-------|----------|-------|
| Beginner | 0-25% | Seedling |
| Intermediate | 26-50% | Herb |
| Advanced | 51-75% | Tree |
| Expert | 76-99% | Star |
| Master | 100% | Crown |

---

### S3-03: SoloHistoryScreen

**Route:** `/solo/history`

**Purpose:** View past solo practice sessions with stats.

**UI Layout:**
```
+-------------------------------------------------------------+
|  [<]                  PRACTICE HISTORY                      |
+-------------------------------------------------------------+
|                                                             |
|  TODAY                                                      |
|  +-----------------------------------------------------+    |
|  |  Greetings - Vocab Flash                            |    |
|  |  Score: 85  -  Accuracy: 80%  -  3:42               |    |
|  |  10:30 AM                                           |    |
|  +-----------------------------------------------------+    |
|                                                             |
|  YESTERDAY                                                  |
|  +-----------------------------------------------------+    |
|  |  Colors - SRS Review                                |    |
|  |  Score: 120  -  Accuracy: 90%  -  5:15              |    |
|  |  8:45 PM                                            |    |
|  +-----------------------------------------------------+    |
|                                                             |
|  OLDER                                                      |
|  +-----------------------------------------------------+    |
|  |  Numbers - Relaxed                                  |    |
|  |  Score: 65  -  Accuracy: 65%  -  4:20               |    |
|  |  Jan 24                                             |    |
|  +-----------------------------------------------------+    |
|                                                             |
+-------------------------------------------------------------+
```

**Provider:** `soloHistoryProvider`

**Grouping:** Sessions grouped by date (Today, Yesterday, Older).

---

### S3-05: Route Updates

**File:** `lib/app/routes.dart`

Add:
```dart
const String progressRoute = '/progress';
const String soloHistoryRoute = '/solo/history';

// In GoRouter routes:
GoRoute(
  path: progressRoute,
  builder: (context, state) => const ProgressDashboardScreen(),
),
GoRoute(
  path: soloHistoryRoute,
  builder: (context, state) => const SoloHistoryScreen(),
),
```

---

### S3-06: HomeScreen Update

Add "My Progress" button after Solo Practice:
```dart
OutlinedButton(
  onPressed: () => context.push(progressRoute),
  child: Column(
    children: [
      const Text('My Progress'),
      Text(
        '${profile.overallMastery.toStringAsFixed(0)}% mastery - fire ${profile.currentStreak}',
        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
      ),
    ],
  ),
),
```

---

### S3-09: Solo Hub "Recent Sessions" Section

Add to SoloHubScreen after action cards:
```dart
// Recent Sessions
Consumer(
  builder: (context, ref, _) {
    final history = ref.watch(soloHistoryProvider);
    final recent = history.take(3).toList();
    if (recent.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Sessions', style: TextStyle(fontWeight: FontWeight.w600)),
            TextButton(
              onPressed: () => context.push(soloHistoryRoute),
              child: const Text('See All'),
            ),
          ],
        ),
        // List recent sessions...
      ],
    );
  },
),
```

---

### S3-10: LearnerStatsProvider

**File:** `lib/data/providers/srs_provider.dart`

```dart
class LearnerStats {
  final int totalReviews;
  final int currentStreak;
  final int longestStreak;
  final double overallMastery;
  final int dueToday;
  final int weakCount;
  final int totalMastered;
  final int totalItems;

  const LearnerStats({
    this.totalReviews = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.overallMastery = 0.0,
    this.dueToday = 0,
    this.weakCount = 0,
    this.totalMastered = 0,
    this.totalItems = 0,
  });
}

final learnerStatsProvider = Provider<LearnerStats>((ref) {
  final profileAsync = ref.watch(learnerProfileProvider);
  final srsItems = ref.watch(srsItemsProvider).value ?? {};

  return profileAsync.when(
    data: (profile) {
      final dueCount = srsItems.values.where((i) => i.isDue).length;
      final weakCount = srsItems.values.where((i) => i.isWeak).length;
      final masteredCount = srsItems.values.where((i) => i.isMastered).length;

      return LearnerStats(
        totalReviews: profile.totalReviews,
        currentStreak: profile.currentStreak,
        longestStreak: profile.longestStreak,
        overallMastery: profile.overallMastery,
        dueToday: dueCount,
        weakCount: weakCount,
        totalMastered: masteredCount,
        totalItems: srsItems.length,
      );
    },
    loading: () => const LearnerStats(),
    error: (_, __) => const LearnerStats(),
  );
});
```

---

## Files to Create/Modify

### Files to Create

```
lib/
  features/
    progress/                              <- NEW FOLDER
      progress_dashboard_screen.dart       <- S3-01
    solo/
      solo_history_screen.dart             <- S3-03
  shared/
    widgets/
      deck_progress_card.dart              <- S3-02
      animated_progress_bar.dart           <- S3-07

test/
  solo_hub_screen_test.dart                <- S3-11
  solo_setup_screen_test.dart              <- S3-12
  solo_practice_screen_test.dart           <- S3-13
  solo_results_screen_test.dart            <- S3-14
  progress_dashboard_screen_test.dart      <- S3-15

integration_test/
  solo_flow_test.dart                      <- S3-16
```

### Files to Modify

| File | Changes |
|------|---------|
| `lib/data/providers/srs_provider.dart` | Remove duplicate provider (S3-00), add LearnerStats (S3-10) |
| `lib/app/routes.dart` | Add progress and history routes (S3-05) |
| `lib/features/home/home_screen.dart` | Add My Progress button (S3-06) |
| `lib/features/solo/solo_hub_screen.dart` | Add Recent Sessions section (S3-09) |

---

## Dependency Graph

```
S3-00 (Bug Fix) --+
                  |
S3-02 (Widget) ---+---> S3-01 (Dashboard) --+--> S3-05 (Routes) --> S3-06 (Home)
                  |                         |
S3-07 (Animations)+                         +--> S3-15 (Tests)

S3-03 (History) --> S3-05 (Routes) --> S3-09 (Solo Hub Recent)

S3-10 (Stats Provider) --> S3-01 (Dashboard)

S3-11-14 (Tests) --> S3-16 (Integration)
```

---

## Verification Plan

### Manual Testing Checklist

**Bug Fix:**
- [ ] App runs without duplicate provider error
- [ ] `allDueItemsProvider` works correctly

**Progress Dashboard:**
- [ ] Progress route navigates correctly
- [ ] Overall mastery percentage displays accurately
- [ ] Streak and review counts are correct
- [ ] All decks show with correct progress
- [ ] Level badges display correctly (seedling, herb, tree, star, crown)
- [ ] Progress bars animate on load
- [ ] "Last practiced" shows correct relative time

**Solo History:**
- [ ] History route navigates correctly
- [ ] Sessions grouped by date correctly
- [ ] Session details (score, accuracy, duration) display
- [ ] Empty state shows when no history
- [ ] Sessions sorted newest first

**Home Screen:**
- [ ] My Progress button appears
- [ ] Shows mastery % and streak
- [ ] Navigates to Progress Dashboard

**Solo Hub:**
- [ ] Recent Sessions section appears (if history exists)
- [ ] "See All" navigates to history screen
- [ ] Shows last 3 sessions

### Test Commands

```bash
# Run all tests
flutter test

# Run solo-specific tests
flutter test test/solo_*.dart

# Run integration tests
flutter test integration_test/

# Run with coverage
flutter test --coverage
```

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Deck list not available when building progress | Low | High | Add null checks, show placeholder |
| SRS items map large, slow UI | Low | Medium | Compute mastery in provider, not widget |
| History grows unbounded | Low | Low | Consider pagination in future |
| Progress bar animation jank | Medium | Low | Use AnimatedContainer or TweenAnimationBuilder |

---

## Out of Scope (Week 4 / Buffer)

- PhraseBuilder game in solo mode (S2-04)
- Notification for due items
- Export/share progress
- Deck detail screen (drill down)
- Performance optimization for large SRS data sets

---

## Success Criteria

Week 3 is complete when:
- [ ] S3-00 bug fix deployed
- [ ] Progress Dashboard shows accurate data for all decks
- [ ] Solo History displays past sessions
- [ ] Home screen has "My Progress" entry point
- [ ] Solo Hub shows recent sessions
- [ ] All P0 and P1 tests passing
- [ ] No regressions in existing functionality
