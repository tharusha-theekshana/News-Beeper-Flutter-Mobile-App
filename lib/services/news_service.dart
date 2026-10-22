import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:newsbeeper/models/news_model.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/app_messages.dart';
import '../core/enums/news_category.dart';
import '../core/exceptions/app_exception.dart';

class NewsService {
  final http.Client _client;

  NewsService({http.Client? client}) : _client = client ?? http.Client();

  /// Gets the top headlines.
  /// [category] null  -> all top headlines of the country
  /// [category] given -> only that category
  /// Throws [AppException] with a readable message when it fails.
  Future<List<NewsModel>> fetchTopHeadlines({
    required String baseUrl,
    required String apiKey,
    NewsCategory? category,
  }) async {
    final base =
    baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;

    final uri = Uri.parse('$base${AppConstants.topHeadlinesEndpoint}').replace(
      queryParameters: {
        'country': AppConstants.newsCountry,
        if (category != null) 'category': category.apiValue,
        'pageSize': AppConstants.newsPageSize.toString(),
      },
    );

    try {
      final response = await _client
          .get(uri, headers: {'X-Api-Key': apiKey})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 401) {
        throw const AppException(AppMessages.newsApiKeyInvalid);
      }
      if (response.statusCode == 429) {
        throw const AppException(AppMessages.newsRateLimited);
      }
      if (response.statusCode != 200) {
        throw const AppException(AppMessages.newsLoadFailed);
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final list = (body['articles'] as List?) ?? [];

      return list
          .map((e) => NewsModel.fromMap(e as Map<String, dynamic>))
          .where((article) => article.isValid)
          .toList();
    } on AppException {
      rethrow;
    } on SocketException {
      throw const AppException(AppMessages.newsNoInternet);
    } on TimeoutException {
      throw const AppException(AppMessages.newsTimeout);
    } catch (_) {
      throw const AppException(AppMessages.newsLoadFailed);
    }
  }
}