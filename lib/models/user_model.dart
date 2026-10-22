import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String mobile;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.mobile,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'full_name': fullName,
      'email': email,
      'mobile': mobile,
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: (map['uid'] ?? '').toString(),
      fullName: (map['full_name'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      mobile: (map['mobile'] ?? '').toString(),
      createdAt: (map['created_at'] as Timestamp?)?.toDate(),
    );
  }
}