import 'package:flutter/material.dart';
import 'dart:math' as math;

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
