import 'package:flutter/material.dart';
import 'package:prost/class/table.dart';
import 'package:prost/widgets/info_alert.dart';

class TableCard extends StatelessWidget {
  final TableModel table;
  final String companyId;

  TableCard({required this.table, required this.companyId});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: table.status == 'available'
          ? Colors.grey[200]
          : const Color.fromARGB(255, 230, 207, 200),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return InfoAlert(companyId: companyId, table: table);
            },
          );
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
