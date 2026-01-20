import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prost/class/app_user.dart';
import 'package:prost/constants/gaps.dart';
import 'package:prost/methods/check_admin.dart';
import 'package:prost/screens/login_screen.dart';
import 'package:prost/screens/table_management_screen.dart';
import 'package:prost/screens/table_reservation_screen.dart';
import 'package:prost/widgets/sidebar_menu.dart';
import 'package:prost/widgets/table_gridview.dart';

/// FirebaseAuth.instance.currentUser로 UID 획득
/// -> Firestore에서 해당 UID 문서 조회
/// -> AppUser.fromMap으로 변환 -> UI에서 사용
class HomeScreen extends StatelessWidget {
  Future<AppUser> _fetchCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser; // User 객체.
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    return AppUser.fromMap(doc.id, doc.data()!);
  }

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
    return FutureBuilder(
      future: _fetchCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final _currentUser = snapshot.data!;

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
                        designatedPage: TableManagementScreen(
                          company: _currentUser.companyid,
                        ),
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
              title: Text('${_currentUser.companyid} Dashboard'),
              bottom: TabBar(
                isScrollable: true,
                tabs: sections.map((s) => Tab(text: s)).toList(),
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () => _scaffoldKey.currentState
                        ?.openEndDrawer(), // open sidebar
                    child: Icon(FontAwesomeIcons.bars),
                  ),
                ),
              ],
            ),
            body: TabBarView(
              children: sections.map((section) {
                return TableGridView(
                  companyid: _currentUser.companyid,
                  section: section,
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
