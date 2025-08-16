import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/login_viewmodel.dart';
import 'package:it_contest_fe/features/onboarding/view/onboarding_screen.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 200,
              ),
              const SizedBox(height: 24),
              const Text(
                '퀘스트플래너',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Jalnan',
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.normal,
                  fontSize: 30,
                  height: 1, // line-height: 30px / font-size: 30px = 1
                  letterSpacing: -0.6, // -2% of 30px = -0.6
                  color: Color(0xFF7D4CFF), // 원하는 색상 지정
                ),
              ),
              const SizedBox(height: 74),
              viewModel.isLoading
                  ? const CircularProgressIndicator()
                  : InkWell(
                      onTap: () async {
                        // 카카오 로그인
                        final token = await viewModel.loginWithKakao();
                        if (token != null) {
                          Navigator.pushReplacementNamed(context, '/main');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('카카오 로그인 실패')),
                          );
                        }
                      },
                      child: Image.asset(
                        'assets/icons/login_btn.png',
                        width: 280,
                      ),
                    ),
              const SizedBox(height: 24),
              SizedBox(
                width: 280,
                height: 56,
                child: OutlinedButton(
                  onPressed: () async {
                    final token = await viewModel.loginAsGuest();
                    if (token != null) {
                      if (token.isNewUser) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OnboardingScreen(),
                          ),
                        );
                      } else {
                        Navigator.pushReplacementNamed(context, '/main');
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('로그인 실패')),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF7958FF), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: const Text(
                    '건너뛰기',
                    style: TextStyle(
                      color: Color(0xFF7958FF),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // 회원 탈퇴(카카오 연결 끊기) 버튼 추가 - 임시
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await UserApi.instance.unlink();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('카카오 연결 끊기 성공!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('카카오 연결 끊기 실패: $e')),
                    );
                  }
                },
                child: const Text('회원 탈퇴(카카오 연결 끊기)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}