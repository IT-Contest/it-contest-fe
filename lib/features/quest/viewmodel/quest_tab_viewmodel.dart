import 'package:flutter/material.dart';
import '../model/quest_item_response.dart';
import '../service/quest_service.dart';
import '../model/completion_status.dart';

class QuestTabViewModel extends ChangeNotifier {
  final QuestService _service = QuestService();
  List<QuestItemResponse> allQuests = [];
  List<QuestItemResponse> filteredQuests = [];
  String selectedPeriod = 'DAILY'; // 기본값
  bool isLoading = false;
  String? errorMessage;

  // 탭 인덱스 관리 (0: 일일, 1: 주간, ...)
  int _selectedTab = 0;
  int get selectedTab => _selectedTab;

  void changeTab(int i) {
    if (_selectedTab != i) {
      _selectedTab = i;
      switch (i) {
        case 0:
          changePeriod('DAILY');
          break;
        case 1:
          changePeriod('WEEKLY');
          break;
        case 2:
          changePeriod('MONTHLY');
          break;
        case 3:
          changePeriod('YEARLY');
          break;
      }
      notifyListeners();
    }
  }

  Future<void> loadQuests() async {
    isLoading = true;
    notifyListeners();
    try {
      allQuests = await _service.fetchQuestList();
      print('[퀘스트 API 응답]');
      for (final q in allQuests) {
        print(q.toJson());
      }
      filterQuests();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void filterQuests() {
    filteredQuests = allQuests.where((q) => q.questType == selectedPeriod).toList();
    notifyListeners();
  }

  void changePeriod(String period) {
    selectedPeriod = period;
    filterQuests(); // ✅ 이걸로 충분
  }

  // 퀘스트 완료 토글 (예시)
  void toggleQuest(int questId) {
    final idx = filteredQuests.indexWhere((q) => q.questId == questId);
    if (idx != -1) {
      final quest = filteredQuests[idx];
      final newStatus = quest.completionStatus == CompletionStatus.COMPLETED
          ? CompletionStatus.INCOMPLETE
          : CompletionStatus.COMPLETED;

      // filteredQuests와 allQuests 모두 업데이트
      filteredQuests[idx] = QuestItemResponse(
        questId: quest.questId,
        title: quest.title,
        expReward: quest.expReward,
        goldReward: quest.goldReward,
        priority: quest.priority,
        partyName: quest.partyName,
        completionStatus: newStatus,
        questType: quest.questType,
      );
      final allIdx = allQuests.indexWhere((q) => q.questId == questId);
      if (allIdx != -1) {
        allQuests[allIdx] = filteredQuests[idx];
      }
      notifyListeners();
    }
  }
} 