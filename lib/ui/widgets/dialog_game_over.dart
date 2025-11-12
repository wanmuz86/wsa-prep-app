import 'package:flutter/material.dart';

class GameOverDialog extends StatelessWidget {
  final String playerName;
  final int coins;
  final int duration;
  final VoidCallback onRestart;
  final VoidCallback onGoToRankings;

  const GameOverDialog({
    super.key,
    required this.playerName,
    required this.coins,
    required this.duration,
    required this.onRestart,
    required this.onGoToRankings,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Game Over'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Player: $playerName'),
          const SizedBox(height: 8),
          Text('Coins: $coins'),
          const SizedBox(height: 8),
          Text('Duration: ${duration}s'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onRestart,
          child: const Text('Restart'),
        ),
        TextButton(
          onPressed: onGoToRankings,
          child: const Text('Go To Rankings'),
        ),
      ],
    );
  }
}

