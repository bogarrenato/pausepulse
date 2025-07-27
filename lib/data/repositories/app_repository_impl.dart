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
    // For iOS/macOS, we'll create mock data since we can't access all installed apps
    // In a real implementation, you would use platform-specific methods
    return [
      const AppInfo(
        packageName: 'com.apple.mobilemail',
        appName: 'Mail',
        iconPath: null,
        isNotificationEnabled: true,
      ),
      const AppInfo(
        packageName: 'com.apple.MobileSMS',
        appName: 'Messages',
        iconPath: null,
        isNotificationEnabled: true,
      ),
      const AppInfo(
        packageName: 'com.apple.mobilecal',
        appName: 'Calendar',
        iconPath: null,
        isNotificationEnabled: true,
      ),
      const AppInfo(
        packageName: 'com.apple.weather',
        appName: 'Weather',
        iconPath: null,
        isNotificationEnabled: true,
      ),
    ];
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
      // On Android, we need notification access permission
      return await Permission.notification.isGranted;
    } else {
      // On iOS/macOS, notifications are handled differently
      return await Permission.notification.isGranted;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    final status = await Permission.notification.request();
    return status.isGranted;
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