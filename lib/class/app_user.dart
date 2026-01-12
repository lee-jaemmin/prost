import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class AppUser {
  final String uid;
  final String userName;
  final String company;
  final DateTime createdAt;

  const AppUser({
    // const: All field has to be final
    // use memory only once
    required this.uid,
    required this.userName,
    required this.company,
    required this.createdAt,
  });

  AppUser copyWith({
    // bc of final fields can't moidfied
    // make copied new instance(changed only certatin field)
    String? userName,
    String? company,
    DateTime? createdAt,
    // nullable: to choose only field that I want to modify
  }) {
    return AppUser(
      uid: this.uid,
      userName: userName ?? this.userName,
      company: company ?? this.company,
      createdAt: createdAt ?? this.createdAt,
      // if modified: modified field, else: same value
    );
  }

  /// 1. creation based on Firebase Auth
  factory AppUser.fromFirebase(
    auth.User user, {
    required String company,
    required String userName,
  }) {
    // factory: smart initializer; return instance according to logid I assign
    // inside {}: named parameter, outside {}: positional parameter

    return AppUser(
      uid: user.uid,
      userName: userName,
      company: company,
      createdAt: DateTime.now(),
    );
  }

  /// 2. restoraion through Firestroe data
  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      userName: map['userName'],
      company: map['company'],
      createdAt: map['createdAt'],
    );
  }

  /// 3. transformation for Firestore save
  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'company': company,
      'createdAt': createdAt,
    };
  }
}
