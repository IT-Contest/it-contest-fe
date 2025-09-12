import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../view/daily_quest_fullpage.dart';
import '../../viewmodel/quest_tab_viewmodel.dart';
import '../../model/completion_status.dart';
import '../quest_personal_view_screen.dart';
import '../../../../shared/widgets/quest_completion_modal.dart';

class QuestListSection extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int>? onTabChanged;
  const QuestListSection({super.key, this.selectedTab = 0, this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    final periods = ['일일', '주간', '월간', '연간'];
    final questTabViewModel = Provider.of<QuestTabViewModel>(context);
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DailyQuestFullPage(showEditDeleteButtons: true),
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
                  Text('전체보기', style: TextStyle(color: Color(0xFF757575), fontSize: 16, fontWeight: FontWeight.w400)),
                  Icon(Icons.chevron_right, size: 20, color: Color(0xFF757575)),
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
                    onPressed: () => onTabChanged?.call(idx),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: selectedTab == idx ? const Color(0xFF7958FF) : Colors.white,
                      side: const BorderSide(color: Color(0xFF7958FF), width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(76, 46),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      periods[idx],
                      style: TextStyle(
                        color: selectedTab == idx ? Colors.white : const Color(0xFF7958FF),
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
        // 실제 퀘스트 리스트 렌더링
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: min(questTabViewModel.filteredQuests.length, 3),
          itemBuilder: (context, index) {
            final quest = questTabViewModel.filteredQuests[index];
            return _QuestCard(
              quest: quest, // ✅ 전체 객체 넘김
              onCheck: () {
                questTabViewModel.toggleQuest(
                  quest.questId,
                  onCompleted: (isFirstCompletion) {
                    // isFirstCompletion이 true일 때만 모달 표시
                    if (isFirstCompletion) {
                      QuestCompletionModal.show(
                        context,
                        expReward: quest.expReward,
                        goldReward: quest.goldReward,
                      );
                    }
                  },
                );
              },
            );
          },
        ),

      ],
    );
  }
}

class _QuestCard extends StatelessWidget {
  final dynamic quest; // quest 객체 전체 넘김
  final VoidCallback? onCheck;

  const _QuestCard({required this.quest, this.onCheck});

  @override
  Widget build(BuildContext context) {
    final done = quest.completionStatus == CompletionStatus.COMPLETED;

    return InkWell(
      onTap: () {
        // 카드 클릭 시 조회화면 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuestPersonalFormPage(quest: quest),
          ),
        );
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
                    quest.title,
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
                      _RewardTag(label: '골드 +${quest.goldReward}', border: true),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onCheck, // ✅ 체크 버튼은 그대로 동작
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
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  ),
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