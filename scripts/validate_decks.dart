import 'dart:convert';
import 'dart:io';

void main() {
  final dataDir = Directory('assets/data');
  if (!dataDir.existsSync()) {
    stderr.writeln('assets/data not found.');
    exit(1);
  }

  var hasErrors = false;
  for (final file in dataDir.listSync().whereType<File>()) {
    if (!file.path.endsWith('.json')) continue;
    final jsonData = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final errors = <String>[];

    void requireField(String key) {
      if (!jsonData.containsKey(key)) {
        errors.add('Missing deck field: $key');
      }
    }

    requireField('deckId');
    requireField('deckName');
    requireField('level');
    requireField('items');

    final items = (jsonData['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();
    for (final item in items) {
      for (final key in ['id', 'type', 'category', 'difficulty', 'greek', 'catalan']) {
        if (!item.containsKey(key)) {
          errors.add('Item ${item['id'] ?? '(unknown)'} missing field: $key');
        }
      }
      final greek = item['greek'] as Map<String, dynamic>? ?? {};
      if (greek['romanization'] == null || greek['phonetic'] == null) {
        errors.add('Item ${item['id']} missing greek romanization/phonetic');
      }
      final catalan = item['catalan'] as Map<String, dynamic>? ?? {};
      if (catalan['phonetic'] == null) {
        errors.add('Item ${item['id']} missing catalan phonetic');
      }
      if (item['type'] == 'phrase' && item['wordBreakdown'] == null) {
        errors.add('Phrase ${item['id']} missing wordBreakdown');
      }
    }

    if (errors.isNotEmpty) {
      hasErrors = true;
      stdout.writeln('Errors in ${file.path}:');
      for (final err in errors) {
        stdout.writeln('  - $err');
      }
    }
  }

  if (hasErrors) {
    exit(1);
  }
  stdout.writeln('All decks passed validation.');
}
