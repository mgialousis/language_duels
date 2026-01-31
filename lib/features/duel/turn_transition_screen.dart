import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../data/providers/game_session_provider.dart';
import '../../shared/widgets/duel_button.dart';

class TurnTransitionScreen extends ConsumerStatefulWidget {
  const TurnTransitionScreen({super.key});

  @override
  ConsumerState<TurnTransitionScreen> createState() =>
      _TurnTransitionScreenState();
}

class _TurnTransitionScreenState extends ConsumerState<TurnTransitionScreen> {
  static const int _countdownSeconds = 3;
  Timer? _countdownTimer;
  int _countdown = _countdownSeconds;
  bool _isCountingDown = false;
  bool _nameRevealed = false;
  double _opacity = 0;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _opacity = 1);
    });
  }

  void _startCountdown() {
    if (_isCountingDown) return;
    setState(() {
      _isCountingDown = true;
      _countdown = _countdownSeconds;
      _nameRevealed = true;
    });
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown <= 1) {
        timer.cancel();
        if (!mounted) return;
        setState(() => _opacity = 0);
        final reduceMotion = MediaQuery.of(context).disableAnimations;
        final delay = reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 400);
        Future.delayed(delay, () {
          if (mounted) context.go(duelRoute);
        });
        return;
      }
      setState(() {
        _countdown -= 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(gameSessionProvider);
    final nextPlayerName = session.currentPlayer == 1
        ? session.playerOneName
        : session.playerTwoName;
    final safeName =
        _nameRevealed ? nextPlayerName : 'Player ${session.currentPlayer}';
    final backgroundColor = session.currentPlayer == 1
        ? const Color(0xFF1F5BFF)
        : const Color(0xFFFF8A00);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final content = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      color: backgroundColor,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Pass the phone',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                'To $safeName',
                key: ValueKey('name-$safeName'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextButton.icon(
              onPressed: _isCountingDown
                  ? null
                  : () => setState(() => _nameRevealed = !_nameRevealed),
              icon: Icon(
                _nameRevealed ? Icons.visibility_off : Icons.visibility,
                color: Colors.white70,
              ),
              label: Text(
                _nameRevealed ? 'Hide name' : 'Reveal name',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 12),
            _HandoffIcon(animate: !reduceMotion),
            const SizedBox(height: 32),
            AnimatedSwitcher(
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 250),
              child: _isCountingDown
                  ? Text(
                      'Starting in $_countdown',
                      key: ValueKey('countdown-$_countdown'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : const Text(
                      "Make sure the other player can't see.",
                      key: ValueKey('ready'),
                      style: TextStyle(color: Colors.white70),
                    ),
            ),
            const SizedBox(height: 24),
            DuelButton(
              label: _isCountingDown ? 'Starting...' : "I'm Ready",
              onPressed: _isCountingDown ? null : _startCountdown,
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      body: reduceMotion
          ? Opacity(opacity: 1, child: content)
          : AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _opacity,
              child: content,
            ),
    );
  }
}

class _HandoffIcon extends StatefulWidget {
  const _HandoffIcon({required this.animate});

  final bool animate;

  @override
  State<_HandoffIcon> createState() => _HandoffIconState();
}

class _HandoffIconState extends State<_HandoffIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.animate) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return const Icon(
        Icons.swap_horiz_rounded,
        size: 72,
        color: Colors.white,
      );
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final offset = (1 - (2 * (_controller.value - 0.5).abs())) * 12;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: const Icon(
        Icons.swap_horiz_rounded,
        size: 72,
        color: Colors.white,
      ),
    );
  }
}
