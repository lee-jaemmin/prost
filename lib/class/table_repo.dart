import 'package:prost/class/table.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class TableRepository {
  final FirebaseFirestore _db;

  TableRepository({
    FirebaseFirestore? db,
    auth.FirebaseAuth? authInstance,
  }) : _db = db ?? FirebaseFirestore.instance;

  /// return the address of 'collection' the group of doc.
  CollectionReference<Map<String, dynamic>> _tableCol(String company) {
    return _db.collection('company').doc(company).collection('tables');
  }

  // 2차 오름차순 정렬. A10 문제 해결
  int _naturalSort(String a, String b) {
    // 정규표현식으로 문자와 숫자를 분리 (예: A1 -> ['A', '1'])
    final regExp = RegExp(r'([A-Za-z]+)|(\d+)');
    final matchesA = regExp.allMatches(a).toList();
    final matchesB = regExp.allMatches(b).toList();

    for (int i = 0; i < matchesA.length && i < matchesB.length; i++) {
      final strA = matchesA[i].group(0)!;
      final strB = matchesB[i].group(0)!;

      // 둘 다 숫자인 경우 숫자로 비교
      if (int.tryParse(strA) != null && int.tryParse(strB) != null) {
        int numA = int.parse(strA);
        int numB = int.parse(strB);
        if (numA != numB) return numA.compareTo(numB);
      } else {
        // 문자인 경우 문자열로 비교
        int res = strA.compareTo(strB);
        if (res != 0) return res;
      }
    }
    return a.length.compareTo(b.length);
  }

  /// live stream
  Stream<List<TableModel>> getTablesStream(String company, String section) {
    return _tableCol(
          company,
        )
        .where('section', isEqualTo: section)
        .orderBy('tablename', descending: false)
        .snapshots()
        .map((snap) {
          final List<TableModel> tableList = snap.docs.map((doc) {
            final Map<String, dynamic> data = doc.data();
            final String id = doc.id;
            return TableModel.fromMap(id, data);
          }).toList();
          tableList.sort((a, b) => _naturalSort(a.tablename, b.tablename));
          return tableList;
        });
  }

  /* 
  .map(
          (snap) => snap.docs
              .map((doc) => TableModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  */

  /// [ADD] create table
  Future<void> createTable({
    required String company,
    required String tablename,
    required String section,
    required String customer,
    required String phonenumber,
    required String bottle,
    required String status,
    required String remark,
    required int persons,
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
      persons: persons,
      remark: remark,
      status: 'available',
      createdat: DateTime.now(),
    );

    // store on DB
    await docRef.set(
      {...newTable.toMap(), 'createdat': FieldValue.serverTimestamp()},
    );
  }

  /// [OUT] Out table
  Future<void> clearTable(String company, String tid) async {
    await _tableCol(company).doc(tid).update({
      'status': 'available', // 사용자 요청에 따라 available로 설정
      'customer': '',
      'phonenumber': '',
      'staff': '',
      'bottle': '',
      'remark': '', // 비고란 추가
      'persons': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// [MOVE] 테이블 이동 처리 (A -> B)
  Future<void> moveTable(
    String company,
    TableModel fromTable,
    String toTid,
  ) async {
    final batch = _db.batch();

    // 대상 테이블(toTid)로 모든 정보 복사 및 상태 변경
    batch.update(_tableCol(company).doc(toTid), {
      'status': 'inuse', // 이동 후 사용 중 상태로 변경
      'customer': fromTable.customer,
      'phonenumber': fromTable.phonenumber,
      'staff': fromTable.staff,
      'bottle': fromTable.bottle,
      'remark': fromTable.remark,
      'persons': fromTable.persons,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 기존 테이블(fromTid) 정보 삭제 및 아웃 처리
    batch.update(_tableCol(company).doc(fromTable.tid), {
      'status': 'available',
      'customer': '',
      'phonenumber': '',
      'staff': '',
      'bottle': '',
      'remark': '',
      'persons': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// [RES] 예약 시간 업데이트
  Future<void> updateReservation(
    String company,
    String tid,
    String? time,
  ) async {
    await _tableCol(company).doc(tid).update({
      'reservationtime': time,
      'updatedAt': FieldValue.serverTimestamp(),
    });
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
        'status': 'available', //
        'customer': '',
        'phonenumber': '',
        'staff': '',
        'bottle': '',
        'remark': '',
        'persons': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  /// [ACT] activation table: 여기가 사실상 정보 입력 하는 부분.
  Future<void> registerBottleKeep({
    required String company,
    required String tid,
    required String customer, // 손님 이름
    required String phonenumber, // 손님 번호
    required String staff, // 담당 직원
    required int persons,
    required String remark,
    required String bottle, // 술 종류
  }) async {
    await _tableCol(company).doc(tid).update({
      'customer': customer,
      'phonenumber': phonenumber,
      'staff': staff,
      'bottle': bottle,
      'status': 'inuse', // 정보가 입력되면 상태를 'inuse'로 변경
      'persons': persons,
      'remark': remark,
      'updatedAt': FieldValue.serverTimestamp(), // 수정 시간 기록
    });
  }

  /// [섹션] 섹션 목록 추가
  Future<void> addSection(String companyId, String sectionName) async {
    await _db.collection('company').doc(companyId).update({
      'sections': FieldValue.arrayUnion([sectionName]),
    });
  }

  /// [섹션] 섹션 목록 삭제
  Future<void> removeSection(String companyId, String sectionName) async {
    await _db.collection('company').doc(companyId).update({
      'sections': FieldValue.arrayRemove([sectionName]),
    });
  }
}
