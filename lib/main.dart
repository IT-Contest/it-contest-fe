import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/view/login_screen.dart';

import 'features/onboarding/view/onboarding_screen.dart';
import 'presentation/main_navigation_screen.dart';
import 'features/mainpage/viewmodel/mainpage_viewmodel.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

void main() {
  KakaoSdk.init(nativeAppKey: '95a6f5cbf0b31573e750535a5c9d7aab');
  runApp(
    ChangeNotifierProvider(
      create: (_) => MainPageViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: MaterialApp(
        home: const LoginScreen(), // 앱 초기 화면을 로그인 화면으로 변경
        routes: {
          '/main': (context) => MainNavigationScreen(),
          '/onboarding': (context) => OnboardingScreen(),
        }
      ),
    );
  }
}
