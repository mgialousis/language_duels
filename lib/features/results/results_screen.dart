import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../data/providers/game_session_provider.dart';
import '../../data/providers/history_provider.dart';
import '../../shared/widgets/duel_button.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(gameSessionProvider);
    final isTie = session.playerOneScore == session.playerTwoScore;
    final winner = session.playerOneScore > session.playerTwoScore
        ? session.playerOneName
        : session.playerTwoName;

    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ResultBanner(isTie: isTie, winner: winner),
            const SizedBox(height: 16),
            _ScoreComparison(
              playerOneName: session.playerOneName,
              playerTwoName: session.playerTwoName,
              playerOneScore: session.playerOneScore,
              playerTwoScore: session.playerTwoScore,
              isTie: isTie,
            ),
            const SizedBox(height: 16),
            const Text(
              'Score Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ..._buildBreakdownRows(session),
            const Spacer(),
            DuelButton(
              label: 'Play Again',
              onPressed: () {
                ref.read(gameSessionProvider.notifier).reset();
                context.go(deckRoute);
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => _confirmClearHistory(context, ref),
              child: const Text('Clear Match History'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.go(homeRoute),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _confirmClearHistory(BuildContext context, WidgetRef ref) async {
  final shouldClear = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Clear match history?'),
      content: const Text('This will remove all saved matches.'),
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
    await ref.read(historyProvider.notifier).clear();
  }
}

List<Widget> _buildBreakdownRows(GameSessionState session) {
  final rows = <Widget>[];
  for (final game in session.gameOrder) {
    switch (game) {
      case GameType.vocab:
        rows.add(
          _BreakdownRow(
            label: 'Vocab Flash Duel',
            playerOneScore: session.vocabPlayerOneScore,
            playerTwoScore: session.vocabPlayerTwoScore,
            playerOneName: session.playerOneName,
            playerTwoName: session.playerTwoName,
          ),
        );
      case GameType.phrase:
        rows.add(
          _BreakdownRow(
            label: 'Phrase Builder',
            playerOneScore: session.phrasePlayerOneScore,
            playerTwoScore: session.phrasePlayerTwoScore,
            playerOneName: session.playerOneName,
            playerTwoName: session.playerTwoName,
          ),
        );
      case GameType.speedRound:
        rows.add(
          _BreakdownRow(
            label: 'Speed Round',
            playerOneScore: session.speedRoundPlayerOneScore,
            playerTwoScore: session.speedRoundPlayerTwoScore,
            playerOneName: session.playerOneName,
            playerTwoName: session.playerTwoName,
          ),
        );
      case GameType.matchMadness:
        rows.add(
          _BreakdownRow(
            label: 'Match Madness',
            playerOneScore: session.matchMadnessPlayerOneScore,
            playerTwoScore: session.matchMadnessPlayerTwoScore,
            playerOneName: session.playerOneName,
            playerTwoName: session.playerTwoName,
          ),
        );
      case GameType.spellingBee:
        rows.add(
          _BreakdownRow(
            label: 'Spelling Bee',
            playerOneScore: session.spellingBeePlayerOneScore,
            playerTwoScore: session.spellingBeePlayerTwoScore,
            playerOneName: session.playerOneName,
            playerTwoName: session.playerTwoName,
          ),
        );
      case GameType.listening:
        rows.add(
          _BreakdownRow(
            label: 'Listening Challenge',
            playerOneScore: session.listeningPlayerOneScore,
            playerTwoScore: session.listeningPlayerTwoScore,
            playerOneName: session.playerOneName,
            playerTwoName: session.playerTwoName,
          ),
        );
    }
  }

  return [
    for (var i = 0; i < rows.length; i++) ...[
      rows[i],
      if (i != rows.length - 1) const SizedBox(height: 8),
    ],
  ];
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({required this.isTie, required this.winner});

  final bool isTie;
  final String winner;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isTie ? Icons.handshake_rounded : Icons.emoji_events_rounded,
              size: 40,
              color: isTie ? Colors.orange : Colors.amber,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isTie ? "It's a tie!" : 'Winner: $winner',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreComparison extends StatelessWidget {
  const _ScoreComparison({
    required this.playerOneName,
    required this.playerTwoName,
    required this.playerOneScore,
    required this.playerTwoScore,
    required this.isTie,
  });

  final String playerOneName;
  final String playerTwoName;
  final int playerOneScore;
  final int playerTwoScore;
  final bool isTie;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _ScoreTile(
                name: playerOneName,
                score: playerOneScore,
                isWinner: !isTie && playerOneScore > playerTwoScore,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('VS', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            Expanded(
              child: _ScoreTile(
                name: playerTwoName,
                score: playerTwoScore,
                isWinner: !isTie && playerTwoScore > playerOneScore,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreTile extends StatelessWidget {
  const _ScoreTile({
    required this.name,
    required this.score,
    required this.isWinner,
  });

  final String name;
  final int score;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(
          '$score',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: isWinner ? Colors.green : null,
          ),
        ),
        if (isWinner)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text('WINNER', style: TextStyle(fontSize: 12)),
          ),
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    required this.playerOneScore,
    required this.playerTwoScore,
    required this.playerOneName,
    required this.playerTwoName,
  });

  final String label;
  final int playerOneScore;
  final int playerTwoScore;
  final String playerOneName;
  final String playerTwoName;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$playerOneName: $playerOneScore'),
                Text('$playerTwoName: $playerTwoScore'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
