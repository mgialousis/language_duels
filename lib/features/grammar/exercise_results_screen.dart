import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../data/models/grammar_progress.dart';
import '../../data/providers/grammar_provider.dart';
import '../../data/providers/srs_provider.dart';
import '../../data/services/srs_service.dart';
import '../../data/services/srs_helpers.dart';
import '../../data/models/srs_item.dart';

class GrammarExerciseResultsScreen extends ConsumerWidget {
  const GrammarExerciseResultsScreen({
    super.key,
    required this.score,
    required this.total,
    required this.lessonId,
  });

  final int score;
  final int total;
  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final percent = total == 0 ? 0 : (score / (total * 10)) * 100;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (lessonId.isEmpty) return;
      final correctCount = total == 0 ? 0 : (score ~/ 10).clamp(0, total);
      final accuracy = total == 0 ? 0.0 : correctCount / total;
      final progress = ref
          .read(grammarProgressProvider.notifier)
          .progressFor(lessonId);
      final masteryLevel = accuracy >= 0.85
          ? GrammarMasteryLevel.mastered
          : GrammarMasteryLevel.practicing;
      ref.read(grammarProgressProvider.notifier).saveProgress(
            progress.copyWith(
              isUnlocked: true,
              exercisesCompleted: total,
              exercisesTotal: total,
              accuracy: accuracy,
              lastPracticed: DateTime.now(),
              masteryLevel: masteryLevel,
            ),
          );
      _updateSrs(ref, lessonId, accuracy);
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Score: $score',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Accuracy: ${percent.toStringAsFixed(0)}%'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(grammarRoute),
              child: const Text('Back to Grammar Hub'),
            ),
          ],
        ),
      ),
    );
  }
}

void _updateSrs(WidgetRef ref, String lessonId, double accuracy) {
  final srsController = ref.read(srsItemsProvider.notifier);
  final existingItems = ref.read(srsItemsProvider).value ?? {};
  final itemId = grammarItemId(lessonId);
  final current =
      existingItems[itemId] ?? SRSItem.newItem(itemId, grammarDeckId);
  final quality = _qualityFromAccuracy(accuracy);
  final updated = SrsService().processReview(current, quality, 0);
  srsController.saveItem(updated);
}

int _qualityFromAccuracy(double accuracy) {
  if (accuracy >= 0.9) return 3;
  if (accuracy >= 0.75) return 2;
  if (accuracy >= 0.5) return 1;
  return 0;
}
