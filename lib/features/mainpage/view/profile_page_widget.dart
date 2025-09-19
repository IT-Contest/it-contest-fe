import 'package:flutter/material.dart';
import 'package:it_contest_fe/shared/widgets/custom_app_bar.dart';
import 'package:it_contest_fe/shared/widgets/bottom_nav_bar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../profile/view/account_settings_page.dart';
import '../../profile/view/notification_settings_page.dart';
import '../../terms/view/terms_detail_screen.dart';

class ProfilePageWidget extends StatelessWidget {
  const ProfilePageWidget({super.key});

  Future<void> _launchKakaoLink() async {
    final Uri url = Uri.parse('https://pf.kakao.com/_ZQjUn');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('카카오톡 채널 열기 실패: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF3FAFF), // ✅ 배경 하늘색
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),

            // ✅ 프로필 사진 + 이름/이메일을 Row로 배치
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start, // 세로축 위쪽 기준
                children: [
                  Container(
                    padding: const EdgeInsets.all(2), // 살짝만 여백
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.4), // ✅ 연한 회색
                        width: 1,                            // ✅ 얇은 두께
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage('assets/images/logo.jpg'),
                      backgroundColor: Colors.transparent,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "애라",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7958FF),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "user@example.com",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ✅ 메뉴 리스트
            Expanded(
              child: ListView(
                children: [
                  _buildMenuItem(
                    "계정 설정",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AccountSettingsPage()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    "알림 설정",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationSettingsPage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    "서비스 이용약관",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TermsDetailScreen(
                            title: "서비스 이용약관",
                            url: "/terms/service-terms-v1.html", // 서버 상대경로
                          ),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    "개인정보 처리방침",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TermsDetailScreen(
                            title: "개인정보 처리방침",
                            url: "/terms/privacy-policy-v1.html", // 서버 상대경로
                          ),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                      "문의하기",
                      onTap: _launchKakaoLink
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ✅ 저작권 표시
            const Align(
              alignment: Alignment.center,
              child: Text(
                "© 2025 QuestPlanner. All rights reserved.",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ✅ 메뉴 아이템 위젯
  static Widget _buildMenuItem(String title, {VoidCallback? onTap}) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap, // ← 외부에서 콜백 전달 가능
    );
  }

}
