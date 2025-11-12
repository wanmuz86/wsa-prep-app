import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/repositories/ranking_repo.dart';

class RankingsPage extends StatelessWidget {
  const RankingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rankings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<RankingRepository>(
        builder: (context, repo, child) {
          if (repo.records.isEmpty) {
            return const Center(
              child: Text('No Ranking'),
            );
          }

          return ListView.builder(
            itemCount: repo.records.length,
            itemBuilder: (context, index) {
              final record = repo.records[index];
              return Container(
                color: record.isHighlighted ? Colors.yellow.withOpacity(0.3) : null,
                child: ListTile(
                  leading: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  title: Text(record.player),
                  subtitle: Text('Coins: ${record.coins}'),
                  trailing: Text('${record.durationSeconds}s'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

