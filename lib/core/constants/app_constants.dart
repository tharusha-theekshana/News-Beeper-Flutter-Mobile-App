class AppConstants{
  AppConstants._();

  // For firestore collections
  static const String metaDataCollection = 'meta_data';
  static const String usersCollection = 'users';

  // API data doc and fields
  static const String apiDataDoc = 'api_data';
  static const String apiKeyField = 'api_key';
  static const String baseUrlField = 'base_url';

  // App data doc and fields
  static const String appDataDoc = 'app_data';
  static const String appVersionField = 'app_version';

  // News API
  static const String topHeadlinesEndpoint = '/top-headlines';
  static const String newsCountry = 'us';
  static const int newsPageSize = 30;

  // Saved news
  static const String savedNewsCollection = 'saved_news';
}