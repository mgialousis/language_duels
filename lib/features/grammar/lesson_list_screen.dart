import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../data/providers/grammar_provider.dart';
import '../../shared/widgets/async_state.dart';

class LessonListScreen extends ConsumerWidget {
  const LessonListScreen({super.key, required this.level});

  final String level;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(grammarLessonsProvider(level));
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
              return ListTile(
                tileColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text(lesson.title.defaultText),
                subtitle: Text(lesson.description.defaultText),
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
