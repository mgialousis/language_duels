import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'models/deck_progress.dart';
import 'models/learner_profile.dart';
import 'models/match_record.dart';
import 'models/settings_state.dart';
import 'models/solo_session_summary.dart';
import 'models/srs_item.dart';
import 'models/grammar_progress.dart';
import 'models/player.dart';

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

class DeckProgressAdapter extends TypeAdapter<DeckProgress> {
  @override
  final int typeId = 20;

  @override
  DeckProgress read(BinaryReader reader) {
    final deckId = reader.readString();
    final itemsSeen = reader.readInt();
    final itemsMastered = reader.readInt();
    final totalItems = reader.readInt();
    final correctCount = reader.readInt();
    final totalAttempts = reader.readInt();
    final lastPracticedRaw = reader.readString();
    final lastPracticed =
        lastPracticedRaw.isEmpty ? null : DateTime.parse(lastPracticedRaw);
    return DeckProgress(
      deckId: deckId,
      itemsSeen: itemsSeen,
      itemsMastered: itemsMastered,
      totalItems: totalItems,
      correctCount: correctCount,
      totalAttempts: totalAttempts,
      lastPracticed: lastPracticed,
    );
  }

  @override
  void write(BinaryWriter writer, DeckProgress obj) {
    writer.writeString(obj.deckId);
    writer.writeInt(obj.itemsSeen);
    writer.writeInt(obj.itemsMastered);
    writer.writeInt(obj.totalItems);
    writer.writeInt(obj.correctCount);
    writer.writeInt(obj.totalAttempts);
    writer.writeString(obj.lastPracticed?.toIso8601String() ?? '');
  }
}

class LearnerProfileAdapter extends TypeAdapter<LearnerProfile> {
  @override
  final int typeId = 21;

  @override
  LearnerProfile read(BinaryReader reader) {
    final ownerId = reader.readString();
    final createdAt = DateTime.parse(reader.readString());
    final totalReviews = reader.readInt();
    final currentStreak = reader.readInt();
    final lastPracticeRaw = reader.readString();
    final lastPracticeDate =
        lastPracticeRaw.isEmpty ? null : DateTime.parse(lastPracticeRaw);
    final longestStreak = reader.readInt();
    final progressCount = reader.readInt();
    final progress = <String, DeckProgress>{};
    for (var i = 0; i < progressCount; i += 1) {
      final key = reader.readString();
      final value = reader.read() as DeckProgress;
      progress[key] = value;
    }
    return LearnerProfile(
      ownerId: ownerId,
      createdAt: createdAt,
      totalReviews: totalReviews,
      currentStreak: currentStreak,
      lastPracticeDate: lastPracticeDate,
      longestStreak: longestStreak,
      deckProgress: progress,
    );
  }

  @override
  void write(BinaryWriter writer, LearnerProfile obj) {
    writer.writeString(obj.ownerId);
    writer.writeString(obj.createdAt.toIso8601String());
    writer.writeInt(obj.totalReviews);
    writer.writeInt(obj.currentStreak);
    writer.writeString(obj.lastPracticeDate?.toIso8601String() ?? '');
    writer.writeInt(obj.longestStreak);
    writer.writeInt(obj.deckProgress.length);
    obj.deckProgress.forEach((key, value) {
      writer.writeString(key);
      writer.write(value);
    });
  }
}

class SrsStateAdapter extends TypeAdapter<SRSState> {
  @override
  final int typeId = 22;

  @override
  SRSState read(BinaryReader reader) {
    return SRSState.values[reader.readInt()];
  }

  @override
  void write(BinaryWriter writer, SRSState obj) {
    writer.writeInt(obj.index);
  }
}

class SrsItemAdapter extends TypeAdapter<SRSItem> {
  @override
  final int typeId = 23;

  @override
  SRSItem read(BinaryReader reader) {
    final itemId = reader.readString();
    final deckId = reader.readString();
    final repetitions = reader.readInt();
    final easeFactor = reader.readDouble();
    final intervalDays = reader.readInt();
    final nextReviewDate = DateTime.parse(reader.readString());
    final lastReviewDate = DateTime.parse(reader.readString());
    final totalReviews = reader.readInt();
    final correctReviews = reader.readInt();
    final state = reader.read() as SRSState;
    final wrongStreak = reader.readInt();
    final resetCount = reader.readInt();
    return SRSItem(
      itemId: itemId,
      deckId: deckId,
      repetitions: repetitions,
      easeFactor: easeFactor,
      intervalDays: intervalDays,
      nextReviewDate: nextReviewDate,
      lastReviewDate: lastReviewDate,
      totalReviews: totalReviews,
      correctReviews: correctReviews,
      state: state,
      wrongStreak: wrongStreak,
      resetCount: resetCount,
    );
  }

