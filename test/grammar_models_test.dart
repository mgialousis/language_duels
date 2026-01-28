import 'package:flutter_test/flutter_test.dart';

import 'package:language_duels/data/models/deck.dart';
import 'package:language_duels/data/models/grammar_exercise.dart';
import 'package:language_duels/data/models/grammar_lesson.dart';
import 'package:language_duels/data/models/grammar_progress.dart';

void main() {
  test('GrammarExercise json round trip', () {
    final json = {
      'id': 'ex1',
      'type': 'multiple_choice',
      'difficulty': 2,
      'instruction': {'en': 'Choose the correct answer'},
      'prompt': 'Hola',
      'promptRomanization': 'hola',
      'correctAnswer': 'Hello',
      'options': ['Hello', 'Bye'],
      'acceptableAnswers': ['Hi'],
      'conjugations': [
        {
          'label': 'yo',
          'answer': 'soy',
          'romanization': 'soi',
          'acceptableAnswers': ['estoy'],
        },
      ],
      'pairs': [
        {'left': 'a', 'right': 'b'},
      ],
      'explanation': {'en': 'Use a greeting.'},
      'hint': 'Think of hello',
    };

    final exercise = GrammarExercise.fromJson(json);
    expect(exercise.type, GrammarExerciseType.multipleChoice);
    expect(exercise.options, ['Hello', 'Bye']);
    expect(exercise.conjugations?.first.label, 'yo');
    expect(exercise.pairs?.first.right, 'b');

    final roundTrip = GrammarExercise.fromJson(exercise.toJson());
    expect(roundTrip.toJson(), equals(exercise.toJson()));
  });

  test('GrammarLesson json round trip', () {
    final json = {
      'id': 'a1_g01',
      'category': 'Basics',
      'subcategory': 'Verbs',
      'level': 'A1',
      'order': 1,
      'title': {'en': 'Verb to be'},
      'description': {'en': 'Learn the verb to be.'},
      'explanation': {
        'content': {'en': 'Use to describe identity.'},
        'rules': [
          {'en': 'Rule one'},
          {'en': 'Rule two'},
        ],
        'tips': [
          {'en': 'Practice aloud'},
        ],
        'commonMistakes': [
          {'en': 'Skipping the verb'},
        ],
      },
      'tables': [
        {
          'title': {'en': 'Present tense'},
          'columnHeaders': ['Singular', 'Plural'],
          'rowHeaders': ['I', 'You'],
          'cells': [
            [
              {
                'greek': 'eimai',
                'romanization': 'eimai',
                'translation': 'am',
                'isHighlighted': true,
              },
              {
                'greek': 'eimaste',
                'romanization': 'eimaste',
                'translation': 'are',
              },
            ],
          ],
          'footnote': 'Common forms',
        },
      ],
      'examples': [
        {
          'id': 'ex',
          'greek': 'Eimai foititis.',
          'romanization': 'Eimai foititis.',
          'catalan': 'Soc estudiant.',
          'englishLiteral': 'I am a student.',
          'highlights': [
            {'startIndex': 0, 'endIndex': 4, 'explanation': 'Verb'},
          ],
        },
      ],
      'exercises': [
        {
          'id': 'ex1',
          'type': 'fillBlank',
          'difficulty': 1,
          'instruction': {'en': 'Fill the blank'},
          'prompt': 'I ___ here',
          'correctAnswer': 'am',
        },
      ],
      'prerequisites': ['intro'],
      'tags': ['verbs', 'basics'],
    };

    final lesson = GrammarLesson.fromJson(json);
    expect(lesson.title, const LocalizedString(en: 'Verb to be'));
    expect(lesson.tables?.first.columnHeaders.length, 2);
    expect(lesson.examples.first.highlights?.first.explanation, 'Verb');

    final roundTrip = GrammarLesson.fromJson(lesson.toJson());
    expect(roundTrip.toJson(), equals(lesson.toJson()));
  });

  test('GrammarProgress json round trip', () {
    final lastPracticed = DateTime.parse('2024-05-20T12:30:00Z');
    const progress = GrammarProgress(
      lessonId: 'a1_g01',
      isUnlocked: true,
      explanationRead: true,
      exercisesCompleted: 4,
      exercisesTotal: 6,
      accuracy: 0.75,
      lastPracticed: null,
      reviewCount: 2,
      masteryLevel: GrammarMasteryLevel.practicing,
    );
    final withDate = progress.copyWith(lastPracticed: lastPracticed);

    final roundTrip = GrammarProgress.fromJson(withDate.toJson());
    expect(roundTrip.lessonId, withDate.lessonId);
    expect(roundTrip.lastPracticed, lastPracticed);
    expect(roundTrip.masteryLevel, GrammarMasteryLevel.practicing);
  });
}
