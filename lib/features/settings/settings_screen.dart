import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/content_provider.dart';
import '../../data/providers/learner_provider.dart';
import '../../data/providers/settings_provider.dart';
import '../../data/providers/solo_history_provider.dart';
import '../../data/providers/srs_provider.dart';
import '../../data/services/migration_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final contentRepository = ref.read(contentRepositoryProvider);
    final learnerStorage = ref.read(learnerStorageProvider);
    final srsStorage = ref.read(srsStorageProvider);
    final soloHistory = ref.read(soloHistoryProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Theme',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('System')),
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (values) {
              controller.setThemeMode(values.first);
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Sound',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Enable sound effects'),
            value: settings.soundEnabled,
            onChanged: controller.setSoundEnabled,
          ),
          const SizedBox(height: 24),
          const Text(
            'Gameplay',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Enable timers (speed bonuses)'),
            subtitle: const Text(
              'Turn off to remove countdowns and keep scores consistent.',
            ),
            value: settings.timersEnabled,
            onChanged: controller.setTimersEnabled,
          ),
          const SizedBox(height: 12),
          const SizedBox(height: 12),
          const Text(
            'Data',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              final shouldClear = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear deck cache?'),
                  content: const Text(
                    'Forces a reload of deck assets on next use.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
              if (shouldClear == true) {
                await contentRepository.clearCache();
                ref.invalidate(deckListProvider);
                ref.invalidate(deckProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Deck cache cleared.'),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.restart_alt),
            label: const Text('Clear deck cache'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final shouldReset = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset solo progress?'),
                  content: const Text(
                    'This clears your solo progress, SRS data, and solo history.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
              if (shouldReset == true) {
                await soloHistory.clear();
                await MigrationService(
                  learnerStorage: learnerStorage,
                  srsStorage: srsStorage,
                  contentRepository: contentRepository,
                ).resetSoloData();
                ref.invalidate(learnerProfileProvider);
                ref.invalidate(srsItemsProvider);
                ref.invalidate(deckListProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Solo progress reset.')),
                  );
                }
              }
            },
            icon: const Icon(Icons.delete_forever),
            label: const Text('Reset solo progress'),
          ),
        ],
      ),
    );
  }
}
