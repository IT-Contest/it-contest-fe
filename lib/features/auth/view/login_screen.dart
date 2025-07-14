import 'package:flutter/material.dart';
import '../service/kakao_login_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loginService = KakaoLoginService();

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
              InkWell(
                onTap: () async {
                  try {
                    final token = await loginService.loginWithKakao();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('AccessToken: ${token.substring(0, 10)}...')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('로그인 실패')));
                  }
                },
                child: Image.asset(
                  'assets/images/kakao_login_button.jpg',
                  width: 258,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/main');
                },
                child: const Text(
                  '건너뛰기',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14
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