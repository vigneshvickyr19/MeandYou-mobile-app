import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeNavigationController extends ChangeNotifier {
  static const String _storageKey = 'last_selected_tab';
  int _index = 0;

  int get index => _index;

  HomeNavigationController() {
    _loadSavedIndex();
  }

  Future<void> _loadSavedIndex() async {
    final prefs = await SharedPreferences.getInstance();
    _index = prefs.getInt(_storageKey) ?? 0;
    notifyListeners();
  }

  void changeTab(int newIndex) async {
    if (_index == newIndex) return;
    _index = newIndex;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_storageKey, newIndex);
  }
}
