import 'package:riverpod/riverpod.dart';

import '../../shared/services/audio_service.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  return const NullAudioService();
});
