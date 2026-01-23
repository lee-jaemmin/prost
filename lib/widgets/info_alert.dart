import 'package:flutter/material.dart';
import 'package:prost/class/table.dart';
import 'package:prost/class/table_repo.dart';

class InfoAlert extends StatefulWidget {
  final String companyId;
  final TableModel table;

  const InfoAlert({
    super.key,
    required this.companyId,
    required this.table,
  });

  @override
  State<InfoAlert> createState() => _TableRegistrationDialogState();
}

class _TableRegistrationDialogState extends State<InfoAlert> {
  // 입력 컨트롤러 정의
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _bottleController;
  late TextEditingController _staffController;
  late TextEditingController _remarksController;
  final _repo = TableRepository();

  @override
  void initState() {
    super.initState();
    // [핵심] 테이블의 기존 정보를 컨트롤러의 초기값으로 설정합니다.
    // '미지정' 혹은 '없음'과 같은 기본값일 때는 빈 칸으로 보여줍니다.
    _nameController = TextEditingController(
      text: widget.table.customer == '손님 미지정' ? '' : widget.table.customer,
    );
    _phoneController = TextEditingController(
      text: widget.table.phonenumber == '번호 없음' ? '' : widget.table.phonenumber,
    );
    _bottleController = TextEditingController(
      text: widget.table.bottle == '바틀 미지정' ? '' : widget.table.bottle,
    );
    _staffController = TextEditingController(
      text: widget.table.staff == '스태프 미지정' ? '' : widget.table.staff,
    );
    _remarksController = TextEditingController(); // 비고는 현재 모델에 없으므로 일단 빈값
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bottleController.dispose();
    _staffController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.table.tablename} 정보 등록'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '손님 이름'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: '손님 번호'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _bottleController,
              decoration: const InputDecoration(labelText: '바틀(술 종류)'),
            ),
            TextField(
              controller: _staffController,
              decoration: const InputDecoration(labelText: '담당 스태프'),
            ),
            TextField(
              controller: _remarksController,
              decoration: const InputDecoration(labelText: '비고(특이사항)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () async {
            // 필수 정보 입력 확인 (이름, 바틀 등)
            if (_nameController.text.isNotEmpty &&
                _bottleController.text.isNotEmpty) {
              await _repo.registerBottleKeep(
                company: widget.companyId,
                tid: widget.table.tid,
                customer: _nameController.text.trim(),
                phonenumber: _phoneController.text.trim(),
                staff: _staffController.text.trim(),
                persons: widget.table.persons, // 기존 인원 유지
                bottle: _bottleController.text.trim(),
              );
              // TODO: '비고' 필드를 모델에 추가했다면 여기에 함께 저장 로직 작성
              if (context.mounted) Navigator.pop(context);
            }
          },
          child: const Text('등록'),
        ),
      ],
    );
  }
}
