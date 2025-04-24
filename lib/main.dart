import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotify-like Audio Player',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1DB954),          // Spotify green
          secondary: Color(0xFF1DB954),
          surface: Color(0xFF212121),          // Dark card background
          background: Color(0xFF121212),       // Darker app background
          onBackground: Color(0xFFB3B3B3),     // Spotify text color
          onSurface: Color(0xFFFFFFFF),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Color(0xFFB3B3B3)),
          bodyMedium: TextStyle(color: Color(0xFF9D9D9D)),
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Music Player'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isInitialized = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Future<void> _initializePlayer() async {
    try {
      await _player.setAsset('assets/sounds/music.mp3');
      _isInitialized = true;

      // Get duration after initialization
      _duration = _player.duration ?? Duration.zero;
      setState(() {});

      // Listen for playback state changes
      _player.playerStateStream.listen((playerState) {
        final playing = playerState.playing;
        if (playing != _isPlaying) {
          setState(() {
            _isPlaying = playing;
          });
        }
      });

      // Listen for completion to reset state
      _player.processingStateStream.listen((state) {
        if (state == ProcessingState.completed) {
          setState(() {
            _isPlaying = false;
            _position = Duration.zero;
          });
        }
      });

      // Listen for position changes
      _player.positionStream.listen((position) {
        if (!_isDragging) {
          setState(() {
            _position = position;
          });
        }
      });

      // Get duration again since it might not be available initially
      _player.durationStream.listen((newDuration) {
        setState(() {
          _duration = newDuration ?? Duration.zero;
        });
      });
    } catch (e) {
      debugPrint("Error initializing player: $e");
    }
  }

  void _playSound() async {
    if (!_isInitialized) {
      await _initializePlayer();
    }

    if (_isPlaying) {
      // If already playing, restart from beginning
      await _player.seek(Duration.zero);
    } else {
      await _player.play();
    }
    _incrementCounter();
  }

  void _togglePlayPause() async {
    if (!_isInitialized) {
      await _initializePlayer();
      await _player.play();
      _incrementCounter();
      return;
    }

    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
      _incrementCounter();
    }
  }

  void _seekPosition(double value) {
    if (!_isInitialized) return;

    final newPosition = Duration(milliseconds: value.toInt());

    setState(() {
      _position = newPosition;
    });

    _player.seek(newPosition);
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF191414).withOpacity(0.8),  // Spotify black
              const Color(0xFF121212),                   // Pure black
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                      onPressed: () {},
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'NOW PLAYING',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // Album art
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.music_note,
                        size: 120,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),

              // Track info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Music Track Title',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Artist Name',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.repeat_one,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Played $_counter times',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        thumbColor: Colors.white,
                        activeTrackColor: Theme.of(context).colorScheme.primary,
                        inactiveTrackColor: Colors.grey[800],
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                      ),
                      child: Slider(
                        min: 0,
                        max: _duration.inMilliseconds.toDouble() == 0 ? 1 : _duration.inMilliseconds.toDouble(),
                        value: _position.inMilliseconds.toDouble().clamp(
                            0,
                            _duration.inMilliseconds.toDouble() == 0 ? 1 : _duration.inMilliseconds.toDouble()
                        ),
                        onChanged: (value) {
                          setState(() {
                            _isDragging = true;
                            _position = Duration(milliseconds: value.toInt());
                          });
                        },
                        onChangeStart: (_) {
                          setState(() {
                            _isDragging = true;
                          });
                        },
                        onChangeEnd: (value) {
                          setState(() {
                            _isDragging = false;
                          });
                          _seekPosition(value);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_position),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onBackground,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _formatDuration(_duration),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onBackground,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Controls
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.shuffle,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.skip_previous,
                        color: Colors.white,
                        size: 36,
                      ),
                      onPressed: () {},
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      child: IconButton(
                        iconSize: 40,
                        padding: const EdgeInsets.all(8),
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ),
                        onPressed: _togglePlayPause,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.skip_next,
                        color: Colors.white,
                        size: 36,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.repeat,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // Bottom player bar (optional)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.replay,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: _playSound,
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      icon: const Icon(
                        Icons.playlist_play,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}