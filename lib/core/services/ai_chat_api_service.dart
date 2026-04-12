import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';

class AiChatApiService {
  static final AiChatApiService _instance = AiChatApiService._();
  static AiChatApiService get instance => _instance;

  final Dio _dio = Dio();

  AiChatApiService._() {
    _dio.options.baseUrl = ApiConstants.aiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {'Content-Type': 'application/json'};
  }

  /// Get first message suggestions when starting a chat
  Future<List<String>> getFirstMessageSuggestions(String profileInfo) async {
    try {
      final response = await _dio.post(
        '/api/ai/first-message',
        data: {'profile': profileInfo},
      );

      if (response.data['success'] == true) {
        final List<dynamic> messages = response.data['data']['messages'];
        return messages.map((e) => e.toString()).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting first message suggestions: $e');
      return [];
    }
  }

  /// Get suggested replies based on the last message in chat
  Future<List<String>> getSuggestedReplies(String lastMessage) async {
    try {
      final response = await _dio.post(
        '/api/ai/suggest-replies',
        data: {'chat': lastMessage},
      );

      if (response.data['success'] == true) {
        final List<dynamic> replies = response.data['data']['replies'];
        return replies.map((e) => e.toString()).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting suggested replies: $e');
      return [];
    }
  }
}
