import 'dart:math' as math;
import '../../data/models/game_config.dart';

enum EntityType { obstacle, coin }

class Entity {
  final EntityType type;
  double x;
  double y;
  final double width;
  final double height;

  Entity({
    required this.type,
    required this.x,
    required this.y,
    this.width = GameConfig.entityWidth,
    this.height = GameConfig.entityHeight,
  });
}

class Spawner {
  final math.Random _random = math.Random();
  final List<Entity> _entities = [];
  double _obstacleSpawnTimer = 0.0;
  double _coinSpawnTimer = 0.0;
  double _nextObstacleSpawn = 0.0;
  double _nextCoinSpawn = 0.0;
  double _screenWidth = 0.0;
  double _screenHeight = 0.0;

  List<Entity> get entities => _entities;

  void initialize(double screenWidth, double screenHeight) {
    _screenWidth = screenWidth;
    _screenHeight = screenHeight;
    _scheduleNextSpawn();
  }

  void _scheduleNextSpawn() {
    final obstacleDelay = _random.nextDouble() * 
        (GameConfig.obstacleSpawnMax.inMilliseconds - GameConfig.obstacleSpawnMin.inMilliseconds) +
        GameConfig.obstacleSpawnMin.inMilliseconds;
    _nextObstacleSpawn = obstacleDelay / 1000.0;

    final coinDelay = _random.nextDouble() * 
        (GameConfig.coinSpawnMax.inMilliseconds - GameConfig.coinSpawnMin.inMilliseconds) +
        GameConfig.coinSpawnMin.inMilliseconds;
    _nextCoinSpawn = coinDelay / 1000.0;
  }

  void update(double deltaTime, double worldSpeed) {
    _obstacleSpawnTimer += deltaTime;
    _coinSpawnTimer += deltaTime;

    // Spawn obstacle
    if (_obstacleSpawnTimer >= _nextObstacleSpawn) {
      _spawnObstacle();
      _obstacleSpawnTimer = 0.0;
      final delay = _random.nextDouble() * 
          (GameConfig.obstacleSpawnMax.inMilliseconds - GameConfig.obstacleSpawnMin.inMilliseconds) +
          GameConfig.obstacleSpawnMin.inMilliseconds;
      _nextObstacleSpawn = delay / 1000.0;
    }

    // Spawn coin (check for non-overlapping)
    if (_coinSpawnTimer >= _nextCoinSpawn) {
      if (_canSpawnCoin()) {
        _spawnCoin();
        _coinSpawnTimer = 0.0;
        final delay = _random.nextDouble() * 
            (GameConfig.coinSpawnMax.inMilliseconds - GameConfig.coinSpawnMin.inMilliseconds) +
            GameConfig.coinSpawnMin.inMilliseconds;
        _nextCoinSpawn = delay / 1000.0;
      }
    }

    // Update entity positions
    for (var entity in _entities) {
      entity.x -= worldSpeed * deltaTime;
    }

    // Remove off-screen entities
    _entities.removeWhere((entity) => entity.x + entity.width < 0);
  }

  void _spawnObstacle() {
    // Spawn on slope area (bottom 40% of screen)
    final slopeAreaTop = _screenHeight * 0.6;
    final y = slopeAreaTop + _random.nextDouble() * (_screenHeight * 0.4 - GameConfig.entityHeight);
    
    _entities.add(Entity(
      type: EntityType.obstacle,
      x: _screenWidth + GameConfig.spawnXOffset,
      y: y,
    ));
  }

  void _spawnCoin() {
    // Spawn on slope area, avoiding obstacles
    final slopeAreaTop = _screenHeight * 0.6;
    final y = slopeAreaTop + _random.nextDouble() * (_screenHeight * 0.4 - GameConfig.entityHeight);
    final x = _screenWidth + GameConfig.spawnXOffset;

    // Check for overlap with existing obstacles
    bool overlaps = false;
    for (var entity in _entities) {
      if (entity.type == EntityType.obstacle) {
        final distance = (entity.x - x).abs();
        if (distance < GameConfig.minSpawnSeparation) {
          overlaps = true;
          break;
        }
      }
    }

    if (!overlaps) {
      _entities.add(Entity(
        type: EntityType.coin,
        x: x,
        y: y,
      ));
    }
  }

  bool _canSpawnCoin() {
    // Simple check: ensure minimum separation from obstacles
    return true; // Spawn logic handles overlap check
  }

  void removeEntity(Entity entity) {
    _entities.remove(entity);
  }

  void reset() {
    _entities.clear();
    _obstacleSpawnTimer = 0.0;
    _coinSpawnTimer = 0.0;
    _scheduleNextSpawn();
  }
}

