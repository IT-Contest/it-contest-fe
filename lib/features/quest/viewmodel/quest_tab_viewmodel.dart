import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../analysis/viewmodel/analysis_viewmodel.dart';
import '../model/quest_item_response.dart';
import '../model/completion_status.dart';
import '../model/invitation_status.dart'; // ✅ 새로 만든 enum import
import '../service/quest_service.dart';
import '../service/party_service.dart';

class QuestTabViewModel extends ChangeNotifier {
  final QuestService _service = QuestService();
  final PartyService _partyService = PartyService(); // ✅ 파티 서비스 추가

  List<QuestItemResponse> allQuests = [];
  List<QuestItemResponse> filteredQuests = [];
  List<QuestItemResponse> partyQuests = []; // ✅ 파티 퀘스트 전용 리스트
  String selectedPeriod = 'DAILY';
  bool isLoading = false;
  String? errorMessage;
  bool _isLoaded = false;

  int _selectedTab = 0;
  int get selectedTab => _selectedTab;

  List<QuestItemResponse> get mainPageQuests {
    final incompleteQuests = allQuests
        .where((q) => q.completionStatus == CompletionStatus.INCOMPLETE)
        .toList();

    incompleteQuests.sort((a, b) {
      int priorityCompare = a.priority.compareTo(b.priority);
      if (priorityCompare != 0) return priorityCompare;
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
    if (_isLoaded && !force) return;

    isLoading = true;
    notifyListeners();
    try {
      allQuests = await _service.fetchQuestList();
      _isLoaded = true;
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

  // 파티 퀘스트 전용 API 호출 메서드
  Future<void> loadPartyQuests(String accessToken) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _partyService.fetchMyParties(accessToken);

      // JSON → QuestItemResponse 변환
      final allPartyQuests = response
          .map((json) => QuestItemResponse.fromJson(json))
          .toList();

      // 여기서 필터링
      partyQuests = allPartyQuests.where((q) =>
      q.completionStatus == CompletionStatus.IN_PROGRESS ||
          q.completionStatus == CompletionStatus.COMPLETED).toList();

      errorMessage = null;
    } catch (e) {
      errorMessage = '파티 퀘스트 조회 실패: $e';
      partyQuests = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  Future<void> toggleQuest(int questId, {Function(bool)? onCompleted, BuildContext? context}) async {
    final idx = allQuests.indexWhere((q) => q.questId == questId);
    if (idx != -1) {
      final quest = allQuests[idx];
      final newStatus = quest.completionStatus == CompletionStatus.COMPLETED
          ? CompletionStatus.INCOMPLETE
          : CompletionStatus.COMPLETED;

      try {
        final response = await _service.updateQuestStatus(questId, newStatus);
        final updatedQuest = quest.copyWith(completionStatus: newStatus);

        allQuests[idx] = updatedQuest;

        final filteredIdx = filteredQuests.indexWhere((q) => q.questId == questId);
        if (filteredIdx != -1) {
          filteredQuests[filteredIdx] = updatedQuest;
        }

        notifyListeners();

        if (newStatus == CompletionStatus.COMPLETED && onCompleted != null) {
          onCompleted(response.isFirstCompletion);
        }

        if (context != null) {
          try {
            final analysisViewModel = context.read<AnalysisViewModel>();
            analysisViewModel.loadAnalysisData();
          } catch (_) {}
        }
      } catch (e) {
        print('Error toggling quest: $e');
      }
    }
  }

  Future<void> togglePartyQuestCompletion(
      int partyId, {
        Function(bool)? onCompleted,
        BuildContext? context,
      }) async {
    final idx = partyQuests.indexWhere((q) => q.questId == partyId);
    if (idx != -1) {
      final quest = partyQuests[idx];
      final newStatus = quest.completionStatus == CompletionStatus.COMPLETED
          ? CompletionStatus.IN_PROGRESS // 🔑 파티퀘스트는 IN_PROGRESS로 되돌림
          : CompletionStatus.COMPLETED;

      try {
        // 백엔드 PATCH API 호출 (partyId, newStatus 전달)
        final response = await _service.updateQuestStatus(partyId, newStatus);
        final updatedQuest = quest.copyWith(completionStatus: newStatus);

        partyQuests[idx] = updatedQuest;
        notifyListeners();

        if (newStatus == CompletionStatus.COMPLETED && onCompleted != null) {
          onCompleted(response.isFirstCompletion);
        }

        if (context != null) {
          try {
            final analysisViewModel = context.read<AnalysisViewModel>();
            analysisViewModel.loadAnalysisData();
          } catch (_) {}
        }
      } catch (e) {
        print('Error toggling party quest: $e');
      }
    }
  }


  Future<bool> deleteQuest(int questId) async {
    try {
      final success = await _service.deleteQuest(questId);
      if (success) {
        allQuests.removeWhere((q) => q.questId == questId);
        filteredQuests.removeWhere((q) => q.questId == questId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
