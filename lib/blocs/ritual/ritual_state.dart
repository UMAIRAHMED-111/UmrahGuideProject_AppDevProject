part of 'ritual_bloc.dart';

abstract class RitualState {}

class RitualInitial extends RitualState {}

class RitualLoading extends RitualState {}

class RitualLoaded extends RitualState {
  final List<Ritual> rituals;
  RitualLoaded(this.rituals);
}

class RitualError extends RitualState {
  final String message;
  RitualError(this.message);
} 