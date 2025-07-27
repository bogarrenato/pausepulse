import 'package:equatable/equatable.dart';

class AppInfo extends Equatable {
  const AppInfo({
    required this.packageName,
    required this.appName,
    required this.iconPath,
    required this.isNotificationEnabled,
    this.version,
  });

  final String packageName;
  final String appName;
  final String? iconPath;
  final bool isNotificationEnabled;
  final String? version;

  AppInfo copyWith({
    String? packageName,
    String? appName,
    String? iconPath,
    bool? isNotificationEnabled,
    String? version,
  }) {
    return AppInfo(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      iconPath: iconPath ?? this.iconPath,
      isNotificationEnabled: isNotificationEnabled ?? this.isNotificationEnabled,
      version: version ?? this.version,
    );
  }

  @override
  List<Object?> get props => [
        packageName,
        appName,
        iconPath,
        isNotificationEnabled,
        version,
      ];
}