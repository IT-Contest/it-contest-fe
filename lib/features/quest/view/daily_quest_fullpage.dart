import 'package:flutter/material.dart';
import 'package:it_contest_fe/features/quest/view/widget/empty_quest_widget.dart';
import 'package:provider/provider.dart';
import '../../quest/viewmodel/daily_quest_viewmodel.dart';
import '../../quest/model/quest_item_response.dart';
import '../model/completion_status.dart';

class DailyQuestFullPage extends StatefulWidget {
  const DailyQuestFullPage({super.key});

  @override
  State<DailyQuestFullPage> createState() => _DailyQuestFullPageState();
}

class _DailyQuestFullPageState extends State<DailyQuestFullPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<DailyQuestViewModel>(context, listen: false)
            .fetchQuests());
  }

  @override
  Widget build(BuildContext context) {
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
          '일일 진행 중인 퀘스트',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(color: Colors.grey, height: 1, thickness: 1),
        ),
      ),
      body: Consumer<DailyQuestViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(child: Text('에러: ${viewModel.errorMessage!}'));
          }

          final quests = viewModel.quests;

          if (quests.isEmpty) {
            return const EmptyQuestWidget(
              imagePath: 'assets/icons/icon3.png',
              message: '일일 진행 중인 퀘스트가 없습니다.',
            );
          }

          return ListView.builder(
            itemCount: quests.length,
            itemBuilder: (context, index) {
              final quest = quests[index];
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
                    // 🔹 좌측 아이콘
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
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // 🔹 퀘스트 정보
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

                    // 🔹 오른쪽 체크 버튼
                    GestureDetector(
                      onTap: () => viewModel.toggleQuestCompletionById(quest.questId),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone ? const Color(0xFF6737F4) : Colors.white,
                          border: Border.all(
                            color: const Color(0xFF6737F4),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.check,
                          size: 18,
                          color: isDone ? Colors.white : Colors.transparent,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
