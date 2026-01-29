import '../models/srs_item.dart';

const String grammarDeckId = 'grammar';

String grammarItemId(String lessonId) => '$grammarDeckId:$lessonId';

String? lessonIdFromGrammarItemId(String itemId) {
  if (!itemId.startsWith('$grammarDeckId:')) return null;
  final lessonId = itemId.substring(grammarDeckId.length + 1);
  return lessonId.isEmpty ? null : lessonId;
}

bool isGrammarSrsItem(SRSItem item) => item.deckId == grammarDeckId;

String? grammarLessonIdFromItem(SRSItem item) {
  if (!isGrammarSrsItem(item)) return null;
  final parsed = lessonIdFromGrammarItemId(item.itemId);
  if (parsed != null) return parsed;
  return item.itemId.isEmpty ? null : item.itemId;
}
