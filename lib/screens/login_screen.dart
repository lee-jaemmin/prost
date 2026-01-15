import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prost/widgets/auth_textfield.dart';
import 'package:prost/widgets/company_picker.dart';
import 'home_screen.dart'; // 홈 화면 import 필요

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true; // true: 로그인 모드, false: 회원가입 모드
  bool isLoading = false; // 로딩 상태

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String _generateFakeEmail(String id) {
    // 사용자가 입력한 아이디에 우리만의 가짜 도메인을 붙입니다.
    // 공백 제거 후 소문자로 통일하는 것이 안전합니다.
    return "${id.trim()}@prost.com";
  }

  String? _selectedCompany;

  // 제출 함수 (로그인 또는 회원가입)
  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    // 사용자가 입력한 아이디를 이메일 형식으로 변환
    final String fakeEmail = _generateFakeEmail(_emailController.text);
    final String password = _passwordController.text.trim();

    try {
      if (isLogin) {
        // [로그인 로직] 변환된 이메일로 로그인 시도
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: fakeEmail,
          password: password,
        );
      } else {
        // [회원가입 로직]
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: fakeEmail,
              password: password,
            );

        // Firestore 저장 (여기서는 실제 입력한 '아이디'를 저장해두면 보기 편함)
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
              'username': _emailController.text.trim(), // 원본 아이디 저장
              'email': fakeEmail, // (참고용) 전체 이메일
              'name': _nameController.text.trim(),
              'company': _companyController.text.trim(),
              'role': 'user',
              'createdAt': FieldValue.serverTimestamp(),
            });
      }
    } on FirebaseAuthException catch (e) {
      String message = "오류가 발생했습니다.";

      // 사용자에게 보여줄 에러 메시지도 다듬어야 합니다.
      if (e.code == 'email-already-in-use') {
        message = "이미 사용 중인 아이디입니다.";
      } else if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        message = "아이디 또는 비밀번호가 잘못되었습니다.";
      } else if (e.code == 'invalid-email') {
        message = "아이디 형식이 올바르지 않습니다.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _handleCompanySelection() async {
    // Picker를 띄우고 사용자가 선택할 때까지 기다림(await)
    final selected = await CompanyPicker.show(context);

    if (selected != null) {
      setState(() {
        _selectedCompany = selected;
        _companyController.text = selected; // 텍스트 필드에도 표시
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "PROST",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // 2. 입력 필드들
                  // [회원가입 전용] 이름
                  if (!isLogin)
                    AuthTextfield(
                      controller: _nameController,
                      hintText: "이름 (본명)",
                      icon: Icons.person_outline,
                    ),
                  if (!isLogin) const SizedBox(height: 16),

                  // [회원가입 전용] 업장명
                  if (!isLogin)
                    GestureDetector(
                      onTap: _handleCompanySelection, // 분리된 함수 호출
                      child: AbsorbPointer(
                        child: AuthTextfield(
                          controller: _companyController,
                          hintText: "업장을 선택해주세요",
                          icon: Icons.store_mall_directory_outlined,
                        ),
                      ),
                    ),
                  if (!isLogin) const SizedBox(height: 16),

                  // [공통] 아이디
                  AuthTextfield(
                    controller: _emailController,
                    hintText: "아이디",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // [공통] 비밀번호
                  AuthTextfield(
                    controller: _passwordController,
                    hintText: "비밀번호",
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 40),

                  // 3. 메인 버튼 (로그인 or 가입하기)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87, // 브랜드 컬러
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // 동글동글
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              isLogin ? "로그인" : "회원가입",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. 모드 전환 버튼 (하단 회색 글씨)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isLogin = !isLogin; // 모드 토글
                        _formKey.currentState?.reset(); // 폼 초기화
                      });
                    },
                    child: Text(
                      isLogin ? "아직 계정이 없으신가요?  회원가입" : "이미 계정이 있으신가요?  로그인",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
