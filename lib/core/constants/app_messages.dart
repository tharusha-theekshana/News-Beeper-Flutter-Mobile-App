class AppMessages {
  AppMessages._();

  static const String genericError = 'Something went wrong. Please try again.';

  static const String connectingToServer = 'Connecting to server. Please wait.';
  static String retryingIn(int seconds) => seconds > 0
      ? 'Reconnecting in $seconds second${seconds == 1 ? '' : 's'}...'
      : 'Reconnecting...';

  // Sign up
  static const String profileCreateFailed =
      'We could not create your profile. Please try again.';

  // Google sign in
  static const String googleSignInFailed =
      'Google sign in failed. Please try again.';

  // Forgot password
  static String passwordResetSent(String email) =>
      'Password reset link has been sent to $email.';

  // User profile
  static const String userLoadFailed =
      'Unable to load your details. Please try again.';

  // News
  static const String newsLoadFailed =
      'Unable to load news. Please try again.';
  static const String newsNoInternet =
      'No internet connection. Please check your network.';
  static const String newsTimeout =
      'Request timed out. Please try again.';
  static const String newsApiKeyInvalid =
      'News service key is invalid. Please contact support.';
  static const String newsRateLimited =
      'Too many requests. Please try again later.';
  static const String noNewsFound = 'No news found.';

  // Saved news
  static const String userNotSignedIn = 'Please sign in again.';
  static const String savedNewsLoadFailed =
      'Unable to load saved news. Please try again.';
  static const String savedNewsActionFailed =
      'Unable to update saved news. Please try again.';
  static const String noSavedNews = 'You have not saved any news yet.';
  static const String newsSaved = 'News saved';
  static const String newsRemoved = 'Removed from saved news';
  static const String openLinkFailed = 'Unable to open the article link.';

  // App config
  static const String configMissing =
      'App configuration is missing. Please try again later.';
  static const String configIncomplete =
      'App configuration is incomplete. Please try again later.';
  static const String configTimeout =
      'Connection timed out. Please check your internet.';
  static const String configLoadFailed =
      'Unable to load app data. Please check your connection.';
}