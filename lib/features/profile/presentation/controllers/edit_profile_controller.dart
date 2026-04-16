import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/models/profile_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/storage_service.dart';
import '../../data/repositories/profile_repository.dart';
import '../../../../core/constants/firebase_constants.dart';

class EditProfileController extends ChangeNotifier {
  final AuthProvider _authProvider;
  final ProfileRepository _profileRepository = ProfileRepository();
  final StorageService _storageService = StorageService.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  ProfileModel? _originalProfile;
  ProfileModel? _draftProfile;
  bool _isLoading = false;
  bool _isSaving = false;

  double _completenessScore = 0.0;
  String? _photoFeedback;


  EditProfileController(this._authProvider);

  ProfileModel? get draftProfile => _draftProfile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  double get completenessScore => _completenessScore;
  String? get photoFeedback => _photoFeedback;

  bool get hasChanges {
    if (_originalProfile == null || _draftProfile == null) return false;
    return _calculateChanges().isNotEmpty;
  }

  int? get age => _draftProfile?.age;

  Future<void> loadProfile() async {
    final userId = _authProvider.currentUser?.id;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _originalProfile = await _profileRepository.getProfile(userId);
      _draftProfile = _originalProfile?.copyWith();
      _calculateCompletenessScore();
    } catch (e) {
      debugPrint("Error loading profile for edit: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateCompletenessScore() {
    if (_draftProfile == null) return;
    
    int totalFields = 0;
    int filledFields = 0;

    void check(dynamic value) {
      totalFields++;
      if (value != null && value.toString().isNotEmpty) {
        if (value is List) {
          if (value.isNotEmpty) filledFields++;
        } else {
          filledFields++;
        }
      }
    }

    // Identity
    check(_draftProfile!.fullName);
    check(_draftProfile!.dob);
    check(_draftProfile!.gender);
    
    // Photos (Weight them more)
    final photoCount = _draftProfile!.photos?.length ?? 0;
    totalFields += 2; // Extra weight
    if (photoCount >= 1) filledFields++;
    if (photoCount >= 3) filledFields++;
    if (photoCount >= 6) filledFields++;

    // Bio
    check(_draftProfile!.bio);
    
    // Details
    check(_draftProfile!.height);
    check(_draftProfile!.jobTitle);
    check(_draftProfile!.education);
    check(_draftProfile!.hometown);

    // Lifestyle
    check(_draftProfile!.drinking);
    check(_draftProfile!.smoking);
    check(_draftProfile!.exercise);
    check(_draftProfile!.diet);
    
    // Interests
    check(_draftProfile!.interests);

    _completenessScore = (filledFields / totalFields).clamp(0.0, 1.0);
  }

  void updateDraft(ProfileModel Function(ProfileModel) update) {
    if (_draftProfile == null) return;
    _draftProfile = update(_draftProfile!);
    _calculateCompletenessScore();
    notifyListeners();
  }

  Map<String, dynamic> _calculateChanges() {
    if (_originalProfile == null || _draftProfile == null) return {};

    final originalMap = _originalProfile!.toMap();
    final draftMap = _draftProfile!.toMap();
    final changes = <String, dynamic>{};

    draftMap.forEach((key, value) {
      if (key == 'photos') {
        // Handle photos separately if needed, but for comparison:
        if (!_areListsEqual(originalMap[key], value)) {
          changes[key] = value;
        }
      } else if (originalMap[key] != value) {
        changes[key] = value;
      }
    });

    return changes;
  }

  bool _areListsEqual(dynamic list1, dynamic list2) {
    if (list1 == list2) return true;
    if (list1 == null || list2 == null) return false;
    if (list1 is! List || list2 is! List) return false;
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  Future<bool> saveProfile() async {
    final userId = _authProvider.currentUser?.id;
    if (userId == null || _draftProfile == null) return false;

    final changes = _calculateChanges();
    if (changes.isEmpty) return true; // Exit silently as requested

    _isSaving = true;
    notifyListeners();

    try {
      // 1. Handle Photos if they changed
      if (changes.containsKey('photos')) {
        final List<String> updatedPhotos = await _handlePhotoUploads(userId);
        changes['photos'] = updatedPhotos;
        // Sync draft with network URLs
        _draftProfile = _draftProfile!.copyWith(photos: updatedPhotos);
      }

      // 2. Update Firebase Profile
      await _profileRepository.updateProfile(userId, changes);
      
      // 3. Sync core fields to 'users' collection to ensure UI refreshes everywhere
      // 3. Sync core fields to 'users' collection to ensure UI refreshes everywhere
      if (changes.containsKey('photos')) {
        final Map<String, dynamic> userSync = {};
        final List<dynamic> photos = changes['photos'] as List;
        if (photos.isNotEmpty) {
           final firstPhotoMeta = _lastUploadedAvatarMeta;
           if (firstPhotoMeta != null) {
              userSync[FirebaseConstants.profileImageUrl] = firstPhotoMeta[FirebaseConstants.profileImageUrl];
              userSync[FirebaseConstants.thumbnailUrl] = firstPhotoMeta[FirebaseConstants.thumbnailUrl];
              userSync[FirebaseConstants.imageVersion] = firstPhotoMeta[FirebaseConstants.imageVersion];
           } else {
              userSync[FirebaseConstants.profileImageUrl] = photos.first;
           }
        }
        
        if (userSync.isNotEmpty) {
          await _db
              .collection(FirebaseConstants.users)
              .doc(userId)
              .update(userSync);
        }
      }

      // Update original profile to current draft after successful save
      _originalProfile = _draftProfile;
      return true;
    } catch (e) {
      debugPrint("Error saving profile: $e");
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Map<String, dynamic>? _lastUploadedAvatarMeta;

  Future<List<String>> _handlePhotoUploads(String userId) async {
    final List<String> currentPhotos = _draftProfile?.photos ?? [];
    final List<String> finalPhotos = List.from(currentPhotos);
    _lastUploadedAvatarMeta = null;

    for (int i = 0; i < currentPhotos.length; i++) {
        final path = currentPhotos[i];
        if (path.isEmpty) continue;

        // If it's a local file path (not a URL)
        if (!path.startsWith('http')) {
          final file = File(path);
          if (await file.exists()) {
            if (i == 0) {
              // Primary Profile Image (Full + Thumbnail + Versioning)
              final meta = await _storageService.uploadUserAvatar(
                userId: userId,
                originalFile: file,
              );
              _lastUploadedAvatarMeta = meta;
              finalPhotos[i] = meta[FirebaseConstants.profileImageUrl];
            } else {
              // Secondary Photos
              final downloadUrl = await _storageService.uploadProfileImage(
                userId: userId,
                file: file,
                index: i,
              );
              finalPhotos[i] = downloadUrl;
            }

            // Optional: Backup URL in separate collection
            await _db.collection(FirebaseConstants.profileImages).add({
              'userId': userId,
              'url': finalPhotos[i],
              'index': i,
              'uploadedAt': FieldValue.serverTimestamp(),
            });
          }
        }
    }
    
    // Cleanup empty strings if any
    finalPhotos.removeWhere((p) => p.isEmpty);
    return finalPhotos;
  }

  // --- AI Suggestion Methods ---

  Future<List<String>> getBioSuggestions() async {
    // In a real app, this would call Gemini or another AI service
    // For now, providing high-quality templates based on profile context
    await Future.delayed(const Duration(seconds: 1)); // Simulate AI lag
    
    return [
      "Coffee lover and tech enthusiast on a quest for the best sunset spots in ${_draftProfile?.city ?? 'town'}.",
      "Passionate about ${_draftProfile?.interests?.take(2).join(', ') ?? 'new experiences'}. Looking for someone to share good vibes and even better conversations.",
      "Adventurer at heart, ${_draftProfile?.jobTitle ?? 'professional'} by day. I believe in ${_draftProfile?.personality ?? 'keeping things real'}.",
    ];
  }

  PhotoAnalysisDetail getPhotoAnalysis(int index) {
    if (_draftProfile?.photos == null || index >= _draftProfile!.photos!.length) {
       return PhotoAnalysisDetail(score: 0, label: "Missing", feedback: "Add a photo", color: Colors.grey);
    }
    
    // Simulating granular analysis for each photo
    if (index == 0) {
      return PhotoAnalysisDetail(
        score: 95, 
        label: "Excellent", 
        feedback: "Perfect primary photo. Good lighting and clear face visibility.",
        color: Colors.greenAccent,
      );
    } else if (index == 1) {
      return PhotoAnalysisDetail(
        score: 70, 
        label: "Good", 
        feedback: "Nice shot, but try a background with more contrast.",
        color: Colors.blueAccent,
      );
    } else if (index == 2) {
      return PhotoAnalysisDetail(
        score: 45, 
        label: "Fair", 
        feedback: "Image is a bit blurry. Higher resolution would be better.",
        color: Colors.orangeAccent,
      );
    }
    
    return PhotoAnalysisDetail(
      score: 80, 
      label: "Great", 
      feedback: "Good variety! This helps show your personality.",
      color: Colors.greenAccent,
    );
  }

  String getScoreAdvice() {
    if (_completenessScore < 0.4) return "Add more photos to get 2x more matches!";
    if (_completenessScore < 0.7) return "A detailed bio helps people know you better.";
    if (_completenessScore < 0.9) return "Almost perfect! Add your lifestyle preferences.";
    return "Your profile looks amazing!";
  }
}

class PhotoAnalysisDetail {
  final int score;
  final String label;
  final String feedback;
  final Color color;

  PhotoAnalysisDetail({
    required this.score, 
    required this.label, 
    required this.feedback, 
    required this.color,
  });
}
