import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/theme_provider.dart';
import '../widgets/widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final _ = Provider.of<ThemeProvider>(context);
    final platformHelper = PlatformHelper();
    final theme = Theme.of(context);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFEE0000),
      brightness: theme.brightness,
    );

    final String appDescription =
        'Version 1.0.0\n\nKomiQ is a manga reader app with integrated music playback '
        'and auto-scrolling functionality. Designed for anime and manga enthusiasts, '
        'it provides a seamless reading experience with customizable settings.';

    final String developerDescription =
        'I am a student with a deep passion for technology and aspirations to become an ethical hacker. '
        'I have continuously challenged myself in cybersecurity, networking, and programming, reflecting my dedication in multiple achievements and certifications. '
        'KomiQ was created to combine my love for anime, manga, and technology into a single, enjoyable experience.';

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? const Color(0xFF121212)
          : Colors.white,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'About KomiQ',
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
            ? const Color(0xFF1E1E1E).withOpacity(0.95)
            : Colors.white.withOpacity(0.95),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(platformHelper.isTV ? 24 : 16),
          child: Column(
            children: [
              // App Info Card
              _buildAboutCard(
                context: context,
                colorScheme: colorScheme,
                platformHelper: platformHelper,
                icon: Icons.menu_book_rounded,
                title: 'About KomiQ',
                content: appDescription,
                isFirst: true,
              ),

              const SizedBox(height: 24),

              // Developer Info Card
              _buildAboutCard(
                context: context,
                colorScheme: colorScheme,
                platformHelper: platformHelper,
                icon: Icons.person_outline,
                title: 'About Developer',
                content: developerDescription,
                isFirst: false,
              ),

              const SizedBox(height: 24),

              // Contact Section
              _buildContactSection(
                context: context,
                colorScheme: colorScheme,
                platformHelper: platformHelper,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutCard({
    required BuildContext context,
    required ColorScheme colorScheme,
    required PlatformHelper platformHelper,
    required IconData icon,
    required String title,
    required String content,
    required bool isFirst,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2A2A2A)
          : Colors.grey.shade50,
      child: Padding(
        padding: EdgeInsets.all(platformHelper.isTV ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
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
                    icon,
                    color: colorScheme.onPrimary,
                    size: platformHelper.isTV ? 28 : 20,
                  ),
                ),
                const SizedBox(width: 16),
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
            const SizedBox(height: 16),
            Text(
              content,
              style: TextStyle(
                fontSize: platformHelper.isTV ? 18 : 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.grey.shade800,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection({
    required BuildContext context,
    required ColorScheme colorScheme,
    required PlatformHelper platformHelper,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2A2A2A)
          : Colors.grey.shade50,
      child: Padding(
        padding: EdgeInsets.all(platformHelper.isTV ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
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
                    Icons.contact_mail_outlined,
                    color: colorScheme.onPrimary,
                    size: platformHelper.isTV ? 28 : 20,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Contact',
                  style: TextStyle(
                    fontSize: platformHelper.isTV ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildContactItem(
              context: context,
              colorScheme: colorScheme,
              platformHelper: platformHelper,
              icon: Icons.email_outlined,
              text: 'rahulbabuoffl@gmail.com',
              onTap: () => _launchURL('mailto:rahulbabuoffl@gmail.com'),
            ),
            _buildContactItem(
              context: context,
              colorScheme: colorScheme,
              platformHelper: platformHelper,
              icon: Icons.phone_outlined,
              text: '+91 9514803391',
              onTap: () => _launchURL('tel:+919514803391'),
            ),
            _buildContactItem(
              context: context,
              colorScheme: colorScheme,
              platformHelper: platformHelper,
              icon: Icons.language_outlined,
              text: 'Visit Portfolio',
              onTap: () => _launchURL('https://rahulbabump.online'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required BuildContext context,
    required ColorScheme colorScheme,
    required PlatformHelper platformHelper,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: platformHelper.isTV ? 12 : 8,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: colorScheme.primary,
                size: platformHelper.isTV ? 24 : 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: platformHelper.isTV ? 18 : 14,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.grey.shade800,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: platformHelper.isTV ? 18 : 14,
              color: colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}