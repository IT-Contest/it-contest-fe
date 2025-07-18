import 'package:flutter/material.dart';
import 'package:it_contest_fe/features/mainpage/view/widgets/invite_modal.dart';
import 'package:provider/provider.dart';

import '../../../friends/view/all_friends_page.dart';
import '../../../friends/viewmodel/friend_viewmodel.dart';
import '../../../quest/view/party_create_page.dart';
import '../../../quest/view/party_join_page.dart';

class PartyAndFriendsSection extends StatelessWidget {
  const PartyAndFriendsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FriendViewModel()..fetchFriends(),
      child: Consumer<FriendViewModel>(
        builder: (context, viewModel, _) {
          final friends = viewModel.friends;
          final hasFriends = friends.isNotEmpty;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목 & 친구추가
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('친구 목록',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF5C2EFF))),
                    TextButton.icon(
                      onPressed: () => InviteModal.show(context),
                      icon: const Icon(Icons.add, color: Colors.black54, size: 18),
                      label: const Text('친구추가', style: TextStyle(color: Colors.black54)),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 32)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 친구 목록 최대 3명만
                Row(
                  children: [
                    if (hasFriends)
                      ...friends.take(3).map((f) => Column(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: Image.network(
                              f.profileImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/simpson.jpg',
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(f.nickname, style: const TextStyle(fontSize: 12)),
                        ],
                      )),

                    // ✅ 더보기 버튼은 항상 표시
                    GestureDetector(
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
                            child: Center(
                              child: Text(
                                '+${friends.length}', // 항상 friend 수 기반
                                style: const TextStyle(
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
                    ),
                  ],
                ),


                const SizedBox(height: 12),

                // 파티 생성 / 참가 버튼
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PartyCreatePage())),
                        icon: Image.asset('assets/icons/party_add.png', width: 20, height: 20),
                        label: const Text('파티 퀘스트 생성', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5C2EFF),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PartyJoinPage())),
                        icon: Image.asset('assets/icons/party_in.png', width: 20, height: 20),
                        label: const Text('파티 퀘스트 참가', style: TextStyle(color: Color(0xFF5C2EFF))),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFF5C2EFF), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

