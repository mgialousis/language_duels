import 'package:equatable/equatable.dart';

import 'content_item.dart';

class LocalizedString extends Equatable {
  final String? en;
  final String? el;
  final String? ca;

  const LocalizedString({this.en, this.el, this.ca});

  factory LocalizedString.fromJson(Map<String, dynamic> json) {
    return LocalizedString(
      en: json['en'] as String?,
      el: json['el'] as String?,
      ca: json['ca'] as String?,
    );
  }

  String get defaultText => en ?? el ?? ca ?? '';

  @override
  List<Object?> get props => [en, el, ca];
}

class DeckInfo extends Equatable {
  final String id;
  final LocalizedString name;
  final LocalizedString description;
  final String level;
  final int itemCount;

  const DeckInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
    required this.itemCount,
  });

  factory DeckInfo.fromJson(Map<String, dynamic> json) {
    return DeckInfo(
      id: json['id'] as String,
      name: LocalizedString.fromJson(json['name'] as Map<String, dynamic>),
      description: LocalizedString.fromJson(
        json['description'] as Map<String, dynamic>,
      ),
      level: json['level'] as String,
      itemCount: json['itemCount'] as int,
    );
  }

  factory DeckInfo.fromRoot(Map<String, dynamic> json) {
    return DeckInfo(
      id: json['deckId'] as String,
      name: LocalizedString.fromJson(
        (json['deckName'] as Map<String, dynamic>?) ?? {},
      ),
      description: LocalizedString.fromJson(
        (json['description'] as Map<String, dynamic>?) ?? {},
      ),
      level: json['level'] as String? ?? 'A1',
      itemCount: (json['itemCount'] as int?) ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, name, description, level, itemCount];
}

class Deck extends Equatable {
  final DeckInfo info;
  final List<ContentItem> items;

  const Deck({required this.info, required this.items});

  List<ContentItem> get vocabularyItems =>
      items.where((item) => !item.isPhrase).toList();

  List<ContentItem> get phraseItems =>
      items.where((item) => item.isPhrase).toList();

  factory Deck.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>;
    final deckJson = json['deck'] as Map<String, dynamic>?;
    return Deck(
      info: deckJson != null ? DeckInfo.fromJson(deckJson) : DeckInfo.fromRoot(json),
      items: itemsJson
          .map((item) => ContentItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [info, items];
}
