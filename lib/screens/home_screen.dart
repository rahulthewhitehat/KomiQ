import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';
import 'manga_reader_screen.dart';
import 'music_player_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _pageTransitionController;
  late Animation<double> _pageAnimation;
  late AnimationController _navBarAnimationController;
  late Animation<double> _navBarAnimation;

  final List<Widget> _screens = [
    MangaReaderScreen(),
    MusicPlayerScreen(),
    SettingsScreen(),
  ];

  final List<String> _titles = ['Manga', 'Music', 'Settings'];
  final List<IconData> _icons = [
    Icons.menu_book_rounded,
    Icons.music_note_rounded,
    Icons.settings_rounded
  ];

  @override
  void initState() {
    super.initState();
    _pageTransitionController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    _pageAnimation = CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeInOut,
    );

    _navBarAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _navBarAnimation = CurvedAnimation(
      parent: _navBarAnimationController,
      curve: Curves.easeInOut,
    );

    _pageTransitionController.forward();
    _navBarAnimationController.forward();
  }

  @override
  void dispose() {
    _pageTransitionController.dispose();
    _navBarAnimationController.dispose();
    super.dispose();
  }

  void _changePage(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _pageTransitionController.reset();
      _selectedIndex = index;
    });
    _pageTransitionController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final platformHelper = PlatformHelper();
    final musicProvider = Provider.of<MusicProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Color(0xFFE80A11),
      brightness: theme.brightness,
    );

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? Color(0xFF121212)  // Dark background
          : Colors.white,      // Pure white in light mode
      body: Column(
        children: [
          // Main content area
          Expanded(
            child: Stack(
              children: [
                // Background with subtle pattern (only visible in light mode)
                if (theme.brightness == Brightness.light)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,  // Ensure white background
                        image: DecorationImage(
                          image: AssetImage('assets/images/subtle_pattern.png'),
                          repeat: ImageRepeat.repeat,
                          opacity: 0.05,  // Very subtle in light mode
                        ),
                      ),
                    ),
                  ),

                // Main content with animation
                FadeTransition(
                  opacity: _pageAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(_pageAnimation),
                    child: _screens[_selectedIndex],
                  ),
                ),

                // Mini music player overlay with glass morphism effect
                if (musicProvider.isMiniPlayerVisible)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 0, // Anchor to bottom of Stack
                    child: Transform.translate(
                      offset: Offset(0, -8), // Only move up by 8 pixels
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0, 1),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _navBarAnimation,
                          curve: Interval(0.3, 1.0),
                        )),
                        child: EnhancedMiniMusicPlayer(),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Navigation bar
          platformHelper.isTV ? _buildTVNavBar(colorScheme) : _buildMobileNavBar(colorScheme),
        ],
      )
    );
  }

  Widget _buildMobileNavBar(ColorScheme colorScheme) {
    final theme = Theme.of(context);

    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, 1),
        end: Offset.zero,
      ).animate(_navBarAnimation),
      child: Container(
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? Color(0xFF1E1E1E)  // Darker than background for contrast
              : Colors.white,      // Pure white to match background
          border: Border(
            top: BorderSide(
              color: colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
          boxShadow: [
            if (theme.brightness == Brightness.light)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                spreadRadius: 0,
                offset: Offset(0, -2),
              ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                _titles.length,
                    (index) => _buildNavItem(index, colorScheme),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, ColorScheme colorScheme) {
    final isSelected = _selectedIndex == index;
    final theme = Theme.of(context);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _changePage(index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _icons[index],
                color: isSelected
                    ? colorScheme.primary
                    : theme.brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.7)
                    : Colors.black.withOpacity(0.6),
                size: 24,
              ),
              SizedBox(height: 4),
              Text(
                _titles[index],
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected
                      ? colorScheme.primary
                      : theme.brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.7)
                      : Colors.black.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTVNavBar(ColorScheme colorScheme) {
    final theme = Theme.of(context);

    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, 1),
        end: Offset.zero,
      ).animate(_navBarAnimation),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? Color(0xFF1E1E1E)  // Darker than background for contrast
              : Colors.white,      // Pure white to match background
          border: Border(
            top: BorderSide(
              color: colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            _titles.length,
                (index) => _buildTVNavItem(index, colorScheme),
          ),
        ),
      ),
    );
  }

  Widget _buildTVNavItem(int index, ColorScheme colorScheme) {
    final isSelected = _selectedIndex == index;
    final theme = Theme.of(context);

    return Expanded(
      child: Focus(
        autofocus: index == 0,
        child: InkWell(
          onTap: () => _changePage(index),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            decoration: BoxDecoration(
              border: isSelected
                  ? Border(
                top: BorderSide(
                  color: colorScheme.primary,
                  width: 3,
                ),
              )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _icons[index],
                  color: isSelected
                      ? colorScheme.primary
                      : theme.brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.7)
                      : Colors.black.withOpacity(0.6),
                  size: 28,
                ),
                SizedBox(height: 6),
                Text(
                  _titles[index],
                  style: TextStyle(
                    color: isSelected
                        ? colorScheme.primary
                        : theme.brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.7)
                        : Colors.black.withOpacity(0.6),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// EnhancedMiniMusicPlayer

class EnhancedMiniMusicPlayer extends StatelessWidget {
  const EnhancedMiniMusicPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);
    final currentTrack = musicProvider.currentTrack;
    final theme = Theme.of(context);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Color(0xFFEE0000),
      brightness: theme.brightness,
    );

    if (currentTrack == null) return SizedBox();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: theme.brightness == Brightness.dark
                ? Colors.black.withOpacity(0.6)
                : Colors.white.withOpacity(0.6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 0,
                offset: Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress indicator
                StreamBuilder<Duration>(
                  stream: musicProvider.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final duration = musicProvider.totalDuration;
                    final progress = duration.inMilliseconds > 0
                        ? position.inMilliseconds / duration.inMilliseconds
                        : 0.0;

                    return Container(
                      height: 3,
                      margin: EdgeInsets.only(bottom: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white,
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        ),
                      ),
                    );
                  },
                ),

                Row(
                  children: [
                    // Album art
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            spreadRadius: 0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: currentTrack.thumbnailUrl != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          currentTrack.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    colorScheme.primaryContainer,
                                    colorScheme.primary,
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.music_note,
                                color: colorScheme.onPrimary,
                                size: 24,
                              ),
                            );
                          },
                        ),
                      )
                          : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme.primaryContainer,
                              colorScheme.primary,
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.music_note,
                          color: colorScheme.onPrimary,
                          size: 24,
                        ),
                      ),
                    ),

                    SizedBox(width: 12),

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
                              fontSize: 14,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Text(
                            currentTrack.artist,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withOpacity(0.7),
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
                        _buildControlButton(
                          icon: Icons.skip_previous,
                          onPressed: musicProvider.playPrevious,
                          colorScheme: colorScheme,
                        ),
                        SizedBox(width: 4),
                        _buildControlButton(
                          icon: musicProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                          onPressed: musicProvider.togglePlayPause,
                          isPlayPause: true,
                          colorScheme: colorScheme,
                        ),
                        SizedBox(width: 4),
                        _buildControlButton(
                          icon: Icons.skip_next,
                          onPressed: musicProvider.playNext,
                          colorScheme: colorScheme,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isPlayPause = false,
    required ColorScheme colorScheme,
  }) {
    return Container(
      width: isPlayPause ? 40 : 36,
      height: isPlayPause ? 40 : 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isPlayPause
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest.withOpacity(0.7),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: isPlayPause ? 22 : 18,
          color: isPlayPause
              ? colorScheme.onPrimary
              : colorScheme.onSurfaceVariant,
        ),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
      ),
    );
  }
}