import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';

import '../../models/ritual.dart';
import '../../models/dua.dart';
import '../../blocs/ritual/ritual_bloc.dart';
import '../../blocs/dua/dua_bloc.dart';
import '../../blocs/audio_player/audio_player_bloc.dart';
import '../../blocs/audio_player/audio_player_state.dart';
import '../../blocs/audio_player/audio_player_event.dart';
import '../../blocs/rituals_prayers/rituals_prayers_bloc.dart';
import '../../blocs/rituals_prayers/rituals_prayers_state.dart';
import '../../blocs/rituals_prayers/rituals_prayers_event.dart';

// Audio Player States
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

// Audio Player Events
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

// Audio Player Bloc
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

void main() {
  runApp(const MaterialApp(
    home: RitualsPrayersScreen(),
  ));
}

class RitualsPrayersScreen extends StatelessWidget {
  const RitualsPrayersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => RitualBloc(
            firestore: FirebaseFirestore.instance,
            hiveBox: Hive.box('ritualsBox'),
            auth: FirebaseAuth.instance,
          )..add(LoadRituals()),
        ),
        BlocProvider(
          create: (_) => DuaBloc(
            firestore: FirebaseFirestore.instance,
            hiveBox: Hive.box('duasBox'),
          )..add(LoadDuas()),
        ),
        BlocProvider(
          create: (_) => AudioPlayerBloc(),
        ),
        BlocProvider(
          create: (_) => RitualsPrayersBloc()..add(LoadRitualsPrayersEvent()),
        ),
      ],
      child: const _RitualsPrayersView(),
    );
  }
}

class _RitualsPrayersView extends StatefulWidget {
  const _RitualsPrayersView({Key? key}) : super(key: key);

  @override
  State<_RitualsPrayersView> createState() => _RitualsPrayersViewState();
}

