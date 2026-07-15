import 'package:just_audio/just_audio.dart';
import '../models/song.dart';

class AudioPlayerService {
  // Singleton Pattern
  static final AudioPlayerService instance = AudioPlayerService._internal();
  AudioPlayerService._internal();

  final AudioPlayer _player = AudioPlayer();

  // Expose the underlying player if needed
  AudioPlayer get player => _player;

  // Streams for UI components to listen to
  Stream<bool> get playingStream => _player.playingStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<double> get volumeStream => _player.volumeStream;
  Stream<LoopMode> get loopModeStream => _player.loopModeStream;
  Stream<bool> get shuffleModeEnabledStream => _player.shuffleModeEnabledStream;
  
  // Sequence state to keep track of current song and index in playlist
  Stream<SequenceState?> get sequenceStateStream => _player.sequenceStateStream;

  // The active playlist of Song models
  List<Song> _currentPlaylist = [];
  List<Song> get currentPlaylist => _currentPlaylist;

  // Set default audio URLs for demo tracks so they still play sound
  static const String _fallbackAudioUrl = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';

  /// Initialize the player service
  Future<void> init() async {
    // Set initial volume
    await _player.setVolume(0.72);
  }

  /// Load a playlist and start playing a specific index
  Future<void> loadPlaylist(List<Song> songs, int initialIndex) async {
    _currentPlaylist = songs;
    
    final audioSources = songs.map((song) {
      if (song.isLocal && song.uri != null) {
        final uriStr = song.uri!;
        if (uriStr.startsWith('content://') || uriStr.startsWith('http://') || uriStr.startsWith('https://')) {
          return AudioSource.uri(
            Uri.parse(uriStr),
            tag: song, // Keep song model as tag
          );
        } else {
          return AudioSource.file(
            uriStr,
            tag: song,
          );
        }
      } else {
        // Fallback for mock songs to stream a royalty-free music track
        return AudioSource.uri(
          Uri.parse(_fallbackAudioUrl),
          tag: song,
        );
      }
    }).toList();

    final playlist = ConcatenatingAudioSource(
      useLazyPreparation: true,
      children: audioSources,
    );

    try {
      await _player.setAudioSource(
        playlist,
        initialIndex: initialIndex >= 0 && initialIndex < songs.length ? initialIndex : 0,
        initialPosition: Duration.zero,
      );
    } catch (e) {
      print("Error loading audio source playlist: $e");
    }
  }

  /// Play the current track
  Future<void> play() async {
    await _player.play();
  }

  /// Pause playback
  Future<void> pause() async {
    await _player.pause();
  }

  /// Stop playback
  Future<void> stop() async {
    await _player.stop();
  }

  /// Seek to a specific duration in the current track
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// Set the player volume
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  /// Seek to a specific song index
  Future<void> playAtIndex(int index) async {
    if (index >= 0 && index < _currentPlaylist.length) {
      await _player.seek(Duration.zero, index: index);
      if (!_player.playing) {
        await play();
      }
    }
  }

  /// Skip to next song
  Future<void> next() async {
    if (_player.hasNext) {
      await _player.seekToNext();
    } else if (_currentPlaylist.isNotEmpty) {
      // Manual skip wraps around to the beginning
      await _player.seek(Duration.zero, index: 0);
    }
  }

  /// Skip to previous song
  Future<void> previous() async {
    if (_player.position.inSeconds > 3) {
      // Re-play current song if it's been playing for more than 3 seconds
      await _player.seek(Duration.zero);
    } else if (_player.hasPrevious) {
      await _player.seekToPrevious();
    } else if (_currentPlaylist.isNotEmpty) {
      // Manual skip wraps around to the end
      await _player.seek(Duration.zero, index: _currentPlaylist.length - 1);
    }
  }

  /// Toggle shuffle mode
  Future<void> toggleShuffle(bool enabled) async {
    await _player.setShuffleModeEnabled(enabled);
  }

  /// Toggle loop mode
  Future<void> setLoopMode(bool enabled) async {
    await _player.setLoopMode(enabled ? LoopMode.one : LoopMode.off);
  }

  /// Clean up resources
  void dispose() {
    _player.dispose();
  }
}
