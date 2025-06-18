import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends NavigationEvent {}

class AuthStateChanged extends NavigationEvent {
  final User? user;

  const AuthStateChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class NavigateToTab extends NavigationEvent {
  final int index;

  const NavigateToTab(this.index);

  @override
  List<Object?> get props => [index];
}

class SignOutRequested extends NavigationEvent {}