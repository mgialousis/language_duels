import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../data/models/solo_session_summary.dart';
import '../../data/providers/content_provider.dart';
import '../../data/providers/learner_provider.dart';
import '../../data/providers/solo_history_provider.dart';
import '../../data/providers/srs_provider.dart';
import '../../shared/widgets/duel_button.dart';
import '../../shared/widgets/async_state.dart';

class SoloHubScreen extends ConsumerWidget {
  const SoloHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(learnerProfileProvider);
    final dueItems = ref.watch(allDueItemsProvider);
    final weakItems = ref.watch(weakItemsProvider);
    final history = ref.watch(soloHistoryProvider);
    final decksAsync = ref.watch(deckListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solo Practice'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(homeRoute),
        ),
      ),
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const LoadingState(message: 'Loading profile...'),
          error: (e, _) => ErrorState(
            title: 'Profile unavailable',
            message: 'Please try again.',
            onRetry: () => ref.invalidate(learnerProfileProvider),
          ),
          data: (profile) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Stats Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        icon: Icons.local_fire_department,
                        value: '${profile.currentStreak}',
                        label: 'day streak',
                      ),
                      _StatItem(
                        icon: Icons.school,
                        value: '${profile.overallMastery.toStringAsFixed(0)}%',
                        label: 'mastery',
                      ),
                      _StatItem(
                        icon: Icons.auto_graph,
                        value: '${profile.overallLearning.toStringAsFixed(0)}%',
                        label: 'learning',
                      ),
                      _StatItem(
                        icon: Icons.check_circle,
                        value: '${profile.totalReviews}',
                        label: 'reviews',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Review Card
                _ActionCard(
                  icon: Icons.bolt,
                  title: 'Quick Review',
                  subtitle: dueItems.isEmpty
                      ? 'Fast mixed session across recent items'
                      : '${dueItems.length} items due today · fast mixed review',
                  buttonLabel: 'Start Review',
                  onPressed: dueItems.isEmpty
                      ? null
                      : () => context.push(
                            soloSetupRoute,
                            extra: {'mode': 'srsReview'},
                          ),
                ),
                const SizedBox(height: 16),

                // Practice Deck Card
                _ActionCard(
                  icon: Icons.library_books,
                  title: 'Practice a Deck',
                  subtitle: 'Focus on one deck with full control',
                  buttonLabel: 'Choose Deck',
                  onPressed: () => context.push(soloSetupRoute),
                ),
                const SizedBox(height: 16),

                // Weak Words Card (only show if 5+ weak items)
                if (weakItems.length >= 5)
                  _ActionCard(
                    icon: Icons.warning_amber,
                    title: 'Weak Words',
                    subtitle: '${weakItems.length} words need extra practice',
                    buttonLabel: 'Review Weak Words',
                    onPressed: () => context.push(weakWordsRoute),
                  ),
                if (history.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Sessions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push(soloHistoryRoute),
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  decksAsync.when(
                    loading: () => const LoadingState(
                      message: 'Loading sessions...',
                    ),
                    error: (error, stackTrace) => _RecentSessionsList(
                      sessions: history,
                      deckNames: const {},
                    ),
                    data: (decks) {
                      final deckNames = {
                        for (final deck in decks) deck.id: deck.name.defaultText,
                      };
                      return _RecentSessionsList(
                        sessions: history,
                        deckNames: deckNames,
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentSessionsList extends StatelessWidget {
  const _RecentSessionsList({
    required this.sessions,
    required this.deckNames,
  });

  final List<SoloSessionSummary> sessions;
  final Map<String, String> deckNames;

  @override
  Widget build(BuildContext context) {
    final sorted = [...sessions]
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    final recent = sorted.take(3).toList();

    return Column(
      children: [
        for (final session in recent)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: ListTile(
                title: Text(deckNames[session.deckId] ?? session.deckId),
                subtitle: Text(
                  '${_labelGame(session)} • ${_labelMode(session)} • ${_formatTime(session.startedAt)}',
                ),
                trailing: Text('${session.score} pts'),
              ),
            ),
          ),
      ],
    );
  }

  String _labelGame(SoloSessionSummary session) {
    return switch (session.gameType) {
      SoloGameType.vocabFlash => 'Vocab Flash',
      SoloGameType.phraseBuilder => 'Phrase Builder',
      SoloGameType.mixed => 'Mixed',
      SoloGameType.speedRound => 'Speed Round',
      SoloGameType.matchMadness => 'Match Madness',
      SoloGameType.spellingBee => 'Spelling Bee',
      SoloGameType.listening => 'Listening',
    };
  }

  String _labelMode(SoloSessionSummary session) {
    return switch (session.mode) {
      SoloMode.timed => 'Timed',
      SoloMode.relaxed => 'Relaxed',
      SoloMode.srsReview => 'SRS Review',
    };
  }

  String _formatTime(DateTime date) {
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: DuelButton(
                label: buttonLabel,
                onPressed: onPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
