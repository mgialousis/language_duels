enum SpellingResult {
  perfect,
  accentError,
  minorError,
  majorError,
  wrong,
}

class SpellingValidator {
  static SpellingResult validate(String userAnswer, String correctAnswer) {
    final normalizedUser = _normalize(userAnswer);
    final normalizedAlternatives = _extractAlternatives(correctAnswer);

    if (normalizedUser.isEmpty) return SpellingResult.wrong;

    var bestResult = SpellingResult.wrong;
    var bestScore = -1;

    for (final normalizedCorrect in normalizedAlternatives) {
      if (normalizedCorrect.isEmpty) continue;
      final result = _compareNormalized(normalizedUser, normalizedCorrect);
      final score = _resultScore(result);
      if (score > bestScore) {
        bestScore = score;
        bestResult = result;
        if (bestResult == SpellingResult.perfect) {
          break;
        }
      }
    }

    return bestResult;
  }

  static String _normalize(String value) {
    return value.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static List<String> _extractAlternatives(String value) {
    final normalized = _normalize(value);
    if (normalized.isEmpty) return const [''];
    final parts =
        normalized.split(RegExp(r'\s*(?:/|,|;|\||\bor\b)\s*'));
    final unique = <String>{};
    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.isNotEmpty) unique.add(trimmed);
    }
    return unique.isEmpty ? const [''] : unique.toList();
  }

  static SpellingResult _compareNormalized(
    String normalizedUser,
    String normalizedCorrect,
  ) {
    if (normalizedUser == normalizedCorrect) {
      return SpellingResult.perfect;
    }

    final userNoAccents = _removeAccents(normalizedUser);
    final correctNoAccents = _removeAccents(normalizedCorrect);

    if (userNoAccents == correctNoAccents) {
      return SpellingResult.accentError;
    }

    final distance = _levenshteinDistance(normalizedUser, normalizedCorrect);
    final similarity = 1 - (distance / normalizedCorrect.length);

    if (similarity >= 0.8) {
      return SpellingResult.minorError;
    } else if (similarity >= 0.5) {
      return SpellingResult.majorError;
    }
    return SpellingResult.wrong;
  }

  static int _resultScore(SpellingResult result) {
    return switch (result) {
      SpellingResult.perfect => 4,
      SpellingResult.accentError => 3,
      SpellingResult.minorError => 2,
      SpellingResult.majorError => 1,
      SpellingResult.wrong => 0,
    };
  }

  static String _removeAccents(String value) {
    const accentMap = {
      'á': 'a',
      'à': 'a',
      'â': 'a',
      'ä': 'a',
      'ã': 'a',
      'å': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'í': 'i',
      'ì': 'i',
      'î': 'i',
      'ï': 'i',
      'ó': 'o',
      'ò': 'o',
      'ô': 'o',
      'ö': 'o',
      'õ': 'o',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ñ': 'n',
      'ç': 'c',
      'ά': 'α',
      'έ': 'ε',
      'ή': 'η',
      'ί': 'ι',
      'ό': 'ο',
      'ύ': 'υ',
      'ώ': 'ω',
      'ϊ': 'ι',
      'ΐ': 'ι',
      'ϋ': 'υ',
      'ΰ': 'υ',
    };

    final buffer = StringBuffer();
    for (final rune in value.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(accentMap[char] ?? char);
    }
    return buffer.toString();
  }

  static int _levenshteinDistance(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final dp = List.generate(
      a.length + 1,
      (_) => List<int>.filled(b.length + 1, 0),
    );

    for (var i = 0; i <= a.length; i++) {
      dp[i][0] = i;
    }
    for (var j = 0; j <= b.length; j++) {
      dp[0][j] = j;
    }

    for (var i = 1; i <= a.length; i++) {
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        dp[i][j] = [
          dp[i - 1][j] + 1,
          dp[i][j - 1] + 1,
          dp[i - 1][j - 1] + cost,
        ].reduce((value, element) => value < element ? value : element);
      }
    }

    return dp[a.length][b.length];
  }
}
