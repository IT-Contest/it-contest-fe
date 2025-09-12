import 'package:flutter/material.dart';

class QuestPartyCreateViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  // 퀘스트 타입 (파티 퀘스트는 기본적으로 DAILY)
  String _questType = 'DAILY';
  String get questType => _questType;
  
  void setQuestType(String type) {
    _questType = type;
    notifyListeners();
  }

  // 날짜, 시간 등 필요한 필드 선언 (예시)
  DateTime? _startDate;
  DateTime? _dueDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  void setStartDate(DateTime? date) {
    _startDate = date;
    notifyListeners();
  }

  void setDueDate(DateTime? date) {
    _dueDate = date;
    notifyListeners();
  }

  void setStartTime(TimeOfDay? time) {
    _startTime = time;
    notifyListeners();
  }

  void setEndTime(TimeOfDay? time) {
    _endTime = time;
    notifyListeners();
  }

  Future<bool> createPartyQuest() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      // TODO: 파티 퀘스트 생성 API 호출 및 로직 구현
      await Future.delayed(const Duration(seconds: 1));
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = '파티 퀘스트 생성에 실패했습니다.';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
} 