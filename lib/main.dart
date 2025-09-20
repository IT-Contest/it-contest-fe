import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:it_contest_fe/shared/interstitial_ad_service.dart';
import 'package:provider/provider.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'features/auth/view/login_screen.dart';
import 'features/auth/viewmodel/login_viewmodel.dart';
import 'features/friends/viewmodel/friend_viewmodel.dart';
import 'features/mainpage/service/mainpage_service.dart';
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

  // Firebase 초기화
  await Firebase.initializeApp();

  // AdMob 초기화
  MobileAds.instance.initialize();

  // 앱 시작 시 전면 광고 미리 로드
  InterstitialAdService.loadAd();

  KakaoSdk.init(nativeAppKey: '95a6f5cbf0b31573e750535a5c9d7aab');
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => MainpageService()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => MainPageViewModel()),
        ChangeNotifierProvider(create: (_) => DailyQuestViewModel()),
        ChangeNotifierProvider(create: (_) => FriendViewModel()),
        ChangeNotifierProvider(create: (_) => QuestTabViewModel()),
        ChangeNotifierProvider(create: (_) => QuestPomodoroViewModel()),
        ChangeNotifierProvider(create: (_) => OnboardingViewModel()),
        ChangeNotifierProvider(create: (_) => InviteViewModel()),
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

    final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

    return MaterialApp(
      home: const LoginScreen(),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics), // 네비게이션 이벤트 추적
      ],
      routes: {
        '/terms': (context) => const TermsAgreementScreen(),
        '/main': (context) => const MainNavigationScreen(),
        '/onboarding': (context) => OnboardingScreen(),
      },
    );
  }
}
