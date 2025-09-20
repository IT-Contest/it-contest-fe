import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:it_contest_fe/features/quest/view/party_quest_view_screen.dart';
import 'package:it_contest_fe/features/quest/view/quest_personal_view_screen.dart';
import 'package:it_contest_fe/features/quest/view/widgets/empty_quest_widget.dart';
import 'package:provider/provider.dart';
import '../../quest/viewmodel/quest_tab_viewmodel.dart';
import '../model/completion_status.dart';
import '../model/quest_item_response.dart';
import 'widgets/quest_card.dart';
import '../../../shared/widgets/quest_completion_modal.dart';

class DailyQuestFullPage extends StatefulWidget {
  final bool showEditDeleteButtons;
  const DailyQuestFullPage({super.key, this.showEditDeleteButtons = false});

  @override
  State<DailyQuestFullPage> createState() => _DailyQuestFullPageState();
}

class _DailyQuestFullPageState extends State<DailyQuestFullPage> {
  String _filter = 'ALL'; // 'ALL', 'PERSONAL', 'PARTY'

  Future<void> _loadPartyQuests() async {
    final token = await const FlutterSecureStorage().read(key: "accessToken");
    if (token != null) {
      await context.read<QuestTabViewModel>().loadPartyQuests(token);
    }
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
                        onPressed: () async {
                          final newFilter = _filter == 'PARTY' ? 'ALL' : 'PARTY';
                          setState(() => _filter = newFilter);

                          if (newFilter == 'PARTY') {
                            await _loadPartyQuests(); // ✅ 파티 리스트 불러오기
                          }
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
            child: Consumer<QuestTabViewModel>(
              builder: (context, viewModel, _) {
                if (viewModel.isLoading && _filter == 'PARTY') {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.errorMessage != null) {
                  return Center(child: Text('에러: ${viewModel.errorMessage!}'));
                }

                // ✅ 필터링된 리스트 선택
                final List<QuestItemResponse> quests;
                if (_filter == 'PERSONAL') {
                  quests = viewModel.allQuests; // ✅ 그대로 사용
                } else if (_filter == 'PARTY') {
                  quests = viewModel.partyQuests;
                } else {
                  quests = [
                    ...viewModel.allQuests,
                    ...viewModel.partyQuests,
                  ]; // ✅ 전체보기면 합쳐서 보여주기
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

                    final isPartyQuest = viewModel.partyQuests
                        .any((p) => p.questId == quest.questId);

                    final isDone = quest.completionStatus == CompletionStatus.COMPLETED;

                    return GestureDetector(
                      onTap: () {
                        final isPartyQuest = viewModel.partyQuests.any((p) => p.questId == quest.questId);

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
                      child: QuestCard(
                        title: viewModel.partyQuests.any((p) => p.questId == quest.questId)
                            ? (quest.partyName ?? '이름 없는 파티')
                            : quest.title,
                        expReward: quest.expReward,
                        goldReward: quest.goldReward,
                        done: isDone,
                        goldTrailing: viewModel.partyQuests.any((p) => p.questId == quest.questId)
                            ? Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Image.asset(
                            'assets/icons/party_in.png',
                            width: 20,
                            height: 20,
                          ),
                        )
                            : null,
                        onCheck: () {
                          final isPartyQuest = viewModel.partyQuests.any((p) => p.questId == quest.questId);

                          if (isPartyQuest) {
                            viewModel.togglePartyQuestCompletion(
                              quest.partyId!,
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
                            viewModel.toggleQuest(
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