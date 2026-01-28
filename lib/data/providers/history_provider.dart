import 'package:riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';

import '../models/match_record.dart';
import '../repositories/history_storage.dart';
import '../repositories/interfaces.dart';

final historyStorageProvider = Provider<IHistoryRepository>((ref) {
  return HistoryStorage();
});

class HistoryController extends StateNotifier<List<MatchRecord>> {
  HistoryController(this._storage) : super([]) {
    _load();
  }

  final IHistoryRepository _storage;

  void _load() {
    state = _storage.getAll();
  }

  Future<void> addRecord(MatchRecord record) async {
    await _storage.add(record);
    _load();
  }

  Future<void> clear() async {
    await _storage.clear();
    _load();
  }
}

final historyProvider =
    StateNotifierProvider<HistoryController, List<MatchRecord>>((ref) {
      return HistoryController(ref.read(historyStorageProvider));
    });
