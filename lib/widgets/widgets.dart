// widgets/mini_music_player.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import '../providers/scroll_provider.dart';


class MiniMusicPlayer extends StatelessWidget {
  const MiniMusicPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);
    final platformHelper = PlatformHelper();
    final currentTrack = musicProvider.currentTrack;

    if (currentTrack == null) return SizedBox();

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: platformHelper.isTV ? 24 : 8,
        vertical: 8,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: platformHelper.isTV ? 24 : 16,
        vertical: platformHelper.isTV ? 12 : 8,
      ),
      decoration: BoxDecoration(
        color: Theme
            .of(context)
            .cardColor,
        borderRadius: BorderRadius.circular(platformHelper.isTV ? 16 : 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Track thumbnail/icon
          Container(
            width: platformHelper.isTV ? 64 : 40,
            height: platformHelper.isTV ? 64 : 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
            child: currentTrack.thumbnailUrl != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                currentTrack.thumbnailUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.music_note, color: Colors.grey.shade700);
                },
              ),
            )
                : Icon(Icons.music_note, color: Colors.grey.shade700),
          ),

          SizedBox(width: platformHelper.isTV ? 16 : 12),

          // Track info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentTrack.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: platformHelper.isTV ? 18 : 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  currentTrack.artist,
                  style: TextStyle(
                    fontSize: platformHelper.isTV ? 14 : 12,
                    color: Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Playback controls
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.skip_previous),
                iconSize: platformHelper.isTV ? 36 : 24,
                onPressed: () {
                  musicProvider.playPrevious();
                },
              ),
              IconButton(
                icon: Icon(
                  musicProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
                iconSize: platformHelper.isTV ? 36 : 24,
                onPressed: () {
                  musicProvider.togglePlayPause();
                },
              ),
              IconButton(
                icon: Icon(Icons.skip_next),
                iconSize: platformHelper.isTV ? 36 : 24,
                onPressed: () {
                  musicProvider.playNext();
                },
              ),
              IconButton(
                icon: Icon(Icons.close),
                iconSize: platformHelper.isTV ? 36 : 24,
                onPressed: () {
                  musicProvider.hideMiniPlayer();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MusicControls extends StatelessWidget {
  const MusicControls({super.key});

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);
    final platformHelper = PlatformHelper();
    final currentTrack = musicProvider.currentTrack;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final colorScheme = Theme.of(context).colorScheme;

    if (currentTrack == null) return SizedBox();

    return Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          // Album Art / Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: isSmallScreen ? 60 : 70,
              height: isSmallScreen ? 60 : 70,
              color: Colors.grey.shade800,
              child: currentTrack.thumbnailUrl != null
                  ? Image.network(
                currentTrack.thumbnailUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.music_note,
                    size: isSmallScreen ? 30 : 36,
                    color: Colors.white,
                  );
                },
              )
                  : Icon(
                Icons.music_note,
                size: isSmallScreen ? 30 : 36,
                color: Colors.white,
              ),
            ),
          ),

          SizedBox(width: 12),

          // Track Info and Controls
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Track Info
                Text(
                  currentTrack.title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Text(
                  currentTrack.artist,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 13,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 8),

                // Progress Indicator
                StreamBuilder<Duration>(
                  stream: musicProvider.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final duration = musicProvider.totalDuration;

                    return Column(
                      children: [
                        // Progress Slider
                        SliderTheme(
                          data: SliderThemeData(
                            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                            overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
                            trackHeight: 4,
                          ),
                          child: Slider(
                            value: math.min(position.inMilliseconds.toDouble(), duration.inMilliseconds.toDouble()),
                            max: duration.inMilliseconds > 0 ? duration.inMilliseconds.toDouble() : 1.0,
                            activeColor: Colors.white,
                            inactiveColor: Colors.white30,
                            onChanged: (value) {
                              musicProvider.seekTo(Duration(milliseconds: value.toInt()));
                            },
                          ),
                        ),

                        // Time indicators
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(position),
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 10 : 11,
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                _formatDuration(duration),
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 10 : 11,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // Playback Controls
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Play/Pause Button
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: IconButton(
                  icon: Icon(
                    musicProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: colorScheme.primary,
                  ),
                  iconSize: isSmallScreen ? 24 : 28,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: isSmallScreen ? 36 : 42,
                    minHeight: isSmallScreen ? 36 : 42,
                  ),
                  onPressed: () {
                    musicProvider.togglePlayPause();
                  },
                ),
              ),

              SizedBox(height: 8),

              // Loop Button
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white24,
                ),
                child: IconButton(
                  icon: Icon(
                    musicProvider.loopMode == LoopMode.One
                        ? Icons.repeat_one
                        : Icons.repeat,
                    color: musicProvider.loopMode != LoopMode.Off
                        ? Colors.white
                        : Colors.white70,
                  ),
                  iconSize: isSmallScreen ? 18 : 20,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: isSmallScreen ? 30 : 34,
                    minHeight: isSmallScreen ? 30 : 34,
                  ),
                  onPressed: () {
                    musicProvider.cycleLoopMode();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}

class AutoScrollControls extends StatelessWidget {
  const AutoScrollControls({super.key});

  @override
  Widget build(BuildContext context) {
    final scrollProvider = Provider.of<ScrollProvider>(context);
    final platformHelper = PlatformHelper();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: platformHelper.isTV ? 24 : 12,
        vertical: platformHelper.isTV ? 16 : 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(platformHelper.isTV ? 16 : 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Auto-scroll toggle
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Auto-Scroll',
                style: TextStyle(
                  fontSize: platformHelper.isTV ? 20 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: platformHelper.isTV ? 16 : 8),
              Switch(
                value: scrollProvider.isAutoScrollEnabled,
                onChanged: (value) {
                  scrollProvider.toggleAutoScroll();
                },
              ),
            ],
          ),

          SizedBox(height: platformHelper.isTV ? 16 : 8),

          // Speed control
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.speed,
                size: platformHelper.isTV ? 24 : 16,
              ),
              SizedBox(width: platformHelper.isTV ? 8 : 4),
              SizedBox(
                width: platformHelper.isTV ? 200 : 150,
                // widgets/auto_scroll_controls.dart (completion)
                child: Slider(
                  value: scrollProvider.scrollSpeed,
                  min: 0.5,
                  max: 10.0,
                  divisions: 19,
                  onChanged: (value) {
                    scrollProvider.setScrollSpeed(value);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class YouTubeUrlDialog extends StatefulWidget {
  const YouTubeUrlDialog({super.key});

  @override
  _YouTubeUrlDialogState createState() => _YouTubeUrlDialogState();
}

class _YouTubeUrlDialogState extends State<YouTubeUrlDialog> {
  final TextEditingController _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final platformHelper = PlatformHelper();

    return AlertDialog(
      title: Text(
        'Add YouTube Track',
        style: TextStyle(
          fontSize: platformHelper.isTV ? 24 : 20,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'YouTube URL',
                hintText: 'https://www.youtube.com/watch?v=...',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a YouTube URL';
                }

                // Simple YouTube URL validation
                if (!value.contains('youtube.com/') && !value.contains('youtu.be/')) {
                  return 'Please enter a valid YouTube URL';
                }

                return null;
              },
              autofocus: !platformHelper.isTV,
            ),
            if (_isProcessing)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text(
            'Cancel',
            style: TextStyle(
              fontSize: platformHelper.isTV ? 18 : 16,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          onPressed: _isProcessing
              ? null
              : () async {
            if (_formKey.currentState!.validate()) {
              setState(() {
                _isProcessing = true;
              });

              try {
                final musicProvider = Provider.of<MusicProvider>(context, listen: false);
                await musicProvider.addYouTubeTrack(_urlController.text.trim());
                Navigator.of(context).pop();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error adding YouTube track: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
                setState(() {
                  _isProcessing = false;
                });
              }
            }
          },
          child: Text(
            'Add',
            style: TextStyle(
              fontSize: platformHelper.isTV ? 18 : 16,
            ),
          ),
        ),
      ],
    );
  }
}



class PlatformHelper {
  bool _isTV = false;

  PlatformHelper() {
    _detectPlatform();
  }

  bool get isTV => _isTV;
  bool get isMobile => !_isTV;

  void _detectPlatform() {
    // Check for TV-specific characteristics
    // This is a simplified version; in a real app you'd want more robust detection
    try {
      // Check for Android TV using system properties
      const platform = MethodChannel('com.weebcentral.weebreader/platform');
      platform.invokeMethod<bool>('isAndroidTV').then((isTV) {
        print("TV Detected");
        _isTV = isTV ?? false;
      });
    } catch (e) {
      // Default to mobile if detection fails
      _isTV = false;
    }
    // For development purposes, you could use a flag to force TV mode
    _isTV = true; // Uncomment to test TV layout
  }
}