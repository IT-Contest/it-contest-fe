import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:it_contest_fe/features/quest/view/party_invite_page.dart';
import 'package:it_contest_fe/shared/widgets/party_creation_modal.dart';
import 'package:provider/provider.dart';

import 'package:it_contest_fe/shared/quest_create_form/title_input.dart';
import 'package:it_contest_fe/shared/quest_create_form/priority_section/priority.dart';
import 'package:it_contest_fe/shared/quest_create_form/category_input.dart';
import 'package:it_contest_fe/shared/quest_create_form/date_time_section.dart';
import 'package:it_contest_fe/shared/ad_banner.dart';
import 'package:it_contest_fe/shared/quest_create_form/party_title_input.dart';

import 'package:it_contest_fe/features/quest/viewmodel/quest_party_create_viewmodel.dart';

import '../../../shared/advertisement/cauly_interstitial_service.dart';
import '../../../shared/interstitial_ad_service.dart';
import '../../../shared/widgets/party_update_modal.dart';
import '../../friends/model/friend_info.dart';
import '../../friends/view/all_friends_page.dart';
import '../../friends/view/invited_friends_page.dart';
import '../../friends/viewmodel/friend_viewmodel.dart';
import '../model/quest_item_response.dart';
import '../service/admob_service.dart';
import '../viewmodel/quest_tab_viewmodel.dart';

class QuestPartyCreateScreen extends StatefulWidget {
  final QuestItemResponse? quest; // ✅ 수정 모드면 quest 전달
  final List<dynamic> invitedFriends;

  const QuestPartyCreateScreen({
    super.key,
    this.quest,
    this.invitedFriends = const [],
  });

  @override
  State<QuestPartyCreateScreen> createState() => _QuestPartyCreateScreenState();
}

class _QuestPartyCreateScreenState extends State<QuestPartyCreateScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.quest != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<QuestPartyCreateViewModel>().initializeFromQuest(widget.quest!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<QuestPartyCreateViewModel>();
    final friendVM = context.watch<FriendViewModel>();
    final friends = friendVM.friends;
    final hasFriends = friends.isNotEmpty;
    final isEditMode = widget.quest != null;

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
          return false;
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
            title: Text(
              isEditMode ? '파티 퀘스트 수정' : '파티 퀘스트 생성',
              style: const TextStyle(fontWeight: FontWeight.bold),
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
                // 파티명
                PartyTitleInput(
                  initialValue: vm.partyTitle,
                  onChanged: vm.setQuestTitle,
                ),
                const SizedBox(height: 16),

                // 퀘스트 제목
                QuestTitleInput(
                  initialValue: vm.questName,
                  onChanged: vm.setContent,
                ),
                const SizedBox(height: 16),

                // 우선순위 & 기간
                QuestPrioritySection(
                  initialPriority: vm.priority,
                  initialPeriod: vm.period,
                  onPriorityChanged: vm.setPriority,
                  onPeriodChanged: vm.setPeriod,
                  // showTipBox: false,
                ),
                const SizedBox(height: 16),

                // 카테고리
                CategoryInput(
                  initialValue: vm.categories,
                  onChanged: vm.setCategories,
                ),

                // 날짜 및 시간
                DateTimeSection(
                  questType: vm.period,
                  selectedPeriod: vm.period, // 선택된 기간 전달
                  initialStartDate: vm.startDate,
                  initialDueDate: vm.dueDate,
                  initialStartTime: vm.startTime,
                  initialEndTime: vm.endTime,
                  onStartDateChanged: vm.setStartDate,
                  onDueDateChanged: vm.setDueDate,
                  onStartTimeChanged: vm.setStartTime,
                  onEndTimeChanged: vm.setEndTime,
                ),
                const SizedBox(height: 32),

                // 파티원 초대
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "파티원 초대",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: 123,
                      height: 46,
                      child: OutlinedButton(
                        onPressed: () async {
                          final selected = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PartyInvitePage(),
                            ),
                          );

                          if (selected != null) {
                            context.read<QuestPartyCreateViewModel>().setInvitedFriends(selected);
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFBDBDBD),
                          side: const BorderSide(
                            color: Color(0xFFBDBDBD),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          "파티 초대하기",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // 친구 목록
                    Row(
                      children: [
                        // 🔹 초대한 친구 프로필만 최대 3명 표시
                        ...vm.invitedFriends.cast<FriendInfo>().take(3).map((f) => Column(
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
                                    'assets/images/logo_3d.png',
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              f.nickname,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        )),

                        // 🔹 "더보기" 버튼은 항상 표시
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => InvitedFriendsPage(
                                  invitedFriends: vm.invitedFriends.cast<FriendInfo>(),
                                ),
                              ),
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
                                    '+${vm.invitedFriends.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const SizedBox(
                                width: 48,
                                child: Text(
                                  '더보기',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12),
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

                // EXP 안내
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
                            text: '10exp',
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

                // 생성 / 수정 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: vm.isFormValid && !vm.isLoading
                        ? () async {
                      if (isEditMode) {
                        final success = await vm.handleUpdate(widget.quest!.questId, context);
                        if (success && context.mounted) {
                          final questTabVM = context.read<QuestTabViewModel>();
                          final token = await const FlutterSecureStorage().read(key: "accessToken");
                          if (token != null) {
                            await questTabVM.loadPartyQuests(token);
                          }

                          // ✅ 광고 표시 후 모달
                          InterstitialAdService.showAd(
                            onClosed: () {
                              PartyUpdateModal.show(
                                context,
                                onClose: () {
                                  Navigator.pop(context); // 모달 닫기
                                  Navigator.pop(context); // 화면 닫기
                                },
                              );
                            },
                          );
                        }
                      } else {
                        final success = await vm.handleCreate(context);
                        if (success && context.mounted) {
                          // ✅ 광고 표시 후 모달
                          InterstitialAdService.showAd(
                            onClosed: () {
                              PartyCreationModal.show(
                                context,
                                onClose: () {
                                  Navigator.pop(context); // 모달 닫기
                                  Navigator.pop(context);
                                },
                              );
                            },
                          );
                        }
                      }
                    }
                        : null,
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
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                        : Text(
                      isEditMode ? "수정 완료" : "생성 완료",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                AdBanner(kind: BannerKind.mrec300x250)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
