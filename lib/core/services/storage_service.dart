import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../constants/firebase_constants.dart';

/// Service to handle Firebase Storage operations with user-scoped isolation
/// 
/// Architecture:
/// - Profile Images: profile_images/{userId}/photo_{index}_v{timestamp}.jpg
/// - Chat Images: chat_images/{userId}/{messageId}_{index}.jpg
/// - Chat Audio: chat_audio/{userId}/{messageId}.m4a
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  
  StorageService._();

  /// Uploads a profile image for a specific user.
  /// Uses a timestamp-based versioning to avoid cache issues and provide historical clarity.
  Future<String> uploadProfileImage({
    required String userId,
    required File file,
    required int index,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = file.path.split('.').last;
      
      // Path: profile_images/{userId}/photo_{index}_v{timestamp}.{ext}
      final path = '${FirebaseConstants.profileImagesPath}/$userId/photo_${index}_v$timestamp.$extension';
      
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(
          contentType: 'image/$extension',
          customMetadata: {
            'userId': userId,
            'index': index.toString(),
            'uploadedAt': timestamp.toString(),
          },
        ),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      rethrow;
    }
  }

  /// Uploads multiple profile images in parallel.
  Future<List<String>> uploadProfileImages({
    required String userId,
    required List<File> files,
  }) async {
    final uploadTasks = <Future<String>>[];
    for (int i = 0; i < files.length; i++) {
        uploadTasks.add(uploadProfileImage(userId: userId, file: files[i], index: i));
    }
    return await Future.wait(uploadTasks);
  }

  /// Uploads a chat image scoped by userId for cleanup clarity.
  Future<String> uploadChatImage({
    required String userId,
    required String messageId,
    required File file,
    int index = 0,
  }) async {
    try {
      final extension = file.path.split('.').last;
      
      // Path: chat_images/{userId}/{messageId}_{index}.{ext}
      final path = '${FirebaseConstants.chatImagesPath}/$userId/${messageId}_$index.$extension';
      
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/$extension'),
      );

      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading chat image: $e');
      rethrow;
    }
  }

  /// Uploads chat audio scoped by userId.
  Future<String> uploadChatAudio({
    required String userId,
    required String messageId,
    required File file,
  }) async {
    try {
      // Path: chat_audio/{userId}/{messageId}.m4a
      final path = '${FirebaseConstants.chatAudioPath}/$userId/$messageId.m4a';
      
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(contentType: 'audio/m4a'),
      );

      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading chat audio: $e');
      rethrow;
    }
  }

  /// Deletes all files in a user's scoped folders.
  /// Useful for GDPR compliance and account deletion.
  /// 
  /// Note: Firebase Storage doesn't support folder deletion directly.
  /// We must list all files and delete them.
  Future<void> deleteUserStorageDetails(String userId) async {
    final folders = [
      '${FirebaseConstants.profileImagesPath}/$userId',
      '${FirebaseConstants.chatImagesPath}/$userId',
      '${FirebaseConstants.chatAudioPath}/$userId',
    ];

    for (final folder in folders) {
      try {
        final ref = _storage.ref().child(folder);
        final listResult = await ref.listAll();
        
        final deleteTasks = <Future<void>>[];
        for (final item in listResult.items) {
          deleteTasks.add(item.delete());
        }
        
        await Future.wait(deleteTasks);
        debugPrint('Successfully cleaned up storage folder: $folder');
      } catch (e) {
        // If folder doesn't exist, ignore
        debugPrint('Note: Cleanup for $folder failed or was not needed: $e');
      }
    }
  }
}
