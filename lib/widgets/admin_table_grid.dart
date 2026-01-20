import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prost/widgets/admin_add_table_card.dart';
import 'package:prost/widgets/admin_table_card.dart';

class AdminTableGrid extends StatelessWidget {
  final String company;
  final String section;

  const AdminTableGrid({
    super.key,
    required this.company,
    required this.section,
  });

  // 테이블 추가 팝업
  void _showAddTableDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('테이블 추가'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '테이블 번호/이름 (예: A1)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('companies')
                    .doc(company)
                    .collection('tables')
                    .add({
                      'tableName': controller.text.trim(),
                      'section': section,
                      'status': 'available',
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // 해당 섹션에 속한 테이블만 필터링해서 가져옴
      stream: FirebaseFirestore.instance
          .collection('companies')
          .doc(company)
          .collection('tables')
          .where('section')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final tables = snapshot.data!.docs;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: tables.length + 1, // 테이블들 + 추가 버튼 카드
          itemBuilder: (context, index) {
            if (index == tables.length) {
              return AdminAddTableCard(
                onTapFunc: () => _showAddTableDialog(context),
              );
            }
            final tableDoc = tables[index];
            return AdminTableCard(doc: tableDoc);
          },
        );
      },
    );
  }
}
