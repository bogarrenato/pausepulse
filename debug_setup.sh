#!/bin/bash

echo "🔧 Pause Pulse Debug Setup Script"
echo "=================================="

# Check if flutter is available
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter first."
    exit 1
fi

echo "✅ Flutter found"

# Run flutter doctor
echo ""
echo "📋 Checking Flutter setup..."
flutter doctor

# Clean and rebuild
echo ""
echo "🧹 Cleaning project..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

# Regenerate dependency injection
echo "🏗️ Regenerating dependency injection..."
dart run build_runner build --delete-conflicting-outputs

# Check for connected devices
echo ""
echo "📱 Checking connected devices..."
flutter devices

# Function to grant Android permissions via ADB
grant_android_permissions() {
    echo ""
    echo "🤖 Granting Android permissions via ADB..."
    
    PACKAGE_NAME="com.example.pause_pulse"
    
    adb shell pm grant $PACKAGE_NAME android.permission.QUERY_ALL_PACKAGES 2>/dev/null || echo "⚠️ QUERY_ALL_PACKAGES permission failed (may not be needed)"
    adb shell pm grant $PACKAGE_NAME android.permission.POST_NOTIFICATIONS 2>/dev/null || echo "⚠️ POST_NOTIFICATIONS permission failed"
    adb shell pm grant $PACKAGE_NAME android.permission.READ_EXTERNAL_STORAGE 2>/dev/null || echo "⚠️ READ_EXTERNAL_STORAGE permission failed"
    adb shell pm grant $PACKAGE_NAME android.permission.WRITE_EXTERNAL_STORAGE 2>/dev/null || echo "⚠️ WRITE_EXTERNAL_STORAGE permission failed"
    
    echo "✅ Attempted to grant all permissions"
}

# Check if Android device is connected
if adb devices | grep -q "device$"; then
    echo "📱 Android device detected"
    read -p "Grant Android permissions via ADB? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        grant_android_permissions
    fi
fi

# iOS specific checks
echo ""
echo "🍎 iOS Setup Checklist:"
echo "- [ ] Open ios/Runner.xcworkspace in Xcode"
echo "- [ ] Select your development team in Signing & Capabilities"
echo "- [ ] Change Bundle Identifier to something unique"
echo "- [ ] Trust developer certificate on device (Settings > General > VPN & Device Management)"
echo "- [ ] Enable Developer Mode on iOS 16+ (Settings > Privacy & Security > Developer Mode)"

# Build options
echo ""
echo "🚀 Ready to test! Choose your platform:"
echo "1. Run on connected device: flutter run"
echo "2. Run on iOS Simulator: flutter run -d ios"
echo "3. Run on Android Emulator: flutter run -d android"
echo "4. Run on Web: flutter run -d web"

# Quick test web version
read -p "Test web version now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🌐 Starting web version..."
    flutter run -d web-server --web-port 8080 &
    echo "🎉 Web app should be available at: http://localhost:8080"
    echo "Press Ctrl+C to stop the web server"
fi

echo ""
echo "✅ Setup complete! Check TROUBLESHOOTING.md for detailed solutions to common issues."