import 'package:riverpod/riverpod.dart';

import '../../shared/services/sound_service.dart';

final soundProvider = Provider<SoundService>((ref) {
  return const SoundService();
});
