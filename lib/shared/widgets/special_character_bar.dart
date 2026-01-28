import 'package:flutter/material.dart';

class SpecialCharacterBar extends StatelessWidget {
  final String language;
  final ValueChanged<String> onCharacterTap;

  const SpecialCharacterBar({
    super.key,
    required this.language,
    required this.onCharacterTap,
  });

  List<String> get _characters {
    switch (language) {
      case 'el':
        return ['ά', 'έ', 'ή', 'ί', 'ό', 'ύ', 'ώ', 'ς'];
      case 'ca':
        return ['à', 'è', 'é', 'í', 'ï', 'ò', 'ó', 'ú', 'ü', 'ç', 'l·l'];
      default:
        return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final characters = _characters;
    if (characters.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: characters
          .map(
            (char) => OutlinedButton(
              onPressed: () => onCharacterTap(char),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(char),
            ),
          )
          .toList(),
    );
  }
}
