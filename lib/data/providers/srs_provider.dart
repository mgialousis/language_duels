import 'package:riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';

import '../models/srs_item.dart';
import '../repositories/interfaces.dart';
import '../repositories/srs_storage.dart';
import '../services/srs_helpers.dart';

final srsStorageProvider = Provider<ISrsRepository>((ref) {
  return SrsStorage();
});

class SrsController extends StateNotifier<AsyncValue<Map<String, SRSItem>>> {
  SrsController(this._storage) : super(const AsyncValue.loading()) {
    _load();
  }

  final ISrsRepository _storage;

  Future<void> _load() async {
    final items = _storage.loadAll();
    state = AsyncValue.data(items);
  }

  Future<void> saveItem(SRSItem item) async {
    await _storage.saveItem(item);
    state.whenData((items) {
      state = AsyncValue.data({...items, item.itemId: item});
    });
  }

  Future<void> saveAll(Iterable<SRSItem> items) async {
    await _storage.saveAll(items);
    state.whenData((current) {
      final updated = {...current};
      for (final item in items) {
        updated[item.itemId] = item;
      }
      state = AsyncValue.data(updated);
    });
  }

  Future<void> clear() async {
    await _storage.clear();
    state = const AsyncValue.data({});
  }
}

final srsItemsProvider =
    StateNotifierProvider<SrsController, AsyncValue<Map<String, SRSItem>>>(
  (ref) => SrsController(ref.read(srsStorageProvider)),
);

final dueItemsProvider = Provider.family<List<SRSItem>, String>((ref, deckId) {
  final items = ref.watch(srsItemsProvider).value ?? {};
  return items.values
      .where((item) => item.deckId == deckId && item.isDue)
      .toList()
    ..sort((a, b) => a.nextReviewDate.compareTo(b.nextReviewDate));
});

final weakItemsProvider = Provider<List<SRSItem>>((ref) {
  final items = ref.watch(srsItemsProvider).value ?? {};
  return items.values
      .where((item) => !isGrammarSrsItem(item) && item.isWeak)
      .toList();
});

final vocabDueItemsProvider = Provider<List<SRSItem>>((ref) {
  final items = ref.watch(srsItemsProvider).value ?? {};
  return items.values
      .where((item) => !isGrammarSrsItem(item) && item.isDue)
      .toList()
    ..sort((a, b) => a.nextReviewDate.compareTo(b.nextReviewDate));
});

final grammarDueItemsProvider = Provider<List<SRSItem>>((ref) {
  final items = ref.watch(srsItemsProvider).value ?? {};
  return items.values
      .where((item) => isGrammarSrsItem(item) && item.isDue)
      .toList()
    ..sort((a, b) => a.nextReviewDate.compareTo(b.nextReviewDate));
});

final grammarWeakItemsProvider = Provider<List<SRSItem>>((ref) {
  final items = ref.watch(srsItemsProvider).value ?? {};
  return items.values
      .where((item) => isGrammarSrsItem(item) && item.isWeak)
      .toList();
});

final allDueItemsProvider = Provider<List<SRSItem>>((ref) {
  final items = ref.watch(srsItemsProvider).value ?? {};
  return items.values.where((item) => item.isDue).toList()
    ..sort((a, b) => a.nextReviewDate.compareTo(b.nextReviewDate));
});
