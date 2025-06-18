// checklist_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/checklist_item.dart';
import '../blocs/checklist/checklist_bloc.dart';
import '../blocs/checklist/checklist_event.dart';
import '../blocs/checklist/checklist_state.dart';
import '../services/auth_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({Key? key, this.onShowAddDialog}) : super(key: key);
  final VoidCallback? onShowAddDialog;

  @override
  ChecklistScreenState createState() => ChecklistScreenState();
}

class ChecklistScreenState extends State<ChecklistScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _connectivityChecked = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void showAddItemDialog() {
    context.read<ChecklistBloc>().add(ShowAddChecklistDialog());
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

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkConnectivityAndShowSnackbar(context);
    });

    return BlocListener<ChecklistBloc, ChecklistState>(
      listenWhen: (prev, curr) =>
          prev is ChecklistLoaded && curr is ChecklistLoaded && prev.isAdding != curr.isAdding,
      listener: (context, state) {
        if (state is ChecklistLoaded && state.isAdding) {
          _titleController.clear();
          _descriptionController.clear();

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Add Checklist Item'),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please enter a title' : null,
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description (optional)'),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<ChecklistBloc>().add(HideAddChecklistDialog());
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final userId = context.read<AuthService>().currentUser?.uid;
                      if (userId != null) {
                        final item = ChecklistItem(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: _titleController.text,
                          description: _descriptionController.text.isEmpty
                              ? null
                              : _descriptionController.text,
                          isCustom: true,
                          createdAt: DateTime.now(),
                        );
                        context.read<ChecklistBloc>().add(AddChecklistItem(userId, item));
                      }
                      Navigator.pop(context);
                      context.read<ChecklistBloc>().add(HideAddChecklistDialog());
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          );
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F3D2E), Color(0xFF1A6244)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: _buildChecklistTab(),
        ),
      ),
    );
  }

  Widget _buildChecklistTab() {
    final userId = context.watch<AuthService>().currentUser?.uid;
    if (userId == null) {
      return const Center(child: Text('Please sign in to view your checklist', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')));
    }

    return BlocBuilder<ChecklistBloc, ChecklistState>(
      builder: (context, state) {
        if (state is ChecklistInitial) {
          context.read<ChecklistBloc>().add(LoadChecklist(userId));
          return _buildShimmerLoading();
        }
        if (state is ChecklistLoading) {
          return _buildShimmerLoading();
        }
        if (state is ChecklistError) {
          return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.white, fontFamily: 'Cairo')));
        }
        if (state is ChecklistLoaded) {
          final items = List<ChecklistItem>.from(state.items);
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No checklist items yet', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF32D27F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      context.read<ChecklistBloc>().add(InitializeDefaultChecklist(userId));
                    },
                    child: const Text('Initialize Default Checklist', style: TextStyle(fontFamily: 'Cairo')),
                  ),
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: ReorderableListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              buildDefaultDragHandles: false,
              proxyDecorator: (child, index, animation) {
                return Transform.scale(
                  scale: 1.03,
                  child: Material(
                    color: Colors.transparent,
                    elevation: 8,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white.withOpacity(0.12),
                        border: Border.all(color: Colors.white.withOpacity(0.18)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: child,
                    ),
                  ),
                );
              },
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) newIndex--;
                final item = items.removeAt(oldIndex);
                items.insert(newIndex, item);
                context.read<ChecklistBloc>().add(ReorderChecklist(userId, items));
              },
              children: [
                for (int index = 0; index < items.length; index++)
                  Container(
                    key: Key(items[index].id),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withOpacity(0.08),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: ListTile(
                      leading: Transform.scale(
                        scale: 1.2,
                        child: Checkbox(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          value: items[index].isDone,
                          onChanged: (bool? value) {
                            if (value != null) {
                              final updatedItem = items[index].copyWith(
                                isDone: value,
                                completedAt: value ? DateTime.now() : null,
                              );
                              context.read<ChecklistBloc>().add(UpdateChecklistItem(userId, updatedItem));
                            }
                          },
                          activeColor: const Color(0xFF32D27F),
                          side: const BorderSide(color: Color(0xFF32D27F), width: 2),
                        ),
                      ),
                      title: Text(
                        items[index].title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      subtitle: items[index].description != null
                          ? Text(
                              items[index].description!,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontFamily: 'Cairo',
                              ),
                            )
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ReorderableDragStartListener(
                            index: index,
                            child: const Icon(Icons.drag_handle, color: Colors.white70),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              context.read<ChecklistBloc>().add(DeleteChecklistItem(userId, items[index].id));
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
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
}
