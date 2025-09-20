import 'package:flutter/material.dart';
import 'package:it_contest_fe/features/quest/service/quest_service.dart';
import 'package:it_contest_fe/features/quest/model/quest_item_response.dart';
import 'package:it_contest_fe/features/quest/model/quest_create_request.dart';

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


  Future<bool> createQuest() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // ✅ 엑셀 데이터에 따른 보상 계산
      final rewards = _calculateRewards(questType, questName);
      
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
        expReward: rewards['exp']!,
        goldReward: rewards['gold']!,
      );

      final result = await QuestService().createQuestWithReward(request);
      
      if (result != null && result['success'] == true) {
        print('[퀘스트 생성 성공]');
        return true;
      } else {
        errorMessage = '퀘스트 생성에 실패했습니다.';
        return false;
      }
    } catch (e) {
      errorMessage = '퀘스트 생성 중 오류가 발생했습니다: $e';
      print('[퀘스트 생성 오류] $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Map<String, int> _calculateRewards(String questType, String questName) {
    // 온보딩 퀘스트 체크 (퀘스트 이름에 '온보딩' 또는 'onboarding'이 포함된 경우)
    if (questName.toLowerCase().contains('온보딩') || 
        questName.toLowerCase().contains('onboarding')) {
      return {
        'exp': 100,  // 온보딩 퀘스트는 100 exp
        'gold': 50,  // 온보딩 퀘스트 골드 보상
      };
    }
    
    // 일반 퀘스트는 엑셀 데이터에 따라 10 exp
    return {
      'exp': 10,   // 모든 일반 퀘스트는 10 exp
      'gold': 5,   // 기본 골드 보상
    };
  }

  // 퀘스트 수정 메서드 추가
  Future<bool> updateQuest(int questId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // 엑셀 데이터에 따른 보상 계산
      final rewards = _calculateRewards(questType, questName);
      
      final updateData = {
        'content': questName,
        'priority': priority,
        'questType': questType,
        'startTime': startTime != null ? '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}:00' : '00:00:00',
        'endTime': endTime != null ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}:00' : '23:59:59',
        'startDate': startDate?.toIso8601String().split('T')[0] ?? DateTime.now().toIso8601String().split('T')[0],
        'dueDate': dueDate?.toIso8601String().split('T')[0] ?? DateTime.now().toIso8601String().split('T')[0],
        'hashtags': hashtags,
        'expReward': rewards['exp']!,
        'goldReward': rewards['gold']!,
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