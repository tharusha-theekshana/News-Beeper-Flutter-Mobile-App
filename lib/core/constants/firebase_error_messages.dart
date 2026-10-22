import '../constants/app_messages.dart';

class FirebaseErrorMessages {
  FirebaseErrorMessages._();

  /// [code] is `FirebaseAuthException.code`, e.g. 'wrong-password'.
  static String fromCode(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return 'Incorrect email or password.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Please choose a stronger password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'operation-not-allowed':
      // Reworded: this can now be email OR Google sign in.
        return 'This sign in method is not enabled for this app.';

    // ---- Added for Google sign in ----
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using another sign in method.';
      case 'credential-already-in-use':
        return 'This Google account is already linked to another user.';
      default:
        return AppMessages.genericError;
    }
  }
}