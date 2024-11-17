import 'package:flutter/foundation.dart';
import 'dart:convert'; // To convert data to/from JSON
import 'package:shared_preferences/shared_preferences.dart';

class HistoryProvider with ChangeNotifier {
  // List to store history records.
  List<Map<String, String?>> _history = [];

  // Getter to access the history records.
  List<Map<String, String?>> get history => _history;

  // Method to add a new record and notify listeners.
  Future<void> addRecord(
      String title,
      String category,
      String carbonFootprint,
      String suggestion,
      String? vehicleType,
      String? distance,
      String? energyUsed) async {
    _history.add({
      'title': title,
      'category': category,
      'carbonFootprint': carbonFootprint,
      'suggestion': suggestion,
      'vehicleType': vehicleType,
      'distance': distance,
      'energyUsed': energyUsed
    });
    notifyListeners(); // Notifies all listeners (UI will rebuild).
    await _saveHistoryToPrefs(); // Save to local storage
  }

  // Load history records from shared preferences.
  Future<void> loadHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? historyString = prefs.getString('history');
    if (historyString != null) {
      List<dynamic> historyList = jsonDecode(historyString);
      _history =
          historyList.map((item) => Map<String, String>.from(item)).toList();
      notifyListeners();
    }
  }

  // Save the current history to shared preferences.
  Future<void> _saveHistoryToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String historyString = jsonEncode(_history);
    await prefs.setString('history', historyString);
  }

  // Clear all history records.
  Future<void> clearHistory() async {
    _history.clear();
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('history');
  }
}
