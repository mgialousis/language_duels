import '../models/learner_profile.dart';
import '../models/srs_item.dart';
import '../repositories/interfaces.dart';

class MigrationService {
  MigrationService({
    required ILearnerRepository learnerStorage,
    required ISrsRepository srsStorage,
    required IContentRepository contentRepository,
  })  : _learnerStorage = learnerStorage,
        _srsStorage = srsStorage,
        _contentRepository = contentRepository;

  final ILearnerRepository _learnerStorage;
  final ISrsRepository _srsStorage;
  final IContentRepository _contentRepository;

  Future<void> migrateToV2() async {
    final hasProfile = _learnerStorage.hasProfile();
    final hasSrsItems = _srsStorage.loadAll().isNotEmpty;

    if (!hasProfile) {
      final profile = LearnerProfile.create();
      await _learnerStorage.save(profile);
    }

    if (!hasSrsItems) {
      await _initializeSrsItems();
    }
  }

  Future<void> resetSoloData() async {
    await _learnerStorage.clear();
    await _srsStorage.clear();
    await migrateToV2();
  }

  Future<void> _initializeSrsItems() async {
    final deckInfos = await _contentRepository.listDecks();
    final items = <SRSItem>[];
    for (final info in deckInfos) {
      final deck = await _contentRepository.loadDeck(info.id);
      for (final item in deck.items) {
        items.add(SRSItem.newItem(item.id, info.id));
      }
    }
    if (items.isNotEmpty) {
      await _srsStorage.saveAll(items);
    }
  }
}
