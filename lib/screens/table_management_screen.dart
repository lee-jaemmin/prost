import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prost/widgets/admin_table_grid.dart'; //

class TableManagementScreen extends StatefulWidget {
  final String company; // 홈 화면에서 넘겨받은 업장 아이디

  const TableManagementScreen({super.key, required this.company});

  @override
  State<TableManagementScreen> createState() => _TableManagementScreenState();
}

class _TableManagementScreenState extends State<TableManagementScreen> {
  // 섹션 추가 팝업
  void _showAddSectionDialog() {
    print(">>>>> 참조하려는 경로: company/${widget.company}");
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 섹션 추가'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '섹션 이름을 입력하세요 (예: Terrace)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),

          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                // company 문서의 sections 배열에 새 이름 추가
                await FirebaseFirestore.instance
                    .collection('company')
                    .doc(widget.company)
                    .update({
                      'sections': FieldValue.arrayUnion([
                        controller.text.trim(),
                      ]),
                    });
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  // 섹션 삭제 확인 팝업
  void _confirmDeleteSection(String sectionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$sectionName 섹션 삭제'),
        content: const Text('이 섹션을 삭제하시겠습니까? 해당 섹션의 테이블들도 관리되지 않을 수 있습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('company')
                  .doc(widget.company)
                  .update({
                    'sections': FieldValue.arrayRemove([sectionName]),
                  });
              if (mounted) Navigator.pop(context);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 업장(company) 문서의 실시간 스트림을 구독합니다.
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('company')
          .doc(widget.company)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Firestore에서 실시간으로 섹션 리스트를 가져옵니다.
        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final List<String> sections = List<String>.from(
          data?['sections'] ?? [],
        );

        return DefaultTabController(
          key: ValueKey(sections.length), // 섹션 개수가 변할 때 탭바를 새로고침하기 위함
          length: sections.length + 1, // 섹션들 + 추가 버튼 탭
          child: Scaffold(
            appBar: AppBar(
              title: const Text('매장 구성 관리'),
              bottom: TabBar(
                isScrollable: true,
                tabs: [
                  ...sections.map(
                    (s) => Tab(
                      child: Row(
                        children: [
                          Text(s),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _confirmDeleteSection(s),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Tab(
                    icon: Icon(Icons.add, color: Colors.blue),
                  ), // 섹션 추가 버튼
                ],
                onTap: (index) {
                  if (index == sections.length) {
                    _showAddSectionDialog();
                  }
                },
              ),
            ),
            body: TabBarView(
              children: [
                ...sections.map(
                  (s) => AdminTableGrid(company: widget.company, section: s),
                ),
                const Center(child: Text('새 섹션을 추가하여 매장을 구성하세요.')),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 해당 섹션의 테이블들을 관리하는 그리드 뷰
