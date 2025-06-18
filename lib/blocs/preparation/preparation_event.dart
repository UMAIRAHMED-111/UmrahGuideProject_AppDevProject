import 'package:equatable/equatable.dart';
import '../../models/reminder.dart';

abstract class PreparationEvent extends Equatable {
  const PreparationEvent();

  @override
  List<Object?> get props => [];
}

class TabChanged extends PreparationEvent {
  final int tabIndex;
  const TabChanged(this.tabIndex);
  @override
  List<Object?> get props => [tabIndex];
}

class ShowAddChecklistDialog extends PreparationEvent {}

class RemindersInitialized extends PreparationEvent {} 