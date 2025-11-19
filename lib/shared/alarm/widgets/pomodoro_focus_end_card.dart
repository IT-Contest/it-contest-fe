import 'package:flutter/material.dart';

import 'notification_card.dart';

class PomodoroFocusEndCard extends StatelessWidget {
  const PomodoroFocusEndCard({super.key});

  @override
  Widget build(BuildContext context) {
    return NotificationCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "뽀모도로 집중 모드 종료",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7958FF),
            ),
          ),
          SizedBox(height: 6),
          Text(
            "0회차 집중모드가 종료되었어요!\n5분 간의 휴식을 취해보세요 :)",
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),
          SizedBox(height: 6),
          Text(
            "남은 시간 (04분 30초)",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
