import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:it_contest_fe/shared/quest_create_form/title_input.dart';
import 'package:it_contest_fe/shared/quest_create_form/priority_section/priority.dart';
import 'package:it_contest_fe/shared/quest_create_form/category_input.dart';
import 'package:it_contest_fe/shared/quest_create_form/date_time_section.dart';
import 'package:it_contest_fe/shared/quest_create_form/sub_screen/invite_bottom_sheet.dart';
import 'package:it_contest_fe/shared/ad_banner.dart';

import 'package:it_contest_fe/features/quest/viewmodel/quest_personal_create_viewmodel.dart';

class QuestPersonalCreateScreen extends StatefulWidget {
  const QuestPersonalCreateScreen({super.key});

  @override
  State<QuestPersonalCreateScreen> createState() => _QuestPersonalCreateScreenState();
}

class _QuestPersonalCreateScreenState extends State<QuestPersonalCreateScreen> {
  String _title = '';
  int _priority = 0;
  String? _period;
  List<String> _categories = [];
  DateTime? _date;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<QuestPersonalCreateViewModel>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text(
            '개인 퀘스트 생성',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: const Color(0xFFB7B7B7),
              height: 1.0,
            ),
          ),
          surfaceTintColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 1. 퀘스트 제목
              QuestTitleInput(
                onChanged: (value) {
                  setState(() => _title = value);
                  vm.setQuestName(value);
                },
              ),
              const SizedBox(height: 16),

              // 2. 우선순위 및 주기
              QuestPrioritySection(
                onPriorityChanged: (value) {
                  setState(() => _priority = value);
                  vm.setPriority(value); // 🔧 ViewModel에도 반영
                },
                onPeriodChanged: (value) {
                  setState(() => _period = value);
                  if (value != null) {
                    vm.setQuestType(value); // 🔧 ViewModel에도 반영
                  }
                },
                showTipBox: true,
              ),
              const SizedBox(height: 16),

              // 3. 카테고리
              CategoryInput(
                onChanged: (value) {
                  setState(() => _categories = value);
                  vm.setHashtags(value); // 🔧 ViewModel에도 반영
                },
              ),
              const SizedBox(height: 16),

              // 4. 날짜 및 시간
              DateTimeSection(
                onStartDateChanged: vm.setStartDate,
                onDueDateChanged: vm.setDueDate,
                onStartTimeChanged: vm.setStartTime,
                onEndTimeChanged: vm.setEndTime,
              ),
              const SizedBox(height: 32),

              // 5. 완료 시 EXP 지급 안내
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFC2C2C2), width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text.rich(
                    TextSpan(
                      text: '완료시 ',
                      style: TextStyle(fontSize: 16, color: Color(0xFF9B9B9B), fontWeight: FontWeight.w600),
                      children: [
                        TextSpan(
                          text: '0,000exp',
                          style: TextStyle(color: Color(0xFF7958FF), fontWeight: FontWeight.w800),
                        ),
                        TextSpan(text: ' 지급'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),

              // 6. 생성 완료 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: vm.isLoading
                      ? null
                      : () async {
                          final success = await vm.createQuest();
                          if (success) {
                            Navigator.pushReplacementNamed(context, '/main');
                          } else if (vm.errorMessage != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(vm.errorMessage!)),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7958FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  child: vm.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          "생성 완료",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),
              const AdBanner(),
            ],
          ),
        ),
      ),
    );
  }
}