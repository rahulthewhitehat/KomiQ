// providers/theme_provider.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'dart:io';
import '../models/models.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isSepia = false;

  ThemeMode get themeMode => _themeMode;
  bool get isSepia => _isSepia;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeValue = prefs.getString('themeMode') ?? 'system';
    _themeMode = _getThemeMode(themeModeValue);
    _isSepia = prefs.getBool('isSepia') ?? false;
    notifyListeners();
  }

  ThemeMode _getThemeMode(String value) {
    switch (value) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    String value = 'system';

    if (mode == ThemeMode.light) value = 'light';
    if (mode == ThemeMode.dark) value = 'dark';

    await prefs.setString('themeMode', value);
  }

  void toggleSepia() async {
    _isSepia = !_isSepia;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSepia', _isSepia);
  }

  ThemeData get lightTheme {
    if (_isSepia) {
      return ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: Color(0xFFF5ECD7),
        cardColor: Color(0xFFEEE0C0),
        canvasColor: Color(0xFFF5ECD7),
        brightness: Brightness.light,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF5C4B26)),
          bodyMedium: TextStyle(color: Color(0xFF5C4B26)),
        ),
      );
    }

    return ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.light,
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Color(0xFF121212),
      cardColor: Color(0xFF1E1E1E),
    );
  }
}

// enum PlaybackSource { Local, YouTube }
enum LoopMode { Off, One, All }

class MusicProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final YoutubeExplode _youtubeExplode = YoutubeExplode();

  final List<MusicTrack> _playlist = [];
  int _currentIndex = -1;
  bool _isPlaying = false;
  bool _isMiniPlayerVisible = false;
  LoopMode _loopMode = LoopMode.Off;
  bool _isShuffled = false;
  List<int> _shuffledIndices = [];

  // Getters
  List<MusicTrack> get playlist => _playlist;
  MusicTrack? get currentTrack => _currentIndex >= 0 && _currentIndex < _playlist.length ? _playlist[_currentIndex] : null;
  bool get isPlaying => _isPlaying;
  bool get isMiniPlayerVisible => _isMiniPlayerVisible;
  LoopMode get loopMode => _loopMode;
  bool get isShuffled => _isShuffled;
  Duration get currentPosition => _audioPlayer.position;
  Duration get totalDuration => _audioPlayer.duration ?? Duration.zero;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  MusicProvider() {
    _initAudioPlayer();
    _loadPlaylistFromStorage();
  }

  MusicTrack? getCurrentIndex()  {
   return  currentTrack;
  }

  void _initAudioPlayer() {
    _audioPlayer.playerStateStream.listen((playerState) {
      _isPlaying = playerState.playing;

      // Auto-play next track when current one completes
      if (playerState.processingState == ProcessingState.completed) {
        if (_loopMode == LoopMode.One) {
          _audioPlayer.seek(Duration.zero);
          _audioPlayer.play();
        } else if (_currentIndex < _playlist.length - 1 || _loopMode == LoopMode.All) {
          playNext();
        }
      }

      notifyListeners();
    });
  }

  Future<void> _loadPlaylistFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playlistJson = prefs.getString('playlist');

      if (playlistJson != null) {
        final List<dynamic> decoded = jsonDecode(playlistJson);

        _playlist.clear();
        for (var trackJson in decoded) {
          _playlist.add(MusicTrack(
            id: trackJson['id'],
            title: trackJson['title'],
            source: trackJson['source'] == 'Local'
                ? PlaybackSource.Local
                : PlaybackSource.YouTube,
            sourceUrl: trackJson['sourceUrl'],
            thumbnailUrl: trackJson['thumbnailUrl'],
            artist: trackJson['artist'],
          ));
        }

        // Restore last played index if available
        _currentIndex = prefs.getInt('lastPlayedIndex') ?? -1;

        notifyListeners();
      }
    } catch (e) {
      print('Error loading playlist from storage: $e');
    }
  }

  Future<void> _savePlaylistToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final List<Map<String, dynamic>> playlistMap = _playlist.map((track) => {
        'id': track.id,
        'title': track.title,
        'source': track.source == PlaybackSource.Local ? 'Local' : 'YouTube',
        'sourceUrl': track.sourceUrl,
        'thumbnailUrl': track.thumbnailUrl,
        'artist': track.artist,
      }).toList();

      await prefs.setString('playlist', jsonEncode(playlistMap));
      await prefs.setInt('lastPlayedIndex', _currentIndex);
    } catch (e) {
      print('Error saving playlist to storage: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _youtubeExplode.close();
    super.dispose();
  }

  // Add local audio file
  Future<void> addLocalTrack(File file) async {
    final fileName = file.path.split('/').last;
    final track = MusicTrack(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: fileName.replaceAll(RegExp(r'\.(mp3|wav|m4a|aac|ogg)$'), ''),
      source: PlaybackSource.Local,
      sourceUrl: file.path,
      thumbnailUrl: null,
      artist: 'Unknown',
    );

    _playlist.add(track);
    await _savePlaylistToStorage(); // Add this line
    notifyListeners();


    if (_playlist.length == 1) {
      _currentIndex = 0;
      await _loadCurrentTrack();
    }
  }

  // Add YouTube track
  Future<void> addYouTubeTrack(String youtubeUrl) async {
    try {
      final video = await _youtubeExplode.videos.get(youtubeUrl);

      final track = MusicTrack(
        id: video.id.value,
        title: video.title,
        source: PlaybackSource.YouTube,
        sourceUrl: youtubeUrl,
        thumbnailUrl: video.thumbnails.highResUrl,
        artist: video.author,
      );

      _playlist.add(track);
      await _savePlaylistToStorage(); // Add this line
      notifyListeners();

      if (_playlist.length == 1) {
        _currentIndex = 0;
        await _loadCurrentTrack();
      }
    } catch (e) {
      print('Error adding YouTube track: $e');
    }
  }

  // Load and prepare the current track for playback
  Future<void> _loadCurrentTrack() async {
    if (_currentIndex < 0 || _currentIndex >= _playlist.length) return;

    final track = _playlist[_currentIndex];
    try {
      if (track.source == PlaybackSource.Local) {
        await _audioPlayer.setFilePath(track.sourceUrl);
      } else if (track.source == PlaybackSource.YouTube) {
        final manifest = await _youtubeExplode.videos.streamsClient.getManifest(track.sourceUrl);
        final audioStream = manifest.audioOnly.withHighestBitrate();
        final audioStreamUrl = audioStream.url.toString();
        await _audioPlayer.setUrl(audioStreamUrl);
      }
    } catch (e) {
      print('Error loading track: $e');
    }
  }

  // Playback controls
  Future<void> play() async {
    if (_currentIndex < 0 && _playlist.isNotEmpty) {
      _currentIndex = 0;
      await _loadCurrentTrack();
    }

    await _audioPlayer.play();
    _isPlaying = true;
    _isMiniPlayerVisible = true;
    notifyListeners();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> playTrack(int index) async {
    if (index < 0 || index >= _playlist.length) return;

    _currentIndex = index;
    await _savePlaylistToStorage(); // Add this line
    await _loadCurrentTrack();
    await play();
  }

  Future<void> playNext() async {
    if (_playlist.isEmpty) return;

    if (_isShuffled) {
      // Find the current position in the shuffled list
      int currentShuffledIndex = _shuffledIndices.indexOf(_currentIndex);
      int nextShuffledIndex = (currentShuffledIndex + 1) % _shuffledIndices.length;
      _currentIndex = _shuffledIndices[nextShuffledIndex];
    } else {
      // Normal sequential playback
      if (_currentIndex < _playlist.length - 1) {
        _currentIndex++;
      } else if (_loopMode == LoopMode.All) {
        _currentIndex = 0;
      } else {
        return;
      }
    }

    await _loadCurrentTrack();
    if (_isPlaying) {
      await play();
    }
  }

  Future<void> playPrevious() async {
    if (_playlist.isEmpty) return;

    // If we're more than 3 seconds into the song, restart it instead of going to previous
    if (_audioPlayer.position.inSeconds > 3) {
      await _audioPlayer.seek(Duration.zero);
      if (_isPlaying) {
        await play();
      }
      return;
    }

    if (_isShuffled) {
      // Find the current position in the shuffled list
      int currentShuffledIndex = _shuffledIndices.indexOf(_currentIndex);
      int prevShuffledIndex = (currentShuffledIndex - 1 + _shuffledIndices.length) % _shuffledIndices.length;
      _currentIndex = _shuffledIndices[prevShuffledIndex];
    } else {
      // Normal sequential playback
      if (_currentIndex > 0) {
        _currentIndex--;
      } else if (_loopMode == LoopMode.All) {
        _currentIndex = _playlist.length - 1;
      } else {
        return;
      }
    }

    await _loadCurrentTrack();
    if (_isPlaying) {
      await play();
    }
  }

  // Seek within the current track
  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
    notifyListeners();
  }

  // Loop mode control
  void cycleLoopMode() {
    switch (_loopMode) {
      case LoopMode.Off:
        _loopMode = LoopMode.One;
        break;
      case LoopMode.One:
        _loopMode = LoopMode.All;
        break;
      case LoopMode.All:
        _loopMode = LoopMode.Off;
        break;
    }

    notifyListeners();
  }

  // Shuffle control
  void toggleShuffle() {
    _isShuffled = !_isShuffled;

    if (_isShuffled) {
      // Create a shuffled list of indices
      _shuffledIndices = List.generate(_playlist.length, (index) => index)..shuffle();

      // Make sure current track remains current after shuffle
      if (_currentIndex >= 0) {
        int currentIndex = _shuffledIndices.indexOf(_currentIndex);
        if (currentIndex != 0) {
          // Swap current track to first position
          int temp = _shuffledIndices[0];
          _shuffledIndices[0] = _currentIndex;
          _shuffledIndices[currentIndex] = temp;
        }
      }
    }

    notifyListeners();
  }

  // Remove track from playlist
  void removeTrack(int index) {
    if (index < 0 || index >= _playlist.length) return;

    bool wasPlaying = _isPlaying;

    // If removing the current track
    if (index == _currentIndex) {
      _audioPlayer.stop();

      if (_playlist.length > 1) {
        // If there are more tracks, play the next one
        _playlist.removeAt(index);

        // Adjust current index
        if (_currentIndex >= _playlist.length) {
          _currentIndex = 0;
        }

        _loadCurrentTrack().then((_) {
          if (wasPlaying) play();
        });
      } else {
        // If this was the only track
        _playlist.removeAt(index);
        _currentIndex = -1;
        _isPlaying = false;
        _isMiniPlayerVisible = false;
      }
    } else {
      // Removing a track that's not currently playing
      _playlist.removeAt(index);

      // Adjust current index if needed
      if (index < _currentIndex) {
        _currentIndex--;
      }
    }

    // Update shuffled indices if needed
    if (_isShuffled) {
      _shuffledIndices = List.generate(_playlist.length, (index) => index)..shuffle();
    }

    _savePlaylistToStorage(); // Add this line
    notifyListeners();
  }

  // Toggle mini player visibility
  void toggleMiniPlayer() {
    _isMiniPlayerVisible = !_isMiniPlayerVisible;
    notifyListeners();
  }

  void showMiniPlayer() {
    _isMiniPlayerVisible = true;
    notifyListeners();
  }

  void hideMiniPlayer() {
    _isMiniPlayerVisible = false;
    notifyListeners();
  }
}

class ScrollProvider with ChangeNotifier {
  bool _isAutoScrollEnabled = false;
  double _scrollSpeed = 2.0; // pixels per frame

  bool get isAutoScrollEnabled => _isAutoScrollEnabled;
  double get scrollSpeed => _scrollSpeed;

  ScrollProvider() {
    _loadScrollPreferences();
  }

  Future<void> _loadScrollPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _scrollSpeed = prefs.getDouble('scrollSpeed') ?? 2.0;
    notifyListeners();
  }

  void toggleAutoScroll() {
    _isAutoScrollEnabled = !_isAutoScrollEnabled;
    notifyListeners();
  }

  void setScrollSpeed(double speed) async {
    _scrollSpeed = speed;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('scrollSpeed', speed);

    notifyListeners();
  }
}