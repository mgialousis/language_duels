# Recent Changes Log — 2026-01-30

This document summarizes recent changes made in the repo across Phase 2 learning updates and Phase 3 UX polish.

## Phase 2 — Learning/SRS Updates (Grammar + Vocab Separation)

- Added shared helpers for grammar SRS item IDs and parsing.
  - `lib/data/services/srs_helpers.dart`
- Standardized grammar SRS updates to use helpers.
  - `lib/features/grammar/exercise_results_screen.dart`
- Split SRS due/weak providers into vocab-only vs grammar-only streams; kept an all-items fallback.
  - `lib/data/providers/srs_provider.dart`
- Added a provider to surface due grammar lessons by resolving SRS items → lesson files.
  - `lib/data/providers/grammar_provider.dart`
- Surfaced due grammar lessons in the Grammar Hub UI.
  - `lib/features/grammar/grammar_hub_screen.dart`
- Updated Home, Solo Hub, and Progress screens to show vocab-only due counts.
  - `lib/features/home/home_screen.dart`
  - `lib/features/solo/solo_hub_screen.dart`
  - `lib/features/progress/progress_dashboard_screen.dart`
- Added tests for grammar SRS helpers and updated solo hub test overrides.
  - `test/srs_helpers_test.dart`
  - `test/solo_hub_screen_test.dart`
- Documented grammar SRS review behavior in README.
  - `README.md`

## Phase 3 — UX Polish & Engagement

### Onboarding / Tutorial
- Added walkthrough mode to the How To Play flow (page-based tutorial).
- Updated routing to enable `?walkthrough=true` and added a Home CTA.
- Expanded How To Play content to include all mini-games.
  - `lib/app/routes.dart`
  - `lib/features/home/home_screen.dart`
  - `lib/features/how_to_play/how_to_play_screen.dart`

### Accessibility Pass (Shared Game Widgets)
- Improved text scaling by using `Theme.textTheme` where possible.
- Added semantics and labels to key interactive widgets.
- Added tooltip + semantics to audio playback controls.
- Improved spelling input usability (label, input action, suggestions off).
  - `lib/shared/widgets/flash_card.dart`
  - `lib/shared/widgets/true_false_buttons.dart`
  - `lib/shared/widgets/match_tile.dart`
  - `lib/shared/widgets/spelling_input.dart`
  - `lib/shared/widgets/audio_play_button.dart`
  - `lib/shared/widgets/answer_feedback.dart`
  - `lib/shared/widgets/timer_bar.dart`

### Turn-Handoff Privacy & Timing
- Added name reveal toggle (hide/reveal) to prevent shoulder-surfing.
- Reduced-motion handling for icon animation and transitions.
- Countdown flow now respects reduced motion and fade timing.
  - `lib/features/duel/turn_transition_screen.dart`

## Grammar Content Expansion — Present Tense (A1)
- Added common irregular present tense lesson with expanded conjugation tables and exercises.
  - `assets/data/grammar/a1/a1_g10_present_tense_irregular.json`
- Added present passive voice lessons for A' and B' class verbs.
  - `assets/data/grammar/a1/a1_g11_present_tense_passive_a.json`
  - `assets/data/grammar/a1/a1_g12_present_tense_passive_b.json`
- Updated grammar index and asset registration for the new lessons.
  - `assets/data/grammar/grammar_index.json`
  - `pubspec.yaml`
- Standardized passive voice terminology to align with textbook phrasing.
  - `assets/data/grammar/a1/a1_g11_present_tense_passive_a.json`
  - `assets/data/grammar/a1/a1_g12_present_tense_passive_b.json`

## Notes / Gaps
- No automated tests added for tutorial flow or handoff UX.
- Accessibility updates focused on shared widgets; game screens should still be reviewed.
