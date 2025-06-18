import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alchemist/alchemist.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';

// Import only the simplest screens that work well
import 'package:umrahguideproject_appdevproject2/screens/splash/splash_screen.dart';

// Mock classes
// class MockNavigationBloc extends Mock implements NavigationBloc {}

void main() {
  group('Golden Tests', () {
    setUpAll(() {
      // Set up method channel mocks for platform services
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Mock connectivity
      const MethodChannel('plugins.flutter.io/connectivity')
          .setMockMethodCallHandler((MethodCall methodCall) async {
        return 'wifi';
      });

      // Mock Firebase Core
      const MethodChannel('plugins.flutter.io/firebase_core')
          .setMockMethodCallHandler((MethodCall methodCall) async {
        return null;
      });

      // Mock Firebase Auth
      const MethodChannel('plugins.flutter.io/firebase_auth')
          .setMockMethodCallHandler((MethodCall methodCall) async {
        return null;
      });

      // Mock Google Sign In
      const MethodChannel('plugins.flutter.io/google_sign_in')
          .setMockMethodCallHandler((MethodCall methodCall) async {
        return null;
      });

      // Mock Firestore
      const MethodChannel('plugins.flutter.io/cloud_firestore')
          .setMockMethodCallHandler((MethodCall methodCall) async {
        return null;
      });
    });

    goldenTest(
      'Splash Screen Golden Tests',
      fileName: 'splash_screen_golden_test',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'SplashScreen UI on multiple devices',
            child: SizedBox(
              width: 390, // e.g. iPhone 13 width
              height: 844, // e.g. iPhone 13 height
              child: MaterialApp(
                home: SplashScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  });
} 