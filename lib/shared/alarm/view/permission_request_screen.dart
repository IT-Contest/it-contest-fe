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
  // 플랫폼(iOS/Android)에 따라 다른 로직을 수행하도록 수정
  Future<void> _requestPermissions(BuildContext context) async {
    bool permissionsGranted = false;

    if (Platform.isAndroid) {
      // --- Android 로직 (기존과 동일) ---
      final phoneStatus = await Permission.phone.request();
      if (!phoneStatus.isGranted) {
        _showDeniedDialog(context, isPhonePermission: true);
        return;
      }

      final notifStatus = await Permission.notification.request();
      if (notifStatus.isGranted) {
        permissionsGranted = true;
      } else {
        _showDeniedDialog(context, isPhonePermission: false);
      }
    } else if (Platform.isIOS) {
      // --- iOS 로직 (알림만 요청) ---
      // iOS에서는 FirebaseMessaging을 사용하여 알림 권한 요청
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        permissionsGranted = true;
      } else {
        // iOS는 알림 권한만 거부될 수 있음
        _showDeniedDialog(context, isPhonePermission: false);
      }
    }

    // --- 두 플랫폼 공통: 모든 권한 허용 시 ---
    if (permissionsGranted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasAgreedPermissions', true);

      await NotificationService.init();
      await FCMService.initFCM();

      // context가 mounted 상태인지 확인 (비동기 작업 후 안전한 화면 전환)
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  // --- 2. 팝업창 로직 수정 ---
  // 두 개의 팝업 함수를 하나로 합치고, 플랫폼별로 다른 텍스트를 보여주도록 수정
  void _showDeniedDialog(BuildContext context, {required bool isPhonePermission}) {
    String title;
    String content;

    if (Platform.isAndroid) {
      // --- Android 팝업 텍스트 ---
      if (isPhonePermission) {
        title = '전화 권한이 필요합니다';
        content = '전화 기능을 사용하려면 권한이 필요합니다.\n\n'
            '⚙️ [설정] → [앱] → [퀘스트플래너] → [전화] → [허용] 으로 이동해 주세요.';
      } else {
        title = '알림 권한이 필요합니다';
        content = '알림 기능을 사용하려면 권한이 필요합니다.\n\n'
            '⚙️ [설정] → [앱] → [퀘스트플래너] → [알림] → [허용] 으로 이동해 주세요.';
      }
    } else {
      // --- iOS 팝업 텍스트 ---
      // iOS는 '전화' 권한을 요청하지 않으므로 '알림' 텍스트만 필요
      title = '알림 권한이 필요합니다';
      content = '퀘스트 알림을 받으려면 권한이 필요합니다.\n\n'
          '⚙️ [설정] → [퀘스트플래너] → [알림] → [알림 허용] 으로 이동해 주세요.';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 16),
              Text(
                content,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.6),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () async {
                          await openAppSettings(); // 설정 화면으로 이동
                          SystemNavigator.pop();   // 앱 종료
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5C2EFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('설정으로 이동',
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () => SystemNavigator.pop(), // 앱 종료
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE6E6E6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('앱 종료',
                            style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
                        text: '편리한 서비스 이용을 위해\n',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: '접근 권한을 허용',
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

                // --- 3. UI 수정 ---
                // '전화' 권한 UI는 Android에서만 보이도록 수정
                if (Platform.isAndroid)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.phone, color: Color(0xFF7958FF)),
                          SizedBox(width: 10),
                          Text('전화 ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('(필수)',
                              style: TextStyle(
                                  fontSize: 14, color: Color(0xFF7958FF), fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),

                // '알림' 권한 UI는 공통으로 표시
                Row(
                  children: const [
                    Icon(Icons.notifications_none, color: Color(0xFF7958FF)),
                    SizedBox(width: 10),
                    Text('알림 ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('(필수)',
                        style: TextStyle(
                            fontSize: 14, color: Color(0xFF7958FF), fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 40),
                const Text(
                  '• 필수 접근 권한에 동의하지 않으실 경우 서비스 가입 및 이용이 제한되어 앱이 종료됩니다.\n'
                      '• 선택적 접근 권한은 해당 기능을 사용할 때 허용이 필요하며, 비허용 하셔도 해당 기능 외 서비스 이용이 가능합니다.\n'
                      '• 휴대폰 설정 > 앱 또는 애플리케이션 관리에서 권한을 변경할 수 있습니다.',
                  style: TextStyle(fontSize: 14, height: 1.6),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 151.5),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  // --- 4. 버튼 동작 수정 ---
                  // 수정된 _requestPermissions 함수를 호출
                  onPressed: () => _requestPermissions(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C1FFF),
                    // --- 5. 오타 수정 ---
                    // RoundedRectangleGBorder -> RoundedRectangleBorder
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

