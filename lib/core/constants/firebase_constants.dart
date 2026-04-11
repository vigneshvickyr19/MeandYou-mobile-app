class FirebaseConstants {
  // Collection Names
  static const String users = 'users';
  static const String profileSetup = 'profileSetup';
  static const String currentLocations = 'current_locations';
  static const String chats = 'chats';
  static const String messages = 'messages';
  static const String notifications = 'notifications';
  static const String admin = 'admin';
  static const String helpCenter = 'help_center';
  static const String announcements = 'announcements';
  static const String dailyStats = 'daily_stats';
  static const String profileImages = 'profile_images';
  static const String benefits = 'benefits';
  static const String subscriptionPlans = 'subscription_plans';
  static const String userSubscriptions = 'user_subscriptions';
  static const String subscriptionHistory = 'subscription_history';

  // Field Names
  static const String lastMessageAt = 'lastMessageAt';
  static const String lastMessageTime = 'lastMessageTime';
  static const String updatedAt = 'updatedAt';
  static const String createdAt = 'createdAt';
  static const String participants = 'participants';
  static const String unreadCount = 'unreadCount';
  static const String typing = 'typing';
  static const String lastMessage = 'lastMessage';
  static const String lastMessageSenderId = 'lastMessageSenderId';
  static const String isGroup = 'isGroup';
  static const String groupName = 'groupName';
  static const String groupImage = 'groupImage';
  static const String status = 'status';
  static const String senderId = 'senderId';
  static const String receiverId = 'receiverId';
  static const String content = 'content';
  static const String type = 'type';
  static const String timestamp = 'timestamp';
  static const String imageUrl = 'imageUrl';
  static const String reactions = 'reactions'; // Map<String, String> {userId: emoji}
  static const String emojiReactions = 'emojiReactions';
  static const String likeCount = 'likeCount';
  static const String isDeleted = 'isDeleted';
  static const String chatRoomId = 'chatRoomId';
  static const String replyToMessageId = 'replyToMessageId';
  static const String replyToContent = 'replyToContent';
  static const String replyToSenderName = 'replyToSenderName';
  static const String isPinned = 'isPinned';
  static const String isEdited = 'isEdited';
  static const String isUnsent = 'isUnsent';
  static const String deletedFor = 'deletedFor'; // List<String> userIds
  static const String pinnedMessageId = 'pinnedMessageId';
  static const String fullName = 'fullName';
  static const String profileImageUrl = 'profileImageUrl';
  static const String fcmToken = 'fcmToken';
  static const String voipToken = 'voipToken';
  static const String isOnline = 'isOnline';
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String email = 'email';
  static const String phoneNumber = 'phoneNumber';
  static const String isProfileComplete = 'isProfileComplete';
  static const String isVerified = 'isVerified';
  static const String likes = 'likes';
  static const String matches = 'matches';
  static const String fromUserId = 'fromUserId';
  static const String toUserId = 'toUserId';
  static const String isMutual = 'isMutual';
  static const String age = 'age';
  static const String address = 'address';
  static const String geohash = 'geohash';
  static const String interests = 'interests';
  static const String preferences = 'preferences';
  static const String blockedUsers = 'blockedUsers';
  static const String swipedUsers = 'swipedUsers';
  static const String lastLocationUpdate = 'lastLocationUpdate';
  static const String gender = 'gender';
  static const String lookingFor = 'lookingFor';
  static const String minAge = 'minAge';
  static const String maxAge = 'maxAge';
  static const String role = 'role';
  static const String settings = 'settings';
  static const String imageVersion = 'imageVersion';
  static const String thumbnailUrl = 'thumbnailUrl';

  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String chatImagesPath = 'chat_images';
  static const String chatAudioPath = 'chat_audio';

  // Realtime Database Paths
  static const String statusPath = 'status';
  static const String typingPath = 'typing';
  static const String activeChatsPath = 'activeChats';
}
