import 'package:flutter/material.dart';

import '../../../data/models/grammar_lesson.dart';

class GrammarTableWidget extends StatelessWidget {
  const GrammarTableWidget({
    super.key,
    required this.tables,
    required this.showRomanization,
  });

  final List<GrammarTable> tables;
  final bool showRomanization;

  @override
  Widget build(BuildContext context) {
    if (tables.isEmpty) {
      return const Center(child: Text('No tables available.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tables.length,
      itemBuilder: (context, index) {
        final table = tables[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  table.title.defaultText,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Table(
                  border: TableBorder.all(
                    color: Theme.of(context).dividerColor,
                    width: 0.8,
                  ),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                      children: [
                        const SizedBox.shrink(),
                        for (final header in table.columnHeaders)
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              header,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),
                    for (int rowIndex = 0;
                        rowIndex < table.rowHeaders.length;
                        rowIndex++)
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              table.rowHeaders[rowIndex],
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          for (final cell in table.cells[rowIndex])
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: cell.isHighlighted
                                        ? const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          )
                                        : EdgeInsets.zero,
                                    decoration: cell.isHighlighted
                                        ? BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer
                                                .withAlpha((0.6 * 255).round()),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          )
                                        : null,
                                    child: Text(
                                      cell.greek,
                                      style: TextStyle(
                                        fontWeight: cell.isHighlighted
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (showRomanization &&
                                      cell.romanization.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        cell.romanization,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ),
                                  if (cell.translation.isNotEmpty)
                                    Text(
                                      cell.translation,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
                if (table.footnote != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    table.footnote!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
