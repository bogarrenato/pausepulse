import '../entities/app_info.dart';

abstract class AppRepository {
  /// Get all installed applications on the device
  Future<List<AppInfo>> getInstalledApps();
  
  /// Get notification settings for a specific app
  Future<bool> getNotificationSetting(String packageName);
  
  /// Update notification setting for a specific app
  Future<void> updateNotificationSetting(String packageName, bool enabled);
  
  /// Get all apps with their notification settings
  Future<List<AppInfo>> getAppsWithNotificationSettings();
  
  /// Save notification settings for multiple apps
  Future<void> saveNotificationSettings(Map<String, bool> settings);
  
  /// Check if the app has necessary permissions
  Future<bool> hasPermissions();
  
  /// Request necessary permissions
  Future<bool> requestPermissions();
}