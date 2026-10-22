import 'package:flutter/foundation.dart';
import 'package:newsbeeper/core/exceptions/app_exception.dart';

import '../core/constants/app_messages.dart';
import '../services/auth_service.dart';

/// PROVIDER layer (ChangeNotifier, supplied by the provider package): sign in / sign up / sign out logic for the UI.
///
/// The views never call Firebase directly. They call this class, and this class
/// calls [AuthService]. The views only listen to [isLoading], [isGoogleLoading]
/// and [errorMessage].
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider(this._authService);

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;

  /// True while an email / password request is running (shows the button spinner).
  bool get isLoading => _isLoading;

  /// True while the Google sign in is running. Kept separate from [isLoading]
  /// so only the Google button spins, not the normal "Sign In" button.
  bool get isGoogleLoading => _isGoogleLoading;

  /// Message of the last failed request, null when there is no error.
  String? get errorMessage => _errorMessage;

  /// True when Firebase already has a signed in user (used by the splash
  /// screen to decide between Home and Sign in).
  bool get isLoggedIn => _authService.currentUser != null;

  /// Name of the signed in user (empty if not available).
  String get displayName => _authService.currentUser?.displayName ?? '';

  /// Signs the user in. Returns true on success, false on failure
  /// (then read [errorMessage] to show the reason).
  Future<bool> signIn({required String email, required String password}) {
    return _run(() => _authService.signIn(email: email, password: password));
  }

  /// Creates an account. Returns true on success, false on failure.
  /// Called from sign up STEP 2 (set password).
  Future<bool> signUp({
    required String fullName,
    required String mobile,
    required String email,
    required String password,
  }) {
    return _run(
          () => _authService.signUp(
        fullName: fullName,
        mobile: mobile,
        email: email,
        password: password,
      ),
    );
  }

  /// Sends the reset password email. Returns true when the request went
  /// through, false on failure (then read [errorMessage]).
  Future<bool> sendPasswordResetEmail({required String email}) {
    return _run(() => _authService.sendPasswordResetEmail(email: email));
  }

  /// Google sign in / sign up.
  ///
  /// Returns true when signed in. Returns false when it failed OR the user
  /// closed the picker. To tell them apart:
  ///   - [errorMessage] != null -> real error, show it
  ///   - [errorMessage] == null -> user cancelled, show nothing
  Future<bool> signInWithGoogle() async {
    _isGoogleLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      return await _authService.signInWithGoogle();
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = AppMessages.genericError;
      return false;
    } finally {
      _isGoogleLoading = false;
      notifyListeners();
    }
  }

  /// Signs the user out (Firebase + Google).
  Future<void> signOut() => _authService.signOut();

  /// Clears the last error (call when leaving a screen if you want).
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Shared wrapper for the email based actions so the loading / error
  /// handling is written only once:
  ///   1. turn the loading flag on
  ///   2. run the action
  ///   3. save the error message if it fails
  ///   4. turn the loading flag off
  Future<bool> _run(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = AppMessages.genericError;
      return false;
    } finally {
      // `finally` always runs, even after the `return`s above.
      _isLoading = false;
      notifyListeners();
    }
  }
}