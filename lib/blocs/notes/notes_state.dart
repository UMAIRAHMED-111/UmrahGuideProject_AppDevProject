import 'package:equatable/equatable.dart';
import '../../models/note.dart';

abstract class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object?> get props => [];
}

class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  final List<Note> notes;
  final bool showDialog;
  final Note? editingNote;

  const NotesLoaded({
    required this.notes,
    this.showDialog = false,
    this.editingNote,
  });

  NotesLoaded copyWith({
    List<Note>? notes,
    bool? showDialog,
    Note? editingNote,
  }) {
    return NotesLoaded(
      notes: notes ?? this.notes,
      showDialog: showDialog ?? this.showDialog,
      editingNote: editingNote ?? this.editingNote,
    );
  }

  @override
  List<Object?> get props => [notes, showDialog, editingNote];
}

class NotesError extends NotesState {
  final String message;

  const NotesError(this.message);

  @override
  List<Object?> get props => [message];
} 