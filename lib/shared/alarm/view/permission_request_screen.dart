import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/fcm/fcm_service.dart';
import '../../../features/auth/view/login_screen.dart';
import '../../../features/profile/service/notification_service.dart';

class PermissionRequestScreen extends StatelessWidget {
  const PermissionRequestScreen({super.key});

  Future<void> _requestNotificationPermission(BuildContext context) async {
    final status = await Permission.notification.request();

    if (status.isGranted) {
      // ✅ 권한 허용됨
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasAgreedPermissions', true);

      await NotificationService.init();
      await FCMService.initFCM();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      // ❌ 허용 안함
      _showDeniedDialog(context);
    }
  }

  void _showDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white, // ✅ 팝업 배경 흰색
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 제목
              const Text(
                '알림 권한이 필요합니다',
                textAlign: TextAlign.center, // ✅ 가운데 정렬
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 16),

              // 본문 내용
              const Text(
                '알림 기능을 사용하려면 권한이 필요합니다.\n\n'
                    '⚙️ [설정] → [앱] → [퀘스트플래너] → [알림] → [허용] 으로 이동하여 권한을 켜주세요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 28),

              // ✅ 버튼 2개 가로 배치
              Row(
                children: [
                  // 설정으로 이동 (보라색)
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () async {
                          await openAppSettings(); // 앱 설정으로 이동
                          SystemNavigator.pop(); // 이동 후 앱 종료
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5C2EFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          '설정으로 이동',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // 앱 종료 (회색)
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () => SystemNavigator.pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE6E6E6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          '앱 종료',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
            // 기존 텍스트/아이콘 UI 그대로 유지
            Column(
              children: const [
                Text.rich(
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
                SizedBox(height: 40),
                Row(
                  children: [
                    Icon(Icons.phone, color: Color(0xFF7958FF)),
                    SizedBox(width: 10),
                    Text('전화 ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('(필수)',
                        style: TextStyle(
                            fontSize: 14, color: Color(0xFF7958FF), fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.notifications_none, color: Color(0xFF7958FF)),
                    SizedBox(width: 10),
                    Text('알림 ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('(필수)',
                        style: TextStyle(
                            fontSize: 14, color: Color(0xFF7958FF), fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 40),
                Text(
                  '• 필수 접근 권한에 동의하지 않으실 경우 서비스 가입 및 이용이 제한되어 앱이 종료됩니다.\n'
                      '• 선택적 접근 권한은 해당 기능을 사용할 때 허용이 필요하며, 비허용 하셔도 해당 기능 외 서비스 이용이 가능합니다.\n'
                      '• 휴대폰 설정 > 앱 또는 애플리케이션 관리에서 권한을 변경할 수 있습니다.',
                  style: TextStyle(fontSize: 14, height: 1.6),
                ),
              ],
            ),

            // 확인 버튼 그대로 유지
            Padding(
              padding: const EdgeInsets.only(bottom: 151.5),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _requestNotificationPermission(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C1FFF),
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
