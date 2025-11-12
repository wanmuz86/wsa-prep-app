import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../data/models/game_config.dart';
import '../engine/world_state.dart';
import '../engine/spawner.dart';
import 'sprites.dart';

class GamePainter extends CustomPainter {
  final WorldState worldState;
  final Spawner spawner;
  final double screenWidth;
  final double screenHeight;
  final Color jacketColor;
  final bool isInvincible;
  final String playerName;
  final int coins;
  final int duration;
  final String? recordingStatus;
  final bool showHitboxes;

  GamePainter({
    required this.worldState,
    required this.spawner,
    required this.screenWidth,
    required this.screenHeight,
    required this.jacketColor,
    required this.isInvincible,
    required this.playerName,
    required this.coins,
    required this.duration,
    this.recordingStatus,
    this.showHitboxes = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw parallax background
    _drawParallax(canvas);

    // Draw slope
    _drawSlope(canvas);

    // Draw entities
    _drawEntities(canvas);

    // Draw skier
    _drawSkier(canvas);

    // Draw HUD
    _drawHUD(canvas);

    // Draw invincibility overlay
    if (isInvincible) {
      _drawInvincibilityOverlay(canvas);
    }
  }

  void _drawParallax(Canvas canvas) {
    final treeImage = SpriteCache().treeImage;
    if (treeImage == null) return;

    // Draw two copies for seamless loop
    final imageWidth = treeImage.width.toDouble();
    final imageHeight = treeImage.height.toDouble();
    
    // Scale to fit screen width
    final scale = screenWidth / imageWidth;
    final scaledHeight = imageHeight * scale;

    // Draw first copy
    canvas.save();
    canvas.translate(worldState.parallaxOffset1, 0);
    canvas.scale(scale);
    canvas.drawImage(treeImage, Offset.zero, Paint());
    canvas.restore();

    // Draw second copy
    canvas.save();
    canvas.translate(worldState.parallaxOffset2, 0);
    canvas.scale(scale);
    canvas.drawImage(treeImage, Offset.zero, Paint());
    canvas.restore();
  }

  void _drawSlope(Canvas canvas) {
    // Draw white slope band at bottom with tilt
    final slopeHeight = screenHeight * 0.4;
    final slopeTop = screenHeight * 0.6;

    canvas.save();
    
    // Rotate around bottom-center
    canvas.translate(screenWidth / 2, screenHeight);
    canvas.rotate(worldState.slopeAngle);
    
    // Draw trapezoid slope
    final slopeWidth = screenWidth * 1.5; // Wider to account for rotation
    final path = Path()
      ..moveTo(-slopeWidth / 2, 0)
      ..lineTo(slopeWidth / 2, 0)
      ..lineTo(slopeWidth / 2 - slopeHeight * 0.3, -slopeHeight)
      ..lineTo(-slopeWidth / 2 + slopeHeight * 0.3, -slopeHeight)
      ..close();
    
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _drawEntities(Canvas canvas) {
    final obstacleImage = SpriteCache().obstacleImage;
    final coinImage = SpriteCache().coinImage;

    for (var entity in spawner.entities) {
      ui.Image? image;
      if (entity.type == EntityType.obstacle) {
        image = obstacleImage;
      } else if (entity.type == EntityType.coin) {
        image = coinImage;
      }

      if (image != null) {
        canvas.drawImage(
          image,
          Offset(entity.x, entity.y),
          Paint(),
        );
      }

      // Draw hitbox if debug
      if (showHitboxes) {
        final paint = Paint()
          ..color = entity.type == EntityType.obstacle ? Colors.red : Colors.yellow
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawRect(
          Rect.fromLTWH(entity.x, entity.y, entity.width, entity.height),
          paint,
        );
      }
    }
  }

  void _drawSkier(Canvas canvas) {
    final skierImage = SpriteCache().skierImage;
    if (skierImage == null) return;

    final skierX = screenWidth / 2;
    final skierY = screenHeight * GameConfig.skierYPosition - worldState.jumpYOffset;

    canvas.save();
    
    // Apply jacket color tint (for invincibility, use black)
    final colorFilter = isInvincible
        ? const ColorFilter.mode(Colors.black, BlendMode.color)
        : ColorFilter.mode(jacketColor, BlendMode.modulate);
    
    canvas.translate(skierX - GameConfig.skierWidth / 2, skierY - GameConfig.skierHeight / 2);
    canvas.scale(GameConfig.skierWidth / skierImage.width, GameConfig.skierHeight / skierImage.height);
    
    final paint = Paint()..colorFilter = colorFilter;
    canvas.drawImage(skierImage, Offset.zero, paint);
    canvas.restore();

    // Draw hitbox if debug
    if (showHitboxes) {
      final paint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(skierX, skierY - worldState.jumpYOffset),
          width: GameConfig.skierHitboxWidth,
          height: GameConfig.skierHitboxHeight,
        ),
        paint,
      );
    }
  }

  void _drawHUD(Canvas canvas) {
    final textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(
          offset: Offset(1, 1),
          blurRadius: 2,
          color: Colors.black,
        ),
      ],
    );

    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    // HUD background
    final hudRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(screenWidth - 200, 20, 180, 100),
      const Radius.circular(8),
    );
    canvas.drawRRect(hudRect, paint);

    // Player name
    final nameText = TextPainter(
      text: TextSpan(text: playerName, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    nameText.layout();
    nameText.paint(canvas, Offset(screenWidth - 190, 30));

    // Coins
    final coinText = TextPainter(
      text: TextSpan(text: 'Coin x$coins', style: textStyle),
      textDirection: TextDirection.ltr,
    );
    coinText.layout();
    coinText.paint(canvas, Offset(screenWidth - 190, 55));

    // Duration
    final durationText = TextPainter(
      text: TextSpan(text: '${duration}s', style: textStyle),
      textDirection: TextDirection.ltr,
    );
    durationText.layout();
    durationText.paint(canvas, Offset(screenWidth - 190, 80));

    // Recording status
    if (recordingStatus != null) {
      final recText = TextPainter(
        text: TextSpan(
          text: recordingStatus!,
          style: textStyle.copyWith(
            color: recordingStatus == 'REC' ? Colors.red : Colors.grey,
            fontSize: 12,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      recText.layout();
      recText.paint(canvas, Offset(screenWidth - 190, 105));
    }
  }

  void _drawInvincibilityOverlay(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, screenWidth, screenHeight),
      paint,
    );

    final textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 32,
      fontWeight: FontWeight.bold,
    );

    final textPainter = TextPainter(
      text: TextSpan(text: 'Invincibility Mode', style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(maxWidth: screenWidth);
    textPainter.paint(
      canvas,
      Offset((screenWidth - textPainter.width) / 2, screenHeight / 2 - 20),
    );
  }

  @override
  bool shouldRepaint(GamePainter oldDelegate) {
    return true; // Always repaint for smooth animation
  }
}

