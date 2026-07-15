
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'dart:async';
import 'services/audio_player_service.dart';
import 'services/local_music_scanner_service.dart';
import 'package:on_audio_query/on_audio_query.dart' show QueryArtworkWidget, ArtworkType;
import 'package:just_audio/just_audio.dart' show LoopMode;

import 'models/song.dart';
import 'models/playlist.dart';
import 'widgets/common_widgets.dart';
import 'widgets/song_card.dart';
import 'widgets/playlist_card.dart';
import 'widgets/now_playing_card.dart';
import 'widgets/lyrics_view.dart';

void main() {
  runApp(const MusicPlaylistApp());
}

class MusicPlaylistApp extends StatefulWidget {
  const MusicPlaylistApp({super.key});

  @override
  State<MusicPlaylistApp> createState() => _MusicPlaylistAppState();
}

class _MusicPlaylistAppState extends State<MusicPlaylistApp> {
  Color _seedColor = Colors.deepPurple;

  void updateTheme(Color newColor) {
    setState(() {
      _seedColor = newColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Playlist App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: _seedColor.withOpacity(0.05),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          color: Colors.white.withOpacity(0.8),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      themeMode: ThemeMode.system,
      home: AppShell(onThemeChanged: updateTheme),
    );
  }
}

class AppShell extends StatefulWidget {
  final Function(Color) onThemeChanged;
  const AppShell({super.key, required this.onThemeChanged});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _mediaChannel = MethodChannel('com.example.music_playlist_app/media_actions');
  int _index = 0;
  int _currentSongIndex = 0;
  bool _playing = false;
  bool _shuffle = false;
  bool _loop = false;
  bool _favoritesOnly = false;
  double _volume = 0.72;
  String _sortOption = 'Title';
  Timer? _sleepTimer;
  int _sleepMinutesRemaining = 0;
  String _selectedMood = 'All';

  final TextEditingController _songSearch = TextEditingController();
  final TextEditingController _playlistSearch = TextEditingController();
  final TextEditingController _newPlaylistName = TextEditingController();
  final TextEditingController _newPlaylistDescription = TextEditingController();

  late List<Playlist> _playlists;
  final Set<String> _favoriteSongIds = {};
  final Set<String> _downloadedSongIds = {};
  final List<String> _recentHistory = [];
  String _genreFilter = 'All';

  // Audio query & playback additions
  List<Song> _songs = [];
  bool _isLoadingLocalSongs = false;
  
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _sequenceSubscription;
  StreamSubscription? _shuffleSubscription;
  StreamSubscription? _loopSubscription;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  static const List<Song> _mockSongs = [];

  @override
  void initState() {
    super.initState();
    _songs = List.from(_mockSongs);
    _playlists = [
      Playlist(
        id: 'p1',
        name: 'Chill Vibes',
        description: 'Relaxing tracks for calm evenings.',
        songIds: [],
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
        color: Colors.deepPurple,
        icon: Icons.self_improvement,
        isPublic: true,
      ),
      Playlist(
        id: 'p2',
        name: 'Workout Mix',
        description: 'High energy songs to keep you moving.',
        songIds: [],
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        color: Colors.red,
        icon: Icons.fitness_center,
      ),
      Playlist(
        id: 'p3',
        name: 'Late Night Drive',
        description: 'Perfect for long rides under city lights.',
        songIds: [],
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        color: Colors.indigo,
        icon: Icons.drive_eta,
        isPublic: true,
      ),
    ];
    _initAudioAndScan();
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _sequenceSubscription?.cancel();
    _shuffleSubscription?.cancel();
    _loopSubscription?.cancel();
    _songSearch.dispose();
    _playlistSearch.dispose();
    _newPlaylistName.dispose();
    _newPlaylistDescription.dispose();
    super.dispose();
  }

  Future<void> _initAudioAndScan() async {
    await AudioPlayerService.instance.init();
    _setupPlayerListeners();

    setState(() => _isLoadingLocalSongs = true);
    final localSongs = await LocalMusicScannerService.instance.scanLocalMusic();
    setState(() {
      if (localSongs.isNotEmpty) {
        _songs = [...localSongs, ..._mockSongs];
      } else {
        _songs = List.from(_mockSongs);
      }
      _isLoadingLocalSongs = false;
    });

    if (_songs.isNotEmpty) {
      await AudioPlayerService.instance.loadPlaylist(_songs, _currentSongIndex);
    }
  }

