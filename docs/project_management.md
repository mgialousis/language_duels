# Language Duel MVP - Project Management Document

**Version:** 1.0
**Last Updated:** 2026-01-26
**Project:** Language Duel - Competitive Language Learning Game
**Mode:** Single-phone hot-seat (two players share one device)
**Languages:** Greek <-> Catalan, A1 beginner level
**Tech Stack:** Flutter, Riverpod, Local Storage (JSON initially, Hive/Isar for persistence)

---

## Table of Contents

1. [Task Breakdown with Dependencies](#1-task-breakdown-with-dependencies)
2. [Sprint Plan](#2-sprint-plan)
3. [Definition of Done](#3-definition-of-done)
4. [Risk Register](#4-risk-register)
5. [Testing Checklist](#5-testing-checklist)
6. [MVP Launch Criteria](#6-mvp-launch-criteria)

---

## 1. Task Breakdown with Dependencies

### Phase 1: Project Setup (Foundation)

| Task ID | Task Name | Description | Dependencies | Estimated Hours | Priority |
|---------|-----------|-------------|--------------|-----------------|----------|
| S-001 | Project Structure Setup | Create folder structure: `lib/models`, `lib/providers`, `lib/screens`, `lib/widgets`, `lib/games`, `lib/services`, `lib/utils`, `assets/data` | None | 1 | P0 |
| S-002 | Add Core Dependencies | Add Riverpod, Hive/Isar, go_router, equatable, json_annotation to pubspec.yaml | S-001 | 1 | P0 |
| S-003 | Configure Riverpod | Set up ProviderScope in main.dart, create base provider structure | S-002 | 2 | P0 |
| S-004 | Set Up Routing | Configure go_router with initial routes (home, player_setup, game, results) | S-003 | 2 | P0 |
| S-005 | Design System Setup | Create theme constants (colors, typography, spacing), app theme data | S-001 | 3 | P0 |
| S-006 | Local Storage Service | Implement storage abstraction layer for game data persistence | S-002 | 3 | P1 |

### Phase 2: Content & Data Models

| Task ID | Task Name | Description | Dependencies | Estimated Hours | Priority |
|---------|-----------|-------------|--------------|-----------------|----------|
| C-001 | Define Data Models | Create Dart models: `VocabItem`, `Phrase`, `ContentDeck`, `Player`, `GameSession`, `Round`, `Score` | S-001 | 4 | P0 |
| C-002 | Create Greetings Deck JSON | Build JSON file with ~30 greeting items (Greek <-> Catalan), include phonetic hints | C-001 | 6 | P0 |
| C-003 | Content Loader Service | Service to load and parse JSON content decks | C-001, C-002 | 3 | P0 |
| C-004 | Content Validation | Validate deck completeness, language pair consistency, A1 level appropriateness | C-002 | 2 | P1 |
| C-005 | Deck Shuffling Logic | Implement randomization with fair distribution algorithm | C-003 | 2 | P1 |

### Phase 3: Core UI Components

| Task ID | Task Name | Description | Dependencies | Estimated Hours | Priority |
|---------|-----------|-------------|--------------|-----------------|----------|
| U-001 | Home Screen | Landing screen with "Start Duel" button, app branding | S-004, S-005 | 3 | P0 |
| U-002 | Player Setup Screen | Input fields for Player 1 & Player 2 names, language direction selection | U-001 | 4 | P0 |
| U-003 | Duel Hub Screen | Central game flow controller, shows current player, round info, mini-game selection | U-002 | 5 | P0 |
| U-004 | Turn Transition Screen | "Pass to [Player Name]" screen with privacy (hides previous answer) | U-003 | 3 | P0 |
| U-005 | Results Screen | Final scores, winner announcement, play again option | U-003 | 4 | P0 |
| U-006 | Shared UI Components | Reusable widgets: ScoreCard, Timer, PlayerBadge, AnswerFeedback, DuelButton | S-005 | 4 | P0 |
| U-007 | Responsive Layout | Ensure UI works on various phone sizes (min 320px width) | U-001 to U-006 | 3 | P1 |

### Phase 4: Mini-Game Implementation

#### 4A: Vocab Flash Duel

| Task ID | Task Name | Description | Dependencies | Estimated Hours | Priority |
|---------|-----------|-------------|--------------|-----------------|----------|
| G1-001 | Flash Card UI | Display word in source language, 4 answer options in target language | U-006, C-003 | 4 | P0 |
| G1-002 | Answer Selection Logic | Handle tap, validate answer, update score | G1-001, C-001 | 3 | P0 |
| G1-003 | Timer Component | Countdown timer (10 seconds per question), auto-skip on timeout | G1-001 | 2 | P0 |
| G1-004 | Scoring System | Points: +10 correct, +5 speed bonus (<3s), 0 wrong/timeout | G1-002 | 2 | P0 |
| G1-005 | Visual Feedback | Correct/incorrect animations, color changes, sound preparation hooks | G1-002 | 3 | P0 |
| G1-006 | Round State Management | Track questions answered, manage round completion | G1-002, G1-004 | 3 | P0 |

#### 4B: Phrase Builder (Reorder)

| Task ID | Task Name | Description | Dependencies | Estimated Hours | Priority |
|---------|-----------|-------------|--------------|-----------------|----------|
| G2-001 | Scrambled Words UI | Display scrambled phrase words as draggable tiles | U-006, C-003 | 5 | P0 |
| G2-002 | Drag & Drop System | Implement ReorderableListView or custom drag logic | G2-001 | 4 | P0 |
| G2-003 | Order Validation | Check if arranged words match correct phrase order | G2-002 | 2 | P0 |
| G2-004 | Submit & Scoring | Submit button, partial credit option (% correct positions) | G2-003 | 3 | P0 |
| G2-005 | Hint System | Optional hint showing first word position (costs points) | G2-001 | 2 | P1 |
| G2-006 | Timer & Time Pressure | 30-second timer for phrase building | G2-001 | 2 | P0 |

### Phase 5: Game Flow & State Management

| Task ID | Task Name | Description | Dependencies | Estimated Hours | Priority |
|---------|-----------|-------------|--------------|-----------------|----------|
| F-001 | Game Session Provider | Riverpod provider managing full game session state | S-003, C-001 | 5 | P0 |
| F-002 | Turn Management | Logic for alternating between players, tracking current turn | F-001 | 3 | P0 |
| F-003 | Round Configuration | Configure rounds (5 questions per player per mini-game) | F-001 | 2 | P0 |
| F-004 | Score Aggregation | Calculate and display cumulative scores across mini-games | F-001, G1-004, G2-004 | 3 | P0 |
| F-005 | Game Completion Logic | Determine winner, handle ties, trigger results screen | F-004 | 2 | P0 |
| F-006 | Game Persistence | Save/restore game state for app backgrounding | F-001, S-006 | 4 | P1 |

### Phase 6: Polish & UX

| Task ID | Task Name | Description | Dependencies | Estimated Hours | Priority |
|---------|-----------|-------------|--------------|-----------------|----------|
| P-001 | Loading States | Skeleton screens, progress indicators | All UI tasks | 2 | P1 |
| P-002 | Error Handling UI | User-friendly error messages, retry options | All tasks | 3 | P1 |
| P-003 | Animations | Page transitions, score updates, answer feedback animations | U-006 | 4 | P2 |
| P-004 | Accessibility Basics | Semantic labels, sufficient contrast, tap target sizes | All UI tasks | 3 | P1 |
| P-005 | Performance Optimization | Widget rebuilds, image caching, list optimization | All tasks | 3 | P2 |
| P-006 | Sound Effect Hooks | Prepare audio hooks (implementation optional for MVP) | G1-005, G2-004 | 2 | P2 |

---

## 2. Sprint Plan

### Sprint Overview

| Sprint | Duration | Focus Area | Goal |
|--------|----------|------------|------|
| Sprint 1 | Days 1-7 | Foundation + Content | Playable content loaded, navigation working |
| Sprint 2 | Days 8-14 | Mini-Games Core | Both mini-games functional (basic) |
| Sprint 3 | Days 15-21 | Game Flow + Polish | Complete duel flow, scoring, results |
| Sprint 4 | Days 22-28 | Testing + Launch Prep | Bug fixes, QA, MVP launch ready |

---

### Sprint 1: Foundation + Content (Days 1-7)

**Sprint Goal:** Establish project structure, load content, basic navigation working

**Tasks:**

| Day | Tasks | Owner | Notes |
|-----|-------|-------|-------|
| 1-2 | S-001, S-002, S-003 | Dev | Project setup, dependencies, Riverpod |
| 2-3 | S-004, S-005 | Dev | Routing, design system |
| 3-4 | C-001, C-002 | Dev + Content | Data models, Greetings deck creation |
| 5-6 | C-003, C-004, C-005 | Dev | Content loading, validation, shuffling |
| 7 | U-001, U-002 | Dev | Home screen, player setup |

**Sprint 1 Definition of Done:**
- [ ] App launches without errors
- [ ] Navigation between Home -> Player Setup works
- [ ] Greetings deck (30 items) loads successfully
- [ ] Player names can be entered and stored in state
- [ ] Design tokens (colors, fonts) applied consistently

**Capacity:** ~35 hours

---

### Sprint 2: Mini-Games Core (Days 8-14)

**Sprint Goal:** Both mini-games playable in isolation

**Tasks:**

| Day | Tasks | Owner | Notes |
|-----|-------|-------|-------|
| 8-9 | G1-001, G1-002, G1-003 | Dev | Vocab Flash: UI, selection, timer |
| 10 | G1-004, G1-005, G1-006 | Dev | Vocab Flash: scoring, feedback, state |
| 11-12 | G2-001, G2-002 | Dev | Phrase Builder: UI, drag-drop |
| 13-14 | G2-003, G2-004, G2-006 | Dev | Phrase Builder: validation, scoring, timer |

**Sprint 2 Definition of Done:**
- [ ] Vocab Flash Duel: Player can answer 5 questions, see score
- [ ] Vocab Flash Duel: Timer works, auto-advances on timeout
- [ ] Phrase Builder: Player can reorder words, submit answer
- [ ] Phrase Builder: Scoring works with timer
- [ ] Both games use content from Greetings deck

**Capacity:** ~35 hours

---

### Sprint 3: Game Flow + Polish (Days 15-21)

**Sprint Goal:** Complete duel flow from start to winner announcement

**Tasks:**

| Day | Tasks | Owner | Notes |
|-----|-------|-------|-------|
| 15-16 | F-001, F-002, F-003 | Dev | Session provider, turns, rounds |
| 17 | U-003, U-004 | Dev | Duel Hub, turn transitions |
| 18 | F-004, F-005 | Dev | Score aggregation, completion |
| 19 | U-005 | Dev | Results screen |
| 20-21 | U-006, U-007, P-001 | Dev | Shared components, responsive, loading |

**Sprint 3 Definition of Done:**
- [ ] Full duel: 2 players alternate, play both mini-games
- [ ] Turn transitions protect player answers
- [ ] Final scores displayed correctly
- [ ] Winner correctly determined
- [ ] "Play Again" returns to start
- [ ] UI responsive on different screen sizes

**Capacity:** ~35 hours

---

### Sprint 4: Testing + Launch Prep (Days 22-28)

**Sprint Goal:** Bug-free MVP ready for user testing

**Tasks:**

| Day | Tasks | Owner | Notes |
|-----|-------|-------|-------|
| 22-23 | S-006, F-006 | Dev | Storage service, game persistence |
| 24 | P-002, P-004 | Dev | Error handling, accessibility |
| 25-26 | Full QA Cycle | QA/Dev | Manual testing, bug fixing |
| 27 | P-003, P-005 | Dev | Animations, performance |
| 28 | Launch Prep | All | Final testing, build, documentation |

**Sprint 4 Definition of Done:**
- [ ] All automated tests passing
- [ ] Manual QA checklist completed
- [ ] No P0/P1 bugs open
- [ ] App persists state on background
- [ ] Performance acceptable (no visible jank)
- [ ] Build successful for target platforms

**Capacity:** ~35 hours

---

## 3. Definition of Done

### Component-Level Definitions

#### Data Models (C-001)
- [ ] All model classes created with appropriate fields
- [ ] Equatable implemented for value equality
- [ ] JSON serialization/deserialization working
- [ ] Unit tests for model creation and serialization
- [ ] Documentation comments on all public members

#### Content Deck (C-002)
- [ ] 30 unique vocabulary/phrase items
- [ ] Both directions covered (Greek->Catalan, Catalan->Greek)
- [ ] A1 CEFR level verified
- [ ] No spelling errors (native speaker review)
- [ ] Phonetic hints included where helpful
- [ ] JSON validates against schema

#### Screen/Page (U-XXX)
- [ ] Renders without errors on iPhone SE (smallest target)
- [ ] Renders without errors on iPhone 14 Pro Max (largest target)
- [ ] All interactive elements have proper tap targets (min 44px)
- [ ] Loading states implemented
- [ ] Error states handled gracefully
- [ ] Back navigation works correctly
- [ ] State preserved on hot reload
- [ ] Widget tests for critical interactions

#### Mini-Game (G1-XXX, G2-XXX)
- [ ] Game rules implemented as specified
- [ ] Timer works correctly (starts, counts, ends)
- [ ] Scoring matches specification
- [ ] Visual feedback clear (correct/incorrect)
- [ ] Player cannot interact after round ends
- [ ] Content loads correctly from deck
- [ ] No duplicate questions in same round
- [ ] Integration test for complete game flow

#### Provider/State Management (F-XXX)
- [ ] State updates trigger appropriate rebuilds
- [ ] State persists correctly during session
- [ ] State can be reset for new game
- [ ] Unit tests for state transitions
- [ ] No memory leaks (dispose properly)

### Overall MVP Definition of Done
- [ ] Two players can complete a full duel
- [ ] Both mini-games functional and fun
- [ ] Scoring accurate across all games
- [ ] Winner correctly identified
- [ ] UI clear and intuitive (no instruction needed)
- [ ] No crashes during normal gameplay
- [ ] Performance: <100ms response to user input
- [ ] All P0 tests passing
- [ ] Manual QA checklist signed off

---

## 4. Risk Register

| Risk ID | Risk Description | Probability | Impact | Severity | Mitigation Strategy | Owner | Status |
|---------|------------------|-------------|--------|----------|---------------------|-------|--------|
| R-001 | **Content Quality Issues** - Greetings deck has incorrect translations or inappropriate difficulty | Medium | High | HIGH | 1. Have native speakers review content before Sprint 2. 2. Build validation tool for deck format. 3. Plan content revision buffer in Sprint 4 | Content Lead | Open |
| R-002 | **Scope Creep** - Stakeholders request additional mini-games or features | High | High | HIGH | 1. Freeze feature set after Sprint 1. 2. Document all requests in backlog for v1.1. 3. Weekly scope review meetings | PM | Open |
| R-003 | **Drag-Drop Performance** - Phrase Builder drag-drop may perform poorly on low-end devices | Medium | Medium | MEDIUM | 1. Test early on low-end device (Sprint 2). 2. Have fallback tap-to-select UI. 3. Optimize with RepaintBoundary if needed | Dev | Open |
| R-004 | **State Management Complexity** - Game flow state becomes difficult to manage/debug | Medium | Medium | MEDIUM | 1. Use Riverpod DevTools. 2. Keep providers small and focused. 3. Comprehensive unit tests for providers | Dev | Open |
| R-005 | **Hot-Seat Privacy** - Players may see each other's answers during transition | Low | High | MEDIUM | 1. Mandatory transition screen. 2. Visual "cover" animation. 3. No answer visible after submission | Dev | Open |
| R-006 | **Timer Accuracy** - Timer may drift or behave inconsistently | Low | Medium | LOW | 1. Use Stopwatch class for accuracy. 2. Test timer under app backgrounding. 3. Grace period for edge cases | Dev | Open |
| R-007 | **Flutter/Dart Version Incompatibility** - Dependencies may conflict with Flutter 3.10+ | Low | High | MEDIUM | 1. Lock dependency versions in pubspec. 2. Test full build on CI. 3. Document working Flutter version | Dev | Open |
| R-008 | **Content Deck Expansion** - Adding new decks harder than expected | Medium | Low | LOW | 1. Design deck format to be extensible. 2. Document deck creation process. 3. Create deck template | Dev | Open |
| R-009 | **Player Frustration** - Mini-games too hard or too easy for A1 learners | Medium | Medium | MEDIUM | 1. User testing in Sprint 4. 2. Adjustable difficulty (future). 3. Clear feedback on wrong answers | PM | Open |
| R-010 | **App Backgrounding** - Game state lost if phone call interrupts | Medium | Medium | MEDIUM | 1. Implement game persistence (F-006). 2. Auto-save after each turn. 3. Resume from last state | Dev | Open |

### Risk Severity Matrix

|              | Low Impact | Medium Impact | High Impact |
|--------------|------------|---------------|-------------|
| **High Prob** | LOW | MEDIUM | HIGH |
| **Med Prob** | LOW | MEDIUM | HIGH |
| **Low Prob** | LOW | LOW | MEDIUM |

### Risk Review Schedule
- **Weekly:** Review all MEDIUM and HIGH risks
- **Sprint Planning:** Re-assess all risks, update probabilities
- **Sprint Retro:** Add new risks identified during sprint

---

## 5. Testing Checklist

### 5.1 Unit Tests

#### Models
- [ ] `VocabItem` creation and JSON serialization
- [ ] `Phrase` creation with word list
- [ ] `ContentDeck` loading from JSON
- [ ] `Player` score calculations
- [ ] `GameSession` state transitions
- [ ] `Score` point calculations and totals

#### Services
- [ ] Content loader parses valid JSON
- [ ] Content loader handles malformed JSON gracefully
- [ ] Storage service saves and retrieves data
- [ ] Deck shuffling produces valid random order
- [ ] Deck shuffling doesn't repeat items inappropriately

#### Providers
- [ ] `GameSessionProvider` initializes correctly
- [ ] Player turn alternates correctly
- [ ] Score updates propagate to UI
- [ ] Round completion triggers correctly
- [ ] Game reset clears all state

#### Game Logic
- [ ] Vocab Flash: Correct answer awards points
- [ ] Vocab Flash: Wrong answer awards zero
- [ ] Vocab Flash: Speed bonus calculated correctly
- [ ] Vocab Flash: Timeout handled correctly
- [ ] Phrase Builder: Correct order validated
- [ ] Phrase Builder: Partial credit calculated
- [ ] Phrase Builder: Hint deduction applied

### 5.2 Widget Tests

#### Screens
- [ ] Home screen renders with start button
- [ ] Player setup validates empty names
- [ ] Player setup accepts valid names
- [ ] Duel hub shows correct player name
- [ ] Turn transition hides previous answer
- [ ] Results screen shows correct winner

#### Game Widgets
- [ ] Flash card displays question text
- [ ] Answer options are tappable
- [ ] Selected answer shows visual feedback
- [ ] Timer displays and counts down
- [ ] Timer triggers callback at zero
- [ ] Draggable tiles can be reordered
- [ ] Submit button enabled after arrangement
- [ ] Score card displays correct values

#### Shared Components
- [ ] ScoreCard updates when score changes
- [ ] PlayerBadge shows correct name and color
- [ ] DuelButton responds to tap
- [ ] AnswerFeedback shows correct/incorrect state

### 5.3 Integration Tests

#### Full Game Flow
- [ ] Complete game: Player setup -> Mini-game 1 -> Transition -> Mini-game 1 -> Transition -> Mini-game 2 -> ... -> Results
- [ ] Both players complete all rounds
- [ ] Scores accumulate correctly across mini-games
- [ ] Winner determined correctly (including ties)
- [ ] "Play Again" starts fresh game

#### Content Integration
- [ ] Greetings deck loads on app start
- [ ] Questions pulled from deck correctly
- [ ] No duplicate questions in single round
- [ ] Both language directions work

#### State Persistence
- [ ] Game state survives app background
- [ ] Game state restored on foreground
- [ ] Interrupted game can resume

### 5.4 Manual QA Checklist

#### Visual/UX
- [ ] Text readable on all target devices
- [ ] Touch targets large enough (44px min)
- [ ] Color contrast sufficient (WCAG AA)
- [ ] No text truncation or overflow
- [ ] Animations smooth (60fps)
- [ ] Loading states visible when appropriate

#### Gameplay Feel
- [ ] Timer creates appropriate urgency
- [ ] Feedback feels rewarding (correct answers)
- [ ] Feedback not discouraging (wrong answers)
- [ ] Turn transitions feel fair
- [ ] Overall experience feels "fun"

#### Edge Cases
- [ ] Very long player names handled
- [ ] Rapid tapping doesn't break state
- [ ] Back button behavior appropriate
- [ ] App handles rotation (or is locked)
- [ ] System font size scaling works
- [ ] Dark mode (if supported)

#### Device Testing Matrix

| Device | OS Version | Screen Size | Status |
|--------|------------|-------------|--------|
| iPhone SE 2nd | iOS 15+ | 4.7" | [ ] Pass |
| iPhone 14 | iOS 16+ | 6.1" | [ ] Pass |
| iPhone 14 Pro Max | iOS 16+ | 6.7" | [ ] Pass |
| Pixel 4a | Android 12 | 5.8" | [ ] Pass |
| Samsung Galaxy S21 | Android 13 | 6.2" | [ ] Pass |
| Tablet (if supported) | - | 10"+ | [ ] Pass |

---

## 6. MVP Launch Criteria

### Must Have (All Required)

#### Functional Requirements
- [x] **F-MVP-01:** Two players can enter their names and start a duel
- [x] **F-MVP-02:** Players alternate turns, each seeing only their own questions
- [x] **F-MVP-03:** Vocab Flash Duel mini-game is playable with 5 questions per player
- [x] **F-MVP-04:** Phrase Builder mini-game is playable with 3 phrases per player
- [x] **F-MVP-05:** Scoring works correctly for both mini-games
- [x] **F-MVP-06:** Final results screen shows both scores and declares winner
- [x] **F-MVP-07:** "Play Again" option returns to player setup
- [x] **F-MVP-08:** Greetings deck has minimum 30 items (Greek <-> Catalan)

#### Quality Requirements
- [x] **Q-MVP-01:** App does not crash during normal gameplay
- [x] **Q-MVP-02:** UI response time < 100ms for all interactions
- [x] **Q-MVP-03:** No visible frame drops during animations
- [x] **Q-MVP-04:** All text legible without zooming
- [x] **Q-MVP-05:** Zero P0 (critical) bugs open
- [x] **Q-MVP-06:** Maximum 2 P1 (major) bugs with documented workarounds

#### Testing Requirements
- [x] **T-MVP-01:** All unit tests passing (>80% coverage on core logic)
- [x] **T-MVP-02:** All widget tests passing for critical flows
- [x] **T-MVP-03:** Full integration test passing
- [x] **T-MVP-04:** Manual QA checklist completed and signed off

### Should Have (Target for MVP)

- [ ] **S-MVP-01:** Game state persists across app backgrounding
- [ ] **S-MVP-02:** Basic sound effects or haptic feedback
- [ ] **S-MVP-03:** Hint system in Phrase Builder
- [ ] **S-MVP-04:** Speed bonus in Vocab Flash clearly communicated

### Nice to Have (Post-MVP)

- [ ] **N-001:** Additional content decks (beyond Greetings)
- [ ] **N-002:** Difficulty settings
- [ ] **N-003:** Player statistics/history
- [ ] **N-004:** Additional mini-games
- [ ] **N-005:** Audio pronunciation

---

### Launch Readiness Checklist

#### Pre-Launch (Day -3)
- [ ] All "Must Have" criteria checked
- [ ] Release build tested on physical devices
- [ ] Version number updated (1.0.0)
- [ ] Screenshots captured for any documentation

#### Launch Day (Day 0)
- [ ] Final smoke test on release build
- [ ] Distribute to test users
- [ ] Monitor for crash reports
- [ ] Collect initial feedback

#### Post-Launch (Day +1 to +7)
- [ ] Triage any reported issues
- [ ] Hotfix critical bugs if found
- [ ] Gather user feedback for v1.1 planning
- [ ] Celebrate!

---

## Appendix A: Task Dependency Graph

```
Phase 1 (Setup)
S-001 ─┬─> S-002 ─> S-003 ─> S-004
       │
       └─> S-005

S-002 ────> S-006

Phase 2 (Content)
S-001 ─────> C-001 ─┬─> C-002 ─> C-004
                    │
                    └─> C-003 ─> C-005

Phase 3 (UI)
S-004 + S-005 ─> U-001 ─> U-002 ─> U-003 ─┬─> U-004
                                          └─> U-005
S-005 ────────> U-006 ─> U-007

Phase 4A (Vocab Flash)
U-006 + C-003 ─> G1-001 ─┬─> G1-002 ─┬─> G1-004 ─> G1-006
                         │           │
                         │           └─> G1-005
                         │
                         └─> G1-003

Phase 4B (Phrase Builder)
U-006 + C-003 ─> G2-001 ─┬─> G2-002 ─> G2-003 ─> G2-004
                         │
                         ├─> G2-005
                         │
                         └─> G2-006

Phase 5 (Game Flow)
S-003 + C-001 ─> F-001 ─┬─> F-002 ─> F-003
                        │
                        └─> F-004 ─> F-005

S-006 + F-001 ─> F-006

Phase 6 (Polish)
All UI ────> P-001, P-002, P-003, P-004, P-005
G1-005 + G2-004 ─> P-006
```

---

## Appendix B: Glossary

| Term | Definition |
|------|------------|
| **Hot-seat** | Two players sharing one device, taking turns |
| **Duel** | A complete game session between two players |
| **Round** | One player's turn within a mini-game |
| **Mini-game** | A specific game type (Vocab Flash, Phrase Builder) |
| **Deck** | Collection of vocabulary/phrase items for a topic |
| **A1 Level** | CEFR beginner level (basic phrases, simple interactions) |
| **Turn Transition** | Screen shown when passing device between players |

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-26 | PM Agent | Initial document creation |

---

*This document serves as the single source of truth for Language Duel MVP project management. All agents and developers should reference this document for task assignments, priorities, and definitions of done.*
