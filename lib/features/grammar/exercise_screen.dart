import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../data/models/grammar_exercise.dart';
import '../../data/providers/grammar_provider.dart';
import '../../shared/widgets/async_state.dart';
import 'controllers/grammar_exercise_controller.dart';

class GrammarExerciseScreen extends ConsumerStatefulWidget {
  const GrammarExerciseScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<GrammarExerciseScreen> createState() =>
      _GrammarExerciseScreenState();
}

class _GrammarExerciseScreenState
    extends ConsumerState<GrammarExerciseScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _initializedLessonId;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lessonAsync = ref.watch(grammarLessonProvider(widget.lessonId));
    return lessonAsync.when(
      loading: () => const Scaffold(
        body: LoadingState(message: 'Loading exercises...'),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Exercises')),
        body: ErrorState(
          title: 'Exercises unavailable',
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
        if (lesson.exercises.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Exercises')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.menu_book, size: 56),
                  const SizedBox(height: 12),
                  Text('No exercises for this lesson yet.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Back to Lesson'),
                  ),
                ],
              ),
            ),
          );
        }

        final controller = ref.read(grammarExerciseControllerProvider.notifier);
        final state = ref.watch(grammarExerciseControllerProvider);

        if (_initializedLessonId != lesson.id) {
          _initializedLessonId = lesson.id;
          if (lesson.exercises.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                controller.initialize(lesson.exercises);
              }
            });
          }
        }

        if (state.exercises.isEmpty) {
          return const Scaffold(
            body: LoadingState(message: 'Loading exercises...'),
          );
        }

        if (state.isComplete) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.go(grammarExerciseResultsRoute, extra: {
                'score': state.score,
                'total': state.exercises.length,
                'lessonId': lesson.id,
              });
            }
          });
          return const Scaffold(
            body: LoadingState(message: 'Finishing up...'),
          );
        }

        final exercise = state.currentExercise;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Exercises'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Exercise ${state.currentIndex + 1} of ${state.exercises.length}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                Text(exercise.instruction.defaultText),
                const SizedBox(height: 12),
                Text(
                  exercise.prompt,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (exercise.promptRomanization != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    exercise.promptRomanization!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (exercise.hint != null && exercise.hint!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    exercise.hint!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                ],
                const SizedBox(height: 16),
                _ExerciseBody(
                  exercise: exercise,
                  controller: _controller,
                  onOptionSelected: (value) {
                    if (!state.isSubmitted) {
                      controller.submitAnswer(value);
                    }
                  },
                  onAnswerChanged: (value) {
                    if (!state.isSubmitted) {
                      controller.updateAnswer(value);
                    }
                  },
                  isSubmitted: state.isSubmitted,
                ),
                const Spacer(),
                if (!state.isSubmitted)
                  ElevatedButton(
                    onPressed: () {
                      final answer = state.userAnswer ?? _controller.text.trim();
                      controller.submitAnswer(answer);
                    },
                    child: const Text('Check Answer'),
                  ),
                if (state.isSubmitted)
                  ElevatedButton(
                    onPressed: () {
                      _controller.clear();
                      controller.nextExercise();
                    },
                    child: const Text('Next'),
                  ),
                const SizedBox(height: 8),
                if (state.isSubmitted)
                  _FeedbackBanner(
                    isCorrect: state.isCorrect ?? false,
                    correctAnswer: exercise.correctAnswer,
                    showAnswer: exercise.correctAnswer.isNotEmpty,
                    explanation: exercise.explanation?.defaultText,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

}

class _ExerciseBody extends StatelessWidget {
  const _ExerciseBody({
    required this.exercise,
    required this.controller,
    required this.onOptionSelected,
    required this.onAnswerChanged,
    required this.isSubmitted,
  });

  final GrammarExercise exercise;
  final TextEditingController controller;
  final ValueChanged<Object?> onOptionSelected;
  final ValueChanged<Object?> onAnswerChanged;
  final bool isSubmitted;

  @override
  Widget build(BuildContext context) {
    switch (exercise.type) {
      case GrammarExerciseType.multipleChoice:
        final options = exercise.options ?? const [];
        return Column(
          children: options
              .map(
                (option) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: OutlinedButton(
                    onPressed: isSubmitted ? null : () => onOptionSelected(option),
                    child: Text(option),
                  ),
                ),
              )
              .toList(),
        );
      case GrammarExerciseType.fillBlank:
      case GrammarExerciseType.translation:
      case GrammarExerciseType.errorCorrection:
      case GrammarExerciseType.transformation:
        return TextField(
          controller: controller,
          onChanged: onAnswerChanged,
          enabled: !isSubmitted,
          decoration: const InputDecoration(
            labelText: 'Your answer',
            border: OutlineInputBorder(),
          ),
        );
      case GrammarExerciseType.conjugation:
        if (exercise.conjugations == null || exercise.conjugations!.isEmpty) {
          return TextField(
            controller: controller,
            onChanged: onAnswerChanged,
            enabled: !isSubmitted,
            decoration: const InputDecoration(
              labelText: 'Your answer',
              border: OutlineInputBorder(),
            ),
          );
        }
        return _ConjugationExercise(
          items: exercise.conjugations ?? const [],
          onAnswerChanged: onAnswerChanged,
          isSubmitted: isSubmitted,
        );
      case GrammarExerciseType.tableCompletion:
        if (exercise.conjugations == null || exercise.conjugations!.isEmpty) {
          return TextField(
            controller: controller,
            onChanged: onAnswerChanged,
            enabled: !isSubmitted,
            decoration: const InputDecoration(
              labelText: 'Your answer',
              border: OutlineInputBorder(),
            ),
          );
        }
        return _ConjugationExercise(
          items: exercise.conjugations ?? const [],
          onAnswerChanged: onAnswerChanged,
          isSubmitted: isSubmitted,
        );
      case GrammarExerciseType.matching:
        if (exercise.pairs == null || exercise.pairs!.isEmpty) {
          return TextField(
            controller: controller,
            onChanged: onAnswerChanged,
            enabled: !isSubmitted,
            decoration: const InputDecoration(
              labelText: 'Your answer',
              border: OutlineInputBorder(),
            ),
          );
        }
        return _MatchingExercise(
          pairs: exercise.pairs ?? const [],
          onAnswerChanged: onAnswerChanged,
          isSubmitted: isSubmitted,
        );
    }
  }
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({
    required this.isCorrect,
    required this.correctAnswer,
    required this.showAnswer,
    required this.explanation,
  });

  final bool isCorrect;
  final String correctAnswer;
  final bool showAnswer;
  final String? explanation;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isCorrect ? 'Correct!' : 'Not quite',
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
          if (!isCorrect && showAnswer) ...[
            const SizedBox(height: 4),
            Text('Answer: $correctAnswer'),
          ],
          if (explanation != null && explanation!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(explanation!),
          ],
        ],
      ),
    );
  }
}

