import 'package:equatable/equatable.dart';

import 'deck.dart';
import 'grammar_exercise.dart';

class GrammarLesson extends Equatable {
  final String id;
  final String category;
  final String subcategory;
  final String level;
  final int order;
  final LocalizedString title;
  final LocalizedString description;
  final GrammarExplanation explanation;
  final List<GrammarTable>? tables;
  final List<GrammarExample> examples;
  final List<GrammarExercise> exercises;
  final List<String> prerequisites;
  final List<String> tags;

  const GrammarLesson({
    required this.id,
    required this.category,
    required this.subcategory,
    required this.level,
    required this.order,
    required this.title,
    required this.description,
    required this.explanation,
    this.tables,
    required this.examples,
    required this.exercises,
    this.prerequisites = const [],
    this.tags = const [],
  });

  factory GrammarLesson.fromJson(Map<String, dynamic> json) {
    List<String> stringList(Object? value) {
      if (value is List) {
        return value.map((item) => item.toString()).toList();
      }
      return const [];
    }

    final tablesJson = json['tables'] as List<dynamic>?;
    final examplesJson = json['examples'] as List<dynamic>? ?? const [];
    final exercisesJson = json['exercises'] as List<dynamic>? ?? const [];

    return GrammarLesson(
      id: json['id'] as String,
      category: json['category'] as String? ?? '',
      subcategory: json['subcategory'] as String? ?? '',
      level: json['level'] as String? ?? 'A1',
      order: json['order'] as int? ?? 0,
      title: LocalizedString.fromJson(
        (json['title'] as Map).cast<String, dynamic>(),
      ),
      description: LocalizedString.fromJson(
        (json['description'] as Map).cast<String, dynamic>(),
      ),
      explanation: GrammarExplanation.fromJson(
        (json['explanation'] as Map).cast<String, dynamic>(),
      ),
      tables: tablesJson
          ?.map((table) => GrammarTable.fromJson(
                (table as Map).cast<String, dynamic>(),
              ))
          .toList(),
      examples: examplesJson
          .map((example) => GrammarExample.fromJson(
                (example as Map).cast<String, dynamic>(),
              ))
          .toList(),
      exercises: exercisesJson
          .map((exercise) => GrammarExercise.fromJson(
                (exercise as Map).cast<String, dynamic>(),
              ))
          .toList(),
      prerequisites: stringList(json['prerequisites']),
      tags: stringList(json['tags']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'subcategory': subcategory,
      'level': level,
      'order': order,
      'title': title.toJson(),
      'description': description.toJson(),
      'explanation': explanation.toJson(),
      'tables': tables?.map((table) => table.toJson()).toList(),
      'examples': examples.map((example) => example.toJson()).toList(),
      'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
      'prerequisites': prerequisites,
      'tags': tags,
    };
  }

  @override
  List<Object?> get props => [id, category, level, order];
}

class GrammarExplanation extends Equatable {
  final LocalizedString content;
  final List<LocalizedString> rules;
  final List<LocalizedString>? tips;
  final List<LocalizedString>? commonMistakes;

  const GrammarExplanation({
    required this.content,
    required this.rules,
    this.tips,
    this.commonMistakes,
  });

  factory GrammarExplanation.fromJson(Map<String, dynamic> json) {
    List<LocalizedString> localizedList(Object? value) {
      if (value is List) {
        return value
            .map((item) => LocalizedString.fromJson(
                  (item as Map).cast<String, dynamic>(),
                ))
            .toList();
      }
      return const [];
    }

    return GrammarExplanation(
      content: LocalizedString.fromJson(
        (json['content'] as Map).cast<String, dynamic>(),
      ),
      rules: localizedList(json['rules']),
      tips: json['tips'] == null ? null : localizedList(json['tips']),
      commonMistakes: json['commonMistakes'] == null
          ? null
          : localizedList(json['commonMistakes']),
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> localizedList(List<LocalizedString>? list) {
      return list?.map((item) => item.toJson()).toList() ?? [];
    }

    return {
      'content': content.toJson(),
      'rules': localizedList(rules),
      'tips': tips == null ? null : localizedList(tips),
      'commonMistakes':
          commonMistakes == null ? null : localizedList(commonMistakes),
    };
  }

  @override
  List<Object?> get props => [content, rules];
}

class GrammarTable extends Equatable {
  final LocalizedString title;
  final List<String> columnHeaders;
  final List<String> rowHeaders;
  final List<List<GrammarTableCell>> cells;
  final String? footnote;

