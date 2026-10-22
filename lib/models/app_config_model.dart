class AppConfigModel {
  final String apiKey;
  final String baseUrl;
  final String appVersion;

  const AppConfigModel({
    required this.apiKey,
    required this.baseUrl,
    required this.appVersion,
  });

  factory AppConfigModel.fromFirestore({
    required Map<String, dynamic> apiData,
    required Map<String, dynamic> appData,
    required String apiKeyField,
    required String baseUrlField,
    required String appVersionField,
  }) {
    return AppConfigModel(
      apiKey: (apiData[apiKeyField] ?? '').toString(),
      baseUrl: (apiData[baseUrlField] ?? '').toString(),
      appVersion: (appData[appVersionField] ?? '').toString(),
    );
  }

  bool get isValid => apiKey.isNotEmpty && baseUrl.isNotEmpty;
}