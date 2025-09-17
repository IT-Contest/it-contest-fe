import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:it_contest_fe/shared/quest_create_form/title_input.dart';
import 'package:it_contest_fe/shared/quest_create_form/priority_section/priority.dart';
import 'package:it_contest_fe/shared/quest_create_form/category_input.dart';
import 'package:it_contest_fe/shared/quest_create_form/date_time_section.dart';
import 'package:it_contest_fe/shared/ad_banner.dart';
import 'package:it_contest_fe/shared/quest_create_form/party_title_input.dart';

import 'package:it_contest_fe/features/quest/viewmodel/quest_party_create_viewmodel.dart';
import 'package:it_contest_fe/shared/widgets/quest_creation_modal.dart';

import '../../../shared/interstitial_ad_service.dart';
import '../../friends/view/all_friends_page.dart';
import '../../friends/viewmodel/friend_viewmodel.dart';

class QuestPartyCreateScreen extends StatefulWidget {
  const QuestPartyCreateScreen({super.key});

  @override
  State<QuestPartyCreateScreen> createState() => _QuestPartyCreateScreenState();
}

class _QuestPartyCreateScreenState extends State<QuestPartyCreateScreen> {
  String _title = '';
  int _priority = 0;
  String? _period;
  List<String> _categories = [];
  DateTime? _date;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<QuestPartyCreateViewModel>();
    final friendVM = context.watch<FriendViewModel>();
    final friends = friendVM.friends; // FriendViewModel에서 가져오기
    final hasFriends = friends.isNotEmpty;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: WillPopScope(
        onWillPop: () async {
          InterstitialAdService.showAd(
            onClosed: () => Navigator.of(context).pop(),
          );
          return false; // 기본 뒤로가기 막기
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 20, color: Colors.black),
              onPressed: () {
                InterstitialAdService.showAd(
                  onClosed: () => Navigator.of(context).pop(),
                );
              },
            ),
            title: const Text(
              '파티 퀘스트 생성',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(
                color: const Color(0xFFB7B7B7),
                height: 1.0,
              ),
            ),
            surfaceTintColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. 파티명
                PartyTitleInput(onChanged: (value) => setState(() => _title = value)),
                const SizedBox(height: 16),

                // 2. 퀘스트 제목
                QuestTitleInput(onChanged: (value) => setState(() => _title = value)),
                const SizedBox(height: 16),

                // 3. 우선순위
                QuestPrioritySection(
                  onPriorityChanged: (value) => setState(() => _priority = value),
                  onPeriodChanged: (value) => setState(() => _period = value),
                  showTipBox: false,
                ),
                const SizedBox(height: 16),

                // 4. 카테고리
                CategoryInput(onChanged: (value) => setState(() => _categories = value)),
                const SizedBox(height: 16),

                // 5. 날짜 및 시간
                DateTimeSection(
                  questType: vm.questType, // 퀘스트 타입 전달
                  onStartDateChanged: vm.setStartDate,
                  onDueDateChanged: vm.setDueDate,
                  onStartTimeChanged: vm.setStartTime,
                  onEndTimeChanged: vm.setEndTime,
                ),
                const SizedBox(height: 32),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 제목
                    const Text(
                      "파티원 초대",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // 🔹 버튼 (제목 바로 밑)
                    SizedBox(
                      width: 123,
                      height: 46,
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: 파티 초대하기 로직
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Color(0xFFBDBDBD), // 텍스트 색
                          side: const BorderSide(
                            color: Color(0xFFBDBDBD), // Gray400 (#BDBDBD)
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // round 정도 (8이 Figma 기본)
                          ),
                          padding: EdgeInsets.zero, // SizedBox 크기 그대로 쓰게 하기
                        ),
                        child: const Text(
                          "파티 초대하기",
                          style: TextStyle(
                            fontSize: 14,

                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // 🔹 친구 목록 Row
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

                        // ✅ 더보기 버튼
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
                                  offset: const Offset(1.5, 0), // 🔹 오른쪽으로 1.5px 이동 (눈으로 맞추는 값)
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
                  ],
                ),
                const SizedBox(height: 50),

                // 완료 시 EXP 지급 안내
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFC2C2C2), width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text.rich(
                      TextSpan(
                        text: '완료시 ',
                        style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF9B9B9B),
                            fontWeight: FontWeight.w600),
                        children: [
                          TextSpan(
                            text: '0,000exp',
                            style: TextStyle(
                                color: Color(0xFF7958FF),
                                fontWeight: FontWeight.w800),
                          ),
                          TextSpan(text: ' 지급'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 26),

                // 6. 생성 완료 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: vm.isLoading
                        ? null
                        : () async {
                      final success = await vm.createPartyQuest();
                      if (success) {
                        InterstitialAdService.showAd(
                          onClosed: () {
                            QuestCreationModal.show(
                              context,
                              onClose: () {
                                Navigator.pushReplacementNamed(context, '/main');
                              },
                            );
                          },
                        );
                      } else if (vm.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(vm.errorMessage!)),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7958FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: vm.isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                        : const Text(
                      "생성 완료",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const AdBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
