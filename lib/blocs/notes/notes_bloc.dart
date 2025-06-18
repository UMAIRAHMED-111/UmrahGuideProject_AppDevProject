import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../services/notes_service.dart';
import '../../models/note.dart';
import 'notes_event.dart';
import 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NotesService _notesService;

  NotesBloc(this._notesService) : super(NotesInitial()) {
    on<LoadNotes>(_onLoadNotes);
    on<AddNote>(_onAddNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
    on<ShowAddNoteDialog>(_onShowAddNoteDialog);
    on<ShowEditNoteDialog>(_onShowEditNoteDialog);
    on<HideNoteDialog>(_onHideNoteDialog);
  }

  Future<void> _onLoadNotes(
    LoadNotes event,
    Emitter<NotesState> emit,
  ) async {
    emit(NotesLoading());
    try {
      await emit.forEach<List<Note>>(
        _notesService.getRelatedNotes(
          event.userId,
          ritualId: event.ritualId,
          siteId: event.siteId,
        ),
        onData: (notes) => NotesLoaded(notes: notes),
        onError: (_, __) => const NotesError('Failed to load notes'),
      );
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onAddNote(
    AddNote event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await _notesService.addNote(event.userId, event.note);
      if (state is NotesLoaded) {
        final currentState = state as NotesLoaded;
        emit(currentState.copyWith(showDialog: false, editingNote: null));
      }
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onUpdateNote(
    UpdateNote event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await _notesService.updateNote(event.userId, event.note);
      if (state is NotesLoaded) {
        final currentState = state as NotesLoaded;
        emit(currentState.copyWith(showDialog: false, editingNote: null));
      }
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onDeleteNote(
    DeleteNote event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await _notesService.deleteNote(event.userId, event.noteId);
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  void _onShowAddNoteDialog(
    ShowAddNoteDialog event,
    Emitter<NotesState> emit,
  ) {
    if (state is NotesLoaded) {
      final currentState = state as NotesLoaded;
      emit(currentState.copyWith(showDialog: true, editingNote: null));
    }
  }

  void _onShowEditNoteDialog(
    ShowEditNoteDialog event,
    Emitter<NotesState> emit,
  ) {
    if (state is NotesLoaded) {
      final currentState = state as NotesLoaded;
      emit(currentState.copyWith(showDialog: true, editingNote: event.note));
    }
  }

  void _onHideNoteDialog(
    HideNoteDialog event,
    Emitter<NotesState> emit,
  ) {
    if (state is NotesLoaded) {
      final currentState = state as NotesLoaded;
      emit(currentState.copyWith(showDialog: false, editingNote: null));
    }
  }
} 