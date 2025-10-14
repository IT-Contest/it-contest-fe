import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:it_contest_fe/features/quest/view/party_quest_view_screen.dart';
import 'package:it_contest_fe/features/quest/view/quest_personal_view_screen.dart';
import 'package:it_contest_fe/features/quest/view/widgets/empty_quest_widget.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/quest_completion_modal.dart';
import '../../../../shared/widgets/party_completion_modal.dart';
import '../model/completion_status.dart';
import '../viewmodel/quest_tab_viewmodel.dart';

class CompletedQuestPage extends StatefulWidget {
  const CompletedQuestPage({super.key});

  @override
  State<CompletedQuestPage> createState() => _CompletedQuestPageState();
}

class _CompletedQuestPageState extends State<CompletedQuestPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final viewModel = context.read<QuestTabViewModel>();
      await viewModel.loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final questTabViewModel = Provider.of<QuestTabViewModel>(context);
    final periods = ['일일', '주간', '월간', '연간'];

    // ✅ 완료된 퀘스트만 필터링
    final completedPersonal = questTabViewModel.allQuests
        .where((q) =>
    q.questType == questTabViewModel.selectedPeriod &&
        q.completionStatus == CompletionStatus.COMPLETED)
        .toList();

    final completedParty = questTabViewModel.allPartyQuests
        .where((q) =>
    q.questType == questTabViewModel.selectedPeriod &&
        q.completionStatus == CompletionStatus.COMPLETED)
        .toList();

    final combinedCompleted = [...completedPersonal, ...completedParty];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          '완료한 퀘스트',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(color: Colors.grey, height: 1, thickness: 1),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // 🔘 일/주/월/연 탭 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(periods.length * 2 - 1, (i) {
                if (i.isEven) {
                  final idx = i ~/ 2;
                  return Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          questTabViewModel.changeTab(idx);
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor:
                          questTabViewModel.selectedTab == idx
                              ? const Color(0xFF7958FF)
                              : Colors.white,
                          side: const BorderSide(
                              color: Color(0xFF7958FF), width: 1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(76, 46),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          periods[idx],
                          style: TextStyle(
                            color: questTabViewModel.selectedTab == idx
                                ? Colors.white
                                : const Color(0xFF7958FF),
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return const SizedBox(width: 12);
                }
              }),
            ),
          ),

          const SizedBox(height: 12),

          // 완료된 퀘스트 리스트
          Expanded(
            child: combinedCompleted.isEmpty
                ? const EmptyQuestWidget(
              imagePath: 'assets/icons/icon3.png',
              message: '완료된 퀘스트가 없습니다.',
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: combinedCompleted.length,
              itemBuilder: (context, index) {
                final quest = combinedCompleted[index];
                final isPartyQuest = questTabViewModel.allPartyQuests
                    .any((p) => p.questId == quest.questId);

                return _QuestCard(
                  quest: quest,
                  isPartyQuest: isPartyQuest,
                  onCheck: () {
                    if (isPartyQuest) {
                      questTabViewModel.togglePartyQuestCompletion(
                        quest.questId,
                        context: context,
                        onStatusChanged: (status) {
                          PartyCompletionModal.show(
                            context,
                            expReward: quest.expReward,
                            goldReward: quest.goldReward,
                            isCompleted:
                            status == CompletionStatus.COMPLETED,
                          );
                        },
                      );
                    } else {
                      questTabViewModel.toggleQuest(
                        quest.questId,
                        context: context,
                        onCompleted: (isCompleted) {
                          QuestCompletionModal.show(
                            context,
                            expReward: quest.expReward,
                            goldReward: quest.goldReward,
                            isCompleted: isCompleted,
                          );
                        },
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ QuestListSection의 _QuestCard 그대로 복사
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
        FocusScope.of(context).unfocus();
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
                        ? (quest.questName ?? '이름 없는 퀘스트')
                        : quest.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: done
                          ? const Color(0xFF643EFF)
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _RewardTag(label: '경험치 +${quest.expReward}'),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // _RewardTag(
                          //   label: '골드 +${quest.goldReward}',
                          //   border: true,
                          // ),
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
                  color: done
                      ? const Color(0xFF643EFF)
                      : const Color(0xFFFAFAFA),
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