  const GrammarTable({
    required this.title,
    required this.columnHeaders,
    required this.rowHeaders,
    required this.cells,
    this.footnote,
  });

  factory GrammarTable.fromJson(Map<String, dynamic> json) {
    final cellsJson = json['cells'] as List<dynamic>? ?? const [];
    return GrammarTable(
      title: LocalizedString.fromJson(
        (json['title'] as Map).cast<String, dynamic>(),
      ),
      columnHeaders: (json['columnHeaders'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      rowHeaders: (json['rowHeaders'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      cells: cellsJson
          .map((row) => (row as List<dynamic>)
              .map((cell) => GrammarTableCell.fromJson(
                    (cell as Map).cast<String, dynamic>(),
                  ))
              .toList())
          .toList(),
      footnote: json['footnote'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title.toJson(),
      'columnHeaders': columnHeaders,
      'rowHeaders': rowHeaders,
      'cells': cells
          .map((row) => row.map((cell) => cell.toJson()).toList())
          .toList(),
      'footnote': footnote,
    };
  }

  @override
  List<Object?> get props => [title, cells];
}

class GrammarTableCell extends Equatable {
  final String greek;
  final String romanization;
  final String translation;
  final bool isHighlighted;

  const GrammarTableCell({
    required this.greek,
    required this.romanization,
    required this.translation,
    this.isHighlighted = false,
  });

  factory GrammarTableCell.fromJson(Map<String, dynamic> json) {
    return GrammarTableCell(
      greek: json['greek'] as String? ?? '',
      romanization: json['romanization'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
      isHighlighted: json['isHighlighted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'greek': greek,
      'romanization': romanization,
      'translation': translation,
      'isHighlighted': isHighlighted,
    };
  }

  @override
  List<Object?> get props => [greek, translation, isHighlighted];
}

class GrammarExample extends Equatable {
  final String id;
  final String greek;
  final String romanization;
  final String catalan;
  final String? englishLiteral;
  final List<GrammarHighlight>? highlights;

  const GrammarExample({
    required this.id,
    required this.greek,
    required this.romanization,
    required this.catalan,
    this.englishLiteral,
    this.highlights,
  });

  factory GrammarExample.fromJson(Map<String, dynamic> json) {
    final highlightsJson = json['highlights'] as List<dynamic>?;
    return GrammarExample(
      id: json['id'] as String,
      greek: json['greek'] as String? ?? '',
      romanization: json['romanization'] as String? ?? '',
      catalan: json['catalan'] as String? ?? '',
      englishLiteral: json['englishLiteral'] as String?,
      highlights: highlightsJson
          ?.map((item) => GrammarHighlight.fromJson(
                (item as Map).cast<String, dynamic>(),
              ))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'greek': greek,
      'romanization': romanization,
      'catalan': catalan,
      'englishLiteral': englishLiteral,
      'highlights': highlights?.map((item) => item.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [id, greek];
}

class GrammarHighlight {
  final int startIndex;
  final int endIndex;
  final String explanation;

  const GrammarHighlight({
    required this.startIndex,
    required this.endIndex,
    required this.explanation,
  });

  factory GrammarHighlight.fromJson(Map<String, dynamic> json) {
    return GrammarHighlight(
      startIndex: json['startIndex'] as int? ?? 0,
      endIndex: json['endIndex'] as int? ?? 0,
      explanation: json['explanation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startIndex': startIndex,
      'endIndex': endIndex,
      'explanation': explanation,
    };
  }
}
