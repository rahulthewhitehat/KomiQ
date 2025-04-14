import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readit/providers/theme_provider.dart';
import 'package:readit/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<Color?> _backgroundColorAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
        ));

        _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
      ),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _backgroundColorAnimation = ColorTween(
      begin: Colors.white,
      end: const Color(0xFF121212),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();

    // Simulate some loading process
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final isSepia = themeProvider.isSepia;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: isDarkMode
              ? _backgroundColorAnimation.value
              : isSepia
              ? const Color(0xFFF5ECD7)
              : Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with animations
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: _buildLogo(isDarkMode, isSepia),
                ),

                const SizedBox(height: 30),

                // "KomiQ" text with slide animation
                SlideTransition(
                  position: _textSlideAnimation,
                  child: Text(
                    'KomiQ',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? Colors.white
                          : isSepia
                          ? const Color(0xFF5C4B26)
                          : const Color(0xFFEE0000),
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: isDarkMode
                              ? Colors.black.withOpacity(0.5)
                              : Colors.grey.withOpacity(0.5),
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Loading indicator
                _buildLoadingIndicator(isDarkMode, isSepia),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogo(bool isDarkMode, bool isSepia) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDarkMode
            ? Colors.black.withOpacity(0.2)
            : isSepia
            ? const Color(0xFFEEE0C0)
            : Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.5)
                : isSepia
                ? Colors.brown.withOpacity(0.3)
                : Colors.grey.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isSepia
              ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF8B5A2B),
              const Color(0xFFCD853F),
            ],
          )
              : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [const Color(0xFFE80A11), const Color(0xFF8E0E00)]
                : [const Color(0xFFE80A11), const Color(0xFFFF6B6B)],
          ),
        ),
        child: Center(
          // Replace with your actual logo asset
          child: Image.asset(
            'assets/images/logo.png', // Update with your actual path
            width: 80,
            height: 80,
           // color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(bool isDarkMode, bool isSepia) {
    return SizedBox(
      width: 200,
      child: LinearProgressIndicator(
        backgroundColor: isDarkMode
            ? Colors.grey[800]
            : isSepia
            ? const Color(0xFFD2B48C)
            : Colors.grey[200],
        valueColor: AlwaysStoppedAnimation<Color>(
          isDarkMode
              ? const Color(0xFFE80A11)
              : isSepia
              ? const Color(0xFF8B5A2B)
              : const Color(0xFFE80A11),
        ),
        minHeight: 4,
      ),
    );
  }
}