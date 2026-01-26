import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);

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
          const Text(
            'Note: Sound effects are not wired yet, but this setting is stored.',
          ),
        ],
      ),
    );
  }
}
