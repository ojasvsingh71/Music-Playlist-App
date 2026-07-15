import 'package:flutter/material.dart';

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
  final String? uri;
  final String? path;
  final bool isLocal;

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
    this.uri,
    this.path,
    this.isLocal = false,
  });
}
