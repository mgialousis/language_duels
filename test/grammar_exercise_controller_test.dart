import 'package:flutter_test/flutter_test.dart';

import 'package:language_duels/data/models/deck.dart';
import 'package:language_duels/data/models/grammar_exercise.dart';
import 'package:language_duels/features/grammar/controllers/grammar_exercise_controller.dart';

void main() {
  test('initialize sets exercises and resets state', () {
    final controller = GrammarExerciseController();
    final exercises = [
      _makeExercise(id: 'ex1', type: GrammarExerciseType.fillBlank),
      _makeExercise(id: 'ex2', type: GrammarExerciseType.fillBlank),
    ];

    controller.initialize(exercises);

    expect(controller.state.exercises.length, 2);
    expect(controller.state.currentIndex, 0);
    expect(controller.state.isSubmitted, false);
  });

  test('submitAnswer updates score and blocks updates after submit', () {
    final controller = GrammarExerciseController();
    controller.initialize([
      _makeExercise(
        id: 'ex1',
        type: GrammarExerciseType.fillBlank,
        correctAnswer: 'cafe',
      ),
    ]);

    controller.updateAnswer('cafe');
    controller.submitAnswer('cafe');

    expect(controller.state.isSubmitted, true);
    expect(controller.state.isCorrect, true);
    expect(controller.state.score, 10);

    controller.updateAnswer('ignored');
    expect(controller.state.userAnswer, 'cafe');
  });

  test('nextExercise marks completion when at end', () {
    final controller = GrammarExerciseController();
    controller.initialize([
      _makeExercise(id: 'ex1', type: GrammarExerciseType.fillBlank),
    ]);

    controller.submitAnswer('answer');
    controller.nextExercise();

    expect(controller.state.isComplete, true);
  });

  test('matching exercise validates map answers', () {
    final controller = GrammarExerciseController();
    final exercise = _makeExercise(
      id: 'match1',
      type: GrammarExerciseType.matching,
      pairs: [
        const GrammarMatchPair(left: 'a', right: 'b'),
        const GrammarMatchPair(left: 'c', right: 'd'),
      ],
    );
    controller.initialize([exercise]);

    controller.submitAnswer({'a': 'b', 'c': 'd'});

    expect(controller.state.isCorrect, true);
  });

  test('conjugation exercise validates acceptable answers', () {
    final controller = GrammarExerciseController();
    final exercise = _makeExercise(
      id: 'conj1',
      type: GrammarExerciseType.conjugation,
      conjugations: [
        const GrammarConjugationItem(
          label: 'yo',
          answer: 'soy',
          acceptableAnswers: ['estoy'],
        ),
      ],
    );
    controller.initialize([exercise]);

    controller.submitAnswer({'yo': 'estoy'});

    expect(controller.state.isCorrect, true);
  });
}

GrammarExercise _makeExercise({
  required String id,
  required GrammarExerciseType type,
  String correctAnswer = 'answer',
  List<GrammarConjugationItem>? conjugations,
  List<GrammarMatchPair>? pairs,
}) {
  return GrammarExercise(
    id: id,
    type: type,
    difficulty: 1,
    instruction: const LocalizedString(en: 'Test'),
    prompt: 'Prompt',
    correctAnswer: correctAnswer,
    conjugations: conjugations,
    pairs: pairs,
  );
}
