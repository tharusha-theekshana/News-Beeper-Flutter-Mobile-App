import 'package:flutter/foundation.dart';

import '../core/constants/app_messages.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

/// PROVIDER layer: holds the signed in user's profile for the UI.
/// Views listen to [user], [isLoading] and [errorMessage].
class UserProvider extends ChangeNotifier {
  final UserService _userService;

  UserProvider(this._userService);

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Loads the profile from Firestore.
  Future<void> loadUser() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _userService.getCurrentUser();
    } catch (_) {
      _errorMessage = AppMessages.userLoadFailed;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Call after sign out so the next user does not see old data.
  void clearUser() {
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }
}