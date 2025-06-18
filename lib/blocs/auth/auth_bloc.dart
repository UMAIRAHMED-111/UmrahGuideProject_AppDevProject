import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(AuthInitial()) {
    on<EmailAuthRequested>(_handleEmailAuth);
    on<GoogleSignInRequested>(_handleGoogleSignIn);
    on<ToggleAuthMode>(_handleToggleMode);
  }

  Future<void> _handleEmailAuth(
    EmailAuthRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (event.email.isEmpty || event.password.isEmpty) {
      emit(const AuthError('Please fill in all fields'));
      return;
    }

    emit(AuthLoading(message: event.isSignUp ? 'Signing up...' : 'Logging in...'));

    try {
      UserCredential? result;
      
      if (event.isSignUp) {
        result = await _authService.signUpWithEmailAndPassword(
          event.email.trim(),
          event.password,
        );
      } else {
        result = await _authService.signInWithEmailAndPassword(
          event.email.trim(),
          event.password,
        );
      }

      if (result?.user != null) {
        emit(AuthSuccess(result!.user!));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _handleGoogleSignIn(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading(message: 'Signing in with Google...'));
      await _authService.signInWithGoogle();
      
      // Wait for auth state change
      await FirebaseAuth.instance.authStateChanges().firstWhere((user) => user != null);
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        emit(AuthSuccess(user));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _handleToggleMode(
    ToggleAuthMode event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthToggleMode(event.isSignUp));
  }
} 