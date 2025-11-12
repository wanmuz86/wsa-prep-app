import '../../data/models/game_config.dart';
import 'spawner.dart';

class CollisionDetector {
  /// Check collision between skier and entity
  /// Returns true if collision detected
  static bool checkCollision(
    double skierX,
    double skierY,
    double skierJumpOffset,
    Entity entity,
  ) {
    // Skier hitbox (centered)
    final skierLeft = skierX - GameConfig.skierHitboxWidth / 2;
    final skierRight = skierX + GameConfig.skierHitboxWidth / 2;
    final skierTop = skierY - GameConfig.skierHitboxHeight / 2 - skierJumpOffset;
    final skierBottom = skierY + GameConfig.skierHitboxHeight / 2 - skierJumpOffset;

    // Entity bounds
    final entityLeft = entity.x;
    final entityRight = entity.x + entity.width;
    final entityTop = entity.y;
    final entityBottom = entity.y + entity.height;

    // AABB collision detection
    return skierLeft < entityRight &&
           skierRight > entityLeft &&
           skierTop < entityBottom &&
           skierBottom > entityTop;
  }
}

