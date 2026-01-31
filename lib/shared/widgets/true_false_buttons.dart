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
    final textStyle = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(fontWeight: FontWeight.w700);
    return Row(
      children: [
        Expanded(
          child: _AnswerButton(
            label: 'TRUE',
            color: Colors.green,
            onPressed: enabled ? onTrue : null,
            isSelected: selectedAnswer == true,
            textStyle: textStyle,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _AnswerButton(
            label: 'FALSE',
            color: Colors.red,
            onPressed: enabled ? onFalse : null,
            isSelected: selectedAnswer == false,
            textStyle: textStyle,
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
  final TextStyle? textStyle;

  const _AnswerButton({
    required this.label,
    required this.color,
    required this.onPressed,
    required this.isSelected,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = isSelected ? color : theme.colorScheme.surface;
    final foregroundColor = isSelected ? Colors.white : color;

    return Semantics(
      button: true,
      enabled: onPressed != null,
      selected: isSelected,
      label: label,
      child: AnimatedContainer(
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
          child: Text(label, style: textStyle),
        ),
      ),
    );
  }
}
