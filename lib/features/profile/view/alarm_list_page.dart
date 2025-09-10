import 'package:flutter/material.dart';

class NotificationListPage extends StatelessWidget {
  const NotificationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "알림",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: ImageIcon(
              AssetImage("assets/icons/alarm_btn2.png"),
              color: Color(0xFF7958FF),
              size: 24,
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, color: Color(0xFFE0E0E0)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 파티 초대 알림
          _buildNotificationCard(
            title: "파티에 참가해보세요!",
            content:
            "애라님이 파티에 참가하도록 초대했어요!\n계획을 완료하면 총 0,000exp를 받을 수 있어요!",
            subContent: "초대장 만료시간 : 09분 58초",
            trailing: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE0E0E0), // 🔹 원 배경 (밝은 회색)
              ),
              child: const Icon(
                Icons.keyboard_arrow_down, // 🔽 아이콘
                size: 20,
                color: Colors.black, // 🔹 아이콘 색
              ),
            ),
          ),

          // 뽀모도로 집중 모드 종료
          _buildNotificationCard(
            title: "뽀모도로 집중 모드 종료",
            content: "0회차 집중모드가 종료되었어요!\n5분 간의 휴식을 취해보세요 :)",
            subContent: "남은 시간 (04분 30초)",
          ),

          // 뽀모도로 휴식 모드 종료
          _buildNotificationCard(
            title: "뽀모도로 휴식 모드 종료",
            content: "0회차가 종료되었어요!\n다음 뽀모도로 세션을 진행할까요?",
            subContent: "완료시 0,000exp, 0,000 골드 지급",
            actions: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7958FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "진행하기",
                      style: TextStyle(color: Colors.white), // 🔹 글씨 흰색
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF7958FF),
                      side: const BorderSide(color: Color(0xFF7958FF)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("그만하기"),
                  ),
                ),
              ],
            ),
          ),

          // 일일 퀘스트 알림
          _buildNotificationCard(
            title: "일일 퀘스트",
            content:
            "오늘 수행해야할 00개의 퀘스트가 있어요!\n오늘의 퀘스트를 수행하고 혜택을 받아가세요!",
            actions: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7958FF),
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "혜택 받으러 가기",
                style: TextStyle(color: Colors.white), // 🔹 글씨 흰색
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 공통 알림 카드 위젯
  Widget _buildNotificationCard({
    required String title,
    required String content,
    String? subContent,
    Widget? actions,
    Widget? trailing,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white, // 🔹 카드 배경 흰색
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7958FF),
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
            const SizedBox(height: 8),
            Text(content, style: const TextStyle(fontSize: 14)),
            if (subContent != null) ...[
              const SizedBox(height: 8),
              Text(
                subContent,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ],
            if (actions != null) ...[
              const SizedBox(height: 12),
              actions,
            ]
          ],
        ),
      ),
    );
  }
}
