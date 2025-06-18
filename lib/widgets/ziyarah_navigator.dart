import 'package:flutter/material.dart';
import 'ziyarah_loader.dart';

class ZiyarahNavigator {
  static Future<T?> push<T>(BuildContext context, Widget page, {String? loadingMessage}) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  static Future<T?> pushReplacement<T>(BuildContext context, Widget page, {String? loadingMessage}) {
    return Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  static void showLoader(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ZiyarahLoader(message: message),
    );
  }

  static void hideLoader(BuildContext context) {
    Navigator.of(context).pop();
  }
} 