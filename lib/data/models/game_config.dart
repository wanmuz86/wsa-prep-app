/// Game configuration constants
class GameConfig {
  // Speed settings
  static const double baseWorldSpeed = 200.0; // pixels per second
  static const double minWorldSpeed = 0.0;
  static const double maxWorldSpeed = 400.0;
  static const double speedBoostMultiplier = 1.5;
  static const Duration speedBoostDuration = Duration(milliseconds: 600);

  // Slope angle settings (in radians)
  static const double defaultSlopeAngle = 0.3; // ~17 degrees
  static const double minSlopeAngle = -0.1; // Slight negative (uphill)
  static const double maxSlopeAngle = 0.5; // Steeper

  // Jump settings
  static const double jumpHeight = 120.0; // pixels
  static const Duration jumpDuration = Duration(milliseconds: 600);
  static const double gravity = 9.8 * 10; // pixels per second squared

  // Spawn settings
  static const Duration obstacleSpawnMin = Duration(milliseconds: 1500);
  static const Duration obstacleSpawnMax = Duration(milliseconds: 3000);
  static const Duration coinSpawnMin = Duration(milliseconds: 1000);
  static const Duration coinSpawnMax = Duration(milliseconds: 2500);
  static const double spawnXOffset = 100.0; // Spawn off-screen to the right
  static const double entityWidth = 60.0;
  static const double entityHeight = 60.0;
  static const double minSpawnSeparation = 150.0; // Min distance between entities

  // Skier settings
  static const double skierWidth = 50.0;
  static const double skierHeight = 80.0;
  static const double skierHitboxWidth = 40.0;
  static const double skierHitboxHeight = 60.0;
  static const double skierYPosition = 0.6; // 60% from top of screen

  // Invincibility settings
  static const int invincibilityCoinCostPerSecond = 1;
  static const Duration invincibilityMinDuration = Duration(seconds: 1);

  // Audio settings
  static const double baseBgmVolume = 1.0;
  static const double minBgmVolume = 0.2;
  static const double maxBgmVolume = 1.0;

  // Initial coins
  static const int initialCoins = 10;
}

