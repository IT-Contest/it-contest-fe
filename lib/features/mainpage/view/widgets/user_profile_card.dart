import 'package:flutter/material.dart';

class UserProfileCard extends StatelessWidget {
  const UserProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withOpacity(0.1), // ✅ 살짝 투명한 회색 테두리
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 프로필 + 닉네임 + 레벨
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.asset(
                  'assets/images/simpson.jpg',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '호머 심슨',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Color(0xFF6737F4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'LV.7',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ✅ 경험치 바 + EXP %
                    Row(
                      children: [
                        Expanded(
                          flex: 7,
                          child: Container(
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Color(0xFF6737F4), width: 2),
                            ),
                            child: Stack(
                              children: [
                                FractionallySizedBox(
                                  widthFactor: 0.67,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Color(0x996737F4), // 투명 보라
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'EXP 67%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6737F4),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // ✅ 누적 경험치 + 골드
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/icons/widget_icon.png',
                              width: 18,
                              height: 18,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '누적 경험치 ',
                              style: TextStyle(color: Color(0xFF6737F4), fontSize: 13),
                            ),
                            const Text(
                              '100,000',
                              style: TextStyle(
                                  color: Color(0xFF6737F4),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Image.asset(
                              'assets/icons/gold_icon.png',
                              width: 18,
                              height: 18,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '골드 ',
                              style: TextStyle(color: Color(0xFF6737F4), fontSize: 13),
                            ),
                            const Text(
                              '2,450',
                              style: TextStyle(
                                  color: Color(0xFF6737F4),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
