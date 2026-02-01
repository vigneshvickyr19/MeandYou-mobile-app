import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_constants.dart';

enum MessageType { text, image, video, audio }

enum MessageStatus { sent, delivered, seen }

class MessageModel {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final String? imageUrl;
  final List<String> imageUrls;
  final String? audioUrl;
  final String? duration;
  final List<String> reactions;
  final int likeCount;
  final bool isDeleted;

  MessageModel({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    required this.timestamp,
    this.imageUrl,
    this.imageUrls = const [],
    this.audioUrl,
    this.duration,
    this.reactions = const [],
    this.likeCount = 0,
    this.isDeleted = false,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      chatRoomId: map[FirebaseConstants.chatRoomId] ?? '',
      senderId: map[FirebaseConstants.senderId] ?? '',
      receiverId: map[FirebaseConstants.receiverId] ?? '',
      content: map[FirebaseConstants.content] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${map[FirebaseConstants.type]}',
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == 'MessageStatus.${map[FirebaseConstants.status]}',
        orElse: () => MessageStatus.sent,
      ),
      timestamp: map[FirebaseConstants.timestamp] != null 
          ? (map[FirebaseConstants.timestamp] as Timestamp).toDate()
          : DateTime.now(),
      imageUrl: map[FirebaseConstants.imageUrl],
      imageUrls: map['imageUrls'] != null 
          ? List<String>.from(map['imageUrls']) 
          : const [],
      audioUrl: map['audioUrl'],
      duration: map['duration'],
      reactions: map[FirebaseConstants.reactions] != null ? List<String>.from(map[FirebaseConstants.reactions]) : const [],
      likeCount: map[FirebaseConstants.likeCount] ?? 0,
      isDeleted: map[FirebaseConstants.isDeleted] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirebaseConstants.chatRoomId: chatRoomId,
      FirebaseConstants.senderId: senderId,
      FirebaseConstants.receiverId: receiverId,
      FirebaseConstants.content: content,
      FirebaseConstants.type: type.toString().split('.').last,
      FirebaseConstants.status: status.toString().split('.').last,
      FirebaseConstants.timestamp: Timestamp.fromDate(timestamp),
      FirebaseConstants.imageUrl: imageUrl,
      'imageUrls': imageUrls,
      'audioUrl': audioUrl,
      'duration': duration,
      FirebaseConstants.reactions: reactions,
      FirebaseConstants.likeCount: likeCount,
      FirebaseConstants.isDeleted: isDeleted,
    };
  }

  MessageModel copyWith({
    String? id,
    String? chatRoomId,
    String? senderId,
    String? receiverId,
    String? content,
    MessageType? type,
    MessageStatus? status,
    DateTime? timestamp,
    String? imageUrl,
    List<String>? imageUrls,
    String? audioUrl,
    String? duration,
    List<String>? reactions,
    int? likeCount,
    bool? isDeleted,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      reactions: reactions ?? this.reactions,
      likeCount: likeCount ?? this.likeCount,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
