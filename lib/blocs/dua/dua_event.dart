part of 'dua_bloc.dart';

abstract class DuaEvent {}

class LoadDuas extends DuaEvent {}

class FilterByCategory extends DuaEvent {
  final String category;
  FilterByCategory(this.category);
} 