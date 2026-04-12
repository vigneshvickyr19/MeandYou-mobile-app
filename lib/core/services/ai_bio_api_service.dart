import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';

class AiBioApiService {
  static final AiBioApiService _instance = AiBioApiService._();
  static AiBioApiService get instance => _instance;

  final Dio _dio = Dio();

  AiBioApiService._() {
    _dio.options.baseUrl = ApiConstants.aiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };
  }

  /// Generate a bio based on interests and personality
  Future<String?> generateBio({
    required String interests,
    required String personality,
  }) async {
    try {
      final response = await _dio.post(
        '/api/ai/generate-bio',
        data: {
          'interests': interests,
          'personality': personality,
        },
      );

      if (response.data['success'] == true) {
        return response.data['data']['bio'] as String;
      }
      return null;
    } catch (e) {
      debugPrint('Error generating AI bio: $e');
      return null;
    }
  }

  /// Helper to fetch multiple suggestions concurrently
  Future<List<String>> generateMultipleBios({
    required String interests,
    required String personality,
    int count = 3,
  }) async {
    final List<Future<String?>> futures = List.generate(
      count,
      (_) => generateBio(interests: interests, personality: personality),
    );

    final results = await Future.wait(futures);
    return results.whereType<String>().toList();
  }
}
