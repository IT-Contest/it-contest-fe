import 'package:flutter/material.dart';

import '../../../friends/view/all_friends_page.dart';
import '../../../quest/view/party_create_page.dart';
import '../../../quest/view/party_join_page.dart';

class PartyAndFriendsSection extends StatelessWidget {
  const PartyAndFriendsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final friends = [
      {'name': '마지 심슨', 'image': 'assets/images/marge.png'},
      {'name': '바트 심슨', 'image': 'assets/images/bart.png'},
      {'name': '리사 심슨', 'image': 'assets/images/lisa.png'},
      {'name': '+3', 'image': ''},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 & 친구추가
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '파티 & 친구',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF5C2EFF),
                ),
              ),
              TextButton.icon(
                onPressed: null,
                icon: const Icon(Icons.add, color: Colors.black54, size: 18),
                label: const Text(
                  '친구추가',
                  style: TextStyle(color: Colors.black54),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),

            ],
          ),
          const SizedBox(height: 8),

          // 친구 목록
          Row(
            children: friends.map((friend) {
              if (friend['name'] == '+3') {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AllFriendsPage()),
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: const BoxDecoration(
                          color: Color(0xFF5C2EFF),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '+3',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text('더보기', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              } else {
                return Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF5C2EFF), width: 1),
                        image: DecorationImage(
                          image: AssetImage(friend['image']!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(friend['name']!, style: const TextStyle(fontSize: 12)),
                  ],
                );
              }
            }).toList(),
          ),


          const SizedBox(height: 12),

          // 버튼 2개
          Row(
            children: [
              // 파티 생성 (채움 버튼)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PartyCreatePage()),
                    );
                  },
                  icon: Image.asset('assets/icons/party_add.png', width: 20, height: 20),
                  label: const Text(
                    '파티 생성',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C2EFF),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )
              ,
              const SizedBox(width: 12),

              // 파티 참가 (테두리 버튼)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PartyJoinPage()),
                    );
                  },
                  icon: Image.asset('assets/icons/party_in.png', width: 20, height: 20),
                  label: const Text(
                    '파티 참가',
                    style: TextStyle(color: Color(0xFF5C2EFF)),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFF5C2EFF), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
