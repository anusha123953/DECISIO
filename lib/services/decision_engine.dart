
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class DecisionEngine {
  static const String storageKey = 'decisio_history';

  static Future<void> saveDecision({
    required String question,
    required List<String> options,
    required List<double> scores,
    required int winner,
  }) async {
    if (winner < 0 || winner >= options.length) {
      throw ArgumentError('Invalid winner index.');
    }

    if (options.length != scores.length) {
      throw ArgumentError('Options and scores must have the same length.');
    }

    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(storageKey) ?? [];

    final decision = {
      'question': question,
      'options': options,
      'scores': scores,
      'winner': options[winner],
      'date': DateTime.now().toIso8601String(),
    };

    history.insert(0, jsonEncode(decision));

    await prefs.setStringList(storageKey, history);
  }

  static Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(storageKey) ?? [];

    return history.map((item) {
      return Map<String, dynamic>.from(jsonDecode(item) as Map);
    }).toList();
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKey);
  }
}
