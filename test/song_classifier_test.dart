import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_playlist_app/services/song_classifier.dart';

void main() {
  group('SongClassifier Auto-Classification Tests', () {
    test('Classifies Sufi/Spiritual songs correctly', () {
      final res = SongClassifier.classify(
        title: 'Kun Faya Kun',
        artist: 'A.R. Rahman',
        album: 'Rockstar',
        nativeGenre: null,
        duration: const Duration(minutes: 7, seconds: 53),
      );

      expect(res.genre, equals('Sufi'));
      expect(res.mood, equals('Spiritual'));
      expect(res.color, equals(Colors.brown));
      expect(res.icon, equals(Icons.auto_awesome));
    });

    test('Classifies Romantic/Love songs correctly', () {
      final res = SongClassifier.classify(
        title: 'Kesariya',
        artist: 'Arijit Singh',
        album: 'Brahmastra',
        nativeGenre: null,
        duration: const Duration(minutes: 4, seconds: 28),
      );

      expect(res.genre, equals('Romantic'));
      expect(res.mood, equals('Romantic'));
      expect(res.color, equals(Colors.pink));
      expect(res.icon, equals(Icons.favorite));
    });

    test('Classifies Energetic/Dance/Fusion songs correctly', () {
      final res = SongClassifier.classify(
        title: 'Pasoori',
        artist: 'Ali Sethi & Shae Gill',
        album: 'Coke Studio',
        nativeGenre: null,
        duration: const Duration(minutes: 3, seconds: 44),
      );

      expect(res.genre, equals('Fusion'));
      expect(res.mood, equals('Energetic'));
      expect(res.color, equals(Colors.redAccent));
      expect(res.icon, equals(Icons.bolt));
    });

    test('Classifies Chill/Acoustic songs correctly', () {
      final res = SongClassifier.classify(
        title: 'Pee Loon',
        artist: 'Mohit Chauhan',
        album: 'Once Upon A Time in Mumbaai',
        nativeGenre: null,
        duration: const Duration(minutes: 4, seconds: 48),
      );

      expect(res.genre, equals('Lo-Fi'));
      expect(res.mood, equals('Chill'));
      expect(res.color, equals(Colors.teal));
      expect(res.icon, equals(Icons.self_improvement));
    });

    test('Classifies Dark/Alternative songs correctly', () {
      final res = SongClassifier.classify(
        title: 'Dil Se Re',
        artist: 'A.R. Rahman',
        album: 'Dil Se',
        nativeGenre: null,
        duration: const Duration(minutes: 6, seconds: 44),
      );

      expect(res.genre, equals('Alternative'));
      expect(res.mood, equals('Dark'));
      expect(res.color, equals(Colors.indigo));
      expect(res.icon, equals(Icons.heart_broken));
    });

    test('Classifies Flirty/Desi songs correctly', () {
      final res = SongClassifier.classify(
        title: 'Zalima',
        artist: 'Arijit Singh',
        album: 'Raees',
        nativeGenre: null,
        duration: const Duration(minutes: 4, seconds: 59),
      );

      expect(res.genre, equals('Desi'));
      expect(res.mood, equals('Flirty'));
      expect(res.color, equals(Colors.green));
      expect(res.icon, equals(Icons.remove_red_eye));
    });

    test('Uses native metadata genre fallback correctly', () {
      final res = SongClassifier.classify(
        title: 'Unknown Track',
        artist: 'Unknown Artist',
        album: 'Unknown Album',
        nativeGenre: 'Acoustic Pop',
        duration: const Duration(minutes: 3),
      );

      expect(res.genre, equals('Lo-Fi'));
      expect(res.mood, equals('Chill'));
      expect(res.color, equals(Colors.teal));
      expect(res.icon, equals(Icons.self_improvement));
    });
  });
}
