import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../quest/view/daily_quest_fullpage.dart';
import '../../../quest/viewmodel/daily_quest_viewmodel.dart';
import '../../../quest/model/completion_status.dart';

class DailyQuestList extends StatefulWidget {
  const DailyQuestList({super.key});

  @override
  State<DailyQuestList> createState() => _DailyQuestListState();
}

class _DailyQuestListState extends State<DailyQuestList> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<DailyQuestViewModel>(context, listen: false).fetchMainQuests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DailyQuestViewModel>(
      builder: (context, viewModel, _) {
        // ✅ INCOMPLETE 퀘스트 중 우선순위 높은 순 정렬 후 2개만 추림
        final incompleteQuests = viewModel.quests
            .where((q) => q.completionStatus == CompletionStatus.INCOMPLETE)
            .toList()
          ..sort((a, b) => b.priority.compareTo(a.priority));

        final displayedQuests = incompleteQuests.take(2).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ 제목 및 전체보기 - 항상 표시
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '일일 진행 중인 퀘스트',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF6737F4),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DailyQuestFullPage(showEditDeleteButtons: false),
                        ),
                      );
                    },
                    child: const Row(
                      children: [
                        Text('전체보기', style: TextStyle(color: Colors.black54)),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right, size: 20, color: Colors.black54),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // ✅ 퀘스트 카드 - 있으면 표시, 없으면 공간만 비워둠
            if (displayedQuests.isNotEmpty)
              ...displayedQuests.map((quest) {
                final isDone = quest.completionStatus == CompletionStatus.COMPLETED;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                  ),
                  child: Row(
                    children: [
                      // 좌측 아이콘 (체크 여부에 따라 아이콘 변경)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Image.asset(
                          isDone
                              ? 'assets/icons/list_O.png'
                              : 'assets/icons/list_X.png',
                          width: 40,
                          height: 40,
                        ),
                      ),

                      // 퀘스트 정보
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              quest.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6737F4),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '경험치 +${quest.expReward}',
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFF6737F4)),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '골드 +${quest.goldReward}',
                                    style: const TextStyle(color: Color(0xFF6737F4), fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // 우측 체크 버튼
                      GestureDetector(
                        onTap: () => viewModel.toggleQuestCompletionById(quest.questId),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isDone ? const Color(0xFF6737F4) : Colors.white,
                            border: Border.all(
                              color: const Color(0xFF6737F4),
                              width: 1, // changed from 2 to 1
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: isDone
                              ? const Icon(Icons.check, size: 18, color: Colors.white)
                              : null,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        );
      },
    );
  }
}
