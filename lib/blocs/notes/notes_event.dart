import 'package:equatable/equatable.dart';
import '../../models/note.dart';

abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotes extends NotesEvent {
  final String userId;
  final String? ritualId;
  final String? siteId;

  const LoadNotes(this.userId, {this.ritualId, this.siteId});

  @override
  List<Object?> get props => [userId, ritualId, siteId];
}

class AddNote extends NotesEvent {
  final String userId;
  final Note note;

  const AddNote(this.userId, this.note);

  @override
  List<Object?> get props => [userId, note];
}

class UpdateNote extends NotesEvent {
  final String userId;
  final Note note;

  const UpdateNote(this.userId, this.note);

  @override
  List<Object?> get props => [userId, note];
}

class DeleteNote extends NotesEvent {
  final String userId;
  final String noteId;

  const DeleteNote(this.userId, this.noteId);

  @override
  List<Object?> get props => [userId, noteId];
}

class ShowAddNoteDialog extends NotesEvent {
  const ShowAddNoteDialog();
}

class ShowEditNoteDialog extends NotesEvent {
  final Note note;

  const ShowEditNoteDialog(this.note);

  @override
  List<Object?> get props => [note];
}

class HideNoteDialog extends NotesEvent {
  const HideNoteDialog();
} 