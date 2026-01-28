import 'package:flutter_test/flutter_test.dart';
import 'package:language_duels/features/games/spelling_bee/spelling_validator.dart';

void main() {
  test('SpellingValidator detects perfect answers', () {
    final result = SpellingValidator.validate('Bon dia', 'Bon dia');
    expect(result, SpellingResult.perfect);
  });

  test('SpellingValidator detects accent errors', () {
    final result = SpellingValidator.validate('Adeu', 'Adéu');
    expect(result, SpellingResult.accentError);
  });

  test('SpellingValidator detects wrong answers', () {
    final result = SpellingValidator.validate('Hola', 'Adeu');
    expect(result, SpellingResult.wrong);
  });

  test('SpellingValidator is case insensitive', () {
    final result = SpellingValidator.validate('bOn dIa', 'Bon Dia');
    expect(result, SpellingResult.perfect);
  });

  test('SpellingValidator accepts multiple correct answers', () {
    final result = SpellingValidator.validate('Bona tarda', 'Bona tarda, bona vespre');
    expect(result, SpellingResult.perfect);
  });

  test('SpellingValidator accepts alternative via slash', () {
    final result = SpellingValidator.validate('Benviguts', 'Benviguts / Benvigut');
    expect(result, SpellingResult.perfect);
  });
}
