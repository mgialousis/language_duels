import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../data/models/grammar_lesson.dart';
import '../../data/models/grammar_progress.dart';
import '../../data/providers/grammar_provider.dart';

class GrammarHubScreen extends ConsumerWidget {
  const GrammarHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(grammarProgressProvider);
    final dueLessonsAsync = ref.watch(grammarDueLessonsProvider);
    final masteredCount = progress.values
        .where((item) => item.masteryLevel == GrammarMasteryLevel.mastered)
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Grammar & Theory')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Mastery: $masteredCount lessons',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 16),
          dueLessonsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (error, _) => const SizedBox.shrink(),
            data: (lessons) {
              if (lessons.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Due for review (${lessons.length})',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ...lessons.map((lesson) => _DueLessonTile(lesson: lesson)),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
          _LevelCard(
            title: 'A1 - Beginner',
            subtitle: 'Start with essential grammar foundations.',
            onTap: () => context.push(
              grammarLevelRoute.replaceFirst(':level', 'A1'),
            ),
          ),
          const SizedBox(height: 12),
          _LevelCard(
            title: 'A2 - Elementary',
            subtitle: 'Build on basics with new structures.',
            onTap: () => context.push(
              grammarLevelRoute.replaceFirst(':level', 'A2'),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => context.push(homeRoute),
            icon: const Icon(Icons.home_outlined),
            label: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _DueLessonTile extends StatelessWidget {
  const _DueLessonTile({required this.lesson});

  final GrammarLesson lesson;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        tileColor: scheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(lesson.title.defaultText),
        subtitle: Text(lesson.description.defaultText),
        trailing: const Icon(Icons.play_circle_outline),
        onTap: () => context.push(
          grammarLessonRoute.replaceFirst(':id', lesson.id),
        ),
      ),
    );
  }
}
