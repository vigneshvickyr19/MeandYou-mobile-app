import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class LocationService {
  /// Reverse geocodes [latitude] and [longitude] to a readable address.
  /// Returns a map with 'landmark' and 'area' keys.
  static Future<Map<String, String>> getReadableLocation(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Privacy-focused: Avoid house numbers
        String landmark = "";
        if (place.name != null && 
            place.name!.isNotEmpty && 
            !place.name!.contains(RegExp(r'^\d+$'))) {
          // If name is not just a number (likely a building name or landmark)
          landmark = "Near ${place.name}";
        } else if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
          // Fallback to street name (thoroughfare)
          landmark = "Near ${place.thoroughfare}";
        } else if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          landmark = "In ${place.subLocality}";
        } else {
          landmark = "Nearby";
        }

        // "Santa Ana, Illinois"
        String area = "";
        List<String> areaParts = [];
        if (place.locality != null && place.locality!.isNotEmpty) {
          areaParts.add(place.locality!);
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          areaParts.add(place.administrativeArea!);
        }
        area = areaParts.join(", ");

        // Full Address: "2972 Westheimer Rd, Santa Ana, Illinois 85486"
        // We still provide this but as secondary text
        String fullAddress = "";
        List<String> addressParts = [];
        if (place.thoroughfare != null) addressParts.add(place.thoroughfare!);
        if (place.locality != null) addressParts.add(place.locality!);
        if (place.administrativeArea != null) addressParts.add(place.administrativeArea!);
        if (place.postalCode != null) addressParts.add(place.postalCode!);
        fullAddress = addressParts.join(", ");

        return {
          'landmark': landmark,
          'area': area,
          'fullAddress': fullAddress,
        };
      }
    } catch (e) {
      debugPrint("Geocoding failed: $e");
    }
    return {
      'landmark': 'Unknown Location',
      'area': 'Nearby',
      'fullAddress': 'Address not available',
    };
  }

  /// Opens Google Maps (or Apple Maps on iOS) at the given [latitude] and [longitude].
  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    String appleUrl = 'https://maps.apple.com/?sll=$latitude,$longitude';

    try {
      if (Platform.isIOS) {
        final appleUri = Uri.parse(appleUrl);
        if (await canLaunchUrl(appleUri)) {
          await launchUrl(appleUri);
          return;
        }
      }

      final googleUri = Uri.parse(googleUrl);
      if (await canLaunchUrl(googleUri)) {
        await launchUrl(googleUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to browser if app is not installed
        await launchUrl(googleUri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint("Could not open maps: $e");
      // Fallback to browser
      final googleUri = Uri.parse(googleUrl);
      await launchUrl(googleUri, mode: LaunchMode.platformDefault);
    }
  }

  /// Single reusable function to fetch and format the location address/name.
  /// If [latitude] or [longitude] are null, it fetches the current position.
  /// Returns a formatted string like "Near Central Park, Manhattan".
  static Future<String> fetchAndFormatLocation({double? latitude, double? longitude}) async {
    double lat = latitude ?? 0;
    double lng = longitude ?? 0;

    if (latitude == null || longitude == null) {
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) return "Location disabled";

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) return "Permission denied";
        }
        
        if (permission == LocationPermission.deniedForever) return "Permission denied";

        Position position = await Geolocator.getCurrentPosition();
        lat = position.latitude;
        lng = position.longitude;
      } catch (e) {
        debugPrint("Error fetching current position: $e");
        return "Unknown Location";
      }
    }

    final locationMap = await getReadableLocation(lat, lng);
    final landmark = locationMap['landmark'] ?? "";
    final area = locationMap['area'] ?? "";

    if (landmark.isNotEmpty && area.isNotEmpty) {
      return "$landmark, $area";
    } else if (area.isNotEmpty) {
      return area;
    } else if (landmark.isNotEmpty) {
      return landmark;
    }
    
    return "Nearby";
  }
}
