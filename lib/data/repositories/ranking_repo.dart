import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/run_record.dart';

class RankingRepository extends ChangeNotifier {
  static const String _key = 'rankings_v1';
  List<RunRecord> _records = [];

  List<RunRecord> get records => List.unmodifiable(_records);

  RankingRepository() {
    _loadRankings();
  }

  Future<void> _loadRankings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        _records = jsonList.map((json) => RunRecord.fromJson(json)).toList();
        _sortRankings();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading rankings: $e');
    }
  }

  Future<void> addRecord(RunRecord record) async {
    try {
      // Remove highlight from all records
      _records = _records.map((r) => RunRecord(
        player: r.player,
        coins: r.coins,
        durationSeconds: r.durationSeconds,
        timestamp: r.timestamp,
        isHighlighted: false,
      )).toList();

      // Add new record with highlight
      _records.add(RunRecord(
        player: record.player,
        coins: record.coins,
        durationSeconds: record.durationSeconds,
        timestamp: record.timestamp,
        isHighlighted: true,
      ));

      _sortRankings();
      await _saveRankings();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding record: $e');
    }
  }

  void clearHighlight() {
    _records = _records.map((r) => RunRecord(
      player: r.player,
      coins: r.coins,
      durationSeconds: r.durationSeconds,
      timestamp: r.timestamp,
      isHighlighted: false,
    )).toList();
    notifyListeners();
  }

  void _sortRankings() {
    _records.sort((a, b) => b.durationSeconds.compareTo(a.durationSeconds));
  }

  Future<void> _saveRankings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _records.map((r) => r.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await prefs.setString(_key, jsonString);
    } catch (e) {
      debugPrint('Error saving rankings: $e');
    }
  }

  Future<void> clearRankings() async {
    _records.clear();
    await _saveRankings();
    notifyListeners();
  }
}

