import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/repositories/ranking_repo.dart';
import 'widgets/primary_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameController = TextEditingController();
  int _titleTapCount = 0;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showDebugPanel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Panel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Reset Rankings'),
              onTap: () {
                context.read<RankingRepository>().clearRankings();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rankings cleared')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/home_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    _titleTapCount++;
                    if (_titleTapCount >= 5) {
                      _titleTapCount = 0;
                      _showDebugPanel();
                    }
                  },
                  child: const Text(
                    'Go Skiing',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 4,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Player name',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'Start Game',
                  onPressed: () {
                    final name = _nameController.text.trim();
                    if (name.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Invalid'),
                          content: const Text('Please enter a player name'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      Navigator.pushNamed(
                        context,
                        '/game',
                        arguments: {'playerName': name},
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  text: 'Rankings',
                  onPressed: () {
                    Navigator.pushNamed(context, '/rankings');
                  },
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  text: 'Setting',
                  onPressed: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

