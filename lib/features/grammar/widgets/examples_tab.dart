import 'package:flutter/material.dart';

import '../../../data/models/grammar_lesson.dart';
import 'grammar_example_card.dart';

class ExamplesTab extends StatelessWidget {
  const ExamplesTab({
    super.key,
    required this.examples,
    required this.showRomanization,
  });

  final List<GrammarExample> examples;
  final bool showRomanization;

  @override
  Widget build(BuildContext context) {
    if (examples.isEmpty) {
      return const Center(child: Text('No examples yet.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: examples.length,
      separatorBuilder: (_, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final example = examples[index];
        return GrammarExampleCard(
          example: example,
          showRomanization: showRomanization,
        );
      },
    );
  }
}
