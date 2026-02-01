# Debug Logs Guide - Nearby Matches Feature

## Overview
Comprehensive logging has been added to help debug why nearby users might not be matching or appearing.

---

## 🔍 What to Look For in Logs

### 1. **NearbyController Initialization**
```
🚀 NearbyController: Loading users...
📱 Initial User: John Doe (user123)
🔄 Fetching full profile from profileSetup...
✅ Profile loaded:
   Name: John Doe
   Location: lat=37.7749, lng=-122.4194
   Geohash: 9q8yy
   Interests: [hiking, music, travel]
   Gender: male
   Preferences: {lookingFor: female, minAge: 22, maxAge: 35, distance: 10}
```

**What to Check:**
- ✅ Location (lat/lng) should NOT be null or 0
- ✅ Geohash should NOT be empty
- ✅ Interests should be populated
- ✅ Preferences should be set

**Common Issues:**
- ❌ Location is null → User hasn't set location
- ❌ Geohash is empty → Location not converted to geohash
- ❌ Interests is empty → Will get 0% for interest matching
- ❌ Preferences is null → Will get 0% for gender/age matching

---

### 2. **Nearby Matches Query**
```
🎧 Starting nearby matches subscription with 10km radius...

🔍 ===== NEARBY MATCHES DEBUG =====
📍 Current User: John Doe (user123)
📍 Current Location: lat=37.7749, lng=-122.4194
📍 Current Geohash: 9q8yy
📍 Search Radius: 10.0km
📍 Current User Interests: [hiking, music, travel]
📍 Current User Gender: male
📍 Current User Preferences: {lookingFor: female, minAge: 22, maxAge: 35}
🔎 Geohash Prefix for Query: 9q8y

📦 Firestore Query Results: 5 documents found
```

**What to Check:**
- ✅ Search Radius is 10km (default)
- ✅ Geohash prefix is at least 4 characters
- ✅ Firestore returns some documents

**Common Issues:**
- ❌ 0 documents found → No users in profileSetup collection nearby
- ❌ Geohash prefix too short → Query too broad
- ❌ Geohash prefix too long → Query too narrow

---

### 3. **User Filtering**
```
👤 Checking User: Jane Smith
   Location: lat=37.7833, lng=-122.4167
   Geohash: 9q8yy9
   📏 Distance: 1.23km
   ✅ INCLUDED: Distance 1.23km within radius
```

**Exclusion Reasons:**
```
⏭️  Skipped: John Doe (self)
🚫 Skipped: Alice Brown (blocked)
👉 Skipped: Bob Wilson (already swiped)
❌ EXCLUDED: Distance 15.67km > 10.0km radius
```

**What to Check:**
- ✅ Users within 10km are included
- ✅ Self is excluded
- ✅ Blocked users are excluded
- ✅ Already swiped users are excluded

**Common Issues:**
- ❌ All users beyond 10km → Increase radius or check location accuracy
- ❌ All users already swiped → Clear swipedUsers array for testing
- ❌ Distance calculation wrong → Check lat/lng values

---

### 4. **Match Percentage Calculation**
```
   💯 Calculating Match % for Jane Smith:
      🎯 Interests: 2 common / 3 total = 26.7% (max 40%)
         My interests: [hiking, music, travel]
         Their interests: [hiking, music, cooking]
      ⚧️  Gender Match: ✅ 30.0% (looking for: female, they are: female)
      🎂 Age Match: ✅ 20.0% (age: 28, range: 22-35)
      📏 Distance: 8.8% (1.23km / 10.0km radius)
      ✨ TOTAL MATCH: 85.5%
```

**Scoring Breakdown:**
- **Interests (40% max):** Common interests / Total interests × 40
- **Gender (30%):** Looking for matches their gender
- **Age (20%):** Their age within your range
- **Distance (10%):** Closer = higher score

**What to Check:**
- ✅ Interest score > 0 (need common interests)
- ✅ Gender match = 30% (if preferences set correctly)
- ✅ Age match = 20% (if age in range)
- ✅ Distance score > 0 (closer is better)

**Common Issues:**
- ❌ 0% interests → No common interests
- ❌ 0% gender → Looking for wrong gender
- ❌ 0% age → Age outside your range
- ❌ Low total → Check all preferences are set

---

### 5. **Final Summary**
```
📊 ===== SUMMARY =====
✅ Total Included: 3 users
⏭️  Excluded (Self): 1
🚫 Excluded (Blocked): 0
👉 Excluded (Swiped): 1
📏 Excluded (Distance): 0
🎯 Final Matches: 3

🏆 Top Matches:
   1. Jane Smith - 85.5% (1.23km)
   2. Sarah Johnson - 72.3% (3.45km)
   3. Emily Davis - 58.1% (7.89km)
================================
```

**What to Check:**
- ✅ Final Matches > 0
- ✅ Top matches have reasonable percentages
- ✅ Distances are within 10km

**If NO MATCHES:**
```
⚠️  NO MATCHES FOUND!
💡 Possible reasons:
   - No users in profileSetup collection
   - All users are beyond 10.0km radius
   - All users are blocked or already swiped
   - Current user location not set properly
```

