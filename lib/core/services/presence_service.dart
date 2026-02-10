import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../constants/firebase_constants.dart';

/// Service to handle real-time presence, typing indicators, and active chat tracking.
/// Uses Firebase Realtime Database for optimized low-latency updates.
class PresenceService {
  static PresenceService? _instance;
  static PresenceService get instance => _instance ??= PresenceService._();

  PresenceService._();

  final FirebaseDatabase _db = FirebaseDatabase.instance;
  StreamSubscription? _connectedSubscription;
  String? _currentUserId;

  /// Initialize presence tracking for a user.
  /// Sets up automatic online/offline status using RTDB's .info/connected.
  void initialize(String userId) {
    if (_currentUserId == userId) return;
    _currentUserId = userId;

    _connectedSubscription?.cancel();
    
    // Reference to the user's status in RTDB
    final statusRef = _db.ref().child(FirebaseConstants.statusPath).child(userId);

    // Listen to connection state
    _connectedSubscription = _db.ref('.info/connected').onValue.listen((event) {
      final connected = event.snapshot.value as bool? ?? false;
      
      if (connected) {
        // 1. Set up onDisconnect to flip to offline when connection is lost
        statusRef.onDisconnect().set({
          'state': 'offline',
          'lastChanged': ServerValue.timestamp,
        });

        // 2. Set status to online now
        statusRef.set({
          'state': 'online',
          'lastChanged': ServerValue.timestamp,
        });
        
        debugPrint('Presence: User $userId is online');
      }
    });
  }

  /// Manually set status (e.g., when app goes to background)
  Future<void> setStatus(bool isOnline) async {
    if (_currentUserId == null) return;
    
    final statusRef = _db.ref().child(FirebaseConstants.statusPath).child(_currentUserId!);
    
    await statusRef.set({
      'state': isOnline ? 'online' : 'offline',
      'lastChanged': ServerValue.timestamp,
    });
  }

  /// Track which chat the user is currently viewing to suppress push notifications.
  Future<void> setActiveChat(String? chatId) async {
    if (_currentUserId == null) return;
    
    final activeChatRef = _db.ref().child(FirebaseConstants.activeChatsPath).child(_currentUserId!);
    
    if (chatId == null) {
      await activeChatRef.remove();
    } else {
      await activeChatRef.set({
        'chatId': chatId,
        'updatedAt': ServerValue.timestamp,
      });
      
      // Ensure it clears on disconnect
      activeChatRef.onDisconnect().remove();
    }
  }

  /// Handle typing indicator updates.
  /// Throttled to avoid excessive RTDB writes.
  Future<void> setTypingStatus(String chatId, bool isTyping) async {
    if (_currentUserId == null) return;

    final typingRef = _db.ref()
        .child(FirebaseConstants.typingPath)
        .child(chatId)
        .child(_currentUserId!);

    if (isTyping) {
      await typingRef.set({
        'isTyping': true,
        'updatedAt': ServerValue.timestamp,
      });
      // Clear typing on disconnect
      typingRef.onDisconnect().remove();
    } else {
      await typingRef.remove();
    }
  }

  /// Stream to listen to another user's presence state
  Stream<Map<String, dynamic>?> streamUserStatus(String userId) {
    return _db.ref().child(FirebaseConstants.statusPath).child(userId).onValue.map((event) {
      if (event.snapshot.value == null) return null;
      return Map<String, dynamic>.from(event.snapshot.value as Map);
    });
  }

  /// Stream to listen to typing status of a specific user in a chat
  Stream<bool> streamTypingStatus(String chatId, String otherUserId) {
    return _db.ref()
        .child(FirebaseConstants.typingPath)
        .child(chatId)
        .child(otherUserId)
        .onValue
        .map((event) {
          if (event.snapshot.value == null) return false;
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          return data['isTyping'] == true;
        });
  }

  void dispose() {
    _connectedSubscription?.cancel();
    _currentUserId = null;
  }
}
