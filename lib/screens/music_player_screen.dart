import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../widgets/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class MusicPlayerScreen extends StatelessWidget {
  const MusicPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);
    final platformHelper = PlatformHelper();
    final theme = Theme.of(context);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Color(0xFFEE0000),
      brightness: theme.brightness,
    );

    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? Color(0xFF121212)
          : Colors.white,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.headphones,
              color: colorScheme.primary,
              size: isSmallScreen ? 18 : 22,
            ),
            SizedBox(width: 8),
            Text(
              'Music Player',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
                fontSize: isSmallScreen ? 18 : 20,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: theme.brightness == Brightness.dark
            ? Color(0xFF1E1E1E).withOpacity(0.95)
            : Colors.white.withOpacity(0.95),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_rounded,
              color: colorScheme.primary,
              size: isSmallScreen ? 22 : 24,
            ),
            onPressed: () => _showAddMusicOptions(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (musicProvider.currentTrack != null)
            // Compact music controls
              Container(
                height: screenSize.height * 0.22, // Responsive height
                margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primaryContainer,
                      colorScheme.primary.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: MusicControls(),
              )
            else
            // Placeholder height when no track is playing
              SizedBox(height: 16),

            // Playlist with modern card design
            Expanded(
              child: Container(
                margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? Color(0xFF1E1E1E)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: musicProvider.playlist.isEmpty
                      ? _buildEmptyPlaylist(context, platformHelper, colorScheme, isSmallScreen)
                      : _buildPlaylist(context, musicProvider, platformHelper, colorScheme, isSmallScreen),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPlaylist(BuildContext context, PlatformHelper platformHelper, ColorScheme colorScheme, bool isSmallScreen) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.music_note,
                size: platformHelper.isTV ? 60 : 40,
                color: colorScheme.primary,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'No music tracks added yet',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddMusicOptions(context),
              icon: Icon(Icons.add, size: isSmallScreen ? 18 : 20, color: Colors.black,),
              label: Text('Add Music', style: TextStyle(fontSize: isSmallScreen ? 14 : 16)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylist(BuildContext context, MusicProvider musicProvider, PlatformHelper platformHelper, ColorScheme colorScheme, bool isSmallScreen) {
    return ListView.builder(
      padding: EdgeInsets.only(top: 12, bottom: 16),
      itemCount: musicProvider.playlist.length,
      itemBuilder: (context, index) {
        final track = musicProvider.playlist[index];
        final isCurrentTrack = index == musicProvider.getCurrentIndex();

        return Dismissible(
          key: Key(track.id),
          background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            color: Colors.red,
            child: Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            musicProvider.removeTrack(index);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${track.title} removed'),
                behavior: SnackBarBehavior.floating,
                width: 280,
                backgroundColor: colorScheme.secondaryContainer,
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isCurrentTrack
                  ? colorScheme.primaryContainer.withOpacity(0.3)
                  : Theme.of(context).brightness == Brightness.dark
                  ? Color(0xFF2A2A2A)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: 8,
              ),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: isSmallScreen ? 40 : 48,
                  height: isSmallScreen ? 40 : 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary.withOpacity(0.7),
                        colorScheme.primaryContainer.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: track.thumbnailUrl != null
                      ? Image.network(
                    track.thumbnailUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.music_note,
                        color: colorScheme.onPrimary,
                        size: isSmallScreen ? 20 : 24,
                      );
                    },
                  )
                      : Icon(
                    Icons.music_note,
                    color: colorScheme.onPrimary,
                    size: isSmallScreen ? 20 : 24,
                  ),
                ),
              ),
              title: Text(
                track.title,
                style: TextStyle(
                  fontWeight: isCurrentTrack ? FontWeight.bold : FontWeight.w500,
                  fontSize: isSmallScreen ? 13 : 14,
                  color: isCurrentTrack ? colorScheme.primary : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                track.artist,
                style: TextStyle(
                  fontSize: isSmallScreen ? 11 : 12,
                  color: isCurrentTrack ? colorScheme.primary.withOpacity(0.7) : Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: isCurrentTrack && musicProvider.isPlaying
                  ? Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.equalizer,
                  color: colorScheme.primary,
                  size: isSmallScreen ? 16 : 18,
                ),
              )
                  : Icon(
                Icons.play_arrow,
                color: Colors.grey,
                size: isSmallScreen ? 20 : 22,
              ),
              onTap: () {
                musicProvider.playTrack(index);
              },
            ),
          ),
        );
      },
    );
  }

  void _showAddMusicOptions(BuildContext context) {
    final platformHelper = PlatformHelper();
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Color(0xFF1E1E1E)
                : Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Add Music",
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: platformHelper.isTV ? 32 : 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAddMusicOption(
                      context,
                      'Local Music',
                      Icons.folder_open,
                          () async {
                        Navigator.pop(context);
                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                          type: FileType.audio,
                          allowMultiple: true,
                        );

                        if (result != null) {
                          for (var file in result.files) {
                            if (file.path != null) {
                              await musicProvider.addLocalTrack(File(file.path!));
                            }
                          }
                        }
                      },
                      platformHelper,
                      colorScheme,
                      isSmallScreen,
                    ),
                    _buildAddMusicOption(
                      context,
                      'YouTube Link',
                      Icons.video_library,
                          () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (context) => YouTubeUrlDialog(),
                        );
                      },
                      platformHelper,
                      colorScheme,
                      isSmallScreen,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddMusicOption(
      BuildContext context,
      String label,
      IconData icon,
      VoidCallback onTap,
      PlatformHelper platformHelper,
      ColorScheme colorScheme,
      bool isSmallScreen,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: isSmallScreen ? 120 : 140,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary,
              colorScheme.primaryContainer,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.25),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isSmallScreen ? 32 : 36,
              color: colorScheme.onPrimary,
            ),
            SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
