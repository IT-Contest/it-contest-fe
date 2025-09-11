import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:it_contest_fe/shared/quest_create_form/title_input.dart';
import 'package:it_contest_fe/shared/quest_create_form/priority_section/priority.dart';
import 'package:it_contest_fe/shared/quest_create_form/category_input.dart';
import 'package:it_contest_fe/shared/quest_create_form/date_time_section.dart';

import 'package:it_contest_fe/features/quest/viewmodel/quest_personal_create_viewmodel.dart';
import 'package:it_contest_fe/features/quest/model/quest_item_response.dart';

class QuestPersonalFormPage extends StatefulWidget {
  final QuestItemResponse? quest;
  const QuestPersonalFormPage({super.key, this.quest});

  @override
  State<QuestPersonalFormPage> createState() =>
      _QuestPersonalFormPageState();
}

class _QuestPersonalFormPageState extends State<QuestPersonalFormPage> {
  String _title = '';
  int _priority = 0;
  String? _period;
  List<String> _categories = [];
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    if (widget.quest != null) {
      _title = widget.quest!.title;
      _priority = widget.quest!.priority;
      _period = _mapQuestTypeToKorean(widget.quest!.questType);
      _categories = List<String>.from(widget.quest!.hashtags);
      _date = _parseDate(widget.quest?.startDate);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final vm = context.read<QuestPersonalCreateViewModel>();
        vm.initializeFromQuest(widget.quest!);
      });
    }
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  TimeOfDay? _parseTime(String? timeStr) {
    if (timeStr == null) return null;
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return null;
    }
  }

  String? _mapQuestTypeToKorean(String? questType) {
    if (questType == null) return null;
    switch (questType) {
      case 'DAILY':
        return '일일';
      case 'WEEKLY':
        return '주간';
      case 'MONTHLY':
        return '월간';
      case 'YEARLY':
        return '연간';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuestPersonalCreateViewModel>(
      builder: (context, vm, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
          ),
          child: WillPopScope(
            onWillPop: () async {
              Navigator.of(context).pop();
              return true;
            },
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 20, color: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: const Text(
                  '개인 퀘스트',
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
                    AbsorbPointer( // ✅ 입력 막음
                      child: QuestTitleInput(
                        initialValue: _title,
                        onChanged: (_) {},
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. 우선순위 및 주기
                    AbsorbPointer( // ✅ 입력 막음
                      child: QuestPrioritySection(
                        initialPriority: _priority,
                        initialPeriod: _period,
                        onPriorityChanged: (_) {},
                        onPeriodChanged: (_) {},
                        showTipBox: true,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3. 카테고리
                    AbsorbPointer( // ✅ 입력 막음
                      child: CategoryInput(
                        initialValue: _categories,
                        onChanged: (_) {},
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 4. 날짜 및 시간
                    AbsorbPointer( // ✅ 입력 막음
                      child: DateTimeSection(
                        initialStartDate: _parseDate(widget.quest?.startDate),
                        initialDueDate: _parseDate(widget.quest?.dueDate),
                        initialStartTime: _parseTime(widget.quest?.startTime),
                        initialEndTime: _parseTime(widget.quest?.endTime),
                        onStartDateChanged: (_) {},
                        onDueDateChanged: (_) {},
                        onStartTimeChanged: (_) {},
                        onEndTimeChanged: (_) {},
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 5. 완료 시 EXP 지급 안내
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        border:
                        Border.all(color: const Color(0xFFC2C2C2), width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text.rich(
                          TextSpan(
                            text: '완료시 ',
                            style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF9B9B9B),
                                fontWeight: FontWeight.w600),
                            children: [
                              TextSpan(
                                text: '0,000exp',
                                style: TextStyle(
                                    color: Color(0xFF7958FF),
                                    fontWeight: FontWeight.w800),
                              ),
                              TextSpan(text: ' 지급'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
