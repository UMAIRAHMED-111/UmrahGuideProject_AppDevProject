import 'package:equatable/equatable.dart';
import '../../models/reminder.dart';

abstract class ReminderEvent extends Equatable {
  const ReminderEvent();

  @override
  List<Object?> get props => [];
}

class LoadReminders extends ReminderEvent {
  final String userId;

  const LoadReminders(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddReminder extends ReminderEvent {
  final String userId;
  final Reminder reminder;

  const AddReminder(this.userId, this.reminder);

  @override
  List<Object?> get props => [userId, reminder];
}

class UpdateReminder extends ReminderEvent {
  final String userId;
  final Reminder reminder;

  const UpdateReminder(this.userId, this.reminder);

  @override
  List<Object?> get props => [userId, reminder];
}

class DeleteReminder extends ReminderEvent {
  final String userId;
  final String reminderId;

  const DeleteReminder(this.userId, this.reminderId);

  @override
  List<Object?> get props => [userId, reminderId];
}

class InitializePrayerTimeReminders extends ReminderEvent {
  final String userId;

  const InitializePrayerTimeReminders(this.userId);

  @override
  List<Object?> get props => [userId];
} 