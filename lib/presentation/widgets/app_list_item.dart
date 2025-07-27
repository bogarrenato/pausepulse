import 'dart:io';

import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/app_info.dart';

class AppListItem extends StatelessWidget {
  const AppListItem({
    super.key,
    required this.app,
    required this.onToggleNotification,
  });

  final AppInfo app;
  final ValueChanged<bool> onToggleNotification;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: _buildAppIcon(),
        title: Text(
          app.appName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: app.version != null
            ? Text('Version: ${app.version}')
            : null,
        trailing: Switch(
          value: app.isNotificationEnabled,
          onChanged: onToggleNotification,
          activeColor: Theme.of(context).colorScheme.primary,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 4.0,
        ),
      ),
    );
  }

  Widget _buildAppIcon() {
    if (app.iconPath != null && Platform.isAndroid) {
      return FutureBuilder<ApplicationWithIcon?>(
        future: _getAppWithIcon(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data?.icon != null) {
            return CircleAvatar(
              radius: 20,
              child: ClipOval(
                child: Image.memory(
                  snapshot.data!.icon,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildDefaultIcon();
                  },
                ),
              ),
            );
          }
          return _buildDefaultIcon();
        },
      );
    }
    
    return _buildDefaultIcon();
  }

  Widget _buildDefaultIcon() {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.grey[300],
      child: Icon(
        Icons.android,
        color: Colors.grey[600],
        size: 24,
      ),
    );
  }

  Future<ApplicationWithIcon?> _getAppWithIcon() async {
    try {
      final appWithIcon = await DeviceApps.getApp(
        app.packageName,
        true,
      ) as ApplicationWithIcon?;
      return appWithIcon;
    } catch (e) {
      return null;
    }
  }
}