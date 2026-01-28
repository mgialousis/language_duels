import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_screen.dart';
import '../features/setup/player_setup_screen.dart';
import '../features/setup/deck_select_screen.dart';
import '../features/duel/duel_hub_screen.dart';
import '../features/games/vocab_flash/vocab_flash_screen.dart';
import '../features/games/phrase_builder/phrase_builder_screen.dart';
import '../features/games/speed_round/speed_round_screen.dart';
import '../features/games/match_madness/match_madness_screen.dart';
import '../features/games/spelling_bee/spelling_bee_screen.dart';
import '../features/games/listening/listening_screen.dart';
import '../features/duel/turn_transition_screen.dart';
import '../features/results/results_screen.dart';
import '../features/history/history_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/how_to_play/how_to_play_screen.dart';
import '../features/grammar/grammar_hub_screen.dart';
import '../features/grammar/lesson_list_screen.dart';
import '../features/grammar/lesson_view_screen.dart';
import '../features/grammar/exercise_screen.dart';
import '../features/grammar/exercise_results_screen.dart';
import '../features/solo/solo_hub_screen.dart';
import '../features/solo/solo_setup_screen.dart';
import '../features/solo/solo_practice_screen.dart';
import '../features/solo/solo_results_screen.dart';
import '../features/solo/solo_history_screen.dart';
import '../features/progress/progress_dashboard_screen.dart';
import '../features/weak_words/weak_words_screen.dart';
import '../shared/widgets/async_state.dart';

const String homeRoute = '/';
const String setupRoute = '/setup';
const String deckRoute = '/deck';
const String duelRoute = '/duel';
const String vocabRoute = '/vocab';
const String phraseRoute = '/phrase';
const String speedRoundRoute = '/speed-round';
const String matchMadnessRoute = '/match-madness';
const String spellingBeeRoute = '/spelling-bee';
const String listeningRoute = '/listening';
const String transitionRoute = '/transition';
const String resultsRoute = '/results';
const String historyRoute = '/history';
const String settingsRoute = '/settings';
const String howToPlayRoute = '/how-to-play';
const String grammarRoute = '/grammar';
const String grammarLevelRoute = '/grammar/:level';
const String grammarLessonRoute = '/grammar/lesson/:id';
const String grammarExerciseRoute = '/grammar/exercises';
const String grammarExerciseResultsRoute = '/grammar/exercises/results';
const String soloRoute = '/solo';
const String soloSetupRoute = '/solo/setup';
const String soloPracticeRoute = '/solo/practice';
const String soloResultsRoute = '/solo/results';
const String soloHistoryRoute = '/solo/history';
const String progressRoute = '/progress';
const String weakWordsRoute = '/weak';

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
        path: speedRoundRoute,
        builder: (context, state) => const SpeedRoundScreen(),
      ),
      GoRoute(
        path: matchMadnessRoute,
        builder: (context, state) => const MatchMadnessScreen(),
      ),
      GoRoute(
        path: spellingBeeRoute,
        builder: (context, state) => const SpellingBeeScreen(),
      ),
      GoRoute(
        path: listeningRoute,
        builder: (context, state) => const ListeningChallengeScreen(),
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
      GoRoute(
        path: howToPlayRoute,
        builder: (context, state) => const HowToPlayScreen(),
      ),
      GoRoute(
        path: grammarRoute,
        builder: (context, state) => const GrammarHubScreen(),
      ),
      GoRoute(
        path: grammarLessonRoute,
        builder: (context, state) {
          final lessonId = state.pathParameters['id'] ?? '';
          return LessonViewScreen(lessonId: lessonId);
        },
      ),
      GoRoute(
        path: grammarExerciseRoute,
        builder: (context, state) {
          final lessonId = state.extra as String? ?? '';
          return GrammarExerciseScreen(lessonId: lessonId);
        },
      ),
      GoRoute(
        path: grammarExerciseResultsRoute,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? const {};
          final score = data['score'] as int? ?? 0;
          final total = data['total'] as int? ?? 0;
          final lessonId = data['lessonId'] as String? ?? '';
          return GrammarExerciseResultsScreen(
            score: score,
            total: total,
            lessonId: lessonId,
          );
        },
      ),
      GoRoute(
        path: grammarLevelRoute,
        builder: (context, state) {
          final level = state.pathParameters['level'] ?? 'A1';
          return LessonListScreen(level: level);
        },
      ),
      GoRoute(
        path: soloRoute,
        builder: (context, state) => const SoloHubScreen(),
      ),
      GoRoute(
        path: soloSetupRoute,
        builder: (context, state) => const SoloSetupScreen(),
      ),
      GoRoute(
        path: soloPracticeRoute,
        builder: (context, state) => const SoloPracticeScreen(),
      ),
      GoRoute(
        path: soloResultsRoute,
        builder: (context, state) => const SoloResultsScreen(),
      ),
      GoRoute(
        path: soloHistoryRoute,
        builder: (context, state) => const SoloHistoryScreen(),
      ),
      GoRoute(
        path: progressRoute,
        builder: (context, state) => const ProgressDashboardScreen(),
      ),
      GoRoute(
        path: weakWordsRoute,
        builder: (context, state) => const WeakWordsScreen(),
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
