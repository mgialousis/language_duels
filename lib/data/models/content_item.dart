import 'package:equatable/equatable.dart';

class LanguageEntry extends Equatable {
  final String text;
  final String? romanization;
  final String? phonetic;

  const LanguageEntry({required this.text, this.romanization, this.phonetic});

  factory LanguageEntry.fromJson(Map<String, dynamic> json) {
    return LanguageEntry(
      text: json['text'] as String,
      romanization: json['romanization'] as String?,
      phonetic: json['phonetic'] as String?,
    );
  }

  @override
  List<Object?> get props => [text, romanization, phonetic];
}

class ContentWord extends Equatable {
  final String greek;
  final String catalan;

  const ContentWord({required this.greek, required this.catalan});

  factory ContentWord.fromJson(Map<String, dynamic> json) {
    return ContentWord(
      greek: json['greek'] as String? ?? '',
      catalan: json['catalan'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [greek, catalan];
}

class ContentItem extends Equatable {
  final String id;
  final String type;
  final String category;
  final int difficulty;
  final LanguageEntry greek;
  final LanguageEntry catalan;
  final List<ContentWord> words;

  const ContentItem({
    required this.id,
    required this.type,
    required this.category,
    required this.difficulty,
    required this.greek,
    required this.catalan,
    required this.words,
  });

  bool get isPhrase => type == 'phrase';

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    final wordsJson = json['words'] as List<dynamic>?;
    final breakdownJson = json['wordBreakdown'] as List<dynamic>?;
    final derivedWords =
        (wordsJson ?? []).map((entry) => ContentWord.fromJson(entry as Map<String, dynamic>)).toList();
    final breakdownWords = (breakdownJson ?? [])
        .map((entry) {
          final map = entry as Map<String, dynamic>;
          final greek = (map['greek'] as Map<String, dynamic>?);
          final catalan = (map['catalan'] as Map<String, dynamic>?);
          return ContentWord(
            greek: (greek?['word'] as String?) ?? '',
            catalan: (catalan?['word'] as String?) ?? '',
          );
        })
        .toList();
    return ContentItem(
      id: json['id'] as String,
      type: json['type'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as int,
      greek: LanguageEntry.fromJson(json['greek'] as Map<String, dynamic>),
      catalan: LanguageEntry.fromJson(json['catalan'] as Map<String, dynamic>),
      words: derivedWords.isNotEmpty ? derivedWords : breakdownWords,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        category,
        difficulty,
        greek,
        catalan,
        words,
      ];
}
