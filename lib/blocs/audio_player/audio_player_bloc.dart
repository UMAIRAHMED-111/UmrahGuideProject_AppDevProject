import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import 'audio_player_event.dart';
import 'audio_player_state.dart';

class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final AudioPlayer _audioPlayer;
  Map<String, Duration> _audioPositions = {};
  String? _currentlyPlayingId;

  AudioPlayerBloc() : _audioPlayer = AudioPlayer(), super(AudioPlayerInitial()) {
    on<PlayAudioEvent>(_onPlayAudio);
    on<PauseAudioEvent>(_onPauseAudio);
    on<SeekAudioEvent>(_onSeekAudio);
    on<UpdateAudioPositionEvent>(_onUpdateAudioPosition);

    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering) {
        add(const UpdateAudioPositionEvent(
          id: '',
          position: Duration.zero,
          duration: Duration.zero,
        ));
      }
    });

    _audioPlayer.durationStream.listen((duration) {
      if (_currentlyPlayingId != null) {
        add(UpdateAudioPositionEvent(
          id: _currentlyPlayingId!,
          position: _audioPlayer.position,
          duration: duration ?? Duration.zero,
        ));
      }
    });

    _audioPlayer.positionStream.listen((position) {
      if (_currentlyPlayingId != null) {
        add(UpdateAudioPositionEvent(
          id: _currentlyPlayingId!,
          position: position,
          duration: _audioPlayer.duration ?? Duration.zero,
        ));
      }
    });
  }

  Future<void> _onPlayAudio(PlayAudioEvent event, Emitter<AudioPlayerState> emit) async {
    try {
      emit(AudioPlayerLoading());

      // Save position of currently playing audio before switching
      if (_currentlyPlayingId != null && _currentlyPlayingId != event.id) {
        _audioPositions[_currentlyPlayingId!] = _audioPlayer.position;
      }

      // Stop any currently playing audio
      await _audioPlayer.stop();
      
      _currentlyPlayingId = event.id;

      // Set new source and play
      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(event.url)));
      
      // Seek to the last known position for this audio
      final lastPosition = _audioPositions[event.id] ?? Duration.zero;
      if (lastPosition > Duration.zero) {
        await _audioPlayer.seek(lastPosition);
      }
      
      await _audioPlayer.play();

      emit(AudioPlayerPlaying(
        currentId: event.id,
        position: _audioPlayer.position,
        duration: _audioPlayer.duration ?? Duration.zero,
        positions: Map.from(_audioPositions),
      ));
    } catch (e) {
      emit(AudioPlayerError(e.toString()));
    }
  }

  Future<void> _onPauseAudio(PauseAudioEvent event, Emitter<AudioPlayerState> emit) async {
    if (_currentlyPlayingId == event.id) {
      if (_audioPlayer.playing) {
        _audioPositions[event.id] = _audioPlayer.position;
        await _audioPlayer.pause();
        emit(AudioPlayerPaused(
          currentId: event.id,
          position: _audioPlayer.position,
          duration: _audioPlayer.duration ?? Duration.zero,
          positions: Map.from(_audioPositions),
        ));
      } else {
        final lastPosition = _audioPositions[event.id] ?? Duration.zero;
        if (lastPosition > Duration.zero) {
          await _audioPlayer.seek(lastPosition);
        }
        await _audioPlayer.play();
        emit(AudioPlayerPlaying(
          currentId: event.id,
          position: _audioPlayer.position,
          duration: _audioPlayer.duration ?? Duration.zero,
          positions: Map.from(_audioPositions),
        ));
      }
    }
  }

  Future<void> _onSeekAudio(SeekAudioEvent event, Emitter<AudioPlayerState> emit) async {
    if (_currentlyPlayingId == event.id) {
      await _audioPlayer.seek(event.position);
      _audioPositions[event.id] = event.position;
      
      if (_audioPlayer.playing) {
        emit(AudioPlayerPlaying(
          currentId: event.id,
          position: event.position,
          duration: _audioPlayer.duration ?? Duration.zero,
          positions: Map.from(_audioPositions),
        ));
      } else {
        emit(AudioPlayerPaused(
          currentId: event.id,
          position: event.position,
          duration: _audioPlayer.duration ?? Duration.zero,
          positions: Map.from(_audioPositions),
        ));
      }
    }
  }

  void _onUpdateAudioPosition(UpdateAudioPositionEvent event, Emitter<AudioPlayerState> emit) {
    if (event.id.isEmpty) {
      emit(AudioPlayerLoading());
    } else if (_currentlyPlayingId == event.id) {
      if (_audioPlayer.playing) {
        emit(AudioPlayerPlaying(
          currentId: event.id,
          position: event.position,
          duration: event.duration,
          positions: Map.from(_audioPositions),
        ));
      } else {
        emit(AudioPlayerPaused(
          currentId: event.id,
          position: event.position,
          duration: event.duration,
          positions: Map.from(_audioPositions),
        ));
      }
    }
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }
} 