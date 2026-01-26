import 'package:flutter/services.dart';

class SoundService {
  const SoundService();

  void playTap(bool enabled) {
    if (!enabled) return;
    SystemSound.play(SystemSoundType.click);
  }

  void playSuccess(bool enabled) {
    if (!enabled) return;
    SystemSound.play(SystemSoundType.alert);
  }

  void playError(bool enabled) {
    if (!enabled) return;
    SystemSound.play(SystemSoundType.alert);
  }
}
