import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/match_record.dart';
import '../../data/providers/history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Match History')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: history.isEmpty
            ? const Center(
                child: Text('No matches yet. Finish a duel to see history.'),
              )
            : ListView.separated(
                itemCount: history.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final record = history[index];
                  return _HistoryCard(record: record);
                },
              ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.record});

  final MatchRecord record;

  @override
  Widget build(BuildContext context) {
    final isTie = record.playerOneScore == record.playerTwoScore;
    final winner = record.playerOneScore > record.playerTwoScore
        ? record.playerOneName
        : record.playerTwoName;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatTimestamp(record.playedAt),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text('${record.playerOneName}: ${record.playerOneScore}'),
            Text('${record.playerTwoName}: ${record.playerTwoScore}'),
            const SizedBox(height: 6),
            Text(
              isTie ? 'Result: Tie' : 'Winner: $winner',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final y = dateTime.year.toString().padLeft(4, '0');
    final m = dateTime.month.toString().padLeft(2, '0');
    final d = dateTime.day.toString().padLeft(2, '0');
    final h = dateTime.hour.toString().padLeft(2, '0');
    final min = dateTime.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min';
  }
}
