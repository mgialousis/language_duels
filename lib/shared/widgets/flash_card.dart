import 'package:flutter/material.dart';

class FlashCard extends StatelessWidget {
  final String text;
  final String? romanization;
  final String? phonetic;

  const FlashCard({
    super.key,
    required this.text,
    this.romanization,
    this.phonetic,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final subtitle = [
      if (romanization != null) romanization!,
      if (phonetic != null) phonetic!,
    ].join(' • ');

    return Semantics(
      label: subtitle.isEmpty ? 'Prompt: $text' : 'Prompt: $text. $subtitle',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(subtitle, style: textTheme.bodyMedium),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
