abstract class AudioService {
  bool get isAvailable;
  bool get isPlaying;
  Future<void> speak(String text, String languageCode);
  Future<void> stop();
}

class NullAudioService implements AudioService {
  const NullAudioService();

  @override
  bool get isAvailable => false;

  @override
  bool get isPlaying => false;

  @override
  Future<void> speak(String text, String languageCode) async {}

  @override
  Future<void> stop() async {}
}
