import 'package:flutter/material.dart';

enum MatchTileState { idle, selected, matched, wrong }

class MatchTile extends StatelessWidget {
  final String text;
  final MatchTileState state;
  final VoidCallback? onTap;

  const MatchTile({
    super.key,
    required this.text,
    required this.state,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final backgroundColor = switch (state) {
      MatchTileState.selected =>
          colors.primary.withAlpha((0.12 * 255).round()),
      MatchTileState.matched => colors.surfaceContainerHighest,
      MatchTileState.wrong => colors.error.withAlpha((0.12 * 255).round()),
      MatchTileState.idle => colors.surface,
    };
    final borderColor = switch (state) {
      MatchTileState.selected => colors.primary,
      MatchTileState.matched => colors.outline,
      MatchTileState.wrong => colors.error,
      MatchTileState.idle => colors.outlineVariant,
    };
    final textColor = state == MatchTileState.matched
        ? colors.onSurfaceVariant
        : colors.onSurface;

    final stateLabel = switch (state) {
      MatchTileState.selected => 'selected',
      MatchTileState.matched => 'matched',
      MatchTileState.wrong => 'wrong',
      MatchTileState.idle => 'idle',
    };

    return Semantics(
      label: '$text, $stateLabel',
      button: onTap != null && state != MatchTileState.matched,
      selected: state == MatchTileState.selected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: state == MatchTileState.selected
              ? [
                  BoxShadow(
                    color: colors.primary.withAlpha((0.2 * 255).round()),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: state == MatchTileState.matched ? null : onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
