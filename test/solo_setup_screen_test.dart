import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:language_duels/data/models/deck.dart';
import 'package:language_duels/data/models/settings_state.dart';
import 'package:language_duels/data/providers/content_provider.dart';
import 'package:language_duels/data/providers/settings_provider.dart';
import 'package:language_duels/data/repositories/interfaces.dart';
import 'package:language_duels/features/solo/solo_setup_screen.dart';

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

void main() {
  testWidgets('Solo setup shows deck dropdown', (WidgetTester tester) async {
    final decks = [
      DeckInfo(
        id: 'greetings',
        name: const LocalizedString(en: 'Greetings'),
        description: const LocalizedString(en: 'Hello words'),
        level: 'A1',
        itemCount: 30,
      ),
      DeckInfo(
        id: 'colors',
        name: const LocalizedString(en: 'Colors'),
        description: const LocalizedString(en: 'Colors deck'),
        level: 'A1',
        itemCount: 16,
      ),
    ];

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SoloSetupScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsStorageProvider
              .overrideWithValue(FakeSettingsRepository(SettingsState.defaults)),
          deckListProvider.overrideWith((ref) async => decks),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Practice Setup'), findsOneWidget);
    expect(find.text('Greetings'), findsOneWidget);
  });
}
