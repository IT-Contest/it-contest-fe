import 'package:flutter/material.dart';

import '../../auth/view/login_screen.dart';
import '../service/kakao_account_logout_page.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 전체 배경 흰색
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: Colors.white, // 상단바 흰색
          child: SafeArea(
            child: Column(
              children: [
                // 상단 영역
                SizedBox(
                  height: 56,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                            Icons.arrow_back_ios_new, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          "계정 설정",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // 오른쪽 여백(아이콘 공간 맞춤)
                    ],
                  ),
                ),
                // 구분선
                const Divider(
                    height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          _buildMenuItem(
            "카카오 계정 로그인",
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
          _buildMenuItem(
            "카카오 계정 로그아웃",
            onTap: () async {
              final authService = AuthService();

              try {
                await authService.logout();

                // 로그아웃 성공 후 LoginScreen으로 이동
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              } catch (e) {
                // 에러 처리 (토스트나 다이얼로그 띄워도 됨)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("로그아웃 실패: $e")),
                );
              }
            },
          ),
          _buildMenuItem(
            "회원 탈퇴하기",
            onTap: () {
              AccountSettingsPage.showWithdrawDialog(context);
              // (static 함수로 만들었을 때)
            },
          ),

        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, {VoidCallback? onTap}) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(
          Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap, // ← 외부에서 전달된 onTap 실행
    );
  }

  static void showWithdrawDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "회원을 탈퇴하시면 지금까지 쌓아왔던\n",
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                    TextSpan(
                      text: "경험치와 골드가 모두 사라지며,\n복구할 수 없습니다.\n",
                      style: TextStyle(
                        color: Color(0xFF7958FF),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: "그래도 진행하시겠어요?",
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF7958FF),
                        side: const BorderSide(color: Color(0xFF7958FF)),
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("취소"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7958FF),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final authService = AuthService();
                        Navigator.of(context, rootNavigator: true).pop(); // 다이얼로그 닫기

                        try {
                          await authService.withdraw();
                          Future.microtask(() => showGoodbyeDialog(context)); // 한 프레임 뒤 실행
                        } catch (e) {
                          Future.microtask(() {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("회원 탈퇴 실패: $e")),
                            );
                          });
                        }
                      },
                      child: const Text("탈퇴"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 탈퇴 완료 후 "감사 메시지 다이얼로그"
  static void showGoodbyeDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.waving_hand, size: 48, color: Color(0xFF7958FF)),
              const SizedBox(height: 16),
              const Text(
                "그동안 퀘스트플래너를 이용해주셔서 감사합니다.\n"
                    "다음에는 더 좋은 인연으로 만나뵙길 바랍니다!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7958FF),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(); // 다이얼로그 닫기
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false, // ✅ 스택 초기화
                  );
                },
                child: const Text("확인"),
              ),
            ],
          ),
        );
      },
    );
  }
}