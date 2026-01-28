import 'package:equatable/equatable.dart';

import 'deck.dart';

enum GrammarExerciseType {
  fillBlank,
  multipleChoice,
  conjugation,
  transformation,
  matching,
  errorCorrection,
  translation,
  tableCompletion,
}

GrammarExerciseType _exerciseTypeFromJson(String value) {
  try {
    return GrammarExerciseType.values.byName(value);
  } catch (_) {
    final normalized = value.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    for (final type in GrammarExerciseType.values) {
      final candidate = type.name.toLowerCase();
      if (candidate == normalized) return type;
    }
    return GrammarExerciseType.fillBlank;
  }
}

class GrammarExercise extends Equatable {
  final String id;
  final GrammarExerciseType type;
  final int difficulty;
  final LocalizedString instruction;
  final String prompt;
  final String? promptRomanization;
  final String correctAnswer;
  final List<String>? options;
  final List<String>? acceptableAnswers;
  final List<GrammarConjugationItem>? conjugations;
  final List<GrammarMatchPair>? pairs;
  final LocalizedString? explanation;
  final String? hint;

  const GrammarExercise({
    required this.id,
    required this.type,
    required this.difficulty,
    required this.instruction,
    required this.prompt,
    this.promptRomanization,
    required this.correctAnswer,
    this.options,
    this.acceptableAnswers,
    this.conjugations,
    this.pairs,
    this.explanation,
    this.hint,
  });

  factory GrammarExercise.fromJson(Map<String, dynamic> json) {
    List<String>? stringList(Object? value) {
      if (value is List) {
        return value.map((item) => item.toString()).toList();
      }
      return null;
    }

    final conjugationsJson = json['conjugations'] as List<dynamic>?;
    final pairsJson = json['pairs'] as List<dynamic>?;

    return GrammarExercise(
      id: json['id'] as String,
      type: _exerciseTypeFromJson(json['type'] as String? ?? ''),
      difficulty: json['difficulty'] as int? ?? 1,
      instruction: LocalizedString.fromJson(
        (json['instruction'] as Map).cast<String, dynamic>(),
      ),
      prompt: json['prompt'] as String? ?? '',
      promptRomanization: json['promptRomanization'] as String?,
      correctAnswer: json['correctAnswer'] as String? ?? '',
      options: stringList(json['options']),
      acceptableAnswers: stringList(json['acceptableAnswers']),
      conjugations: conjugationsJson
          ?.map((item) => GrammarConjugationItem.fromJson(
                (item as Map).cast<String, dynamic>(),
              ))
          .toList(),
      pairs: pairsJson
          ?.map((item) => GrammarMatchPair.fromJson(
                (item as Map).cast<String, dynamic>(),
              ))
          .toList(),
      explanation: json['explanation'] == null
          ? null
          : LocalizedString.fromJson(
              (json['explanation'] as Map).cast<String, dynamic>(),
            ),
      hint: json['hint'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'difficulty': difficulty,
      'instruction': instruction.toJson(),
      'prompt': prompt,
      'promptRomanization': promptRomanization,
      'correctAnswer': correctAnswer,
      'options': options,
      'acceptableAnswers': acceptableAnswers,
      'conjugations': conjugations?.map((item) => item.toJson()).toList(),
      'pairs': pairs?.map((item) => item.toJson()).toList(),
      'explanation': explanation?.toJson(),
      'hint': hint,
    };
  }

  @override
  List<Object?> get props => [id, type, prompt];
}

class GrammarConjugationItem extends Equatable {
  final String label;
  final String answer;
  final String? romanization;
  final List<String>? acceptableAnswers;

  const GrammarConjugationItem({
    required this.label,
    required this.answer,
    this.romanization,
    this.acceptableAnswers,
  });

  factory GrammarConjugationItem.fromJson(Map<String, dynamic> json) {
    List<String>? stringList(Object? value) {
      if (value is List) {
        return value.map((item) => item.toString()).toList();
      }
      return null;
    }

    return GrammarConjugationItem(
      label: json['label'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      romanization: json['romanization'] as String?,
      acceptableAnswers: stringList(json['acceptableAnswers']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'answer': answer,
      'romanization': romanization,
      'acceptableAnswers': acceptableAnswers,
    };
  }

  @override
  List<Object?> get props => [label, answer];
}

class GrammarMatchPair extends Equatable {
  final String left;
  final String right;

  const GrammarMatchPair({required this.left, required this.right});

  factory GrammarMatchPair.fromJson(Map<String, dynamic> json) {
    return GrammarMatchPair(
      left: json['left'] as String? ?? '',
      right: json['right'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'left': left,
      'right': right,
    };
  }

  @override
  List<Object?> get props => [left, right];
}
