import 'package:flutter/material.dart';
import 'package:it_contest_fe/shared/alarm/widgets/daily_quest_card.dart';
import 'package:it_contest_fe/shared/alarm/widgets/party_invite_card.dart';
import 'package:it_contest_fe/shared/alarm/widgets/pomodoro_break_end_card.dart';
import 'package:it_contest_fe/shared/alarm/widgets/pomodoro_focus_end_card.dart';

class NotificationPage extends StatelessWidget {
  final bool hasNotifications;

  const NotificationPage({super.key, this.hasNotifications = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: Colors.white,
              child: SafeArea(
                child: SizedBox(
                  height: 56,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        "알림",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Image.asset(
                          hasNotifications
                              ? "assets/icons/alarm_btn2.png"
                              : "assets/icons/alarm_btn1.png",
                          width: 28,
                          height: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFB7B7B7)),
          ],
        ),
      ),
      body: hasNotifications
          ? ListView(
        children: const [
          PartyInviteCard(),
          PomodoroFocusEndCard(),
          PomodoroBreakEndCard(),
          DailyQuestCard(),
        ],
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/icons/alarm_empty.png",
              width: 208,
              height: 172,
            ),
            const SizedBox(height: 16),
            const Text(
              "현재 알림이 없습니다.",
              style: TextStyle(
                fontFamily: "SUITE",   // SUITE 폰트 적용
                fontSize: 20,          // Figma Title 스타일 크기
                height: 1.5,           // 20px * 1.5 = 30px line height
                fontWeight: FontWeight.w600, // SemiBold (Figma Title 스타일 보통 SemiBold)
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
