import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/note.dart';
import '../blocs/notes/notes_bloc.dart';
import '../blocs/notes/notes_event.dart';
import '../blocs/notes/notes_state.dart';
import '../services/auth_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NotesScreen extends StatefulWidget {
  final String? ritualId;
  final String? siteId;
  final String? title;

  const NotesScreen({
    Key? key,
    this.ritualId,
    this.siteId,
    this.title,
  }) : super(key: key);

  @override
  NotesScreenState createState() => NotesScreenState();
}

class NotesScreenState extends State<NotesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _connectivityChecked = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _checkConnectivityAndShowSnackbar(BuildContext context) async {
    if (_connectivityChecked) return;
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection. Some features may not work.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
    _connectivityChecked = true;
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      itemCount: 3,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withOpacity(0.08),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 180,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 120,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteDialog(BuildContext context, NotesLoaded state) {
    final editingNote = state.editingNote;
    
    // Set controller values based on editing state
    _titleController.text = editingNote?.title ?? '';
    _contentController.text = editingNote?.content ?? '';

    return AlertDialog(
      title: Text(editingNote == null ? 'Add Note' : 'Edit Note'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some content';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.read<NotesBloc>().add(const HideNoteDialog());
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final userId = context.read<AuthService>().currentUser?.uid;
              if (userId != null) {
                final now = DateTime.now();
                final note = Note(
                  id: editingNote?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  title: _titleController.text,
                  content: _contentController.text,
                  relatedRitualId: widget.ritualId,
                  relatedSiteId: widget.siteId,
                  createdAt: editingNote?.createdAt ?? now,
                  updatedAt: now,
                );

                if (editingNote == null) {
                  context.read<NotesBloc>().add(AddNote(userId, note));
                } else {
                  context.read<NotesBloc>().add(UpdateNote(userId, note));
                }
              }
            }
          },
          child: Text(editingNote == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context, NotesLoaded state) {
    final notes = state.notes;
    
    if (notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No notes yet', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF32D27F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                context.read<NotesBloc>().add(const ShowAddNoteDialog());
              },
              child: const Text('Add Note', style: TextStyle(fontFamily: 'Cairo')),
            ),
          ],
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 80),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withOpacity(0.08),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: ListTile(
              title: Text(
                note.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Cairo',
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.content,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last updated: ${note.updatedAt.toString().split('.')[0]}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70, fontFamily: 'Cairo'),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF32D27F)),
                    onPressed: () {
                      context.read<NotesBloc>().add(ShowEditNoteDialog(note));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      final userId = context.read<AuthService>().currentUser?.uid;
                      if (userId != null) {
                        context.read<NotesBloc>().add(DeleteNote(userId, note.id));
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkConnectivityAndShowSnackbar(context);
    });
    
    final userId = context.watch<AuthService>().currentUser?.uid;
    if (userId == null) {
      return const Center(child: Text('Please sign in to view your notes', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')));
    }
    
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F3D2E), Color(0xFF1A6244)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: BlocBuilder<NotesBloc, NotesState>(
          builder: (context, state) {
            if (state is NotesInitial) {
              context.read<NotesBloc>().add(LoadNotes(userId, ritualId: widget.ritualId, siteId: widget.siteId));
              return _buildShimmerLoading();
            }
            
            if (state is NotesLoading) {
              return _buildShimmerLoading();
            }
            
            if (state is NotesError) {
              return Center(child: Text('Error: ${state.message}', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')));
            }
            
            if (state is NotesLoaded) {
              return Stack(
                children: [
                  _buildMainContent(context, state),
                  if (state.showDialog)
                    Container(
                      color: Colors.black54,
                      child: Center(
                        child: _buildNoteDialog(context, state),
                      ),
                    ),
                ],
              );
            }
            
            return const Center(child: Text('Unknown state', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')));
          },
        ),
      ),
    );
  }
} 