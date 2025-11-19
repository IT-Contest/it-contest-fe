import 'package:flutter/material.dart';

class PomodoroBreakModeEndingCard extends StatelessWidget {
  final int round; // 회차
  final int expReward; // 보상 경험치
  final int goldReward; // 보상 골드
  final VoidCallback onContinue; // 진행하기 버튼
  final VoidCallback onStop; // 그만하기 버튼

  const PomodoroBreakModeEndingCard({
    super.key,
    required this.round,
    required this.expReward,
    required this.goldReward,
    required this.onContinue,
    required this.onStop,
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
              "뽀모도로 휴식 모드 종료",
              style: TextStyle(
                color: Color(0xFF7958FF),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "${round}회차가 종료되었어요!\n다음 뽀모도로 세션을 진행할까요?",
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "완료시 ${expReward}exp, ${goldReward} 골드 지급",
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7958FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: onContinue,
                    child: const Text(
                      "진행하기",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF7958FF)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: onStop,
                    child: const Text(
                      "그만하기",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7958FF),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
