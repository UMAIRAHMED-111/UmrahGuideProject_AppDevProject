import 'package:flutter/material.dart';
import '../screens/login/login_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/rituals_prayers/rituals_prayers_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String ritualsPrayers = '/rituals_prayers';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    ritualsPrayers: (context) => const RitualsPrayersScreen(),
  };
}
