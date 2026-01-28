import 'package:flutter/material.dart';

import '../../../data/models/grammar_lesson.dart';

class GrammarExampleCard extends StatelessWidget {
  const GrammarExampleCard({
    super.key,
    required this.example,
    required this.showRomanization,
  });

  final GrammarExample example;
  final bool showRomanization;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highlights = example.highlights ?? const [];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HighlightedText(
              text: example.greek,
              highlights: highlights,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
              highlightColor: theme.colorScheme.tertiaryContainer,
            ),
            if (showRomanization && example.romanization.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                example.romanization,
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 8),
            Text(example.catalan),
            if (example.englishLiteral != null &&
                example.englishLiteral!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                example.englishLiteral!,
                style: theme.textTheme.bodySmall,
              ),
            ],
            if (highlights.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: highlights
                    .where((highlight) => highlight.explanation.isNotEmpty)
                    .map(
                      (highlight) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiaryContainer
                              .withAlpha((0.7 * 255).round()),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          highlight.explanation,
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HighlightedText extends StatelessWidget {
  const _HighlightedText({
    required this.text,
    required this.highlights,
    required this.style,
    required this.highlightColor,
  });

  final String text;
  final List<GrammarHighlight> highlights;
  final TextStyle? style;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    if (highlights.isEmpty || text.isEmpty) {
      return Text(text, style: style);
    }

    final spans = _buildSpans();
    return RichText(
      text: TextSpan(style: style, children: spans),
    );
  }

  List<TextSpan> _buildSpans() {
    final length = text.length;
    final sorted = [...highlights]
      ..sort((a, b) => a.startIndex.compareTo(b.startIndex));

    final spans = <TextSpan>[];
    var cursor = 0;
    for (final highlight in sorted) {
      final start = highlight.startIndex.clamp(0, length);
      final end = highlight.endIndex.clamp(0, length);
      if (start >= end || start < cursor) {
        continue;
      }
      if (cursor < start) {
        spans.add(TextSpan(text: text.substring(cursor, start)));
      }
      spans.add(
        TextSpan(
          text: text.substring(start, end),
          style: TextStyle(
            backgroundColor: highlightColor.withAlpha((0.6 * 255).round()),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
      cursor = end;
    }
    if (cursor < length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }
    return spans;
  }
}
