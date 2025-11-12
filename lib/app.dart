import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/storage/prefs.dart';
import 'data/repositories/ranking_repo.dart';
import 'ui/home_page.dart';
import 'ui/game_page.dart';
import 'ui/rankings_page.dart';
import 'ui/settings_page.dart';
import 'theme/theme.dart';

class GoSkiingApp extends StatelessWidget {
  const GoSkiingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RankingRepository()),
        ChangeNotifierProvider(create: (_) => PreferencesService()),
      ],
      child: MaterialApp(
        title: 'Go Skiing',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/game': (context) => const GamePage(),
          '/rankings': (context) => const RankingsPage(),
          '/settings': (context) => const SettingsPage(),
        },
      ),
    );
  }
}

