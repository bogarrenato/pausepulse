# Pause Pulse - Troubleshooting Guide

## 🤖 Android Emulator - Permission Issues

### Problem: "Permission Required" button doesn't work

**Root Causes:**
1. **QUERY_ALL_PACKAGES Permission**: Android 11+ requires special permission to query all installed packages
2. **Emulator Limitations**: Some permissions work differently in emulators
3. **Google Play Services**: Required for certain permission dialogs

**Solutions:**

#### 1. Enable Developer Options in Emulator
```bash
# In your emulator:
# 1. Go to Settings > About phone
# 2. Tap "Build number" 7 times
# 3. Go back to Settings > System > Developer options
# 4. Enable "Stay awake" and "USB debugging"
```

#### 2. Grant Permissions Manually
```bash
# Via ADB commands:
adb shell pm grant com.example.pause_pulse android.permission.QUERY_ALL_PACKAGES
adb shell pm grant com.example.pause_pulse android.permission.POST_NOTIFICATIONS
adb shell pm grant com.example.pause_pulse android.permission.READ_EXTERNAL_STORAGE
adb shell pm grant com.example.pause_pulse android.permission.WRITE_EXTERNAL_STORAGE
```

#### 3. Use Emulator with Google Play Services
- Create a new AVD with "Google Play" image (not "Google APIs")
- This provides better permission dialog support

#### 4. Alternative: Test on Real Device
- Real Android devices handle permissions more reliably
- Enable Developer Mode and USB Debugging on your physical device

### Updated Android Manifest Features

The app now includes:
- `QUERY_ALL_PACKAGES` for app discovery
- `POST_NOTIFICATIONS` for Android 13+ notification permissions
- `PACKAGE_USAGE_STATS` for better app information access
- Proper tools namespace to suppress lint warnings

### Code Improvements Made

1. **Enhanced Permission Handling**:
   - Multiple permission requests
   - Automatic settings redirect on permanent denial
   - Better error messages

2. **Improved User Experience**:
   - Clearer permission explanations
   - Multiple retry options
   - Direct link to app settings

## 📱 iOS - White Screen & Trust Issues

### Problem: White screen and idevicesyslog errors

**Root Causes:**
1. **Developer Certificate Trust**: iOS doesn't trust the developer certificate
2. **Device Management**: App isn't properly installed/trusted
3. **App Transport Security**: Network security restrictions
4. **Dependency Injection Failures**: Critical services not initializing

**Solutions:**

#### 1. Trust Developer Certificate
```bash
# On your iOS device:
# 1. Go to Settings > General > VPN & Device Management
# 2. Find your developer profile under "Developer App"
# 3. Tap it and select "Trust [Your Developer Name]"
# 4. Confirm by tapping "Trust" again
```

#### 2. Enable Developer Mode (iOS 16+)
```bash
# On your iOS device:
# 1. Go to Settings > Privacy & Security
# 2. Scroll down to "Developer Mode"
# 3. Toggle it ON
# 4. Restart your device when prompted
# 5. After restart, go back and confirm enabling Developer Mode
```

#### 3. Xcode Configuration
```bash
# In Xcode:
# 1. Open ios/Runner.xcworkspace (not .xcodeproj)
# 2. Select your device as target
# 3. Product > Build
# 4. If build succeeds, Product > Run
```

#### 4. Clean Build and Reinstall
```bash
flutter clean
cd ios
rm -rf Pods/ Podfile.lock
cd ..
flutter pub get
cd ios
pod install
cd ..
flutter run --debug
```

#### 5. Check iOS Bundle Identifier
Ensure your bundle identifier is unique:
```
# In ios/Runner.xcworkspace > Runner > Signing & Capabilities
# Change Bundle Identifier to something unique like:
com.yourname.pausepulse.unique
```

### Code Improvements Made

1. **Robust Error Handling**:
   - Try-catch blocks around dependency injection
   - Graceful degradation on iOS
   - Mock data for iOS app listing

2. **Better iOS Compatibility**:
   - Enhanced Info.plist configuration
   - URL scheme registration
   - Export compliance declarations

3. **Improved Debug Experience**:
   - Debug prints for troubleshooting
   - Better error messages
   - Fallback UI states

## 🔧 General Debugging Steps

### 1. Flutter Doctor Check
```bash
flutter doctor -v
```

### 2. Clear Everything and Rebuild
```bash
flutter clean
flutter pub get
cd ios && pod install && cd .. # For iOS
dart run build_runner build --delete-conflicting-outputs
```

### 3. Check Logs
```bash
# For iOS:
flutter logs

# For Android:
adb logcat | grep flutter

# Or run with verbose logging:
flutter run --verbose
```

### 4. Test on Different Devices
- Try both simulator/emulator and real devices
- Test on different Android API levels
- Test on different iOS versions

## 📋 Quick Fixes Checklist

### Android Emulator Issues:
- [ ] Create AVD with Google Play Services
- [ ] Enable Developer Options
- [ ] Grant permissions via ADB
- [ ] Test on real device if emulator fails

### iOS Trust Issues:
- [ ] Trust developer certificate in device settings
- [ ] Enable Developer Mode (iOS 16+)
- [ ] Use unique bundle identifier
- [ ] Clean and rebuild project
- [ ] Test on simulator first, then device

### General Issues:
- [ ] Run `flutter doctor` and fix any issues
- [ ] Update Flutter to latest stable version
- [ ] Clear all caches and rebuild
- [ ] Check device/simulator logs for specific errors

## 🆘 Still Having Issues?

If problems persist:

1. **Check the exact error messages** in the logs
2. **Try the web version** first to test core functionality
3. **Use Flutter Inspector** to debug widget issues
4. **Compare with working sample apps** in Flutter samples
5. **Consider platform-specific alternatives** for app discovery

The app is designed to degrade gracefully - even if app discovery fails, the core notification management features should still work with mock data.