import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

/// SERVICE layer: reads the signed in user's profile from Firestore.
/// No widgets and no Provider in here.
class UserService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  UserService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Returns the profile of the signed in user, or null if nobody is signed in.
  /// If the Firestore document is missing, we build the profile from the
  /// Firebase Auth user so the screen still has something to show.
  Future<UserModel?> getCurrentUser() async {
    final authUser = _auth.currentUser;
    if (authUser == null) return null;

    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(authUser.uid)
        .get();

    final data = doc.data();
    if (data != null) return UserModel.fromMap(data);

    return UserModel(
      uid: authUser.uid,
      fullName: authUser.displayName ?? '',
      email: authUser.email ?? '',
      mobile: '',
    );
  }
}