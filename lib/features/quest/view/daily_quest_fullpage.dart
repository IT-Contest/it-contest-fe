import 'package:flutter/material.dart';

import '../../mainpage/model/quest_item.dart';

class DailyQuestFullPage extends StatefulWidget {
  const DailyQuestFullPage({super.key});

  @override
  State<DailyQuestFullPage> createState() => _DailyQuestFullPageState();
}

class _DailyQuestFullPageState extends State<DailyQuestFullPage> {
  final List<QuestItem> quests = List.generate(
    10,
        (index) => QuestItem(title: '아침 루틴 완료', exp: 10, gold: 5),
  );

  void toggleComplete(int index) {
    setState(() {
      quests[index].isCompleted = !quests[index].isCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ 1. Scaffold 배경을 흰색으로
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          '일일 진행 중인 퀘스트',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            color: Colors.grey,
            height: 1,
            thickness: 1,
          ),
        ),
      ),
      body: Container(
        color: Colors.white, // ✅ 2. Body에 한 번 더 흰색 설정
        child: ListView.builder(
          itemCount: quests.length,
          itemBuilder: (context, index) {
            final quest = quests[index];
            final isDone = quest.isCompleted;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white, // ✅ 3. 카드 배경도 흰색
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
                  // 텍스트 및 보상
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
                  // 체크박스
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
          },
        ),
      ),
    );
  }
}
