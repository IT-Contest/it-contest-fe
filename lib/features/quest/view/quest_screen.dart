import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/quest_tab_viewmodel.dart';
import 'widgets/quest_search_section.dart';
import 'widgets/quest_list_section.dart';
import 'widgets/quest_add_section.dart';
import 'widgets/quest_pomodoro_section.dart';
import '../../../shared/widgets/custom_app_bar.dart';

class QuestScreen extends StatelessWidget {
  const QuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final questTabViewModel = Provider.of<QuestTabViewModel>(context);
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          // 메인화면과 동일하게 헤더바 아래 구분선은 CustomAppBar에서 처리
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
                  const SizedBox(height: 24),
                  QuestListSection(
                    selectedTab: questTabViewModel.selectedTab,
                    onTabChanged: questTabViewModel.changeTab,
                  ),
                  const SizedBox(height: 16),
                  const QuestAddSection(),
                  const SizedBox(height: 24),
                  const QuestPomodoroSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
