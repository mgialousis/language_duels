import 'package:hive/hive.dart';

import '../models/match_record.dart';
import 'interfaces.dart';

class HistoryStorage implements IHistoryRepository {
  static const String _boxName = 'history';

  Box<dynamic> get _box => Hive.box<dynamic>(_boxName);

  @override
  Future<void> add(MatchRecord record) async {
    await _box.put(record.id, record);
  }

  @override
  List<MatchRecord> getAll() {
    final records = <MatchRecord>[];
    for (final value in _box.values) {
      if (value is MatchRecord) {
        records.add(value);
      } else if (value is Map) {
        records.add(MatchRecord.fromJson(value.cast<String, dynamic>()));
      }
    }
    records.sort((a, b) => b.playedAt.compareTo(a.playedAt));
    return records;
  }

  @override
  Future<void> clear() async {
    await _box.clear();
  }
}
