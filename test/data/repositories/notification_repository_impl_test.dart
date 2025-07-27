import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pause_pulse/data/repositories/notification_repository_impl.dart';
import 'package:pause_pulse/domain/entities/notification_interval.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late NotificationRepositoryImpl repository;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    repository = NotificationRepositoryImpl(mockSharedPreferences);
  });

  group('NotificationRepositoryImpl', () {
    const packageNames = ['com.example.app1', 'com.example.app2'];
    const interval = NotificationInterval(type: IntervalType.hour1);

    group('pauseNotifications', () {
      test('should save paused apps with correct end times', () async {
        // Arrange
        when(() => mockSharedPreferences.getString('paused_apps'))
            .thenReturn(null);
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        await repository.pauseNotifications(packageNames, interval);

        // Assert
        verify(() => mockSharedPreferences.setString(
          'paused_apps',
          any(),
        )).called(1);
      });

      test('should update existing paused apps', () async {
        // Arrange
        final existingData = {
          'com.example.existing': DateTime.now().add(const Duration(hours: 2)).millisecondsSinceEpoch,
        };
        when(() => mockSharedPreferences.getString('paused_apps'))
            .thenReturn(json.encode(existingData));
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        await repository.pauseNotifications(packageNames, interval);

        // Assert
        verify(() => mockSharedPreferences.setString(
          'paused_apps',
          any(),
        )).called(1);
      });
    });

    group('resumeNotifications', () {
      test('should remove apps from paused list', () async {
        // Arrange
        final existingData = {
          'com.example.app1': DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch,
          'com.example.app2': DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch,
          'com.example.app3': DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch,
        };
        when(() => mockSharedPreferences.getString('paused_apps'))
            .thenReturn(json.encode(existingData));
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        await repository.resumeNotifications(['com.example.app1', 'com.example.app2']);

        // Assert
        final captured = verify(() => mockSharedPreferences.setString(
          'paused_apps',
          captureAny(),
        )).captured.first as String;
        
        final savedData = json.decode(captured) as Map<String, dynamic>;
        expect(savedData.containsKey('com.example.app1'), false);
        expect(savedData.containsKey('com.example.app2'), false);
        expect(savedData.containsKey('com.example.app3'), true);
      });
    });

    group('areNotificationsPaused', () {
      test('should return true for paused app that has not expired', () async {
        // Arrange
        final futureTime = DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch;
        final existingData = {
          'com.example.app1': futureTime,
        };
        when(() => mockSharedPreferences.getString('paused_apps'))
            .thenReturn(json.encode(existingData));

        // Act
        final result = await repository.areNotificationsPaused('com.example.app1');

        // Assert
        expect(result, true);
      });

      test('should return false for non-paused app', () async {
        // Arrange
        when(() => mockSharedPreferences.getString('paused_apps'))
            .thenReturn(null);

        // Act
        final result = await repository.areNotificationsPaused('com.example.app1');

        // Assert
        expect(result, false);
      });

      test('should return false and clean up expired app', () async {
        // Arrange
        final pastTime = DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch;
        final existingData = {
          'com.example.app1': pastTime,
        };
        when(() => mockSharedPreferences.getString('paused_apps'))
            .thenReturn(json.encode(existingData));
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        final result = await repository.areNotificationsPaused('com.example.app1');

        // Assert
        expect(result, false);
        verify(() => mockSharedPreferences.setString('paused_apps', any())).called(1);
      });
    });

    group('getRemainingPauseTime', () {
      test('should return correct remaining time for paused app', () async {
        // Arrange
        final futureTime = DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch;
        final existingData = {
          'com.example.app1': futureTime,
        };
        when(() => mockSharedPreferences.getString('paused_apps'))
            .thenReturn(json.encode(existingData));

        // Act
        final result = await repository.getRemainingPauseTime('com.example.app1');

        // Assert
        expect(result, isNotNull);
        expect(result!.inMinutes, greaterThan(50)); // Should be close to 60 minutes
      });

      test('should return null for non-paused app', () async {
        // Arrange
        when(() => mockSharedPreferences.getString('paused_apps'))
            .thenReturn(null);

        // Act
        final result = await repository.getRemainingPauseTime('com.example.app1');

        // Assert
        expect(result, null);
      });
    });

    group('getPausedApps', () {
      test('should return only non-expired paused apps', () async {
        // Arrange
        final now = DateTime.now();
        final futureTime = now.add(const Duration(hours: 1)).millisecondsSinceEpoch;
        final pastTime = now.subtract(const Duration(hours: 1)).millisecondsSinceEpoch;
        
        final existingData = {
          'com.example.app1': futureTime,
          'com.example.app2': pastTime,
          'com.example.app3': futureTime,
        };
        when(() => mockSharedPreferences.getString('paused_apps'))
            .thenReturn(json.encode(existingData));
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        final result = await repository.getPausedApps();

        // Assert
        expect(result, containsAll(['com.example.app1', 'com.example.app3']));
        expect(result, isNot(contains('com.example.app2')));
        
        // Should clean up expired apps
        verify(() => mockSharedPreferences.setString('paused_apps', any())).called(1);
      });

      test('should return empty list when no apps are paused', () async {
        // Arrange
        when(() => mockSharedPreferences.getString('paused_apps'))
            .thenReturn(null);

        // Act
        final result = await repository.getPausedApps();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('clearAllPausedNotifications', () {
      test('should clear all paused notifications', () async {
        // Arrange
        when(() => mockSharedPreferences.remove('paused_apps'))
            .thenAnswer((_) async => true);

        // Act
        await repository.clearAllPausedNotifications();

        // Assert
        verify(() => mockSharedPreferences.remove('paused_apps')).called(1);
      });
    });
  });
}