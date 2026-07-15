import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart' show QueryArtworkWidget, ArtworkType;
import '../models/song.dart';

class SongCard extends StatelessWidget {
  final Song song;
  final bool isFavorite;
  final bool isDownloaded;
  final bool compact;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onAddToPlaylist;
  final VoidCallback? onDelete;
  final VoidCallback? onMore;

  const SongCard({
    super.key,
    required this.song,
    required this.isFavorite,
    required this.isDownloaded,
    required this.compact,
    required this.onTap,
    this.onFavoriteToggle,
    this.onAddToPlaylist,
    this.onDelete,
    this.onMore,
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: compact ? 54 : 66,
                    height: compact ? 54 : 66,
                    decoration: BoxDecoration(
                      color: song.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: song.isLocal
                        ? QueryArtworkWidget(
                            id: int.parse(song.id),
                            type: ArtworkType.AUDIO,
                            artworkWidth: compact ? 54 : 66,
                            artworkHeight: compact ? 54 : 66,
                            artworkFit: BoxFit.cover,
                            keepOldArtwork: true,
                            nullArtworkWidget: Icon(song.icon, color: song.color),
                          )
                        : Icon(song.icon, color: song.color),
                  ),
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
                        MetaBadge(text: song.genre),
                        MetaBadge(text: durationText),
                        MetaBadge(text: song.year.toString()),
                        if (isDownloaded) const MetaBadge(text: 'Downloaded'),
                      ],
                    ),
                  ],
                ),
              ),
              if (onFavoriteToggle != null ||
                  onAddToPlaylist != null ||
                  onDelete != null ||
                  onMore != null)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onFavoriteToggle != null)
                      IconButton(
                        onPressed: onFavoriteToggle,
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.redAccent : null,
                        ),
                      ),
                    if (onAddToPlaylist != null)
                      IconButton(
                        onPressed: onAddToPlaylist,
                        icon: const Icon(Icons.playlist_add),
                      ),
                    if (onDelete != null)
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      ),
                    if (onMore != null)
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

class MetaBadge extends StatelessWidget {
  final String text;

  const MetaBadge({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}
