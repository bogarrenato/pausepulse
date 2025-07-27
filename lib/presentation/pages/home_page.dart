import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/apps/apps_bloc.dart';
import '../bloc/apps/apps_event.dart';
import '../bloc/apps/apps_state.dart';
import '../widgets/app_list_item.dart';
import '../widgets/interval_selection_dialog.dart';
import '../widgets/confirmation_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<AppsBloc>().add(const LoadApps());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pause Pulse'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AppsBloc>().add(const RefreshApps());
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh apps',
          ),
        ],
      ),
      body: BlocConsumer<AppsBloc, AppsState>(
        listener: (context, state) {
          if (state is AppsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            AppsInitial() => const Center(
                child: Text('Welcome to Pause Pulse'),
              ),
            AppsLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            AppsPermissionDenied() => _buildPermissionDeniedWidget(),
            AppsLoaded() => _buildAppsListWidget(state),
            AppsError() => _buildErrorWidget(state),
            _ => const Center(
                child: Text('Unknown state'),
              ),
          };
        },
      ),
      floatingActionButton: BlocBuilder<AppsBloc, AppsState>(
        builder: (context, state) {
          if (state is! AppsLoaded) return const SizedBox.shrink();
          
          final hasDisabledApps = state.apps.any((app) => !app.isNotificationEnabled);
          
          return FloatingActionButton.extended(
            onPressed: hasDisabledApps ? () => _showIntervalDialog(context) : null,
            backgroundColor: hasDisabledApps ? null : Colors.grey,
            icon: const Icon(Icons.notifications_off),
            label: const Text('Turn Off Notifications'),
          );
        },
      ),
    );
  }

  Widget _buildPermissionDeniedWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.security,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            const Text(
              'Permission Required',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This app needs notification access to manage your app notifications.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<AppsBloc>().add(const LoadApps());
              },
              child: const Text('Grant Permission'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppsListWidget(AppsLoaded state) {
    if (state.apps.isEmpty) {
      return const Center(
        child: Text('No apps found'),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Found ${state.apps.length} apps',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: state.apps.length,
            itemBuilder: (context, index) {
              final app = state.apps[index];
              return AppListItem(
                app: app,
                onToggleNotification: (enabled) {
                  context.read<AppsBloc>().add(
                    ToggleAppNotification(
                      packageName: app.packageName,
                      enabled: enabled,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(AppsError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<AppsBloc>().add(const LoadApps());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showIntervalDialog(BuildContext context) async {
    final interval = await showDialog(
      context: context,
      builder: (context) => const IntervalSelectionDialog(),
    );

    if (interval != null && mounted) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => const ConfirmationDialog(),
      );

      if (confirmed == true && mounted) {
        context.read<AppsBloc>().add(TurnOffNotifications(interval));
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notifications have been paused successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}