import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../data/models/grammar_progress.dart';
import '../../data/providers/grammar_provider.dart';
import '../../shared/widgets/async_state.dart';

class LessonListScreen extends ConsumerWidget {
  const LessonListScreen({super.key, required this.level});

  final String level;

  String _masteryLabel(GrammarMasteryLevel level) {
    switch (level) {
      case GrammarMasteryLevel.notStarted:
        return 'Not started';
      case GrammarMasteryLevel.learning:
        return 'Learning';
      case GrammarMasteryLevel.practicing:
        return 'Practicing';
      case GrammarMasteryLevel.reviewing:
        return 'Reviewing';
      case GrammarMasteryLevel.mastered:
        return 'Mastered';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(grammarLessonsProvider(level));
    final progressMap = ref.watch(grammarProgressProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Grammar $level')),
      body: lessonsAsync.when(
        loading: () => const LoadingState(message: 'Loading lessons...'),
        error: (error, _) => ErrorState(
          title: 'Lessons unavailable',
          message: 'Please try again.',
          onRetry: () => ref.refresh(grammarLessonsProvider(level)),
        ),
        data: (lessons) {
          if (lessons.isEmpty) {
            return Center(
              child: Text('No $level lessons yet.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lessons.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              final progress = progressMap[lesson.id];
              final accuracy = progress?.accuracy ?? 0.0;
              final percent = (accuracy * 100).round();
              final mastery =
                  _masteryLabel(progress?.masteryLevel ??
                      GrammarMasteryLevel.notStarted);
              return ListTile(
                tileColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text(lesson.title.defaultText),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lesson.description.defaultText),
                    const SizedBox(height: 4),
                    Text(
                      '$percent% • $mastery',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.push(
                    grammarLessonRoute.replaceFirst(':id', lesson.id),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
