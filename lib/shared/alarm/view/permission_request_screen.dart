import 'dart:io'; // Platform.isIOS / Platform.isAndroid를 위해 필요
import 'package:flutter/services.dart'; // 오타 수정
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../core/fcm/fcm_service.dart';
import '../../../features/auth/view/login_screen.dart';
import '../../../features/profile/service/notification_service.dart';

class PermissionRequestScreen extends StatelessWidget {
  const PermissionRequestScreen({super.key});

  // --- 1. 권한 요청 로직 수정 ---
  // 알림 권한을 선택사항으로 변경 (거부해도 앱 사용 가능)
  Future<void> _requestPermissions(BuildContext context) async {
    bool notificationGranted = false;

    if (Platform.isAndroid) {
      // --- Android 로직: 알림만 요청 (전화 권한 제거) ---
      final notifStatus = await Permission.notification.request();
      notificationGranted = notifStatus.isGranted;
    } else if (Platform.isIOS) {
      // --- iOS 로직 (알림만 요청) ---
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      notificationGranted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    }

    // --- 알림 허용 여부와 관계없이 다음 화면으로 이동 ---
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasAgreedPermissions', true);

    // 알림 권한이 허용된 경우에만 FCM 초기화
    if (notificationGranted) {
      await NotificationService.init();
      await FCMService.initFCM();
    }

    // context가 mounted 상태인지 확인 (비동기 작업 후 안전한 화면 전환)
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  // 나중에 하기 버튼 클릭 시 (권한 요청 없이 바로 다음 화면으로)
  Future<void> _skipPermissions(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasAgreedPermissions', true);

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 151.5),
            Column(
              children: [
                const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '퀘스트 알림을 받으시려면\n',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: '알림 권한을 허용',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF5C2EFF),
                        ),
                      ),
                      TextSpan(
                        text: '해주세요!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // 알림 권한 UI (선택사항)
                Row(
                  children: const [
                    Icon(Icons.notifications_none, color: Color(0xFF7958FF)),
                    SizedBox(width: 10),
                    Text('알림 ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('(선택)',
                        style: TextStyle(
                            fontSize: 14, color: Color(0xFF999999), fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 40),
                const Text(
                  '• 알림 권한을 허용하시면 퀘스트 시작/종료 알림을 받을 수 있습니다.\n'
                      '• 알림 권한을 거부하셔도 서비스를 정상적으로 이용할 수 있습니다.\n'
                      '• 휴대폰 설정 > 앱 또는 애플리케이션 관리에서 권한을 변경할 수 있습니다.',
                  style: TextStyle(fontSize: 14, height: 1.6),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 151.5),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _requestPermissions(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4C1FFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        '알림 허용',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => _skipPermissions(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF4C1FFF)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        '나중에',
                        style: TextStyle(
                          color: Color(0xFF4C1FFF),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

