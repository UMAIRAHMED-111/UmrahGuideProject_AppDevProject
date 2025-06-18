import 'package:equatable/equatable.dart';

abstract class AudioPlayerState extends Equatable {
  const AudioPlayerState();

  @override
  List<Object?> get props => [];
}

class AudioPlayerInitial extends AudioPlayerState {}

class AudioPlayerLoading extends AudioPlayerState {}

class AudioPlayerPlaying extends AudioPlayerState {
  final String currentId;
  final Duration position;
  final Duration duration;
  final Map<String, Duration> positions;

  const AudioPlayerPlaying({
    required this.currentId,
    required this.position,
    required this.duration,
    required this.positions,
  });

  @override
  List<Object?> get props => [currentId, position, duration, positions];
}

class AudioPlayerPaused extends AudioPlayerState {
  final String currentId;
  final Duration position;
  final Duration duration;
  final Map<String, Duration> positions;

  const AudioPlayerPaused({
    required this.currentId,
    required this.position,
    required this.duration,
    required this.positions,
  });

  @override
  List<Object?> get props => [currentId, position, duration, positions];
}

class AudioPlayerError extends AudioPlayerState {
  final String message;

  const AudioPlayerError(this.message);

  @override
  List<Object?> get props => [message];
} 