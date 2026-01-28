import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../data/providers/grammar_provider.dart';
import '../../shared/widgets/async_state.dart';
import 'widgets/explanation_tab.dart';
import 'widgets/examples_tab.dart';
import 'widgets/grammar_table_widget.dart';

class LessonViewScreen extends ConsumerStatefulWidget {
  const LessonViewScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<LessonViewScreen> createState() => _LessonViewScreenState();
}

class _LessonViewScreenState extends ConsumerState<LessonViewScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _showRomanization = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lessonAsync = ref.watch(grammarLessonProvider(widget.lessonId));
    return lessonAsync.when(
      loading: () => const Scaffold(
        body: LoadingState(message: 'Loading lesson...'),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Lesson')),
        body: ErrorState(
          title: 'Lesson unavailable',
          message: 'Please try again.',
          onRetry: () => ref.refresh(grammarLessonProvider(widget.lessonId)),
        ),
      ),
      data: (lesson) {
        if (lesson == null) {
          return const Scaffold(
            body: Center(child: Text('Lesson not found.')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(lesson.title.defaultText),
            actions: [
              IconButton(
                tooltip: _showRomanization
                    ? 'Hide romanization'
                    : 'Show romanization',
                onPressed: () {
                  setState(() {
                    _showRomanization = !_showRomanization;
                  });
                },
                icon: Icon(
                  _showRomanization ? Icons.visibility_off : Icons.visibility,
                ),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Explanation'),
                Tab(text: 'Tables'),
                Tab(text: 'Examples'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              ExplanationTab(lesson: lesson),
              GrammarTableWidget(
                tables: lesson.tables ?? const [],
                showRomanization: _showRomanization,
              ),
              ExamplesTab(
                examples: lesson.examples,
                showRomanization: _showRomanization,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push(
              grammarExerciseRoute,
              extra: lesson.id,
            ),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Exercises'),
          ),
        );
      },
    );
  }
}