---

## 🐛 Common Issues & Solutions

### Issue 1: "NO MATCHES FOUND"
**Symptoms:**
```
📦 Firestore Query Results: 0 documents found
⚠️  NO MATCHES FOUND!
```

**Solutions:**
1. Check if users exist in `profileSetup` collection
2. Verify users have `latitude`, `longitude`, `geohash` fields
3. Check if geohash is calculated correctly
4. Increase search radius from 10km to 50km for testing

---

### Issue 2: "Current user has no geohash"
**Symptoms:**
```
📍 Current Geohash: 
❌ ERROR: Current user has no geohash! Cannot search nearby users.
```

**Solutions:**
1. Ensure location permission is granted
2. Check if `GetCurrentUserProfileUseCase` is fetching location
3. Verify `profileSetup` document has geohash field
4. Manually set location for testing

---

### Issue 3: "All users excluded by distance"
**Symptoms:**
```
📏 Excluded (Distance): 10
🎯 Final Matches: 0
```

**Solutions:**
1. Increase radius: Change `radiusInKm: 10.0` to `radiusInKm: 50.0`
2. Check if user locations are realistic (not 0,0)
3. Verify Haversine distance calculation is correct

---

### Issue 4: "Low match percentages"
**Symptoms:**
```
✨ TOTAL MATCH: 12.5%
```

**Solutions:**
1. **Add interests:** Set interests in profile
2. **Set preferences:** Configure gender, age range
3. **Check gender:** Ensure looking for correct gender
4. **Check age range:** Widen age range (e.g., 18-99)

---

## 📊 Expected Log Flow

### Successful Match Flow:
```
1. 🚀 NearbyController: Loading users...
2. ✅ Profile loaded with location & geohash
3. 🎧 Starting nearby matches subscription
4. 🔍 ===== NEARBY MATCHES DEBUG =====
5. 📦 Firestore Query Results: X documents found
6. 👤 Checking User: [for each user]
7. ✅ INCLUDED: [users within radius]
8. 💯 Calculating Match %: [detailed breakdown]
9. 📊 ===== SUMMARY =====
10. 🏆 Top Matches: [list of matches]
11. 📥 Received X matches from stream
```

### Failed Match Flow:
```
1. 🚀 NearbyController: Loading users...
2. ❌ Location is null or geohash is empty
   OR
3. 📦 Firestore Query Results: 0 documents found
   OR
4. ❌ EXCLUDED: All users beyond radius
   OR
5. ⚠️  NO MATCHES FOUND!
```

---

## 🔧 Testing Tips

### 1. Test with Mock Data
Create test users in Firestore:
```javascript
// User 1 (nearby)
{
  fullName: "Test User 1",
  latitude: 37.7749,
  longitude: -122.4194,
  geohash: "9q8yy9",
  age: 25,
  gender: "female",
  interests: ["hiking", "music"]
}

// User 2 (far away)
{
  fullName: "Test User 2",
  latitude: 40.7128,
  longitude: -74.0060,
  geohash: "dr5reg",
  age: 30,
  gender: "female",
  interests: ["travel"]
}
```

### 2. Temporarily Increase Radius
In `nearby_controller.dart`, change:
```dart
radiusInKm: 10.0  →  radiusInKm: 5000.0  // 5000km for testing
```

### 3. Clear Filters
Temporarily disable filters in `matching_repository_impl.dart`:
```dart
// Comment out these lines for testing
// if (currentUser.blockedUsers.contains(userId)) continue;
// if (currentUser.swipedUsers.contains(userId)) continue;
```

### 4. Set Default Match Score
For testing, set minimum match to 1%:
```dart
return math.min(100, math.max(1, score));  // Always at least 1%
```

---

## 📝 Log Analysis Checklist

When debugging, check these in order:

- [ ] Current user has valid location (not null, not 0,0)
- [ ] Current user has geohash
- [ ] Current user has interests set
- [ ] Current user has preferences set
- [ ] Firestore query returns documents
- [ ] Users have valid locations
- [ ] Users are within 10km radius
- [ ] Users are not blocked/swiped
- [ ] Match percentage calculation runs
- [ ] Final matches list is not empty

---

## 🎯 Quick Diagnosis

| Log Message | Meaning | Action |
|-------------|---------|--------|
| `❌ ERROR: Current user has no geohash!` | No location set | Enable location, update profile |
| `📦 Firestore Query Results: 0 documents` | No users nearby | Add test users or increase radius |
| `📏 Excluded (Distance): X` | All users too far | Increase radius to 50km+ |
| `🎯 Interests: 0%` | No common interests | Add interests to profile |
| `⚧️  Gender Match: ❌ 0%` | Wrong gender preference | Check lookingFor setting |
| `🎂 Age Match: ❌ 0%` | Age outside range | Widen age range |
| `✨ TOTAL MATCH: 1.0%` | Very low compatibility | Check all preferences |

---

**Last Updated:** 2026-02-01
**Default Radius:** 10km
**Minimum Match Score:** 1%
