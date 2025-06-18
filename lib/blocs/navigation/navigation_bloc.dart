import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import 'navigation_event.dart';
import 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  final AuthService _authService;
  StreamSubscription<User?>? _authSubscription;

  NavigationBloc({required AuthService authService})
      : _authService = authService,
        super(NavigationInitial()) {
    on<CheckAuthStatus>(_handleCheckAuthStatus);
    on<AuthStateChanged>(_handleAuthStateChanged);
    on<NavigateToTab>(_handleNavigateToTab);
    on<SignOutRequested>(_handleSignOut);

    // Listen to auth state changes
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      add(AuthStateChanged(user));
    });
  }

  Future<void> _handleCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<NavigationState> emit,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      emit(NavigationAuthenticated(user: user));
    } else {
      emit(NavigationUnauthenticated());
    }
  }

  void _handleAuthStateChanged(
    AuthStateChanged event,
    Emitter<NavigationState> emit,
  ) {
    if (event.user != null) {
      if (state is NavigationAuthenticated) {
        emit((state as NavigationAuthenticated).copyWith(user: event.user));
      } else {
        emit(NavigationAuthenticated(user: event.user!));
      }
    } else {
      emit(NavigationUnauthenticated());
    }
  }

  void _handleNavigateToTab(
    NavigateToTab event,
    Emitter<NavigationState> emit,
  ) {
    if (state is NavigationAuthenticated) {
      emit((state as NavigationAuthenticated).copyWith(
        selectedIndex: event.index,
      ));
    }
  }

  Future<void> _handleSignOut(
    SignOutRequested event,
    Emitter<NavigationState> emit,
  ) async {
    try {
      emit(const NavigationLoading(message: 'Signing out...'));
      await _authService.signOut();
      emit(NavigationUnauthenticated());
    } catch (e) {
      emit(NavigationError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}