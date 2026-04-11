import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
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

  /// Compresses an image and returns a temporary file.
  Future<File?> _compressImage(File file, {int quality = 85, int minWidth = 1000}) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.webp';
      
      return await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: minWidth,
        format: CompressFormat.webp,
      ).then((xFile) => xFile != null ? File(xFile.path) : null);
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return null;
    }
  }

  /// Generates a low-resolution thumbnail.
  Future<File?> _generateThumbnail(File file) async {
    return await _compressImage(file, quality: 50, minWidth: 200);
  }

  /// Uploads a profile photo (full + thumbnail) with automated versioning.
  /// This implements Requirement #2 (Url Versioning), #4 (Upload Flow), and #6 (Thumbnail Optimization).
  Future<Map<String, dynamic>> uploadUserAvatar({
    required String userId,
    required File originalFile,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // 1. Compress Full Image
      final compressedFull = await _compressImage(originalFile) ?? originalFile;
      
      // 2. Generate Thumbnail
      final thumbnailFile = await _generateThumbnail(originalFile) ?? compressedFull;

      // 3. Upload Full Image
      final fullPath = '${FirebaseConstants.profileImagesPath}/$userId/profile_v$timestamp.webp';
      final fullRef = _storage.ref().child(fullPath);
      await fullRef.putFile(compressedFull, SettableMetadata(contentType: 'image/webp'));
      final fullUrl = await fullRef.getDownloadURL();

      // 4. Upload Thumbnail
      final thumbPath = '${FirebaseConstants.profileImagesPath}/$userId/thumb_v$timestamp.webp';
      final thumbRef = _storage.ref().child(thumbPath);
      await thumbRef.putFile(thumbnailFile, SettableMetadata(contentType: 'image/webp'));
      final thumbUrl = await thumbRef.getDownloadURL();

      return {
        FirebaseConstants.profileImageUrl: fullUrl,
        FirebaseConstants.thumbnailUrl: thumbUrl,
        FirebaseConstants.imageVersion: timestamp,
      };
    } catch (e) {
      debugPrint('Error in uploadUserAvatar: $e');
      rethrow;
    }
  }

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
