// checklist_event.dart
import 'package:equatable/equatable.dart';
import '../../models/checklist_item.dart';

abstract class ChecklistEvent extends Equatable {
  const ChecklistEvent();

  @override
  List<Object?> get props => [];
}

class LoadChecklist extends ChecklistEvent {
  final String userId;
  const LoadChecklist(this.userId);
  @override
  List<Object?> get props => [userId];
}

class AddChecklistItem extends ChecklistEvent {
  final String userId;
  final ChecklistItem item;
  const AddChecklistItem(this.userId, this.item);
  @override
  List<Object?> get props => [userId, item];
}

class UpdateChecklistItem extends ChecklistEvent {
  final String userId;
  final ChecklistItem item;
  const UpdateChecklistItem(this.userId, this.item);
  @override
  List<Object?> get props => [userId, item];
}

class DeleteChecklistItem extends ChecklistEvent {
  final String userId;
  final String itemId;
  const DeleteChecklistItem(this.userId, this.itemId);
  @override
  List<Object?> get props => [userId, itemId];
}

class InitializeDefaultChecklist extends ChecklistEvent {
  final String userId;
  const InitializeDefaultChecklist(this.userId);
  @override
  List<Object?> get props => [userId];
}

class ReorderChecklist extends ChecklistEvent {
  final String userId;
  final List<ChecklistItem> reorderedItems;
  const ReorderChecklist(this.userId, this.reorderedItems);
  @override
  List<Object?> get props => [userId, reorderedItems];
}

class ShowAddChecklistDialog extends ChecklistEvent {}
class HideAddChecklistDialog extends ChecklistEvent {}
