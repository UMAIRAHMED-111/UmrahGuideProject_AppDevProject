import 'package:equatable/equatable.dart';
import '../../models/reminder.dart';

abstract class PreparationState extends Equatable {
  const PreparationState();
  @override
  List<Object?> get props => [];
}

class PreparationInitial extends PreparationState {}

class PreparationLoaded extends PreparationState {
  final int currentTabIndex;
  final bool isAddingChecklist;
  final bool remindersInitialized;

  const PreparationLoaded({
    this.currentTabIndex = 0,
    this.isAddingChecklist = false,
    this.remindersInitialized = false,
  });

  PreparationLoaded copyWith({
    int? currentTabIndex,
    bool? isAddingChecklist,
    bool? remindersInitialized,
  }) {
    return PreparationLoaded(
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      isAddingChecklist: isAddingChecklist ?? this.isAddingChecklist,
      remindersInitialized: remindersInitialized ?? this.remindersInitialized,
    );
  }

  @override
  List<Object?> get props => [
        currentTabIndex,
        isAddingChecklist,
        remindersInitialized,
      ];
}

class PreparationError extends PreparationState {
  final String message;
  const PreparationError(this.message);
  @override
  List<Object?> get props => [message];
} 