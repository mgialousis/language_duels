import 'package:riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';

import '../models/solo_session_summary.dart';
import '../repositories/interfaces.dart';
import '../repositories/solo_history_storage.dart';

final soloHistoryStorageProvider = Provider<ISoloHistoryRepository>((ref) {
  return SoloHistoryStorage();
});

class SoloHistoryController extends StateNotifier<List<SoloSessionSummary>> {
  SoloHistoryController(this._storage) : super([]) {
    _load();
  }

  final ISoloHistoryRepository _storage;

  void _load() {
    state = _storage.getAll();
  }

  Future<void> addSession(SoloSessionSummary session) async {
    await _storage.add(session);
    _load();
  }

  Future<void> clear() async {
    await _storage.clear();
    _load();
  }
}

final soloHistoryProvider =
    StateNotifierProvider<SoloHistoryController, List<SoloSessionSummary>>(
  (ref) => SoloHistoryController(ref.read(soloHistoryStorageProvider)),
);
