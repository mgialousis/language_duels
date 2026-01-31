import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/audio_provider.dart';

class AudioPlayButton extends ConsumerWidget {
  final String text;
  final String languageCode;
  final double size;
  final bool showReplayCost;
  final int replayCost;
  final VoidCallback? onReplay;

  const AudioPlayButton({
    super.key,
    required this.text,
    required this.languageCode,
    this.size = 48,
    this.showReplayCost = false,
    this.replayCost = 2,
    this.onReplay,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioService = ref.watch(audioServiceProvider);
    final isAvailable = audioService.isAvailable;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          enabled: isAvailable,
          label: isAvailable ? 'Play audio' : 'Audio unavailable',
          child: Tooltip(
            message: isAvailable ? 'Play audio' : 'Audio unavailable',
            child: IconButton(
              iconSize: size,
              icon: Icon(
                Icons.volume_up_rounded,
                color:
                    isAvailable ? Theme.of(context).colorScheme.primary : null,
              ),
              onPressed: !isAvailable
                  ? null
                  : () async {
                      onReplay?.call();
                      await audioService.speak(text, languageCode);
                    },
            ),
          ),
        ),
        if (showReplayCost)
          Text(
            '(-$replayCost pts)',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        if (!isAvailable)
          Text(
            'Audio unavailable',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}
