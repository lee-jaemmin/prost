import 'package:flutter/material.dart';

class TableManagementScreen extends StatefulWidget {
  const TableManagementScreen({super.key});

  @override
  State<TableManagementScreen> createState() => _TableManagementScreenState();
}

class _TableManagementScreenState extends State<TableManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('테이블 관리 화면'),
    );
  }
}
