// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:language_duels/data/models/settings_state.dart';
import 'package:language_duels/data/models/srs_item.dart';
import 'package:language_duels/data/providers/game_session_provider.dart';
import 'package:language_duels/data/providers/settings_provider.dart';
import 'package:language_duels/data/providers/srs_provider.dart';
import 'package:language_duels/data/repositories/interfaces.dart';
import 'package:language_duels/features/home/home_screen.dart';

class FakeSettingsRepository implements ISettingsRepository {
  SettingsState _state = SettingsState.defaults;

  @override
  SettingsState load() => _state;

  @override
  Future<void> save(SettingsState state) async {
    _state = state;
  }
}

class FakeSrsController extends SrsController {
  FakeSrsController() : super(FakeSrsRepository());
}

class FakeSrsRepository implements ISrsRepository {
  @override
  Map<String, SRSItem> loadAll() => {};

  @override
  Future<void> saveItem(SRSItem item) async {}

  @override
  Future<void> saveAll(Iterable<SRSItem> items) async {}

  @override
  Future<void> clear() async {}
}

void main() {
  testWidgets('Home screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsStorageProvider.overrideWithValue(FakeSettingsRepository()),
          savedSessionProvider.overrideWith((ref) async => null),
          srsItemsProvider.overrideWith(
            (ref) => FakeSrsController(),
          ),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Start New Duel'), findsOneWidget);
  });
}
