import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../data/models/content_item.dart';
import '../../data/models/deck.dart';
import '../../data/providers/content_provider.dart';
import '../../data/providers/srs_provider.dart';
import '../../shared/widgets/duel_button.dart';
import '../../shared/widgets/async_state.dart';

class WeakWordsScreen extends ConsumerWidget {
  const WeakWordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weakItems = ref.watch(weakItemsProvider);
    final deckIds = weakItems.map((item) => item.deckId).toSet().toList()..sort();
    final decksAsync = deckIds.isEmpty
        ? const AsyncValue.data(<Deck>[])
        : ref.watch(decksByIdsProvider(deckIds));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weak Words'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: decksAsync.when(
          loading: () => const LoadingState(message: 'Loading decks...'),
          error: (e, _) => ErrorState(
            title: 'Decks unavailable',
            message: 'Please try again.',
            onRetry: () => ref.refresh(decksByIdsProvider(deckIds)),
          ),
          data: (decks) {
            final itemMap = <String, ContentItem>{
              for (final deck in decks)
                for (final item in deck.vocabularyItems) item.id: item,
            };

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  weakItems.isEmpty
                      ? 'You have no weak words right now.'
                      : '${weakItems.length} words need extra practice.',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                if (weakItems.isNotEmpty)
                  ...weakItems.map((item) {
                    final content = itemMap[item.itemId];
                    if (content == null) {
                      return Card(
                        child: ListTile(
                          title: Text(item.itemId),
                          subtitle: const Text('Word not found in deck data'),
                        ),
                      );
                    }
                    return Card(
                      child: ListTile(
                        title: Text(content.greek.text),
                        subtitle: Text(content.catalan.text),
                        trailing: const Icon(Icons.warning_amber),
                      ),
                    );
                  }),
                const SizedBox(height: 24),
                if (weakItems.length >= 5)
                  DuelButton(
                    label: 'Review Weak Words',
                    onPressed: () => context.push(
                      soloSetupRoute,
                      extra: {'mode': 'weakWords'},
                    ),
                  ),
                if (weakItems.length < 5)
                  Text(
                    'At least 5 weak words are needed to start a review.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
