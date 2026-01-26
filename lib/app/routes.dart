import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_screen.dart';
import '../features/setup/player_setup_screen.dart';
import '../features/setup/deck_select_screen.dart';
import '../features/duel/duel_hub_screen.dart';
import '../features/games/vocab_flash/vocab_flash_screen.dart';
import '../features/games/phrase_builder/phrase_builder_screen.dart';
import '../features/duel/turn_transition_screen.dart';
import '../features/results/results_screen.dart';
import '../features/history/history_screen.dart';
import '../features/settings/settings_screen.dart';
import '../shared/widgets/async_state.dart';

const String homeRoute = '/';
const String setupRoute = '/setup';
const String deckRoute = '/deck';
const String duelRoute = '/duel';
const String vocabRoute = '/vocab';
const String phraseRoute = '/phrase';
const String transitionRoute = '/transition';
const String resultsRoute = '/results';
const String historyRoute = '/history';
const String settingsRoute = '/settings';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: homeRoute,
    routes: <RouteBase>[
      GoRoute(path: homeRoute, builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: setupRoute,
        builder: (context, state) => const PlayerSetupScreen(),
      ),
      GoRoute(
        path: deckRoute,
        builder: (context, state) => const DeckSelectScreen(),
      ),
      GoRoute(
        path: duelRoute,
        builder: (context, state) => const DuelHubScreen(),
      ),
      GoRoute(
        path: vocabRoute,
        builder: (context, state) => const VocabFlashScreen(),
      ),
      GoRoute(
        path: phraseRoute,
        builder: (context, state) => const PhraseBuilderScreen(),
      ),
      GoRoute(
        path: transitionRoute,
        builder: (context, state) => const TurnTransitionScreen(),
      ),
      GoRoute(
        path: resultsRoute,
        builder: (context, state) => const ResultsScreen(),
      ),
      GoRoute(
        path: historyRoute,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: settingsRoute,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Navigation Error')),
      body: ErrorState(
        title: 'Page not available',
        message: 'Return to the home screen and try again.',
        actionLabel: 'Go home',
        onRetry: () => context.go(homeRoute),
      ),
    ),
  );
});
