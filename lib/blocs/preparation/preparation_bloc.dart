import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/reminder.dart';
import 'preparation_event.dart';
import 'preparation_state.dart';

class PreparationBloc extends Bloc<PreparationEvent, PreparationState> {
  PreparationBloc() : super(PreparationLoaded()) {
    on<TabChanged>(_onTabChanged);
    on<ShowAddChecklistDialog>(_onShowAddChecklistDialog);
    on<RemindersInitialized>(_onRemindersInitialized);
  }

  void _onTabChanged(TabChanged event, Emitter<PreparationState> emit) {
    if (state is PreparationLoaded) {
      emit((state as PreparationLoaded).copyWith(
        currentTabIndex: event.tabIndex,
        isAddingChecklist: false,
      ));
    }
  }

  void _onShowAddChecklistDialog(ShowAddChecklistDialog event, Emitter<PreparationState> emit) {
    if (state is PreparationLoaded) {
      emit((state as PreparationLoaded).copyWith(
        isAddingChecklist: true,
      ));
    }
  }

  void _onRemindersInitialized(RemindersInitialized event, Emitter<PreparationState> emit) {
    if (state is PreparationLoaded) {
      emit((state as PreparationLoaded).copyWith(
        remindersInitialized: true,
      ));
    }
  }
} 