  @override
  void write(BinaryWriter writer, SRSItem obj) {
    writer.writeString(obj.itemId);
    writer.writeString(obj.deckId);
    writer.writeInt(obj.repetitions);
    writer.writeDouble(obj.easeFactor);
    writer.writeInt(obj.intervalDays);
    writer.writeString(obj.nextReviewDate.toIso8601String());
    writer.writeString(obj.lastReviewDate.toIso8601String());
    writer.writeInt(obj.totalReviews);
    writer.writeInt(obj.correctReviews);
    writer.write(obj.state);
    writer.writeInt(obj.wrongStreak);
    writer.writeInt(obj.resetCount);
  }
}

class SoloModeAdapter extends TypeAdapter<SoloMode> {
  @override
  final int typeId = 24;

  @override
  SoloMode read(BinaryReader reader) {
    return SoloMode.values[reader.readInt()];
  }

  @override
  void write(BinaryWriter writer, SoloMode obj) {
    writer.writeInt(obj.index);
  }
}

class SoloGameTypeAdapter extends TypeAdapter<SoloGameType> {
  @override
  final int typeId = 25;

  @override
  SoloGameType read(BinaryReader reader) {
    return SoloGameType.values[reader.readInt()];
  }

  @override
  void write(BinaryWriter writer, SoloGameType obj) {
    writer.writeInt(obj.index);
  }
}

class SoloSessionSummaryAdapter extends TypeAdapter<SoloSessionSummary> {
  @override
  final int typeId = 26;

  @override
  SoloSessionSummary read(BinaryReader reader) {
    final id = reader.readString();
    final deckId = reader.readString();
    final mode = reader.read() as SoloMode;
    final gameType = reader.read() as SoloGameType;
    final timerEnabled = reader.readBool();
    final direction = LanguageDirection.values[reader.readInt()];
    final startedAt = DateTime.parse(reader.readString());
    final durationSeconds = reader.readInt();
    final totalQuestions = reader.readInt();
    final correctCount = reader.readInt();
    final score = reader.readInt();
    return SoloSessionSummary(
      id: id,
      deckId: deckId,
      mode: mode,
      gameType: gameType,
      timerEnabled: timerEnabled,
      direction: direction,
      startedAt: startedAt,
      durationSeconds: durationSeconds,
      totalQuestions: totalQuestions,
      correctCount: correctCount,
      score: score,
    );
  }

  @override
  void write(BinaryWriter writer, SoloSessionSummary obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.deckId);
    writer.write(obj.mode);
    writer.write(obj.gameType);
    writer.writeBool(obj.timerEnabled);
    writer.writeInt(obj.direction.index);
    writer.writeString(obj.startedAt.toIso8601String());
    writer.writeInt(obj.durationSeconds);
    writer.writeInt(obj.totalQuestions);
    writer.writeInt(obj.correctCount);
    writer.writeInt(obj.score);
  }
}

class GrammarProgressAdapter extends TypeAdapter<GrammarProgress> {
  @override
  final int typeId = 27;

  @override
  GrammarProgress read(BinaryReader reader) {
    final lessonId = reader.readString();
    final isUnlocked = reader.readBool();
    final explanationRead = reader.readBool();
    final exercisesCompleted = reader.readInt();
    final exercisesTotal = reader.readInt();
    final accuracy = reader.readDouble();
    final lastPracticedRaw = reader.readString();
    final lastPracticed =
        lastPracticedRaw.isEmpty ? null : DateTime.parse(lastPracticedRaw);
    final reviewCount = reader.readInt();
    final masteryIndex = reader.readInt();
    return GrammarProgress(
      lessonId: lessonId,
      isUnlocked: isUnlocked,
      explanationRead: explanationRead,
      exercisesCompleted: exercisesCompleted,
      exercisesTotal: exercisesTotal,
      accuracy: accuracy,
      lastPracticed: lastPracticed,
      reviewCount: reviewCount,
      masteryLevel: GrammarMasteryLevel.values[masteryIndex],
    );
  }

  @override
  void write(BinaryWriter writer, GrammarProgress obj) {
    writer.writeString(obj.lessonId);
    writer.writeBool(obj.isUnlocked);
    writer.writeBool(obj.explanationRead);
    writer.writeInt(obj.exercisesCompleted);
    writer.writeInt(obj.exercisesTotal);
    writer.writeDouble(obj.accuracy);
    writer.writeString(obj.lastPracticed?.toIso8601String() ?? '');
    writer.writeInt(obj.reviewCount);
    writer.writeInt(obj.masteryLevel.index);
  }
}
