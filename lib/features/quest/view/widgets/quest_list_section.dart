import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../view/daily_quest_fullpage.dart';
import '../../viewmodel/quest_tab_viewmodel.dart';
import '../../model/completion_status.dart';
import '../quest_personal_view_screen.dart';
import '../../view/party_quest_view_screen.dart'; // ✅ 파티퀘스트 상세보기
import '../../../../shared/widgets/quest_completion_modal.dart';

class QuestListSection extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int>? onTabChanged;
  const QuestListSection({super.key, this.selectedTab = 0, this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    final periods = ['일일', '주간', '월간', '연간'];
    final questTabViewModel = Provider.of<QuestTabViewModel>(context);

    // ✅ 개인 + 파티 퀘스트 모두 합친 리스트
    final combinedQuests = [
      ...questTabViewModel.filteredQuests,
      ...questTabViewModel.partyQuests,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '진행 중인 퀘스트 목록',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Color(0xFF4C1FFF),
                height: 1.5,
                letterSpacing: -0.4,
              ),
            ),
            TextButton(
              onPressed: () {
                // 키보드 포커스 해제
                FocusScope.of(context).unfocus();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const DailyQuestFullPage(showEditDeleteButtons: true),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Row(
                children: [
                  Text('전체보기',
                      style: TextStyle(
                          color: Color(0xFF757575),
                          fontSize: 16,
                          fontWeight: FontWeight.w400)),
                  Icon(Icons.chevron_right,
                      size: 20, color: Color(0xFF757575)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(periods.length * 2 - 1, (i) {
            if (i.isEven) {
              final idx = i ~/ 2;
              return Expanded(
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton(
                    onPressed: () {
                      // 키보드 포커스 해제
                      FocusScope.of(context).unfocus();
                      onTabChanged?.call(idx);
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor:
                      selectedTab == idx ? const Color(0xFF7958FF) : Colors.white,
                      side: const BorderSide(color: Color(0xFF7958FF), width: 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(76, 46),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      periods[idx],
                      style: TextStyle(
                        color: selectedTab == idx
                            ? Colors.white
                            : const Color(0xFF7958FF),
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              );
            } else {
              return const SizedBox(width: 12);
            }
          }),
        ),
        const SizedBox(height: 12),
        // 실제 퀘스트 리스트 렌더링 (최대 3개)
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: min(combinedQuests.length, 3),
          itemBuilder: (context, index) {
            final quest = combinedQuests[index];
            final isPartyQuest = questTabViewModel.partyQuests
                .any((p) => p.questId == quest.questId);

            return _QuestCard(
              quest: quest,
              isPartyQuest: isPartyQuest,
              onCheck: () {
                if (isPartyQuest) {
                  questTabViewModel.togglePartyQuestCompletion(
                    quest.questId,
                    context: context,
                    onCompleted: (isFirstCompletion) {
                      if (isFirstCompletion) {
                        QuestCompletionModal.show(
                          context,
                          expReward: quest.expReward,
                          goldReward: quest.goldReward,
                        );
                      }
                    },
                  );
                } else {
                  questTabViewModel.toggleQuest(
                    quest.questId,
                    context: context,
                    onCompleted: (isFirstCompletion) {
                      if (isFirstCompletion) {
                        QuestCompletionModal.show(
                          context,
                          expReward: quest.expReward,
                          goldReward: quest.goldReward,
                        );
                      }
                    },
                  );
                }
              },
            );
          },
        ),
      ],
    );
  }
}

class _QuestCard extends StatelessWidget {
  final dynamic quest;
  final bool isPartyQuest;
  final VoidCallback? onCheck;

  const _QuestCard({
    required this.quest,
    required this.isPartyQuest,
    this.onCheck,
  });

  @override
  Widget build(BuildContext context) {
    final done = quest.completionStatus == CompletionStatus.COMPLETED;

    return InkWell(
      onTap: () {
        // 키보드 포커스 해제
        FocusScope.of(context).unfocus();
        // ✅ 개인/파티 구분하여 다른 화면으로 이동
        if (isPartyQuest) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PartyQuestViewScreen(quest: quest),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QuestPersonalFormPage(quest: quest),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                done
                    ? 'assets/icons/quest_select.png'
                    : 'assets/icons/quest_not_select.png',
                width: 44,
                height: 44,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPartyQuest
                        ? (quest.partyName ?? '이름 없는 파티')
                        : quest.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: done ? const Color(0xFF643EFF) : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _RewardTag(label: '경험치 +${quest.expReward}'),
                      const SizedBox(width: 8),

                      // 🔧 골드 태그 + 파티 아이콘 묶음
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _RewardTag(label: '골드 +${quest.goldReward}', border: true),
                          if (isPartyQuest) ...[
                            const SizedBox(width: 10),
                            Image.asset(
                              'assets/icons/party_in.png',
                              width: 20,
                              height: 20,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onCheck,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: done ? const Color(0xFF643EFF) : const Color(0xFFFAFAFA),
                  border: Border.all(
                    color: const Color(0xFF7958FF),
                    width: 1,
                  ),
                  shape: BoxShape.circle,
                ),
                child: done
                    ? const Center(
                  child: Icon(Icons.check,
                      color: Colors.white, size: 20),
                )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardTag extends StatelessWidget {
  final String label;
  final bool border;
  const _RewardTag({required this.label, this.border = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: border ? Colors.white : const Color(0xFF643EFF),
        border: border ? Border.all(color: const Color(0xFF643EFF)) : null,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: border ? const Color(0xFF643EFF) : Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}