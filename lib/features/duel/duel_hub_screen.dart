import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../data/providers/game_session_provider.dart';
import '../../shared/widgets/duel_button.dart';
import '../../shared/widgets/score_board.dart';

class DuelHubScreen extends ConsumerWidget {
  const DuelHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(gameSessionProvider);

    final nextGameLabel = switch (session.currentGame) {
      GameType.vocab => 'Vocab Flash Duel',
      GameType.phrase => 'Phrase Builder',
      GameType.speedRound => 'Speed Round',
      GameType.matchMadness => 'Match Madness',
      GameType.spellingBee => 'Spelling Bee',
      GameType.listening => 'Listening Challenge',
    };
    final nextRoute = switch (session.currentGame) {
      GameType.vocab => vocabRoute,
      GameType.phrase => phraseRoute,
      GameType.speedRound => speedRoundRoute,
      GameType.matchMadness => matchMadnessRoute,
      GameType.spellingBee => spellingBeeRoute,
      GameType.listening => listeningRoute,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Duel Hub'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Change deck',
          onPressed: () => _confirmExit(context, ref),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScoreBoard(
              playerOne: session.playerOneName,
              playerTwo: session.playerTwoName,
              playerOneScore: session.playerOneScore,
              playerTwoScore: session.playerTwoScore,
            ),
            const SizedBox(height: 16),
            Text(
              'Round ${session.currentGameIndex + 1} of ${session.gameOrder.length}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Current player: ${session.currentPlayer == 1 ? session.playerOneName : session.playerTwoName}',
            ),
            const SizedBox(height: 8),
            Text('Next: $nextGameLabel'),
            const Spacer(),
            DuelButton(
              label: 'Start $nextGameLabel',
              onPressed: session.status == SessionStatus.inProgress
                  ? () => context.go(nextRoute)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _confirmExit(BuildContext context, WidgetRef ref) async {
  final shouldExit = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Change deck?'),
      content: const Text(
        'This will reset the current duel setup.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Change deck'),
        ),
      ],
    ),
  );
  if (shouldExit == true && context.mounted) {
    ref.read(gameSessionProvider.notifier).reset();
    context.go(deckRoute);
  }
}
