import 'package:flutter/material.dart';

class ConfirmExitDialog extends StatelessWidget {
  final VoidCallback onYes;
  final VoidCallback onNo;

  const ConfirmExitDialog({
    super.key,
    required this.onYes,
    required this.onNo,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Exit'),
      content: const Text('The game is in progress. Are you sure to quit?'),
      actions: [
        TextButton(
          onPressed: onNo,
          child: const Text('No'),
        ),
        TextButton(
          onPressed: onYes,
          child: const Text('Yes'),
        ),
      ],
    );
  }
}

