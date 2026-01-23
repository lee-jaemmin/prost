import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prost/class/table.dart';
import 'package:prost/class/table_repo.dart';

class MoveScreen extends StatelessWidget {
  final String companyId;
  final TableModel fromTable; // 어디에서 이동하는지 정보

  const MoveScreen({
    super.key,
    required this.companyId,
    required this.fromTable,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('company')
          .doc(companyId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );

        final companyData = snapshot.data?.data() as Map<String, dynamic>?;
        final List<String> sections = List<String>.from(
          companyData?['sections'] ?? [],
        );

        return DefaultTabController(
          length: sections.length,
          child: Scaffold(
            appBar: AppBar(
              title: Text('${fromTable.tablename} 이동 위치 선택'),
              bottom: TabBar(
                isScrollable: true,
                tabs: sections.map((s) => Tab(text: s)).toList(),
              ),
            ),
            body: TabBarView(
              children: sections
                  .map(
                    (section) => MoveTableGridView(
                      companyId: companyId,
                      section: section,
                      fromTable: fromTable,
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}

class MoveTableGridView extends StatelessWidget {
  final String companyId;
  final String section;
  final TableModel fromTable;
  final TableRepository _repo = TableRepository();

  MoveTableGridView({
    required this.companyId,
    required this.section,
    required this.fromTable,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TableModel>>(
      stream: _repo.getTablesStream(companyId, section),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final tables = snapshot.data!;
        return GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: tables.length,
          itemBuilder: (context, index) {
            final targetTable = tables[index];
            bool isAvailable = targetTable.status == 'available';

            return GestureDetector(
              onTap: isAvailable
                  ? () => _confirmMove(context, targetTable)
                  : null,
              child: Card(
                // 사용 중이면 회색, 이동 가능하면 파란색
                color: isAvailable ? Colors.blue[100] : Colors.grey[300],
                child: Center(
                  child: Text(
                    targetTable.tablename,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isAvailable ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmMove(BuildContext context, TableModel targetTable) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('테이블 이동'),
        content: Text(
          '${fromTable.tablename}의 정보를 ${targetTable.tablename}으로 이동하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _repo.moveTable(companyId, fromTable, targetTable.tid);
              if (context.mounted) {
                Navigator.pop(context); // 다이얼로그 닫기
                Navigator.pop(context); // 이동 화면 닫기 (홈으로 복귀)
              }
            },
            child: const Text('이동 확정'),
          ),
        ],
      ),
    );
  }
}
