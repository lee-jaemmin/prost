import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:prost/class/app_user.dart';

class UserRepository {
  final FirebaseFirestore _db;
  final auth.FirebaseAuth _auth;

  UserRepository({
    FirebaseFirestore? db,
    auth.FirebaseAuth? authInstance,
  }) : _db = db ?? FirebaseFirestore.instance,
       _auth = authInstance ?? auth.FirebaseAuth.instance;
  // init list: set field at a time when instance is created

  /// find path to store data(maybe AppUser instance)
  DocumentReference<Map<String, dynamic>> _meDoc() {
    final uid = _auth.currentUser?.uid; // 지금 로그인한 사람 누구야?
    if (uid == null) {
      throw StateError('로그인이 필요합니다. ERROR CODE: currentUser is null');
    }
    return _db.collection('users').doc(uid);
  }

  /// 이미 있는 데이터: 냅둠, 새 데이터: db에 등록
  Future<void> upsertFromAuth({
    required String company,
    required String username,
    required bool isAdmin,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null)
      throw StateError('로그인이 필요합니다. ERROR CODE: currentUser is null');

    // create AppUser instance using company, username from outside
    final appUser = AppUser.fromFirebase(
      currentUser,
      company: company,
      isAdmin: isAdmin,
      username: username,
    );

    final ref = _db.collection('users').doc(currentUser.uid);
    final snap = await ref.get();

    if (!snap.exists) {
      // 신규 가입 시 모든 정보 저장
      await ref.set({
        ...appUser.toMap(),

        //...: {}안에 내용 물 꺼내기.
      });
    } else {
      // 바뀔 수 있을 만한 정보만 업데이트
      await ref.update({
        'username': username,
        'company': company,
      });
    }
  }
}
