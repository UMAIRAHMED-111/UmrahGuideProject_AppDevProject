import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'core/theme.dart'; // Make sure this file contains AppTheme class
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'seed_data.dart';
// Your route definitions
import 'widgets/auth_wrapper.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/main_shell.dart';
import 'services/auth_service.dart';
import 'services/checklist_service.dart';
import 'services/notes_service.dart';
import 'services/reminder_service.dart';
import 'blocs/checklist/checklist_bloc.dart';
import 'blocs/notes/notes_bloc.dart';
import 'blocs/reminder/reminder_bloc.dart';
import 'services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  await Hive.openBox('ritualsBox');
  await Hive.openBox('duasBox');
  final prefs = await SharedPreferences.getInstance();
  await seedData(); // <-- Seed Firestore with sample data
  await NotificationService().initialize();
  runApp(ZiyarahApp(prefs: prefs));
}

class ZiyarahApp extends StatelessWidget {
  final SharedPreferences prefs;
  
  const ZiyarahApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<ChecklistService>(
          create: (_) => ChecklistService(prefs),
        ),
        Provider<NotesService>(
          create: (_) => NotesService(prefs),
        ),
        Provider<ReminderService>(
          create: (_) => ReminderService(FirebaseFirestore.instance),
        ),
        BlocProvider<ChecklistBloc>(
          create: (context) => ChecklistBloc(context.read<ChecklistService>()),
        ),
        BlocProvider<NotesBloc>(
          create: (context) => NotesBloc(context.read<NotesService>()),
        ),
        BlocProvider<ReminderBloc>(
          create: (context) => ReminderBloc(context.read<ReminderService>()),
        ),
      ],
      child: MaterialApp(
        title: 'Ziyarah',
        debugShowCheckedModeBanner: false,

        // ✅ Global theme with Cairo font and custom colors
        theme: AppTheme.theme,

        // ✅ Optionally support dark mode (add if needed)
        // darkTheme: AppTheme.darkTheme,
        // themeMode: ThemeMode.system,

        // ✅ Use MainShell as home for bottom navigation
        home: const MainShell(),

        // ✅ Keep routes for splash screen and other non-auth screens
        routes: {
          '/splash': (context) => const SplashScreen(),
        },
      ),
    );
  }
}
