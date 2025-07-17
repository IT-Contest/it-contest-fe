import 'package:flutter/material.dart';
import '../../../quest/view/daily_quest_fullpage.dart';
import '../../model/quest_item.dart';

class DailyQuestList extends StatefulWidget {
  const DailyQuestList({super.key});

  @override
  State<DailyQuestList> createState() => _DailyQuestListState();
}

class _DailyQuestListState extends State<DailyQuestList> {
  final List<QuestItem> quests = [
    QuestItem(title: '아침 루틴 완료', exp: 10, gold: 5),
    QuestItem(title: '아침 루틴 완료', exp: 10, gold: 5),
  ];

  void toggleComplete(int index) {
    setState(() {
      quests[index].isCompleted = !quests[index].isCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상단 제목 + 전체보기 버튼
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      builder: (_) => const DailyQuestFullPage(),
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
        const SizedBox(height: 12),

        // 퀘스트 카드 리스트
        Column(
          children: quests.asMap().entries.map((entry) {
            int index = entry.key;
            QuestItem quest = entry.value;
            bool isDone = quest.isCompleted;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDone ? const Color(0xFFBCA8F9) : const Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // 아이콘
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2ECFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        isDone
                            ? 'assets/icons/list_O.png'
                            : 'assets/icons/list_X.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 텍스트 + 보상
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quest.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDone ? const Color(0xFF6737F4) : Colors.black87,
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
                                '경험치 +${quest.exp}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
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
                                '골드 +${quest.gold}',
                                style: const TextStyle(
                                  color: Color(0xFF6737F4),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 체크 버튼
                  GestureDetector(
                    onTap: () => toggleComplete(index),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone ? const Color(0xFF6737F4) : Colors.white,
                        border: Border.all(
                          color: const Color(0xFF6737F4),
                          width: 2,
                        ),
                      ),
                      child: isDone
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        )
      ],
    );
  }
}
