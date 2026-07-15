import 'package:flutter/material.dart';

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
