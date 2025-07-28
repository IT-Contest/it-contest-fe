import 'package:flutter/material.dart';
import '../model/completion_status.dart';
import '../model/quest_item_response.dart';
import '../service/quest_service.dart';

class DailyQuestViewModel extends ChangeNotifier {
  final QuestService _service = QuestService();
  List<QuestItemResponse> quests = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchQuests({int? limit}) async {
    isLoading = true;
    notifyListeners();

    try {
      final all = await _service.fetchQuestList();

      // INCOMPLETE 먼저, COMPLETED 나중에
      final incompletes = all.where((q) => q.completionStatus == CompletionStatus.INCOMPLETE).toList()
        ..sort((a, b) => b.priority.compareTo(a.priority));
      final completed = all.where((q) => q.completionStatus == CompletionStatus.COMPLETED).toList()
        ..sort((a, b) => b.priority.compareTo(a.priority));

      final sorted = [...incompletes, ...completed];
      quests = (limit != null) ? sorted.take(limit).toList() : sorted;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMainQuests() async {
    isLoading = true;
    notifyListeners();

    try {
      final all = await _service.fetchQuestList();

      // ✅ 메인화면은 INCOMPLETE만, 우선순위 내림차순, 최대 2개만
      quests = all
          .where((q) => q.completionStatus == CompletionStatus.INCOMPLETE)
          .toList()
        ..sort((a, b) => b.priority.compareTo(a.priority));

      // 최대 2개까지만 유지
      quests = quests.take(2).toList();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 퀘스트 완료 / 취소
  Future<void> toggleQuestCompletionById(int questId) async {
    try {
      final old = quests.firstWhere((q) => q.questId == questId);
      final newStatus = old.completionStatus == CompletionStatus.COMPLETED
          ? 'INCOMPLETE'
          : 'COMPLETED';

      final updatedList = await _service.changeQuestStatus([questId], newStatus);
      final updated = updatedList.first;

      final index = quests.indexWhere((q) => q.questId == questId);
      if (index == -1) return;

      quests[index] = QuestItemResponse(
        questId: updated.questId,
        title: updated.title,
        expReward: old.expReward,
        goldReward: old.goldReward,
        priority: old.priority,
        partyName: old.partyName,
        completionStatus: updated.completionStatus,
        questType: old.questType,
        hashtags: old.hashtags,
      );

      // 정렬 반영
      final incompletes = quests
          .where((q) => q.completionStatus == CompletionStatus.INCOMPLETE)
          .toList()
        ..sort((a, b) => b.priority.compareTo(a.priority));

      final completed = quests
          .where((q) => q.completionStatus == CompletionStatus.COMPLETED)
          .toList()
        ..sort((a, b) => b.priority.compareTo(a.priority));

      quests = [...incompletes, ...completed];

      notifyListeners();
    } catch (e) {
      print('[체크 상태 변경 실패] $e');
    }
  }
}