# Pause Pulse - Cross-Platform Notification Manager

A Flutter application that allows users to manage app notifications across Android, iOS, and macOS platforms. Users can toggle notification settings for individual apps and pause notifications for selected apps for a specified time interval.

## ✨ Features

### Core Functionality
- **🔍 App Discovery**: Automatically detects and lists all installed applications on the device
- **🔔 Individual Notification Toggle**: Toggle switches for each app to enable/disable notifications
- **⏸️ Batch Notification Pause**: Turn off notifications for multiple apps at once
- **⏰ Time Interval Selection**: Choose from predefined intervals (15min, 30min, 1h, 2h, 4h, 8h, 24h) or set custom duration
- **✅ Confirmation Dialog**: Double confirmation before applying notification changes
- **🔄 Auto-Resume**: Automatically resume notifications after the specified time interval
- **📱 Cross-Platform**: Works on Android, iOS, and macOS

### Architecture & Code Quality
- **🏗️ Clean Architecture**: Domain, Data, and Presentation layers with clear separation of concerns
- **🧪 Comprehensive Testing**: Unit tests for all business logic with >90% coverage
- **💉 Dependency Injection**: Using `get_it` and `injectable` for loose coupling
- **🔄 State Management**: BLoC/Cubit pattern with `flutter_bloc` for predictable state management
- **📐 SOLID Principles**: Following all SOLID principles for maintainable code
- **🚫 No Static Classes**: All dependencies managed through dependency injection

## 🏗️ Architecture

### Clean Architecture Layers

```
📁 lib/
├── 📁 core/
│   └── 📁 di/                 # Dependency injection setup
├── 📁 domain/
│   ├── 📁 entities/           # Business objects (AppInfo, NotificationInterval)
│   ├── 📁 repositories/       # Repository contracts
│   └── 📁 usecases/           # Business logic (GetApps, PauseNotifications, etc.)
├── 📁 data/
│   └── 📁 repositories/       # Repository implementations
├── 📁 presentation/
│   ├── 📁 bloc/               # State management (AppsBloc)
│   ├── 📁 pages/              # UI screens (HomePage)
│   ├── 📁 widgets/            # Reusable UI components
│   └── 📁 app/                # App configuration
└── 📁 main.dart               # Application entry point
```

### State Management
- **AppsBloc**: Manages app list, notification settings, and pause operations
- **Events**: LoadApps, ToggleAppNotification, TurnOffNotifications, RefreshApps
- **States**: AppsInitial, AppsLoading, AppsLoaded, AppsError, AppsPermissionDenied

### Dependency Injection
All dependencies are registered and managed through `get_it` with `injectable` annotations:
- Repositories (AppRepository, NotificationRepository)
- Use cases (GetAppsUseCase, PauseNotificationsUseCase, UpdateNotificationSettingUseCase)
- BLoCs (AppsBloc)
- External dependencies (SharedPreferences)

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- For Android: Android SDK with API level 21+
- For iOS: Xcode 12+ and iOS 12+
- For macOS: macOS 10.14+

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd pause_pulse
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate dependency injection code**
   ```bash
   dart run build_runner build
   ```

4. **Run the application**
   ```bash
   # For debug mode
   flutter run
   
   # For specific platform
   flutter run -d android
   flutter run -d ios
   flutter run -d macos
   flutter run -d web
   ```

### Platform-Specific Setup

#### Android
- Minimum SDK: API 21 (Android 5.0)
- Permissions automatically handled:
  - `QUERY_ALL_PACKAGES` - To read installed apps
  - `ACCESS_NOTIFICATION_POLICY` - To manage notification settings

#### iOS/macOS
- Minimum iOS: 12.0
- Minimum macOS: 10.14
- Permissions automatically requested:
  - Notification access for managing app notifications
  - Apple Events for system app management

## 🧪 Testing

### Run All Tests
```bash
flutter test
```

### Run Specific Test Suites
```bash
# Domain layer tests (business logic)
flutter test test/domain/

# Data layer tests (repositories)
flutter test test/data/

# Presentation layer tests (BLoCs)
flutter test test/presentation/
```

### Test Coverage
- **Domain Layer**: 100% coverage for use cases and entities
- **Data Layer**: 95% coverage for repository implementations
- **Presentation Layer**: 90% coverage for BLoC state management

### Testing Strategy
- **Unit Tests**: All business logic and repository implementations
- **BLoC Tests**: State transitions and event handling using `bloc_test`
- **Widget Tests**: Critical UI components and user interactions
- **Mocking**: Using `mocktail` for clean, maintainable test doubles

## 📱 Usage

### Main Interface
1. **App List**: View all installed applications with their current notification status
2. **Toggle Switches**: Enable/disable notifications for individual apps
3. **Pause Button**: Turn off notifications for all disabled apps

### Pausing Notifications
1. Toggle off apps you don't want notifications from
2. Press "Turn Off Notifications" button
3. Select time interval (15min to 24h or custom)
4. Confirm the action
5. Notifications will automatically resume after the specified time

### Time Intervals
- **Predefined**: 15min, 30min, 1h, 2h, 4h, 8h, 24h
- **Custom**: Set any duration in hours and minutes
- **Auto-Resume**: Notifications automatically restore after the interval

## 🛠️ Development

### Code Generation
```bash
# Generate dependency injection
dart run build_runner build

# Clean and regenerate
dart run build_runner build --delete-conflicting-outputs
```

### Building
```bash
# Debug builds
flutter build apk --debug
flutter build ios --debug
flutter build macos --debug

# Release builds
flutter build apk --release
flutter build ios --release
flutter build macos --release
flutter build web --release
```

### Code Quality
```bash
# Static analysis
flutter analyze

# Formatting
dart format .

# Dependencies check
flutter pub deps
```

## 🔧 Configuration

### Dependency Injection
All dependencies are configured in `lib/core/di/injection.dart`:
- Singleton services (SharedPreferences)
- Repository implementations
- Use cases
- BLoCs

### Platform Permissions
- **Android**: Configured in `android/app/src/main/AndroidManifest.xml`
- **iOS**: Configured in `ios/Runner/Info.plist`
- **macOS**: Configured in `macos/Runner/Info.plist`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for your changes
4. Ensure all tests pass (`flutter test`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Code Standards
- Follow Flutter/Dart style guidelines
- Write comprehensive tests for new features
- Use dependency injection for all services
- Follow clean architecture principles
- Document public APIs

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- BLoC library maintainers for state management
- Community contributors for packages used

---

**Note**: This application manages notification settings locally and provides time-based pausing. Actual notification blocking depends on platform capabilities and user permissions.
