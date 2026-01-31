import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../shared/widgets/duel_button.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key, this.walkthrough = false});

  final bool walkthrough;

  @override
  Widget build(BuildContext context) {
    return walkthrough ? const _WalkthroughScreen() : const _GuideScreen();
  }
}

const List<_InfoCardData> _gameModeCards = [
  _InfoCardData(
    title: 'Vocab Flash Duel',
    body:
        'Pick the correct translation from 4 options. Faster answers give bonus points.',
  ),
  _InfoCardData(
    title: 'Phrase Builder',
    body:
        'Drag words into the correct order. Submit when you think the phrase is correct.',
  ),
  _InfoCardData(
    title: 'Speed Round',
    body: 'Answer true/false questions as fast as you can.',
  ),
  _InfoCardData(
    title: 'Match Madness',
    body: 'Match word pairs before the timer runs out.',
  ),
  _InfoCardData(
    title: 'Spelling Bee',
    body: 'Type the translation with accent-friendly input.',
  ),
  _InfoCardData(
    title: 'Listening Challenge',
    body: 'Listen to a word and pick the correct translation.',
  ),
];

const List<_TutorialSection> _guideSections = [
  _TutorialSection(
    title: 'Quick Start',
    bullets: [
      'Enter both player names on the setup screen.',
      'Pick a deck that matches your level (A1/A2).',
      'Each player answers rounds on the same device.',
      'Highest total score wins the duel.',
    ],
  ),
  _TutorialSection(
    title: 'Game Modes',
    cards: _gameModeCards,
  ),
  _TutorialSection(
    title: 'Scoring',
    bullets: [
      'Correct answer: 10 points',
      'Speed bonus (timed mode): +1 to +5 points',
      'Incorrect answer: 0 points',
      'No timer mode: all correct answers score the same',
    ],
  ),
  _TutorialSection(
    title: 'Turn Handoff',
    bullets: [
      'A “Pass the phone” screen appears between players.',
      'Reveal your name only when you have the phone.',
    ],
  ),
  _TutorialSection(
    title: 'Tips',
    bullets: [
      'Use the timer for challenge, or disable it in Settings.',
      'Practice decks you struggle with to improve accuracy.',
      'Solo Practice helps review weak or due items.',
    ],
  ),
];

const List<_WalkthroughPageData> _walkthroughPages = [
  _WalkthroughPageData(
    title: 'Welcome to Language Duel',
    body: 'Hot-seat language battles in Greek ↔ Catalan.',
    icon: Icons.sports_esports,
    bullets: [
      'Play together on one device.',
      'Earn points across multiple mini-games.',
      'Take turns and keep answers private.',
    ],
  ),
  _WalkthroughPageData(
    title: 'Quick Start',
    icon: Icons.flag_outlined,
    bullets: [
      'Enter player names and pick a deck.',
      'Choose mini-games for the duel.',
      'Play timed or relaxed rounds.',
    ],
  ),
  _WalkthroughPageData(
    title: 'Game Modes',
    icon: Icons.videogame_asset_outlined,
    cards: _gameModeCards,
  ),
  _WalkthroughPageData(
    title: 'Scoring',
    icon: Icons.emoji_events_outlined,
    bullets: [
      'Correct answers earn 10 points.',
      'Timed mode adds a speed bonus.',
      'Incorrect answers score 0 points.',
    ],
  ),
  _WalkthroughPageData(
    title: 'Turn Handoff',
    icon: Icons.swap_horiz_rounded,
    bullets: [
      'Use the handoff screen between players.',
      'Reveal your name only when ready.',
      'Start the countdown when the phone is secure.',
    ],
  ),
  _WalkthroughPageData(
    title: 'Keep Improving',
    icon: Icons.auto_graph,
    bullets: [
      'Use Solo Practice to build mastery.',
      'Review weak words and spaced repetition items.',
      'Track streaks and progress in My Progress.',
    ],
  ),
];

class _GuideScreen extends StatelessWidget {
  const _GuideScreen();

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
          children: [
            const _HeroCard(),
            const SizedBox(height: 16),
            DuelButton(
              label: 'Start Tutorial',
              onPressed: () => context.push(
                '$howToPlayRoute?walkthrough=true',
              ),
            ),
            const SizedBox(height: 20),
            for (final section in _guideSections) ...[
              _SectionTitle(section.title),
              const SizedBox(height: 8),
              if (section.bullets.isNotEmpty)
                _BulletList(items: section.bullets),
              if (section.cards.isNotEmpty) ...[
                for (final card in section.cards) ...[
                  _InfoCard(title: card.title, body: card.body),
                  const SizedBox(height: 10),
                ],
              ],
              const SizedBox(height: 20),
            ],
            const _FooterNote(),
            const SizedBox(height: 16),
            const _BackButton(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _WalkthroughScreen extends StatefulWidget {
  const _WalkthroughScreen();

  @override
  State<_WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<_WalkthroughScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextPage() {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (_index >= _walkthroughPages.length - 1) {
      context.push(setupRoute);
      return;
    }
    _controller.nextPage(
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  void _previousPage() {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (_index <= 0) return;
    _controller.previousPage(
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final isLast = _index == _walkthroughPages.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => context.go(homeRoute),
            child: const Text('Skip'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                physics: reduceMotion
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(),
                itemCount: _walkthroughPages.length,
                onPageChanged: (index) => setState(() => _index = index),
                itemBuilder: (context, index) {
                  final page = _walkthroughPages[index];
                  return _WalkthroughPage(page: page);
                },
              ),
            ),
            const SizedBox(height: 12),
            _ProgressDots(count: _walkthroughPages.length, index: _index),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _index == 0 ? null : _previousPage,
                    child: const Text('Back'),
                  ),
                  const Spacer(),
                  Expanded(
                    child: DuelButton(
                      label: isLast ? 'Start Duel' : 'Next',
                      onPressed: _nextPage,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _WalkthroughPage extends StatelessWidget {
  const _WalkthroughPage({required this.page});

  final _WalkthroughPageData page;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(page.icon, color: theme.colorScheme.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                page.title,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        if (page.body != null) ...[
          const SizedBox(height: 12),
          Text(page.body!, style: theme.textTheme.bodyMedium),
        ],
        if (page.bullets.isNotEmpty) ...[
          const SizedBox(height: 16),
          _BulletList(items: page.bullets),
        ],
        if (page.cards.isNotEmpty) ...[
          const SizedBox(height: 16),
          for (final card in page.cards) ...[
            _InfoCard(title: card.title, body: card.body),
            const SizedBox(height: 10),
          ],
        ],
      ],
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Step ${index + 1} of $count',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          count,
          (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: i == index ? 20 : 8,
            decoration: BoxDecoration(
              color: i == index ? scheme.primary : scheme.outlineVariant,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
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
    final theme = Theme.of(context);
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
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(body, style: theme.textTheme.bodyMedium),
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
      onPressed: () => context.go(homeRoute),
    );
  }
}

class _TutorialSection {
  final String title;
  final List<String> bullets;
  final List<_InfoCardData> cards;

  const _TutorialSection({
    required this.title,
    this.bullets = const [],
    this.cards = const [],
  });
}

class _InfoCardData {
  final String title;
  final String body;

  const _InfoCardData({required this.title, required this.body});
}

class _WalkthroughPageData {
  final String title;
  final String? body;
  final IconData icon;
  final List<String> bullets;
  final List<_InfoCardData> cards;

  const _WalkthroughPageData({
    required this.title,
    required this.icon,
    this.body,
    this.bullets = const [],
    this.cards = const [],
  });
}
