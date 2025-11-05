import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:it_contest_fe/shared/alarm/view/permission_request_screen.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_links/app_links.dart';

import 'core/fcm/fcm_service.dart';
import 'features/auth/view/login_screen.dart';
import 'features/auth/viewmodel/login_viewmodel.dart';
import 'features/terms/view/terms_agreement_screen.dart';
import 'features/onboarding/view/onboarding_screen.dart';
import 'features/mainpage/viewmodel/mainpage_viewmodel.dart';
import 'features/friends/viewmodel/friend_viewmodel.dart';
import 'features/quest/viewmodel/quest_tab_viewmodel.dart';
import 'features/onboarding/viewmodel/onboarding_viewmodel.dart';
import 'features/mainpage/service/mainpage_service.dart';
import 'features/analysis/viewmodel/analysis_viewmodel.dart';
import 'features/quest/viewmodel/daily_quest_viewmodel.dart';
import 'features/quest/viewmodel/quest_pomodoro_viewmodel.dart';
import 'features/quest/viewmodel/quest_party_create_viewmodel.dart';
import 'features/quest/viewmodel/quest_personal_create_viewmodel.dart';
import 'features/mainpage/viewmodel/invite_viewmodel.dart';
import 'features/profile/service/notification_service.dart';
import 'shared/interstitial_ad_service.dart';
import 'presentation/main_navigation_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase already initialized: $e');
  }
  MobileAds.instance.initialize();
  KakaoSdk.init(nativeAppKey: '95a6f5cbf0b31573e750535a5c9d7aab');
  // await NotificationService.init();
  InterstitialAdService.loadAd();

  final prefs = await SharedPreferences.getInstance();
  final hasAgreed = prefs.getBool('hasAgreedPermissions') ?? false;

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => MainpageService()),
        ChangeNotifierProvider(create: (_) => MainPageViewModel()),
        ChangeNotifierProvider(create: (_) => DailyQuestViewModel()),
        ChangeNotifierProvider(create: (_) => FriendViewModel()),
        ChangeNotifierProvider(create: (_) => QuestTabViewModel()),
        ChangeNotifierProvider(create: (_) => OnboardingViewModel()),
        ChangeNotifierProvider(create: (_) => InviteViewModel()),
        ChangeNotifierProvider(create: (_) => QuestPomodoroViewModel()),
        ChangeNotifierProvider(create: (_) => QuestPersonalCreateViewModel()),
        ChangeNotifierProvider(create: (_) => AnalysisViewModel()),
        ChangeNotifierProvider(create: (_) => QuestPartyCreateViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
      ],
      child: const MyApp(),
    ),
  );

  /// ✅ 앱이 완전히 뜬 뒤에 푸시 리스너 연결
  if (hasAgreed) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await NotificationService.init();
      await FCMService.initFCM();
    });
  }
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<bool> _hasAgreedPermissions;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  Future<bool> _checkPermissionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasAgreedPermissions') ?? false;
  }

  Future<void> _handleInviteLink(Uri uri) async {
    // /invite.html?code=xxx 형식에서 code 추출
    if (uri.path == '/invite.html' && uri.queryParameters.containsKey('code')) {
      final code = uri.queryParameters['code'];
      if (code != null) {
        // 초대 수락 API 호출
        final result = await MainpageService().acceptFriendInvite(code);

        if (result != null && result['success'] == true) {
          // 성공 메시지 표시
          if (mounted && navigatorKey.currentContext != null) {
            ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? '친구 초대를 수락했습니다!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _hasAgreedPermissions = _checkPermissionStatus();
    _appLinks = AppLinks();

    // 앱이 닫힌 상태에서 링크로 열렸을 때
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleInviteLink(uri);
      }
    });

    // 앱이 열린 상태에서 링크를 받았을 때
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleInviteLink(uri);
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

    return FutureBuilder<bool>(
      future: _hasAgreedPermissions,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
        }

        final hasAgreed = snapshot.data!;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          home: hasAgreed
              ? const LoginScreen() // ✅ 이미 동의했다면 로그인 화면
              : const PermissionRequestScreen(), // ✅ 처음 실행 시 권한 동의 화면
          navigatorObservers: [
            FirebaseAnalyticsObserver(analytics: analytics),
          ],
          routes: {
            '/terms': (context) => const TermsAgreementScreen(),
            '/main': (context) => const MainNavigationScreen(),
            '/onboarding': (context) => OnboardingScreen(),
          },
        );
      },
    );
  }
}
