# Windows Developer Mode Setup

## Issue

Flutter on Windows requires Developer Mode to be enabled for symlink support when building with plugins.

## Solution

### Enable Developer Mode

1. **Open Settings:**
   - Press `Windows + I` to open Settings
   - OR run this command in PowerShell:
     ```powershell
     start ms-settings:developers
     ```

2. **Enable Developer Mode:**
   - Navigate to: **Settings > Privacy & Security > For developers**
   - Toggle **Developer Mode** to **On**
   - Accept the User Account Control prompt if it appears

3. **Restart (if needed):**
   - Some systems may require a restart after enabling Developer Mode

### Verify the Fix

After enabling Developer Mode, run:

```powershell
flutter clean
flutter pub get
flutter run
```

## Alternative: Run as Administrator

If you cannot enable Developer Mode, you can run your terminal as Administrator:

1. Right-click on PowerShell or Command Prompt
2. Select "Run as administrator"
3. Navigate to your project directory
4. Run `flutter run`

## What This Enables

Developer Mode enables:
- Symlink creation without admin privileges
- Better development tools integration
- Faster build times with Flutter plugins
- Required for many Flutter packages

## Troubleshooting

If you still encounter issues after enabling Developer Mode:

1. **Restart your terminal** - Close and reopen PowerShell/Command Prompt
2. **Restart your IDE** - Close and reopen VS Code or Android Studio
3. **Clear Flutter cache:**
   ```powershell
   flutter clean
   flutter pub cache repair
   flutter pub get
   ```

4. **Verify Developer Mode is enabled:**
   ```powershell
   start ms-settings:developers
   ```

## Deep Linking Fix Applied

The namespace issue with `uni_links` has already been fixed by adding:
```gradle
namespace 'name.avioli.unilinks'
```

to the package's `build.gradle` file.
