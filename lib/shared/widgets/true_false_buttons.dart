import 'package:flutter/material.dart';

class TrueFalseButtons extends StatelessWidget {
  final VoidCallback? onTrue;
  final VoidCallback? onFalse;
  final bool enabled;
  final bool? selectedAnswer;

  const TrueFalseButtons({
    super.key,
    required this.onTrue,
    required this.onFalse,
    this.enabled = true,
    this.selectedAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _AnswerButton(
            label: 'TRUE',
            color: Colors.green,
            onPressed: enabled ? onTrue : null,
            isSelected: selectedAnswer == true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _AnswerButton(
            label: 'FALSE',
            color: Colors.red,
            onPressed: enabled ? onFalse : null,
            isSelected: selectedAnswer == false,
          ),
        ),
      ],
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onPressed;
  final bool isSelected;

  const _AnswerButton({
    required this.label,
    required this.color,
    required this.onPressed,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = isSelected ? color : theme.colorScheme.surface;
    final foregroundColor = isSelected ? Colors.white : color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          side: BorderSide(color: color, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
