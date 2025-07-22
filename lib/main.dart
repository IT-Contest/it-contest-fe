import 'package:flutter/material.dart';
import 'package:it_contest_fe/features/mainpage/view/main_screen.dart';
import 'package:provider/provider.dart';
import 'features/auth/view/login_screen.dart';
import 'features/auth/viewmodel/login_viewmodel.dart';
import 'features/friends/viewmodel/friend_viewmodel.dart';
import 'features/onboarding/view/onboarding_screen.dart';
import 'features/quest/viewmodel/daily_quest_viewmodel.dart';
import 'presentation/main_navigation_screen.dart';
import 'features/mainpage/viewmodel/mainpage_viewmodel.dart';
import 'features/quest/viewmodel/quest_tab_viewmodel.dart';
import 'features/quest/viewmodel/quest_pomodoro_viewmodel.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

void main() {
  KakaoSdk.init(nativeAppKey: '95a6f5cbf0b31573e750535a5c9d7aab');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => MainPageViewModel()),
        ChangeNotifierProvider(create: (_) => DailyQuestViewModel()),
        ChangeNotifierProvider(create: (_) => FriendViewModel()),
        ChangeNotifierProvider(create: (_) => QuestTabViewModel()),
        ChangeNotifierProvider(create: (_) => QuestPomodoroViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const LoginScreen(),
      routes: {
        '/main': (context) => MainNavigationScreen(),
        '/onboarding': (context) => OnboardingScreen(),
      },
    );
  }
}
