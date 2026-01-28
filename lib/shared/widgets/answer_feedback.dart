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
    final Color foreground;
    final Color iconColor;
    if (state == AnswerFeedbackState.correct) {
      background = const Color(0xFFD6F5D6);
      foreground = const Color(0xFF1B5E20);
      iconColor = const Color(0xFF2E7D32);
    } else if (state == AnswerFeedbackState.incorrect) {
      background = const Color(0xFFFFE0E0);
      foreground = const Color(0xFFB71C1C);
      iconColor = const Color(0xFFC62828);
    } else {
      final scheme = Theme.of(context).colorScheme;
      background = scheme.surfaceContainerHighest;
      foreground = scheme.onSurfaceVariant;
      iconColor = scheme.onSurfaceVariant;
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
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: DuelAnimations.fadeScale,
              child: Text(
                message,
                key: ValueKey(message),
                style: TextStyle(color: foreground),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
