import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class EmailAuthRequested extends AuthEvent {
  final String email;
  final String password;
  final bool isSignUp;

  const EmailAuthRequested({
    required this.email,
    required this.password,
    required this.isSignUp,
  });

  @override
  List<Object?> get props => [email, password, isSignUp];
}

class GoogleSignInRequested extends AuthEvent {}

class ToggleAuthMode extends AuthEvent {
  final bool isSignUp;

  const ToggleAuthMode(this.isSignUp);

  @override
  List<Object?> get props => [isSignUp];
} 