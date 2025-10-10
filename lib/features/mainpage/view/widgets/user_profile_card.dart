import 'package:flutter/material.dart';
import 'package:it_contest_fe/features/mainpage/model/mainpage_user_response.dart';

class UserProfileCard extends StatelessWidget {
  final MainpageUserResponse user;

  const UserProfileCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withOpacity(0.1),
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

      /// Column: 상단 GIF + 프로필 정보
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          AspectRatio(
            aspectRatio: 1.01, // 화면 비율 (너비:높이). 1.5 = 가로가 세로보다 1.5배
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                'assets/images/seed.gif',
                fit: BoxFit.cover, // 카드 상단을 꽉 채움
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 프로필 아바타
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: user.profileImageUrl.isNotEmpty
                      ? Image.network(
                          user.profileImageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/images/logo_3d.png', // 기본 이미지
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                ),

                const SizedBox(width: 16),

                /// 닉네임, 레벨, 경험치, 골드
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 닉네임 + 레벨
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            user.nickname,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Color(0xFF6737F4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'LV.${user.level}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      /// 경험치 바
                      Row(
                        children: [
                          Expanded(
                            flex: 7,
                            child: Container(
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: Color(0xFF6737F4), width: 2),
                              ),
                              child: Stack(
                                children: [
                                  FractionallySizedBox(
                                    widthFactor: user.expPercent / 100,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(0x996737F4),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${user.expPercent}%',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6737F4),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      /// 경험치 + 골드
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset('assets/icons/widget_icon.png',
                                  width: 18, height: 18),
                              const SizedBox(width: 4),
                              const Text(
                                '누적 경험치 ',
                                style: TextStyle(
                                    color: Color(0xFF6737F4), fontSize: 13),
                              ),
                              Text(
                                '${user.exp}',
                                style: const TextStyle(
                                  color: Color(0xFF6737F4),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Image.asset('assets/icons/gold_icon.png',
                                  width: 18, height: 18),
                              const SizedBox(width: 4),
                              const Text(
                                '골드 ',
                                style: TextStyle(
                                    color: Color(0xFF6737F4), fontSize: 13),
                              ),
                              Text(
                                '${user.gold}',
                                style: const TextStyle(
                                  color: Color(0xFF6737F4),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
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
          ),
        ],
      ),
    );
  }
}
