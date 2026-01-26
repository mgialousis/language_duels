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

    final nextGameLabel = session.currentGame == GameType.vocab
        ? 'Vocab Flash Duel'
        : 'Phrase Builder';
    final nextRoute = session.currentGame == GameType.vocab
        ? vocabRoute
        : phraseRoute;

    return Scaffold(
      appBar: AppBar(title: const Text('Duel Hub')),
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
              session.currentGame == GameType.vocab
                  ? 'Round 1 of 2'
                  : 'Round 2 of 2',
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
