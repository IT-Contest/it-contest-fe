import 'package:flutter/material.dart';

class PomodoroFocusModeEndingCard extends StatelessWidget {
  final int round; // 회차
  final String remainingTime; // 남은 시간 표시 (예: "04분 30초")

  const PomodoroFocusModeEndingCard({
    super.key,
    required this.round,
    required this.remainingTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0)), // 연한 테두리
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "뽀모도로 집중 모드 종료",
              style: TextStyle(
                color: Color(0xFF7958FF), // 보라색
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "${round}회차 집중모드가 종료되었어요!\n5분 간의 휴식을 취해보세요 :)",
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "남은 시간 ($remainingTime)",
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
