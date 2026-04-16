import '../constants/app_routes.dart';

class NotificationMessage {
  final String title;
  final String body;
  final String route;

  const NotificationMessage({
    required this.title,
    required this.body,
    required this.route,
  });
}

class NotificationPool {
  static const List<NotificationMessage> morningMessages = [
    NotificationMessage(
      title: "Good Morning! ☀️",
      body: "Someone viewed your profile while you were sleeping! 👀",
      route: AppRoutes.likes,
    ),
    NotificationMessage(
      title: "Wake up to Love ☕",
      body: "New profiles are active near you right now! 📍",
      route: AppRoutes.home,
    ),
    NotificationMessage(
      title: "Fresh Starts 💖",
      body: "Your daily matches are ready. Check them out!",
      route: AppRoutes.home,
    ),
    // ... adding more below in bulk
  ];

  static const List<NotificationMessage> afternoonMessages = [
    NotificationMessage(
      title: "Taking a break? 🥯",
      body: "You've got a new message waiting for a reply 💬",
      route: AppRoutes.chat,
    ),
    NotificationMessage(
      title: "Lunchtime Spark ✨",
      body: "A potential match is active nearby! Say hi? 👋",
      route: AppRoutes.home,
    ),
  ];

  static const List<NotificationMessage> eveningMessages = [
    NotificationMessage(
      title: "Evening Vibes 🌙",
      body: "The community is most active now! Don't miss out 🔥",
      route: AppRoutes.home,
    ),
    NotificationMessage(
      title: "Night Owl? 🦉",
      body: "Someone just liked your latest photo! See who it is 💖",
      route: AppRoutes.likes,
    ),
  ];

