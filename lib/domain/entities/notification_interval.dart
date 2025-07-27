import 'package:equatable/equatable.dart';

enum IntervalType {
  minutes15('15 minutes'),
  minutes30('30 minutes'),
  hour1('1 hour'),
  hours2('2 hours'),
  hours4('4 hours'),
  hours8('8 hours'),
  hours24('24 hours'),
  custom('Custom');

  const IntervalType(this.displayName);
  final String displayName;

  Duration get duration {
    switch (this) {
      case IntervalType.minutes15:
        return const Duration(minutes: 15);
      case IntervalType.minutes30:
        return const Duration(minutes: 30);
      case IntervalType.hour1:
        return const Duration(hours: 1);
      case IntervalType.hours2:
        return const Duration(hours: 2);
      case IntervalType.hours4:
        return const Duration(hours: 4);
      case IntervalType.hours8:
        return const Duration(hours: 8);
      case IntervalType.hours24:
        return const Duration(hours: 24);
      case IntervalType.custom:
        return Duration.zero; // Will be handled separately
    }
  }
}

class NotificationInterval extends Equatable {
  const NotificationInterval({
    required this.type,
    this.customDuration,
  });

  final IntervalType type;
  final Duration? customDuration;

  Duration get effectiveDuration {
    if (type == IntervalType.custom && customDuration != null) {
      return customDuration!;
    }
    return type.duration;
  }

  @override
  List<Object?> get props => [type, customDuration];
}