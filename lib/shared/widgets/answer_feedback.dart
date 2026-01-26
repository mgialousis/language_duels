import 'package:flutter/material.dart';

import '../animations/duel_animations.dart';

enum AnswerFeedbackState { neutral, correct, incorrect }

class AnswerFeedback extends StatelessWidget {
  final String message;
  final AnswerFeedbackState state;

  const AnswerFeedback({super.key, required this.message, required this.state});

  @override
  Widget build(BuildContext context) {
    final Color background;
    if (state == AnswerFeedbackState.correct) {
      background = const Color(0xFFD6F5D6);
    } else if (state == AnswerFeedbackState.incorrect) {
      background = const Color(0xFFFFE0E0);
    } else {
      background = const Color(0xFFEFF2F5);
    }

    final icon = state == AnswerFeedbackState.correct
        ? Icons.check_circle
        : (state == AnswerFeedbackState.incorrect ? Icons.cancel : Icons.info);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 8),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: DuelAnimations.fadeScale,
              child: Text(message, key: ValueKey(message)),
            ),
          ),
        ],
      ),
    );
  }
}
