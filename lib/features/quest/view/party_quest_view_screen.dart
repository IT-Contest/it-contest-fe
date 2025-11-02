import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:it_contest_fe/features/quest/view/quest_party_create_screen.dart';
import 'package:it_contest_fe/shared/widgets/party_delete_success.dart';
import 'package:provider/provider.dart';

import 'package:it_contest_fe/shared/quest_create_form/title_input.dart';
import 'package:it_contest_fe/shared/quest_create_form/priority_section/priority.dart';
import 'package:it_contest_fe/shared/quest_create_form/category_input.dart';
import 'package:it_contest_fe/shared/quest_create_form/date_time_section.dart';

import 'package:it_contest_fe/features/quest/model/quest_item_response.dart';

import '../../../shared/quest_create_form/party_title_input.dart';
import '../viewmodel/quest_party_create_viewmodel.dart';
import '../../../shared/widgets/party_delete_confirmation_modal.dart';

class PartyQuestViewScreen extends StatefulWidget {
  final QuestItemResponse? quest;
  const PartyQuestViewScreen({super.key, this.quest});

  @override
  State<PartyQuestViewScreen> createState() => _PartyQuestViewScreenState();
}

class _PartyQuestViewScreenState extends State<PartyQuestViewScreen> {
  String _title = '';
  String? _partyName;
  int _priority = 0;
  String? _period;
  List<String> _categories = [];
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    if (widget.quest != null) {
      _title = widget.quest!.questName ?? '';
      _partyName = widget.quest!.partyTitle;
      _priority = widget.quest!.priority;
      _period = _mapQuestTypeToKorean(widget.quest!.questType);
      _categories = List<String>.from(widget.quest!.hashtags);
      _date = _parseDate(widget.quest?.startDate);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final vm = context.read<QuestPartyCreateViewModel>();
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
    return Consumer<QuestPartyCreateViewModel>(
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
                  '파티 퀘스트',
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
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 0. 파티명
                          AbsorbPointer(
                            child: PartyTitleInput(
                              initialValue: _partyName,
                              onChanged: (_) {},
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 1. 퀘스트 제목
                          AbsorbPointer(
                            child: QuestTitleInput(
                              initialValue: _title,
                              onChanged: (_) {},
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 2. 우선순위 및 주기
                          AbsorbPointer(
                            child: QuestPrioritySection(
                              initialPriority: _priority,
                              initialPeriod: _period,
                              onPriorityChanged: (_) {},
                              onPeriodChanged: (_) {},
                              // showTipBox: true,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 3. 카테고리
                          AbsorbPointer(
                            child: CategoryInput(
                              initialValue: _categories,
                              onChanged: (_) {},
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 4. 날짜 및 시간
                          AbsorbPointer(
                            child: DateTimeSection(
                              initialStartDate:
                              _parseDate(widget.quest?.startDate),
                              initialDueDate:
                              _parseDate(widget.quest?.dueDate),
                              initialStartTime:
                              _parseTime(widget.quest?.startTime),
                              initialEndTime:
                              _parseTime(widget.quest?.endTime),
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
                              border: Border.all(
                                  color: const Color(0xFFC2C2C2), width: 1),
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
                                      text: '10exp',
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

                  // 하단 버튼
                  if (widget.quest != null)
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          const Divider(
                              color: Color(0xFFE0E0E0),
                              height: 1,
                              thickness: 1),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    // 수정하기 버튼
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  QuestPartyCreateScreen(
                                                    quest: widget.quest,
                                                  ),
                                            ),
                                          ).then((_) {
                                            Navigator.pop(context);
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                          const Color(0xFF6737F4),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(12)),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          elevation: 0,
                                        ),
                                        child: const Text(
                                          '수정하기',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // 삭제하기 버튼
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          PartyDeleteConfirmationModal.show(
                                            context,
                                            onDelete: () async {
                                              final vm = context.read<
                                                  QuestPartyCreateViewModel>();
                                              final success =
                                              await vm.handleDelete(
                                                  widget.quest!.questId, context);

                                              if (success && mounted) {
                                                PartyDeleteSuccessModal.show(
                                                  context,
                                                  onClose: () {
                                                    Navigator.pop(
                                                        context); // 상세 화면 닫기
                                                  },
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          '삭제 실패: 서버 오류')),
                                                );
                                              }
                                            },
                                            onCancel: () {
                                              Navigator.pop(context);
                                            },
                                          );
                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                              color: Color(0xFF6737F4),
                                              width: 1),
                                          foregroundColor:
                                          const Color(0xFF6737F4),
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(12)),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                        ),
                                        child: const Text(
                                          '삭제하기',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
