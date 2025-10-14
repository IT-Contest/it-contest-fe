import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/quest_tab_viewmodel.dart';
import 'completed_quest_page.dart';
import 'widgets/quest_search_section.dart';
import 'widgets/quest_list_section.dart';
import 'widgets/quest_add_section.dart';
import 'widgets/quest_pomodoro_section.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import 'package:it_contest_fe/features/quest/view/quest_personal_form_screen.dart';

class QuestScreen extends StatefulWidget {
  const QuestScreen({super.key});

  @override
  State<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final questTabViewModel = context.read<QuestTabViewModel>();
      questTabViewModel.loadQuests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final questTabViewModel = Provider.of<QuestTabViewModel>(context);
    return Scaffold(
      appBar: const CustomAppBar(),
      body: GestureDetector(
        onTap: () {
          // 다른 영역 클릭 시 키보드 포커스 해제
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: [
            Expanded(
              child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF3FAFF),
                    Color(0xFFEEEBFF),
                  ],
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 16),
                  const QuestSearchSection(),
                  const SizedBox(height: 16),

                  // ✅ 완료된 퀘스트 보기 버튼 추가
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7958FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // 완료된 퀘스트 페이지로 이동
                        // (예: CompletedQuestPage())
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CompletedQuestPage(),
                          ),
                        );
                      },
                      child: const Text(
                        '완료된 퀘스트 보기',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  QuestListSection(
                    selectedTab: questTabViewModel.selectedTab,
                    onTabChanged: questTabViewModel.changeTab,
                  ),
                  const SizedBox(height: 16),
                  QuestAddSection(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const QuestPersonalFormScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const QuestPomodoroSection(),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}
