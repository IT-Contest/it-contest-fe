import 'package:flutter/material.dart';
import 'package:it_contest_fe/shared/widgets/custom_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../profile/view/account_settings_page.dart';
import '../../profile/view/notification_settings_page.dart';
import '../../terms/view/terms_detail_screen.dart';
import '../model/mainpage_user_response.dart';
import '../service/mainpage_service.dart';

class ProfilePageWidget extends StatelessWidget {
  const ProfilePageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: FutureBuilder<MainpageUserResponse>(
        future: MainpageService().fetchMainUserProfile(), // ✅ API 호출
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("프로필 정보를 불러올 수 없습니다."));
          }

          final user = snapshot.data!; // ✅ MainpageUserResponse

          return Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFF3FAFF),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ 서버에서 받은 프로필 이미지
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: user.profileImageUrl.isNotEmpty
                            ? NetworkImage(user.profileImageUrl)
                            : const AssetImage('assets/images/logo_3d.png')
                        as ImageProvider,
                        backgroundColor: Colors.transparent,
                      ),
                      const SizedBox(width: 16),
                      // ✅ 서버에서 받은 닉네임
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.nickname,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7958FF),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "LV.${user.level} • EXP ${user.expPercent}%", // 보너스 표시 가능
                            style: const TextStyle(
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

                // ✅ 이후 메뉴는 그대로 유지
                Expanded(
                  child: ListView(
                    children: [
                      _buildMenuItem("계정 설정", onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AccountSettingsPage()),
                        );
                      }),
                      _buildMenuItem("알림 설정", onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              const NotificationSettingsPage()),
                        );
                      }),
                      _buildMenuItem("서비스 이용약관", onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TermsDetailScreen(
                              title: "서비스 이용약관",
                              url: "/terms/service-terms-v1.html",
                            ),
                          ),
                        );
                      }),
                      _buildMenuItem("개인정보 처리방침", onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TermsDetailScreen(
                              title: "개인정보 처리방침",
                              url: "/terms/privacy-policy-v1.html",
                            ),
                          ),
                        );
                      }),
                      _buildMenuItem("문의하기", onTap: () async {
                        final Uri url = Uri.parse('https://pf.kakao.com/_ZQjUn');
                        if (!await launchUrl(url,
                            mode: LaunchMode.externalApplication)) {
                          throw Exception('카카오톡 채널 열기 실패: $url');
                        }
                      }),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget _buildMenuItem(String title, {VoidCallback? onTap}) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing:
      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
