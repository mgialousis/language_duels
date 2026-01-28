import 'package:hive/hive.dart';

import '../models/srs_item.dart';
import 'interfaces.dart';

class SrsStorage implements ISrsRepository {
  static const String _boxName = 'srs_items';

  Box<dynamic> get _box => Hive.box<dynamic>(_boxName);

  @override
  Map<String, SRSItem> loadAll() {
    final items = <String, SRSItem>{};
    for (final entry in _box.toMap().entries) {
      final key = entry.key.toString();
      final value = entry.value;
      if (value is SRSItem) {
        items[key] = value;
      } else if (value is Map) {
        items[key] = SRSItem.fromJson(value.cast<String, dynamic>());
      }
    }
    return items;
  }

  @override
  Future<void> saveItem(SRSItem item) async {
    await _box.put(item.itemId, item);
  }

  @override
  Future<void> saveAll(Iterable<SRSItem> items) async {
    final batch = <String, SRSItem>{
      for (final item in items) item.itemId: item,
    };
    await _box.putAll(batch);
  }

  @override
  Future<void> clear() async {
    await _box.clear();
  }
}
