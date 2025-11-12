import 'package:flutter/material.dart';

/// Handles game input gestures
class GestureLayer extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final VoidCallback onSwipeDown;
  final VoidCallback onSwipeRight;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;

  const GestureLayer({
    super.key,
    required this.child,
    required this.onTap,
    required this.onSwipeDown,
    required this.onSwipeRight,
    required this.onLongPressStart,
    required this.onLongPressEnd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
          // Swipe down
          onSwipeDown();
        }
      },
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
          // Swipe left to right
          onSwipeRight();
        }
      },
      onLongPressStart: (_) => onLongPressStart(),
      onLongPressEnd: (_) => onLongPressEnd(),
      child: child,
    );
  }
}

