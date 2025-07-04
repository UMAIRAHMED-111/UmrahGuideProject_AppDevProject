import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alchemist/alchemist.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import all screens
import 'package:umrahguideproject_appdevproject2/screens/splash/splash_screen.dart';
import 'package:umrahguideproject_appdevproject2/screens/login/login_screen.dart';
import 'package:umrahguideproject_appdevproject2/screens/home/home_screen.dart';
import 'package:umrahguideproject_appdevproject2/screens/checklist_screen.dart';
import 'package:umrahguideproject_appdevproject2/screens/notes_screen.dart';
import 'package:umrahguideproject_appdevproject2/screens/preparation/preparation_screen.dart';
import 'package:umrahguideproject_appdevproject2/screens/rituals_prayers/rituals_prayers_screen.dart';
import 'package:umrahguideproject_appdevproject2/screens/help_ai/help_ai_screen.dart';

// Import blocs
import 'package:umrahguideproject_appdevproject2/blocs/auth/auth_bloc.dart';
import 'package:umrahguideproject_appdevproject2/blocs/auth/auth_state.dart';
import 'package:umrahguideproject_appdevproject2/blocs/auth/auth_event.dart';
import 'package:umrahguideproject_appdevproject2/blocs/home/home_bloc.dart';
import 'package:umrahguideproject_appdevproject2/blocs/home/home_state.dart';
import 'package:umrahguideproject_appdevproject2/blocs/home/home_event.dart';
import 'package:umrahguideproject_appdevproject2/blocs/checklist/checklist_bloc.dart';
import 'package:umrahguideproject_appdevproject2/blocs/checklist/checklist_state.dart';
import 'package:umrahguideproject_appdevproject2/blocs/checklist/checklist_event.dart';
import 'package:umrahguideproject_appdevproject2/blocs/notes/notes_bloc.dart';
import 'package:umrahguideproject_appdevproject2/blocs/notes/notes_state.dart';
import 'package:umrahguideproject_appdevproject2/blocs/notes/notes_event.dart';
import 'package:umrahguideproject_appdevproject2/blocs/preparation/preparation_bloc.dart';
import 'package:umrahguideproject_appdevproject2/blocs/preparation/preparation_state.dart';
import 'package:umrahguideproject_appdevproject2/blocs/preparation/preparation_event.dart';
import 'package:umrahguideproject_appdevproject2/blocs/ritual/ritual_bloc.dart';
import 'package:umrahguideproject_appdevproject2/blocs/help_ai/help_ai_bloc.dart';
import 'package:umrahguideproject_appdevproject2/blocs/help_ai/help_ai_state.dart';
import 'package:umrahguideproject_appdevproject2/blocs/help_ai/help_ai_event.dart';

// Import services
import 'package:umrahguideproject_appdevproject2/services/auth_service.dart';

// Mock classes
class MockAuthService extends Mock implements AuthService {}
class MockAuthBloc extends Mock implements AuthBloc {}
class MockHomeBloc extends Mock implements HomeBloc {}
class MockChecklistBloc extends Mock implements ChecklistBloc {}
class MockNotesBloc extends Mock implements NotesBloc {}
class MockPreparationBloc extends Mock implements PreparationBloc {}
class MockRitualBloc extends Mock implements RitualBloc {}
class MockHelpAIBloc extends Mock implements HelpAIBloc {}

class FakeAuthState extends Fake implements AuthState {}
class FakeAuthEvent extends Fake implements AuthEvent {}
class FakeHomeState extends Fake implements HomeState {}
class FakeHomeEvent extends Fake implements HomeEvent {}
class FakeChecklistState extends Fake implements ChecklistState {}
class FakeChecklistEvent extends Fake implements ChecklistEvent {}
class FakeNotesState extends Fake implements NotesState {}
class FakeNotesEvent extends Fake implements NotesEvent {}
class FakePreparationState extends Fake implements PreparationState {}
class FakePreparationEvent extends Fake implements PreparationEvent {}
class FakeRitualState extends Fake implements RitualState {}
class FakeRitualEvent extends Fake implements RitualEvent {}
class FakeHelpAIState extends Fake implements HelpAIState {}
class FakeHelpAIEvent extends Fake implements HelpAIEvent {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthService mockAuthService;
  late MockAuthBloc mockAuthBloc;
  late MockHomeBloc mockHomeBloc;
  late MockChecklistBloc mockChecklistBloc;
  late MockNotesBloc mockNotesBloc;
  late MockPreparationBloc mockPreparationBloc;
  late MockRitualBloc mockRitualBloc;
  late MockHelpAIBloc mockHelpAIBloc;

