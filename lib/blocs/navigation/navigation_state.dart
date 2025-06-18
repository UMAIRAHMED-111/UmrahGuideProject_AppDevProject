import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class NavigationState extends Equatable {
  const NavigationState();

  @override
  List<Object?> get props => [];
}

class NavigationInitial extends NavigationState {}

class NavigationLoading extends NavigationState {
  final String message;

  const NavigationLoading({this.message = 'Loading...'});

  @override
  List<Object?> get props => [message];
}

class NavigationAuthenticated extends NavigationState {
  final User user;
  final int selectedIndex;

  const NavigationAuthenticated({
    required this.user,
    this.selectedIndex = 0,
  });

  NavigationAuthenticated copyWith({
    User? user,
    int? selectedIndex,
  }) {
    return NavigationAuthenticated(
      user: user ?? this.user,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }

  @override
  List<Object?> get props => [user, selectedIndex];
}

class NavigationUnauthenticated extends NavigationState {}

class NavigationError extends NavigationState {
  final String message;

  const NavigationError(this.message);

  @override
  List<Object?> get props => [message];
}