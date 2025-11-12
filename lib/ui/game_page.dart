import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import '../core/storage/prefs.dart';
import '../data/models/run_record.dart';
import '../data/repositories/ranking_repo.dart';
import '../game/domain/game_controller.dart';
import '../game/rendering/game_painter.dart';
import '../game/rendering/sprites.dart';
import '../game/input/gesture_layer.dart';
import 'widgets/dialog_confirm_exit.dart';
import 'widgets/dialog_game_over.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late GameController _gameController;
  final GlobalKey _repaintKey = GlobalKey();
  String _playerName = '';
  Color _jacketColor = Colors.blue;
  bool _hasVibrated = false;

  @override
  void initState() {
    super.initState();
    _gameController = GameController();
    _gameController.addListener(_onGameStateChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _playerName = args['playerName'] ?? '';
      final prefsService = context.read<PreferencesService>();
      _jacketColor = Color(int.parse(prefsService.jacketColor));
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startGame();
      });
    }
  }

  Future<void> _startGame() async {
    final size = MediaQuery.of(context).size;
    _gameController.initialize(size.width, size.height, _repaintKey);
    
    // Load sprites
    await SpriteCache().loadSprites();
    
    // Vibrate on start
    if (!_hasVibrated) {
      _hasVibrated = true;
      try {
        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate(duration: 100);
        } else {
          HapticFeedback.mediumImpact();
        }
      } catch (e) {
        HapticFeedback.mediumImpact();
      }
    }
    
    await _gameController.startGame(_playerName, _jacketColor);
  }

  void _onGameStateChanged() {
    setState(() {}); // Trigger rebuild on state change
    if (_gameController.state == GameState.gameOver) {
      _showGameOverDialog();
    }
  }

  void _showGameOverDialog() {
    // Vibrate on game over
    try {
      Vibration.vibrate(duration: 200);
    } catch (e) {
      HapticFeedback.mediumImpact();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameOverDialog(
        playerName: _playerName,
        coins: _gameController.coins,
        duration: _gameController.duration,
        onRestart: () {
          Navigator.pop(context);
          _gameController.restart();
          _startGame();
        },
        onGoToRankings: () {
          // Save record
          final record = RunRecord(
            player: _playerName,
            coins: _gameController.coins,
            durationSeconds: _gameController.duration,
            timestamp: DateTime.now(),
          );
          context.read<RankingRepository>().addRecord(record);
          
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, '/rankings');
        },
      ),
    );
  }

  void _handleSwipeRight() {
    if (_gameController.state == GameState.playing) {
      _gameController.pause();
      showDialog(
        context: context,
        builder: (context) => ConfirmExitDialog(
          onYes: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
          onNo: () {
            Navigator.pop(context);
            _gameController.resume();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureLayer(
            onTap: () => _gameController.jump(),
            onSwipeDown: () => _gameController.swipeDown(),
            onSwipeRight: () => _handleSwipeRight(),
            onLongPressStart: () => _gameController.longPressStart(),
            onLongPressEnd: () => _gameController.longPressEnd(),
            child: RepaintBoundary(
              key: _repaintKey,
              child: CustomPaint(
                painter: GamePainter(
                  worldState: _gameController.worldState,
                  spawner: _gameController.spawner,
                  screenWidth: MediaQuery.of(context).size.width,
                  screenHeight: MediaQuery.of(context).size.height,
                  jacketColor: _jacketColor,
                  isInvincible: _gameController.isInvincible,
                  playerName: _playerName,
                  coins: _gameController.coins,
                  duration: _gameController.duration,
                  recordingStatus: _gameController.recordingStatus,
                  showHitboxes: _gameController.showHitboxes,
                ),
                size: MediaQuery.of(context).size,
              ),
            ),
          ),
          // Pause button
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              icon: Icon(
                _gameController.state == GameState.paused
                    ? Icons.play_arrow
                    : Icons.pause,
                color: Colors.white,
                size: 32,
              ),
              onPressed: () {
                if (_gameController.state == GameState.playing) {
                  _gameController.pause();
                } else if (_gameController.state == GameState.paused) {
                  _gameController.resume();
                }
                setState(() {}); // Trigger rebuild
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _gameController.removeListener(_onGameStateChanged);
    _gameController.dispose();
    super.dispose();
  }
}

