import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/audio/audio_service.dart';
import '../../core/record/record_service.dart';
import '../../core/sensors/gyro_service.dart';
import '../../core/utils/time_tick.dart';
import '../../data/models/game_config.dart';
import '../engine/game_loop.dart';
import '../engine/world_state.dart';
import '../engine/spawner.dart';
import '../engine/collision.dart';
import 'invincibility.dart';

enum GameState { initial, playing, paused, gameOver }

class GameController extends ChangeNotifier {
  // Services
  final AudioService _audioService = AudioService();
  final RecordService _recordService = RecordService();
  final GyroService _gyroService = GyroService();
  final TimeTick _timeTick = TimeTick();
  final GameLoop _gameLoop = GameLoop();
  final WorldState _worldState = WorldState();
  final Spawner _spawner = Spawner();
  final InvincibilityManager _invincibility = InvincibilityManager();

  // Game state
  GameState _state = GameState.initial;
  int _coins = GameConfig.initialCoins;
  int _duration = 0;
  String _playerName = '';
  Color _jacketColor = Colors.blue;
  bool _showHitboxes = false;
  double _screenWidth = 0.0;
  double _screenHeight = 0.0;
  GlobalKey? _repaintKey;

  // Getters
  GameState get state => _state;
  int get coins => _coins;
  int get duration => _duration;
  String get playerName => _playerName;
  Color get jacketColor => _jacketColor;
  bool get showHitboxes => _showHitboxes;
  WorldState get worldState => _worldState;
  Spawner get spawner => _spawner;
  bool get isInvincible => _invincibility.isActive;
  String? get recordingStatus => _recordService.recordingStatus;

  void initialize(double screenWidth, double screenHeight, GlobalKey repaintKey) {
    _screenWidth = screenWidth;
    _screenHeight = screenHeight;
    _repaintKey = repaintKey;
    _spawner.initialize(screenWidth, screenHeight);
    
    // Initialize parallax offsets
    _worldState.parallaxOffset2 = screenWidth;
    
    // Set up invincibility callbacks
    _invincibility.onCoinConsumed = (amount) {
      if (_coins >= amount) {
        _coins -= amount;
        notifyListeners();
      } else {
        _invincibility.deactivate();
      }
    };
  }

  Future<void> startGame(String playerName, Color jacketColor) async {
    _playerName = playerName;
    _jacketColor = jacketColor;
    _coins = GameConfig.initialCoins;
    _duration = 0;
    _state = GameState.playing;
    
    // Reset game systems
    _worldState.reset();
    _spawner.reset();
    _invincibility.deactivate();
    
    // Initialize audio
    await _audioService.initialize();
    await _audioService.playBgm('audio/bgm.mp3');
    
    // Start recording
    if (_repaintKey != null) {
      await _recordService.startRecording(_repaintKey!);
    }
    
    // Start gyroscope
    _gyroService.startListening((tiltX) {
      _worldState.gyroTiltX = tiltX;
      _worldState.gyroAvailable = _gyroService.isAvailable;
      _worldState.updateSlopeAngle();
      
      // Update BGM volume based on speed
      final effectiveSpeed = _worldState.getEffectiveSpeed();
      final speedRatio = effectiveSpeed / GameConfig.baseWorldSpeed;
      final volume = (GameConfig.minBgmVolume + 
                     (GameConfig.maxBgmVolume - GameConfig.minBgmVolume) * speedRatio)
                     .clamp(GameConfig.minBgmVolume, GameConfig.maxBgmVolume);
      _audioService.setBgmVolume(volume);
    });
    
    // Start time tick
    _timeTick.start((seconds) {
      _duration = seconds;
      notifyListeners();
    });
    
    // Start game loop
    _gameLoop.start(_update);
    
    notifyListeners();
  }

  void _update(double deltaTime) {
    if (_state != GameState.playing) return;
    
    // Update world state
    _worldState.updateParallax(deltaTime, _screenWidth);
    _worldState.updateSpeedBoost(deltaTime);
    _worldState.updateJump(deltaTime);
    _worldState.updateSlopeAngle();
    
    // Update spawner
    final effectiveSpeed = _worldState.getEffectiveSpeed();
    _spawner.update(deltaTime, effectiveSpeed);
    
    // Check collisions
    _checkCollisions();
    
    notifyListeners();
  }

  void _checkCollisions() {
    final skierX = _screenWidth / 2;
    final skierY = _screenHeight * GameConfig.skierYPosition;
    
    for (var entity in List.from(_spawner.entities)) {
      if (CollisionDetector.checkCollision(
        skierX,
        skierY,
        _worldState.jumpYOffset,
        entity,
      )) {
        if (entity.type == EntityType.coin) {
          // Collect coin
          _spawner.removeEntity(entity);
          _coins++;
          _audioService.playCoin();
          notifyListeners();
        } else if (entity.type == EntityType.obstacle) {
          // Hit obstacle
          if (!_invincibility.isActive) {
            _gameOver();
          }
        }
      }
    }
  }

  void jump() {
    if (_state == GameState.playing && !_worldState.isJumping) {
      _worldState.startJump();
      _audioService.playJump();
      notifyListeners();
    }
  }

  void swipeDown() {
    if (_state == GameState.playing) {
      _worldState.activateSpeedBoost();
      notifyListeners();
    }
  }

  void swipeRight() {
    // Handled by UI layer to show dialog
  }

  void longPressStart() {
    if (_state == GameState.playing && _coins > 0) {
      _invincibility.activate();
      notifyListeners();
    }
  }

  void longPressEnd() {
    if (_invincibility.isActive) {
      _invincibility.deactivate();
      notifyListeners();
    }
  }

  void pause() {
    if (_state == GameState.playing) {
      _state = GameState.paused;
      _gameLoop.pause();
      _timeTick.pause();
      _audioService.pauseBgm();
      notifyListeners();
    }
  }

  void resume() {
    if (_state == GameState.paused) {
      _state = GameState.playing;
      _gameLoop.resume();
      _timeTick.resume();
      _audioService.resumeBgm();
      notifyListeners();
    }
  }

  void _gameOver() {
    _state = GameState.gameOver;
    _gameLoop.stop();
    _timeTick.stop();
    _audioService.stopBgm();
    _audioService.playGameOver();
    _recordService.stopRecording();
    _gyroService.stopListening();
    notifyListeners();
  }

  void restart() {
    _state = GameState.initial;
    _worldState.reset();
    _spawner.reset();
    _invincibility.deactivate();
    _timeTick.reset();
    notifyListeners();
  }

  void toggleDebugHitboxes() {
    _showHitboxes = !_showHitboxes;
    notifyListeners();
  }

  void dispose() {
    _gameLoop.dispose();
    _timeTick.dispose();
    _gyroService.dispose();
    _invincibility.dispose();
    _audioService.dispose();
    super.dispose();
  }
}

