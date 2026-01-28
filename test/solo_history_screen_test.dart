import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:language_duels/data/models/deck.dart';
import 'package:language_duels/data/models/player.dart';
import 'package:language_duels/data/models/solo_session_summary.dart';
import 'package:language_duels/data/models/settings_state.dart';
import 'package:language_duels/data/providers/content_provider.dart';
import 'package:language_duels/data/providers/solo_history_provider.dart';
import 'package:language_duels/data/providers/settings_provider.dart';
import 'package:language_duels/data/repositories/interfaces.dart';
import 'package:language_duels/features/solo/solo_history_screen.dart';

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
  testWidgets('Solo history lists sessions', (WidgetTester tester) async {
    final sessions = [
      SoloSessionSummary(
        id: 's1',
        deckId: 'greetings',
        mode: SoloMode.timed,
        gameType: SoloGameType.vocabFlash,
        timerEnabled: true,
        direction: LanguageDirection.greekToCatalan,
        startedAt: DateTime(2026, 1, 27, 9, 30),
        durationSeconds: 90,
        totalQuestions: 10,
        correctCount: 7,
        score: 70,
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
          soloHistoryStorageProvider
              .overrideWithValue(FakeSoloHistoryRepository(sessions)),
          deckListProvider.overrideWith((ref) async => decks),
        ],
        child: const MaterialApp(home: SoloHistoryScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Practice History'), findsOneWidget);
    expect(find.text('Greetings'), findsOneWidget);
    expect(find.textContaining('Score'), findsOneWidget);
  });
}
