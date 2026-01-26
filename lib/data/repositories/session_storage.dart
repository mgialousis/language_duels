import 'package:hive/hive.dart';

class SessionStorage {
  static const String _boxName = 'session';
  static const String _key = 'current_session';

  Box<dynamic> get _box => Hive.box<dynamic>(_boxName);

  Future<void> saveSession(Map<String, dynamic> json) async {
    await _box.put(_key, json);
  }

  Map<String, dynamic>? loadSession() {
    final value = _box.get(_key);
    if (value is Map) {
      return value.cast<String, dynamic>();
    }
    return null;
  }

  Future<void> clearSession() async {
    await _box.delete(_key);
  }
}
