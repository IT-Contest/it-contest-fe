import 'package:flutter/material.dart';
import 'package:it_contest_fe/features/quest/view/quest_personal_view_screen.dart';
import 'package:it_contest_fe/features/quest/view/widgets/empty_quest_widget.dart';
import 'package:provider/provider.dart';
import '../../quest/viewmodel/quest_tab_viewmodel.dart'; // ViewModel 변경
import '../model/completion_status.dart';
import '../model/quest_item_response.dart';
import 'widgets/quest_card.dart';
import 'quest_personal_form_screen.dart'; // QuestPersonalFormScreen으로 변경
import '../../../shared/widgets/quest_completion_modal.dart';

class DailyQuestFullPage extends StatefulWidget {
  final bool showEditDeleteButtons;
  const DailyQuestFullPage({super.key, this.showEditDeleteButtons = false});

  @override
  State<DailyQuestFullPage> createState() => _DailyQuestFullPageState();
}

class _DailyQuestFullPageState extends State<DailyQuestFullPage> {
  String _filter = 'ALL'; // 'ALL', 'PERSONAL', 'PARTY'

  @override
  void initState() {
    super.initState();
    // initState에서 fetchQuests를 호출할 필요가 없음.
    // QuestTabViewModel은 이미 QuestScreen에서 데이터를 로드했기 때문.
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
      body: Column(
        children: [
          if (widget.showEditDeleteButtons)
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _filter = _filter == 'PERSONAL' ? 'ALL' : 'PERSONAL';
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF8F73FF), width: 1),
                          backgroundColor: _filter == 'PERSONAL' ? const Color(0xFF8F73FF) : Colors.white,
                          foregroundColor: _filter == 'PERSONAL' ? Colors.white : const Color(0xFF8F73FF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.zero,
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        child: const Text('개인 퀘스트만 보기'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _filter = _filter == 'PARTY' ? 'ALL' : 'PARTY';
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF8F73FF), width: 1),
                          backgroundColor: _filter == 'PARTY' ? const Color(0xFF8F73FF) : Colors.white,
                          foregroundColor: _filter == 'PARTY' ? Colors.white : const Color(0xFF8F73FF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.zero,
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        child: const Text('파티 퀘스트만 보기'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (!widget.showEditDeleteButtons) const SizedBox(height: 8),
          Expanded(
            child: Consumer<QuestTabViewModel>( // ViewModel 변경
              builder: (context, viewModel, _) {
                if (viewModel.isLoading && viewModel.allQuests.isEmpty) { // 로딩 조건 수정
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.errorMessage != null) {
                  return Center(child: Text('에러: ${viewModel.errorMessage!}'));
                }

                // QuestTabViewModel의 allQuests를 사용하도록 변경
                final List<QuestItemResponse> quests;
                if (_filter == 'PERSONAL') {
                  quests = viewModel.allQuests.where((q) => q.partyName == null).toList();
                } else if (_filter == 'PARTY') {
                  quests = viewModel.allQuests.where((q) => q.partyName != null).toList();
                } else {
                  quests = viewModel.allQuests;
                }

                if (quests.isEmpty) {
                  return const EmptyQuestWidget(
                    imagePath: 'assets/icons/icon3.png',
                    message: '일일 진행 중인 퀘스트가 없습니다.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: quests.length,
                  itemBuilder: (context, index) {
                    final quest = quests[index];
                    final isDone = quest.completionStatus == CompletionStatus.COMPLETED;
                    return GestureDetector(
                      onTap: () {
                        // 조회 페이지로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuestPersonalFormPage(quest: quest),
                          ),
                        );
                      },
                      child: QuestCard(
                        title: quest.title,
                        exp: quest.expReward,
                        gold: quest.goldReward,
                        done: isDone,
                        onCheck: () {
                          viewModel.toggleQuest(
                            quest.questId,
                            context: context, // context 전달
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
                        highlightTitle: false,
                        showBackground: true,
                        useFilledIconBg: true,
                        padding: 12,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: null,
    );
  }
}

