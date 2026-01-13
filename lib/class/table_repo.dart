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

  /// live stream
  Stream<List<TableModel>> getTablesStream(String company, String section) {
    return _tableCol(company)
        .where('section', isEqualTo: section)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => TableModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  /// [ADD] create table
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
      status: 'empty',
      createdat: DateTime.now(),
    );

    // store on DB
    await docRef.set(
      {...newTable.toMap(), 'createdat': FieldValue.serverTimestamp()},
    );
  }

  /// [DEL] Delete table
  Future<void> deleteTable(String company, String tid) async {
    await _tableCol(company).doc(tid).delete();
  }

  /// [MOD] modify tablename or section
  Future<void> updateTableLayout(
    String company,
    String tid,
    Map<String, dynamic> patch,
  ) async {
    await _tableCol(company).doc(tid).update({
      ...patch,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// [RESET] empty every table at morning
  Future<void> resetAllTablesForNewDay(String company) async {
    final snap = await _tableCol(company).get();
    final batch = _db.batch();

    for (var doc in snap.docs) {
      batch.update(doc.reference, {
        'status': 'empty', //
        'customer': '',
        'phonenumber': '',
        'staff': '',
        'bottle': '',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  /// [ACT] activation table
  Future<void> registerBottleKeep({
    required String company,
    required String tid,
    required String customer, // 손님 이름
    required String phonenumber, // 손님 번호
    required String staff, // 담당 직원
    required String bottle, // 술 종류
  }) async {
    await _tableCol(company).doc(tid).update({
      'customer': customer,
      'phonenumber': phonenumber,
      'staff': staff,
      'bottle': bottle,
      'status': 'active', // 정보가 입력되면 상태를 'active'로 변경
      'updatedAt': FieldValue.serverTimestamp(), // 수정 시간 기록
    });
  }
}