  setUpAll(() async {
    // Register fallback values for all fake classes
    registerFallbackValue(FakeAuthState());
    registerFallbackValue(FakeAuthEvent());
    registerFallbackValue(FakeHomeState());
    registerFallbackValue(FakeHomeEvent());
    registerFallbackValue(FakeChecklistState());
    registerFallbackValue(FakeChecklistEvent());
    registerFallbackValue(FakeNotesState());
    registerFallbackValue(FakeNotesEvent());
    registerFallbackValue(FakePreparationState());
    registerFallbackValue(FakePreparationEvent());
    registerFallbackValue(FakeRitualState());
    registerFallbackValue(FakeRitualEvent());
    registerFallbackValue(FakeHelpAIState());
    registerFallbackValue(FakeHelpAIEvent());

    // Mock Firebase Core
    const MethodChannel firebaseCore = MethodChannel('plugins.flutter.io/firebase_core');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      firebaseCore,
      (MethodCall methodCall) async {
        return {
          'app': {
            'name': '[DEFAULT]',
            'options': {
              'apiKey': 'test-api-key',
              'appId': 'test-app-id',
              'messagingSenderId': 'test-sender-id',
              'projectId': 'test-project-id',
            },
          },
          'pluginConstants': {},
        };
      },
    );

    // Mock Firebase Auth
    const MethodChannel firebaseAuth = MethodChannel('plugins.flutter.io/firebase_auth');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      firebaseAuth,
      (MethodCall methodCall) async {
        if (methodCall.method == 'getCurrentUser') {
          return {
            'uid': 'mock_uid',
            'email': 'mock@email.com',
            'displayName': 'Test User',
            'photoURL': null,
          };
        }
        return null;
      },
    );

