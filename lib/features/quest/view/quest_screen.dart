import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/quest_tab_viewmodel.dart';
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
      body: Column(
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
                  const SizedBox(height: 24),
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
    );
  }
}
