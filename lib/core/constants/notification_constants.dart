class NotificationConstants {
  // Notification Types
  static const String typeChat = 'CHAT';
  static const String typeProfile = 'PROFILE';
  static const String typeCall = 'CALL';
  static const String typeSystem = 'SYSTEM';
  static const String typeCallSignal = 'CALL_SIGNAL';

  // Payload Keys
  static const String keyType = 'type';
  static const String keyRoute = 'route';
  static const String keyLink = 'link';
  static const String keyChatId = 'chatId';
  static const String keyRoomId = 'roomId'; // Sometimes used interchangeably with chatId
  static const String keyProfileId = 'profileId';
  static const String keyUserId = 'userId';
  static const String keySenderId = 'senderId';
  static const String keySenderPhotoUrl = 'senderPhotoUrl';
  static const String keyCallerId = 'callerId';
  static const String keyCalleeId = 'calleeId';
  static const String keyCallId = 'callId';
  static const String keyCallType = 'callType';
  static const String keyAction = 'action';
  static const String keyTitle = 'title';
  static const String keyBody = 'body';
  static const String keyDescription = 'description';
  static const String keyScreen = 'screen';

  // Screen Identifiers (mapped to routes mostly, but good for payload consistency)
  static const String screenChat = 'chat_screen';
  static const String screenProfile = 'profile_screen';
  static const String screenCall = 'call_screen';
  static const String screenHome = 'home_screen';
  static const String screenDiscover = 'DISCOVER';
  static const String screenNearby = 'NEARBY';

  // Message Type Descriptions (for notification body)
  static const String msgDescriptionText = ''; // Use actual message text
  static const String msgDescriptionImage = 'Sent an image';
  static const String msgDescriptionImages = 'Sent images';
  static const String msgDescriptionReaction = 'Reacted to your message';
  static const String msgDescriptionVoice = 'Sent a voice message';
  static const String msgDescriptionVideo = 'Sent a video';
  
  // Profile Interaction Descriptions
  static const String profileDescriptionLike = 'Liked your profile';
  static const String profileDescriptionMatch = 'You have a new match!';

  // Topic Names
  static const String topicAllUsers = 'all_users';
  static const String topicMale = 'male';
  static const String topicFemale = 'female';
}
