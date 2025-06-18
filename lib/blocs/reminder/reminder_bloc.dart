import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../services/reminder_service.dart';
import '../../models/reminder.dart';
import 'reminder_event.dart';
import 'reminder_state.dart';
import '../../services/notification_service.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  final ReminderService _reminderService;

  ReminderBloc(this._reminderService) : super(ReminderInitial()) {
    on<LoadReminders>(_onLoadReminders);
    on<AddReminder>(_onAddReminder);
    on<UpdateReminder>(_onUpdateReminder);
    on<DeleteReminder>(_onDeleteReminder);
    on<InitializePrayerTimeReminders>(_onInitializePrayerTimeReminders);
  }

  Future<void> _onLoadReminders(
    LoadReminders event,
    Emitter<ReminderState> emit,
  ) async {
    emit(ReminderLoading());
    try {
      await emit.forEach<List<Reminder>>(
        _reminderService.getReminders(event.userId),
        onData: (reminders) => ReminderLoaded(reminders),
        onError: (_, __) => const ReminderError('Failed to load reminders'),
      );
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onAddReminder(
    AddReminder event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      await _reminderService.addReminder(event.userId, event.reminder);
      await NotificationService().scheduleReminderNotification(event.reminder);
    } catch (e) {
      emit(ReminderError('Failed to add reminder: $e'));
    }
  }

  Future<void> _onUpdateReminder(
    UpdateReminder event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      await _reminderService.updateReminder(event.userId, event.reminder);
      await NotificationService().updateReminderNotification(event.reminder);
    } catch (e) {
      emit(ReminderError('Failed to update reminder: $e'));
    }
  }

  Future<void> _onDeleteReminder(
    DeleteReminder event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      await _reminderService.deleteReminder(event.userId, event.reminderId);
      await NotificationService().cancelReminderNotification(event.reminderId);
    } catch (e) {
      emit(ReminderError('Failed to delete reminder: $e'));
    }
  }

  Future<void> _onInitializePrayerTimeReminders(
    InitializePrayerTimeReminders event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      await _reminderService.initializePrayerTimeReminders(event.userId);
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }
} 