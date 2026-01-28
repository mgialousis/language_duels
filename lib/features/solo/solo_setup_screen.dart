import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../data/models/player.dart';
import '../../data/models/solo_session_summary.dart';
import '../../data/providers/content_provider.dart';
import '../../shared/widgets/duel_button.dart';

class SoloSetupScreen extends ConsumerStatefulWidget {
  const SoloSetupScreen({super.key});

  @override
  ConsumerState<SoloSetupScreen> createState() => _SoloSetupScreenState();
}

class _SoloSetupScreenState extends ConsumerState<SoloSetupScreen> {
  String? _selectedDeckId;
  SoloGameType _gameType = SoloGameType.vocabFlash;
  SoloMode _mode = SoloMode.timed;
  int _questionCount = 10;
  LanguageDirection _direction = LanguageDirection.greekToCatalan;

  @override
  Widget build(BuildContext context) {
    final decksAsync = ref.watch(deckListProvider);
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final presetMode = extra?['mode'] as String?;
    final reviewOnly = presetMode == 'srsReview' || presetMode == 'weakWords';

    // Handle preset modes
    if (presetMode == 'srsReview' && _mode != SoloMode.srsReview) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _mode = SoloMode.srsReview);
      });
    }
    if (presetMode == 'weakWords' && _mode != SoloMode.srsReview) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _mode = SoloMode.srsReview);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Setup'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: decksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Decks unavailable'),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => ref.refresh(deckListProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (decks) {
            // Set default deck if not selected
            if (_selectedDeckId == null && decks.isNotEmpty) {
              _selectedDeckId = decks.first.id;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Deck Selection
                  _SectionTitle('Deck'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedDeckId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    items: decks
                        .map((deck) => DropdownMenuItem(
                              value: deck.id,
                              child: Text(deck.name.defaultText),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedDeckId = value);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Game Type
                  _SectionTitle('Mini-Game'),
                  const SizedBox(height: 8),
                  _OptionChips<SoloGameType>(
                    options: SoloGameType.values
                        .where((type) => type != SoloGameType.listening)
                        .toList(),
                    selected: _gameType,
                    labelBuilder: (type) => switch (type) {
                      SoloGameType.vocabFlash => 'Vocab Flash',
                      SoloGameType.phraseBuilder => 'Phrase Builder',
                      SoloGameType.mixed => 'Mixed',
                      SoloGameType.speedRound => 'Speed Round',
                      SoloGameType.matchMadness => 'Match Madness',
                      SoloGameType.spellingBee => 'Spelling Bee',
                      SoloGameType.listening => 'Listening',
                    },
                    onSelected: (type) => setState(() => _gameType = type),
                  ),
                  const SizedBox(height: 24),

                  if (!reviewOnly) ...[
                    // Mode
                    _SectionTitle('Mode'),
                    const SizedBox(height: 8),
                    _OptionChips<SoloMode>(
                      options: SoloMode.values,
                      selected: _mode,
                      labelBuilder: (mode) => switch (mode) {
                        SoloMode.timed => 'Timed',
                        SoloMode.relaxed => 'Relaxed',
                        SoloMode.srsReview => 'SRS Review',
                      },
                      onSelected: (mode) => setState(() => _mode = mode),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _modeDescription,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Question Count
                  _SectionTitle('Questions'),
                  const SizedBox(height: 8),
                  _OptionChips<int>(
                    options: reviewOnly
                        ? const [10, 15, 20, 30]
                        : const [5, 10, 15, 20],
                    selected: _questionCount,
                    labelBuilder: (count) => '$count',
                    onSelected: (count) =>
                        setState(() => _questionCount = count),
                  ),
                  const SizedBox(height: 24),

                  // Direction
                  _SectionTitle('Direction'),
                  const SizedBox(height: 8),
                  _OptionChips<LanguageDirection>(
                    options: LanguageDirection.values,
                    selected: _direction,
                    labelBuilder: (dir) => switch (dir) {
                      LanguageDirection.greekToCatalan => 'Greek \u2192 Catalan',
                      LanguageDirection.catalanToGreek => 'Catalan \u2192 Greek',
                    },
                    onSelected: (dir) => setState(() => _direction = dir),
                  ),
                  const SizedBox(height: 40),

                  // Start Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: DuelButton(
                      label: 'Start Practice',
                      onPressed: _selectedDeckId == null
                          ? null
                          : () {
                              final extra =
                                  GoRouterState.of(context).extra as Map<String, dynamic>?;
                              final isWeakWords = extra?['mode'] == 'weakWords';
                              context.push(
                                soloPracticeRoute,
                                extra: {
                                  'deckId': _selectedDeckId,
                                  'gameType': _gameType,
                                  'mode': _mode,
                                  'weakWords': isWeakWords,
                                  'questionCount': _questionCount,
                                  'direction': _direction,
                                },
                              );
                            },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String get _modeDescription => switch (_mode) {
        SoloMode.timed => 'Practice with timers, just like in a duel.',
        SoloMode.relaxed => 'No time pressure. Take your time to learn.',
        SoloMode.srsReview =>
          'Review items based on spaced repetition for optimal retention.',
      };
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _OptionChips<T> extends StatelessWidget {
  const _OptionChips({
    required this.options,
    required this.selected,
    required this.labelBuilder,
    required this.onSelected,
  });

  final List<T> options;
  final T selected;
  final String Function(T) labelBuilder;
  final void Function(T) onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = option == selected;
        return ChoiceChip(
          label: Text(labelBuilder(option)),
          selected: isSelected,
          onSelected: (_) => onSelected(option),
          selectedColor: Theme.of(context).colorScheme.primaryContainer,
          labelStyle: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : null,
          ),
        );
      }).toList(),
    );
  }
}
