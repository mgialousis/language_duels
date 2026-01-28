import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/progress_provider.dart';
import '../../data/providers/srs_provider.dart';
import '../../data/providers/learner_provider.dart';
import '../../data/providers/content_provider.dart';
import '../../data/models/deck_progress.dart';
import 'deck_progress_card.dart';
import '../../shared/widgets/async_state.dart';

class ProgressDashboardScreen extends ConsumerWidget {
  const ProgressDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(learnerProfileProvider);
    final deckProgressAsync = ref.watch(deckProgressListProvider);
    final dueItems = ref.watch(allDueItemsProvider);
    final weakItems = ref.watch(weakItemsProvider);
    final decksAsync = ref.watch(deckListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Progress'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const LoadingState(message: 'Loading profile...'),
          error: (e, _) => ErrorState(
            title: 'Progress unavailable',
            message: 'Please try again.',
            onRetry: () => ref.invalidate(learnerProfileProvider),
          ),
          data: (profile) => deckProgressAsync.when(
            loading: () => const LoadingState(message: 'Loading progress...'),
            error: (e, _) => ErrorState(
              title: 'Progress unavailable',
              message: 'Please try again.',
              onRetry: () => ref.invalidate(deckProgressListProvider),
            ),
            data: (progressList) {
              final totals = _calculateTotals(progressList);
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _OverviewCard(
                    mastery: totals.masteryPercent,
                    learning: totals.learningPercent,
                    currentStreak: profile.currentStreak,
                    totalReviews: profile.totalReviews,
                    accuracy: totals.accuracyPercent,
                    dueCount: dueItems.length,
                    weakCount: weakItems.length,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Deck Progress',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  if (progressList.isEmpty)
                    const Text('No progress yet. Complete a solo session.'),
                  if (progressList.isNotEmpty)
                    decksAsync.when(
                      loading: () => Column(
                        children: progressList
                            .map(
                              (progress) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: DeckProgressCard(
                                  title: progress.deckId,
                                  progress: progress,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      error: (e, _) => ErrorState(
                        title: 'Decks unavailable',
                        message: 'Please try again.',
                        onRetry: () => ref.refresh(deckListProvider),
                      ),
                      data: (decks) {
                        final deckName = {
                          for (final deck in decks) deck.id: deck.name.defaultText,
                        };
                        return Column(
                          children: progressList
                              .map(
                                (progress) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: DeckProgressCard(
                                    title:
                                        deckName[progress.deckId] ?? progress.deckId,
                                    progress: progress,
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  _Totals _calculateTotals(List<DeckProgress> progressList) {
    if (progressList.isEmpty) {
      return const _Totals();
    }
    int mastered = 0;
    int seen = 0;
    int total = 0;
    int correct = 0;
    int attempts = 0;
    for (final progress in progressList) {
      mastered += progress.itemsMastered;
      seen += progress.itemsSeen;
      total += progress.totalItems;
      correct += progress.correctCount;
      attempts += progress.totalAttempts;
    }
    final mastery = total > 0 ? (mastered / total) * 100 : 0.0;
    final learning = total > 0 ? (seen / total) * 100 : 0.0;
    final accuracy = attempts > 0 ? (correct / attempts) * 100 : 0.0;
    return _Totals(
      masteryPercent: mastery,
      learningPercent: learning,
      accuracyPercent: accuracy,
    );
  }
}

class _Totals {
  final double masteryPercent;
  final double learningPercent;
  final double accuracyPercent;

  const _Totals({
    this.masteryPercent = 0.0,
    this.learningPercent = 0.0,
    this.accuracyPercent = 0.0,
  });
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.mastery,
    required this.learning,
    required this.currentStreak,
    required this.totalReviews,
    required this.accuracy,
    required this.dueCount,
    required this.weakCount,
  });

  final double mastery;
  final double learning;
  final int currentStreak;
  final int totalReviews;
  final double accuracy;
  final int dueCount;
  final int weakCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.insights),
                const SizedBox(width: 8),
                const Text(
                  'Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Text('${mastery.toStringAsFixed(0)}% mastery'),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: mastery / 100),
                duration: const Duration(milliseconds: 600),
                builder: (context, value, _) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 10,
                    backgroundColor: scheme.surfaceContainerHighest,
                    color: scheme.primary,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 10,
              children: [
                _StatPill(
                  icon: Icons.local_fire_department,
                  label: 'Streak',
                  value: '$currentStreak days',
                ),
                _StatPill(
                  icon: Icons.check_circle,
                  label: 'Accuracy',
                  value: '${accuracy.toStringAsFixed(0)}%',
                ),
                _StatPill(
                  icon: Icons.auto_graph,
                  label: 'Learning',
                  value: '${learning.toStringAsFixed(0)}%',
                ),
                _StatPill(
                  icon: Icons.history,
                  label: 'Reviews',
                  value: '$totalReviews',
                ),
                _StatPill(
                  icon: Icons.notifications_active,
                  label: 'Due',
                  value: '$dueCount',
                ),
                _StatPill(
                  icon: Icons.warning_amber,
                  label: 'Weak',
                  value: '$weakCount',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11)),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
