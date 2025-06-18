part of 'dua_bloc.dart';

abstract class DuaState {}

class DuaInitial extends DuaState {}

class DuaLoading extends DuaState {}

class DuaLoaded extends DuaState {
  final List<Dua> duas;
  DuaLoaded(this.duas);
}

class DuaError extends DuaState {
  final String message;
  DuaError(this.message);
} 