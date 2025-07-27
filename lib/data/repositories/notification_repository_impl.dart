import 'dart:async';
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/notification_interval.dart';
import '../../domain/repositories/notification_repository.dart';

@Injectable(as: NotificationRepository)
class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;
  final Map<String, Timer> _activeTimers = {};

  static const String _pausedAppsKey = 'paused_apps';

  @override
  Future<void> pauseNotifications(
    List<String> packageNames,
    NotificationInterval interval,
  ) async {
    final pausedApps = _getPausedApps();
    final endTime = DateTime.now().add(interval.effectiveDuration);

    // Cancel existing timers for these apps
    for (final packageName in packageNames) {
      _activeTimers[packageName]?.cancel();
    }

    // Add apps to paused list
    for (final packageName in packageNames) {
      pausedApps[packageName] = endTime.millisecondsSinceEpoch;
      
      // Set up timer to automatically resume notifications
      _activeTimers[packageName] = Timer(interval.effectiveDuration, () {
        _resumeSingleApp(packageName);
      });
    }

    await _savePausedApps(pausedApps);
  }

  @override
  Future<void> resumeNotifications(List<String> packageNames) async {
    final pausedApps = _getPausedApps();

    for (final packageName in packageNames) {
      pausedApps.remove(packageName);
      _activeTimers[packageName]?.cancel();
      _activeTimers.remove(packageName);
    }

    await _savePausedApps(pausedApps);
  }

  @override
  Future<bool> areNotificationsPaused(String packageName) async {
    final pausedApps = _getPausedApps();
    final endTime = pausedApps[packageName];
    
    if (endTime == null) return false;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now >= endTime) {
      // Timer has expired, remove from paused apps
      await _resumeSingleApp(packageName);
      return false;
    }
    
    return true;
  }

  @override
  Future<Duration?> getRemainingPauseTime(String packageName) async {
    final pausedApps = _getPausedApps();
    final endTime = pausedApps[packageName];
    
    if (endTime == null) return null;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now >= endTime) {
      await _resumeSingleApp(packageName);
      return null;
    }
    
    return Duration(milliseconds: endTime - now);
  }

  @override
  Future<List<String>> getPausedApps() async {
    final pausedApps = _getPausedApps();
    final now = DateTime.now().millisecondsSinceEpoch;
    final activePausedApps = <String>[];
    final expiredApps = <String>[];

    for (final entry in pausedApps.entries) {
      if (now >= entry.value) {
        expiredApps.add(entry.key);
      } else {
        activePausedApps.add(entry.key);
      }
    }

    // Clean up expired apps
    if (expiredApps.isNotEmpty) {
      await resumeNotifications(expiredApps);
    }

    return activePausedApps;
  }

  @override
  Future<void> clearAllPausedNotifications() async {
    // Cancel all active timers
    for (final timer in _activeTimers.values) {
      timer.cancel();
    }
    _activeTimers.clear();

    // Clear stored paused apps
    await _sharedPreferences.remove(_pausedAppsKey);
  }

  Map<String, int> _getPausedApps() {
    final pausedAppsJson = _sharedPreferences.getString(_pausedAppsKey);
    if (pausedAppsJson == null) return {};

    try {
      final Map<String, dynamic> decoded = json.decode(pausedAppsJson);
      return decoded.map((key, value) => MapEntry(key, value as int));
    } catch (e) {
      return {};
    }
  }

  Future<void> _savePausedApps(Map<String, int> pausedApps) async {
    final pausedAppsJson = json.encode(pausedApps);
    await _sharedPreferences.setString(_pausedAppsKey, pausedAppsJson);
  }

  Future<void> _resumeSingleApp(String packageName) async {
    final pausedApps = _getPausedApps();
    pausedApps.remove(packageName);
    _activeTimers[packageName]?.cancel();
    _activeTimers.remove(packageName);
    await _savePausedApps(pausedApps);
  }
}