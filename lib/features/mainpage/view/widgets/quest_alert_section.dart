import 'package:flutter/material.dart';

class QuestAlertSection extends StatelessWidget {
  const QuestAlertSection({super.key});

  @override
  Widget build(BuildContext context) {
    final quests = [
      {
        'title': '일일퀘스트',
        'count': '10개 남음',
        'icon': 'assets/icons/file_1.png',
        'bgColor': Color(0xFFF3B3F5),
      },
      {
        'title': '주간퀘스트',
        'count': '10개 남음',
        'icon': 'assets/icons/file_2.png',
        'bgColor': Color(0xFF9CE297),
      },
      {
        'title': '월간퀘스트',
        'count': '10개 남음',
        'icon': 'assets/icons/file_3.png',
        'bgColor': Color(0xFF7CB6F5),
      },
      {
        'title': '연간퀘스트',
        'count': '10개 남음',
        'icon': 'assets/icons/file_4.png',
        'bgColor': Color(0xFF8D71E7),
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withOpacity(0.1), // 💡 살짝 투명한 회색 테두리
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // 🟣 가운데 정렬
        children: [
          const Text(
            '퀘스트 알림',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: quests.map((q) {
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: q['bgColor'] as Color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          q['icon'] as String,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      q['title'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      q['count'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6737F4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
