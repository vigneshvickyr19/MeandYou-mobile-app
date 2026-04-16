class AiAnalysisResponse {
  final bool success;
  final AiAnalysisData data;

  AiAnalysisResponse({required this.success, required this.data});

  factory AiAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return AiAnalysisResponse(
      success: json['success'] ?? false,
      data: AiAnalysisData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'data': data.toJson(),
  };
}

class AiAnalysisData {
  final int profileScore;
  final SectionAnalysis photos;
  final SectionAnalysis bio;
  final SectionAnalysis personalDetails;
  final SectionAnalysis lifestyle;
  final SectionAnalysis interests;
  final SectionAnalysis preferences;
  final List<String> overallTips;

  AiAnalysisData({
    required this.profileScore,
    required this.photos,
    required this.bio,
    required this.personalDetails,
    required this.lifestyle,
    required this.interests,
    required this.preferences,
    required this.overallTips,
  });

  factory AiAnalysisData.fromJson(Map<String, dynamic> json) {
    return AiAnalysisData(
      profileScore: json['profileScore'] ?? 0,
      photos: SectionAnalysis.fromJson(json['photos'] ?? {}),
      bio: SectionAnalysis.fromJson(json['bio'] ?? {}),
      personalDetails: SectionAnalysis.fromJson(json['personalDetails'] ?? {}),
      lifestyle: SectionAnalysis.fromJson(json['lifestyle'] ?? {}),
      interests: SectionAnalysis.fromJson(json['interests'] ?? {}),
      preferences: SectionAnalysis.fromJson(json['preferences'] ?? {}),
      overallTips: List<String>.from(json['overallTips'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'profileScore': profileScore,
    'photos': photos.toJson(),
    'bio': bio.toJson(),
    'personalDetails': personalDetails.toJson(),
    'lifestyle': lifestyle.toJson(),
    'interests': interests.toJson(),
    'preferences': preferences.toJson(),
    'overallTips': overallTips,
  };
}

class SectionAnalysis {
  final int score;
  final List<String> feedback;
  final String? improvedExample;
  final List<String>? suggestions;

  SectionAnalysis({
    required this.score,
    required this.feedback,
    this.improvedExample,
    this.suggestions,
  });

  factory SectionAnalysis.fromJson(Map<String, dynamic> json) {
    return SectionAnalysis(
      score: json['score'] ?? 0,
      feedback: List<String>.from(json['feedback'] ?? []),
      improvedExample: json['improvedExample'],
      suggestions: json['suggestions'] != null ? List<String>.from(json['suggestions']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'score': score,
    'feedback': feedback,
    'improvedExample': improvedExample,
    'suggestions': suggestions,
  };
}
