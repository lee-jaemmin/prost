import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';

class AppUser {
  final String uid;
  final String username;
  final String company;
  final bool isAdmin;
  final DateTime createdat;

  const AppUser({
    // const: All field has to be final
    // use memory only once
    required this.uid,
    required this.username,
    required this.company,
    required this.isAdmin,
    required this.createdat,
  });

  AppUser copyWith({
    // bc of final fields can't moidfied
    // make copied new instance(changed only certatin field)
    //-------------------------------------------------------
    String? username,
    String? company,
    bool? isAdmin,
    DateTime? createdat,
    // nullable: to choose only field that I want to modify
  }) {
    return AppUser(
      uid: this.uid,
      username: username ?? this.username,
      company: company ?? this.company,
      isAdmin: isAdmin ?? false,
      createdat: createdat ?? this.createdat,
      // if modified: modified field, else: same value
    );
  }

  /// 1. creation based on Firebase Auth
  factory AppUser.fromFirebase(
    auth.User user, {
    required String company,
    required String username,
    required bool isAdmin,
  }) {
    // factory: smart initializer; return instance according to logic I assign
    // inside {}: named parameter, outside {}: positional parameter

    return AppUser(
      uid: user.uid,
      username: username,
      company: company,
      isAdmin: isAdmin,
      createdat: DateTime.now(),
    );
  }

  /// 2. restoraion through Firestore data
  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      username: map['username'] ?? '이름 미지정',
      company: map['company'] ?? '회사 미지정',
      isAdmin: map['isAdmin'] ?? false,
      createdat: (map['createdat'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// 3. transformation for Firestore save
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'company': company,
      'createdat': createdat,
    };
  }
}
