import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:newsbeeper/core/constants/firebase_error_messages.dart';
import 'package:newsbeeper/core/exceptions/app_exception.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/app_messages.dart';
import '../models/user_model.dart';

/// SERVICE layer: talks to Firebase Authentication, Google Sign-In and
/// Firestore (users collection).
/// No widgets and no Provider in here, only Firebase / Google calls.
class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// The currently signed in Firebase user, or null if nobody is signed in.
  /// Firebase remembers the user between app launches automatically.
  User? get currentUser => _auth.currentUser;

  // ---------------------------------------------------------------------------
  // Email + password
  // ---------------------------------------------------------------------------

  /// Signs in with email + password.
  /// Throws [AppException] with a readable message when it fails.
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AppException(FirebaseErrorMessages.fromCode(e.code));
    }
  }

  /// Creates the account. Called from sign up STEP 2, when we finally have
  /// every value (name, mobile, email from step 1 + password from step 2).
  Future<void> signUp({
    required String fullName,
    required String mobile,
    required String email,
    required String password,
  }) async {
    try {
      // Step 1: create the Firebase Auth user (this also signs them in).
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;

      try {
        // Step 2: save the name on the auth user + the full profile in Firestore.
        await user.updateDisplayName(fullName.trim());

        final profile = UserModel(
          uid: user.uid,
          fullName: fullName.trim(),
          email: email.trim(),
          mobile: mobile.trim(),
        );

        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set(profile.toMap());
      } catch (_) {
        // Step 3 (rollback): if the profile could not be saved, delete the
        // auth user too, otherwise the email would be "taken" with no profile.
        await user.delete();
        throw const AppException(AppMessages.profileCreateFailed);
      }
    } on FirebaseAuthException catch (e) {
      throw AppException(FirebaseErrorMessages.fromCode(e.code));
    }
  }

  // ---------------------------------------------------------------------------
  // Forgot password
  // ---------------------------------------------------------------------------

  /// Sends Firebase's "reset password" email to [email].
  /// The email contains a link that opens a Firebase-hosted page where the
  /// user types a new password. No extra screen is needed in the app.
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      // Older Firebase projects (without "email enumeration protection")
      // throw 'user-not-found' here. We treat it as success on purpose so the
      // screen never reveals which emails are registered.
      if (e.code == 'user-not-found') return;
      throw AppException(FirebaseErrorMessages.fromCode(e.code));
    }
  }

  // ---------------------------------------------------------------------------
  // Google sign in  (google_sign_in 7.x API)
  // ---------------------------------------------------------------------------

  // In google_sign_in 7.x, `GoogleSignIn.instance.initialize()` must be called
  // exactly once before anything else. We do it lazily the first time it is
  // needed, so main.dart does not need to change.
  bool _googleInitialized = false;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    // On Android the web client id is read automatically from
    // google-services.json (default_web_client_id). If you ever get a
    // "serverClientId must be provided" error, pass it here:
    //   initialize(serverClientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com')
    await GoogleSignIn.instance.initialize();
    _googleInitialized = true;
  }

  /// Signs in (or signs up, if it is the first time) with a Google account.
  ///
  /// Returns:
  ///   true  -> signed in
  ///   false -> the user closed the Google account picker (NOT an error, so
  ///            the UI should show nothing)
  /// Throws [AppException] for real failures.
  Future<bool> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();

      // 1. Opens the Google account picker. Throws GoogleSignInException
      //    (code `canceled`) if the user backs out.
      final GoogleSignInAccount googleUser =
      await GoogleSignIn.instance.authenticate();

      // 2. The idToken proves to Firebase who the user is.
      final String? idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        throw const AppException(AppMessages.googleSignInFailed);
      }

      // 3. Exchange the Google token for a Firebase user.
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final result = await _auth.signInWithCredential(credential);
      final user = result.user!;

      // 4. First time with Google -> create the Firestore profile, same
      //    collection and model as email sign up. Mobile is unknown, so it is
      //    stored empty (you can ask for it later from a profile screen).
      if (result.additionalUserInfo?.isNewUser ?? false) {
        try {
          final profile = UserModel(
            uid: user.uid,
            fullName: user.displayName ?? '',
            email: user.email ?? '',
            mobile: '',
          );
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(user.uid)
              .set(profile.toMap());
        } catch (_) {
          // Rollback, same idea as in signUp().
          await user.delete();
          await signOut();
          throw const AppException(AppMessages.profileCreateFailed);
        }
      }
      return true;
    } on GoogleSignInException catch (e) {
      // User closed the picker -> not an error.
      if (e.code == GoogleSignInExceptionCode.canceled) return false;
      throw const AppException(AppMessages.googleSignInFailed);
    } on FirebaseAuthException catch (e) {
      throw AppException(FirebaseErrorMessages.fromCode(e.code));
    }
  }

  // ---------------------------------------------------------------------------
  // Sign out
  // ---------------------------------------------------------------------------

  /// Signs out of Firebase AND Google, so the Google account picker shows
  /// again the next time (otherwise Google may silently reuse the last account).
  Future<void> signOut() async {
    try {
      await _ensureGoogleInitialized();
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Ignore: the user may never have used Google, that is fine.
    }
    await _auth.signOut();
  }
}