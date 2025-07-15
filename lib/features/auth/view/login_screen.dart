import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/login_viewmodel.dart';
import 'package:it_contest_fe/features/onboarding/view/onboarding_screen.dart';

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
                'assets/images/logo.jpg',
                width: 200,
              ),
              const SizedBox(height: 74),
              viewModel.isLoading
                  ? const CircularProgressIndicator()
                  : InkWell(
                      onTap: () async {
                        final token = await viewModel.loginAsGuest();
                        if (token != null) {
                          // 게스트 로그인: isNewUser 확인 -> 메인 or 온보딩화면
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
                      child: Image.asset(
                        'assets/images/kakao_login_button.jpg',
                        width: 258,
                      ),
                    ),
              const SizedBox(height: 16),
              TextButton(
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
                child: const Text(
                  '건너뛰기',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}