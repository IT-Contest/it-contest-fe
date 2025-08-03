// quest_list_section.dart, daily_quest_fullpage.dart, quest_search_screen.dart, quest_screen.dart (탭별 퀘스트 리스트 등)
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
  bool _isLoaded = false; // 데이터 로드 여부 플래그

  // 탭 인덱스 관리 (0: 일일, 1: 주간, ...)
  int _selectedTab = 0;
  int get selectedTab => _selectedTab;

  // 메인 화면에 표시될 퀘스트 목록을 위한 getter
  List<QuestItemResponse> get mainPageQuests {
    final incompleteQuests = allQuests
        .where((q) => q.completionStatus == CompletionStatus.INCOMPLETE)
        .toList();

    // 우선순위(오름차순), ثم ID(오름차순, 생성순)로 정렬
    incompleteQuests.sort((a, b) {
      int priorityCompare = a.priority.compareTo(b.priority);
      if (priorityCompare != 0) {
        return priorityCompare;
      }
      return a.questId.compareTo(b.questId);
    });

    return incompleteQuests.take(2).toList();
  }

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

  Future<void> loadQuests({bool force = false}) async {
    // 이미 로드되었고, 강제 새로고침이 아니라면 실행하지 않음
    if (_isLoaded && !force) return;

    isLoading = true;
    notifyListeners();
    try {
      allQuests = await _service.fetchQuestList();
      _isLoaded = true; // 로드 성공 시 플래그 설정
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
    filterQuests(); 
  }

  // 퀘스트 완료 토글
  Future<void> toggleQuest(int questId) async {
    final idx = allQuests.indexWhere((q) => q.questId == questId);
    if (idx != -1) {
      final quest = allQuests[idx];
      final newStatus = quest.completionStatus == CompletionStatus.COMPLETED
          ? CompletionStatus.INCOMPLETE
          : CompletionStatus.COMPLETED;

      try {
        // 1. 서버 API를 호출하고, 성공 응답을 받습니다.
        final response = await _service.updateQuestStatus(questId, newStatus);
        
        // 2. 응답으로 받은 최신 상태를 사용하여 로컬 데이터를 직접 업데이트합니다.
        // QuestStatusChangeResponse에는 completionStatus가 없으므로,
        // 요청했던 newStatus를 사용합니다. API 호출이 성공했기 때문에 상태는 일치합니다.
        final updatedQuest = quest.copyWith(completionStatus: newStatus);

        allQuests[idx] = updatedQuest;
        
        // filteredQuests도 업데이트합니다.
        final filteredIdx = filteredQuests.indexWhere((q) => q.questId == questId);
        if (filteredIdx != -1) {
          filteredQuests[filteredIdx] = updatedQuest;
        }
        
        notifyListeners();
        
      } catch (e) {
        // 에러 처리 (예: 사용자에게 알림 표시)
        print('Error toggling quest: $e');
        // 필요하다면 원래 상태로 롤백하는 로직을 추가할 수 있습니다.
      }
    }
  }
} 