import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'rituals_prayers/rituals_prayers_screen.dart';
import 'home/home_screen.dart';
import 'dart:ui';
import 'login/login_screen.dart';
import '../widgets/ziyarah_navigator.dart';
import 'preparation/preparation_screen.dart';
import 'help_ai/help_ai_screen.dart';
import 'location/location_screen.dart';
import '../blocs/navigation/navigation_bloc.dart';
import '../blocs/navigation/navigation_event.dart';
import '../blocs/navigation/navigation_state.dart';
import '../blocs/preparation/preparation_bloc.dart';
import '../blocs/preparation/preparation_event.dart';
import '../blocs/location/location_bloc.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';

class MainShell extends StatelessWidget {
  const MainShell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => NavigationBloc(authService: AuthService())..add(CheckAuthStatus()),
        ),
        BlocProvider(
          create: (context) => LocationBloc(LocationService()),
        ),
      ],
      child: BlocListener<NavigationBloc, NavigationState>(
        listener: (context, state) {
          if (state is NavigationUnauthenticated) {
            ZiyarahNavigator.pushReplacement(
              context,
              const LoginScreen(),
              loadingMessage: 'Redirecting to login...',
            );
          }
        },
        child: BlocBuilder<NavigationBloc, NavigationState>(
          builder: (context, state) {
            if (state is NavigationAuthenticated) {
              return _MainShellContent(
                user: state.user,
                selectedIndex: state.selectedIndex,
              );
            }
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MainShellContent extends StatelessWidget {
  final User user;
  final int selectedIndex;

  const _MainShellContent({
    required this.user,
    required this.selectedIndex,
  });

  void _onTabSelected(BuildContext context, int index) {
    if (selectedIndex != index) {
      ZiyarahNavigator.showLoader(
        context,
        message: 'Loading ${_getTabName(index)}...',
      );
      context.read<NavigationBloc>().add(NavigateToTab(index));
      Future.delayed(const Duration(milliseconds: 300), () {
        if (context.mounted) {
          ZiyarahNavigator.hideLoader(context);
        }
      });
    }
  }

  String _getTabName(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Rituals & Prayers';
      case 2:
        return 'Preparation';
      case 3:
        return 'Location Awareness';
      case 4:
        return 'Live Updates';
      default:
        return 'Screen';
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget currentScreen;

    switch (selectedIndex) {
      case 0:
        currentScreen = HomeScreen(user: user, onBlockTap: (index) => _onTabSelected(context, index));
        break;
      case 1:
        currentScreen = const RitualsPrayersScreen();
        break;
      case 2:
        currentScreen = BlocProvider(
          create: (_) => PreparationBloc()..add(TabChanged(0)),
          child: const PreparationScreen(),
        );
        break;
      case 3:
        currentScreen = const LocationScreen();
        break;
      case 4:
        currentScreen = const HelpAIScreen();
        break;
      default:
        currentScreen = const Center(child: Text("Unknown tab"));
    }

    return Scaffold(
      extendBody: true,
      body: currentScreen,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: const Color(0xFF32D27F),
              unselectedItemColor: Colors.white.withOpacity(0.7),
              showUnselectedLabels: true,
              currentIndex: selectedIndex,
              onTap: (index) => _onTabSelected(context, index),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.mosque),
                  label: 'Rituals',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Preparation',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.location_on),
                  label: 'Location',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.smart_toy),
                  label: 'Help & AI',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
