import 'package:flutter/material.dart';

class SidebarMenu extends StatelessWidget {
  final String name;
  final Future<void> onTapFunc; // 클릭했을 때 실행할 함수를 받음

  const SidebarMenu({
    super.key,
    required this.name,
    required this.onTapFunc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 300,
      decoration: BoxDecoration(
        border: BoxBorder.all(color: Colors.transparent),
      ),
      child: Center(
        child: Text(
          name,
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
