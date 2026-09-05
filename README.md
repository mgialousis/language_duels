# Language Duels

[![Flutter CI](https://github.com/mgialousis/language_duels/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/mgialousis/language_duels/actions/workflows/flutter_ci.yml)

Language Duels turns Greek-Catalan study into a shared, hot-seat game for two people while also supporting focused solo practice. It combines short competitive rounds, bidirectional vocabulary decks, grammar lessons, and local progress tracking in one Flutter application.

The app is designed for a single Android or iOS device. It does not require an account or a network connection: learning content ships with the app and progress stays on the device.

## Highlights

- Two-player hot-seat duels with resumable sessions and match history
- Six game formats: Vocab Flash, Phrase Builder, Speed Round, Match Madness, Spelling Bee, and Listening Challenge
- Solo Timed, Relaxed, and spaced-repetition modes, including mixed minigame sessions
- Greek → Catalan and Catalan → Greek practice directions
- Eight bundled A1-A2 vocabulary and phrase decks
- A1-A2 grammar lessons, exercises, mastery states, and optional IPA guidance
- Progress dashboard, practice streaks, weak-word review, and session history
- Content validation and automated unit/widget tests

## How it works

In a duel, two players share one phone and alternate turns. They choose the content and mini-games, complete their rounds privately, and pass the device at the transition screen. The app scores the match and stores the result locally.

Solo practice uses the same learning content with configurable session length, direction, game type, and time pressure. Review performance feeds a spaced-repetition schedule so due and difficult material can be surfaced again.

## Technical overview

Language Duels is built with Flutter and Dart. Riverpod owns application and game-session state, GoRouter handles navigation, and Hive provides on-device persistence. Decks and grammar lessons are versioned JSON assets loaded through repositories, keeping learning content separate from presentation and game logic.

```text
lib/
├── app/                 # Routing, theme, and application shell
├── data/
│   ├── models/          # Immutable domain models
│   ├── providers/       # Riverpod state and controllers
│   ├── repositories/    # Content and persistence boundaries
│   └── services/        # Migrations and spaced-repetition logic
├── features/            # Feature-oriented screens and flows
└── shared/              # Reusable widgets, animation, and audio services

assets/data/             # Vocabulary decks and grammar lessons
test/                    # Unit and widget tests
scripts/                 # Content validation and local build helpers
```

Important design choices include:

- Repository interfaces isolate content loading and storage from UI code.
- Riverpod providers make game and learning state independently testable.
- Explicit Hive adapters and a migration service preserve local data compatibility.
- Bundled JSON allows language content to evolve without coupling it to widgets.

## Getting started

### Requirements

- Flutter 3.38.8 (stable) or a compatible release with Dart 3.10.4+
- Android Studio/Xcode tooling for the platform you want to run
- An Android emulator/device or iOS simulator/device

### Run locally

```bash
git clone https://github.com/mgialousis/language_duels.git
cd language_duels
flutter pub get
flutter run
```

The committed `pubspec.lock` pins the dependency graph used by this application. Flutter may create platform-specific generated files during setup; these are excluded from version control.

## Quality checks

Run the same checks used by CI:

```bash
dart run scripts/validate_decks.dart
flutter analyze
flutter test
```

The test suite covers game controllers, spelling validation, grammar exercise behavior, spaced-repetition scheduling, progress state, and key solo-practice widgets.

## Content development

Vocabulary decks live in `assets/data/*_deck.json`, while grammar content lives under `assets/data/grammar/`. When adding a deck:

1. Follow the existing deck schema and use a unique deck/item ID.
2. Register the asset in `pubspec.yaml`.
3. Add the deck to `ContentRepository`.
4. Run the content validator and full test suite.

The app's models, repositories, and validated JSON assets are the current source of truth for content behavior. Historical content specifications and additional engineering decisions are retained in [`docs/`](docs/).

## Privacy and data

- No sign-in, analytics SDK, advertising SDK, or cloud backend is used.
- Player names, settings, match history, learner progress, and review schedules are stored locally with Hive.
- Vocabulary and grammar data are bundled application assets.
- The repository does not require API keys, service accounts, or `.env` files to build or run.
- Clearing the app's storage or uninstalling it removes locally saved progress, subject to the platform's backup behavior.

Do not commit signing keys, platform service configuration, or environment files. Relevant secret-bearing file patterns are excluded in `.gitignore`.

## Project documentation

The `docs/` directory records the product and engineering process as well as historical implementation phases. Good entry points are:

- [`docs/game_design.md`](docs/game_design.md) — game rules and interaction model
- [`docs/flutter_engineering.md`](docs/flutter_engineering.md) — Flutter architecture notes
- [`docs/data_storage.md`](docs/data_storage.md) — original persistence design
- [`docs/product_ux.md`](docs/product_ux.md) — product and UX decisions
- [`docs/content_language.md`](docs/content_language.md) — original content specification

## Status

Language Duels is a portfolio project under active development. Android and iOS project files are included; store distribution artifacts are not published from this repository.
