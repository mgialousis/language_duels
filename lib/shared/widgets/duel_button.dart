import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/settings_provider.dart';
import '../../data/providers/sound_provider.dart';

class DuelButton extends ConsumerWidget {
  final String label;
  final VoidCallback? onPressed;

  const DuelButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (onPressed == null) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Text(label),
        ),
      );
    }

    final soundEnabled =
        ref.watch(settingsProvider.select((state) => state.soundEnabled));
    final soundService = ref.read(soundProvider);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          soundService.playTap(soundEnabled);
          onPressed?.call();
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(label),
      ),
    );
  }
}
