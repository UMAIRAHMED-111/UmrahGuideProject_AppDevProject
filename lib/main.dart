import 'package:flutter/material.dart';
import 'core/theme.dart'; // Make sure this file contains AppTheme class
import 'routes/app_routes.dart'; // Your route definitions

void main() {
  runApp(const ZiyarahApp());
}

class ZiyarahApp extends StatelessWidget {
  const ZiyarahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ziyarah',
      debugShowCheckedModeBanner: false,

      // ✅ Global theme with Cairo font and custom colors
      theme: AppTheme.theme,

      // ✅ Optionally support dark mode (add if needed)
      // darkTheme: AppTheme.darkTheme,
      // themeMode: ThemeMode.system,

      // ✅ Initial screen route
      initialRoute: '/splash',

      // ✅ Centralized app routing
      routes: AppRoutes.routes,
    );
  }
}
