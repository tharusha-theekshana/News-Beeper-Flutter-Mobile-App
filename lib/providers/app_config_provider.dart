import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:newsbeeper/core/exceptions/app_exception.dart';

import '../core/constants/app_messages.dart';
import '../core/enums/config_status.dart';
import '../models/app_config_model.dart';
import '../services/app_config_service.dart';

class AppConfigProvider extends ChangeNotifier {
  final AppConfigService _service;

  AppConfigProvider(this._service);

  ConfigStatus _status = ConfigStatus.initial;
  AppConfigModel? _config;
  String? _errorMessage;

  // Getters
  ConfigStatus get status => _status;
  bool get isLoading => _status == ConfigStatus.loading;
  String? get errorMessage => _errorMessage;

  // Empty string until the config has been loaded.
  String get apiKey => _config?.apiKey ?? '';
  String get baseUrl => _config?.baseUrl ?? '';
  String get appVersion => _config?.appVersion ?? '';

  // Load all config data and return true or false
  Future<bool> loadConfig() async {
    _status = ConfigStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _config = await _service
          .fetchAppConfig()
          .timeout(const Duration(seconds: 15));
      _status = ConfigStatus.loaded;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      return _processFailed(e.message);
    } on TimeoutException {
      return _processFailed(AppMessages.configTimeout);
    } catch (_) {
      return _processFailed(AppMessages.configLoadFailed);
    }
  }

  // stores the error, updates the state and returns false.
  bool _processFailed(String message) {
    _errorMessage = message;
    _status = ConfigStatus.error;
    notifyListeners();
    return false;
  }
}