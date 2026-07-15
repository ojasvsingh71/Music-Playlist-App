import 'package:flutter/material.dart';
import '../models/song.dart';

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
}
