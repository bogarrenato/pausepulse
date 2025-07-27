import 'package:flutter/material.dart';

import '../../domain/entities/notification_interval.dart';

class IntervalSelectionDialog extends StatefulWidget {
  const IntervalSelectionDialog({super.key});

  @override
  State<IntervalSelectionDialog> createState() => _IntervalSelectionDialogState();
}

class _IntervalSelectionDialogState extends State<IntervalSelectionDialog> {
  IntervalType? _selectedInterval;
  Duration? _customDuration;
  final _customHoursController = TextEditingController();
  final _customMinutesController = TextEditingController();

  @override
  void dispose() {
    _customHoursController.dispose();
    _customMinutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Time Interval'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'How long would you like to pause notifications?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ...IntervalType.values.map(
              (interval) => RadioListTile<IntervalType>(
                title: Text(interval.displayName),
                value: interval,
                groupValue: _selectedInterval,
                onChanged: (value) {
                  setState(() {
                    _selectedInterval = value;
                  });
                },
                dense: true,
              ),
            ),
            if (_selectedInterval == IntervalType.custom) ...[
              const SizedBox(height: 16),
              const Text(
                'Custom Duration:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _customHoursController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Hours',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: _updateCustomDuration,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _customMinutesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Minutes',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: _updateCustomDuration,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _canConfirm() ? _onConfirm : null,
          child: const Text('Continue'),
        ),
      ],
    );
  }

  bool _canConfirm() {
    if (_selectedInterval == null) return false;
    
    if (_selectedInterval == IntervalType.custom) {
      return _customDuration != null && 
             _customDuration!.inMinutes > 0;
    }
    
    return true;
  }

  void _updateCustomDuration(String value) {
    final hours = int.tryParse(_customHoursController.text) ?? 0;
    final minutes = int.tryParse(_customMinutesController.text) ?? 0;
    
    setState(() {
      _customDuration = Duration(hours: hours, minutes: minutes);
    });
  }

  void _onConfirm() {
    if (_selectedInterval != null) {
      final interval = NotificationInterval(
        type: _selectedInterval!,
        customDuration: _selectedInterval == IntervalType.custom 
            ? _customDuration 
            : null,
      );
      
      Navigator.of(context).pop(interval);
    }
  }
}