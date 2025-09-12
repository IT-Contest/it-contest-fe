import 'package:flutter/material.dart';

class QuestCompletionModal extends StatelessWidget {
  final int expReward;
  final int goldReward;
  final VoidCallback? onClose;

  const QuestCompletionModal({
    super.key,
    required this.expReward,
    required this.goldReward,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 제목과 닫기 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Spacer(), // 왼쪽 공간
              const Text(
                '퀘스트 완료',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: onClose ?? () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.close,
                      color: Colors.black,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 완료 메시지
          const Text(
            '퀘스트를 완료했습니다. 보상이 지급됩니다.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // 보상 카드들
          Row(
            children: [
              // 경험치 카드
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8F73FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/icons/arrow_circle_up.png',
                            width: 30,
                            height: 30,
                            color: const Color(0xFF8F73FF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '경험치 + $expReward exp',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // 골드 카드
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF8F73FF), width: 2),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/icons/database.png',
                            width: 30,
                            height: 30,
                            color: const Color(0xFF8F73FF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '+ $goldReward 골드',
                        style: const TextStyle(
                          color: Color(0xFF8F73FF),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static void show(
    BuildContext context, {
    required int expReward,
    required int goldReward,
    VoidCallback? onClose,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => QuestCompletionModal(
        expReward: expReward,
        goldReward: goldReward,
        onClose: onClose,
      ),
    );
  }
}