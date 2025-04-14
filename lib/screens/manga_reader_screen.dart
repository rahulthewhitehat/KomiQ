import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/scroll_provider.dart';
import '../widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';

class MangaReaderScreen extends StatefulWidget {
  const MangaReaderScreen({super.key});

  @override
  _MangaReaderScreenState createState() => _MangaReaderScreenState();
}

class _MangaReaderScreenState extends State<MangaReaderScreen> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final String baseUrl = 'https://weebcentral.com/';
  late WebViewController _webViewController;
  bool _isFullscreen = false;
  bool _isLoading = true;
  Timer? _autoScrollTimer;
  final FocusNode _webViewFocusNode = FocusNode();
  double _webViewOpacity = 0.0;
  bool _showScrollControls = false;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  bool _canGoBack = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
    _autoScrollTimer = Timer.periodic(Duration(milliseconds: 16), (_) {
      final scrollProvider = Provider.of<ScrollProvider>(context, listen: false);
      if (scrollProvider.isAutoScrollEnabled) {
        _executeAutoScroll(scrollProvider.scrollSpeed);
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _webViewFocusNode.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _executeAutoScroll(double speed) {
    _webViewController.runJavaScript('window.scrollBy(0, $speed);');
  }

  Future<void> _initWebView() async {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              setState(() {
                _isLoading = false;
                _webViewOpacity = 1.0;
              });
            }
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _webViewOpacity = 0.0;
            });
            _updateBackButtonState();
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
              _webViewOpacity = 1.0;
            });
            _updateBackButtonState();
          },
          onWebResourceError: (WebResourceError error) {
            //print('WebView error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            // You can add logic here to control navigation if needed
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(baseUrl))
      ..setBackgroundColor(const Color(0x00000000));

    _webViewController = controller;
  }

  Future<void> _updateBackButtonState() async {
    final canGoBack = await _webViewController.canGoBack();
    setState(() {
      _canGoBack = canGoBack;
    });
  }

  Future<bool> _handleBackPressed() async {
    final canGoBack = await _webViewController.canGoBack();
    if (canGoBack) {
      _webViewController.goBack();
      return false; // Don't close the app
    }
    return true; // Allow the app to handle back button (close app)
  }

  void _goToHomePage() {
    _webViewController.loadRequest(Uri.parse(baseUrl));
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    SystemChrome.setEnabledSystemUIMode(
      _isFullscreen ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  void _toggleScrollControls() {
    setState(() {
      _showScrollControls = !_showScrollControls;
      if (_showScrollControls) {
        _fabAnimationController.forward();
      } else {
        _fabAnimationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final platformHelper = PlatformHelper();
    final _ = Provider.of<ScrollProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Color(0xFFEE0000),
      brightness: theme.brightness,
    );

    return WillPopScope(
      onWillPop: _handleBackPressed,
      child: RawKeyboardListener(
        focusNode: _webViewFocusNode,
        onKey: (RawKeyEvent event) {
          if (platformHelper.isTV && event is RawKeyDownEvent) {
            _handleTVKeyNavigation(event);
          }
        },
        child: Scaffold(
          backgroundColor: theme.brightness == Brightness.dark
              ? Color(0xFF121212)
              : Colors.white,
          extendBodyBehindAppBar: false,
          appBar: _isFullscreen
              ? null
              : AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.book,
                  color: colorScheme.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'KomiQ',
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
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: _canGoBack ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.3),
              ),
              onPressed: _canGoBack
                  ? () async {
                await _webViewController.goBack();
                _updateBackButtonState();
              }
                  : null,
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.home_rounded,
                  color: colorScheme.primary,
                ),
                onPressed: _goToHomePage,
              ),
              IconButton(
                icon: Icon(
                  Icons.refresh_rounded,
                  color: colorScheme.primary,
                ),
                onPressed: () => _webViewController.reload(),
              ),
              IconButton(
                icon: Icon(
                  _isFullscreen
                      ? Icons.fullscreen_exit_rounded
                      : Icons.fullscreen_rounded,
                  color: colorScheme.primary,
                ),
                onPressed: _toggleFullscreen,
              ),
            ],
          ),
          body: Stack(
            children: [
              // WebView with fade animation
              AnimatedOpacity(
                opacity: _webViewOpacity,
                duration: Duration(milliseconds: 300),
                child: WebViewWidget(
                  controller: _webViewController,
                ),
              ),

              // Loading indicator with modern design
              if (_isLoading)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: theme.brightness == Brightness.dark
                      ? Colors.black.withOpacity(0.7)
                      : Colors.white.withOpacity(0.7),
                  child: Center(
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme.primaryContainer,
                              colorScheme.primary,
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colorScheme.onPrimary,
                                ),
                                strokeWidth: 4,
                              ),
                            ),
                            SizedBox(height: 24),
                            Text(
                              'Loading Manga...',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Auto-scroll controls
              if (_showScrollControls && !_isFullscreen && !_isLoading)
                Positioned(
                  bottom: 190,
                  right: 20,
                  child: ScaleTransition(
                    scale: _fabAnimation,
                    child: AutoScrollControls()
                  ),
                ),

              // FAB for scroll controls visibility
              if (!_isFullscreen && !_isLoading)
                Positioned(
                  bottom: 110,
                  right: 30,
                  child: FloatingActionButton(
                    onPressed: _toggleScrollControls,
                    backgroundColor: colorScheme.primary,
                    elevation: 8,
                    child: Icon(
                      _showScrollControls ? Icons.speed_outlined : Icons.speed,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),

              // Fullscreen exit button
              if (_isFullscreen)
                Positioned(
                  top: 24,
                  right: 24,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _toggleFullscreen,
                      borderRadius: BorderRadius.circular(40),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.7),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.fullscreen_exit_rounded,
                          color: colorScheme.onPrimaryContainer,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTVKeyNavigation(RawKeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _webViewController.scrollBy(0, 50);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _webViewController.scrollBy(0, -50);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _webViewController.scrollBy(50, 0);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _webViewController.scrollBy(-50, 0);
    } else if (event.logicalKey == LogicalKeyboardKey.select) {
      _webViewController.runJavaScript(
          'document.elementFromPoint(window.innerWidth/2, window.innerHeight/2).click();');
    }
  }

  @override
  bool get wantKeepAlive => true;
}