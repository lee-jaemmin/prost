import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prost/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:prost/constants/sizes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:prost/screens/home_screen.dart';
import 'package:prost/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance.activate(
    // 웹 환경이 아니라면 androidProvider에 Play Integrity를 설정합니다.
    androidProvider: AndroidProvider.playIntegrity,
  );
  runApp(const Prost());
}

class Prost extends StatelessWidget {
  const Prost({super.key});

  @override
  Widget build(BuildContext context) {
    const seedGreen = Color(0xFF16A34A); // 원하는 초록

    final scheme = ColorScheme.fromSeed(
      seedColor: seedGreen,
      brightness: Brightness.light,
    );
    return MaterialApp(
      title: 'Prost',
      theme: ThemeData(
        colorScheme: scheme,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.green.shade600,
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: Sizes.size18,
            color: Colors.black,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: const UnderlineInputBorder(),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: scheme.outlineVariant),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: scheme.primary, width: 2),
          ),
          floatingLabelStyle: TextStyle(color: scheme.primary),
        ),
        // 진행바 색
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: scheme.primary,
        ),
        // BottomNavigationBar 색
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: scheme.surface,
          selectedItemColor: scheme.primary,
          unselectedItemColor: scheme.onSurfaceVariant,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. 로그인 정보가 있으면 -> 홈 화면으로
          if (snapshot.hasData) {
            return HomeScreen();
          }
          // 2. 없으면 -> 로그인 화면으로
          return const LoginScreen();
        },
      ),
    );
  }
}