class _RitualsPrayersViewState extends State<_RitualsPrayersView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = [
    'Travel',
    'Tawaf',
    'Sa\'i',
    'General',
    'Safety',
    'Other'
  ];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  Future<void> _checkConnectivityAndShowSnackbar(BuildContext context) async {
    final state = context.read<RitualsPrayersBloc>().state;
    if (state is RitualsPrayersLoaded && state.connectivityChecked) return;
    
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection. Some features may not work.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
    context.read<RitualsPrayersBloc>().add(const UpdateConnectivityCheckedEvent(true));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Widget _buildAudioPlayer(String id, String url) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        bool isCurrentAudio = false;
        bool isPlaying = false;
        bool isAudioLoading = false;
        Duration currentPosition = Duration.zero;
        Duration currentDuration = Duration.zero;
        Map<String, Duration> positions = {};

        if (state is AudioPlayerPlaying) {
          isCurrentAudio = state.currentId == id;
          positions = state.positions;
          if (isCurrentAudio) {
            currentPosition = state.position;
            currentDuration = state.duration;
            isPlaying = true;
          } else {
            currentPosition = positions[id] ?? Duration.zero;
            currentDuration = state.duration;
          }
        } else if (state is AudioPlayerPaused) {
          isCurrentAudio = state.currentId == id;
          positions = state.positions;
          if (isCurrentAudio) {
            currentPosition = state.position;
            currentDuration = state.duration;
            isPlaying = false;
          } else {
            currentPosition = positions[id] ?? Duration.zero;
            currentDuration = state.duration;
          }
        }

        // Calculate normalized value between 0 and 1
        final maxDuration = currentDuration.inSeconds.toDouble();
        final currentValue = currentPosition.inSeconds.toDouble();
        final normalizedValue = maxDuration > 0 ? currentValue / maxDuration : 0.0;

        return Column(
          children: [
            Slider(
              value: normalizedValue,
              min: 0.0,
              max: 1.0,
              onChanged: isCurrentAudio
                  ? (value) {
                      final newPosition = Duration(seconds: (value * maxDuration).toInt());
                      context.read<AudioPlayerBloc>().add(SeekAudioEvent(
                        id: id,
                        position: newPosition,
                      ));
                    }
                  : null,
              activeColor: const Color(0xFF32D27F),
              inactiveColor: Colors.white.withOpacity(0.3),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(currentPosition),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    _formatDuration(currentDuration),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: const Color(0xFF32D27F),
                  ),
                  onPressed: () {
                    if (isPlaying) {
                      context.read<AudioPlayerBloc>().add(PauseAudioEvent(id));
                    } else {
                      context.read<AudioPlayerBloc>().add(PlayAudioEvent(id: id, url: url));
                    }
                  },
                ),
                if (isAudioLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF32D27F)),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check connectivity and show snackbar only once per screen open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkConnectivityAndShowSnackbar(context);
    });

    return BlocBuilder<RitualsPrayersBloc, RitualsPrayersState>(
      builder: (context, state) {
        if (state is RitualsPrayersLoading) {
          return _buildShimmerLoading();
        }

        final showTranslation = state is RitualsPrayersLoaded 
            ? state.showTranslation 
            : <String, bool>{};

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F3D2E), Color(0xFF1A6244)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Step-by-Step Umrah Ritual Guide',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Cairo',
                            shadows: [Shadow(blurRadius: 8, color: Colors.black26)],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        // Rituals Section
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BlocBuilder<RitualBloc, RitualState>(
                                builder: (context, state) {
                                  if (state is RitualLoading) {
                                    return const Center(
                                        child: CircularProgressIndicator(
                                            color: Color(0xFF32D27F)));
                                  } else if (state is RitualLoaded) {
                                    final completed = state.rituals
                                        .where((r) => r.isComplete)
                                        .length;
                                    final total = state.rituals.length;
                                    return Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: LinearProgressIndicator(
                                            value: total == 0 ? 0 : completed / total,
                                            backgroundColor:
                                                Colors.white.withOpacity(0.15),
                                            color: const Color(0xFF32D27F),
                                            minHeight: 10,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        ...state.rituals.map((ritual) {
                                          // Find duas that match this ritual's title
                                          final matchingDuas = context.read<DuaBloc>().state is DuaLoaded
                                              ? (context.read<DuaBloc>().state as DuaLoaded)
                                                  .duas
                                                  .where((d) => d.category == ritual.title)
                                                  .toList()
                                              : [];
                                          
                                          return Container(
                                            margin: const EdgeInsets.only(bottom: 16),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              color: Colors.white.withOpacity(0.1),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(0.2),
                                              ),
                                            ),
                                            child: Theme(
                                              data: Theme.of(context).copyWith(
                                                dividerColor: Colors.transparent,
                                              ),
                                              child: ExpansionTile(
                                                tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                                                leading: Checkbox(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  value: ritual.isComplete,
                                                  onChanged: (_) {
                                                    context.read<RitualBloc>().add(
                                                        ToggleComplete(ritual.id));
                                                  },
                                                  activeColor: const Color(0xFF32D27F),
                                                  side: const BorderSide(
                                                    color: Color(0xFF32D27F),
                                                    width: 2,
                                                  ),
                                                ),
                                                title: Text(
                                                  ritual.title,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontFamily: 'Cairo',
                                                  ),
                                                ),
                                                collapsedIconColor: const Color(0xFF32D27F),
                                                iconColor: const Color(0xFF32D27F),
                                                subtitle: null,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                                    child: Text(
                                                      ritual.description,
                                                      style: TextStyle(
                                                        color: Colors.white.withOpacity(0.85),
                                                        fontFamily: 'Cairo',
                                                      ),
                                                    ),
                                                  ),
                                                  if (ritual.imageUrl.isNotEmpty)
                                                    Padding(
                                                      padding: const EdgeInsets.all(16),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(8),
                                                        child: Image.network(
                                                          ritual.imageUrl,
                                                          height: 150,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (context, error, stackTrace) => Container(
                                                            height: 150,
                                                            color: Colors.white.withOpacity(0.08),
                                                            child: const Center(
                                                              child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Icon(Icons.broken_image, color: Colors.white54, size: 48),
                                                                  SizedBox(height: 8),
                                                                  Text('Image unavailable', style: TextStyle(color: Colors.white54)),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  if (ritual.audioUrl.isNotEmpty)
                                                    Padding(
                                                      padding: const EdgeInsets.only(bottom: 16),
                                                      child: _buildAudioPlayer(ritual.id, ritual.audioUrl),
                                                    ),
                                                  if (matchingDuas.isNotEmpty) ...[
                                                    const Padding(
                                                      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                                                      child: Text(
                                                        'Related Duas',
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.white,
                                                          fontFamily: 'Cairo',
                                                        ),
                                                      ),
                                                    ),
                                                    ...matchingDuas.map((dua) {
                                                      showTranslation.putIfAbsent(dua.id, () => false);
                                                      return Container(
                                                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(8),
                                                          color: Colors.white.withOpacity(0.05),
                                                          border: Border.all(
                                                            color: Colors.white.withOpacity(0.1),
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(16.0),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                dua.title,
                                                                style: const TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.white,
                                                                  fontFamily: 'Cairo',
                                                                ),
                                                              ),
                                                              const SizedBox(height: 8),
                                                              Text(
                                                                dua.arabic,
                                                                style: const TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.white,
                                                                  fontFamily: 'Cairo',
                                                                ),
                                                              ),
                                                              const SizedBox(height: 8),
                                                              Text(
                                                                dua.transliteration,
                                                                style: TextStyle(
                                                                  fontSize: 14,
                                                                  fontStyle: FontStyle.italic,
                                                                  color: Colors.white.withOpacity(0.7),
                                                                  fontFamily: 'Cairo',
                                                                ),
                                                              ),
                                                              TextButton(
                                                                onPressed: () {
                                                                  context.read<RitualsPrayersBloc>().add(
                                                                    ToggleTranslationEvent(dua.id),
                                                                  );
                                                                },
                                                                child: Text(
                                                                  showTranslation[dua.id]! ? 'Hide Translation' : 'Show Translation',
                                                                  style: const TextStyle(color: Color(0xFF32D27F)),
                                                                ),
                                                              ),
                                                              if (showTranslation[dua.id]!)
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 8.0),
                                                                  child: Text(
                                                                    dua.translation,
                                                                    style: const TextStyle(
                                                                      color: Colors.white,
                                                                      fontFamily: 'Cairo',
                                                                    ),
                                                                  ),
                                                                ),
                                                              if (dua.audioUrl.isNotEmpty)
                                                                Padding(
                                                                  padding: const EdgeInsets.only(bottom: 16),
                                                                  child: _buildAudioPlayer(dua.id, dua.audioUrl),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                      ],
                                    );
                                  } else if (state is RitualError) {
                                    return Text('Error: ${state.message}',
                                        style: const TextStyle(color: Colors.red));
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerLoading() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 300,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              // Rituals Section Shimmer
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(3, (index) => Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white.withOpacity(0.1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 200,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: 150,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )),
                  ],
                ),
              ),
              // Dua Section Shimmer
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withOpacity(0.1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Container(
                          width: 200,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        height: 48,
                        color: Colors.white.withOpacity(0.1),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          itemBuilder: (context, index) => Container(
                            width: 100,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 400,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: 3,
                          itemBuilder: (context, index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white.withOpacity(0.05),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 200,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: 250,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
