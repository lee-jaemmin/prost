import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prost/class/table.dart';
import 'package:prost/class/table_repo.dart';
import 'package:prost/constants/gaps.dart';
import 'package:prost/methods/check_admin.dart';
import 'package:prost/screens/login_screen.dart';
import 'package:prost/screens/table_management_screen.dart';
import 'package:prost/screens/table_reservation_screen.dart';
import 'package:prost/widgets/sidebar_menu.dart';
import 'package:prost/widgets/table_card.dart';

class HomeScreen extends StatelessWidget {
  final String company = "prost"; // 실제로는 로그인한 유저의 소속 정보를 가져와야 함
  final List<String> sections = [
    'Bravo',
    'Terrace',
    'VIP',
  ]; // 관리자 설정에서 가져오도록 확장 해야함.

  // scaffold key to open side bar safely
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // logout Function
  Future<void> signOutAndNavigate(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false, // 모든 이전 라우트를 제거 (false 반환)
        );
      }
    } catch (e) {
      print("로그아웃 오류: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그아웃 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: sections.length,
      child: Scaffold(
        key: _scaffoldKey,
        endDrawer: Drawer(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 100.0),
            child: Column(
              children: [
                SidebarMenu(
                  name: '테이블 관리',
                  onTapFunc: () => CheckAdminAndNavigate(
                    context: context,
                    designatedPage: TableManagementScreen(),
                  ),
                ),
                Gaps.v20(context),
                SidebarMenu(
                  name: '예약',
                  onTapFunc: () => CheckAdminAndNavigate(
                    context: context,
                    designatedPage: TableReservationScreen(),
                  ),
                ),
                Gaps.v20(context),
                SidebarMenu(
                  name: '로그아웃',
                  onTapFunc: () => signOutAndNavigate(context),
                ),
                Gaps.v20(context),
              ],
            ),
          ),
        ),
        appBar: AppBar(
          title: Text('PROST Dashboard'),
          bottom: TabBar(
            isScrollable: true,
            tabs: sections.map((s) => Tab(text: s)).toList(),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () =>
                    _scaffoldKey.currentState?.openEndDrawer(), // open sidebar
                child: Icon(FontAwesomeIcons.bars),
              ),
            ),
          ],
        ),
        body: TabBarView(
          children: sections
              .map(
                (section) => TableGridView(company: company, section: section),
              )
              .toList(),
        ),
      ),
    );
  }
}

class TableGridView extends StatelessWidget {
  final String company;
  final String section;
  final TableRepository _repo = TableRepository();

  TableGridView({required this.company, required this.section});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TableModel>>(
      stream: _repo.getTablesStream(company, section), // 실시간 데이터 수신
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Center(child: Text("오류 발생: snapshot.hasError"));
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());

        final tables = snapshot.data!;

        return GridView.builder(
          padding: EdgeInsets.all(10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 한 줄에 3개씩 배치
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: tables.length,
          itemBuilder: (context, index) {
            final table = tables[index];
            return TableCard(table: table);
          },
        );
      },
    );
  }
}
