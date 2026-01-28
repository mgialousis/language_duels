import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/solo_session_summary.dart';
import '../../data/providers/content_provider.dart';
import '../../data/providers/solo_history_provider.dart';
import '../../shared/widgets/async_state.dart';

class SoloHistoryScreen extends ConsumerWidget {
  const SoloHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(soloHistoryProvider);
    final sorted = [...history]
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice History'),
        centerTitle: true,
        actions: [
          if (sorted.isNotEmpty)
            IconButton(
              tooltip: 'Clear history',
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final shouldClear = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear practice history?'),
                    content: const Text(
                      'This removes all solo practice sessions from this device.',
                    ),
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
                  await ref.read(soloHistoryProvider.notifier).clear();
                }
              },
            ),
        ],
      ),
      body: SafeArea(
        child: sorted.isEmpty
            ? const Center(
                child: Text('No sessions yet. Complete a solo session first.'),
              )
            : ref.watch(deckListProvider).when(
                  loading: () => const LoadingState(
                    message: 'Loading history...',
                  ),
                  error: (error, stackTrace) =>
                      _HistoryList(history: sorted),
                  data: (decks) {
                    final deckNames = {
                      for (final deck in decks) deck.id: deck.name.defaultText,
                    };
                    return _HistoryList(history: sorted, deckNames: deckNames);
                  },
                ),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({
    required this.history,
    this.deckNames = const {},
  });

  final List<SoloSessionSummary> history;
  final Map<String, String> deckNames;

  @override
  Widget build(BuildContext context) {
    final sections = _groupByDate(history);

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...section.items.map(
              (session) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _HistoryCard(
                  session: session,
                  deckName: deckNames[session.deckId] ?? session.deckId,
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
        );
      },
    );
  }

  List<_HistorySection> _groupByDate(List<SoloSessionSummary> items) {
    final sections = <_HistorySection>[];
    for (final session in items) {
      final label = _formatDateLabel(session.startedAt);
      final existing = sections.where((section) => section.label == label);
      if (existing.isNotEmpty) {
        existing.first.items.add(session);
      } else {
        sections.add(_HistorySection(label: label, items: [session]));
      }
    }
    return sections;
  }

  String _formatDateLabel(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

class _HistorySection {
  _HistorySection({required this.label, required this.items});

  final String label;
  final List<SoloSessionSummary> items;
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.session, required this.deckName});

  final SoloSessionSummary session;
  final String deckName;

  @override
  Widget build(BuildContext context) {
    final accuracy = (session.accuracy * 100).toStringAsFixed(0);
    final modeLabel = switch (session.mode) {
      SoloMode.timed => 'Timed',
      SoloMode.relaxed => 'Relaxed',
      SoloMode.srsReview => 'SRS Review',
    };
    final gameLabel = switch (session.gameType) {
      SoloGameType.vocabFlash => 'Vocab Flash',
      SoloGameType.phraseBuilder => 'Phrase Builder',
      SoloGameType.mixed => 'Mixed',
      SoloGameType.speedRound => 'Speed Round',
      SoloGameType.matchMadness => 'Match Madness',
      SoloGameType.spellingBee => 'Spelling Bee',
      SoloGameType.listening => 'Listening',
    };

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              deckName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text('$gameLabel • $modeLabel'),
            const SizedBox(height: 8),
            Text(
              'Score: ${session.score}  •  Accuracy: $accuracy%  •  Time: ${_formatDuration(session.durationSeconds)}',
            ),
            const SizedBox(height: 6),
            Text(_formatTime(session.startedAt)),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  String _formatTime(DateTime date) {
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
