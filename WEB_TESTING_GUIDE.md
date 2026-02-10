# Testing Deep Links from Web Browser

## Quick Start - Using the HTML Test File

### Method 1: Open HTML File Directly

1. **Open the test file in your browser:**
   ```
   File location: C:\Users\vignesh.ra\ME_-_YOU\deep_link_test.html
   ```

2. **Double-click** `deep_link_test.html` or right-click → "Open with" → Your browser

3. **Click any link** to test deep linking:
   - 🏠 Home Tab
   - ❤️ Likes Tab  
   - 💬 Chat Tab
   - 👤 Profile Tab
   - Profile with user ID
   - Chat with chat ID

### Method 2: Serve via Local Server (Recommended for Mobile Testing)

#### Option A: Using Python

```bash
# Navigate to project directory
cd C:\Users\vignesh.ra\ME_-_YOU

# Python 3
python -m http.server 8000

# Python 2
python -m SimpleHTTPServer 8000
```

Then open: `http://localhost:8000/deep_link_test.html`

#### Option B: Using Node.js (http-server)

```bash
# Install http-server globally (one time)
npm install -g http-server

# Navigate to project directory
cd C:\Users\vignesh.ra\ME_-_YOU

# Start server
http-server -p 8000
```

Then open: `http://localhost:8000/deep_link_test.html`

#### Option C: Using PHP

```bash
cd C:\Users\vignesh.ra\ME_-_YOU
php -S localhost:8000
```

Then open: `http://localhost:8000/deep_link_test.html`

### Method 3: Test from Mobile Device

If you want to test from your phone (connected to same WiFi):

1. **Start a local server** (see Method 2)

2. **Find your computer's IP address:**
   ```powershell
   ipconfig
   ```
   Look for "IPv4 Address" (e.g., 192.168.1.100)

3. **Open on your phone:**
   ```
   http://192.168.1.100:8000/deep_link_test.html
   ```

4. **Click links** to test deep linking on your phone!

## Testing Methods Comparison

| Method | Use Case | Pros | Cons |
|--------|----------|------|------|
| **Direct File** | Quick desktop testing | Instant, no setup | Desktop only |
| **Local Server** | Mobile testing | Test on real device | Requires server setup |
| **ADB Commands** | Automated testing | Scriptable, precise | Command line only |
| **Browser Address Bar** | Quick single tests | Fast, simple | Manual typing |

## Browser-Based Testing Steps

### Desktop Testing (Chrome/Edge/Firefox)

1. **Open** `deep_link_test.html` in browser
2. **Click** any deep link button
3. **Browser will prompt:** "Open ME_-_YOU?"
4. **Click "Open"** or "Allow"
5. **App launches** with the specified route!

### Mobile Testing (Android)

1. **Connect phone** to same WiFi as computer
2. **Start local server** on computer
3. **Open browser** on phone (Chrome recommended)
4. **Navigate to** `http://YOUR_IP:8000/deep_link_test.html`
5. **Tap any link**
6. **App opens** automatically!

### Mobile Testing (iOS)

1. **Connect iPhone** to same WiFi as computer
2. **Start local server** on computer
3. **Open Safari** on iPhone
4. **Navigate to** `http://YOUR_IP:8000/deep_link_test.html`
5. **Tap any link**
6. **Tap "Open"** when prompted
7. **App launches!**

## Testing Specific Features

### Test Bottom Tab Navigation

Click these links to test tab switching:
- `meandyou://home/tab/0` → Home tab
- `meandyou://home/tab/1` → Likes tab
- `meandyou://home/tab/2` → Chat tab
- `meandyou://home/tab/3` → Profile tab

**Expected Result:** App opens and switches to the specified tab

### Test Parameter Passing

Click these links to test parameters:
- `meandyou://profile/user123` → Shows "User ID: user123"
- `meandyou://chat/chat789` → Shows "Chat ID: chat789"

**Expected Result:** App opens and displays the parameter value

### Test Navigation Stack

1. Open app normally
2. Click `meandyou://home/tab/2` from browser
3. **Expected:** App switches to chat tab (clears stack)

## Alternative Testing Methods

### 1. Browser Address Bar

Simply type in the address bar:
```
meandyou://home/tab/2
```
Press Enter → App opens!

### 2. Create Bookmark

1. Create a bookmark with URL: `meandyou://profile/user123`
2. Click bookmark → App opens!

### 3. QR Code

Generate QR codes for deep links:

