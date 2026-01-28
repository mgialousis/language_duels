import 'package:hive/hive.dart';

import '../models/solo_session_summary.dart';
import 'interfaces.dart';

class SoloHistoryStorage implements ISoloHistoryRepository {
  static const String _boxName = 'solo_history';

  Box<dynamic> get _box => Hive.box<dynamic>(_boxName);

  @override
  Future<void> add(SoloSessionSummary session) async {
    await _box.put(session.id, session);
  }

  @override
  List<SoloSessionSummary> getAll() {
    final sessions = <SoloSessionSummary>[];
    for (final value in _box.values) {
      if (value is SoloSessionSummary) {
        sessions.add(value);
      } else if (value is Map) {
        sessions.add(
          SoloSessionSummary.fromJson(value.cast<String, dynamic>()),
        );
      }
    }
    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sessions;
  }

  @override
  Future<void> clear() async {
    await _box.clear();
  }
}
