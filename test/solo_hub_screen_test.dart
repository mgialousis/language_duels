import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:language_duels/data/models/deck.dart';
import 'package:language_duels/data/models/learner_profile.dart';
import 'package:language_duels/data/models/player.dart';
import 'package:language_duels/data/models/solo_session_summary.dart';
import 'package:language_duels/data/models/srs_item.dart';
import 'package:language_duels/data/models/settings_state.dart';
import 'package:language_duels/data/providers/content_provider.dart';
import 'package:language_duels/data/providers/learner_provider.dart';
import 'package:language_duels/data/providers/settings_provider.dart';
import 'package:language_duels/data/providers/solo_history_provider.dart';
import 'package:language_duels/data/providers/srs_provider.dart';
import 'package:language_duels/data/repositories/interfaces.dart';
import 'package:language_duels/features/solo/solo_hub_screen.dart';

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

class FakeSoloHistoryRepository implements ISoloHistoryRepository {
  FakeSoloHistoryRepository(this.sessions);

  List<SoloSessionSummary> sessions;

  @override
  List<SoloSessionSummary> getAll() => sessions;

  @override
  Future<void> add(SoloSessionSummary session) async {
    sessions = [session, ...sessions];
  }

  @override
  Future<void> clear() async {
    sessions = [];
  }
}

void main() {
  testWidgets('Solo hub renders stats and recent sessions',
      (WidgetTester tester) async {
    final profile = LearnerProfile(
      ownerId: 'test',
      createdAt: DateTime(2026, 1, 1),
      totalReviews: 12,
      currentStreak: 3,
      longestStreak: 5,
      lastPracticeDate: DateTime(2026, 1, 27),
      deckProgress: const {},
    );

    final sessions = [
      SoloSessionSummary(
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
      ),
    ];

    final decks = [
      DeckInfo(
        id: 'greetings',
        name: const LocalizedString(en: 'Greetings'),
        description: const LocalizedString(en: 'Hello words'),
        level: 'A1',
        itemCount: 30,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsStorageProvider
              .overrideWithValue(FakeSettingsRepository(SettingsState.defaults)),
          learnerStorageProvider
              .overrideWithValue(FakeLearnerRepository(profile)),
          vocabDueItemsProvider.overrideWithValue(<SRSItem>[]),
          weakItemsProvider.overrideWithValue(<SRSItem>[]),
          soloHistoryStorageProvider
              .overrideWithValue(FakeSoloHistoryRepository(sessions)),
          deckListProvider.overrideWith((ref) async => decks),
        ],
        child: const MaterialApp(home: SoloHubScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Solo Practice'), findsOneWidget);
    expect(find.text('Recent Sessions'), findsOneWidget);
    expect(find.text('Greetings'), findsOneWidget);
  });
}
