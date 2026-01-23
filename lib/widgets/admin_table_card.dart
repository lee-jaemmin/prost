import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// 관리자용 추가, 삭제 가능한 테이블 UI
class AdminTableCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  const AdminTableCard({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            doc['tablename'], // 테이블 이름 (예: A1)
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Positioned(
          // 마이너스 기호
          top: 5,
          right: 5,
          child: GestureDetector(
            onTap: () => doc.reference.delete(), // 테이블 즉시 삭제
            child: const Icon(Icons.remove_circle, color: Colors.red, size: 20),
          ),
        ),
      ],
    );
  }
}
