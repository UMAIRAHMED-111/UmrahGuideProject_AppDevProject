import 'package:flutter/material.dart';
import '../../blocs/reminder/reminder_bloc.dart';
import '../../blocs/reminder/reminder_event.dart';
import '../../blocs/reminder/reminder_state.dart';
import '../../models/reminder.dart';
import '../../services/auth_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../checklist_screen.dart';
import '../notes_screen.dart';
import '../../blocs/checklist/checklist_bloc.dart';
import '../../blocs/checklist/checklist_event.dart';
import '../../blocs/checklist/checklist_state.dart';
import '../../models/checklist_item.dart';
import '../../blocs/preparation/preparation_bloc.dart';
import '../../blocs/preparation/preparation_event.dart';
import '../../blocs/preparation/preparation_state.dart';
import '../../blocs/notes/notes_bloc.dart';
import '../../blocs/notes/notes_event.dart';

class PreparationScreen extends StatefulWidget {
  const PreparationScreen({Key? key}) : super(key: key);

  @override
  _PreparationScreenState createState() => _PreparationScreenState();
}

class _PreparationScreenState extends State<PreparationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ChecklistScreenState> _checklistKey = GlobalKey<ChecklistScreenState>();
  final GlobalKey<NotesScreenState> _notesKey = GlobalKey<NotesScreenState>();
  final _reminderTitleController = TextEditingController();
  final _reminderDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PreparationBloc>().add(TabChanged(_tabController.index));
      }
    });

    _tabController.addListener(() {
      if (mounted) {
        context.read<PreparationBloc>().add(TabChanged(_tabController.index));
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reminderTitleController.dispose();
    _reminderDescriptionController.dispose();
    super.dispose();
  }

  void showAddReminderDialog({required BuildContext context, Reminder? reminder}) {
    _reminderTitleController.text = reminder?.title ?? '';
    _reminderDescriptionController.text = reminder?.description ?? '';

    DateTime selectedTime = reminder?.reminderTime ?? DateTime.now();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(reminder == null ? 'Add Reminder' : 'Edit Reminder'),
              content: Form(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _reminderTitleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _reminderDescriptionController,
                      decoration: const InputDecoration(labelText: 'Description (optional)'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Time'),
                      subtitle: Text(
                        '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                      ),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedTime),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedTime = DateTime(
                              selectedTime.year,
                              selectedTime.month,
                              selectedTime.day,
                              picked.hour,
                              picked.minute,
                            );
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final userId = context.read<AuthService>().currentUser?.uid;
                    if (userId != null && _reminderTitleController.text.isNotEmpty) {
                      final updatedReminder = Reminder(
                        id: reminder?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                        title: _reminderTitleController.text,
                        description: _reminderDescriptionController.text.isEmpty
                            ? null
                            : _reminderDescriptionController.text,
                        reminderTime: selectedTime,
                        isSystemGenerated: reminder?.isSystemGenerated ?? false,
                        isEnabled: reminder?.isEnabled ?? true,
                        createdAt: reminder?.createdAt ?? DateTime.now(),
                        lastTriggeredAt: reminder?.lastTriggeredAt,
                      );
                      if (reminder == null) {
                        context.read<ReminderBloc>().add(AddReminder(userId, updatedReminder));
                      } else {
                        context.read<ReminderBloc>().add(UpdateReminder(userId, updatedReminder));
                      }
                    }
                    Navigator.pop(context);
                  },
                  child: Text(reminder == null ? 'Add' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRemindersTab() {
    final userId = context.watch<AuthService>().currentUser?.uid;
    if (userId == null) {
      return const Center(child: Text('Please sign in to view your reminders', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')));
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
        child: BlocBuilder<ReminderBloc, ReminderState>(
          builder: (context, state) {
            if (state is ReminderInitial) {
              context.read<ReminderBloc>().add(LoadReminders(userId));
              return _buildShimmerLoading();
            }
            if (state is ReminderLoading) {
              return _buildShimmerLoading();
            }
            if (state is ReminderError) {
              return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.white, fontFamily: 'Cairo')));
            }
            if (state is ReminderLoaded) {
              final reminders = state.reminders;
              return BlocBuilder<PreparationBloc, PreparationState>(
                builder: (context, prepState) {
                  if (prepState is PreparationLoaded) {
                    if (reminders.isEmpty && !prepState.remindersInitialized) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        context.read<ReminderBloc>().add(InitializePrayerTimeReminders(userId));
                        context.read<PreparationBloc>().add(RemindersInitialized());
                      });
                      return _buildShimmerLoading();
                    }
                    if (reminders.isEmpty) {
                      return Center(
                        child: Text('No reminders yet', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 80),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                        itemCount: reminders.length,
                        itemBuilder: (context, index) {
                          final reminder = reminders[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white.withOpacity(0.08),
                              border: Border.all(color: Colors.white.withOpacity(0.15)),
                            ),
                            child: ListTile(
                              leading: Transform.scale(
                                scale: 1.2,
                                child: Switch(
                                  value: reminder.isEnabled,
                                  onChanged: (bool value) {
                                    final updatedReminder = reminder.copyWith(isEnabled: value);
                                    context.read<ReminderBloc>().add(UpdateReminder(userId, updatedReminder));
                                  },
                                  activeColor: const Color(0xFF32D27F),
                                ),
                              ),
                              title: Text(
                                reminder.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (reminder.description != null)
                                    Text(
                                      reminder.description!,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.85),
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${reminder.reminderTime.hour.toString().padLeft(2, '0')}:${reminder.reminderTime.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ],
                              ),
                              trailing: reminder.isSystemGenerated
                                  ? const Icon(Icons.lock, color: Colors.white70)
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Color(0xFF32D27F)),
                                          onPressed: () {
                                            showAddReminderDialog(context: context, reminder: reminder);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () {
                                            context.read<ReminderBloc>().add(DeleteReminder(userId, reminder.id));
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
                  return const SizedBox.shrink();
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PreparationBloc, PreparationState>(
      builder: (context, state) {
        if (state is PreparationLoaded) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: const Color(0xFF0F3D2E),
              elevation: 0,
              title: const Text(
                'Preparation',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  fontSize: 26,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black26)],
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF32D27F),
                labelColor: const Color(0xFF32D27F),
                unselectedLabelColor: Colors.white,
                labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(icon: Icon(Icons.checklist, color: Colors.white), text: 'Checklist'),
                  Tab(icon: Icon(Icons.alarm, color: Colors.white), text: 'Reminders'),
                  Tab(icon: Icon(Icons.note, color: Colors.white), text: 'Notes'),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                ChecklistScreen(key: _checklistKey),
                _buildRemindersTab(),
                NotesScreen(key: _notesKey),
              ],
            ),
            floatingActionButton: state.currentTabIndex == 0
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 90.0),
                    child: FloatingActionButton(
                      onPressed: () {
                        _checklistKey.currentState?.showAddItemDialog();
                      },
                      child: const Icon(Icons.add),
                      tooltip: 'Add Checklist Item',
                    ),
                  )
                : state.currentTabIndex == 1
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 90.0),
                        child: Builder(
                          builder: (innerContext) => FloatingActionButton(
                            onPressed: () => showAddReminderDialog(context: innerContext),
                            child: const Icon(Icons.add),
                            tooltip: 'Add Reminder',
                          ),
                        ),
                      )
                    : state.currentTabIndex == 2
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 90.0),
                            child: FloatingActionButton(
                              onPressed: () {
                                context.read<NotesBloc>().add(const ShowAddNoteDialog());
                              },
                              child: const Icon(Icons.add),
                              tooltip: 'Add Note',
                            ),
                          )
                        : null,
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
        }

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