  void _setupPlayerListeners() {
    _playerStateSubscription = AudioPlayerService.instance.playerStateStream.listen((state) {
      setState(() {
        _playing = state.playing;
      });
    });

    _positionSubscription = AudioPlayerService.instance.positionStream.listen((pos) {
      setState(() {
        _position = pos;
      });
    });

    _durationSubscription = AudioPlayerService.instance.durationStream.listen((dur) {
      setState(() {
        _duration = dur ?? Duration.zero;
      });
    });

    _sequenceSubscription = AudioPlayerService.instance.sequenceStateStream.listen((seq) {
      if (seq != null) {
        final currentTag = seq.currentSource?.tag;
        if (currentTag is Song) {
          final idx = _songs.indexWhere((s) => s.id == currentTag.id);
          if (idx != -1 && idx != _currentSongIndex) {
            setState(() {
              _currentSongIndex = idx;
              _recentHistory.insert(0, currentTag.title);
              if (_recentHistory.length > 10) _recentHistory.removeLast();
            });
            widget.onThemeChanged(currentTag.color);
          }
        }
      }
    });

    _shuffleSubscription = AudioPlayerService.instance.shuffleModeEnabledStream.listen((shuffled) {
      setState(() => _shuffle = shuffled);
    });

    _loopSubscription = AudioPlayerService.instance.loopModeStream.listen((loopMode) {
      setState(() => _loop = loopMode == LoopMode.one);
    });
  }

  Future<void> _playSong(Song song, List<Song> queue) async {
    final indexInQueue = queue.indexWhere((s) => s.id == song.id);
    if (indexInQueue != -1) {
      await AudioPlayerService.instance.loadPlaylist(queue, indexInQueue);
      await AudioPlayerService.instance.play();
    }
  }

  Song get _currentSong {
    if (_songs.isEmpty) {
      return const Song(
        id: '',
        title: 'No Songs',
        artist: 'Unknown',
        album: 'Unknown',
        duration: Duration.zero,
        genre: 'None',
        year: 0,
        rating: 0.0,
        icon: Icons.music_note,
        color: Colors.grey,
        mood: 'None',
        lyrics: [],
      );
    }
    return _songs[_currentSongIndex % _songs.length];
  }

  List<Song> get _filteredSongs {
    final query = _songSearch.text.trim().toLowerCase();
    final filtered = _songs.where((song) {
      final matchesQuery = query.isEmpty ||
          song.title.toLowerCase().contains(query) ||
          song.artist.toLowerCase().contains(query) ||
          song.album.toLowerCase().contains(query) ||
          song.genre.toLowerCase().contains(query);
      final matchesGenre = _genreFilter == 'All' || song.genre == _genreFilter;
      final matchesFavorite = !_favoritesOnly || _favoriteSongIds.contains(song.id);
      final matchesMood = _selectedMood == 'All' || song.mood == _selectedMood;
      return matchesQuery && matchesGenre && matchesFavorite && matchesMood;
    }).toList();

    if (_sortOption == 'Title') filtered.sort((a, b) => a.title.compareTo(b.title));
    if (_sortOption == 'Artist') filtered.sort((a, b) => a.artist.compareTo(b.artist));
    if (_sortOption == 'Year') filtered.sort((a, b) => b.year.compareTo(a.year));
    if (_sortOption == 'Duration') filtered.sort((a, b) => a.duration.compareTo(b.duration));

    return filtered;
  }

  List<String> get _genres {
    final genres = _songs.map((e) => e.genre).toSet().toList()..sort();
    return ['All', ...genres];
  }

