import 'package:flutter/material.dart';
import 'package:riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';

import '../models/settings_state.dart';
import '../repositories/interfaces.dart';
import '../repositories/settings_storage.dart';

final settingsStorageProvider = Provider<ISettingsRepository>((ref) {
  return SettingsStorage();
});

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController(this._storage) : super(SettingsState.defaults) {
    _load();
  }

  final ISettingsRepository _storage;

  Future<void> _load() async {
    state = _storage.load();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _storage.save(state);
  }

  Future<void> setSoundEnabled(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
    await _storage.save(state);
  }

  Future<void> setTimersEnabled(bool enabled) async {
    state = state.copyWith(timersEnabled: enabled);
    await _storage.save(state);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) {
      return SettingsController(ref.read(settingsStorageProvider));
    });
