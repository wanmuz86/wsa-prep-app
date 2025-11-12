import '../../data/models/game_config.dart';

/// World state management
class WorldState {
  // World movement
  double worldSpeed = GameConfig.baseWorldSpeed;
  double slopeAngle = GameConfig.defaultSlopeAngle;
  
  // Parallax background
  double parallaxOffset1 = 0.0;
  double parallaxOffset2 = 0.0;
  double parallaxSpeed = 0.0;
  
  // Speed boost
  bool isSpeedBoostActive = false;
  double speedBoostTimer = 0.0;
  
  // Jump state
  bool isJumping = false;
  double jumpTimer = 0.0;
  double jumpYOffset = 0.0;
  
  // Gyroscope tilt
  double gyroTiltX = 0.0;
  bool gyroAvailable = false;

  void updateParallax(double deltaTime, double screenWidth) {
    parallaxSpeed = worldSpeed * 0.5; // Parallax moves at half world speed
    parallaxOffset1 -= parallaxSpeed * deltaTime;
    parallaxOffset2 -= parallaxSpeed * deltaTime;
    
    // Wrap parallax when one copy fully leaves screen
    final imageWidth = screenWidth; // Assuming tree image width matches screen
    if (parallaxOffset1 <= -imageWidth) {
      parallaxOffset1 = parallaxOffset2 + imageWidth;
    }
    if (parallaxOffset2 <= -imageWidth) {
      parallaxOffset2 = parallaxOffset1 + imageWidth;
    }
  }

  void updateSpeedBoost(double deltaTime) {
    if (isSpeedBoostActive) {
      speedBoostTimer -= deltaTime;
      if (speedBoostTimer <= 0) {
        isSpeedBoostActive = false;
        speedBoostTimer = 0.0;
      }
    }
  }

  void activateSpeedBoost() {
    isSpeedBoostActive = true;
    speedBoostTimer = GameConfig.speedBoostDuration.inMilliseconds / 1000.0;
  }

  double getEffectiveSpeed() {
    double speed = worldSpeed;
    
    // Apply speed boost
    if (isSpeedBoostActive) {
      speed *= GameConfig.speedBoostMultiplier;
    }
    
    // Apply gyro tilt (left tilt decreases speed)
    if (gyroTiltX < 0) {
      // Map tilt from -1.0 to 0.0, scale speed accordingly
      final speedScale = 1.0 + gyroTiltX; // 0.0 at full left tilt
      speed *= speedScale.clamp(0.0, 1.0);
    }
    
    return speed.clamp(GameConfig.minWorldSpeed, GameConfig.maxWorldSpeed);
  }

  void updateSlopeAngle() {
    if (!gyroAvailable) {
      slopeAngle = GameConfig.defaultSlopeAngle;
      return;
    }

    // Map gyro tilt to slope angle
    // Left tilt (negative) decreases angle, right tilt restores to default
    if (gyroTiltX < 0) {
      // Decrease angle towards min (can go negative/uphill)
      final tiltFactor = -gyroTiltX; // 0.0 to 1.0
      slopeAngle = GameConfig.defaultSlopeAngle - 
                   (tiltFactor * (GameConfig.defaultSlopeAngle - GameConfig.minSlopeAngle));
    } else {
      // Right tilt restores to default
      slopeAngle = GameConfig.defaultSlopeAngle;
    }
    
    slopeAngle = slopeAngle.clamp(GameConfig.minSlopeAngle, GameConfig.maxSlopeAngle);
  }

  void startJump() {
    if (!isJumping) {
      isJumping = true;
      jumpTimer = 0.0;
      jumpYOffset = 0.0;
    }
  }

  void updateJump(double deltaTime) {
    if (isJumping) {
      jumpTimer += deltaTime;
      final progress = jumpTimer / (GameConfig.jumpDuration.inMilliseconds / 1000.0);
      
      if (progress >= 1.0) {
        isJumping = false;
        jumpTimer = 0.0;
        jumpYOffset = 0.0;
      } else {
        // Parabolic jump arc
        jumpYOffset = GameConfig.jumpHeight * (4 * progress * (1 - progress));
      }
    }
  }

  void reset() {
    worldSpeed = GameConfig.baseWorldSpeed;
    slopeAngle = GameConfig.defaultSlopeAngle;
    parallaxOffset1 = 0.0;
    parallaxOffset2 = 0.0;
    isSpeedBoostActive = false;
    speedBoostTimer = 0.0;
    isJumping = false;
    jumpTimer = 0.0;
    jumpYOffset = 0.0;
    gyroTiltX = 0.0;
  }
}

