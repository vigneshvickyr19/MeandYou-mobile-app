# Web Platform Notes

## Deep Linking on Web

Deep linking works differently on web compared to mobile platforms:

### How It Works

**Mobile (Android/iOS):**
- Uses custom URL scheme: `meandyou://`
- OS intercepts the URL and opens the app
- Works from browser, email, SMS, etc.

**Web:**
- Uses browser URL routing
- `app_links` package captures URL changes
- Must filter out localhost URLs

### Implementation Details

The `DeepLinkService` now includes URL scheme validation:

```dart
// Only process custom scheme links (meandyou://)
// Ignore http/https URLs (web platform localhost, etc.)
if (uri.scheme != 'meandyou') {
  debugPrint('Ignoring non-deep-link URL with scheme: ${uri.scheme}');
  return;
}
```

This prevents the service from trying to process:
- `http://localhost:52061/` (development server)
- `https://yourdomain.com/` (production web URL)
- Other non-deep-link URLs

### Testing on Web

**Note:** Custom URL schemes (`meandyou://`) don't work in web browsers for security reasons.

For web platform, you would typically use:
1. **Hash routing:** `https://yourdomain.com/#/profile/123`
2. **Path routing:** `https://yourdomain.com/profile/123`
3. **Query parameters:** `https://yourdomain.com/?page=profile&id=123`

### Recommended Approach

**For Mobile Apps:** Use custom scheme (`meandyou://`) - ✅ Implemented
**For Web Apps:** Use standard HTTP URLs with path/hash routing - Not implemented (web is not primary target)

### Current Status

✅ **Mobile (Android/iOS):** Fully functional with `meandyou://` scheme
✅ **Web:** App runs without errors, but deep linking is disabled
⚠️ **Web Deep Links:** Custom schemes don't work in browsers (browser limitation)

### If You Need Web Deep Linking

To enable deep linking on web, you would need to:

1. **Use Flutter's built-in routing** instead of custom schemes
2. **Implement URL path parsing** for web
3. **Use `go_router` package** for unified routing across platforms

Example with `go_router`:
```dart
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomePage(),
    ),
    GoRoute(
      path: '/profile/:userId',
      builder: (context, state) {
        final userId = state.pathParameters['userId'];
        return ProfilePage(userId: userId);
      },
    ),
  ],
);
```

Then web URLs would work like:
- `http://localhost/#/profile/123`
- `https://yourdomain.com/profile/123`

### Conclusion

The current implementation is **optimized for mobile apps** (Android/iOS) where custom URL schemes work perfectly. Web platform is supported for development/testing, but deep linking is intentionally filtered out to prevent errors.

If you need full web deep linking support, consider migrating to `go_router` for cross-platform URL routing.
