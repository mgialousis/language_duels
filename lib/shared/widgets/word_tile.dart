import 'package:flutter/material.dart';

class WordTile extends StatelessWidget {
  final String text;
  final bool locked;
  final Widget? dragHandle;

  const WordTile({
    super.key,
    required this.text,
    this.locked = false,
    this.dragHandle,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: locked ? 'Word tile, locked: $text' : 'Word tile: $text',
      child: Card(
        child: ListTile(
          title: Text(text),
          trailing: locked ? const Icon(Icons.lock) : dragHandle,
        ),
      ),
    );
  }
}
