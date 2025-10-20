import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../features/auth/view/login_screen.dart';

class PermissionRequestScreen extends StatelessWidget {
  const PermissionRequestScreen({super.key});

  Future<void> _savePermissionAgreement(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasAgreedPermissions', true);

    // ✅ 로그인 화면으로 이동
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ 배경 흰색
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 151.5),

            // 본문 타이틀
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
                          color: Color(0xFF5C2EFF), // primary/700
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

                // 전화 (굵게)
                Row(
                  children: const [
                    Icon(Icons.phone, color: Color(0xFF7958FF)),
                    SizedBox(width: 10),
                    Text(
                      '전화 ',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '(필수)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7958FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 알림 (굵게)
                Row(
                  children: const [
                    Icon(Icons.notifications_none, color: Color(0xFF7958FF)),
                    SizedBox(width: 10),
                    Text(
                      '알림 ',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '(필수)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7958FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // 안내 문구
                const Text(
                  '• 필수 접근 권한에 동의하지 않으실 경우 서비스 가입 및 이용이 제한되어 앱이 종료됩니다.\n'
                      '• 선택적 접근 권한은 해당 기능을 사용할 때 허용이 필요하며, 비허용 하셔도 해당 기능 외 서비스 이용이 가능합니다.\n'
                      '• 휴대폰 설정 > 앱 또는 애플리케이션 관리에서 권한을 변경할 수 있습니다.',
                  style: TextStyle(fontSize: 14, height: 1.6),
                ),
              ],
            ),

            // 확인 버튼
            Padding(
              padding: const EdgeInsets.only(bottom: 151.5),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _savePermissionAgreement(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C1FFF), // primary/800
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
