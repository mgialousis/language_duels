import 'package:equatable/equatable.dart';

class MatchRecord extends Equatable {
  final String id;
  final String playerOneName;
  final String playerTwoName;
  final int playerOneScore;
  final int playerTwoScore;
  final DateTime playedAt;

  const MatchRecord({
    required this.id,
    required this.playerOneName,
    required this.playerTwoName,
    required this.playerOneScore,
    required this.playerTwoScore,
    required this.playedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'playerOneName': playerOneName,
      'playerTwoName': playerTwoName,
      'playerOneScore': playerOneScore,
      'playerTwoScore': playerTwoScore,
      'playedAt': playedAt.toIso8601String(),
    };
  }

  factory MatchRecord.fromJson(Map<String, dynamic> json) {
    return MatchRecord(
      id: json['id'] as String,
      playerOneName: json['playerOneName'] as String,
      playerTwoName: json['playerTwoName'] as String,
      playerOneScore: json['playerOneScore'] as int,
      playerTwoScore: json['playerTwoScore'] as int,
      playedAt: DateTime.parse(json['playedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        playerOneName,
        playerTwoName,
        playerOneScore,
        playerTwoScore,
        playedAt,
      ];
}
