# Language Duels

Hot-seat language duel game (Greek ↔ Catalan) with solo practice and spaced repetition. Built with Flutter + Riverpod + Hive.

## Features
- Duel mode with Vocab Flash + Phrase Builder mini-games
- Solo practice (Timed, Relaxed, SRS Review) + Mixed mode
- Grammar & Theory module with lessons + exercises (A1–A2)
- IPA toggle for grammar lesson tables/examples
- Progress dashboard, weak words review, and practice history
- Grammar lessons feed SRS with due-review surfaced in Grammar Hub
- Local deck content stored in `assets/data`

## Run
```bash
flutter pub get
flutter run
```

## Tests
```bash
flutter test
```

## Content Decks
- Deck JSON lives in `assets/data/*.json`
- Add new decks and update `pubspec.yaml` assets + `ContentRepository` deck map
- Run validation: `dart run scripts/validate_decks.dart`

## Solo + Grammar Data
- Solo data uses Hive boxes: `learner_profile`, `srs_items`, `solo_history`
- Grammar progress uses `grammar_progress` and feeds SRS as `grammar:<lessonId>`
- Settings provides “Clear deck cache” and “Reset solo progress”

## Project Structure
- `lib/features` screens and flows
- `lib/data` models, repositories, providers, services
- `lib/shared` reusable widgets and animations
