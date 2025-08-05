import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:it_contest_fe/shared/quest_create_form/title_input.dart';
import 'package:it_contest_fe/shared/quest_create_form/priority_section/priority.dart';
import 'package:it_contest_fe/shared/quest_create_form/category_input.dart';
import 'package:it_contest_fe/shared/quest_create_form/date_time_section.dart';
import 'package:it_contest_fe/shared/ad_banner.dart';

import 'package:it_contest_fe/features/quest/viewmodel/quest_personal_create_viewmodel.dart';
import 'package:it_contest_fe/features/quest/model/quest_item_response.dart';
import 'package:it_contest_fe/features/quest/viewmodel/quest_tab_viewmodel.dart';
import 'package:it_contest_fe/features/mainpage/viewmodel/mainpage_viewmodel.dart';
import 'package:it_contest_fe/presentation/main_navigation_screen.dart';

class QuestPersonalFormScreen extends StatefulWidget {
  final QuestItemResponse? quest;
  const QuestPersonalFormScreen({super.key, this.quest});

  @override
  State<QuestPersonalFormScreen> createState() => _QuestPersonalFormScreenState();
}

class _QuestPersonalFormScreenState extends State<QuestPersonalFormScreen> {
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
      _period = _mapQuestTypeToKorean(widget.quest!.questType); // 한글로 변환
      _categories = List<String>.from(widget.quest!.hashtags);
      
      // ViewModel 초기화는 build 후에 실행
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
          title: Text(widget.quest != null ? '개인 퀘스트 수정' : '개인 퀘스트 생성',
              style: const TextStyle(fontWeight: FontWeight.bold)),
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
                initialValue: _title,
                onChanged: (value) {
                  setState(() => _title = value);
                  vm.setQuestName(value);
                },
              ),
              const SizedBox(height: 16),

              // 2. 우선순위 및 주기
              QuestPrioritySection(
                initialPriority: _priority,
                initialPeriod: _period,
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
                initialValue: _categories,
                onChanged: (value) {
                  setState(() => _categories = value);
                  vm.setHashtags(value); // 🔧 ViewModel에도 반영
                },
              ),
              const SizedBox(height: 16),

              // 4. 날짜 및 시간
              DateTimeSection(
                initialStartDate: _parseDate(widget.quest?.startDate),
                initialDueDate: _parseDate(widget.quest?.dueDate),
                initialStartTime: _parseTime(widget.quest?.startTime),
                initialEndTime: _parseTime(widget.quest?.endTime),
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
                          if (widget.quest != null) {
                            // 수정 로직
                            final success = await vm.updateQuest(widget.quest!.questId);
                            if (success) {
                              if (mounted) {
                                // 수정 완료 후 퀘스트 리스트 새로고침
                                final questTabVM = context.read<QuestTabViewModel>();
                                await questTabVM.loadQuests(force: true);
                                
                                Navigator.pop(context); // 수정 완료 후 이전 화면으로
                              }
                            } else if (vm.errorMessage != null) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(vm.errorMessage!)),
                                );
                              }
                            }
                          } else {
                            // 생성 로직
                            final success = await vm.createQuest();
                            if (success) {
                              if (mounted) {
                                // 생성 완료 후 퀘스트 리스트 새로고침
                                final questTabVM = context.read<QuestTabViewModel>();
                                await questTabVM.loadQuests(force: true);
                                
                                // 메인페이지 퀘스트도 새로고침 (필요시)
                                try {
                                  final mainPageVM = context.read<MainPageViewModel>();
                                  await mainPageVM.loadMainQuests();
                                } catch (e) {
                                  // MainPageViewModel이 없을 수도 있으므로 에러 무시
                                  print('MainPageViewModel not found: $e');
                                }
                                
                                // 메인 네비게이션으로 이동하고 퀘스트 탭(인덱스 1) 선택
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MainNavigationScreen(initialIndex: 1),
                                  ),
                                  (route) => false,
                                );
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('퀘스트가 성공적으로 생성되었습니다.')),
                                );
                              }
                            } else if (vm.errorMessage != null) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(vm.errorMessage!)),
                                );
                              }
                            }
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
                      : Text(
                          widget.quest != null ? '수정 완료' : '생성 완료',
                          style: const TextStyle(
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