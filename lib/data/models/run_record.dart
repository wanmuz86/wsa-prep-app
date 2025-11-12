class RunRecord {
  final String player;
  final int coins;
  final int durationSeconds;
  final DateTime timestamp;
  final bool isHighlighted;

  RunRecord({
    required this.player,
    required this.coins,
    required this.durationSeconds,
    required this.timestamp,
    this.isHighlighted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'player': player,
      'coins': coins,
      'durationSeconds': durationSeconds,
      'timestamp': timestamp.toIso8601String(),
      'isHighlighted': isHighlighted,
    };
  }

  factory RunRecord.fromJson(Map<String, dynamic> json) {
    return RunRecord(
      player: json['player'] as String,
      coins: json['coins'] as int,
      durationSeconds: json['durationSeconds'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isHighlighted: json['isHighlighted'] as bool? ?? false,
    );
  }
}

