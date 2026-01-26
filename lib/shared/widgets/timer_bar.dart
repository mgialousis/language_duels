import 'package:flutter/material.dart';

class TimerBar extends StatelessWidget {
  final int totalSeconds;
  final int remainingSeconds;
  final int warningThreshold;
  final int criticalThreshold;

  const TimerBar({
    super.key,
    required this.totalSeconds,
    required this.remainingSeconds,
    this.warningThreshold = 3,
    this.criticalThreshold = 1,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final progress = (remainingSeconds / totalSeconds).clamp(0.0, 1.0);
    final isCritical = remainingSeconds <= criticalThreshold;
    final isWarning = remainingSeconds <= warningThreshold && !isCritical;
    final color = isCritical
        ? Colors.redAccent
        : (isWarning ? Colors.orangeAccent : Colors.green);

    final bar = ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 10,
        color: color,
        backgroundColor: Colors.black12,
      ),
    );

    return Semantics(
      label: 'Time remaining $remainingSeconds seconds',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Time: ${remainingSeconds}s'),
          const SizedBox(height: 6),
          if (reduceMotion)
            bar
          else
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 400),
              tween: Tween<double>(
                begin: 1.0,
                end: isCritical ? 1.06 : (isWarning ? 1.03 : 1.0),
              ),
              builder: (context, value, child) =>
                  Transform.scale(scale: value, child: child),
              child: bar,
            ),
        ],
      ),
    );
  }
}
