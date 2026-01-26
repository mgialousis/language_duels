import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../data/models/player.dart';
import '../../data/providers/setup_provider.dart';
import '../../shared/widgets/duel_button.dart';

class PlayerSetupScreen extends ConsumerStatefulWidget {
  const PlayerSetupScreen({super.key});

  @override
  ConsumerState<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends ConsumerState<PlayerSetupScreen> {
  final _playerOneController = TextEditingController();
  final _playerTwoController = TextEditingController();
  final _playerOneFocus = FocusNode();
  final _playerTwoFocus = FocusNode();
  bool _playerOneTouched = false;
  bool _playerTwoTouched = false;
  String _playerOneLearning = 'Catalan';
  String _playerTwoLearning = 'Greek';

  @override
  void dispose() {
    _playerOneController.dispose();
    _playerTwoController.dispose();
    _playerOneFocus.dispose();
    _playerTwoFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _playerOneFocus.addListener(() {
      if (!_playerOneFocus.hasFocus && !_playerOneTouched) {
        setState(() => _playerOneTouched = true);
      }
    });
    _playerTwoFocus.addListener(() {
      if (!_playerTwoFocus.hasFocus && !_playerTwoTouched) {
        setState(() => _playerTwoTouched = true);
      }
    });
  }

  String? _validateName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Please enter a name';
    if (trimmed.length > 20) return 'Name must be 20 characters or less';
    return null;
  }

  bool get _canContinue {
    final p1 = _playerOneController.text.trim();
    final p2 = _playerTwoController.text.trim();
    if (_validateName(p1) != null || _validateName(p2) != null) return false;
    return p1 != p2;
  }

  void _continue() {
    final playerOne = _playerOneController.text.trim();
    final playerTwo = _playerTwoController.text.trim();

    if (!_canContinue) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the name fields.')),
      );
      return;
    }

    ref.read(playerOneNameProvider.notifier).state = playerOne;
    ref.read(playerTwoNameProvider.notifier).state = playerTwo;
    final p1Direction = _playerOneLearning == 'Catalan'
        ? LanguageDirection.greekToCatalan
        : LanguageDirection.catalanToGreek;
    final p2Direction = _playerTwoLearning == 'Catalan'
        ? LanguageDirection.greekToCatalan
        : LanguageDirection.catalanToGreek;
    ref.read(playerOneDirectionProvider.notifier).state = p1Direction;
    ref.read(playerTwoDirectionProvider.notifier).state = p2Direction;

    context.push(deckRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Player Setup')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _PlayerCard(
                title: 'PLAYER 1',
                accentColor: Colors.blue,
                nameField: TextField(
                  controller: _playerOneController,
                  focusNode: _playerOneFocus,
                  maxLength: 20,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Enter name...',
                    errorText: _playerOneTouched
                        ? _validateName(_playerOneController.text)
                        : null,
                  ),
                ),
                learningValue: _playerOneLearning,
                onLearningChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _playerOneLearning = value;
                    _playerTwoLearning =
                        value == 'Catalan' ? 'Greek' : 'Catalan';
                  });
                },
              ),
              const SizedBox(height: 16),
              _PlayerCard(
                title: 'PLAYER 2',
                accentColor: Colors.orange,
                nameField: TextField(
                  controller: _playerTwoController,
                  focusNode: _playerTwoFocus,
                  maxLength: 20,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Enter name...',
                    errorText: _playerTwoTouched
                        ? _validateName(_playerTwoController.text)
                        : null,
                  ),
                ),
                learningValue: _playerTwoLearning,
                onLearningChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _playerTwoLearning = value;
                    _playerOneLearning =
                        value == 'Catalan' ? 'Greek' : 'Catalan';
                  });
                },
              ),
              const SizedBox(height: 24),
              DuelButton(
                label: 'Continue',
                onPressed: _canContinue ? _continue : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    required this.title,
    required this.accentColor,
    required this.nameField,
    required this.learningValue,
    required this.onLearningChanged,
  });

  final String title;
  final Color accentColor;
  final Widget nameField;
  final String learningValue;
  final ValueChanged<String?> onLearningChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: accentColor, width: 4),
        ),
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 8),
          nameField,
          const SizedBox(height: 12),
          DropdownMenu<String>(
            label: const Text('Learning'),
            initialSelection: learningValue,
            dropdownMenuEntries: const [
              DropdownMenuEntry(value: 'Catalan', label: 'Catalan'),
              DropdownMenuEntry(value: 'Greek', label: 'Greek'),
            ],
            onSelected: onLearningChanged,
          ),
        ],
      ),
    );
  }
}
