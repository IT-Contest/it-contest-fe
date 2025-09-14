import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:it_contest_fe/shared/interstitial_ad_service.dart';
import 'package:provider/provider.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'features/auth/view/login_screen.dart';
import 'features/auth/viewmodel/login_viewmodel.dart';
import 'features/friends/viewmodel/friend_viewmodel.dart';
import 'features/mainpage/viewmodel/invite_viewmodel.dart';
import 'features/onboarding/view/onboarding_screen.dart';
import 'features/onboarding/viewmodel/onboarding_viewmodel.dart';
import 'features/quest/viewmodel/daily_quest_viewmodel.dart';
import 'features/quest/viewmodel/quest_party_create_viewmodel.dart';
import 'features/terms/view/terms_agreement_screen.dart';
import 'presentation/main_navigation_screen.dart';
import 'features/mainpage/viewmodel/mainpage_viewmodel.dart';
import 'features/quest/viewmodel/quest_tab_viewmodel.dart';
import 'features/quest/viewmodel/quest_pomodoro_viewmodel.dart';
import 'features/quest/viewmodel/quest_personal_create_viewmodel.dart';
import 'features/analysis/viewmodel/analysis_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize(); // 📌 AdMob 초기화

  // 📌 앱 시작 시 전면 광고 미리 로드
  InterstitialAdService.loadAd();

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
        ChangeNotifierProvider(create: (_) => OnboardingViewModel()),
        ChangeNotifierProvider(create: (_) => InviteViewModel(inviteCode: 'temp')),
        ChangeNotifierProvider(create: (_) => OnboardingViewModel()),
        ChangeNotifierProvider(create: (_) => QuestPersonalCreateViewModel()),
        ChangeNotifierProvider(create: (_) => AnalysisViewModel()),
        ChangeNotifierProvider(create: (_) => QuestPartyCreateViewModel()),
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
        '/terms': (context) => const TermsAgreementScreen(),
        '/main': (context) => MainNavigationScreen(),
        '/onboarding': (context) => OnboardingScreen(),
      },
    );
  }
}
