import 'package:flutter/material.dart';

class SongClassification {
  final String genre;
  final String mood;
  final Color color;
  final IconData icon;

  const SongClassification({
    required this.genre,
    required this.mood,
    required this.color,
    required this.icon,
  });
}

class SongClassifier {
  static SongClassification classify({
    required String title,
    required String artist,
    required String album,
    required String? nativeGenre,
    required Duration duration,
  }) {
    final searchStr = '$title $artist $album ${nativeGenre ?? ''}'.toLowerCase();

    // 1. Devotional / Sufi / Spiritual
    if (searchStr.contains('kun faya kun') ||
        searchStr.contains('namo') ||
        searchStr.contains('shiva') ||
        searchStr.contains('krishna') ||
        searchStr.contains('bhajan') ||
        searchStr.contains('ram') ||
        searchStr.contains('hanuman') ||
        searchStr.contains('sufi') ||
        searchStr.contains('spiritual') ||
        searchStr.contains('devotional') ||
        searchStr.contains('mantra') ||
        searchStr.contains('chant') ||
        searchStr.contains('allah') ||
        searchStr.contains('khwaja') ||
        searchStr.contains('baba') ||
        searchStr.contains('temple') ||
        searchStr.contains('stotra') ||
        searchStr.contains('aarti') ||
        searchStr.contains('prarthana') ||
        searchStr.contains('ganesha') ||
        searchStr.contains('om') ||
        searchStr.contains('shanti') ||
        searchStr.contains('sai')) {
      return const SongClassification(
        genre: 'Sufi',
        mood: 'Spiritual',
        color: Colors.brown,
        icon: Icons.auto_awesome,
      );
    }

    // 2. Dark / Melancholy / Sad
    if (searchStr.contains('dil se re') ||
        searchStr.contains('sad') ||
        searchStr.contains('broken') ||
        searchStr.contains('dard') ||
        searchStr.contains('dark') ||
        searchStr.contains('lonely') ||
        searchStr.contains('cry') ||
        searchStr.contains('judai') ||
        searchStr.contains('aloneness') ||
        searchStr.contains('judaiyaan') ||
        searchStr.contains('tanha') ||
        searchStr.contains('tanhaai') ||
        searchStr.contains('bewafa') ||
        searchStr.contains('maut') ||
        searchStr.contains('tear') ||
        searchStr.contains('melancholy') ||
        searchStr.contains('death') ||
        searchStr.contains('hurt') ||
        searchStr.contains('alone')) {
      return const SongClassification(
        genre: 'Alternative',
        mood: 'Dark',
        color: Colors.indigo,
        icon: Icons.heart_broken,
      );
    }

    // 3. Romantic / Love
    if (searchStr.contains('kesariya') ||
        searchStr.contains('tum se hi') ||
        searchStr.contains('dil') ||
        searchStr.contains('love') ||
        searchStr.contains('romantic') ||
        searchStr.contains('piya') ||
        searchStr.contains('ishq') ||
        searchStr.contains('pyaar') ||
        searchStr.contains('mohabbat') ||
        searchStr.contains('sanam') ||
        searchStr.contains('jaan') ||
        searchStr.contains('humsafar') ||
        searchStr.contains('dhadkan') ||
        searchStr.contains('soniye') ||
        searchStr.contains('heeriye') ||
        searchStr.contains('tumhe') ||
        searchStr.contains('akela') ||
        searchStr.contains('tumhi') ||
        searchStr.contains('baatein') ||
        searchStr.contains('chaahat')) {
      return const SongClassification(
        genre: 'Romantic',
        mood: 'Romantic',
        color: Colors.pink,
        icon: Icons.favorite,
      );
    }

    // 4. Energetic / Party / Dance / Hip-Hop
    if (searchStr.contains('pasoori') ||
        searchStr.contains('dance') ||
        searchStr.contains('party') ||
        searchStr.contains('club') ||
        searchStr.contains('remix') ||
        searchStr.contains('shake') ||
        searchStr.contains('energetic') ||
        searchStr.contains('high') ||
        searchStr.contains('dhamaka') ||
        searchStr.contains('beat') ||
        searchStr.contains('dj') ||
        searchStr.contains('electronic') ||
        searchStr.contains('rockstar') ||
        searchStr.contains('nakhra') ||
        searchStr.contains('gabru') ||
        searchStr.contains('bhangra') ||
        searchStr.contains('punjabi') ||
        searchStr.contains('dhol') ||
        searchStr.contains('machayenge') ||
        searchStr.contains('rap') ||
        searchStr.contains('hip hop') ||
        searchStr.contains('hiphop') ||
        searchStr.contains('yo yo') ||
        searchStr.contains('badshah') ||
        searchStr.contains('raftaar') ||
        searchStr.contains('run') ||
        searchStr.contains('workout') ||
        searchStr.contains('gym')) {
      return const SongClassification(
        genre: 'Fusion',
        mood: 'Energetic',
        color: Colors.redAccent,
        icon: Icons.bolt,
      );
    }

    // 5. Chill / Acoustic / Lo-Fi
    if (searchStr.contains('pee loon') ||
        searchStr.contains('chill') ||
        searchStr.contains('relax') ||
        searchStr.contains('lofi') ||
        searchStr.contains('lo-fi') ||
        searchStr.contains('acoustic') ||
        searchStr.contains('soothing') ||
        searchStr.contains('calm') ||
        searchStr.contains('slowed') ||
        searchStr.contains('reverb') ||
        searchStr.contains('peaceful') ||
        searchStr.contains('sleep') ||
        searchStr.contains('night') ||
        searchStr.contains('rain') ||
        searchStr.contains('coffee') ||
        searchStr.contains('breeze') ||
        searchStr.contains('shaam') ||
        searchStr.contains('safar') ||
        searchStr.contains('sukun') ||
        searchStr.contains('khoya')) {
      return const SongClassification(
        genre: 'Lo-Fi',
        mood: 'Chill',
        color: Colors.teal,
        icon: Icons.self_improvement,
      );
    }

    // 6. Flirty / Playful
    if (searchStr.contains('zalima') ||
        searchStr.contains('zaalima') ||
        searchStr.contains('flirty') ||
        searchStr.contains('playful') ||
        searchStr.contains('naughty') ||
        searchStr.contains('nakhre') ||
        searchStr.contains('ada') ||
        searchStr.contains('jhumka') ||
        searchStr.contains('chashma') ||
        searchStr.contains('gora') ||
        searchStr.contains('beauty') ||
        searchStr.contains('sweetheart') ||
        searchStr.contains('ishqbaaz') ||
        searchStr.contains('nazar') ||
        searchStr.contains('chori') ||
        searchStr.contains('ankh') ||
        searchStr.contains('ishara') ||
        searchStr.contains('dilbar')) {
      return const SongClassification(
        genre: 'Desi',
        mood: 'Flirty',
        color: Colors.green,
        icon: Icons.remove_red_eye,
      );
    }

    // 7. Happy / Feel Good
    if (searchStr.contains('happy') ||
        searchStr.contains('feel good') ||
        searchStr.contains('joy') ||
        searchStr.contains('smile') ||
        searchStr.contains('sunshine') ||
        searchStr.contains('zindagi') ||
        searchStr.contains('muskurana') ||
        searchStr.contains('kushi') ||
        searchStr.contains('masti') ||
        searchStr.contains('dosti') ||
        searchStr.contains('yaar') ||
        searchStr.contains('yaara') ||
        searchStr.contains('jeena') ||
        searchStr.contains('subah')) {
      return const SongClassification(
        genre: 'Pop',
        mood: 'Happy',
        color: Colors.yellow,
        icon: Icons.wb_sunny,
      );
    }

    // 8. Soothing / Quiet
    if (searchStr.contains('rataan lambiyan') ||
        searchStr.contains('raataan lambiyan') ||
        searchStr.contains('lullaby') ||
        searchStr.contains('stars') ||
        searchStr.contains('chanda') ||
        searchStr.contains('sleepy')) {
      return const SongClassification(
        genre: 'Pop',
        mood: 'Chill',
        color: Colors.blueGrey,
        icon: Icons.nightlight_round,
      );
    }

    // 9. Native metadata fallbacks
    if (nativeGenre != null && nativeGenre.isNotEmpty && nativeGenre != '<unknown>') {
      final cleanGenre = nativeGenre.toLowerCase();
      if (cleanGenre.contains('romantic') || cleanGenre.contains('love')) {
        return const SongClassification(
          genre: 'Romantic',
          mood: 'Romantic',
          color: Colors.pink,
          icon: Icons.favorite,
        );
      }
      if (cleanGenre.contains('sufi') || cleanGenre.contains('devotional') || cleanGenre.contains('spiritual')) {
        return const SongClassification(
          genre: 'Sufi',
          mood: 'Spiritual',
          color: Colors.brown,
          icon: Icons.auto_awesome,
        );
      }
      if (cleanGenre.contains('pop') || cleanGenre.contains('dance')) {
        return const SongClassification(
          genre: 'Pop',
          mood: 'Happy',
          color: Colors.yellow,
          icon: Icons.wb_sunny,
        );
      }
      if (cleanGenre.contains('rock') || cleanGenre.contains('metal')) {
        return const SongClassification(
          genre: 'Rock',
          mood: 'Energetic',
          color: Colors.blueGrey,
          icon: Icons.music_note,
        );
      }
      if (cleanGenre.contains('rap') || cleanGenre.contains('hip')) {
        return const SongClassification(
          genre: 'Hip-Hop',
          mood: 'Energetic',
          color: Colors.redAccent,
          icon: Icons.bolt,
        );
      }
      if (cleanGenre.contains('acoustic') || cleanGenre.contains('chill') || cleanGenre.contains('ambient')) {
        return const SongClassification(
          genre: 'Lo-Fi',
          mood: 'Chill',
          color: Colors.teal,
          icon: Icons.self_improvement,
        );
      }
      if (cleanGenre.contains('sad') || cleanGenre.contains('blues')) {
        return const SongClassification(
          genre: 'Alternative',
          mood: 'Dark',
          color: Colors.indigo,
          icon: Icons.heart_broken,
        );
      }

      return SongClassification(
        genre: _capitalize(nativeGenre),
        mood: 'Chill',
        color: _generateColorForTitle(title),
        icon: Icons.music_note,
      );
    }

    // Default Fallback
    return SongClassification(
      genre: 'Local Audio',
      mood: 'Chill',
      color: _generateColorForTitle(title),
      icon: Icons.music_note,
    );
  }

  static String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  static Color _generateColorForTitle(String title) {
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
