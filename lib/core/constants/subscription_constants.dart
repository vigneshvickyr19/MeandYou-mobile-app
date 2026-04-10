class SubscriptionBenefits {
  static const String seeWhoLikedYou = 'SEE_WHO_LIKE_YOU';
  static const String unlimitedLikes = 'UNLIMITED_LIKES';
  static const String setMorePreference = 'SET_MORE_PREFERENCE';

  // Helper to get all codes
  static List<String> get all => [
    seeWhoLikedYou,
    unlimitedLikes,
    setMorePreference,
  ];
}

class SubscriptionPlanCodes {
  static const String gold = 'gold';
  static const String platinum = 'platinum';
  static const String premium = 'premium';
}
