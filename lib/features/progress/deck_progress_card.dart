import 'package:flutter/material.dart';

import '../../data/models/deck_progress.dart';

class DeckProgressCard extends StatelessWidget {
  const DeckProgressCard({
    super.key,
    required this.title,
    required this.progress,
  });

  final String title;
  final DeckProgress progress;

  @override
  Widget build(BuildContext context) {
    final pct = progress.masteryPercentage.clamp(0.0, 100.0);
    final learningPct = progress.learningPercentage.clamp(0.0, 100.0);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: pct / 100),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, value, _) {
                        return LinearProgressIndicator(
                          value: value,
                          minHeight: 8,
                          backgroundColor: scheme.surfaceContainerHighest,
                          color: scheme.primary,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${pct.toStringAsFixed(0)}%'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${progress.itemsMastered}/${progress.totalItems} mastered',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: learningPct / 100,
                      minHeight: 6,
                      backgroundColor: scheme.surfaceContainerHighest,
                      color: scheme.secondary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${learningPct.toStringAsFixed(0)}%'),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${progress.itemsSeen}/${progress.totalItems} learned',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
