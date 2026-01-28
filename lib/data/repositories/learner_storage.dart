import 'package:hive/hive.dart';

import '../models/learner_profile.dart';
import 'interfaces.dart';

class LearnerStorage implements ILearnerRepository {
  static const String _boxName = 'learner_profile';
  static const String _profileKey = 'profile';

  Box<dynamic> get _box => Hive.box<dynamic>(_boxName);

  @override
  LearnerProfile? load() {
    final value = _box.get(_profileKey);
    if (value is LearnerProfile) return value;
    if (value is Map) {
      return LearnerProfile.fromJson(value.cast<String, dynamic>());
    }
    return null;
  }

  @override
  bool hasProfile() => _box.containsKey(_profileKey);

  @override
  Future<void> save(LearnerProfile profile) async {
    await _box.put(_profileKey, profile);
  }

  @override
  Future<void> clear() async {
    await _box.clear();
  }
}
