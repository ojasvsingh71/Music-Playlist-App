
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'dart:async';

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

class LyricLine {
  final Duration timestamp;
  final String text;
  const LyricLine(this.timestamp, this.text);
}

class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final String genre;
  final int year;
  final double rating;
  final IconData icon;
  final Color color;
  final String mood;
  final List<LyricLine> lyrics;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.genre,
    required this.year,
    required this.rating,
    required this.icon,
    required this.color,
    required this.mood,
    required this.lyrics,
  });
}

class Playlist {
  final String id;
  String name;
  String description;
  final List<String> songIds;
  final DateTime createdAt;
  final Color color;
  final IconData icon;
  bool isPublic;

  Playlist({
    required this.id,
    required this.name,
    required this.description,
    required this.songIds,
    required this.createdAt,
    required this.color,
    required this.icon,
    this.isPublic = false,
  });
}

class AppShell extends StatefulWidget {
  final Function(Color) onThemeChanged;
  const AppShell({super.key, required this.onThemeChanged});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
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
  final Set<String> _favoriteSongIds = {'s1', 's3', 's7'};
  final Set<String> _downloadedSongIds = {'s1', 's2', 's4'};
  final List<String> _recentHistory = [];
  String _genreFilter = 'All';

  static const List<Song> _songs = [
    Song(
      id: 's1',
      title: 'Kesariya',
      artist: 'Arijit Singh',
      album: 'Brahmastra',
      duration: Duration(minutes: 4, seconds: 28),
      genre: 'Romantic',
      year: 2022,
      rating: 4.9,
      icon: Icons.favorite,
      color: Colors.orange,
      mood: 'Romantic',
      lyrics: [
        LyricLine(Duration(seconds: 0), "(Instrumental Intro)"),
        LyricLine(Duration(seconds: 15), "Mujhse hi... mujh tak ka..."),
        LyricLine(Duration(seconds: 22), "Ek safar hai... tu..."),
        LyricLine(Duration(seconds: 30), "Kesariya tera ishq hai piya..."),
        LyricLine(Duration(seconds: 38), "Rang jaaun jo main haath lagaun..."),
        LyricLine(Duration(seconds: 45), "Din beete saara teri fikr mein..."),
        LyricLine(Duration(seconds: 52), "Rain saari teri khair manaun..."),
      ],
    ),
    Song(
      id: 's2',
      title: 'Kun Faya Kun',
      artist: 'A.R. Rahman',
      album: 'Rockstar',
      duration: Duration(minutes: 7, seconds: 53),
      genre: 'Sufi',
      year: 2011,
      rating: 5.0,
      icon: Icons.auto_awesome,
      color: Colors.brown,
      mood: 'Spiritual',
      lyrics: [
        LyricLine(Duration(seconds: 0), "Kun faya kun..."),
        LyricLine(Duration(seconds: 20), "Jab kahin pe... kuch nahi tha..."),
        LyricLine(Duration(seconds: 40), "Wahi tha... wahi tha..."),
        LyricLine(Duration(seconds: 60), "Sajde mein... sir jhuka..."),
      ],
    ),
    Song(
      id: 's3',
      title: 'Tum Se Hi',
      artist: 'Mohit Chauhan',
      album: 'Jab We Met',
      duration: Duration(minutes: 5, seconds: 23),
      genre: 'Pop',
      year: 2007,
      rating: 4.8,
      icon: Icons.wb_sunny,
      color: Colors.yellow,
      mood: 'Happy',
      lyrics: [
        LyricLine(Duration(seconds: 0), "Na hai yeh paana..."),
        LyricLine(Duration(seconds: 15), "Na khona hi hai..."),
        LyricLine(Duration(seconds: 30), "Tera milna..."),
        LyricLine(Duration(seconds: 45), "Tum se hi... tum se hi..."),
      ],
    ),
    Song(
      id: 's4',
      title: 'Pasoori',
      artist: 'Ali Sethi & Shae Gill',
      album: 'Coke Studio',
      duration: Duration(minutes: 3, seconds: 44),
      genre: 'Fusion',
      year: 2022,
      rating: 4.7,
      icon: Icons.nightlight,
      color: Colors.redAccent,
      mood: 'Energetic',
      lyrics: [
        LyricLine(Duration(seconds: 0), "Agg lavaan majboori nu..."),
        LyricLine(Duration(seconds: 15), "Aan jaan di pasoori nu..."),
        LyricLine(Duration(seconds: 30), "Jehr bane teri..."),
        LyricLine(Duration(seconds: 45), "Mainu kadi na..."),
      ],
    ),
    Song(
      id: 's5',
      title: 'Dil Se Re',
      artist: 'A.R. Rahman',
      album: 'Dil Se',
      duration: Duration(minutes: 6, seconds: 44),
      genre: 'Alternative',
      year: 1998,
      rating: 4.9,
      icon: Icons.heart_broken,
      color: Colors.red,
      mood: 'Dark',
      lyrics: [
        LyricLine(Duration(seconds: 0), "Dil se re..."),
        LyricLine(Duration(seconds: 20), "Ek baar... bacha ke dekh..."),
      ],
    ),
    Song(
      id: 's6',
      title: 'Pee Loon',
      artist: 'Mohit Chauhan',
      album: 'Once Upon A Time',
      duration: Duration(minutes: 4, seconds: 48),
      genre: 'Romantic',
      year: 2010,
      rating: 4.7,
      icon: Icons.water_drop,
      color: Colors.blueAccent,
      mood: 'Romantic',
      lyrics: [
        LyricLine(Duration(seconds: 0), "Pee loon... tere neele neele..."),
        LyricLine(Duration(seconds: 20), "Tere khwab..."),
      ],
    ),
    Song(
      id: 's7',
      title: 'Zalima',
      artist: 'Arijit Singh',
      album: 'Raees',
      duration: Duration(minutes: 4, seconds: 59),
      genre: 'Desi',
      year: 2017,
      rating: 4.6,
      icon: Icons.remove_red_eye,
      color: Colors.green,
      mood: 'Flirty',
      lyrics: [
        LyricLine(Duration(seconds: 0), "Jo teri khatir..."),
        LyricLine(Duration(seconds: 20), "Tadap raha hai..."),
      ],
    ),
    Song(
      id: 's8',
      title: 'Raataan Lambiyan',
      artist: 'Jubin Nautiyal',
      album: 'Shershaah',
      duration: Duration(minutes: 3, seconds: 50),
      genre: 'Pop',
      year: 2021,
      rating: 4.8,
      icon: Icons.nightlight_round,
      color: Colors.blueGrey,
      mood: 'Soothing',
      lyrics: [
        LyricLine(Duration(seconds: 0), "Teri meri baaton mein..."),
        LyricLine(Duration(seconds: 20), "Raataan lambiyan..."),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _playlists = [
      Playlist(
        id: 'p1',
        name: 'Chill Vibes',
        description: 'Relaxing tracks for calm evenings.',
        songIds: ['s1', 's2', 's5'],
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
        color: Colors.deepPurple,
        icon: Icons.self_improvement,
        isPublic: true,
      ),
      Playlist(
        id: 'p2',
        name: 'Workout Mix',
        description: 'High energy songs to keep you moving.',
        songIds: ['s3', 's8', 's4'],
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        color: Colors.red,
        icon: Icons.fitness_center,
      ),
      Playlist(
        id: 'p3',
        name: 'Late Night Drive',
        description: 'Perfect for long rides under city lights.',
        songIds: ['s1', 's3', 's10'],
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        color: Colors.indigo,
        icon: Icons.drive_eta,
        isPublic: true,
      ),
    ];
  }

  @override
  void dispose() {
    _songSearch.dispose();
    _playlistSearch.dispose();
    _newPlaylistName.dispose();
    _newPlaylistDescription.dispose();
    super.dispose();
  }

  Song get _currentSong => _songs[_currentSongIndex % _songs.length];

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
        _SectionHeader(
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
                  selectedColor: _songs.firstWhere((s) => s.mood == mood, orElse: () => _songs.first).color.withOpacity(0.2),
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
            _StatCard(
              title: 'Songs',
              value: '${_songs.length}',
              icon: Icons.music_note,
            ),
            _StatCard(
              title: 'Playlists',
              value: '${_playlists.length}',
              icon: Icons.playlist_play,
            ),
            _StatCard(
              title: 'Favorites',
              value: '${_favoriteSongIds.length}',
              icon: Icons.favorite,
            ),
            _StatCard(
              title: 'Duration',
              value: _formatDuration(_libraryDuration),
              icon: Icons.timer,
            ),
          ],
        ),
        const SizedBox(height: 32),
        _SectionHeader(
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
              _ActionChip(icon: Icons.shuffle, label: 'Shuffle', onTap: _shuffleToRandomSong),
              const SizedBox(width: 12),
              _ActionChip(
                icon: Icons.favorite,
                label: 'Favorites',
                onTap: () => setState(() {
                  _index = 1;
                  _favoritesOnly = true;
                }),
              ),
              const SizedBox(width: 12),
              _ActionChip(
                icon: Icons.queue_music,
                label: 'Queue',
                onTap: () => setState(() => _index = 3),
              ),
              const SizedBox(width: 12),
              _ActionChip(
                icon: Icons.download,
                label: 'Downloads',
                onTap: () => _showInfoSheet(context, 'Downloads', 'This mock app marks some songs as downloaded.'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _SectionHeader(
          title: 'Recently Played',
          subtitle: 'Your latest listening history',
          actionLabel: 'Clear',
          onAction: () => setState(() => _recentHistory.clear()),
        ),
        const SizedBox(height: 16),
        if (_recentHistory.isEmpty)
          const _EmptyState(
            icon: Icons.history,
            title: 'No recent songs',
            subtitle: 'Start playback to create history.',
          )
        else
          ..._recentHistory.take(5).map((title) => _HistoryTile(title: title)),
        const SizedBox(height: 32),
        _SectionHeader(
          title: 'Top Playlist Preview',
          subtitle: 'Open a playlist to view details',
          actionLabel: 'Open',
          onAction: () => setState(() => _index = 2),
        ),
        const SizedBox(height: 16),
        if (_playlists.isNotEmpty)
          _PlaylistPreviewCard(
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
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(song.icon, size: 46, color: Colors.white),
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
                  value: _playing ? 0.72 : 0.28,
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
              separatorBuilder: (_, __) => const SizedBox(width: 8),
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
          child: songs.isEmpty
              ? const _EmptyState(
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
                      child: _SongCard(
                        song: song,
                        isFavorite: isFavorite,
                        isDownloaded: isDownloaded,
                        compact: false,
                        onTap: () {
                          _setCurrentSong(_songs.indexWhere((s) => s.id == song.id));
                          setState(() {
                            _index = 3;
                            _playing = true;
                          });
                        },
                        onFavoriteToggle: () => setState(() {
                          if (isFavorite) {
                            _favoriteSongIds.remove(song.id);
                          } else {
                            _favoriteSongIds.add(song.id);
                          }
                        }),
                        onAddToPlaylist: () => _showAddToPlaylistSheet(context, song),
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
              ? const _EmptyState(
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
                    return _PlaylistCard(
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
        _NowPlayingCard(
          song: current,
          isPlaying: _playing,
          progress: _playing ? 0.64 : 0.16,
          onPlayPause: () => setState(() => _playing = !_playing),
          onNext: _nextSong,
          onPrevious: _previousSong,
        ),
        const SizedBox(height: 16),
        _SectionHeader(
          title: 'Lyrics',
          subtitle: 'Synchronized with playback',
          actionLabel: 'Settings',
          onAction: () => _showAudioSettings(context),
        ),
        const SizedBox(height: 12),
        LyricsView(song: current, progress: _playing ? 0.64 : 0.16),
        const SizedBox(height: 16),
        _ControlPanel(
          isShuffled: _shuffle,
          isLooping: _loop,
          volume: _volume,
          onShuffle: () => setState(() => _shuffle = !_shuffle),
          onLoop: () => setState(() => _loop = !_loop),
          onVolumeChanged: (value) => setState(() => _volume = value),
        ),
        const SizedBox(height: 16),
        _SectionHeader(
          title: 'Up Next',
          subtitle: 'Queue preview from the first playlist',
          actionLabel: 'Open Playlist',
          onAction: () => setState(() => _index = 2),
        ),
        const SizedBox(height: 12),
        if (queueSongs.isEmpty)
          const _EmptyState(
            icon: Icons.queue_music,
            title: 'Queue is empty',
            subtitle: 'Add songs to a playlist to populate the queue.',
          )
        else
          ...queueSongs.take(5).map(
                (song) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _QueueTile(
                    song: song,
                    isCurrent: song.id == current.id,
                    onTap: () {
                      _setCurrentSong(_songs.indexWhere((s) => s.id == song.id));
                      setState(() => _playing = true);
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
        _SectionHeader(
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
            _ThemeChip(label: 'Classic Purple'),
            _ThemeChip(label: 'Ocean Blue'),
            _ThemeChip(label: 'Sunset Orange'),
          ],
        ),
        const SizedBox(height: 20),
        _SectionHeader(
          title: 'App Preferences',
          subtitle: 'Toggle features used in the mock interface',
          actionLabel: 'Tips',
          onAction: () => _showTipsDialog(context),
        ),
        const SizedBox(height: 12),
        _SettingsTile(
          title: 'Loop playback',
          subtitle: 'Repeat the current song when it ends',
          value: _loop,
          icon: Icons.repeat,
          onChanged: (value) => setState(() => _loop = value),
        ),
        _SettingsTile(
          title: 'Shuffle mode',
          subtitle: 'Randomize track order in the player',
          value: _shuffle,
          icon: Icons.shuffle,
          onChanged: (value) => setState(() => _shuffle = value),
        ),
        _SettingsTile(
          title: 'Favorite filter',
          subtitle: 'Show only your favorite tracks',
          value: _favoritesOnly,
          icon: Icons.favorite,
          onChanged: (value) => setState(() => _favoritesOnly = value),
        ),
        const SizedBox(height: 20),
        _SupportCard(
          title: 'Sleep Timer',
          subtitle: _sleepMinutesRemaining > 0 ? 'Stopping in $_sleepMinutesRemaining min' : 'Auto-stop playback after time',
          icon: Icons.timer,
          onTap: () => _showSleepTimerDialog(context),
        ),
        const SizedBox(height: 12),
        const _SupportCard(
          title: 'Song Selection',
          subtitle: 'Choose a track, open details, favorite it, or add it to a playlist.',
          icon: Icons.touch_app,
        ),
        const SizedBox(height: 12),
        const _SupportCard(
          title: 'Playlist Display',
          subtitle: 'See songs, statistics, colors, and actions in card layouts.',
          icon: Icons.dashboard_customize,
        ),
        const SizedBox(height: 12),
        const _SupportCard(
          title: 'Hero Animations',
          subtitle: 'Move between screens with a smooth hero transition for the active song.',
          icon: Icons.auto_awesome,
        ),
      ],
    );
  }

  void _setCurrentSong(int index) {
    setState(() {
      _currentSongIndex = index;
      _recentHistory.insert(0, _currentSong.title);
      if (_recentHistory.length > 10) _recentHistory.removeLast();
    });
    widget.onThemeChanged(_currentSong.color);
  }

  void _nextSong() {
    if (_shuffle) {
      _setCurrentSong((_currentSongIndex + 3) % _songs.length);
    } else {
      _setCurrentSong((_currentSongIndex + 1) % _songs.length);
    }
    setState(() => _playing = true);
  }

  void _previousSong() {
    if (_shuffle) {
      _setCurrentSong((_currentSongIndex + _songs.length - 2) % _songs.length);
    } else {
      _setCurrentSong((_currentSongIndex + _songs.length - 1) % _songs.length);
    }
    setState(() => _playing = true);
  }

  void _shuffleToRandomSong() {
    _setCurrentSong(DateTime.now().millisecondsSinceEpoch % _songs.length);
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
                          child: Icon(song.icon, color: Colors.white, size: 24),
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
                        onPressed: () => setState(() => _playing = !_playing),
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
                    value: _playing ? 0.6 : 0.2,
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
                        child: _SongCard(
                          song: song,
                          isFavorite: _favoriteSongIds.contains(song.id),
                          isDownloaded: _downloadedSongIds.contains(song.id),
                          compact: true,
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              _currentSongIndex = _songs.indexWhere((s) => s.id == song.id);
                              _index = 3;
                              _playing = true;
                            });
                          },
                          onFavoriteToggle: () {},
                          onAddToPlaylist: () {},
                          onMore: () {},
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
    return ids
        .map((id) => _songs.firstWhere((song) => song.id == id, orElse: () => _songs.first))
        .toList();
  }

  void _showPlaylistDetails(BuildContext context, Playlist playlist) {
    final playlistSongs = _songsFromIds(playlist.songIds);
    final duration = playlistSongs.fold(Duration.zero, (prev, song) => prev + song.duration);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
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
                      backgroundColor: playlist.color.withOpacity(0.15),
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
                    _StatCard(title: 'Songs', value: '${playlistSongs.length}', icon: Icons.music_note),
                    _StatCard(title: 'Duration', value: _formatDuration(duration), icon: Icons.timelapse),
                    _StatCard(title: 'Public', value: playlist.isPublic ? 'Yes' : 'No', icon: Icons.public),
                  ],
                ),
                const SizedBox(height: 20),
                _SectionHeader(
                  title: 'Songs in Playlist',
                  subtitle: 'Tap any song to play it instantly',
                  actionLabel: 'Add Songs',
                  onAction: () {},
                ),
                const SizedBox(height: 12),
                if (playlistSongs.isEmpty)
                  const _EmptyState(
                    icon: Icons.playlist_remove,
                    title: 'No songs yet',
                    subtitle: 'Add songs from the Songs tab.',
                  )
                else
                  ...playlistSongs.map(
                    (song) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _QueueTile(
                        song: song,
                        isCurrent: song.id == _currentSong.id,
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _currentSongIndex = _songs.indexWhere((s) => s.id == song.id);
                            _index = 3;
                            _playing = true;
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
            ],
          ),
        );
      },
    );
  }

  void _showPlaylistTips(BuildContext context) {
    _showInfoSheet(
      context,
      'Playlist Tips',
      'Create playlists, search them, edit details, and open the preview sheet to inspect songs.',
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(100),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  actionLabel,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final String title;

  const _HistoryTile({required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.history)),
        title: Text(title),
        subtitle: const Text('Played recently'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, size: 54),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(subtitle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _PlaylistPreviewCard extends StatelessWidget {
  final Playlist playlist;
  final int songCount;
  final VoidCallback onTap;

  const _PlaylistPreviewCard({
    required this.playlist,
    required this.songCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: playlist.color.withOpacity(0.15),
                child: Icon(playlist.icon, color: playlist.color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(playlist.name, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(playlist.description),
                    const SizedBox(height: 8),
                    Text('$songCount songs • ${playlist.isPublic ? 'Public' : 'Private'}'),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _SongCard extends StatelessWidget {
  final Song song;
  final bool isFavorite;
  final bool isDownloaded;
  final bool compact;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onAddToPlaylist;
  final VoidCallback onMore;

  const _SongCard({
    required this.song,
    required this.isFavorite,
    required this.isDownloaded,
    required this.compact,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onAddToPlaylist,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final durationText =
        '${song.duration.inMinutes}:${song.duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';

    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Hero(
                tag: 'hero_${song.id}',
                child: Container(
                  width: compact ? 54 : 66,
                  height: compact ? 54 : 66,
                  decoration: BoxDecoration(
                    color: song.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(song.icon, color: song.color),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(song.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('${song.artist} • ${song.album}', maxLines: compact ? 1 : 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _MetaBadge(text: song.genre),
                        _MetaBadge(text: durationText),
                        _MetaBadge(text: song.year.toString()),
                        if (isDownloaded) const _MetaBadge(text: 'Downloaded'),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    onPressed: onFavoriteToggle,
                    icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                  ),
                  IconButton(
                    onPressed: onAddToPlaylist,
                    icon: const Icon(Icons.playlist_add),
                  ),
                  IconButton(
                    onPressed: onMore,
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  final String text;

  const _MetaBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final int songCount;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PlaylistCard({
    required this.playlist,
    required this.songCount,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: playlist.color.withOpacity(0.16),
                    child: Icon(playlist.icon, color: playlist.color),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                playlist.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                playlist.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text(
                      '$songCount songs',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                  Chip(
                    label: Text(
                      playlist.isPublic ? 'Public' : 'Private',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NowPlayingCard extends StatelessWidget {
  final Song song;
  final double progress;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const _NowPlayingCard({
    required this.song,
    required this.progress,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: song.color.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            colors: [song.color.withOpacity(0.05), Colors.white.withOpacity(0.8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Text(
                song.genre.toUpperCase(),
                style: TextStyle(
                  letterSpacing: 4,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: song.color.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 20),
              Hero(
                tag: 'hero_${song.id}',
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [song.color, song.color.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: song.color.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(song.icon, size: 90, color: Colors.white),
                      if (isPlaying)
                        Positioned(
                          bottom: 20,
                          child: MusicVisualizer(
                            color: Colors.white,
                            genre: song.genre,
                            isPlaying: isPlaying,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                song.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                '${song.artist} • ${song.album}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                borderRadius: BorderRadius.circular(99),
                backgroundColor: song.color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(song.color),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('1:24', style: TextStyle(fontWeight: FontWeight.w600, color: song.color)),
                  Text(_durationText(song.duration), style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 24),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton.filledTonal(
                      onPressed: onPrevious,
                      icon: const Icon(Icons.skip_previous, size: 32),
                      style: IconButton.styleFrom(padding: const EdgeInsets.all(16)),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: onPlayPause,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: song.color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: song.color.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton.filledTonal(
                      onPressed: onNext,
                      icon: const Icon(Icons.skip_next, size: 32),
                      style: IconButton.styleFrom(padding: const EdgeInsets.all(16)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _durationText(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _ControlPanel extends StatelessWidget {
  final bool isShuffled;
  final bool isLooping;
  final double volume;
  final VoidCallback onShuffle;
  final VoidCallback onLoop;
  final ValueChanged<double> onVolumeChanged;

  const _ControlPanel({
    required this.isShuffled,
    required this.isLooping,
    required this.volume,
    required this.onShuffle,
    required this.onLoop,
    required this.onVolumeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Controls', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                FilterChip(
                  label: const Text('Shuffle'),
                  selected: isShuffled,
                  onSelected: (_) => onShuffle(),
                ),
                const SizedBox(width: 10),
                FilterChip(
                  label: const Text('Loop'),
                  selected: isLooping,
                  onSelected: (_) => onLoop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Volume'),
            Slider(value: volume, onChanged: onVolumeChanged),
          ],
        ),
      ),
    );
  }
}

class _QueueTile extends StatelessWidget {
  final Song song;
  final bool isCurrent;
  final VoidCallback onTap;

  const _QueueTile({
    required this.song,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: song.color.withOpacity(0.16),
          child: Icon(song.icon, color: song.color),
        ),
        title: Text(song.title),
        subtitle: Text('${song.artist} • ${song.genre}'),
        trailing: isCurrent ? const Icon(Icons.play_circle_filled) : const Icon(Icons.drag_handle),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                              fontSize: 10,
                            ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
                  ],
                ),
                const Spacer(),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final String label;

  const _ThemeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: false,
      onSelected: (_) {},
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final IconData icon;
  final ValueChanged<bool> onChanged;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const _SupportCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(child: Icon(icon)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(subtitle),
                  ],
                ),
              ),
              if (onTap != null) const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class MusicVisualizer extends StatefulWidget {
  final Color color;
  final String genre;
  final bool isPlaying;

  const MusicVisualizer({
    super.key,
    required this.color,
    required this.genre,
    required this.isPlaying,
  });

  @override
  State<MusicVisualizer> createState() => _MusicVisualizerState();
}

class _MusicVisualizerState extends State<MusicVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _heights = List.generate(30, (_) => math.Random().nextDouble());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPlaying) _controller.stop();
    if (widget.isPlaying && !_controller.isAnimating) _controller.repeat();

    double speedMultiplier = 1.0;
    if (widget.genre == 'Electronic' || widget.genre == 'Dance') speedMultiplier = 2.0;
    if (widget.genre == 'Ambient' || widget.genre == 'Lo-Fi') speedMultiplier = 0.5;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(15, (index) {
            final h = math.sin((_controller.value * speedMultiplier * math.pi * 2) + (index * 0.5)) * 0.5 + 0.5;
            return Container(
              width: 4,
              height: 20 + (h * 40),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.7),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}

class LyricsView extends StatelessWidget {
  final Song song;
  final double progress;
  const LyricsView({super.key, required this.song, required this.progress});

  @override
  Widget build(BuildContext context) {
    final currentDuration = song.duration * progress;
    
    int activeIndex = -1;
    for (int i = 0; i < song.lyrics.length; i++) {
        if (song.lyrics[i].timestamp <= currentDuration) {
          activeIndex = i;
        }
    }

    return Container(
      height: 240,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: song.color.withOpacity(0.04),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: song.color.withOpacity(0.1)),
      ),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: song.lyrics.length,
        itemBuilder: (context, index) {
          final isHighlighted = index == activeIndex;
          final lyric = song.lyrics[index];
          
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              lyric.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isHighlighted ? 22 : 16,
                fontWeight: isHighlighted ? FontWeight.w900 : FontWeight.w500,
                color: isHighlighted ? song.color : Colors.grey.withOpacity(0.6),
                height: 1.4,
              ),
            ),
          );
        },
      ),
    );
  }

  List<String> _getMockLyrics(String genre) {
    if (genre == 'Synthwave') {
      return ['Neon lights reflect in your eyes', 'Racing through the digital skies', 'Cyber heart, electric soul', 'In this machine, I lose control'];
    }
    if (genre == 'Lo-Fi') {
      return ['Raindrops on the window pane', 'Coffee steam and hidden pain', 'Low fidelity, high emotion', 'Sailing on a steady ocean'];
    }
    return ['Music flows through the air', 'Melodies beyond compare', 'A rhythm for the lonely heart', 'Where every end is a new start'];
  }
}