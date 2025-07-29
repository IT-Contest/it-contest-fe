import 'package:flutter/material.dart';
import 'package:it_contest_fe/features/quest/view/widget/empty_quest_widget.dart';
import 'package:provider/provider.dart';
import '../../quest/viewmodel/daily_quest_viewmodel.dart';
import '../model/completion_status.dart';
import '../model/quest_item_response.dart';
import 'widgets/quest_card.dart';

class DailyQuestFullPage extends StatefulWidget {
  final bool showEditDeleteButtons;
  const DailyQuestFullPage({super.key, this.showEditDeleteButtons = false});

  @override
  State<DailyQuestFullPage> createState() => _DailyQuestFullPageState();
}

class _DailyQuestFullPageState extends State<DailyQuestFullPage> {
  String _filter = 'ALL'; // 'ALL', 'PERSONAL', 'PARTY'
  int _selectedNav = -1; // 0: 수정, 1: 삭제

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
            child: Consumer<DailyQuestViewModel>(
              builder: (context, viewModel, _) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.errorMessage != null) {
                  return Center(child: Text('에러: ${viewModel.errorMessage!}'));
                }

                final List<QuestItemResponse> quests;
                if (_filter == 'PERSONAL') {
                  quests = viewModel.quests.where((q) => q.partyName == null).toList();
                } else if (_filter == 'PARTY') {
                  quests = viewModel.quests.where((q) => q.partyName != null).toList();
                } else {
                  quests = viewModel.quests;
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
                    return QuestCard(
                      title: quest.title,
                      exp: quest.expReward,
                      gold: quest.goldReward,
                      done: isDone,
                      onCheck: () => viewModel.toggleQuestCompletionById(quest.questId),
                      highlightTitle: false,
                      showBackground: true,
                      useFilledIconBg: true,
                      padding: 12,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.showEditDeleteButtons
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(color: Color(0xFFE0E0E0), height: 1, thickness: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() => _selectedNav = 0);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('수정 기능은 추후 구현 예정')),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF4C1FFF), width: 1),
                              backgroundColor: _selectedNav == 0 ? const Color(0xFF4C1FFF) : Colors.white,
                              foregroundColor: _selectedNav == 0 ? Colors.white : const Color(0xFF4C1FFF),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: EdgeInsets.zero,
                              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            child: const Text('수정하기'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() => _selectedNav = 1);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('삭제 기능은 추후 구현 예정')),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF4C1FFF), width: 1),
                              backgroundColor: _selectedNav == 1 ? const Color(0xFF4C1FFF) : Colors.white,
                              foregroundColor: _selectedNav == 1 ? Colors.white : const Color(0xFF4C1FFF),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: EdgeInsets.zero,
                              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            child: const Text('삭제하기'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : null,
    );
  }
}
