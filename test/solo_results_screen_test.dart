import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:language_duels/data/models/learner_profile.dart';
import 'package:language_duels/data/models/player.dart';
import 'package:language_duels/data/models/solo_session_summary.dart';
import 'package:language_duels/data/models/settings_state.dart';
import 'package:language_duels/data/providers/learner_provider.dart';
import 'package:language_duels/data/providers/settings_provider.dart';
import 'package:language_duels/data/repositories/interfaces.dart';
import 'package:language_duels/features/solo/solo_results_screen.dart';

class FakeSettingsRepository implements ISettingsRepository {
  FakeSettingsRepository(this.state);

  SettingsState state;

  @override
  SettingsState load() => state;

  @override
  Future<void> save(SettingsState state) async {
    this.state = state;
  }
}

class FakeLearnerRepository implements ILearnerRepository {
  FakeLearnerRepository(this.profile);

  LearnerProfile? profile;

  @override
  LearnerProfile? load() => profile;

  @override
  Future<void> save(LearnerProfile profile) async {
    this.profile = profile;
  }

  @override
  bool hasProfile() => profile != null;

  @override
  Future<void> clear() async {
    profile = null;
  }
}

void main() {
  testWidgets('Solo results shows summary data', (WidgetTester tester) async {
    final summary = SoloSessionSummary(
      id: 's1',
      deckId: 'greetings',
      mode: SoloMode.timed,
      gameType: SoloGameType.vocabFlash,
      timerEnabled: true,
      direction: LanguageDirection.greekToCatalan,
      startedAt: DateTime(2026, 1, 27, 10, 0),
      durationSeconds: 120,
      totalQuestions: 10,
      correctCount: 8,
      score: 80,
    );

    final profile = LearnerProfile(
      ownerId: 'test',
      createdAt: DateTime(2026, 1, 1),
      totalReviews: 20,
      currentStreak: 4,
      longestStreak: 5,
      lastPracticeDate: DateTime(2026, 1, 27),
      deckProgress: const {},
    );

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/results',
          builder: (context, state) => const SoloResultsScreen(),
        ),
      ],
      initialLocation: '/results',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsStorageProvider
              .overrideWithValue(FakeSettingsRepository(SettingsState.defaults)),
          learnerStorageProvider
              .overrideWithValue(FakeLearnerRepository(profile)),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    router.go('/results', extra: summary);
    await tester.pumpAndSettle();

    expect(find.text('Practice Complete'), findsOneWidget);
    expect(find.textContaining('Score'), findsOneWidget);
    expect(find.textContaining('Accuracy'), findsOneWidget);
  });
}
