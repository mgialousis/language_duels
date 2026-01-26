import 'package:flutter/material.dart';

class ScoreBoard extends StatelessWidget {
  final String playerOne;
  final String playerTwo;
  final int playerOneScore;
  final int playerTwoScore;

  const ScoreBoard({
    super.key,
    required this.playerOne,
    required this.playerTwo,
    this.playerOneScore = 0,
    this.playerTwoScore = 0,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return Semantics(
      label:
          'Scores. $playerOne: $playerOneScore points. $playerTwo: $playerTwoScore points.',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playerOne,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  AnimatedSwitcher(
                    duration: reduceMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) => reduceMotion
                        ? child
                        : ScaleTransition(scale: animation, child: child),
                    child: Text(
                      '$playerOneScore pts',
                      key: ValueKey('p1-$playerOneScore'),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    playerTwo,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  AnimatedSwitcher(
                    duration: reduceMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) => reduceMotion
                        ? child
                        : ScaleTransition(scale: animation, child: child),
                    child: Text(
                      '$playerTwoScore pts',
                      key: ValueKey('p2-$playerTwoScore'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
