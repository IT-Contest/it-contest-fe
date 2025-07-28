import 'package:flutter/material.dart';
import 'package:it_contest_fe/features/quest/model/quest_create_request.dart';
import 'package:it_contest_fe/features/quest/service/quest_service.dart';

// TimeData class removed; use the imported one from quest_create_request.dart

class QuestPersonalCreateViewModel extends ChangeNotifier {
  String questName = '';
  int priority = 1;
  String questType = 'DAILY';
  String completionStatus = 'INCOMPLETE';
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  DateTime? startDate;
  DateTime? dueDate;
  List<String> hashtags = [];

  bool isLoading = false;
  String? errorMessage;

  void setQuestName(String value) {
    questName = value;
    notifyListeners();
  }

  void setPriority(int value) {
    priority = value;
    notifyListeners();
  }

  void setStartTime(TimeOfDay? value) {
    startTime = value;
    notifyListeners();
  }

  void setEndTime(TimeOfDay? value) {
    endTime = value;
    notifyListeners();
  }

  void setStartDate(DateTime? value) {
    startDate = value;
    notifyListeners();
  }

  void setDueDate(DateTime? value) {
    dueDate = value;
    notifyListeners();
  }

  void setHashtags(List<String> value) {
    hashtags = value;
    notifyListeners();
  }

  void setQuestType(String value) {
    const periodMap = {
      '일일': 'DAILY',
      '주간': 'WEEKLY',
      '월간': 'MONTHLY',
      '연간': 'YEARLY',
    };
    questType = periodMap[value] ?? 'DAILY';
    notifyListeners();
  }

  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<bool> createQuest() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final request = QuestCreateRequest(
        content: questName,
        priority: priority,
        questType: questType,
        completionStatus: completionStatus,
        startTime: startTime != null
            ? "${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}:00"
            : "00:00:00",
        endTime: endTime != null
            ? "${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}:00"
            : "00:00:00",
        startDate: startDate != null ? _formatDate(startDate!) : '',
        dueDate: dueDate != null ? _formatDate(dueDate!) : '',
        hashtags: hashtags,
      );
      print('[개인 퀘스트 생성 요청] ${request.toJson().toString()}');
      final success = await QuestService().createQuest(request);
      isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      isLoading = false;
      errorMessage = '개인 퀘스트 생성 실패: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}