# Music Playlist App

A modern Flutter music playlist demo app with multi-tab navigation, playlist management, song discovery, queue controls, animated player UI, and synchronized mock lyrics.

This project currently focuses on rich UI/UX patterns and local in-memory state. It does not use a backend or real audio streaming yet.

## Features

### Core Experience

- 5-tab app shell: Home, Songs, Playlists, Player, Settings
- Material 3 theming with light/dark support
- Dynamic seed color updates based on the selected song
- Mini player docked above bottom navigation

### Songs

- Search songs by title, artist, album, and genre
- Genre filter chips
- Mood filter chips (from Home)
- Favorites-only filter
- Sorting by Title, Artist, Year, and Duration
- Song actions: favorite toggle, add to playlist, details bottom sheet

### Playlists

- Playlist grid with summary card
- Create playlist dialog
- Edit playlist dialog
- Delete playlist
- Search playlists by name/description
- Playlist detail sheet with stats and quick play
- Add song to selected playlist from song actions

### Player

- Full “Now Playing” card with animated visuals
- Play/Pause, Next, Previous controls
- Shuffle and Loop toggles
- Volume slider
- Queue preview section
- Lyrics view with highlighted active line (mock synchronized behavior)
- Audio settings bottom sheet (equalizer-style mock controls)

### Settings and Utilities

- Preference toggles (loop, shuffle, favorite filter)
- Sleep timer (Off, 15, 30, 60 minutes)
- App tips dialog
- Informational sheets for quick actions/help

## Tech Stack

- Flutter (Material 3)
- Dart SDK: ^3.11.3
- No external state-management package (setState-based local state)
- No backend or database integration yet

## Project Structure

Key files and folders:

- lib/main.dart: Main app UI and logic
- test/widget_test.dart: Flutter widget test scaffold
- pubspec.yaml: Dependencies, SDK constraints, project metadata
- android/, ios/, web/, windows/, linux/, macos/: Platform runners

## Getting Started

### Prerequisites

- Flutter SDK installed and available in PATH
- A configured device/emulator/simulator
- Dart SDK compatible with Flutter (project constraint: ^3.11.3)

Check setup:

    flutter doctor

### Installation

1. Clone the repository.
2. Open the project root.
3. Install dependencies:

   flutter pub get

### Run the App

List available devices:

    flutter devices

Run on your selected device:

    flutter run

Run on web:

    flutter run -d chrome

### Build

Android APK:

    flutter build apk --release

Android App Bundle:

    flutter build appbundle --release

iOS (macOS only):

    flutter build ios --release

Web:

    flutter build web

Windows:

    flutter build windows

Linux:

    flutter build linux

macOS:

    flutter build macos

### Testing

Run tests:

    flutter test

## Current Data Model

The app uses in-memory mock data:

- Song
  - id, title, artist, album, duration, genre, year, rating, icon, color, mood, lyrics
- Playlist
  - id, name, description, songIds, createdAt, color, icon, isPublic
- LyricLine
  - timestamp, text

Because data is in memory, changes reset when the app restarts.

## Known Limitations

- No real audio playback engine (UI simulation only)
- No persistent storage (SQLite/Hive/SharedPreferences not integrated)
- No authentication or cloud sync
- No background playback/media notifications
- No network-based song catalog

## Roadmap Ideas

- Integrate real audio playback (just_audio or audioplayers)
- Persist playlists and user preferences locally
- Add artist/album detail screens
- Add queue reorder and drag-and-drop interactions
- Add offline caching strategy and download manager
- Add backend sync and user accounts

## Contributing

Contributions are welcome.

1. Fork the repo
2. Create a feature branch
3. Commit your changes
4. Open a pull request
