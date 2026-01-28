import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/duel_button.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Play'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: const [
            _HeroCard(),
            SizedBox(height: 20),
            _SectionTitle('Quick Start'),
            SizedBox(height: 8),
            _BulletList(items: [
              'Enter both player names on the setup screen.',
              'Pick a deck that matches your level (A1/A2).',
              'Each player answers vocab and phrase rounds on the same device.',
              'Highest total score wins the duel.',
            ]),
            SizedBox(height: 20),
            _SectionTitle('Game Modes'),
            SizedBox(height: 8),
            _InfoCard(
              title: 'Vocab Flash Duel',
              body:
                  'Pick the correct translation from 4 options. Faster answers give bonus points.',
            ),
            SizedBox(height: 10),
            _InfoCard(
              title: 'Phrase Builder',
              body:
                  'Drag words into the correct order. Submit when you think the phrase is correct.',
            ),
            SizedBox(height: 20),
            _SectionTitle('Scoring'),
            SizedBox(height: 8),
            _BulletList(items: [
              'Correct answer: 10 points',
              'Speed bonus (timed mode): +1 to +5 points',
              'Incorrect answer: 0 points',
              'No timer mode: all correct answers score the same',
            ]),
            SizedBox(height: 20),
            _SectionTitle('Turn Handoff'),
            SizedBox(height: 8),
            _BulletList(items: [
              'A “Pass the phone” screen appears between players.',
              'Hide the screen when switching to keep answers private.',
            ]),
            SizedBox(height: 20),
            _SectionTitle('Tips'),
            SizedBox(height: 8),
            _BulletList(items: [
              'Use the timer for challenge, or disable it in Settings.',
              'Practice decks you struggle with to improve accuracy.',
              'Short, frequent sessions help retention.',
            ]),
            SizedBox(height: 28),
            _FooterNote(),
            SizedBox(height: 16),
            _BackButton(),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor:
                scheme.onPrimaryContainer.withAlpha((0.08 * 255).round()),
            child: Icon(Icons.sports_esports, color: scheme.onPrimaryContainer),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Language Duel',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Hot-seat language battles in Greek ↔ Catalan.',
                  style: TextStyle(color: scheme.onPrimaryContainer),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(body),
          ],
        ),
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  '),
                  Expanded(child: Text(item)),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _FooterNote extends StatelessWidget {
  const _FooterNote();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Text(
      'Play fair, take turns, and keep it friendly!',
      textAlign: TextAlign.center,
      style: TextStyle(color: color),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return DuelButton(
      label: 'Back to Home',
      onPressed: () => context.go('/'),
    );
  }
}
