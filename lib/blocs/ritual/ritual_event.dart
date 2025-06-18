part of 'ritual_bloc.dart';

abstract class RitualEvent {}

class LoadRituals extends RitualEvent {}

class FilterByCategory extends RitualEvent {
  final String category;
  FilterByCategory(this.category);
}

class ToggleComplete extends RitualEvent {
  final String id;
  final bool completed;
  ToggleComplete(this.id, {this.completed = true});
} 