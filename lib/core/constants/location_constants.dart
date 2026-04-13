class LocationConstants {
  // Geolocator settings
  static const int distanceFilter = 100; // meters
  static const int timeInterval = 10; // seconds (not used by all geolocator platforms)

  // Firestore update thresholds
  static const double minDistanceForUpdateInMeters = 500.0;
  static const int minTimeForUpdateInMinutes = 30;

  // Nearby search settings
  static const double defaultRadiusInKm = 10.0;
  static const int defaultFetchLimit = 20;

  // Background settings
  static const String backgroundTaskName = "com.meandyou.location_sync_task";
  static const int androidTaskFrequencyMins = 15;
}
