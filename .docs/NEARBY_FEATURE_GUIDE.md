# Nearby Users Feature - Implementation Guide

## Overview
This document explains the implementation of the nearby users feature with a topographic map-style UI, based on the provided design references.

## Architecture

### Data Flow
```
Firebase (profileSetup) 
  ↓
MatchingRepository 
  ↓
GetNearbyMatchesUseCase 
  ↓
NearbyController 
  ↓
NearbyTab (UI)
```

## Key Components

### 1. **Data Layer**

#### Firebase Collection Structure
```
profileSetup/
  ├── {userId}/
      ├── fullName: string
      ├── age: number
      ├── photoUrl: string
      ├── latitude: number
      ├── longitude: number
      ├── geohash: string
      ├── address: string
      ├── interests: array
      ├── gender: string
      └── preferences: map
```

#### MatchingRepositoryImpl
**Location:** `lib/features/matching/data/repositories/matching_repository_impl.dart`

**Key Methods:**
- `getNearbyMatches()` - Queries users from `profileSetup` collection using geohash
- `updateLocation()` - Updates user's location in `profileSetup` collection
- `_calculateDistance()` - Haversine formula for distance calculation
- `_calculateMatchPercentage()` - Weighted scoring based on interests, preferences, age, distance

**Geohash Query:**
```dart
.collection(FirebaseConstants.profileSetup)
.where('geohash', isGreaterThanOrEqualTo: precisionPrefix)
.where('geohash', isLessThanOrEqualTo: '$precisionPrefix\uf8ff')
```

### 2. **Domain Layer**

#### NearbyMatchEntity
**Location:** `lib/features/matching/domain/entities/nearby_match_entity.dart`

**Fields:**
- `id`: User ID
- `fullName`: User's full name
- `profileImageUrl`: Profile photo URL
- `distance`: Distance in kilometers (double)
- `matchPercentage`: Match score (0-100)
- `address`: Location address
- `age`: User's age
- `latitude`, `longitude`: Geo-coordinates
- `interests`: List of interests

#### Use Cases
1. **GetNearbyMatchesUseCase** - Fetches nearby users within radius
2. **UpdateLocationUseCase** - Updates current user's location
3. **GetCurrentUserProfileUseCase** - Fetches current user's full profile with location

### 3. **Presentation Layer**

#### NearbyController
**Location:** `lib/features/matching/presentation/controllers/nearby_controller.dart`

**Responsibilities:**
- Manages nearby users list
- Handles user selection state
- Listens to real-time location updates
- Calculates user positions on screen
- Formats distance strings

**Key Methods:**
```dart
loadUsers(UserModel currentUser) // Initialize and load nearby users
selectUser(NearbyMatchEntity match) // Select a user to show details
closeSelectedUser() // Deselect user
getUserPosition(int index, Size size) // Calculate radial position
getDistanceString(NearbyMatchEntity user) // Format distance (m/km)
```

#### NearbyTab (Main UI)
**Location:** `lib/features/home/presentation/pages/nearby_tab.dart`

**UI Layers (from bottom to top):**
1. **Topographic Wave Background** - Animated flowing contour lines
2. **Connection Lines** - Lines connecting current user to nearby users
3. **Central User Avatar** - Large avatar with orange ring
4. **Radial Nearby Users** - Smaller avatars positioned radially
5. **Profile Preview Card** - Slides up when user is selected
6. **Empty State** - Shown when no nearby users found

**Key Features:**
- ✅ Distance hidden by default on connection lines
- ✅ Distance badge appears when user is tapped (orange pill)
- ✅ Smooth animations for card appearance
- ✅ Dark-themed design with topographic waves
- ✅ Real-time updates

#### ProfilePreviewCard
**Location:** `lib/features/home/presentation/widgets/profile_preview_card.dart`

**Design Specifications:**
- Large circular avatar (100x100)
- Name and age display
- Distance badge (shows meters if < 1km, otherwise km)
- Location information
- Single "View Profile" button (orange gradient)
- Close button (X)
- Glassmorphism effect

**Distance Formatting:**
```dart
String _formatDistance(double distanceInKm) {
  if (distanceInKm < 1) {
    return '${(distanceInKm * 1000).toInt()}m';  // e.g., "200m"
  }
  return '${distanceInKm.toStringAsFixed(1)}km';  // e.g., "2.5km"
}
```

## UI Interaction Flow

### Default State (No Selection)
```
┌─────────────────────────────────┐
│  Topographic Wave Background    │
│                                 │
│    👤 ← faint line → 👤         │
│         (small)    (small)      │
│                                 │
│         🔴 YOU                  │
│       (large, orange ring)      │
│                                 │
│    👤 ← faint line → 👤         │
│  (small)           (small)      │
└─────────────────────────────────┘
```

