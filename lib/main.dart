import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'data/hive_adapters.dart';
import 'data/repositories/content_repository.dart';
import 'data/repositories/learner_storage.dart';
import 'data/repositories/srs_storage.dart';
import 'data/services/migration_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(SettingsStateAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(MatchRecordAdapter());
  }
  if (!Hive.isAdapterRegistered(20)) {
    Hive.registerAdapter(DeckProgressAdapter());
  }
  if (!Hive.isAdapterRegistered(21)) {
    Hive.registerAdapter(LearnerProfileAdapter());
  }
  if (!Hive.isAdapterRegistered(22)) {
    Hive.registerAdapter(SrsStateAdapter());
  }
  if (!Hive.isAdapterRegistered(23)) {
    Hive.registerAdapter(SrsItemAdapter());
  }
  if (!Hive.isAdapterRegistered(24)) {
    Hive.registerAdapter(SoloModeAdapter());
  }
  if (!Hive.isAdapterRegistered(25)) {
    Hive.registerAdapter(SoloGameTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(26)) {
    Hive.registerAdapter(SoloSessionSummaryAdapter());
  }
  if (!Hive.isAdapterRegistered(27)) {
    Hive.registerAdapter(GrammarProgressAdapter());
  }
  await Hive.openBox<dynamic>('session');
  await Hive.openBox<dynamic>('settings');
  await Hive.openBox<dynamic>('history');
  await Hive.openBox<dynamic>('learner_profile');
  await Hive.openBox<dynamic>('srs_items');
  await Hive.openBox<dynamic>('solo_history');
  await Hive.openBox<dynamic>('grammar_progress');
  await MigrationService(
    learnerStorage: LearnerStorage(),
    srsStorage: SrsStorage(),
    contentRepository: ContentRepository(),
  ).migrateToV2();
  runApp(const ProviderScope(child: App()));
}
