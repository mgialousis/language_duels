# Repository Guidelines

## MVP Implementation Checklist

Use this file to track which doc-specified items are implemented. Checked items are done; unchecked items are pending. Keep this list up to date as work progresses.

### Product UX (`docs/product_ux.md`)
- [x] Core screens exist: Home, Player Setup, Deck Select, Duel Hub, Vocab Flash, Phrase Builder, Turn Transition, Results
- [x] Turn Transition screen present (privacy cover)
- [x] Timer warning state + pulse (TimerBar)
- [x] Back navigation on setup/deck
- [x] Settings: toggle to disable timers/speed bonuses
- [x] Home screen spec details (logo layout, version footer, exact CTA layout)
- [x] Player Setup: 20‑char limit, per‑field validation on blur, disabled Continue until valid
- [x] Player Setup styling (player cards + language dropdowns)
- [x] Deck Select spec (locked decks + icons + “coming soon” visuals)
- [x] Turn Transition: player‑color background, animated handoff icon, ready countdown
- [x] Turn Transition: fade in/out sequence
- [x] Results spec (winner/tie visuals + mini‑game breakdown)
- [x] Accessibility semantics + reduce‑motion behavior (score/timer + option labels)
- [x] Pause/resume overlay on backgrounding

### Game Design (`docs/game_design.md`)
- [x] Vocab Flash round size (5 per player), timer 10s, speed bonus logic
- [x] Phrase Builder round size (3 per player), timer 30s, partial scoring + time bonus
- [x] Turn order swap for game 2 (P2 starts phrase builder)
- [x] Tie handled (results text)
- [x] No duplicate options (dedupe by target text)
- [x] Distractor algorithm per spec (semantic siblings, confusion pairs, difficulty/length matching)
- [x] Always show correct answer, even when correct
- [x] Encouragement messages
- [x] 3‑second countdown after “I’m Ready”
- [x] Hint system (optional)

### Flutter Engineering (`docs/flutter_engineering.md`)
- [x] Folder structure largely matches spec
- [x] go_router navigation configured
- [x] Shared widgets: ScoreBoard, TimerBar, DuelButton, AnswerFeedback
- [x] Dedicated widget components (FlashCard, OptionTile, WordTile, SubmitBar)
- [x] Reusable animations module (`shared/animations`)
- [x] Controllers driving game state (screens use controller state for feedback/flags)
- [x] Portrait lock & safe‑area polish

### Content & Language (`docs/content_language.md`)
- [x] Multiple decks exist (greetings + 3 new)
- [x] Bidirectional text present in items
- [x] Decks match schema (deck metadata, wordBreakdown, formality, tags)
- [x] Schema validation or checklist tooling
- [x] Consistent phonetic/romanization across entries

### Data Storage (`docs/data_storage.md`)
- [x] Hive boxes for session/history/settings; persisted settings + match history
- [x] Typed Hive adapters / model annotations per spec
- [x] Equatable/json_serializable model pattern
- [x] Repo interfaces as specified
- [x] Content caching layer

### Project Management (`docs/project_management.md`)
- [x] Core MVP flow functional end‑to‑end
- [x] Testing checklist coverage (unit/widget/integration)
- [x] Loading/error UX polish
- [x] Accessibility checklist completion
- [x] Performance polish
- [x] Sound hooks wired (setting exists only)
