import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../constants/storage_constants.dart';

class AiSuggestionCacheService {
  static final AiSuggestionCacheService _instance = AiSuggestionCacheService._();
  static AiSuggestionCacheService get instance => _instance;

  Box<List<String>>? _box;

  AiSuggestionCacheService._();

  /// Initialize Hive and open the box
  Future<void> initialize() async {
    try {
      if (_box != null) return;
      await Hive.initFlutter();
      _box = await Hive.openBox<List<String>>(StorageConstants.aiSuggestionsBox);
      debugPrint('AiSuggestionCacheService: Hive initialized');
    } catch (e) {
      debugPrint('AiSuggestionCacheService: Error initializing Hive: $e');
    }
  }

  /// Save first message suggestions for a specific chat
  Future<void> saveFirstMessages(String chatId, List<String> suggestions) async {
    if (_box == null) await initialize();
    final key = '${StorageConstants.firstMessagePrefix}$chatId';
    await _box?.put(key, suggestions);
  }

  /// Get cached first message suggestions
  List<String>? getFirstMessages(String chatId) {
    final key = '${StorageConstants.firstMessagePrefix}$chatId';
    return _box?.get(key);
  }

  /// Save suggested replies for a specific message in a chat
  Future<void> saveSuggestedReplies(String chatId, String lastMessageId, List<String> suggestions) async {
    if (_box == null) await initialize();
    final key = '${StorageConstants.suggestReplyPrefix}${chatId}_$lastMessageId';
    await _box?.put(key, suggestions);
  }

  /// Get cached suggested replies
  List<String>? getSuggestedReplies(String chatId, String lastMessageId) {
    final key = '${StorageConstants.suggestReplyPrefix}${chatId}_$lastMessageId';
    return _box?.get(key);
  }

  /// Clear all cached suggestions (useful for logout)
  Future<void> clearAll() async {
    await _box?.clear();
  }
}
