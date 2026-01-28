import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

import '../models/deck.dart';
import 'interfaces.dart';

class ContentRepository implements IContentRepository {
  static const String _cacheBoxName = 'deck_cache';
  static const int _cacheVersion = 1;
  static const String _cacheVersionKey = '__cacheVersion';
  static const Map<String, String> _deckAssets = {
    'greetings': 'assets/data/greetings_deck.json',
    'numbers': 'assets/data/numbers_deck.json',
    'colors': 'assets/data/colors_deck.json',
    'family': 'assets/data/family_deck.json',
    'travel_basics_a1': 'assets/data/travel_basics_a1_deck.json',
    'travel_interactions_a2': 'assets/data/travel_instructions_a2_deck.json',
    'house_cleaning_a2': 'assets/data/house_cleaning_a2_deck.json',
    'house_tools_diy_a2': 'assets/data/house_tools_a2_deck.json',
  };

  Future<Box<dynamic>> _openCacheBox() async {
    if (Hive.isBoxOpen(_cacheBoxName)) {
      final box = Hive.box<dynamic>(_cacheBoxName);
      await _ensureCacheVersion(box);
      return box;
    }
    final box = await Hive.openBox<dynamic>(_cacheBoxName);
    await _ensureCacheVersion(box);
    return box;
  }

  Future<void> _ensureCacheVersion(Box<dynamic> box) async {
    final cachedVersion = box.get(_cacheVersionKey) as int?;
    if (cachedVersion != _cacheVersion) {
      await box.clear();
      await box.put(_cacheVersionKey, _cacheVersion);
    }
  }

  Future<Map<String, dynamic>> _loadDeckMap(String deckId) async {
    final asset = _deckAssets[deckId] ?? _deckAssets['greetings']!;
    final cache = await _openCacheBox();
    final cached = cache.get(deckId);
    if (cached is Map) {
      return cached.cast<String, dynamic>();
    }
    final jsonString = await rootBundle.loadString(asset);
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    await cache.put(deckId, jsonMap);
    return jsonMap;
  }

  @override
  Future<Deck> loadDeck(String deckId) async {
    final jsonMap = await _loadDeckMap(deckId);
    return Deck.fromJson(jsonMap);
  }

  @override
  Future<List<DeckInfo>> listDecks() async {
    final decks = <DeckInfo>[];
    for (final id in _deckAssets.keys) {
      try {
        final jsonMap = await _loadDeckMap(id);
        final deckJson = jsonMap['deck'];
        final info = deckJson is Map
            ? DeckInfo.fromJson(deckJson.cast<String, dynamic>())
            : DeckInfo.fromRoot(jsonMap);
        decks.add(info);
      } catch (_) {
        continue;
      }
    }
    if (decks.isEmpty) {
      throw StateError('No valid decks loaded.');
    }
    return decks;
  }

  @override
  Future<void> clearCache() async {
    final box = await _openCacheBox();
    await box.clear();
    await box.put(_cacheVersionKey, _cacheVersion);
  }
}