**Online Tools:**
- https://www.qr-code-generator.com/
- https://qr.io/

**Example:**
1. Generate QR for `meandyou://home/tab/2`
2. Scan with phone camera
3. Tap notification → App opens!

### 4. Email/SMS Links

**HTML Email:**
```html
<a href="meandyou://profile/user123">View Profile</a>
```

**Plain Text:**
```
Check out this profile: meandyou://profile/user123
```

### 5. WhatsApp/Telegram

Send a message with:
```
meandyou://home/tab/2
```
Tap the link → App opens!

## Testing Checklist

Use this checklist to verify all deep linking functionality:

### Basic Navigation
- [ ] `meandyou://home` opens home
- [ ] `meandyou://login` opens login
- [ ] `meandyou://signup` opens signup

### Tab Navigation
- [ ] `meandyou://home/tab/0` opens home tab
- [ ] `meandyou://home/tab/1` opens likes tab
- [ ] `meandyou://home/tab/2` opens chat tab
- [ ] `meandyou://home/tab/3` opens profile tab

### Parameters
- [ ] `meandyou://profile/123` shows user ID
- [ ] `meandyou://chat/456` shows chat ID
- [ ] Invalid IDs handled gracefully

### App States
- [ ] Works when app is closed (cold start)
- [ ] Works when app is in background
- [ ] Works when app is already open

### Error Handling
- [ ] Invalid routes redirect to home
- [ ] Missing parameters handled
- [ ] Malformed URLs don't crash app

## Troubleshooting Web Testing

### Link Doesn't Work

**Problem:** Clicking link does nothing

**Solutions:**
1. Make sure app is installed
2. Try different browser (Chrome recommended)
3. Check if custom scheme is registered
4. Restart browser after app installation

### Browser Blocks Deep Link

**Problem:** Browser shows security warning

**Solutions:**
1. Click "Allow" or "Open"
2. Add exception in browser settings
3. Use incognito/private mode
4. Try different browser

### Mobile Browser Issues

**Problem:** Links don't work on mobile browser

**Solutions:**
1. Use Chrome on Android (best support)
2. Use Safari on iOS (best support)
3. Ensure app is installed
4. Try long-press → "Open in app"

### Server Not Accessible on Phone

**Problem:** Can't access `http://192.168.x.x:8000`

**Solutions:**
1. Check both devices on same WiFi
2. Disable Windows Firewall temporarily
3. Use correct IP address (run `ipconfig`)
4. Try different port (8080, 3000, etc.)

## Advanced Testing

### Automated Testing Script

Create `test_deep_links.html` with JavaScript:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Automated Deep Link Test</title>
</head>
<body>
    <h1>Automated Testing</h1>
    <button onclick="testAllLinks()">Test All Links</button>
    <div id="results"></div>

    <script>
        const links = [
            'meandyou://home',
            'meandyou://home/tab/1',
            'meandyou://profile/123',
            'meandyou://chat/456'
        ];

        function testAllLinks() {
            links.forEach((link, index) => {
                setTimeout(() => {
                    window.location.href = link;
                    console.log(`Testing: ${link}`);
                }, index * 2000); // 2 seconds between tests
            });
        }
    </script>
</body>
</html>
```

### Analytics Tracking

Add to your HTML to track clicks:

```javascript
document.querySelectorAll('a[href^="meandyou://"]').forEach(link => {
    link.addEventListener('click', (e) => {
        console.log('Deep link clicked:', e.target.href);
        // Send to analytics
        // gtag('event', 'deep_link_click', { url: e.target.href });
    });
});
```

## Best Practices

1. **Always test on real devices** - Emulators may behave differently
2. **Test different browsers** - Chrome, Safari, Firefox, Edge
3. **Test different app states** - Closed, background, foreground
4. **Test with/without parameters** - Ensure both work
5. **Test invalid links** - Verify error handling
6. **Document test results** - Keep track of what works

## Quick Reference

**Test File Location:**
```
C:\Users\vignesh.ra\ME_-_YOU\deep_link_test.html
```

**Start Local Server:**
```bash
python -m http.server 8000
```

**Access from Phone:**
```
http://YOUR_IP:8000/deep_link_test.html
```

**ADB Command:**
```bash
adb shell am start -W -a android.intent.action.VIEW -d "meandyou://home/tab/2"
```

**iOS Simulator:**
```bash
xcrun simctl openurl booted "meandyou://home/tab/2"
```

Happy Testing! 🚀
