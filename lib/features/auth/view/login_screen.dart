import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../terms/view/terms_agreement_screen.dart';
import '../viewmodel/login_viewmodel.dart';
import 'package:it_contest_fe/features/onboarding/view/onboarding_screen.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:it_contest_fe/features/terms/service/terms_service.dart';

class LoginScreen extends StatelessWidget {
  final List<int> agreedTermIds; // ✅ 약관 동의 IDs 전달받음

  const LoginScreen({
    super.key,
    this.agreedTermIds = const [], // ✅ 기본값 비어있는 리스트
  });

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
                  height: 1,
                  letterSpacing: -0.6,
                  color: Color(0xFF7D4CFF),
                ),
              ),
              const SizedBox(height: 74),

              // ✅ 카카오 로그인 버튼
              viewModel.isLoading
                  ? const CircularProgressIndicator()
                  : InkWell(
                onTap: () async {
                  final token = await viewModel.loginWithKakao();
                  if (token != null) {
                    try {
                      // ✅ 로그인 성공 후 토큰 저장 (이미 하고 있다면 생략)
                      final termsService = TermsService();

                      // ✅ 필수 약관 동의 여부 확인
                      final agreed = await termsService.checkRequiredTerms();

                      if (agreed) {
                        // 이미 동의했으면 메인으로
                        Navigator.pushReplacementNamed(context, '/main');
                      } else {
                        // 동의 안했으면 약관 동의 화면으로
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const TermsAgreementScreen()),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('약관 확인 실패: $e')),
                      );
                    }
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

              // ✅ 게스트 로그인 버튼
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

              const SizedBox(height: 24),

              // ✅ 임시 회원 탈퇴 버튼
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
