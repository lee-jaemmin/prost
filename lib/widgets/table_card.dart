import 'package:flutter/material.dart';
import 'package:prost/class/table.dart';

class TableCard extends StatelessWidget {
  final TableModel table;

  TableCard({required this.table});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: table.status == 'available' ? Colors.grey[200] : Colors.amber[100],
      child: InkWell(
        onTap: () {
          /* 클릭 시 바틀 상세 정보 팝업 */
        },
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                table.tablename,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              if (table.customer.isNotEmpty) ...[
                SizedBox(height: 5),
                Text(table.bottle, style: TextStyle(fontSize: 14)), // 손님 이름
                Text(
                  table.staff,
                  style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                ), // 술 종류
              ],
            ],
          ),
        ),
      ),
    );
  }
}
