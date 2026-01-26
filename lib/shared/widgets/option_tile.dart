import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/settings_provider.dart';
import '../../data/providers/sound_provider.dart';

class OptionTile extends ConsumerWidget {
  final String label;
  final VoidCallback? onPressed;

  const OptionTile({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soundEnabled =
        ref.watch(settingsProvider.select((state) => state.soundEnabled));
    final soundService = ref.read(soundProvider);

    return Semantics(
      label: 'Option: $label',
      button: true,
      child: OutlinedButton(
        onPressed: onPressed == null
            ? null
            : () {
                soundService.playTap(soundEnabled);
                onPressed?.call();
              },
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}
