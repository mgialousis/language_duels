import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/settings_provider.dart';
import '../../data/providers/sound_provider.dart';

class SubmitBar extends ConsumerWidget {
  final bool hintEnabled;
  final VoidCallback? onHint;
  final bool submitEnabled;
  final VoidCallback? onSubmit;

  const SubmitBar({
    super.key,
    required this.hintEnabled,
    required this.onHint,
    required this.submitEnabled,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soundEnabled =
        ref.watch(settingsProvider.select((state) => state.soundEnabled));
    final soundService = ref.read(soundProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: hintEnabled
              ? () {
                  soundService.playTap(soundEnabled);
                  onHint?.call();
                }
              : null,
          icon: const Icon(Icons.lightbulb_outline),
          label: const Text('Show first word (-3 pts)'),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: submitEnabled
                ? () {
                    soundService.playTap(soundEnabled);
                    onSubmit?.call();
                  }
                : null,
            child: const Text('Submit'),
          ),
        ),
      ],
    );
  }
}
