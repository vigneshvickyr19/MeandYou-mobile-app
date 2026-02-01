import '../../features/matching/domain/entities/nearby_match_entity.dart';

/// Utility class for formatting location and distance information
/// 
/// This class provides reusable methods for displaying user location data
/// across different features (Discover, Nearby, Profile, etc.)
/// 
/// Usage:
/// ```dart
/// final locationText = LocationFormatter.getLocationName(match);
/// final distanceText = LocationFormatter.getDistanceString(match.distance);
/// final fullLocation = LocationFormatter.getFullLocationDisplay(match);
/// ```
class LocationFormatter {
  /// Private constructor to prevent instantiation
  LocationFormatter._();

  /// Get formatted distance string
  /// 
  /// Returns:
  /// - "500m" for distances less than 1km
  /// - "2.5km" for distances 1km or more
  /// 
  /// Example:
  /// ```dart
  /// LocationFormatter.getDistanceString(0.5) // "500m"
  /// LocationFormatter.getDistanceString(2.3) // "2.3km"
  /// ```
  static String getDistanceString(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).toInt()}m';
    }
    return '${distanceInKm.toStringAsFixed(1)}km';
  }

  /// Get location name from NearbyMatchEntity
  /// 
  /// Priority order:
  /// 1. area (if available)
  /// 2. landmark (if available)
  /// 3. address (first 2 parts, comma-separated)
  /// 4. fullAddress (if available)
  /// 5. "Location unknown" (fallback)
  /// 
  /// Example:
  /// ```dart
  /// LocationFormatter.getLocationName(match) // "Downtown, New York"
  /// ```
  static String getLocationName(NearbyMatchEntity match) {
    // Priority 1: Use area if available
    if (match.area != null && match.area!.isNotEmpty) {
      return match.area!;
    }

    // Priority 2: Use landmark if available
    if (match.landmark != null && match.landmark!.isNotEmpty) {
      return match.landmark!;
    }

    // Priority 3: Extract from address (first 2 parts)
    if (match.address != null && match.address!.isNotEmpty) {
      final parts = match.address!.split(',');
      if (parts.length >= 2) {
        return parts.take(2).join(',').trim();
      }
      return match.address!;
    }

    // Priority 4: Use full address if available
    if (match.fullAddress != null && match.fullAddress!.isNotEmpty) {
      final parts = match.fullAddress!.split(',');
      if (parts.length >= 2) {
        return parts.take(2).join(',').trim();
      }
      return match.fullAddress!;
    }

    // Fallback
    return 'Location unknown';
  }

  /// Get full location display with distance
  /// 
  /// Returns formatted string like "Downtown, New York • 2.5km"
  /// 
  /// Example:
  /// ```dart
  /// LocationFormatter.getFullLocationDisplay(match) 
  /// // "Downtown, New York • 2.5km"
  /// ```
  static String getFullLocationDisplay(NearbyMatchEntity match) {
    final location = getLocationName(match);
    final distance = getDistanceString(match.distance);
    return '$location • $distance';
  }

  /// Get short location (area only, no landmark)
  /// 
  /// Returns just the area/city name without detailed address
  /// 
  /// Example:
  /// ```dart
  /// LocationFormatter.getShortLocation(match) // "New York"
  /// ```
  static String getShortLocation(NearbyMatchEntity match) {
    if (match.area != null && match.area!.isNotEmpty) {
      return match.area!;
    }

    if (match.address != null && match.address!.isNotEmpty) {
      final parts = match.address!.split(',');
      if (parts.isNotEmpty) {
        return parts.first.trim();
      }
    }

    return 'Unknown';
  }

  /// Get detailed location (landmark + area)
  /// 
  /// Returns combined landmark and area if both available
  /// 
  /// Example:
  /// ```dart
  /// LocationFormatter.getDetailedLocation(match) 
  /// // "Central Park, Manhattan"
  /// ```
  static String getDetailedLocation(NearbyMatchEntity match) {
    final List<String> parts = [];

    if (match.landmark != null && match.landmark!.isNotEmpty) {
      parts.add(match.landmark!);
    }

    if (match.area != null && match.area!.isNotEmpty) {
      parts.add(match.area!);
    }

    if (parts.isEmpty) {
      return getLocationName(match);
    }

    return parts.join(', ');
  }

  /// Check if location data is available
  /// 
  /// Returns true if any location field has valid data
  /// 
  /// Example:
  /// ```dart
  /// if (LocationFormatter.hasLocationData(match)) {
  ///   // Show location
  /// }
  /// ```
  static bool hasLocationData(NearbyMatchEntity match) {
    return (match.area != null && match.area!.isNotEmpty) ||
           (match.landmark != null && match.landmark!.isNotEmpty) ||
           (match.address != null && match.address!.isNotEmpty) ||
           (match.fullAddress != null && match.fullAddress!.isNotEmpty);
  }

  /// Get location with fallback
  /// 
  /// Returns location name or custom fallback text
  /// 
  /// Example:
  /// ```dart
  /// LocationFormatter.getLocationWithFallback(match, "No location set")
  /// ```
  static String getLocationWithFallback(
    NearbyMatchEntity match,
    String fallback,
  ) {
    final location = getLocationName(match);
    return location == 'Location unknown' ? fallback : location;
  }
}