class _ConjugationExercise extends StatefulWidget {
  const _ConjugationExercise({
    required this.items,
    required this.onAnswerChanged,
    required this.isSubmitted,
  });

  final List<GrammarConjugationItem> items;
  final ValueChanged<Object?> onAnswerChanged;
  final bool isSubmitted;

  @override
  State<_ConjugationExercise> createState() => _ConjugationExerciseState();
}

class _ConjugationExerciseState extends State<_ConjugationExercise> {
  late final Map<String, String> _answers;

  @override
  void initState() {
    super.initState();
    _answers = {for (final item in widget.items) item.label: ''};
  }

  @override
  void didUpdateWidget(covariant _ConjugationExercise oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _answers
        ..clear()
        ..addAll({for (final item in widget.items) item.label: ''});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const Text('No conjugation data available.');
    }
    return Column(
      children: widget.items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                enabled: !widget.isSubmitted,
                decoration: InputDecoration(
                  labelText: item.label,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _answers[item.label] = value;
                  widget.onAnswerChanged(Map<String, String>.from(_answers));
                },
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MatchingExercise extends StatefulWidget {
  const _MatchingExercise({
    required this.pairs,
    required this.onAnswerChanged,
    required this.isSubmitted,
  });

  final List<GrammarMatchPair> pairs;
  final ValueChanged<Object?> onAnswerChanged;
  final bool isSubmitted;

  @override
  State<_MatchingExercise> createState() => _MatchingExerciseState();
}

class _MatchingExerciseState extends State<_MatchingExercise> {
  late final Map<String, String> _matches;
  late final List<String> _rightOptions;

  @override
  void initState() {
    super.initState();
    _matches = {for (final pair in widget.pairs) pair.left: ''};
    _rightOptions =
        widget.pairs.map((pair) => pair.right).toSet().toList();
    _rightOptions.shuffle();
  }

  @override
  void didUpdateWidget(covariant _MatchingExercise oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pairs != widget.pairs) {
      _matches
        ..clear()
        ..addAll({for (final pair in widget.pairs) pair.left: ''});
      _rightOptions
        ..clear()
        ..addAll(widget.pairs.map((pair) => pair.right).toSet());
      _rightOptions.shuffle();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pairs.isEmpty) {
      return const Text('No matching data available.');
    }
    return Column(
      children: widget.pairs
          .map(
            (pair) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(pair.left),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _matches[pair.left]!.isEmpty
                          ? null
                          : _matches[pair.left],
                      items: _rightOptions
                          .map(
                            (option) => DropdownMenuItem(
                              value: option,
                              child: Text(option),
                            ),
                          )
                          .toList(),
                      onChanged: widget.isSubmitted
                          ? null
                          : (value) {
                              _matches[pair.left] = value ?? '';
                              widget.onAnswerChanged(
                                Map<String, String>.from(_matches),
                              );
                            },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Select',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
