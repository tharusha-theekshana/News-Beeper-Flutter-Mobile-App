class NewsModel{
  final String title;
  final String description;
  final String content;
  final String sourceName;
  final String? author;
  final String url;
  final String? imageUrl;
  final DateTime? publishedAt;

  const NewsModel({
    required this.title,
    required this.description,
    required this.content,
    required this.sourceName,
    required this.url,
    this.author,
    this.imageUrl,
    this.publishedAt,
  });

  factory NewsModel.fromMap(Map<String, dynamic> map) {
    final source = map['source'];
    final sourceName =
    source is Map ? (source['name'] ?? '').toString() : '';

    var title = (map['title'] ?? '').toString();
    final suffix = ' - $sourceName';
    if (sourceName.isNotEmpty && title.endsWith(suffix)) {
      title = title.substring(0, title.length - suffix.length);
    }

    final content = (map['content'] ?? '')
        .toString()
        .replaceAll(RegExp(r'\s*\[\+\d+ chars\]\s*$'), '');

    return NewsModel(
      title: title,
      description: (map['description'] ?? '').toString(),
      content: content,
      sourceName: sourceName,
      author: _cleanOrNull(map['author']),
      url: (map['url'] ?? '').toString(),
      imageUrl: _cleanOrNull(map['urlToImage']),
      publishedAt: DateTime.tryParse((map['publishedAt'] ?? '').toString()),
    );
  }


  factory NewsModel.fromSavedMap(Map<String, dynamic> map) {
    return NewsModel(
      title: (map['title'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      content: (map['content'] ?? '').toString(),
      sourceName: (map['sourceName'] ?? '').toString(),
      author: _cleanOrNull(map['author']),
      url: (map['url'] ?? '').toString(),
      imageUrl: _cleanOrNull(map['imageUrl']),
      publishedAt: DateTime.tryParse((map['publishedAt'] ?? '').toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'content': content,
      'sourceName': sourceName,
      'author': author,
      'url': url,
      'imageUrl': imageUrl,
      'publishedAt': publishedAt?.toIso8601String(),
    };
  }

  // Remove empty news
  bool get isValid => title.isNotEmpty && title != '[Removed]';

  static String? _cleanOrNull(dynamic value) {
    final text = (value ?? '').toString().trim();
    return text.isEmpty ? null : text;
  }
}
