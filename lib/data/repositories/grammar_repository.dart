import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

import '../models/grammar_lesson.dart';
import '../models/grammar_progress.dart';
import 'interfaces.dart';

class GrammarRepository implements IGrammarRepository {
  static const String _indexAsset = 'assets/data/grammar/grammar_index.json';
  static const String _progressBoxName = 'grammar_progress';

  Box<dynamic> get _progressBox => Hive.box<dynamic>(_progressBoxName);

  Future<Map<String, dynamic>> _loadIndexMap() async {
    final jsonString = await rootBundle.loadString(_indexAsset);
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  Future<Map<String, String>> _lessonFileMap() async {
    final index = await _loadIndexMap();
    final levels = index['levels'] as List<dynamic>? ?? const [];
    final mapping = <String, String>{};
    for (final levelEntry in levels) {
      final levelMap = (levelEntry as Map).cast<String, dynamic>();
      final lessons = levelMap['lessons'] as List<dynamic>? ?? const [];
      for (final lessonEntry in lessons) {
        final lessonMap = (lessonEntry as Map).cast<String, dynamic>();
        final id = lessonMap['id'] as String?;
        final file = lessonMap['file'] as String?;
        if (id != null && file != null) {
          mapping[id] = 'assets/data/grammar/$file';
        }
      }
    }
    return mapping;
  }

  Future<List<String>> _lessonFilesForLevel(String level) async {
    final index = await _loadIndexMap();
    final levels = index['levels'] as List<dynamic>? ?? const [];
    for (final entry in levels) {
      final levelMap = (entry as Map).cast<String, dynamic>();
      if ((levelMap['id'] as String?) == level) {
        final lessons = levelMap['lessons'] as List<dynamic>? ?? const [];
        final lessonMaps = lessons
            .map((lesson) => (lesson as Map).cast<String, dynamic>())
            .where((lesson) => lesson['file'] != null)
            .toList();
        lessonMaps.sort((a, b) =>
            (a['order'] as int? ?? 0).compareTo(b['order'] as int? ?? 0));
        return lessonMaps
            .map((lesson) => 'assets/data/grammar/${lesson['file']}')
            .toList();
      }
    }
    return const [];
  }

  @override
  Map<String, GrammarProgress> loadAllProgress() {
    final progress = <String, GrammarProgress>{};
    for (final entry in _progressBox.toMap().entries) {
      final value = entry.value;
      if (value is GrammarProgress) {
        progress[value.lessonId] = value;
      } else if (value is Map) {
        final parsed = GrammarProgress.fromJson(value.cast<String, dynamic>());
        progress[parsed.lessonId] = parsed;
      }
    }
    return progress;
  }

  @override
  Future<void> saveProgress(GrammarProgress progress) async {
    await _progressBox.put(progress.lessonId, progress);
  }

  @override
  Future<List<GrammarLesson>> loadLessons(String level) async {
    final files = await _lessonFilesForLevel(level);
    if (files.isEmpty) return const [];

    final lessons = <GrammarLesson>[];
    for (final file in files) {
      try {
        final jsonString = await rootBundle.loadString(file);
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        lessons.add(GrammarLesson.fromJson(jsonMap));
      } catch (error) {
        // Skip malformed lesson to avoid blocking the entire list.
        // ignore: avoid_print
        print('Failed to load grammar lesson: $file ($error)');
      }
    }
    return lessons;
  }

  @override
  Future<GrammarLesson?> loadLesson(String id) async {
    final files = await _lessonFileMap();
    final file = files[id];
    if (file == null) return null;
    final jsonString = await rootBundle.loadString(file);
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    return GrammarLesson.fromJson(jsonMap);
  }
}