    // Mock Connectivity Plus
    const MethodChannel connectivity = MethodChannel('dev.fluttercommunity.plus/connectivity');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      connectivity,
      (MethodCall methodCall) async {
        if (methodCall.method == 'check') {
          return 1; // ConnectivityResult.wifi
        }
        return null;
      },
    );

    // Mock Hive
    const MethodChannel hive = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      hive,
      (MethodCall methodCall) async {
        return '/tmp/test_path';
      },
    );

    // Load Cairo font
    final cairoLoader = FontLoader('Cairo')
      ..addFont(rootBundle.load('assets/fonts/Cairo-VariableFont_slnt,wght.ttf'));
    await cairoLoader.load();
  });

  setUp(() {
    mockAuthService = MockAuthService();
    mockAuthBloc = MockAuthBloc();
    mockHomeBloc = MockHomeBloc();
    mockChecklistBloc = MockChecklistBloc();
    mockNotesBloc = MockNotesBloc();
    mockPreparationBloc = MockPreparationBloc();
    mockRitualBloc = MockRitualBloc();
    mockHelpAIBloc = MockHelpAIBloc();

    // Setup default mock behaviors
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockHomeBloc.state).thenReturn(HomeInitial());
    when(() => mockHomeBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockChecklistBloc.state).thenReturn(ChecklistInitial());
    when(() => mockChecklistBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockNotesBloc.state).thenReturn(NotesInitial());
    when(() => mockNotesBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockPreparationBloc.state).thenReturn(PreparationInitial());
    when(() => mockPreparationBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockRitualBloc.state).thenReturn(RitualInitial());
    when(() => mockRitualBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockHelpAIBloc.state).thenReturn(HelpAIInitial());
    when(() => mockHelpAIBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  group('Splash Screen Golden Tests', () {
    goldenTest(
      'SplashScreen UI on multiple devices',
      fileName: 'splash_screen_ui',
      builder: () => GoldenTestGroup(
        children: [
          for (final device in [
            {'name': 'Samsung S21', 'width': 360.0, 'height': 800.0},
            {'name': 'iPhone 13', 'width': 390.0, 'height': 844.0},
            {'name': 'Pixel 5', 'width': 393.0, 'height': 851.0},
          ])
            GoldenTestScenario(
              name: device['name'] as String,
              child: SizedBox(
                width: device['width'] as double,
                height: device['height'] as double,
                child: MaterialApp(
                  home: const SplashScreen(),
                ),
              ),
            ),
        ],
      ),
    );
  });

  group('Login Screen Golden Tests', () {
    goldenTest(
      'LoginScreen UI on multiple devices',
      fileName: 'login_screen_ui',
      builder: () => GoldenTestGroup(
        children: [
          for (final device in [
            {'name': 'Samsung S21', 'width': 360.0, 'height': 800.0},
            {'name': 'iPhone 13', 'width': 390.0, 'height': 844.0},
            {'name': 'Pixel 5', 'width': 393.0, 'height': 851.0},
          ])
            GoldenTestScenario(
              name: device['name'] as String,
              child: SizedBox(
                width: device['width'] as double,
                height: device['height'] as double,
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider<AuthBloc>.value(value: mockAuthBloc),
                  ],
                  child: MaterialApp(
                    home: const LoginScreen(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  });

  group('Home Screen Golden Tests', () {
    goldenTest(
      'HomeScreen UI on multiple devices',
      fileName: 'home_screen_ui',
      builder: () => GoldenTestGroup(
        children: [
          for (final device in [
            {'name': 'Samsung S21', 'width': 360.0, 'height': 800.0},
            {'name': 'iPhone 13', 'width': 390.0, 'height': 844.0},
            {'name': 'Pixel 5', 'width': 393.0, 'height': 851.0},
          ])
            GoldenTestScenario(
              name: device['name'] as String,
              child: SizedBox(
                width: device['width'] as double,
                height: device['height'] as double,
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider<HomeBloc>.value(value: mockHomeBloc),
                  ],
                  child: MaterialApp(
                    home: const HomeScreen(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  });

  group('Checklist Screen Golden Tests', () {
    goldenTest(
      'ChecklistScreen UI on multiple devices',
      fileName: 'checklist_screen_ui',
      builder: () => GoldenTestGroup(
        children: [
          for (final device in [
            {'name': 'Samsung S21', 'width': 360.0, 'height': 800.0},
            {'name': 'iPhone 13', 'width': 390.0, 'height': 844.0},
            {'name': 'Pixel 5', 'width': 393.0, 'height': 851.0},
          ])
            GoldenTestScenario(
              name: device['name'] as String,
              child: SizedBox(
                width: device['width'] as double,
                height: device['height'] as double,
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider<ChecklistBloc>.value(value: mockChecklistBloc),
                  ],
                  child: MaterialApp(
                    home: const ChecklistScreen(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  });

  group('Notes Screen Golden Tests', () {
    goldenTest(
      'NotesScreen UI on multiple devices',
      fileName: 'notes_screen_ui',
      builder: () => GoldenTestGroup(
        children: [
          for (final device in [
            {'name': 'Samsung S21', 'width': 360.0, 'height': 800.0},
            {'name': 'iPhone 13', 'width': 390.0, 'height': 844.0},
            {'name': 'Pixel 5', 'width': 393.0, 'height': 851.0},
          ])
            GoldenTestScenario(
              name: device['name'] as String,
              child: SizedBox(
                width: device['width'] as double,
                height: device['height'] as double,
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider<NotesBloc>.value(value: mockNotesBloc),
                  ],
                  child: MaterialApp(
                    home: const NotesScreen(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  });

  group('Preparation Screen Golden Tests', () {
    goldenTest(
      'PreparationScreen UI on multiple devices',
      fileName: 'preparation_screen_ui',
      builder: () => GoldenTestGroup(
        children: [
          for (final device in [
            {'name': 'Samsung S21', 'width': 360.0, 'height': 800.0},
            {'name': 'iPhone 13', 'width': 390.0, 'height': 844.0},
            {'name': 'Pixel 5', 'width': 393.0, 'height': 851.0},
          ])
            GoldenTestScenario(
              name: device['name'] as String,
              child: SizedBox(
                width: device['width'] as double,
                height: device['height'] as double,
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider<PreparationBloc>.value(value: mockPreparationBloc),
                  ],
                  child: MaterialApp(
                    home: const PreparationScreen(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  });

  group('Rituals Prayers Screen Golden Tests', () {
    goldenTest(
      'RitualsPrayersScreen UI on multiple devices',
      fileName: 'rituals_prayers_screen_ui',
      builder: () => GoldenTestGroup(
        children: [
          for (final device in [
            {'name': 'Samsung S21', 'width': 360.0, 'height': 800.0},
            {'name': 'iPhone 13', 'width': 390.0, 'height': 844.0},
            {'name': 'Pixel 5', 'width': 393.0, 'height': 851.0},
          ])
            GoldenTestScenario(
              name: device['name'] as String,
              child: SizedBox(
                width: device['width'] as double,
                height: device['height'] as double,
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider<RitualBloc>.value(value: mockRitualBloc),
                  ],
                  child: MaterialApp(
                    home: const RitualsPrayersScreen(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  });

  group('Help AI Screen Golden Tests', () {
    goldenTest(
      'HelpAiScreen UI on multiple devices',
      fileName: 'help_ai_screen_ui',
      builder: () => GoldenTestGroup(
        children: [
          for (final device in [
            {'name': 'Samsung S21', 'width': 360.0, 'height': 800.0},
            {'name': 'iPhone 13', 'width': 390.0, 'height': 844.0},
            {'name': 'Pixel 5', 'width': 393.0, 'height': 851.0},
          ])
            GoldenTestScenario(
              name: device['name'] as String,
              child: SizedBox(
                width: device['width'] as double,
                height: device['height'] as double,
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider<HelpAIBloc>.value(value: mockHelpAIBloc),
                  ],
                  child: MaterialApp(
                    home: const HelpAIScreen(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  });
} 