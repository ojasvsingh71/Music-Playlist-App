import 'dart:io';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/song.dart';
import 'song_classifier.dart';

class LocalMusicScannerService {
  // Singleton Pattern
  static final LocalMusicScannerService instance = LocalMusicScannerService._internal();
  LocalMusicScannerService._internal();

  final OnAudioQuery _audioQuery = OnAudioQuery();

  /// Check permissions and request if missing
  Future<bool> checkAndRequestPermissions() async {
    if (Platform.isAndroid) {
      // For Android 13+ (API level 33) we need READ_MEDIA_AUDIO
      var audioStatus = await Permission.audio.status;
      if (!audioStatus.isGranted) {
        audioStatus = await Permission.audio.request();
      }

      if (audioStatus.isGranted) {
        return true;
      }

      // Fallback/standard permission for Android 12 and below
      var storageStatus = await Permission.storage.status;
      if (!storageStatus.isGranted) {
        storageStatus = await Permission.storage.request();
      }
      return storageStatus.isGranted;
    } else if (Platform.isIOS) {
      // iOS media library access
      var status = await Permission.mediaLibrary.status;
      if (!status.isGranted) {
        status = await Permission.mediaLibrary.request();
      }
      return status.isGranted;
    }
    return true; // Other platforms (desktop, web, etc.)
  }

  /// Scan for local songs and return mapped Song models
  Future<List<Song>> scanLocalMusic() async {
    try {
      final hasPermission = await checkAndRequestPermissions();
      if (!hasPermission) {
        print("Permissions denied. Cannot query local songs.");
        return [];
      }

      // Query songs from external storage
      final List<SongModel> localSongs = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      // Filter out voice notes, call recordings, app files, or files under 30 seconds
      final playableSongs = localSongs.where((song) {
        // Exclude tracks shorter than 30 seconds (standard for songs)
        final duration = song.duration ?? 0;
        if (duration < 30000) return false;

        // Exclude typical voice recording / WhatsApp prefix patterns
        final name = (song.displayName).toUpperCase();
        if (name.startsWith("AUD-") || 
            name.startsWith("PTT-") || 
            name.startsWith("REC-") || 
            name.startsWith("VOICE-")) {
          return false;
        }

        // Exclude non-music paths (WhatsApp, Telegram, Call recorders, App caches, System audio)
        final path = (song.data).toLowerCase();
        final excludedKeywords = [
          "whatsapp",
          "telegram",
          "recorder",
          "recording",
          "voice_memo",
          "voicememo",
          "call_rec",
          "callrec",
          "android/data",
          "notifications",
          "ringtones",
          "alarms",
          "podcasts"
        ];
        for (final keyword in excludedKeywords) {
          if (path.contains(keyword)) {
            return false;
          }
        }

        return true;
      }).toList();

      // Map to our custom Song model using the auto classifier
      return playableSongs.map((songModel) {
        final title = songModel.title;
        final artist = (songModel.artist == '<unknown>' || songModel.artist == null)
            ? 'Unknown Artist'
            : songModel.artist!;
        final album = (songModel.album == '<unknown>' || songModel.album == null)
            ? 'Unknown Album'
            : songModel.album!;
        final duration = Duration(milliseconds: songModel.duration ?? 0);
        final nativeGenre = (songModel.genre == '<unknown>' || songModel.genre == null)
            ? null
            : songModel.genre;

        final classification = SongClassifier.classify(
          title: title,
          artist: artist,
          album: album,
          nativeGenre: nativeGenre,
          duration: duration,
        );

        return Song(
          id: songModel.id.toString(),
          title: title,
          artist: artist,
          album: album,
          duration: duration,
          genre: classification.genre,
          year: DateTime.now().year,
          rating: 0.0, // default rating for local files
          icon: classification.icon,
          color: classification.color,
          mood: classification.mood,
          lyrics: [],
          uri: songModel.uri,
          path: songModel.data,
          isLocal: true,
        );
      }).toList();
    } catch (e) {
      print("Error scanning local music: $e");
      return [];
    }
  }
}
