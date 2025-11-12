import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  
  bool _isBgmPlaying = false;
  double _bgmVolume = 1.0;
  double _targetBgmVolume = 1.0;
  Timer? _volumeFadeTimer;

  Future<void> initialize() async {
    try {
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.setVolume(1.0);
      await _sfxPlayer.setVolume(1.0);
    } catch (e) {
      // Silently continue if audio initialization fails
      debugPrint('Audio initialization error: $e');
    }
  }

  Future<void> playBgm(String assetPath) async {
    try {
      if (!_isBgmPlaying) {
        await _bgmPlayer.play(AssetSource(assetPath));
        _isBgmPlaying = true;
      }
    } catch (e) {
      debugPrint('BGM play error: $e');
    }
  }

  Future<void> pauseBgm() async {
    try {
      await _bgmPlayer.pause();
      _isBgmPlaying = false;
    } catch (e) {
      debugPrint('BGM pause error: $e');
    }
  }

  Future<void> resumeBgm() async {
    try {
      if (!_isBgmPlaying) {
        await _bgmPlayer.resume();
        _isBgmPlaying = true;
      }
    } catch (e) {
      debugPrint('BGM resume error: $e');
    }
  }

  Future<void> stopBgm() async {
    try {
      await _bgmPlayer.stop();
      _isBgmPlaying = false;
    } catch (e) {
      debugPrint('BGM stop error: $e');
    }
  }

  /// Set BGM volume (0.0 to 1.0) with smooth fade
  void setBgmVolume(double volume, {bool smooth = true}) {
    _targetBgmVolume = volume.clamp(0.0, 1.0);
    
    if (!smooth) {
      _bgmVolume = _targetBgmVolume;
      _bgmPlayer.setVolume(_bgmVolume);
      return;
    }

    _volumeFadeTimer?.cancel();
    const fadeDuration = Duration(milliseconds: 200);
    const steps = 10;
    final stepDuration = fadeDuration ~/ steps;
    final stepDelta = (_targetBgmVolume - _bgmVolume) / steps;
    var currentStep = 0;

    _volumeFadeTimer = Timer.periodic(stepDuration, (timer) {
      currentStep++;
      _bgmVolume += stepDelta;
      
      if (currentStep >= steps || (_targetBgmVolume - _bgmVolume).abs() < 0.01) {
        _bgmVolume = _targetBgmVolume;
        timer.cancel();
      }
      
      _bgmPlayer.setVolume(_bgmVolume);
    });
  }

  Future<void> playJump() async {
    try {
      await _sfxPlayer.play(AssetSource('audio/jump.wav'));
    } catch (e) {
      debugPrint('Jump sound error: $e');
    }
  }

  Future<void> playCoin() async {
    try {
      await _sfxPlayer.play(AssetSource('audio/coin.wav'));
    } catch (e) {
      debugPrint('Coin sound error: $e');
    }
  }

  Future<void> playGameOver() async {
    try {
      await _sfxPlayer.play(AssetSource('audio/game_over.wav'));
    } catch (e) {
      debugPrint('Game over sound error: $e');
    }
  }

  void dispose() {
    _volumeFadeTimer?.cancel();
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
  }
}

