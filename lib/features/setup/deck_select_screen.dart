import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../data/providers/content_provider.dart';
import '../../shared/widgets/duel_button.dart';
import '../../shared/widgets/async_state.dart';

class DeckSelectScreen extends ConsumerWidget {
  const DeckSelectScreen({super.key});

  static const List<_LockedDeck> _lockedDecks = [
    _LockedDeck(id: 'food', name: 'Food & Drinks'),
  ];

  IconData _iconForDeck(String id) {
    switch (id) {
      case 'greetings':
        return Icons.waving_hand_rounded;
      case 'numbers':
        return Icons.tag_rounded;
      case 'colors':
        return Icons.palette_rounded;
      case 'family':
        return Icons.family_restroom_rounded;
      case 'travel_basics_a1':
        return Icons.travel_explore_rounded;
      case 'travel_interactions_a2':
        return Icons.airport_shuttle_rounded;
      case 'house_cleaning_a2':
        return Icons.cleaning_services_rounded;
      case 'house_tools_diy_a2':
        return Icons.handyman_rounded;
      default:
        return Icons.auto_stories_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deckListAsync = ref.watch(deckListProvider);

    final selectedDeck = ref.watch(selectedDeckProvider);

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Deck')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Available Decks', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Expanded(
              child: deckListAsync.when(
                data: (decks) => ListView(
                  children: [
                    ...decks.map(
                      (deck) => Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Icon(
                              _iconForDeck(deck.id),
                              color: theme.colorScheme.onPrimaryContainer,
                              semanticLabel: '${deck.name.defaultText} deck',
                            ),
                          ),
                          title: Text(deck.name.defaultText),
                          subtitle: Text(
                            '${deck.itemCount} items • ${deck.level} • Greek ↔ Catalan',
                          ),
                          trailing: selectedDeck == deck.id
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                              : const Icon(Icons.circle_outlined),
                          onTap: () {
                            ref.read(selectedDeckProvider.notifier).state =
                                deck.id;
                          },
                        ),
                      ),
                    ),
                    if (_lockedDecks.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text('Coming Soon', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 12),
                      ..._lockedDecks.map(
                        (deck) => Semantics(
                          label: '${deck.name} deck locked',
                          child: Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHighest,
                                child: const Icon(Icons.lock_outline),
                              ),
                              title: Text(deck.name),
                              subtitle: const Text('Locked'),
                              trailing: const Icon(Icons.lock),
                              enabled: false,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                loading: () => const LoadingState(
                  message: 'Loading decks...',
                ),
                error: (error, _) => ErrorState(
                  title: 'Decks unavailable',
                  message: 'Check your connection and try again.',
                  onRetry: () => ref.refresh(deckListProvider),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => context.go(homeRoute),
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Main Menu'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DuelButton(
                    label: 'Continue',
                    onPressed: () => context.push(miniGameRoute),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LockedDeck {
  final String id;
  final String name;

  const _LockedDeck({required this.id, required this.name});
}
