// checklist_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/checklist_service.dart';
import '../../models/checklist_item.dart';
import 'checklist_event.dart';
import 'checklist_state.dart';

class ChecklistBloc extends Bloc<ChecklistEvent, ChecklistState> {
  final ChecklistService _checklistService;

  ChecklistBloc(this._checklistService) : super(ChecklistInitial()) {
    on<LoadChecklist>(_onLoadChecklist);
    on<AddChecklistItem>(_onAddChecklistItem);
    on<UpdateChecklistItem>(_onUpdateChecklistItem);
    on<DeleteChecklistItem>(_onDeleteChecklistItem);
    on<InitializeDefaultChecklist>(_onInitializeDefaultChecklist);
    on<ReorderChecklist>(_onReorderChecklist);
    on<ShowAddChecklistDialog>(_onShowAddDialog);
    on<HideAddChecklistDialog>(_onHideAddDialog);
  }

  Future<void> _onLoadChecklist(LoadChecklist event, Emitter<ChecklistState> emit) async {
    emit(ChecklistLoading());
    try {
      final stream = _checklistService.getChecklistItems(event.userId);
      final firstItems = await stream.first;
      if (firstItems.isEmpty) {
        await _checklistService.initializeDefaultChecklist(event.userId);
        await emit.forEach<List<ChecklistItem>>(
          _checklistService.getChecklistItems(event.userId),
          onData: (items) => ChecklistLoaded(items),
          onError: (_, __) => const ChecklistError('Failed to load checklist'),
        );
      } else {
        await emit.forEach<List<ChecklistItem>>(
          stream,
          onData: (items) => ChecklistLoaded(items),
          onError: (_, __) => const ChecklistError('Failed to load checklist'),
        );
      }
    } catch (e) {
      emit(ChecklistError(e.toString()));
    }
  }

  Future<void> _onAddChecklistItem(AddChecklistItem event, Emitter<ChecklistState> emit) async {
    try {
      await _checklistService.addChecklistItem(event.userId, event.item);
    } catch (e) {
      emit(ChecklistError(e.toString()));
    }
  }

  Future<void> _onUpdateChecklistItem(UpdateChecklistItem event, Emitter<ChecklistState> emit) async {
    try {
      await _checklistService.updateChecklistItem(event.userId, event.item);
    } catch (e) {
      emit(ChecklistError(e.toString()));
    }
  }

  Future<void> _onDeleteChecklistItem(DeleteChecklistItem event, Emitter<ChecklistState> emit) async {
    try {
      await _checklistService.deleteChecklistItem(event.userId, event.itemId);
    } catch (e) {
      emit(ChecklistError(e.toString()));
    }
  }

  Future<void> _onInitializeDefaultChecklist(InitializeDefaultChecklist event, Emitter<ChecklistState> emit) async {
    try {
      await _checklistService.initializeDefaultChecklist(event.userId);
    } catch (e) {
      emit(ChecklistError(e.toString()));
    }
  }

  Future<void> _onReorderChecklist(ReorderChecklist event, Emitter<ChecklistState> emit) async {
    try {
      await _checklistService.reorderChecklist(event.userId, event.reorderedItems);
    } catch (e) {
      emit(ChecklistError(e.toString()));
    }
  }

  void _onShowAddDialog(ShowAddChecklistDialog event, Emitter<ChecklistState> emit) {
    if (state is ChecklistLoaded) {
      emit((state as ChecklistLoaded).copyWith(isAdding: true));
    }
  }

  void _onHideAddDialog(HideAddChecklistDialog event, Emitter<ChecklistState> emit) {
    if (state is ChecklistLoaded) {
      emit((state as ChecklistLoaded).copyWith(isAdding: false));
    }
  }
}
