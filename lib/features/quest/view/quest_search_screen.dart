import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:it_contest_fe/shared/widgets/onboarding_app_bar.dart';

import '../model/completion_status.dart';
import '../viewmodel/quest_tab_viewmodel.dart'; // ViewModel 변경

class QuestSearchScreen extends StatefulWidget {
  final String initialQuery;
  const QuestSearchScreen({super.key, this.initialQuery = ''});

  @override
  State<QuestSearchScreen> createState() => _QuestSearchScreenState();
}

class _QuestSearchScreenState extends State<QuestSearchScreen> {
  late String _query;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery;
    _controller = TextEditingController(text: _query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<QuestTabViewModel>(context); // ViewModel 변경
    final filtered = viewModel.allQuests.where((q) { // allQuests 사용
      final query = _query.trim().toLowerCase();
      final titleMatch = q.title.toLowerCase().contains(query);
      final partyMatch = q.partyName?.toLowerCase().contains(query) ?? false;
      final hashtagMatch =
          q.hashtags.any((h) => h.toLowerCase().contains(query));
      return titleMatch || partyMatch || hashtagMatch;
    }).toList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const OnboardingAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: '퀘스트를 검색해 주세요',
                hintStyle: const TextStyle(
                  color: Color(0xFFBDBDBD),
                ),
                suffixIcon: const Icon(Icons.search, color: Color(0xFF643EFF)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF643EFF), width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF643EFF), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF643EFF), width: 2),
                ),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: viewModel.isLoading && viewModel.allQuests.isEmpty // 로딩 조건 수정
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? const Center(child: Text('검색 결과가 없습니다.'))
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final quest = filtered[index];
                            final isDone =
                                quest.completionStatus == CompletionStatus.COMPLETED;

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xFFE0E0E0), width: 1),
                              ),
                              child: Row(
                                children: [
                                  // 좌측 아이콘
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF2ECFF),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Image.asset(
                                      isDone
                                          ? 'assets/icons/list_O.png'
                                          : 'assets/icons/list_X.png',
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // 퀘스트 정보
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF6737F4),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                '경험치 +${quest.expReward}',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color:
                                                        const Color(0xFF6737F4)),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                '골드 +${quest.goldReward}',
                                                style: const TextStyle(
                                                    color: Color(0xFF6737F4),
                                                    fontSize: 12),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // 오른쪽 체크 버튼
                                  GestureDetector(
                                    onTap: () => viewModel.toggleQuest(quest.questId), // 호출 함수 변경
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isDone
                                            ? const Color(0xFF6737F4)
                                            : Colors.white,
                                        border: Border.all(
                                          color: const Color(0xFF6737F4),
                                          width: 1,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.check,
                                        size: 18,
                                        color: isDone
                                            ? Colors.white
                                            : Colors.transparent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
} 