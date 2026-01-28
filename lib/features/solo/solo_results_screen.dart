import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../data/models/solo_session_summary.dart';
import '../../data/providers/learner_provider.dart';
import '../../shared/widgets/duel_button.dart';

class SoloResultsScreen extends ConsumerWidget {
  const SoloResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final extra = GoRouterState.of(context).extra;
    final summary = extra is SoloSessionSummary ? extra : null;

    if (summary == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Results')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No session data available'),
              const SizedBox(height: 16),
              DuelButton(
                label: 'Go Home',
                onPressed: () => context.go(homeRoute),
              ),
            ],
          ),
        ),
      );
    }

    final profileAsync = ref.watch(learnerProfileProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go(soloRoute);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Practice Complete'),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Trophy icon and title
                Center(
                  child: Column(
                    children: [
                      _buildResultIcon(summary.accuracy),
                      const SizedBox(height: 16),
                      Text(
                        _getResultTitle(summary.accuracy),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Main stats card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _StatRow(
                          icon: Icons.star,
                          label: 'Score',
                          value: '${summary.score} points',
                        ),
                        const Divider(height: 24),
                        _StatRow(
                          icon: Icons.check_circle,
                          label: 'Accuracy',
                          value:
                              '${summary.correctCount}/${summary.totalQuestions} (${(summary.accuracy * 100).toStringAsFixed(0)}%)',
                        ),
                        const Divider(height: 24),
                        _StatRow(
                          icon: Icons.timer,
                          label: 'Time',
                          value: _formatDuration(summary.durationSeconds),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Progress update card
                profileAsync.when(
                  data: (profile) => Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Progress Update',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(
                                Icons.local_fire_department,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${profile.currentStreak} day streak',
                                style: const TextStyle(fontSize: 16),
                              ),
                              if (profile.currentStreak > 1)
                                const Text(
                                  ' - Keep it up!',
                                  style: TextStyle(color: Colors.grey),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.school, color: Colors.blue),
                              const SizedBox(width: 12),
                              Text(
                                '${profile.totalReviews} total reviews',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.trending_up, color: Colors.green),
                              const SizedBox(width: 12),
                              Text(
                                '${profile.overallMastery.toStringAsFixed(0)}% overall mastery',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 32),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.go(soloRoute),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Solo Hub'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DuelButton(
                        label: 'Practice Again',
                        onPressed: () => context.go(soloSetupRoute),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => context.go(homeRoute),
                    child: const Text('Back to Home'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultIcon(double accuracy) {
    if (accuracy >= 0.9) {
      return const Icon(Icons.emoji_events, size: 72, color: Colors.amber);
    } else if (accuracy >= 0.7) {
      return const Icon(Icons.star, size: 72, color: Colors.blue);
    } else if (accuracy >= 0.5) {
      return const Icon(Icons.thumb_up, size: 72, color: Colors.green);
    } else {
      return const Icon(Icons.trending_up, size: 72, color: Colors.orange);
    }
  }

  String _getResultTitle(double accuracy) {
    if (accuracy >= 0.9) return 'Excellent!';
    if (accuracy >= 0.7) return 'Great Job!';
    if (accuracy >= 0.5) return 'Good Work!';
    return 'Keep Practicing!';
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes == 0) {
      return '$secs seconds';
    }
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
