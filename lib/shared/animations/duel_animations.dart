import 'package:flutter/material.dart';

class DuelAnimations {
  const DuelAnimations._();

  static Widget fadeScale(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.96, end: 1.0).animate(animation),
        child: child,
      ),
    );
  }
}
