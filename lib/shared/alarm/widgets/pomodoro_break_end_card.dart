import 'package:flutter/material.dart';

import 'notification_card.dart';

class PomodoroBreakEndCard extends StatelessWidget {
  const PomodoroBreakEndCard({super.key});

  @override
  Widget build(BuildContext context) {
    return NotificationCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "뽀모도로 휴식 모드 종료",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7958FF),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "0회차가 종료되었어요!\n다음 뽀모도로 세션을 진행할까요?",
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          const Text(
            "완료시 0,000exp, 0,000 골드 지급",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7958FF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {},
                  child: const Text(
                      "진행하기",
                    style: TextStyle(
                      color: Colors.white
                    )
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF7958FF),
                    side: const BorderSide(color: Color(0xFF7958FF)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {},
                  child: const Text("그만하기"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
