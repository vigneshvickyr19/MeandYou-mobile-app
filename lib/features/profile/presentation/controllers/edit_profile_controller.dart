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

  EditProfileController(this._authProvider);

  ProfileModel? get draftProfile => _draftProfile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

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
    } catch (e) {
      debugPrint("Error loading profile for edit: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateDraft(ProfileModel Function(ProfileModel) update) {
    if (_draftProfile == null) return;
    _draftProfile = update(_draftProfile!);
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
      if (changes.containsKey('fullName') || changes.containsKey('photos')) {
        final Map<String, dynamic> userSync = {};
        if (changes.containsKey('fullName')) {
          userSync['fullName'] = changes['fullName'];
        }
        if (changes.containsKey('photos')) {
          final List<dynamic> photos = changes['photos'] as List;
          if (photos.isNotEmpty) {
            userSync['profileImageUrl'] = photos.first;
          }
        }
        
        if (userSync.isNotEmpty) {
          await _db.collection(FirebaseConstants.users).doc(userId).update(userSync);
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

  Future<List<String>> _handlePhotoUploads(String userId) async {
    final List<String> currentPhotos = _draftProfile?.photos ?? [];
    final List<String> finalPhotos = List.from(currentPhotos);

    for (int i = 0; i < currentPhotos.length; i++) {
        final path = currentPhotos[i];
        if (path.isEmpty) continue;

        // If it's a local file path (not a URL)
        if (!path.startsWith('http')) {
          final file = File(path);
          if (await file.exists()) {
            final downloadUrl = await _storageService.uploadProfileImage(
              userId: userId,
              file: file,
              index: i,
            );
            finalPhotos[i] = downloadUrl;

            // Store metadata in profile_images collection as requested
            await _db.collection(FirebaseConstants.profileImages).add({
              'userId': userId,
              'url': downloadUrl,
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
}
