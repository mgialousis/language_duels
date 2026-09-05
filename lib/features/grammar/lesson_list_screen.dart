import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../data/models/grammar_lesson.dart';
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
          if (level == 'A1') {
            final presentLessons = lessons
                .where((lesson) => lesson.subcategory == 'present_tense')
                .toList();
            final otherLessons = lessons
                .where((lesson) => lesson.subcategory != 'present_tense')
                .toList();

            final items = <Widget>[
              _PresentTenseOverviewCard(
                lessons: presentLessons,
                progressMap: progressMap,
                masteryLabel: _masteryLabel,
              ),
              ...otherLessons.map((lesson) {
                final progress = progressMap[lesson.id];
                return _lessonTile(context, lesson, progress);
              }),
            ];

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => items[index],
            );
          }

          if (level == 'A2') {
            final simplePastLessons = lessons
                .where((lesson) => lesson.id.contains('simple_past'))
                .toList();
            final otherLessons = lessons
                .where((lesson) => !lesson.id.contains('simple_past'))
                .toList();

            final items = <Widget>[
              _SimplePastOverviewCard(
                lessons: simplePastLessons,
                progressMap: progressMap,
                masteryLabel: _masteryLabel,
              ),
              ...otherLessons.map((lesson) {
                final progress = progressMap[lesson.id];
                return _lessonTile(context, lesson, progress);
              }),
            ];

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => items[index],
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lessons.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              final progress = progressMap[lesson.id];
              return _lessonTile(context, lesson, progress);
            },
          );
        },
      ),
    );
  }

  Widget _lessonTile(
    BuildContext context,
    GrammarLesson lesson,
    GrammarProgress? progress,
  ) {
    final accuracy = progress?.accuracy ?? 0.0;
    final percent = (accuracy * 100).round();
    final mastery =
        _masteryLabel(progress?.masteryLevel ?? GrammarMasteryLevel.notStarted);
    return ListTile(
      tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      onTap: () => context.push(
        grammarLessonRoute.replaceFirst(':id', lesson.id),
      ),
    );
  }
}

class _PresentTenseOverviewCard extends StatelessWidget {
  const _PresentTenseOverviewCard({
    required this.lessons,
    required this.progressMap,
    required this.masteryLabel,
  });

  final List<GrammarLesson> lessons;
  final Map<String, GrammarProgress> progressMap;
  final String Function(GrammarMasteryLevel level) masteryLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final links = const [
      _LessonLink(
        label: "A Active",
        lessonId: 'a1_g08_present_tense_regular',
      ),
      _LessonLink(
        label: "B1 Active",
        lessonId: 'a1_g13_present_tense_b1_active',
      ),
      _LessonLink(
        label: "B2 Active",
        lessonId: 'a1_g09_present_tense_common_irregular',
      ),
      _LessonLink(
        label: 'Irregular',
        lessonId: 'a1_g10_present_tense_irregular',
      ),
      _LessonLink(
        label: "A Passive",
        lessonId: 'a1_g14_present_tense_a_class_passive',
      ),
      _LessonLink(
        label: "B1 Passive",
        lessonId: 'a1_g11_present_tense_passive_a',
      ),
      _LessonLink(
        label: "B2 Passive",
        lessonId: 'a1_g12_present_tense_passive_b',
      ),
      _LessonLink(
        label: "Deponent",
        lessonId: 'a1_g15_present_tense_deponent',
      ),
    ];

    return Ink(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Present Tense Overview', style: textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            "Jump into A/B1/B2 active, irregular, passive, and deponent lessons.",
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: links
                .map(
                  (link) => ActionChip(
                    label: Text(link.label),
                    onPressed: () => context.push(
                      grammarLessonRoute.replaceFirst(':id', link.lessonId),
                    ),
                  ),
                )
                .toList(),
          ),
          if (lessons.isNotEmpty) ...[
            const SizedBox(height: 12),
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text('Present Tense Lessons'),
                subtitle: const Text('Show or hide the full set'),
                children: lessons
                    .map<Widget>(
                      (lesson) {
                        final progress = progressMap[lesson.id];
                        final accuracy = progress?.accuracy ?? 0.0;
                        final percent = (accuracy * 100).round();
                        final mastery = masteryLabel(
                          progress?.masteryLevel ??
                              GrammarMasteryLevel.notStarted,
                        );
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                          child: ListTile(
                            tileColor: scheme.surface,
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
                            onTap: () => context.push(
                              grammarLessonRoute.replaceFirst(':id', lesson.id),
                            ),
                          ),
                        );
                      },
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LessonLink {
  const _LessonLink({required this.label, required this.lessonId});

  final String label;
  final String lessonId;
}

class _SimplePastOverviewCard extends StatelessWidget {
  const _SimplePastOverviewCard({
    required this.lessons,
    required this.progressMap,
    required this.masteryLabel,
  });

  final List<GrammarLesson> lessons;
  final Map<String, GrammarProgress> progressMap;
  final String Function(GrammarMasteryLevel level) masteryLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final links = const [
      _LessonLink(
        label: 'A Class',
        lessonId: 'a2_g01_simple_past',
      ),
      _LessonLink(
        label: 'B Class',
        lessonId: 'a2_g06_simple_past_b_class',
      ),
      _LessonLink(
        label: 'Irregular',
        lessonId: 'a2_g07_simple_past_irregular',
      ),
      _LessonLink(
        label: 'Passive',
        lessonId: 'a2_g08_simple_past_passive',
      ),
    ];

    return Ink(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Simple Past Overview', style: textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            'Jump into A/B class, irregular, and passive aorist lessons.',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: links
                .map(
                  (link) => ActionChip(
                    label: Text(link.label),
                    onPressed: () => context.push(
                      grammarLessonRoute.replaceFirst(':id', link.lessonId),
                    ),
                  ),
                )
                .toList(),
          ),
          if (lessons.isNotEmpty) ...[
            const SizedBox(height: 12),
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text('Simple Past Lessons'),
                subtitle: const Text('Show or hide the full set'),
                children: lessons
                    .map<Widget>(
                      (lesson) {
                        final progress = progressMap[lesson.id];
                        final accuracy = progress?.accuracy ?? 0.0;
                        final percent = (accuracy * 100).round();
                        final mastery = masteryLabel(
                          progress?.masteryLevel ??
                              GrammarMasteryLevel.notStarted,
                        );
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                          child: ListTile(
                            tileColor: scheme.surface,
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
                            onTap: () => context.push(
                              grammarLessonRoute.replaceFirst(':id', lesson.id),
                            ),
                          ),
                        );
                      },
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
