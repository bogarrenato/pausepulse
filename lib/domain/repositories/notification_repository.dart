import '../entities/notification_interval.dart';

abstract class NotificationRepository {
  /// Pause notifications for specified apps for a given duration
  Future<void> pauseNotifications(
    List<String> packageNames,
    NotificationInterval interval,
  );
  
  /// Resume notifications for specified apps
  Future<void> resumeNotifications(List<String> packageNames);
  
  /// Check if notifications are currently paused for an app
  Future<bool> areNotificationsPaused(String packageName);
  
  /// Get remaining pause time for an app
  Future<Duration?> getRemainingPauseTime(String packageName);
  
  /// Get all currently paused apps
  Future<List<String>> getPausedApps();
  
  /// Clear all paused notifications
  Future<void> clearAllPausedNotifications();
}