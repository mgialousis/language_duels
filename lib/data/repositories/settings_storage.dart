import 'package:hive/hive.dart';

import '../models/settings_state.dart';
import 'interfaces.dart';

class SettingsStorage implements ISettingsRepository {
  static const String _boxName = 'settings';
  static const String _key = 'settings';

  Box<dynamic> get _box => Hive.box<dynamic>(_boxName);

  @override
  SettingsState load() {
    final value = _box.get(_key);
    if (value is SettingsState) return value;
    if (value is Map) {
      return SettingsState.fromJson(value.cast<String, dynamic>());
    }
    return SettingsState.defaults;
  }

  @override
  Future<void> save(SettingsState settings) async {
    await _box.put(_key, settings);
  }
}
