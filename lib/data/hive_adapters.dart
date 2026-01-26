import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'models/match_record.dart';
import 'models/settings_state.dart';

class SettingsStateAdapter extends TypeAdapter<SettingsState> {
  @override
  final int typeId = 1;

  @override
  SettingsState read(BinaryReader reader) {
    final themeIndex = reader.readInt();
    final soundEnabled = reader.readBool();
    final timersEnabled = reader.readBool();
    return SettingsState(
      themeMode: ThemeMode.values[themeIndex],
      soundEnabled: soundEnabled,
      timersEnabled: timersEnabled,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsState obj) {
    writer.writeInt(obj.themeMode.index);
    writer.writeBool(obj.soundEnabled);
    writer.writeBool(obj.timersEnabled);
  }
}

class MatchRecordAdapter extends TypeAdapter<MatchRecord> {
  @override
  final int typeId = 2;

  @override
  MatchRecord read(BinaryReader reader) {
    final id = reader.readString();
    final playerOneName = reader.readString();
    final playerTwoName = reader.readString();
    final playerOneScore = reader.readInt();
    final playerTwoScore = reader.readInt();
    final playedAt = DateTime.parse(reader.readString());
    return MatchRecord(
      id: id,
      playerOneName: playerOneName,
      playerTwoName: playerTwoName,
      playerOneScore: playerOneScore,
      playerTwoScore: playerTwoScore,
      playedAt: playedAt,
    );
  }

  @override
  void write(BinaryWriter writer, MatchRecord obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.playerOneName);
    writer.writeString(obj.playerTwoName);
    writer.writeInt(obj.playerOneScore);
    writer.writeInt(obj.playerTwoScore);
    writer.writeString(obj.playedAt.toIso8601String());
  }
}
