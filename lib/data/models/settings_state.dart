import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final bool soundEnabled;
  final bool timersEnabled;

  const SettingsState({
    required this.themeMode,
    required this.soundEnabled,
    required this.timersEnabled,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? soundEnabled,
    bool? timersEnabled,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      timersEnabled: timersEnabled ?? this.timersEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.name,
      'soundEnabled': soundEnabled,
      'timersEnabled': timersEnabled,
    };
  }

  factory SettingsState.fromJson(Map<String, dynamic> json) {
    return SettingsState(
      themeMode: ThemeMode.values.byName(json['themeMode'] as String),
      soundEnabled: json['soundEnabled'] as bool,
      timersEnabled: (json['timersEnabled'] as bool?) ?? true,
    );
  }

  static const defaults = SettingsState(
    themeMode: ThemeMode.system,
    soundEnabled: true,
    timersEnabled: true,
  );

  @override
  List<Object?> get props => [themeMode, soundEnabled, timersEnabled];
}
