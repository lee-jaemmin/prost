import 'package:cloud_firestore/cloud_firestore.dart';

class TableModel {
  final String tid;
  final String tablename;
  final String section;
  final String status;
  final String customer;
  final String phonenumber;
  final String staff;
  final String bottle;
  final int persons;
  final DateTime createdat;

  const TableModel({
    required this.tid,
    required this.tablename,
    required this.section,
    required this.status,
    required this.customer,
    required this.phonenumber,
    required this.staff,
    required this.bottle,
    required this.persons,
    required this.createdat,
  });

  TableModel copyWith({
    String? tablename,
    String? section,
    String? status,
    String? customer,
    String? phonenumber,
    String? staff,
    String? bottle,
    int? persons,
    DateTime? createdat,
  }) {
    return TableModel(
      tid: this.tid,
      tablename: tablename ?? this.tablename,
      section: section ?? this.section,
      status: status ?? this.status,
      customer: customer ?? this.customer,
      phonenumber: phonenumber ?? this.phonenumber,
      staff: staff ?? this.staff,
      bottle: bottle ?? this.bottle,
      persons: persons ?? this.persons,
      createdat: createdat ?? this.createdat,
    );
  }

  factory TableModel.fromMap(String tid, Map<String, dynamic> map) {
    return TableModel(
      tid: tid,
      tablename: map['tablename'] ?? '테이블 미지정',
      section: map['section'] ?? '섹션 미지정',
      status: map['status'] ?? '상태 미지정',
      customer: map['customer'] ?? '손님 미지정',
      phonenumber: map['phonenumber'] ?? '번호 없음',
      staff: map['staff'] ?? '스태프 미지정',
      bottle: map['bottle'] ?? '바틀 미지정',
      persons: map['persons'] ?? '인원 미지정',
      createdat: (map['createdat'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tablename': tablename,
      'section': section,
      'status': status,
      'customer': customer,
      'phonenumber': phonenumber,
      'staff': staff,
      'bottle': bottle,
      'persons': persons,
      'createdat': createdat,
    };
  }
}
