import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../data/providers/game_session_provider.dart';
import '../../data/providers/history_provider.dart';
import '../../shared/widgets/duel_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedSessionAsync = ref.watch(savedSessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Language Duel'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Column(
                      children: [
                      Semantics(
                        label: 'Language Duel logo',
                        image: true,
                        child: Image.asset(
                          'assets/icons/app_icon.png',
                          width: 112,
                          height: 112,
                        ),
                      ),
                        const SizedBox(height: 14),
                        const Text(
                          'LANGUAGE DUEL',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Greek ↔ Catalan • A1',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  savedSessionAsync.when(
                    data: (session) {
                      if (session == null) return const SizedBox.shrink();
                      final resumeRoute = _resumeRoute(session);
                      return Column(
                        children: [
                          Center(
                            child: SizedBox(
                              width: 260,
                              height: 48,
                              child: DuelButton(
                                label: 'Resume Duel',
                                onPressed: () {
                                  ref
                                      .read(gameSessionProvider.notifier)
                                      .restoreSession(session);
                                  context.go(resumeRoute);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (error, stack) => const SizedBox.shrink(),
                  ),
                  Center(
                    child: SizedBox(
                      width: 260,
                      height: 48,
                      child: DuelButton(
                        label: 'Start New Duel',
                        onPressed: () => context.push(setupRoute),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: SizedBox(
                      width: 260,
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => context.push(historyRoute),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Match History'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: SizedBox(
                      width: 260,
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => context.push(settingsRoute),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Settings'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: SizedBox(
                      width: 260,
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () {
                          showDialog<void>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('How to Play'),
                              content: const Text(
                                'Take turns on one phone. Answer vocab questions fast '
                                'and reorder phrase tiles. Highest score wins.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    ref.read(historyProvider.notifier).clear();
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Clear History'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Got it'),
                                ),
                              ],
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('How to Play'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Center(
                    child: Text(
                      'v1.0.0 MVP',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _resumeRoute(GameSessionState session) {
    if (session.currentGame == GameType.vocab && !session.vocabComplete) {
      return vocabRoute;
    }
    if (session.currentGame == GameType.phrase && !session.phraseComplete) {
      return phraseRoute;
    }
    return duelRoute;
  }
}
