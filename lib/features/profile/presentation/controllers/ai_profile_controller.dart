import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/models/profile_model.dart';
import '../../../../core/services/ai_profile_service.dart';
import '../../data/models/ai_analysis_model.dart';

class AiProfileController extends ChangeNotifier {
  bool _isLoading = false;
  AiAnalysisResponse? _analysisResult;
  String _loadingMessage = "Calculating your profile score...";
  int _messageIndex = 0;
  
  final List<String> _loadingMessages = [
    "Analyzing your photos...",
    "Reviewing your bio vibe...",
    "Scanning your lifestyle tags...",
    "Checking interest match potential...",
    "Optimizing for maximum charm...",
    "Almost there, gathering insights...",
  ];

  bool get isLoading => _isLoading;
  AiAnalysisResponse? get analysisResult => _analysisResult;
  String get loadingMessage => _loadingMessage;

  static String _getCacheKey(ProfileModel profile) {
    final timestamp = profile.profileUpdatedAt?.millisecondsSinceEpoch ?? 0;
    return "${StorageConstants.profileAuditCache}${profile.userId}_$timestamp";
  }

  /// Entry point for analysis. Checks cache first unless [forceRefresh] is true.
  Future<void> performAnalysis(ProfileModel profile, {bool forceRefresh = false}) async {
    final cacheKey = _getCacheKey(profile);

    // 1. Try to load from cache first
    if (!forceRefresh) {
      final cached = await _loadFromCache(cacheKey);
      if (cached != null) {
        _analysisResult = cached;
        _isLoading = false;
        notifyListeners();
        return;
      }
    }

    // 2. Otherwise perform new analysis
    _isLoading = true;
    _messageIndex = 0;
    _loadingMessage = _loadingMessages[0];
    notifyListeners();
    
    _startMessageRotation();

    try {
      final result = await AiProfileService.instance.analyzeProfile(profile);
      if (result != null && result.success) {
        _analysisResult = result;
        await _saveToCache(cacheKey, result);
      }
    } catch (e) {
      debugPrint('Error in AiProfileController: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AiAnalysisResponse?> _loadFromCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString(key);
      if (cachedData != null) {
        return AiAnalysisResponse.fromJson(jsonDecode(cachedData));
      }
    } catch (e) {
      debugPrint('AiProfileController: Cache load error: $e');
    }
    return null;
  }

  Future<void> _saveToCache(String key, AiAnalysisResponse result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(result.toJson()));
    } catch (e) {
      debugPrint('AiProfileController: Cache save error: $e');
    }
  }

  void _startMessageRotation() async {
    while (_isLoading) {
      await Future.delayed(const Duration(seconds: 3));
      if (!_isLoading) break;
      _messageIndex = (_messageIndex + 1) % _loadingMessages.length;
      _loadingMessage = _loadingMessages[_messageIndex];
      notifyListeners();
    }
  }
}
