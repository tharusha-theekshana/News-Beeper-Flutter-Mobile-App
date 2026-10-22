import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:newsbeeper/models/news_model.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/app_messages.dart';
import '../core/exceptions/app_exception.dart';

/// SERVICE layer: saves news under the signed in user in Firestore.
///
/// users / {uid} / saved_news / {articleId}
class SavedNewsService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  SavedNewsService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _savedCollection() {
    final user = _auth.currentUser;
    if (user == null) throw const AppException(AppMessages.userNotSignedIn);

    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .collection(AppConstants.savedNewsCollection);
  }

  // A URL can not be used as a document id (it has "/"), so we use its hash.
  // The same article always gives the same id, so it can never be saved twice.
  String _docId(NewsModel article) =>
      md5.convert(utf8.encode(article.url)).toString();

  /// All saved news of this user, newest first.
  Future<List<NewsModel>> fetchSavedArticles() async {
    final snapshot =
    await _savedCollection().orderBy('savedAt', descending: true).get();

    return snapshot.docs
        .map((doc) => NewsModel.fromSavedMap(doc.data()))
        .toList();
  }

  Future<void> saveArticle(NewsModel article) {
    return _savedCollection().doc(_docId(article)).set({
      ...article.toMap(),
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeArticle(NewsModel article) {
    return _savedCollection().doc(_docId(article)).delete();
  }
}