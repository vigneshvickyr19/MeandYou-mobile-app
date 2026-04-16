import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../models/profile_model.dart';
import '../../features/profile/data/models/ai_analysis_model.dart';

class AiProfileService {
  static final AiProfileService _instance = AiProfileService._();
  static AiProfileService get instance => _instance;

  final Dio _dio = Dio();

  AiProfileService._() {
    _dio.options.baseUrl = ApiConstants.aiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 60);
    _dio.options.receiveTimeout = const Duration(seconds: 120);
    _dio.options.headers = {'Content-Type': 'application/json'};
  }

  /// Analyze the profile using AI to get a score and feedback
  Future<AiAnalysisResponse?> analyzeProfile(ProfileModel profile) async {
    try {
      final payload = {
        "photos":
            profile.photos
                ?.asMap()
                .entries
                .map(
                  (entry) => {"url": entry.value, "isPrimary": entry.key == 0},
                )
                .toList() ??
            [],
        "basicInfo": {
          "fullName": profile.fullName,
          "dob": profile.dob?.toIso8601String().split('T')[0],
          "bio": profile.bio,
        },
        "personalDetails": {
          "height": profile.height,
          "jobTitle": profile.jobTitle,
          "education": profile.education,
          "city": profile.city,
          "hometown": profile.hometown,
          "address": profile.addressLine1,
        },
        "lifestyle": {
          "drinking": profile.drinking,
          "smoking": profile.smoking,
          "exercise": profile.exercise,
          "diet": profile.diet,
          "pets": profile.pets,
          "religion": profile.religion,
        },
        "interests": profile.interests ?? [],
        "preferences": {
          "lookingFor": profile.lookingFor,
          "ageRange": {
            "min": profile.minAge ?? 18,
            "max": profile.maxAge ?? 50,
          },
          "maxDistance": profile.distance ?? 50,
        },
      };

      final response = await _dio.post(
        '/api/ai/analyze-profile',
        data: payload,
      );

      if (response.data != null) {
        return AiAnalysisResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error analyzing profile: $e');
      return null;
    }
  }
}
