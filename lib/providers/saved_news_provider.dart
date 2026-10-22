import 'package:flutter/foundation.dart';
import 'package:newsbeeper/models/news_model.dart';

import '../core/constants/app_messages.dart';
import '../core/exceptions/app_exception.dart';
import '../services/saved_news_service.dart';

/// PROVIDER layer: the news the signed in user has saved.
class SavedNewsProvider extends ChangeNotifier {
  final SavedNewsService _service;

  SavedNewsProvider(this._service);

  List<NewsModel> _articles = [];
  final Set<String> _busyUrls = {};
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;

  List<NewsModel> get articles => _articles;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get errorMessage => _errorMessage;

  bool isSaved(NewsModel article) =>
      _articles.any((saved) => saved.url == article.url);

  /// True while this article is being saved / removed (blocks double taps).
  bool isBusy(NewsModel article) => _busyUrls.contains(article.url);

  /// Loads the saved news from Firestore (only once unless [refresh]).
  Future<void> loadSaved({bool refresh = false}) async {
    if (_isLoading) return;
    if (_hasLoaded && !refresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _articles = await _service.fetchSavedArticles();
      _hasLoaded = true;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = AppMessages.savedNewsLoadFailed;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Saves the article, or removes it if it is already saved.
  /// Returns an error message, or null when everything went fine.
  Future<String?> toggleSave(NewsModel article) async {
    if (isBusy(article)) return null;

    _busyUrls.add(article.url);
    notifyListeners();

    try {
      if (isSaved(article)) {
        await _service.removeArticle(article);
        _articles.removeWhere((saved) => saved.url == article.url);
      } else {
        await _service.saveArticle(article);
        _articles.insert(0, article);
      }
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (_) {
      return AppMessages.savedNewsActionFailed;
    } finally {
      _busyUrls.remove(article.url);
      notifyListeners();
    }
  }

  /// Call after sign out.
  void clear() {
    _articles = [];
    _busyUrls.clear();
    _hasLoaded = false;
    _errorMessage = null;
    notifyListeners();
  }
}