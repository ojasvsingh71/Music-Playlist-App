import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart' show QueryArtworkWidget, ArtworkType;
import '../models/song.dart';
import 'music_visualizer.dart';

class NowPlayingCard extends StatelessWidget {
  final Song song;
  final double progress;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final Duration position;
  final Duration duration;
  final ValueChanged<double>? onSeek;

  const NowPlayingCard({
    super.key,
    required this.song,
    required this.progress,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.position,
    required this.duration,
    required this.onSeek,
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
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
                        if (song.isLocal)
                          Positioned.fill(
                            child: QueryArtworkWidget(
                              id: int.parse(song.id),
                              type: ArtworkType.AUDIO,
                              artworkWidth: 200,
                              artworkHeight: 200,
                              artworkFit: BoxFit.cover,
                              keepOldArtwork: true,
                              nullArtworkWidget: Icon(song.icon, size: 90, color: Colors.white),
                            ),
                          )
                        else
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
              Slider(
                value: progress.clamp(0.0, 1.0),
                onChanged: onSeek,
                activeColor: song.color,
                inactiveColor: song.color.withOpacity(0.15),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_durationText(position), style: TextStyle(fontWeight: FontWeight.w600, color: song.color)),
                  Text(_durationText(duration), style: const TextStyle(fontWeight: FontWeight.w600)),
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

class ControlPanel extends StatelessWidget {
  final bool isShuffled;
  final bool isLooping;
  final double volume;
  final VoidCallback onShuffle;
  final VoidCallback onLoop;
  final ValueChanged<double> onVolumeChanged;

  const ControlPanel({
    super.key,
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
