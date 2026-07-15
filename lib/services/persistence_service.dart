import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/playlist.dart';

class PersistenceService {
  static final PersistenceService instance = PersistenceService._internal();
  PersistenceService._internal();

  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/user_data.json');
  }

  static IconData getIconFromName(String name) {
    switch (name) {
      case 'self_improvement':
        return Icons.self_improvement;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'drive_eta':
        return Icons.drive_eta;
      case 'queue_music':
        return Icons.queue_music;
      default:
        return Icons.music_note;
    }
  }

  static String getNameFromIcon(IconData icon) {
    if (icon == Icons.self_improvement) return 'self_improvement';
    if (icon == Icons.fitness_center) return 'fitness_center';
    if (icon == Icons.drive_eta) return 'drive_eta';
    if (icon == Icons.queue_music) return 'queue_music';
    return 'music_note';
  }

  Future<Map<String, dynamic>> loadData() async {
    try {
      final file = await _file;
      if (await file.exists()) {
        final content = await file.readAsString();
        return jsonDecode(content) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint("Error loading persistent data: $e");
    }
    return {};
  }

  Future<void> saveData({
    required List<Playlist> playlists,
    required Set<String> favoriteSongIds,
    required Set<String> downloadedSongIds,
    required List<String> recentHistory,
  }) async {
    try {
      final file = await _file;
      final data = {
        'playlists': playlists.map((p) => {
          'id': p.id,
          'name': p.name,
          'description': p.description,
          'songIds': p.songIds,
          'createdAt': p.createdAt.toIso8601String(),
          'color': p.color.toARGB32(),
          'icon': getNameFromIcon(p.icon),
          'isPublic': p.isPublic,
        }).toList(),
        'favorites': favoriteSongIds.toList(),
        'downloads': downloadedSongIds.toList(),
        'history': recentHistory,
      };
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint("Error saving persistent data: $e");
    }
  }
}
