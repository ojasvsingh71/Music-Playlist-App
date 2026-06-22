import 'dart:io';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import '../main.dart'; // To reference the Song model

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

      // Filter out notifications, ringtones, or files under 10 seconds
      final playableSongs = localSongs.where((song) {
        final isMusic = song.isMusic ?? true;
        final duration = song.duration ?? 0;
        return isMusic && duration >= 10000;
      }).toList();

      // Map to our custom Song model
      return playableSongs.map((songModel) {
        return Song(
          id: songModel.id.toString(),
          title: songModel.title,
          artist: (songModel.artist == '<unknown>' || songModel.artist == null) 
              ? 'Unknown Artist' 
              : songModel.artist!,
          album: (songModel.album == '<unknown>' || songModel.album == null) 
              ? 'Unknown Album' 
              : songModel.album!,
          duration: Duration(milliseconds: songModel.duration ?? 0),
          genre: (songModel.genre == '<unknown>' || songModel.genre == null) 
              ? 'Local Audio' 
              : songModel.genre!,
          year: DateTime.now().year,
          rating: 0.0, // default rating for local files
          icon: Icons.music_note,
          color: _generateColorForSong(songModel.title),
          mood: 'Local',
          lyrics: [],
          uri: songModel.uri,
          isLocal: true,
        );
      }).toList();
    } catch (e) {
      print("Error scanning local music: $e");
      return [];
    }
  }

  /// Generate a consistent, aesthetic theme color based on the title string hash
  Color _generateColorForSong(String title) {
    final hash = title.hashCode;
    final colors = [
      Colors.orange,
      Colors.brown,
      Colors.amber,
      Colors.redAccent,
      Colors.red,
      Colors.blueAccent,
      Colors.green,
      Colors.blueGrey,
      Colors.deepPurple,
      Colors.indigo,
      Colors.pinkAccent,
      Colors.teal,
      Colors.cyan,
      Colors.purpleAccent,
    ];
    return colors[hash.abs() % colors.length];
  }
}
