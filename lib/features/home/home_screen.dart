import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../data/providers/game_session_provider.dart';
import '../../data/providers/srs_provider.dart';
import '../../shared/widgets/duel_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedSessionAsync = ref.watch(savedSessionProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Language Duel'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: scheme.outlineVariant,
                      ),
                    ),
                    child: Row(
                      children: [
                        Semantics(
                          label: 'Language Duel logo',
                          image: true,
                          child: Image.asset(
                            'assets/icons/app_icon.png',
                            width: 56,
                            height: 56,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'LANGUAGE DUEL',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Greek ↔ Catalan • A1',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  savedSessionAsync.when(
                    data: (session) {
                      if (session == null) return const SizedBox.shrink();
                      final resumeRoute = _resumeRoute(session);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 52,
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
                          const SizedBox(height: 12),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (error, stack) => const SizedBox.shrink(),
                  ),
                  SizedBox(
                    height: 52,
                    child: DuelButton(
                      label: 'Start New Duel',
                      onPressed: () => context.push(setupRoute),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Consumer(
                    builder: (context, ref, _) {
                      final dueItems = ref.watch(allDueItemsProvider);
                      return _SecondaryActionCard(
                        title: 'Solo Practice',
                        subtitle: 'Focus on today’s spaced repetition.',
                        icon: Icons.school_outlined,
                        badgeText: dueItems.isNotEmpty
                            ? '${dueItems.length} due'
                            : null,
                        onTap: () => context.push(soloRoute),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _SecondaryActionCard(
                    title: 'My Progress',
                    subtitle: 'Track streaks and mastery.',
                    icon: Icons.insights_outlined,
                    onTap: () => context.push(progressRoute),
                  ),
                  const SizedBox(height: 10),
                  _SecondaryActionCard(
                    title: 'Grammar & Theory',
                    subtitle: 'Lessons, tables, and examples.',
                    icon: Icons.menu_book_outlined,
                    onTap: () => context.push(grammarRoute),
                  ),
                  const SizedBox(height: 10),
                  _SecondaryActionCard(
                    title: 'Match History',
                    subtitle: 'Review recent duels.',
                    icon: Icons.history,
                    onTap: () => context.push(historyRoute),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      TextButton.icon(
                        onPressed: () => context.push(settingsRoute),
                        icon: const Icon(Icons.settings_outlined, size: 18),
                        label: const Text('Settings'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => context.push(howToPlayRoute),
                        icon: const Icon(Icons.help_outline, size: 18),
                        label: const Text('How to Play'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
    switch (session.currentGame) {
      case GameType.vocab:
        return session.vocabComplete ? duelRoute : vocabRoute;
      case GameType.phrase:
        return session.phraseComplete ? duelRoute : phraseRoute;
      case GameType.speedRound:
        return session.speedRoundComplete ? duelRoute : speedRoundRoute;
      case GameType.matchMadness:
        return session.matchMadnessComplete ? duelRoute : matchMadnessRoute;
      case GameType.spellingBee:
        return session.spellingBeeComplete ? duelRoute : spellingBeeRoute;
      case GameType.listening:
        return session.listeningComplete ? duelRoute : listeningRoute;
    }
  }
}

class _SecondaryActionCard extends StatelessWidget {
  const _SecondaryActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.badgeText,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final String? badgeText;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (badgeText != null) _CountBadge(text: badgeText!),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
