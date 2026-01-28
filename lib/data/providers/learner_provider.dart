import 'package:riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';

import '../models/learner_profile.dart';
import '../repositories/interfaces.dart';
import '../repositories/learner_storage.dart';

final learnerStorageProvider = Provider<ILearnerRepository>((ref) {
  return LearnerStorage();
});

class LearnerProfileController
    extends StateNotifier<AsyncValue<LearnerProfile>> {
  LearnerProfileController(this._storage)
      : super(const AsyncValue.loading()) {
    _load();
  }

  final ILearnerRepository _storage;

  Future<void> _load() async {
    final existing = _storage.load();
    if (existing != null) {
      state = AsyncValue.data(existing);
      return;
    }
    final created = LearnerProfile.create();
    await _storage.save(created);
    state = AsyncValue.data(created);
  }

  Future<void> save(LearnerProfile profile) async {
    await _storage.save(profile);
    state = AsyncValue.data(profile);
  }
}

final learnerProfileProvider =
    StateNotifierProvider<LearnerProfileController, AsyncValue<LearnerProfile>>(
  (ref) => LearnerProfileController(ref.read(learnerStorageProvider)),
);
