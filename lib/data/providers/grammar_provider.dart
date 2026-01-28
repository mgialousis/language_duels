import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/grammar_lesson.dart';
import '../models/grammar_progress.dart';
import '../repositories/grammar_repository.dart';
import '../repositories/interfaces.dart';

final grammarRepositoryProvider = Provider<IGrammarRepository>((ref) {
  return GrammarRepository();
});

final grammarLessonsProvider =
    FutureProvider.family<List<GrammarLesson>, String>((ref, level) {
  final repo = ref.read(grammarRepositoryProvider);
  return repo.loadLessons(level);
});

final grammarLessonProvider =
    FutureProvider.family<GrammarLesson?, String>((ref, id) {
  final repo = ref.read(grammarRepositoryProvider);
  return repo.loadLesson(id);
});

class GrammarProgressController
    extends StateNotifier<Map<String, GrammarProgress>> {
  GrammarProgressController(this._repository)
      : super(_repository.loadAllProgress());

  final IGrammarRepository _repository;

  GrammarProgress progressFor(String lessonId) {
    return state[lessonId] ?? GrammarProgress(lessonId: lessonId);
  }

  Future<void> saveProgress(GrammarProgress progress) async {
    state = {...state, progress.lessonId: progress};
    await _repository.saveProgress(progress);
  }
}

final grammarProgressProvider = StateNotifierProvider<GrammarProgressController,
    Map<String, GrammarProgress>>((ref) {
  final repo = ref.read(grammarRepositoryProvider);
  return GrammarProgressController(repo);
});
