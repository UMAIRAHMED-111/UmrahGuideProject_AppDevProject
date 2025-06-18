import 'package:equatable/equatable.dart';

abstract class RitualsPrayersState extends Equatable {
  const RitualsPrayersState();

  @override
  List<Object?> get props => [];
}

class RitualsPrayersInitial extends RitualsPrayersState {}

class RitualsPrayersLoading extends RitualsPrayersState {}

class RitualsPrayersLoaded extends RitualsPrayersState {
  final bool isLoading;
  final bool connectivityChecked;
  final Map<String, bool> showTranslation;

  const RitualsPrayersLoaded({
    required this.isLoading,
    required this.connectivityChecked,
    required this.showTranslation,
  });

  RitualsPrayersLoaded copyWith({
    bool? isLoading,
    bool? connectivityChecked,
    Map<String, bool>? showTranslation,
  }) {
    return RitualsPrayersLoaded(
      isLoading: isLoading ?? this.isLoading,
      connectivityChecked: connectivityChecked ?? this.connectivityChecked,
      showTranslation: showTranslation ?? this.showTranslation,
    );
  }

  @override
  List<Object?> get props => [isLoading, connectivityChecked, showTranslation];
} 