import 'package:prost/class/table.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class TableRepository {
  final FirebaseFirestore _db;
  final auth.FirebaseAuth _auth;

  TableRepository({
    FirebaseFirestore? db,
    auth.FirebaseAuth? authInstance,
  }) : _db = db ?? FirebaseFirestore.instance,
       _auth = authInstance ?? auth.FirebaseAuth.instance;

  /// shorten the data path as a central controller
  CollectionReference<Map<String, dynamic>> _tableCol(String company) {
    return _db.collection('stores').doc(company).collection('tables');
  }

  /// 1. create Table for database

  Future<void> createTable({
    required String company,
    required String tablename,
    required String section,
    required String customer,
    required String phonenumber,
    required String bottle,
    required String status,
    required String staff,
  }) async {
    // 저장할 위치(문서 참조)를 먼저 정해서 tid 확보
    final docRef = _tableCol(company).doc();

    final newTable = TableModel(
      tid: docRef.id,
      tablename: tablename,
      section: section,
      customer: customer,
      phonenumber: phonenumber,
      bottle: bottle,
      staff: staff,
      status: status,
      createdat: DateTime.now(),
    );

    /// 3. DB에 저장
    await docRef.set(
      {...newTable.toMap(), 'createdat': FieldValue.serverTimestamp()},
    );
  }
}
