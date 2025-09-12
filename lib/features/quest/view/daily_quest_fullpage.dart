import 'package:flutter/material.dart';
import 'package:it_contest_fe/features/quest/view/quest_personal_view_screen.dart';
import 'package:it_contest_fe/features/quest/view/widgets/empty_quest_widget.dart';
import 'package:provider/provider.dart';
import '../../quest/viewmodel/quest_tab_viewmodel.dart'; // ViewModel 변경
import '../model/completion_status.dart';
import '../model/quest_item_response.dart';
import 'widgets/quest_card.dart';
import 'quest_personal_form_screen.dart'; // QuestPersonalFormScreen으로 변경

class DailyQuestFullPage extends StatefulWidget {
  final bool showEditDeleteButtons;
  const DailyQuestFullPage({super.key, this.showEditDeleteButtons = false});

  @override
  State<DailyQuestFullPage> createState() => _DailyQuestFullPageState();
}

class _DailyQuestFullPageState extends State<DailyQuestFullPage> {
  String _filter = 'ALL'; // 'ALL', 'PERSONAL', 'PARTY'
  int _selectedNav = -1; // 0: 수정, 1: 삭제
  int? _selectedQuestId; // 선택된 퀘스트 ID 추가

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
                        if (widget.showEditDeleteButtons && (_selectedNav == 0 || _selectedNav == 1)) {
                          // 수정/삭제 모드일 때는 선택 로직
                          setState(() {
                            if (_selectedQuestId == quest.questId) {
                              _selectedQuestId = null;
                            } else {
                              _selectedQuestId = quest.questId;
                            }
                          });
                        } else {
                          // ✅ 일반 모드에서는 조회 페이지로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuestPersonalFormPage(quest: quest),
                            ),
                          );
                        }
                      },
                      child: QuestCard(
                        title: quest.title,
                        exp: quest.expReward,
                        gold: quest.goldReward,
                        done: isDone,
                        onCheck: () => viewModel.toggleQuest(quest.questId),
                        highlightTitle: false,
                        showBackground: true,
                        useFilledIconBg: true,
                        padding: 12,
                        isSelected: quest.questId == _selectedQuestId,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.showEditDeleteButtons
          ? (_selectedNav == 0
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Divider(color: Color(0xFFE0E0E0), height: 1, thickness: 1),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12), // 기존 수정/삭제 버튼과 동일하게
                      child: SizedBox(
                        width: double.infinity,
                        height: 46, // 기존 버튼과 동일하게
                        child: OutlinedButton(
                          onPressed: _selectedQuestId != null
                              ? () {
                                  final selectedQuest = context
                                      .read<QuestTabViewModel>()
                                      .allQuests
                                      .firstWhere((q) => q.questId == _selectedQuestId);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => QuestPersonalFormScreen(quest: selectedQuest),
                                    ),
                                  ).then((_) => setState(() => _selectedQuestId = null)); // 돌아오면 선택 해제
                                }
                              : null,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF4C1FFF), width: 1),
                            backgroundColor: _selectedQuestId != null ? const Color(0xFF4C1FFF) : Colors.white,
                            foregroundColor: _selectedQuestId != null ? Colors.white : const Color(0xFF4C1FFF),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: EdgeInsets.zero,
                            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                            disabledForegroundColor: const Color(0xFF4C1FFF).withOpacity(0.5),
                          ),
                          child: Text(_selectedQuestId != null ? '선택한 퀘스트 수정하기' : '수정할 퀘스트를 선택해주세요'),
                        ),
                      ),
                    ),
                  ],
                )
              : _selectedNav == 1
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Divider(color: Color(0xFFE0E0E0), height: 1, thickness: 1),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          child: SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: OutlinedButton(
                              onPressed: _selectedQuestId != null
                                  ? () async {
                                      // 삭제 확인 다이얼로그
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => Dialog(
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // 제목
                                                const Text(
                                                  '주의',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFFD33248),
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                // 메시지
                                                const Text(
                                                  '완료된 퀘스트의 경우 지급되었던 경험치와\n골드가 차감됩니다.\n그래도 삭제하시겠습니까?',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black87,
                                                    height: 1.4,
                                                  ),
                                                ),
                                                const SizedBox(height: 24),
                                                // 버튼들
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: SizedBox(
                                                        height: 48,
                                                        child: ElevatedButton(
                                                          onPressed: () => Navigator.of(context).pop(true),
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: const Color(0xFF7958FF),
                                                            foregroundColor: Colors.white,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(12),
                                                            ),
                                                            elevation: 0,
                                                          ),
                                                          child: const Text(
                                                            '삭제',
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: SizedBox(
                                                        height: 48,
                                                        child: OutlinedButton(
                                                          onPressed: () => Navigator.of(context).pop(false),
                                                          style: OutlinedButton.styleFrom(
                                                            side: const BorderSide(color: Color(0xFF7958FF), width: 1),
                                                            foregroundColor: const Color(0xFF7958FF),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(12),
                                                            ),
                                                          ),
                                                          child: const Text(
                                                            '취소',
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                      
                                      // 삭제 확인 다이얼로그 결과 처리
                                      if (confirm == true) {
                                        final success = await context
                                            .read<QuestTabViewModel>()
                                            .deleteQuest(_selectedQuestId!);
                                        
                                        if (success) {
                                          setState(() {
                                            _selectedQuestId = null;
                                            _selectedNav = -1; // 삭제 완료 후 하단 버튼을 수정/삭제 선택 버튼으로 되돌리기
                                          });
                                        }
                                      }
                                    }
                                  : null,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF4C1FFF), width: 1),
                                backgroundColor: _selectedQuestId != null ? const Color(0xFF4C1FFF) : Colors.white,
                                foregroundColor: _selectedQuestId != null ? Colors.white : const Color(0xFF4C1FFF),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: EdgeInsets.zero,
                                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                disabledForegroundColor: const Color(0xFF4C1FFF).withOpacity(0.5),
                              ),
                              child: Text(_selectedQuestId != null ? '선택한 퀘스트 삭제하기' : '삭제할 퀘스트를 선택해주세요'),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
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
                                      setState(() {
                                        _selectedNav = 0;
                                        _selectedQuestId = null; // 수정 모드 진입 시 선택 초기화
                                      });
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
                                      setState(() {
                                        _selectedNav = 1;
                                        _selectedQuestId = null; // 삭제 모드 진입 시 선택 초기화
                                      });
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
                    ))
          : null,
    );
  }
}

