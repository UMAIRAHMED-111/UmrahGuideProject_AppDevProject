import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {
  final String message;

  const AuthLoading({this.message = 'Loading...'});

  @override
  List<Object?> get props => [message];
}

class AuthSuccess extends AuthState {
  final User user;

  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthToggleMode extends AuthState {
  final bool isSignUp;

  const AuthToggleMode(this.isSignUp);

  @override
  List<Object?> get props => [isSignUp];
} 