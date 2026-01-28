# Phase 2 - Week 4 Plan (Buffer & QA)

**Week:** 4  
**Status:** Planned  
**Owner:** Engineering  
**Goal:** Stabilize Solo Mode + Progress features, improve UX, and validate reliability before release.

---

## Day 1 - Bug Fix Pass
- Validate solo flow end-to-end (Setup → Practice → Results → Hub).
- Verify SRS review edge cases (no due items, all due items, weak-only).
- Confirm deck ID consistency in Solo session summaries.
- Fix navigation regressions (back stack, “Quit practice”, deep links).

## Day 2 - Performance + Data Integrity
- Reduce heavy data loads in Weak Words and Progress (load only needed decks).
- Ensure Hive boxes remain bounded (no duplicate SRS items; safe clears).
- Validate migration for existing users (profile + SRS item init).

## Day 3 - UX Polish
- Improve empty states (Progress, Weak Words, Solo Hub).
- Standardize loading/error visuals across new screens.
- Tighten spacing/alignment for progress cards and stat pills.

## Day 4 - Testing
- Integration test: full Solo flow.
- Unit tests: SRS logic + progress aggregation.
- Manual QA checklist pass.

## Day 5 - Release Prep
- Fix remaining P1 issues.
- Update docs/checklists.
- Scope freeze + tag release candidate.

---

## Optional Enhancements (If Time)
- Add “Reset Solo Progress” button in Settings for QA/support.
- Lightweight analytics hooks for Solo usage (if analytics infra is ready).