  Duration get _libraryDuration =>
      _songs.fold(Duration.zero, (previous, song) => previous + song.duration);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Playlist App'),
        actions: [
          IconButton(
            onPressed: () => _showCreatePlaylistDialog(context),
            icon: const Icon(Icons.playlist_add),
          ),
          IconButton(
            onPressed: () => _openSearchSheet(context),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: [
          _buildHomeTab(context),
          _buildSongsTab(context),
          _buildPlaylistsTab(context),
          _buildPlayerTab(context),
          _buildSettingsTab(context),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_index != 3) _buildMiniPlayer(context),
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.music_note_outlined), selectedIcon: Icon(Icons.music_note), label: 'Songs'),
              NavigationDestination(icon: Icon(Icons.playlist_play_outlined), selectedIcon: Icon(Icons.playlist_play), label: 'Playlists'),
              NavigationDestination(icon: Icon(Icons.graphic_eq_outlined), selectedIcon: Icon(Icons.graphic_eq), label: 'Player'),
              NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _heroBanner(context),
        const SizedBox(height: 24),
        SectionHeader(
          title: 'Moods',
          subtitle: 'Songs for your current vibe',
          actionLabel: 'Reset',
          onAction: () => setState(() => _selectedMood = 'All'),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', 'Romantic', 'Happy', 'Spiritual', 'Energetic', 'Chill', 'Dark', 'Flirty'].map((mood) {
              final isSelected = _selectedMood == mood;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(mood),
                  selected: isSelected,
                  onSelected: (v) => setState(() => _selectedMood = mood),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  selectedColor: _songs.isEmpty
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                      : _songs.firstWhere((s) => s.mood == mood, orElse: () => _songs.first).color.withValues(alpha: 0.2),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            StatCard(
              title: 'Songs',
              value: '${_songs.length}',
              icon: Icons.music_note,
            ),
            StatCard(
              title: 'Playlists',
              value: '${_playlists.length}',
              icon: Icons.playlist_play,
            ),
            StatCard(
              title: 'Favorites',
              value: '${_favoriteSongIds.length}',
              icon: Icons.favorite,
            ),
            StatCard(
              title: 'Duration',
              value: _formatDuration(_libraryDuration),
              icon: Icons.timer,
            ),
          ],
        ),
        const SizedBox(height: 32),
        SectionHeader(
          title: 'Quick Actions',
          subtitle: 'Manage your music with one tap',
          actionLabel: 'New Playlist',
          onAction: () => _showCreatePlaylistDialog(context),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ActionChipWidget(icon: Icons.shuffle, label: 'Shuffle', onTap: _shuffleToRandomSong),
              const SizedBox(width: 12),
              ActionChipWidget(
                icon: Icons.favorite,
                label: 'Favorites',
                onTap: () => setState(() {
                  _index = 1;
                  _favoritesOnly = true;
                }),
              ),
              const SizedBox(width: 12),
              ActionChipWidget(
                icon: Icons.queue_music,
                label: 'Queue',
                onTap: () => setState(() => _index = 3),
              ),
              const SizedBox(width: 12),
              ActionChipWidget(
                icon: Icons.download,
                label: 'Downloads',
                onTap: () => _showInfoSheet(context, 'Downloads', 'This mock app marks some songs as downloaded.'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SectionHeader(
          title: 'Recently Played',
          subtitle: 'Your latest listening history',
          actionLabel: 'Clear',
          onAction: () => setState(() => _recentHistory.clear()),
        ),
        const SizedBox(height: 16),
        if (_recentHistory.isEmpty)
          const EmptyState(
            icon: Icons.history,
            title: 'No recent songs',
            subtitle: 'Start playback to create history.',
          )
        else
          ..._recentHistory.take(5).map((title) => HistoryTile(title: title)),
        const SizedBox(height: 32),
        SectionHeader(
          title: 'Top Playlist Preview',
          subtitle: 'Open a playlist to view details',
          actionLabel: 'Open',
          onAction: () => setState(() => _index = 2),
        ),
        const SizedBox(height: 16),
        if (_playlists.isNotEmpty)
          PlaylistPreviewCard(
            playlist: _playlists.first,
            songCount: _playlists.first.songIds.length,
            onTap: () => _showPlaylistDetails(context, _playlists.first),
          ),
      ],
    );
  }

