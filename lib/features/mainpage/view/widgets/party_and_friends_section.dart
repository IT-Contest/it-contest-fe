import 'package:flutter/material.dart';
import 'package:it_contest_fe/features/mainpage/view/widgets/invite_modal.dart';
import 'package:provider/provider.dart';

import '../../../../shared/analytics/service/analytics_service.dart';
import '../../../friends/view/all_friends_page.dart';
import '../../../friends/viewmodel/friend_viewmodel.dart';
import '../../../quest/view/party_join_page.dart';
import '../../../quest/view/quest_party_create_screen.dart';

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
                      onPressed: () {
                        // Analytics 이벤트 기록
                        AnalyticsService.logFriendInvited("main_friends_section");

                        // 기존 친구초대 모달 실행
                        InviteModal.show(context);
                      },
                      icon: const Icon(Icons.add, color: Colors.black54, size: 18),
                      label: const Text(
                        '친구추가',
                        style: TextStyle(color: Colors.black54),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 32),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 친구 목록 최대 3명만
                Row(
                  children: [
                    if (hasFriends)
                      ...friends.take(3).map((f) => Container(
                        margin: const EdgeInsets.only(right: 12), // ← Column 전체에 margin
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center, // ← 가운데 정렬
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(shape: BoxShape.circle),
                              clipBehavior: Clip.hardEdge,
                              child: Image.network(
                                f.profileImageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset('assets/images/logo_3d.png', fit: BoxFit.cover);
                                },
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 48, // ← 아바타와 같은 너비 확보
                              child: Text(
                                f.nickname,
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis, // 닉네임 길 경우 줄임표
                              ),
                            ),
                          ],
                        ),
                      )),

                    // 더보기 버튼은 항상 표시
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AllFriendsPage()),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFF5C2EFF),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '+${friends.length}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 48,
                            child: Transform.translate(
                              offset: const Offset(1.5, 0),
                              child: const Text(
                                '더보기',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
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
                        onPressed: () {
                          // ✅ 파티 퀘스트 생성 이벤트 기록
                          AnalyticsService.logPartyQuestCreated();

                          // ✅ 기존 네비게이션 로직
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const QuestPartyCreateScreen()),
                          );
                        },
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
                        onPressed: () {
                          // 🔹 Analytics 이벤트 기록
                          AnalyticsService.logPartyQuestJoinClicked();

                          // 🔹 기존 네비게이션 로직
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PartyJoinPage()),
                          );
                        },
                        icon: Image.asset('assets/icons/party_in.png', width: 20, height: 20),
                        label: const Text(
                          '파티 퀘스트 참가',
                          style: TextStyle(color: Color(0xFF5C2EFF)),
                        ),
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

