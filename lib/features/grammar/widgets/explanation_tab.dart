import 'package:flutter/material.dart';

import '../../../data/models/grammar_lesson.dart';

class ExplanationTab extends StatelessWidget {
  const ExplanationTab({super.key, required this.lesson});

  final GrammarLesson lesson;

  @override
  Widget build(BuildContext context) {
    final explanation = lesson.explanation;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          explanation.content.defaultText,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Text('Key Rules', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        for (final rule in explanation.rules)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• '),
                Expanded(child: Text(rule.defaultText)),
              ],
            ),
          ),
        if (explanation.tips != null && explanation.tips!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Tips', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          for (final tip in explanation.tips!)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(child: Text(tip.defaultText)),
                ],
              ),
            ),
        ],
        if (explanation.commonMistakes != null &&
            explanation.commonMistakes!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Common Mistakes',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          for (final mistake in explanation.commonMistakes!)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(child: Text(mistake.defaultText)),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
