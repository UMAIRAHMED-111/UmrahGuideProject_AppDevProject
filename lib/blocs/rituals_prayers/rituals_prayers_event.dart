import 'package:equatable/equatable.dart';

abstract class RitualsPrayersEvent extends Equatable {
  const RitualsPrayersEvent();

  @override
  List<Object?> get props => [];
}

class LoadRitualsPrayersEvent extends RitualsPrayersEvent {}

class UpdateLoadingEvent extends RitualsPrayersEvent {
  final bool isLoading;

  const UpdateLoadingEvent(this.isLoading);

  @override
  List<Object?> get props => [isLoading];
}

class UpdateConnectivityCheckedEvent extends RitualsPrayersEvent {
  final bool checked;

  const UpdateConnectivityCheckedEvent(this.checked);

  @override
  List<Object?> get props => [checked];
}

class ToggleTranslationEvent extends RitualsPrayersEvent {
  final String duaId;

  const ToggleTranslationEvent(this.duaId);

  @override
  List<Object?> get props => [duaId];
} 