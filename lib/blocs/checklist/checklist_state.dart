// checklist_state.dart
import 'package:equatable/equatable.dart';
import '../../models/checklist_item.dart';

abstract class ChecklistState extends Equatable {
  const ChecklistState();
  @override
  List<Object?> get props => [];
}

class ChecklistInitial extends ChecklistState {}

class ChecklistLoading extends ChecklistState {}

class ChecklistLoaded extends ChecklistState {
  final List<ChecklistItem> items;
  final bool isAdding;
  const ChecklistLoaded(this.items, {this.isAdding = false});

  ChecklistLoaded copyWith({List<ChecklistItem>? items, bool? isAdding}) {
    return ChecklistLoaded(
      items ?? this.items,
      isAdding: isAdding ?? this.isAdding,
    );
  }

  @override
  List<Object?> get props => [items, isAdding];
}

class ChecklistError extends ChecklistState {
  final String message;
  const ChecklistError(this.message);
  @override
  List<Object?> get props => [message];
}
