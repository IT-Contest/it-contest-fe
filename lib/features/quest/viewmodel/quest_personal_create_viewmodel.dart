import 'package:flutter/material.dart';
import 'package:it_contest_fe/features/quest/model/quest_create_request.dart';
import 'package:it_contest_fe/features/quest/service/quest_service.dart';
import 'package:it_contest_fe/features/quest/model/quest_item_response.dart';

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

  void initializeFromQuest(QuestItemResponse quest) {
    questName = quest.title;
    priority = quest.priority;
    questType = quest.questType;
    hashtags = List<String>.from(quest.hashtags);
    
    // 날짜/시간 파싱 및 초기화
    if (quest.startDate != null) {
      try {
        startDate = DateTime.parse(quest.startDate!);
      } catch (e) {
        startDate = null;
      }
    }
    
    if (quest.dueDate != null) {
      try {
        dueDate = DateTime.parse(quest.dueDate!);
      } catch (e) {
        dueDate = null;
      }
    }
    
    if (quest.startTime != null) {
      try {
        final parts = quest.startTime!.split(':');
        startTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      } catch (e) {
        startTime = null;
      }
    }
    
    if (quest.endTime != null) {
      try {
        final parts = quest.endTime!.split(':');
        endTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      } catch (e) {
        endTime = null;
      }
    }
    
    notifyListeners();
  }

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
        startTime: startTime != null ? '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}:00' : '00:00:00',
        endTime: endTime != null ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}:00' : '23:59:59',
        startDate: startDate?.toIso8601String().split('T')[0] ?? DateTime.now().toIso8601String().split('T')[0],
        dueDate: dueDate?.toIso8601String().split('T')[0] ?? DateTime.now().toIso8601String().split('T')[0],
        hashtags: hashtags,
      );

      final success = await QuestService().createQuest(request);
      
      if (success) {
        print('[퀘스트 생성 성공]');
      } else {
        errorMessage = '퀘스트 생성에 실패했습니다.';
      }
      
      return success;
    } catch (e) {
      errorMessage = '퀘스트 생성 중 오류가 발생했습니다: $e';
      print('[퀘스트 생성 오류] $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 퀘스트 수정 메서드 추가
  Future<bool> updateQuest(int questId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final updateData = {
        'content': questName,
        'priority': priority,
        'questType': questType,
        'startTime': startTime != null ? '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}:00' : '00:00:00',
        'endTime': endTime != null ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}:00' : '23:59:59',
        'startDate': startDate?.toIso8601String().split('T')[0] ?? DateTime.now().toIso8601String().split('T')[0],
        'dueDate': dueDate?.toIso8601String().split('T')[0] ?? DateTime.now().toIso8601String().split('T')[0],
        'hashtags': hashtags,
      };

      final success = await QuestService().updateQuest(questId, updateData);
      
      if (success) {
        print('[퀘스트 수정 성공]');
      } else {
        errorMessage = '퀘스트 수정에 실패했습니다.';
      }
      
      return success;
    } catch (e) {
      errorMessage = '퀘스트 수정 중 오류가 발생했습니다: $e';
      print('[퀘스트 수정 오류] $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}