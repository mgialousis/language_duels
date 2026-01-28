import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../data/providers/content_provider.dart';
import '../../data/providers/game_session_provider.dart';
import '../../data/providers/setup_provider.dart';
import '../../shared/widgets/async_state.dart';
import '../../shared/widgets/duel_button.dart';

class MiniGameSelectScreen extends ConsumerWidget {
  const MiniGameSelectScreen({super.key});

  IconData _iconForGame(GameType type) {
    switch (type) {
      case GameType.vocab:
        return Icons.flash_on_rounded;
      case GameType.phrase:
        return Icons.translate_rounded;
      case GameType.speedRound:
        return Icons.timer_rounded;
      case GameType.matchMadness:
        return Icons.grid_on_rounded;
      case GameType.spellingBee:
        return Icons.spellcheck_rounded;
      case GameType.listening:
        return Icons.headphones_rounded;
    }
  }

  String _labelForGame(GameType type) {
    switch (type) {
      case GameType.vocab:
        return 'Vocab Flash';
      case GameType.phrase:
        return 'Phrase Builder';
      case GameType.speedRound:
        return 'Speed Round';
      case GameType.matchMadness:
        return 'Match Madness';
      case GameType.spellingBee:
        return 'Spelling Bee';
      case GameType.listening:
        return 'Listening';
    }
  }

  Future<void> _startDuel(WidgetRef ref, BuildContext context) async {
    final deckAsync = ref.read(deckProvider);
    final deck = deckAsync.isLoading
        ? null
        : deckAsync.value ?? await ref.read(deckProvider.future);

    if (deck == null) return;

    final playerOne = ref.read(playerOneNameProvider);
    final playerTwo = ref.read(playerTwoNameProvider);
    final playerOneDirection = ref.read(playerOneDirectionProvider);
    final playerTwoDirection = ref.read(playerTwoDirectionProvider);
    final selectedGames = ref.read(selectedGameTypesProvider);

    if (selectedGames.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one mini-game.')),
      );
      return;
    }

    ref.read(gameSessionProvider.notifier).startSession(
          deck: deck,
          playerOneName: playerOne,
          playerTwoName: playerTwo,
          playerOneDirection: playerOneDirection,
          playerTwoDirection: playerTwoDirection,
          gameOrder: selectedGames,
        );

    if (!context.mounted) return;
    context.go(duelRoute);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedGames = ref.watch(selectedGameTypesProvider);
    final gameOptions = [
      GameType.vocab,
      GameType.phrase,
      GameType.speedRound,
      GameType.matchMadness,
      GameType.spellingBee,
    ];

    final deckAsync = ref.watch(deckProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mini-games')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            deckAsync.when(
              data: (deck) => Text(
                'Deck: ${deck.info.name.defaultText}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              loading: () => const LoadingState(message: 'Loading deck...'),
              error: (error, _) => ErrorState(
                title: 'Deck unavailable',
                message: 'Go back and reselect your deck.',
                onRetry: () => context.pop(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Select mini-games', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final game in gameOptions)
                  FilterChip(
                    label: Text(_labelForGame(game)),
                    selected: selectedGames.contains(game),
                    onSelected: (value) {
                      final updatedSet = selectedGames.toSet();
                      if (value) {
                        updatedSet.add(game);
                      } else {
                        updatedSet.remove(game);
                      }
                      final updated =
                          gameOptions.where(updatedSet.contains).toList();
                      ref.read(selectedGameTypesProvider.notifier).state =
                          updated;
                    },
                    avatar: Icon(
                      _iconForGame(game),
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    selectedColor: theme.colorScheme.primaryContainer,
                    showCheckmark: false,
                  ),
              ],
            ),
            if (selectedGames.isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Select at least one mini-game.',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
            const Spacer(),
            DuelButton(
              label: 'Start Duel',
              onPressed: () => _startDuel(ref, context),
            ),
          ],
        ),
      ),
    );
  }
}