  static final List<NotificationMessage> allMessages = [
    // Matches & Likes
    const NotificationMessage(title: "It's a Match! 💖", body: "Check out your new match now!", route: AppRoutes.likes),
    const NotificationMessage(title: "Someone Likes You 👀", body: "Click to see who's interested!", route: AppRoutes.likes),
    const NotificationMessage(title: "Hidden Admirer? 🕵️", body: "Someone is checking you out. Intrigued?", route: AppRoutes.likes),
    const NotificationMessage(title: "New Attention! ✨", body: "Your profile is getting some love today!", route: AppRoutes.likes),
    const NotificationMessage(title: "Don't keep them waiting! ⏳", body: "You have new likes pending review.", route: AppRoutes.likes),
    
    // Nearby
    const NotificationMessage(title: "Close by! 📍", body: "Dating is better nearby. See who's 1km away!", route: AppRoutes.home),
    const NotificationMessage(title: "Local Singles Active 🔥", body: "People near you are looking to chat!", route: AppRoutes.home),
    const NotificationMessage(title: "Neighborhood Spark 🏘️", body: "A great profile just popped up near you!", route: AppRoutes.home),
    const NotificationMessage(title: "Around the Corner 🗺️", body: "Explore new connections in your area!", route: AppRoutes.home),
    
    // Chat
    const NotificationMessage(title: "New Message 💬", body: "Don't leave them on read! Click to reply.", route: AppRoutes.chat),
    const NotificationMessage(title: "Keep the Spark ⚡", body: "Your conversation is waiting for you!", route: AppRoutes.chat),
    const NotificationMessage(title: "Typing... ✍️", body: "Someone might be waiting for your hello!", route: AppRoutes.chat),
    const NotificationMessage(title: "Don't Ghost! 👋", body: "Continue that great conversation from earlier.", route: AppRoutes.chat),
    const NotificationMessage(title: "A Secret Message? 🤫", body: "You have unread chats. Check them now!", route: AppRoutes.chat),

    // Profile Boost
    const NotificationMessage(title: "Boost Your Profile 🚀", body: "Add a new photo to get 3x more matches!", route: AppRoutes.editProfile),
    const NotificationMessage(title: "Profile Audit 📝", body: "AI says your bio can be 50% better. Improve now!", route: AppRoutes.editProfile),
    const NotificationMessage(title: "Stand Out! ⭐", body: "Complete your lifestyle tags for better matches.", route: AppRoutes.editProfile),
    const NotificationMessage(title: "Photo Update 📸", body: "Fresh photos lead to fresh dates! Update now.", route: AppRoutes.editProfile),
    const NotificationMessage(title: "Optimized Bio 🪄", body: "Use our AI to write a bio that actually works!", route: AppRoutes.editProfile),

    // Subscription/Premium
    const NotificationMessage(title: "Unlock Gold 💎", body: "See who already liked you with Premium!", route: AppRoutes.likes),
    const NotificationMessage(title: "Go Unlimited ♾️", body: "Don't let swipes run out. Get Premium now!", route: AppRoutes.likes),
    const NotificationMessage(title: "Premium Access 👑", body: "Get featured at the top of the discovery list!", route: AppRoutes.likes),
    const NotificationMessage(title: "Special Offer 🎁", body: "Premium is 30% off today only. Don't miss out!", route: AppRoutes.likes),

    // Discover
    const NotificationMessage(title: "New Faces 💖", body: "We found 10 new people you might like!", route: AppRoutes.home),
    const NotificationMessage(title: "Discovery Mode 🔍", body: "New profiles waiting for your swipe!", route: AppRoutes.home),
    const NotificationMessage(title: "Your Daily Stack 📚", body: "Your curated matches have arrived. Check them!", route: AppRoutes.home),
    const NotificationMessage(title: "Don't Miss Out! 🏃", body: "The perfect match might be in your stack right now.", route: AppRoutes.home),
    const NotificationMessage(title: "Swipe Time! 🎡", body: "Take a break and find someone special today.", route: AppRoutes.home),

    // Extra High Engagement
    const NotificationMessage(title: "Hey You! 👋", body: "Someone is thinking about you right now...", route: AppRoutes.likes),
    const NotificationMessage(title: "Match Alert! 🚨", body: "We think we found your perfect partner!", route: AppRoutes.home),
    const NotificationMessage(title: "Is it Destiny? 🔮", body: "See who the universe picked for you today.", route: AppRoutes.home),
    const NotificationMessage(title: "Bored? Let's Chat! ☕", body: "Active users are waiting for a conversation.", route: AppRoutes.home),
    const NotificationMessage(title: "Confidence Is Key 🗝️", body: "Your profile was shown to 100 people today!", route: AppRoutes.likes),
    const NotificationMessage(title: "Trending! 🔥", body: "Your profile is hot today! See your new views.", route: AppRoutes.likes),
    const NotificationMessage(title: "First Move? ♟️", body: "It's your turn to say hi to your matches!", route: AppRoutes.chat),
    const NotificationMessage(title: "Secret Admirer? 🤫", body: "Someone just viewed your bio. Who could it be?", route: AppRoutes.likes),
    const NotificationMessage(title: "Love is in the Air ☁️", body: "Explore new connections around you today.", route: AppRoutes.home),
    const NotificationMessage(title: "Double Take! 👀", body: "Someone liked you twice! Check it out.", route: AppRoutes.likes),
    const NotificationMessage(title: "Instant Connection ⚡", body: "Fast-track your dating life with these picks.", route: AppRoutes.home),
    const NotificationMessage(title: "Weekend Ready? 🥂", body: "Find a date for the weekend right now!", route: AppRoutes.home),
    const NotificationMessage(title: "Better Together 👫", body: "New people joined Me & You today. Meet them!", route: AppRoutes.home),
    const NotificationMessage(title: "Spark Something New 🎆", body: "Your journey to love continues here.", route: AppRoutes.home),
    const NotificationMessage(title: "Feeling Lucky? 🍀", body: "Your soulmate might be just one swipe away.", route: AppRoutes.home),
    const NotificationMessage(title: "Profile Pick of the Day 🏆", body: "We've selected someone special for you.", route: AppRoutes.home),
    const NotificationMessage(title: "Curiosity Killed the Cat 🐈", body: "But it might find you a match! Peek now.", route: AppRoutes.likes),
    const NotificationMessage(title: "Say Hello! 👋", body: "A friendly 'Hi' goes a long way. Start chatting!", route: AppRoutes.chat),
    const NotificationMessage(title: "Refresh Your Vibe 🌊", body: "Small profile changes lead to BIG results.", route: AppRoutes.editProfile),
    const NotificationMessage(title: "The Wait is Over 🎉", body: "Check out who just joined your neighborhood.", route: AppRoutes.home),
  ];
}
