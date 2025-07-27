import 'dart:io';

import 'package:device_apps/device_apps.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_info.dart';
import '../../domain/repositories/app_repository.dart';

@Injectable(as: AppRepository)
class AppRepositoryImpl implements AppRepository {
  AppRepositoryImpl(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;
  
  static const String _notificationSettingsKey = 'notification_settings';

  @override
  Future<List<AppInfo>> getInstalledApps() async {
    if (Platform.isAndroid) {
      return _getAndroidApps();
    } else if (Platform.isIOS || Platform.isMacOS) {
      return _getIOSMacOSApps();
    } else {
      return [];
    }
  }

  Future<List<AppInfo>> _getAndroidApps() async {
    try {
      final apps = await DeviceApps.getInstalledApplications(
        includeAppIcons: true,
        includeSystemApps: false,
        onlyAppsWithLaunchIntent: true,
      );

      return apps.map((app) {
        return AppInfo(
          packageName: app.packageName,
          appName: app.appName,
          iconPath: app is ApplicationWithIcon ? app.icon.toString() : null,
          isNotificationEnabled: true, // Default to enabled
          version: app.versionName,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<AppInfo>> _getIOSMacOSApps() async {
    // For iOS/macOS, we'll create representative mock data since we can't access all installed apps
    // In a real implementation, you would use platform-specific methods or limit to specific apps
    try {
      return [
        const AppInfo(
          packageName: 'com.apple.mobilemail',
          appName: 'Mail',
          iconPath: null,
          isNotificationEnabled: true,
          version: '1.0',
        ),
        const AppInfo(
          packageName: 'com.apple.mobilesafari',
          appName: 'Safari',
          iconPath: null,
          isNotificationEnabled: true,
          version: '1.0',
        ),
        const AppInfo(
          packageName: 'com.apple.mobilephone',
          appName: 'Phone',
          iconPath: null,
          isNotificationEnabled: true,
          version: '1.0',
        ),
        const AppInfo(
          packageName: 'com.apple.MobileSMS',
          appName: 'Messages',
          iconPath: null,
          isNotificationEnabled: true,
          version: '1.0',
        ),
        const AppInfo(
          packageName: 'com.apple.camera',
          appName: 'Camera',
          iconPath: null,
          isNotificationEnabled: false,
          version: '1.0',
        ),
        const AppInfo(
          packageName: 'com.apple.Photos',
          appName: 'Photos',
          iconPath: null,
          isNotificationEnabled: true,
          version: '1.0',
        ),
        const AppInfo(
          packageName: 'com.apple.Music',
          appName: 'Music',
          iconPath: null,
          isNotificationEnabled: true,
          version: '1.0',
        ),
        const AppInfo(
          packageName: 'com.apple.weather',
          appName: 'Weather',
          iconPath: null,
          isNotificationEnabled: false,
          version: '1.0',
        ),
        const AppInfo(
          packageName: 'com.apple.reminders',
          appName: 'Reminders',
          iconPath: null,
          isNotificationEnabled: true,
          version: '1.0',
        ),
        const AppInfo(
          packageName: 'com.apple.calendar',
          appName: 'Calendar',
          iconPath: null,
          isNotificationEnabled: true,
          version: '1.0',
        ),
      ];
    } catch (e) {
      // Return empty list if there's any error
      return [];
    }
  }

  @override
  Future<bool> getNotificationSetting(String packageName) async {
    final settings = _getStoredSettings();
    return settings[packageName] ?? true;
  }

  @override
  Future<void> updateNotificationSetting(String packageName, bool enabled) async {
    final settings = _getStoredSettings();
    settings[packageName] = enabled;
    await _saveSettings(settings);
  }

  @override
  Future<List<AppInfo>> getAppsWithNotificationSettings() async {
    final apps = await getInstalledApps();
    final settings = _getStoredSettings();

    return apps.map((app) {
      final isEnabled = settings[app.packageName] ?? true;
      return app.copyWith(isNotificationEnabled: isEnabled);
    }).toList();
  }

  @override
  Future<void> saveNotificationSettings(Map<String, bool> settings) async {
    await _saveSettings(settings);
  }

  @override
  Future<bool> hasPermissions() async {
    if (Platform.isAndroid) {
      // On Android, we need multiple permissions
      final notificationStatus = await Permission.notification.status;
      final storageStatus = await Permission.storage.status;
      
      // For Android 11+ (API 30+), we also need to check if we can query all packages
      return notificationStatus.isGranted && storageStatus.isGranted;
    } else {
      // On iOS/macOS, we only need notification permission
      final notificationStatus = await Permission.notification.status;
      return notificationStatus.isGranted;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      // Request multiple permissions for Android
      final Map<Permission, PermissionStatus> statuses = await [
        Permission.notification,
        Permission.storage,
      ].request();
      
      final notificationGranted = statuses[Permission.notification]?.isGranted == true;
      final storageGranted = statuses[Permission.storage]?.isGranted == true;
      
      // If any permission is permanently denied, open app settings
      if (statuses[Permission.notification]?.isPermanentlyDenied == true ||
          statuses[Permission.storage]?.isPermanentlyDenied == true) {
        await openAppSettings();
        // Re-check permissions after returning from settings
        final recheckStatuses = await [
          Permission.notification,
          Permission.storage,
        ].request();
        return recheckStatuses[Permission.notification]?.isGranted == true &&
               recheckStatuses[Permission.storage]?.isGranted == true;
      }
      
      return notificationGranted && storageGranted;
    } else {
      // For iOS/macOS, request notification permission
      final status = await Permission.notification.request();
      
      if (status.isPermanentlyDenied) {
        await openAppSettings();
        // Re-check permission after returning from settings
        final recheckStatus = await Permission.notification.status;
        return recheckStatus.isGranted;
      }
      
      return status.isGranted;
    }
  }

  Map<String, bool> _getStoredSettings() {
    final settingsJson = _sharedPreferences.getString(_notificationSettingsKey);
    if (settingsJson == null) return {};

    try {
      final settings = <String, bool>{};
      final pairs = settingsJson.split(',');
      for (final pair in pairs) {
        final keyValue = pair.split(':');
        if (keyValue.length == 2) {
          settings[keyValue[0]] = keyValue[1].toLowerCase() == 'true';
        }
      }
      return settings;
    } catch (e) {
      return {};
    }
  }

  Future<void> _saveSettings(Map<String, bool> settings) async {
    final settingsString = settings.entries
        .map((entry) => '${entry.key}:${entry.value}')
        .join(',');
    await _sharedPreferences.setString(_notificationSettingsKey, settingsString);
  }
}