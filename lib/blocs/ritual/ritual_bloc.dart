import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/ritual.dart';

part 'ritual_event.dart';
part 'ritual_state.dart';

class RitualBloc extends Bloc<RitualEvent, RitualState> {
  final FirebaseFirestore firestore;
  final Box hiveBox;
  final FirebaseAuth auth;

  RitualBloc({
    required this.firestore, 
    required this.hiveBox,
    required this.auth,
  }) : super(RitualInitial()) {
    on<LoadRituals>(_onLoadRituals);
    on<FilterByCategory>(_onFilterByCategory);
    on<ToggleComplete>(_onToggleComplete);
  }

  Future<void> _onLoadRituals(LoadRituals event, Emitter<RitualState> emit) async {
    emit(RitualLoading());
    try {
      // Try loading from Hive first
      final cached = hiveBox.get('rituals');
      if (cached != null) {
        final rituals = (cached as List).map((e) => Ritual.fromMap(Map<String, dynamic>.from(e))).toList();
        emit(RitualLoaded(rituals));
      }
      // Always try to update from Firestore
      final snapshot = await firestore.collection('rituals').get();
      final rituals = snapshot.docs.map((doc) => Ritual.fromMap(doc.data())).toList();
      hiveBox.put('rituals', rituals.map((r) => r.toMap()).toList());
      emit(RitualLoaded(rituals));
    } catch (e) {
      emit(RitualError(e.toString()));
    }
  }

  Future<void> _onFilterByCategory(FilterByCategory event, Emitter<RitualState> emit) async {
    if (state is RitualLoaded) {
      final allRituals = (state as RitualLoaded).rituals;
      final filtered = allRituals.where((r) => r.title == event.category).toList();
      emit(RitualLoaded(filtered));
    }
  }

  Future<void> _onToggleComplete(ToggleComplete event, Emitter<RitualState> emit) async {
    if (state is RitualLoaded) {
      final allRituals = (state as RitualLoaded).rituals;
      final updatedRituals = allRituals.map((r) => 
        r.id == event.id ? r.copyWith(isComplete: event.completed) : r
      ).toList();
      hiveBox.put('rituals', updatedRituals.map((r) => r.toMap()).toList());
      emit(RitualLoaded(updatedRituals));
    }
  }
} 