### Selected State (User Tapped)
```
┌─────────────────────────────────┐
│  Topographic Wave Background    │
│                                 │
│    👤                           │
│         ╲                       │
│          ╲  [200m] ← Orange     │
│           ╲  badge              │
│         🔴 YOU                  │
│                                 │
│  ┌───────────────────────────┐  │
│  │  👤 (large avatar)        │  │
│  │  Jenny Wilson, 26    200m │  │
│  │  📍 Near by Starbucks     │  │
│  │  📍 2972 Westheimer Rd... │  │
│  │  ┌─────────────────────┐  │  │
│  │  │  View Profile       │  │  │
│  │  └─────────────────────┘  │  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘
```

## Distance Calculation

### Haversine Formula Implementation
```dart
double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const p = 0.017453292519943295; // Math.PI / 180
  final a = 0.5 -
      math.cos((lat2 - lat1) * p) / 2 +
      math.cos(lat1 * p) *
          math.cos(lat2 * p) *
          (1 - math.cos((lon2 - lon1) * p)) /
          2;
  return 12742 * math.asin(math.sqrt(a)); // 2 * R; R = 6371 km
}
```

**Returns:** Distance in kilometers (double)

## Match Percentage Calculation

### Weighted Scoring System
```dart
double _calculateMatchPercentage(
  UserModel currentUser,
  Map<String, dynamic> otherData,
  double distance,
  double radiusInKm,
) {
  double score = 0;

  // 1. Interests (40%)
  final common = currentUser.interests
      .where((i) => otherInterests.contains(i))
      .length;
  score += (common / currentUser.interests.length) * 40;

  // 2. Preferences (30%)
  if (myLookingFor == otherGender) {
    score += 30;
  }

  // 3. Age Range (20%)
  if (otherAge >= minAge && otherAge <= maxAge) {
    score += 20;
  }

  // 4. Distance (10%)
  score += (1 - (distance / radiusInKm)) * 10;

  return math.min(100, math.max(1, score));
}
```

## Styling & Design

### Color Palette
```dart
Primary Orange: #E85D04
Secondary Orange: #FF8C42
Background: #000000 (Black)
Card Background: #1A1A1A (Dark Gray)
Text Primary: #FFFFFF (White)
Text Secondary: rgba(255, 255, 255, 0.5)
```

### Topographic Wave Colors
```dart
Green: #10B981
Yellow: #FBBF24
Orange: #E85D04
Blue: #3B82F6
```

### Typography
- **Name/Age:** 22px, Semi-bold (w600)
- **Distance Badge:** 13px, Medium (w500)
- **Location:** 14px, Regular
- **Button:** 16px, Semi-bold (w600)

### Spacing
- Card Padding: 24px
- Avatar Top Offset: -50px
- Button Height: 52px
- Border Radius: 16-24px

## Real-Time Updates

### Location Update Trigger
- **Minimum Distance:** 500 meters
- **Accuracy:** High (LocationAccuracy.high)
- **Distance Filter:** 100 meters

### Firestore Listeners
```dart
_matchesSubscription = _getNearbyMatchesUseCase(
  currentUser: _currentUser!,
  radiusInKm: 10.0,
).listen((matches) {
  _users = matches;
  _isLoading = false;
  notifyListeners();
});
```

## Performance Optimizations

1. **Geohash Indexing** - Fast proximity queries
2. **Distance Filter** - Only query users within 10km radius
3. **Debounced Location Updates** - Update only when moved 500m+
4. **Efficient Rendering** - CustomPainter for background waves
5. **Lazy Loading** - Profile data loaded on demand

## Error Handling

### Location Permission Denied
```dart
permission = await Geolocator.requestPermission();
if (permission == LocationPermission.denied) return;
```

### No Location Data
```dart
if (userGeohash.isEmpty) return Stream.value([]);
```

### Network Errors
```dart
errorBuilder: (_, __, ___) => Container(
  color: Colors.grey[800],
  child: const Icon(Icons.person, color: Colors.white24),
)
```

## Testing Checklist

- [ ] Distance shown in meters when < 1km
- [ ] Distance shown in km when >= 1km
- [ ] Distance badge hidden by default
- [ ] Distance badge appears on tap
- [ ] Profile card slides up smoothly
- [ ] Connection line highlights selected user
- [ ] Real-time location updates work
- [ ] Nearby users update when location changes
- [ ] Empty state shows when no users nearby
- [ ] Close button dismisses profile card

## Future Enhancements

1. **Filter by Interests** - Show only users with common interests
2. **Distance Slider** - Adjust search radius dynamically
3. **Online Status** - Show green dot for online users
4. **Last Seen** - Display when user was last active
5. **Mutual Likes** - Highlight users who liked you back
6. **Chat Integration** - Quick message from profile card
7. **Block/Report** - User safety features

---

**Last Updated:** 2026-02-01
**Version:** 1.0.0
