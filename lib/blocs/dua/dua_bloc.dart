import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../../models/dua.dart';

part 'dua_event.dart';
part 'dua_state.dart';

class DuaBloc extends Bloc<DuaEvent, DuaState> {
  final FirebaseFirestore firestore;
  final Box hiveBox;

  DuaBloc({required this.firestore, required this.hiveBox}) : super(DuaInitial()) {
    on<LoadDuas>(_onLoadDuas);
    on<FilterByCategory>(_onFilterByCategory);
  }

  Future<void> _onLoadDuas(LoadDuas event, Emitter<DuaState> emit) async {
    emit(DuaLoading());
    try {
      // Try loading from Hive first
      final cached = hiveBox.get('duas');
      if (cached != null) {
        final duas = (cached as List).map((e) => Dua.fromMap(Map<String, dynamic>.from(e))).toList();
        emit(DuaLoaded(duas));
      }
      // Always try to update from Firestore
      final snapshot = await firestore.collection('duas').get();
      final duas = snapshot.docs.map((doc) => Dua.fromMap(doc.data())).toList();
      hiveBox.put('duas', duas.map((d) => d.toMap()).toList());
      emit(DuaLoaded(duas));
    } catch (e) {
      emit(DuaError(e.toString()));
    }
  }

  Future<void> _onFilterByCategory(FilterByCategory event, Emitter<DuaState> emit) async {
    if (state is DuaLoaded) {
      final allDuas = (state as DuaLoaded).duas;
      final filtered = allDuas.where((d) => d.category == event.category).toList();
      emit(DuaLoaded(filtered));
    }
  }
} 