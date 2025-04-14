// models/music_track.dart
enum PlaybackSource { Local, YouTube }

class MusicTrack {
  final String id;
  final String title;
  final PlaybackSource source;
  final String sourceUrl;
  final String? thumbnailUrl;
  final String artist;

  MusicTrack({
    required this.id,
    required this.title,
    required this.source,
    required this.sourceUrl,
    this.thumbnailUrl,
    required this.artist,
  });
}

// models/webview_bookmark.dart
class WebViewBookmark {
  final String id;
  final String title;
  final String url;
  final DateTime createdAt;

  WebViewBookmark({
    required this.id,
    required this.title,
    required this.url,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WebViewBookmark.fromJson(Map<String, dynamic> json) {
    return WebViewBookmark(
      id: json['id'],
      title: json['title'],
      url: json['url'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}