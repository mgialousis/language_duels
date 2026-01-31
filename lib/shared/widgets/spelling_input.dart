import 'package:flutter/material.dart';

import 'special_character_bar.dart';

class SpellingInput extends StatefulWidget {
  final String targetLanguage;
  final ValueChanged<String> onSubmit;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final String? hint;

  const SpellingInput({
    super.key,
    required this.targetLanguage,
    required this.onSubmit,
    this.onChanged,
    this.enabled = true,
    this.hint,
  });

  @override
  State<SpellingInput> createState() => _SpellingInputState();
}

class _SpellingInputState extends State<SpellingInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headlineSmall;
    return Column(
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          textAlign: TextAlign.center,
          style: textStyle,
          textInputAction: TextInputAction.done,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
            labelText: 'Answer',
            hintText: widget.hint ?? 'Type your answer...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                widget.onChanged?.call('');
                _focusNode.requestFocus();
              },
            ),
          ),
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmit,
        ),
        const SizedBox(height: 10),
        SpecialCharacterBar(
          language: widget.targetLanguage,
          onCharacterTap: (char) {
            final selection = _controller.selection;
            final newText = _controller.text.replaceRange(
              selection.start,
              selection.end,
              char,
            );
            _controller.text = newText;
            _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: selection.start + char.length),
            );
            widget.onChanged?.call(_controller.text);
            _focusNode.requestFocus();
          },
        ),
      ],
    );
  }
}