  Widget _heroBanner(BuildContext context) {
    final song = _currentSong;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [song.color.withOpacity(0.9), Colors.black87],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Hero(
            tag: 'hero_${song.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: song.isLocal
                    ? QueryArtworkWidget(
                        id: int.parse(song.id),
                        type: ArtworkType.AUDIO,
                        artworkWidth: 88,
                        artworkHeight: 88,
                        artworkFit: BoxFit.cover,
                        keepOldArtwork: true,
                        nullArtworkWidget: Icon(song.icon, size: 46, color: Colors.white),
                      )
                    : Icon(song.icon, size: 46, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Now Highlighting', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 6),
                Text(
                  song.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${song.artist} • ${song.genre}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _duration.inMilliseconds > 0
                      ? _position.inMilliseconds / _duration.inMilliseconds
                      : 0.0,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(99),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongsTab(BuildContext context) {
    final songs = _filteredSongs;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _songSearch,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search songs, artists, albums, genres...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _songSearch.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _songSearch.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.clear),
                    ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _genres.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final genre = _genres[index];
                return ChoiceChip(
                  label: Text(genre),
                  selected: _genreFilter == genre,
                  onSelected: (_) => setState(() => _genreFilter = genre),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              FilterChip(
                label: const Text('Favorites only'),
                selected: _favoritesOnly,
                onSelected: (value) => setState(() => _favoritesOnly = value),
              ),
              const Spacer(),
              DropdownButton<String>(
                value: _sortOption,
                onChanged: (val) => setState(() => _sortOption = val!),
                items: ['Title', 'Artist', 'Year', 'Duration'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              ),
              const SizedBox(width: 8),
              Text('${songs.length} tracks'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _isLoadingLocalSongs
              ? const Center(child: CircularProgressIndicator())
              : songs.isEmpty
                  ? const EmptyState(
                      icon: Icons.search_off,
                      title: 'No matching songs',
                      subtitle: 'Try another search or filter.',
                    )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    final isFavorite = _favoriteSongIds.contains(song.id);
                    final isDownloaded = _downloadedSongIds.contains(song.id);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SongCard(
                        song: song,
                        isFavorite: isFavorite,
                        isDownloaded: isDownloaded,
                        compact: false,
                        onTap: () {
                          _playSong(song, songs);
                          setState(() {
                            _index = 3;
                          });
                        },
                        onFavoriteToggle: () => setState(() {
                          if (isFavorite) {
                            _favoriteSongIds.remove(song.id);
                          } else {
                            _favoriteSongIds.add(song.id);
                          }
                        }),
                        onDelete: () => _deleteSongPermanently(song),
                        onMore: () => _showSongActions(context, song),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPlaylistsTab(BuildContext context) {
    final query = _playlistSearch.text.trim().toLowerCase();
    final playlists = _playlists.where((playlist) {
      return query.isEmpty ||
          playlist.name.toLowerCase().contains(query) ||
          playlist.description.toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _playlistSearch,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search playlists...',
              prefixIcon: const Icon(Icons.manage_search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.analytics)),
              title: const Text('Playlist Summary'),
              subtitle: Text('${_playlists.length} playlists • ${_playlists.fold<int>(0, (a, p) => a + p.songIds.length)} total songs'),
              trailing: TextButton(
                onPressed: () => _showInfoSheet(context, 'Playlist Overview', 'This section demonstrates cards and grid layouts.'),
                child: const Text('Details'),
              ),
            ),
          ),
        ),
        Expanded(
          child: playlists.isEmpty
              ? const EmptyState(
                  icon: Icons.playlist_remove,
                  title: 'No playlists found',
                  subtitle: 'Create a playlist or clear the search field.',
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    return PlaylistCard(
                      playlist: playlist,
                      songCount: playlist.songIds.length,
                      onTap: () => _showPlaylistDetails(context, playlist),
                      onEdit: () => _showEditPlaylistDialog(context, playlist),
                      onDelete: () => _deletePlaylist(playlist),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPlayerTab(BuildContext context) {
    final current = _currentSong;
    final playlist = _playlists.isNotEmpty ? _playlists.first : null;
    final queueSongs = playlist == null ? <Song>[] : _songsFromIds(playlist.songIds);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        NowPlayingCard(
          song: current,
          isPlaying: _playing,
          progress: _duration.inMilliseconds > 0
              ? _position.inMilliseconds / _duration.inMilliseconds
              : 0.0,
          position: _position,
          duration: _duration,
          onSeek: (val) {
            final targetMs = (val * _duration.inMilliseconds).toInt();
            AudioPlayerService.instance.seek(Duration(milliseconds: targetMs));
          },
          onPlayPause: () {
            if (_playing) {
              AudioPlayerService.instance.pause();
            } else {
              AudioPlayerService.instance.play();
            }
          },
          onNext: _nextSong,
          onPrevious: _previousSong,
        ),
        const SizedBox(height: 16),
        SectionHeader(
          title: 'Lyrics',
          subtitle: 'Synchronized with playback',
          actionLabel: 'Settings',
          onAction: () => _showAudioSettings(context),
        ),
        const SizedBox(height: 12),
        LyricsView(
          song: current,
          progress: _duration.inMilliseconds > 0
              ? _position.inMilliseconds / _duration.inMilliseconds
              : 0.0,
        ),
        const SizedBox(height: 16),
        ControlPanel(
          isShuffled: _shuffle,
          isLooping: _loop,
          volume: _volume,
          onShuffle: () {
            final nextShuffle = !_shuffle;
            AudioPlayerService.instance.toggleShuffle(nextShuffle);
          },
          onLoop: () {
            final nextLoop = !_loop;
            AudioPlayerService.instance.setLoopMode(nextLoop);
          },
          onVolumeChanged: (value) {
            setState(() => _volume = value);
            AudioPlayerService.instance.setVolume(value);
          },
        ),
        const SizedBox(height: 16),
        SectionHeader(
          title: 'Up Next',
          subtitle: 'Queue preview from the first playlist',
          actionLabel: 'Open Playlist',
          onAction: () => setState(() => _index = 2),
        ),
        const SizedBox(height: 12),
        if (queueSongs.isEmpty)
          const EmptyState(
            icon: Icons.queue_music,
            title: 'Queue is empty',
            subtitle: 'Add songs to a playlist to populate the queue.',
          )
        else
          ...queueSongs.take(5).map(
                (song) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: QueueTile(
                    song: song,
                    isCurrent: song.id == current.id,
                    onTap: () {
                      _playSong(song, queueSongs);
                    },
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildSettingsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionHeader(
          title: 'Appearance',
          subtitle: 'Change the app mood and surface colors',
          actionLabel: 'Reset',
          onAction: () => setState(() {}),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: const [
            ThemeChip(label: 'Classic Purple'),
            ThemeChip(label: 'Ocean Blue'),
            ThemeChip(label: 'Sunset Orange'),
          ],
        ),
        const SizedBox(height: 20),
        SectionHeader(
          title: 'App Preferences',
          subtitle: 'Toggle features used in the mock interface',
          actionLabel: 'Tips',
          onAction: () => _showTipsDialog(context),
        ),
        const SizedBox(height: 12),
        SettingsTile(
          title: 'Loop playback',
          subtitle: 'Repeat the current song when it ends',
          value: _loop,
          icon: Icons.repeat,
          onChanged: (value) => setState(() => _loop = value),
        ),
        SettingsTile(
          title: 'Shuffle mode',
          subtitle: 'Randomize track order in the player',
          value: _shuffle,
          icon: Icons.shuffle,
          onChanged: (value) => setState(() => _shuffle = value),
        ),
        SettingsTile(
          title: 'Favorite filter',
          subtitle: 'Show only your favorite tracks',
          value: _favoritesOnly,
          icon: Icons.favorite,
          onChanged: (value) => setState(() => _favoritesOnly = value),
        ),
        const SizedBox(height: 20),
        SupportCard(
          title: 'Sleep Timer',
          subtitle: _sleepMinutesRemaining > 0 ? 'Stopping in $_sleepMinutesRemaining min' : 'Auto-stop playback after time',
          icon: Icons.timer,
          onTap: () => _showSleepTimerDialog(context),
        ),
        const SizedBox(height: 12),
        const SupportCard(
          title: 'Song Selection',
          subtitle: 'Choose a track, open details, favorite it, or add it to a playlist.',
          icon: Icons.touch_app,
        ),
        const SizedBox(height: 12),
        const SupportCard(
          title: 'Playlist Display',
          subtitle: 'See songs, statistics, colors, and actions in card layouts.',
          icon: Icons.dashboard_customize,
        ),
        const SizedBox(height: 12),
        const SupportCard(
          title: 'Hero Animations',
          subtitle: 'Move between screens with a smooth hero transition for the active song.',
          icon: Icons.auto_awesome,
        ),
      ],
    );
  }


  void _nextSong() {
    AudioPlayerService.instance.next();
  }

  void _previousSong() {
    AudioPlayerService.instance.previous();
  }

  Future<void> _deleteSongPermanently(Song song) async {
    // If the song is currently playing, transition to next song first
    final currentSong = _currentSong;
    if (currentSong.id == song.id) {
      if (_songs.length > 1) {
        _nextSong();
      } else {
        await AudioPlayerService.instance.stop();
      }
    }

    if (!mounted) return;

    if (!song.isLocal) {
      // Mock song deletion confirmation
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Remove Mock Song'),
          content: Text('"${song.title}" is a mock song and is not stored on your device. Would you like to remove it from the list for this session?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remove'),
            ),
          ],
        ),
      );

      if (!mounted) return;

      if (confirm == true) {
        setState(() {
          _songs.removeWhere((s) => s.id == song.id);
          _favoriteSongIds.remove(song.id);
          _downloadedSongIds.remove(song.id);
          _recentHistory.removeWhere((title) => title == song.title);
          for (final playlist in _playlists) {
            playlist.songIds.remove(song.id);
          }
        });
        
        // Update player playlist with remaining songs
        if (_songs.isNotEmpty) {
          final newIndex = _songs.indexWhere((s) => s.id == _currentSong.id);
          await AudioPlayerService.instance.loadPlaylist(_songs, newIndex != -1 ? newIndex : 0);
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${song.title}" removed from list.')),
        );
      }
      return;
    }

    // Local song deletion confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permanently Delete Song'),
        content: Text('Are you sure you want to permanently delete "${song.title}" from your device? This action is irreversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (confirm != true) return;

    try {
      // Call native channel
      final bool success = await _mediaChannel.invokeMethod('deleteSong', {
        'uri': song.uri,
        'path': song.path,
      }) ?? false;

      if (!mounted) return;

      if (success) {
        setState(() {
          _songs.removeWhere((s) => s.id == song.id);
          _favoriteSongIds.remove(song.id);
          _downloadedSongIds.remove(song.id);
          _recentHistory.removeWhere((title) => title == song.title);
          for (final playlist in _playlists) {
            playlist.songIds.remove(song.id);
          }
        });

        // Update player playlist with remaining songs
        if (_songs.isNotEmpty) {
          final newIndex = _songs.indexWhere((s) => s.id == _currentSong.id);
          await AudioPlayerService.instance.loadPlaylist(_songs, newIndex != -1 ? newIndex : 0);
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permanently deleted "${song.title}" from device.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete song or permission was denied.')),
        );
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting song: ${e.message}')),
      );
    }
  }

  void _shuffleToRandomSong() {
    if (_songs.isEmpty) return;
    final randomIndex = DateTime.now().millisecondsSinceEpoch % _songs.length;
    _playSong(_songs[randomIndex], _songs);
    setState(() {
      _shuffle = true;
      _playing = true;
      _index = 3;
    });
  }

  Widget _buildMiniPlayer(BuildContext context) {
    final song = _currentSong;
    return GestureDetector(
      onTap: () => setState(() => _index = 3),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        height: 68,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: song.color.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Hero(
                        tag: 'mini_hero_${song.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [song.color, song.color.withOpacity(0.6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: song.isLocal
                                ? QueryArtworkWidget(
                                    id: int.parse(song.id),
                                    type: ArtworkType.AUDIO,
                                    artworkWidth: 48,
                                    artworkHeight: 48,
                                    artworkFit: BoxFit.cover,
                                    keepOldArtwork: true,
                                    nullArtworkWidget: Icon(song.icon, color: Colors.white, size: 24),
                                  )
                                : Icon(song.icon, color: Colors.white, size: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              song.artist,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (_playing) {
                            AudioPlayerService.instance.pause();
                          } else {
                            AudioPlayerService.instance.play();
                          }
                        },
                        icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
                      ),
                      IconButton(
                        onPressed: _nextSong,
                        icon: const Icon(Icons.skip_next),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    value: _duration.inMilliseconds > 0
                        ? _position.inMilliseconds / _duration.inMilliseconds
                        : 0.0,
                    minHeight: 2.5,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(song.color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m ${seconds}s';
  }

  void _showInfoSheet(BuildContext context, String title, String message) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(message),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openSearchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final local = TextEditingController(text: _songSearch.text);
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = _songs.where((song) {
              final q = local.text.trim().toLowerCase();
              return q.isEmpty ||
                  song.title.toLowerCase().contains(q) ||
                  song.artist.toLowerCase().contains(q) ||
                  song.album.toLowerCase().contains(q);
            }).toList();

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.85,
              minChildSize: 0.55,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('Search Songs', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 12),
                    TextField(
                      controller: local,
                      onChanged: (_) => setSheetState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Type a title or artist',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...filtered.map(
                      (song) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SongCard(
                          song: song,
                          isFavorite: _favoriteSongIds.contains(song.id),
                          isDownloaded: _downloadedSongIds.contains(song.id),
                          compact: true,
                          onTap: () {
                            Navigator.pop(context);
                            _playSong(song, filtered);
                            setState(() {
                              _index = 3;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _showCreatePlaylistDialog(BuildContext context) async {
    _newPlaylistName.clear();
    _newPlaylistDescription.clear();
    final created = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Playlist'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _newPlaylistName,
                  decoration: const InputDecoration(labelText: 'Playlist name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _newPlaylistDescription,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (created == true && _newPlaylistName.text.trim().isNotEmpty) {
      setState(() {
        _playlists.insert(
          0,
          Playlist(
            id: 'p${DateTime.now().millisecondsSinceEpoch}',
            name: _newPlaylistName.text.trim(),
            description: _newPlaylistDescription.text.trim().isEmpty
                ? 'New playlist created by user.'
                : _newPlaylistDescription.text.trim(),
            songIds: [],
            createdAt: DateTime.now(),
            color: Colors.primaries[DateTime.now().millisecond % Colors.primaries.length],
            icon: Icons.queue_music,
          ),
        );
      });
    }
  }

  Future<void> _showEditPlaylistDialog(BuildContext context, Playlist playlist) async {
    final nameController = TextEditingController(text: playlist.name);
    final descController = TextEditingController(text: playlist.description);

    final updated = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Playlist'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Playlist name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (updated == true) {
      setState(() {
        playlist.name = nameController.text.trim().isEmpty ? playlist.name : nameController.text.trim();
        playlist.description = descController.text.trim().isEmpty ? playlist.description : descController.text.trim();
      });
    }
  }

  void _deletePlaylist(Playlist playlist) {
    setState(() {
      _playlists.removeWhere((p) => p.id == playlist.id);
    });
  }

  List<Song> _songsFromIds(List<String> ids) {
    if (_songs.isEmpty) return [];
    return ids
        .map((id) {
          final found = _songs.where((song) => song.id == id);
          return found.isNotEmpty ? found.first : null;
        })
        .whereType<Song>()
        .toList();
  }

  void _showPlaylistDetails(BuildContext context, Playlist playlist) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDetailState) {
            final playlistSongs = _songsFromIds(playlist.songIds);
            final duration = playlistSongs.fold(Duration.zero, (prev, song) => prev + song.duration);

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.9,
              minChildSize: 0.6,
              maxChildSize: 0.96,
              builder: (context, scrollController) {
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: playlist.color.withValues(alpha: 0.15),
                          child: Icon(playlist.icon, color: playlist.color, size: 30),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(playlist.name, style: Theme.of(context).textTheme.headlineSmall),
                              const SizedBox(height: 4),
                              Text(playlist.description),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        StatCard(title: 'Songs', value: '${playlistSongs.length}', icon: Icons.music_note),
                        StatCard(title: 'Duration', value: _formatDuration(duration), icon: Icons.timelapse),
                        StatCard(title: 'Public', value: playlist.isPublic ? 'Yes' : 'No', icon: Icons.public),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SectionHeader(
                      title: 'Songs in Playlist',
                      subtitle: 'Tap any song to play it instantly',
                      actionLabel: 'Add Songs',
                      onAction: () => _showAddSongsToPlaylistSheet(context, playlist, () {
                        setDetailState(() {});
                      }),
                    ),
                    const SizedBox(height: 12),
                    if (playlistSongs.isEmpty)
                      const EmptyState(
                        icon: Icons.playlist_remove,
                        title: 'No songs yet',
                        subtitle: 'Add songs from the Songs tab.',
                      )
                    else
                      ...playlistSongs.map(
                        (song) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: QueueTile(
                            song: song,
                            isCurrent: song.id == _currentSong.id,
                            onTap: () {
                              Navigator.pop(context);
                              _playSong(song, playlistSongs);
                              setState(() {
                                _index = 3;
                              });
                            },
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showAddSongsToPlaylistSheet(BuildContext context, Playlist playlist, VoidCallback onUpdate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final searchController = TextEditingController();
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final query = searchController.text.toLowerCase();
            final filtered = _songs.where((song) {
              return song.title.toLowerCase().contains(query) ||
                  song.artist.toLowerCase().contains(query);
            }).toList();

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.85,
              minChildSize: 0.55,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Add Songs to ${playlist.name}',
                            style: Theme.of(context).textTheme.headlineSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: searchController,
                      onChanged: (_) => setSheetState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Type a title or artist',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (filtered.isEmpty)
                      const EmptyState(
                        icon: Icons.music_off,
                        title: 'No matching songs',
                        subtitle: 'Try another query',
                      )
                    else
                      ...filtered.map(
                        (song) {
                          final exists = playlist.songIds.contains(song.id);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: song.color.withValues(alpha: 0.15),
                                child: Icon(song.icon, color: song.color),
                              ),
                              title: Text(song.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${song.artist} • ${song.album}'),
                              trailing: Icon(
                                exists ? Icons.check_circle : Icons.add_circle_outline,
                                color: exists ? Colors.green : null,
                              ),
                              onTap: () {
                                setState(() {
                                  if (exists) {
                                    playlist.songIds.remove(song.id);
                                  } else {
                                    playlist.songIds.add(song.id);
                                  }
                                });
                                setSheetState(() {});
                                onUpdate();
                              },
                            ),
                          );
                        },
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showAddToPlaylistSheet(BuildContext context, Song song) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add "${song.title}" to Playlist', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (_playlists.isEmpty) const Text('No playlists available.'),
              ..._playlists.map((playlist) {
                final exists = playlist.songIds.contains(song.id);
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: playlist.color.withOpacity(0.16),
                      child: Icon(playlist.icon, color: playlist.color),
                    ),
                    title: Text(playlist.name),
                    subtitle: Text(playlist.description),
                    trailing: exists ? const Icon(Icons.check_circle) : const Icon(Icons.add_circle_outline),
                    onTap: () {
                      setState(() {
                        if (!exists) playlist.songIds.add(song.id);
                      });
                      Navigator.pop(context);
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showSongActions(BuildContext context, Song song) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Song details'),
                subtitle: Text('${song.artist} • ${song.album}'),
                onTap: () {
                  Navigator.pop(context);
                  _showInfoSheet(
                    context,
                    song.title,
                    'Genre: ${song.genre}\nYear: ${song.year}\nRating: ${song.rating}',
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite_border),
                title: const Text('Toggle favorite'),
                onTap: () {
                  setState(() {
                    if (_favoriteSongIds.contains(song.id)) {
                      _favoriteSongIds.remove(song.id);
                    } else {
                      _favoriteSongIds.add(song.id);
                    }
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.playlist_add),
                title: const Text('Add to playlist'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddToPlaylistSheet(context, song);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Delete Song', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteSongPermanently(song);
                },
              ),
            ],
          ),
        );
      },
    );
  }


  void _showTipsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('App Tips'),
        content: const Text(
          '1. Use the Songs tab to search and filter tracks.\n'
          '2. Use the Playlists tab to create and manage collections.\n'
          '3. Use the Player tab to control playback.\n'
          '4. Use the Settings tab to explore toggles and UI demos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _startSleepTimer(int minutes) {
    _sleepTimer?.cancel();
    setState(() => _sleepMinutesRemaining = minutes);
    if (minutes > 0) {
      _sleepTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
        setState(() {
          if (_sleepMinutesRemaining > 0) {
            _sleepMinutesRemaining--;
          } else {
            _playing = false;
            _sleepTimer?.cancel();
          }
        });
      });
    }
  }

  Future<void> _showSleepTimerDialog(BuildContext context) async {
    final selected = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sleep Timer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Off'),
                subtitle: const Text('No timer active'),
                leading: const Icon(Icons.timer_off),
                onTap: () => Navigator.pop(context, 0),
              ),
              ListTile(
                title: const Text('15 Minutes'),
                leading: const Icon(Icons.timer_3),
                onTap: () => Navigator.pop(context, 15),
              ),
              ListTile(
                title: const Text('30 Minutes'),
                leading: const Icon(Icons.timer_10),
                onTap: () => Navigator.pop(context, 30),
              ),
              ListTile(
                title: const Text('60 Minutes'),
                leading: const Icon(Icons.timer),
                onTap: () => Navigator.pop(context, 60),
              ),
            ],
          ),
        );
      },
    );
    if (selected != null) _startSleepTimer(selected);
  }

  void _showAudioSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Audio FX', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 20),
            Text('Equalizer Preset', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  return Column(
                    children: [
                      Expanded(
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Slider(
                            value: 0.5 + (math.sin(index * 0.5) * 0.3),
                            onChanged: (v) {},
                            activeColor: _currentSong.color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('${[60, 230, 910, 3000, 14000][index]}Hz', style: Theme.of(context).textTheme.labelSmall),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
