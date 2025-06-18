import 'package:equatable/equatable.dart';

abstract class AudioPlayerEvent extends Equatable {
  const AudioPlayerEvent();

  @override
  List<Object?> get props => [];
}

class PlayAudioEvent extends AudioPlayerEvent {
  final String id;
  final String url;

  const PlayAudioEvent({required this.id, required this.url});

  @override
  List<Object?> get props => [id, url];
}

class PauseAudioEvent extends AudioPlayerEvent {
  final String id;

  const PauseAudioEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class SeekAudioEvent extends AudioPlayerEvent {
  final String id;
  final Duration position;

  const SeekAudioEvent({required this.id, required this.position});

  @override
  List<Object?> get props => [id, position];
}

class UpdateAudioPositionEvent extends AudioPlayerEvent {
  final String id;
  final Duration position;
  final Duration duration;

  const UpdateAudioPositionEvent({
    required this.id,
    required this.position,
    required this.duration,
  });

  @override
  List<Object?> get props => [id, position, duration];
} 