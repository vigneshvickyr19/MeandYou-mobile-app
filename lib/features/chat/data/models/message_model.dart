import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_constants.dart';

enum MessageType { text, image, video, audio }

enum MessageStatus { sending, sent, delivered, seen, error }

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
  final Map<String, String> emojiReactions;
  final int likeCount;
  final bool isDeleted;
  final String? replyToMessageId;
  final String? replyToContent;
  final String? replyToSenderName;
  final bool isPinned;
  final bool isEdited;
  final bool isUnsent;
  final List<String> deletedFor;

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
    this.emojiReactions = const {},
    this.likeCount = 0,
    this.isDeleted = false,
    this.replyToMessageId,
    this.replyToContent,
    this.replyToSenderName,
    this.isPinned = false,
    this.isEdited = false,
    this.isUnsent = false,
    this.deletedFor = const [],
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
      emojiReactions: map[FirebaseConstants.emojiReactions] != null 
          ? Map<String, String>.from(map[FirebaseConstants.emojiReactions]) 
          : {},
      likeCount: map[FirebaseConstants.likeCount] ?? 0,
      isDeleted: map[FirebaseConstants.isDeleted] ?? false,
      replyToMessageId: map[FirebaseConstants.replyToMessageId],
      replyToContent: map[FirebaseConstants.replyToContent],
      replyToSenderName: map[FirebaseConstants.replyToSenderName],
      isPinned: map[FirebaseConstants.isPinned] ?? false,
      isEdited: map[FirebaseConstants.isEdited] ?? false,
      isUnsent: map[FirebaseConstants.isUnsent] ?? false,
      deletedFor: map[FirebaseConstants.deletedFor] != null 
          ? List<String>.from(map[FirebaseConstants.deletedFor]) 
          : const [],
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
      FirebaseConstants.emojiReactions: emojiReactions,
      FirebaseConstants.likeCount: likeCount,
      FirebaseConstants.isDeleted: isDeleted,
      FirebaseConstants.replyToMessageId: replyToMessageId,
      FirebaseConstants.replyToContent: replyToContent,
      FirebaseConstants.replyToSenderName: replyToSenderName,
      FirebaseConstants.isPinned: isPinned,
      FirebaseConstants.isEdited: isEdited,
      FirebaseConstants.isUnsent: isUnsent,
      FirebaseConstants.deletedFor: deletedFor,
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
    Map<String, String>? emojiReactions,
    int? likeCount,
    bool? isDeleted,
    String? replyToMessageId,
    String? replyToContent,
    String? replyToSenderName,
    bool? isPinned,
    bool? isEdited,
    bool? isUnsent,
    List<String>? deletedFor,
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
      emojiReactions: emojiReactions ?? this.emojiReactions,
      likeCount: likeCount ?? this.likeCount,
      isDeleted: isDeleted ?? this.isDeleted,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToContent: replyToContent ?? this.replyToContent,
      replyToSenderName: replyToSenderName ?? this.replyToSenderName,
      isPinned: isPinned ?? this.isPinned,
      isEdited: isEdited ?? this.isEdited,
      isUnsent: isUnsent ?? this.isUnsent,
      deletedFor: deletedFor ?? this.deletedFor,
    );
  }
}
