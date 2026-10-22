import 'package:flutter/foundation.dart';
import 'package:newsbeeper/models/news_model.dart';

import '../core/constants/app_messages.dart';
import '../core/enums/news_category.dart';
import '../core/exceptions/app_exception.dart';
import '../services/news_service.dart';
import 'app_config_provider.dart';

class NewsProvider extends ChangeNotifier {
  final NewsService _service;
  final AppConfigProvider _config;

  NewsProvider(this._service, this._config);

  final Map<NewsCategory?, List<NewsModel>> _articles = {};
  final Set<NewsCategory?> _loading = {};
  final Map<NewsCategory?, String> _errors = {};

  List<NewsModel> articlesFor(NewsCategory? category) =>
      _articles[category] ?? [];

  bool isLoading(NewsCategory? category) => _loading.contains(category);

  /// True once this category was loaded successfully at least one time.
  bool hasLoaded(NewsCategory? category) => _articles.containsKey(category);

  String? errorFor(NewsCategory? category) => _errors[category];

  /// Loads the news of [category].
  /// Already loaded categories are not loaded again unless [refresh] is true
  /// (pull to refresh / try again).
  Future<void> loadNews(NewsCategory? category, {bool refresh = false}) async {
    if (_loading.contains(category)) return;
    if (!refresh && _articles.containsKey(category)) return;

    _loading.add(category);
    _errors.remove(category);
    notifyListeners();

    try {
      _articles[category] = await _service.fetchTopHeadlines(
        baseUrl: _config.baseUrl,
        apiKey: _config.apiKey,
        category: category,
      );
    } on AppException catch (e) {
      _errors[category] = e.message;
    } catch (_) {
      _errors[category] = AppMessages.genericError;
    } finally {
      _loading.remove(category);
      notifyListeners();
    }
  }

  /// Call after sign out.
  void clear() {
    _articles.clear();
    _loading.clear();
    _errors.clear();
    notifyListeners();
  }
}