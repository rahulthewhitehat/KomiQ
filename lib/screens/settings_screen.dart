import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readit/about_screen.dart';
import '../providers/scroll_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final scrollProvider = Provider.of<ScrollProvider>(context);
    final platformHelper = PlatformHelper();
    final theme = Theme.of(context);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Color(0xFFEE0000),
      brightness: theme.brightness,
    );

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? Color(0xFF121212)
          : Colors.white,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.settings,
              color: colorScheme.primary,
            ),
            SizedBox(width: 8),
            Text(
              'Settings',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: theme.brightness == Brightness.dark
            ? Color(0xFF1E1E1E).withOpacity(0.95)
            : Colors.white.withOpacity(0.95),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(platformHelper.isTV ? 24 : 16),
          children: [
            // App Theme Section
            _buildSectionHeader('App Theme', context, platformHelper, colorScheme),
            _buildThemeSelector(context, themeProvider, platformHelper, colorScheme),

            SizedBox(height: platformHelper.isTV ? 32 : 24),

            // Auto Scroll Section
            _buildSectionHeader('Auto Scroll Settings', context, platformHelper, colorScheme),
            _buildScrollSpeedSlider(context, scrollProvider, platformHelper, colorScheme),

            SizedBox(height: platformHelper.isTV ? 32 : 24),

            // About Section
            _buildSectionHeader('About', context, platformHelper, colorScheme),
            InkWell(
              onTap: () {
                // Navigate to the about page when tapped
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => AboutScreen()),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: platformHelper.isTV ? 16 : 8),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? Color(0xFF2A2A2A)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(platformHelper.isTV ? 24 : 16),
                  title: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme.primary,
                              colorScheme.primaryContainer,
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.book,
                          color: colorScheme.onPrimary,
                          size: platformHelper.isTV ? 28 : 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'KomiQ',
                        style: TextStyle(
                          fontSize: platformHelper.isTV ? 22 : 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: EdgeInsets.only(top: 16, left: platformHelper.isTV ? 10 : 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            fontSize: platformHelper.isTV ? 18 : 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'A manga reader app with music playback and auto-scrolling functionality developed by Rahul Babu M P.',
                          style: TextStyle(
                            fontSize: platformHelper.isTV ? 16 : 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context, PlatformHelper platformHelper, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.only(
        left: platformHelper.isTV ? 16 : 8,
        bottom: platformHelper.isTV ? 16 : 12,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: platformHelper.isTV ? 24 : 20,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: platformHelper.isTV ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector(
      BuildContext context,
      ThemeProvider themeProvider,
      PlatformHelper platformHelper,
      ColorScheme colorScheme,
      ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: platformHelper.isTV ? 16 : 6,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Changed to center
        children: [
          _buildThemeOption(
            context,
            'Light',
            Icons.light_mode,
            themeProvider.themeMode == ThemeMode.light,
                () => themeProvider.setThemeMode(ThemeMode.light),
            platformHelper,
            colorScheme,
          ),
          SizedBox(width: 12), // Add spacing between items
          _buildThemeOption(
            context,
            'Dark',
            Icons.dark_mode,
            themeProvider.themeMode == ThemeMode.dark,
                () => themeProvider.setThemeMode(ThemeMode.dark),
            platformHelper,
            colorScheme,
          ),
          SizedBox(width: 12), // Add spacing between items
          _buildThemeOption(
            context,
            'System',
            Icons.settings_suggest,
            themeProvider.themeMode == ThemeMode.system,
                () => themeProvider.setThemeMode(ThemeMode.system),
            platformHelper,
            colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
      BuildContext context,
      String label,
      IconData icon,
      bool isSelected,
      VoidCallback onTap,
      PlatformHelper platformHelper,
      ColorScheme colorScheme,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: platformHelper.isTV ? 100 : 80,
        padding: EdgeInsets.all(platformHelper.isTV ? 14 : 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isSelected
              ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary,
              colorScheme.primaryContainer,
            ],
          )
              : null,
          color: !isSelected
              ? Theme.of(context).brightness == Brightness.dark
              ? Color(0xFF2A2A2A)
              : Colors.grey.shade100
              : null,
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? colorScheme.primary.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
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
              size: platformHelper.isTV ? 40 : 26,
              color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
            ),
            SizedBox(height: platformHelper.isTV ? 12 : 14),
            Text(
              label,
              style: TextStyle(
                fontSize: platformHelper.isTV ? 18 : 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? colorScheme.onPrimary : null,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildScrollSpeedSlider(
      BuildContext context,
      ScrollProvider scrollProvider,
      PlatformHelper platformHelper,
      ColorScheme colorScheme,
      ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: platformHelper.isTV ? 16 : 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Color(0xFF2A2A2A)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.speed,
                  color: colorScheme.primary,
                  size: platformHelper.isTV ? 28 : 20,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Scroll Speed',
                      style: TextStyle(
                        fontSize: platformHelper.isTV ? 20 : 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        '${scrollProvider.scrollSpeed.toStringAsFixed(1)} px/frame',
                        style: TextStyle(
                          fontSize: platformHelper.isTV ? 18 : 14,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: platformHelper.isTV ? 24 : 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: colorScheme.primary,
              inactiveTrackColor: colorScheme.primaryContainer.withOpacity(0.3),
              thumbColor: colorScheme.primary,
              overlayColor: colorScheme.primary.withOpacity(0.2),
              trackHeight: platformHelper.isTV ? 8 : 4,
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: platformHelper.isTV ? 12 : 8,
              ),
            ),
            child: Slider(
              value: scrollProvider.scrollSpeed,
              min: 0.5,
              max: 10.0,
              divisions: 19,
              label: scrollProvider.scrollSpeed.toStringAsFixed(1),
              onChanged: (value) {
                scrollProvider.setScrollSpeed(value);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Slow',
                  style: TextStyle(
                    fontSize: platformHelper.isTV ? 16 : 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Fast',
                  style: TextStyle(
                    fontSize: platformHelper.isTV ? 16 : 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}