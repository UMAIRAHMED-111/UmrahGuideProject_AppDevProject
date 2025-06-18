import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'rituals_prayers_event.dart';
import 'rituals_prayers_state.dart';

class RitualsPrayersBloc extends Bloc<RitualsPrayersEvent, RitualsPrayersState> {
  RitualsPrayersBloc() : super(RitualsPrayersInitial()) {
    on<LoadRitualsPrayersEvent>(_onLoadRitualsPrayers);
    on<UpdateLoadingEvent>(_onUpdateLoading);
    on<UpdateConnectivityCheckedEvent>(_onUpdateConnectivityChecked);
    on<ToggleTranslationEvent>(_onToggleTranslation);
  }

  Future<void> _onLoadRitualsPrayers(
    LoadRitualsPrayersEvent event,
    Emitter<RitualsPrayersState> emit,
  ) async {
    emit(RitualsPrayersLoaded(
      isLoading: true,
      connectivityChecked: false,
      showTranslation: {},
    ));

    await Future.delayed(const Duration(seconds: 2));

    emit(RitualsPrayersLoaded(
      isLoading: false,
      connectivityChecked: false,
      showTranslation: {},
    ));
  }

  void _onUpdateLoading(
    UpdateLoadingEvent event,
    Emitter<RitualsPrayersState> emit,
  ) {
    if (state is RitualsPrayersLoaded) {
      emit((state as RitualsPrayersLoaded).copyWith(
        isLoading: event.isLoading,
      ));
    }
  }

  void _onUpdateConnectivityChecked(
    UpdateConnectivityCheckedEvent event,
    Emitter<RitualsPrayersState> emit,
  ) {
    if (state is RitualsPrayersLoaded) {
      emit((state as RitualsPrayersLoaded).copyWith(
        connectivityChecked: event.checked,
      ));
    }
  }

  void _onToggleTranslation(
    ToggleTranslationEvent event,
    Emitter<RitualsPrayersState> emit,
  ) {
    if (state is RitualsPrayersLoaded) {
      final currentState = state as RitualsPrayersLoaded;
      final newShowTranslation = Map<String, bool>.from(currentState.showTranslation);
      newShowTranslation[event.duaId] = !(newShowTranslation[event.duaId] ?? false);
      
      emit(currentState.copyWith(
        showTranslation: newShowTranslation,
      ));
    }
  }
} 