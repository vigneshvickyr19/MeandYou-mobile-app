import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  like,
  match,
  message,
}

class AppNotification {
  final String id;
  final String receiverId;
  final String senderId;
  final String senderName;
  final String? senderPhotoUrl;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? metadata;

  AppNotification({
    required this.id,
    required this.receiverId,
    required this.senderId,
    required this.senderName,
    this.senderPhotoUrl,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.metadata,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map, String docId) {
    return AppNotification(
      id: docId,
      receiverId: map['receiverId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderPhotoUrl: map['senderPhotoUrl'],
      type: _typeFromString(map['type']),
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
      metadata: map['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'receiverId': receiverId,
      'senderId': senderId,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'type': type.name,
      'title': title,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': isRead,
      'metadata': metadata,
    };
  }

  static NotificationType _typeFromString(String? type) {
    switch (type) {
      case 'like':
        return NotificationType.like;
      case 'match':
        return NotificationType.match;
      case 'message':
        return NotificationType.message;
      default:
        return NotificationType.message;
    }
  }
}
