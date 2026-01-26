# Repository Guidelines

## Project Structure & Module Organization
- `lib/` contains all Dart source code for the Flutter app (widgets, screens, services).
- `test/` holds unit/widget tests using Flutter's test tooling.
- `assets/` stores static assets (images, fonts, etc.); register new assets in `pubspec.yaml`.
- `android/` and `ios/` contain platform-specific build configurations.
- `docs/` is available for longer-form documentation or design notes.

## Build, Test, and Development Commands
- `flutter pub get` installs dependencies defined in `pubspec.yaml`.
- `flutter run` launches the app on a connected device or simulator.
- `flutter test` runs the test suite in `test/`.
- `flutter analyze` runs the Dart analyzer with `flutter_lints` enabled.
- `dart format .` auto-formats all Dart code in the repository.

## Coding Style & Naming Conventions
- Indentation: 2 spaces (Dart standard).
- Formatting: run `dart format .` before committing.
- Files: use `snake_case.dart` (e.g., `game_screen.dart`).
- Types/classes: `UpperCamelCase` (e.g., `GameScreen`).
- Variables/functions: `lowerCamelCase` (e.g., `startMatch()`).

## Testing Guidelines
- Framework: `flutter_test` (see `dev_dependencies` in `pubspec.yaml`).
- Place tests under `test/` and name files to match the unit (e.g., `game_screen_test.dart`).
- Run focused tests with `flutter test test/path/to/file_test.dart`.

## Commit & Pull Request Guidelines
- Commit history is minimal; the only existing message is "Initial commit".
- Until conventions are established, use clear, imperative messages (e.g., "Add matchmaking screen").
- PRs should include a concise summary, testing notes, and screenshots for UI changes.
