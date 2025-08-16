import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:it_contest_fe/features/onboarding/viewmodel/onboarding_viewmodel.dart';

import 'package:it_contest_fe/shared/quest_create_form/title_input.dart';
import 'package:it_contest_fe/shared/quest_create_form/priority_section/priority.dart';
import 'package:it_contest_fe/shared/quest_create_form/category_input.dart';
import 'package:it_contest_fe/shared/quest_create_form/date_time_section.dart';
import 'package:it_contest_fe/shared/quest_create_form/sub_screen/invite_bottom_sheet.dart';
import 'package:it_contest_fe/shared/ad_banner.dart';

import 'package:it_contest_fe/shared/widgets/onboarding_app_bar.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String _title = '';
  int _priority = 0;
  String? _period;
  List<String> _categories = [];
  DateTime? _date;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const OnboardingAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleSection(), 
            const SizedBox(height: 24),

            // 1. 퀘스트 제목
            QuestTitleInput(onChanged: (value) => setState(() => _title = value)),
            const SizedBox(height: 16),

            // 2. 우선순위 (팁 + 선택자)
            const SizedBox(height: 12),
            QuestPrioritySection(
              onPriorityChanged: (value) => setState(() => _priority = value),
              onPeriodChanged: (value) => setState(() => _period = value),
            ),
            const SizedBox(height: 16),

            // 3. 카테고리 분류
            CategoryInput(onChanged: (value) => setState(() => _categories = value)),
            const SizedBox(height: 16),

            // 4. 날짜 및 시간
            DateTimeSection(
              onStartDateChanged: vm.setStartDate,
              onDueDateChanged: vm.setDueDate,
              onStartTimeChanged: vm.setStartTime,
              onEndTimeChanged: vm.setEndTime,
            ),
            const SizedBox(height: 32),

            // 5. 파티원 초대 영역
            const Text(
              "파티원 초대",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFF7D4CFF), width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("파티원 초대 TIP",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF7D4CFF))),
                  SizedBox(height: 8),
                  Text("친구를 초대하고 파티를 맺어 계획을 진행하면",
                      style: TextStyle(fontSize: 13, color: Color(0xFF6B6B6B))),
                  SizedBox(height: 2),
                  Text.rich(TextSpan(children: [
                    TextSpan(text: "더 많은 리워드",
                        style: TextStyle(color: Color(0xFF7D4CFF), fontWeight: FontWeight.bold, fontSize: 13)),
                    TextSpan(text: "를 얻을 수 있어요!", style: TextStyle(color: Color(0xFF6B6B6B), fontSize: 13)),
                  ])),
                  SizedBox(height: 2),
                  Text.rich(TextSpan(children: [
                    TextSpan(text: "파티원 초대시 ", style: TextStyle(color: Color(0xFF6B6B6B), fontSize: 13)),
                    TextSpan(text: "000exp",
                        style: TextStyle(color: Color(0xFF7D4CFF), fontWeight: FontWeight.bold, fontSize: 13)),
                    TextSpan(text: " 추가 지급", style: TextStyle(color: Color(0xFF6B6B6B), fontSize: 13)),
                  ])),
                ],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                showInviteBottomSheet(context);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF9F9F9F)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
              ),
              child: const Text('파티원 초대하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF9F9F9F))),
            ),

            const SizedBox(height: 24),

            // 6. 시작하기 버튼
            SizedBox(
              width: double.infinity, // or a fixed width like 300 if desired
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
                  padding: const EdgeInsets.symmetric(vertical: 24),
                ),
                child: vm.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "퀘스트플래너 시작하기",
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
    );
  }
    // 타이틀 영역: 퀘스트 생성 안내 및 보상 정보 (디자인 반영)
  Widget _buildTitleSection() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFF7D4CFF), width: 1.5),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            const Text(
              "퀘스트를 만들어볼까요?",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: const TextSpan(
                text: "완료시 ",
                style: TextStyle(fontSize: 18, color: Colors.grey),
                children: [
                  TextSpan(
                    text: "0,000exp",
                    style: TextStyle(
                      color: Color(0xFF7D4CFF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: " 지급"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}