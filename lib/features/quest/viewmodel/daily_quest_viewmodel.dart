// daily_quest_list.dart (메인화면 일일퀘스트), quest_search_section.dart (퀘스트 검색 화면)
import 'package:flutter/material.dart';
import '../model/completion_status.dart';
import '../model/quest_item_response.dart';
import '../service/quest_service.dart';

class DailyQuestViewModel extends ChangeNotifier {
  final QuestService _service = QuestService();
  List<QuestItemResponse> quests = [];
  bool isLoading = false;
  String? errorMessage;

  // 최근 체크한 퀘스트 ID를 잠깐 저장 (애니메이션용)
  Set<int> recentlyCompleted = {};

  void addRecentlyCompleted(int questId) {
    recentlyCompleted.add(questId);
    notifyListeners();
  }

  void removeRecentlyCompleted(int questId) {
    recentlyCompleted.remove(questId);
    notifyListeners();
  }

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

      // (7/30 추가) 퀘스트 완료시 완료된 퀘스트를 메인화면 퀘스트 목록에서 없애고 아직 완료되지 않은 퀘스트를 불러와 채운다.
      final incompleteQuests = all
          .where((q) => q.completionStatus == CompletionStatus.INCOMPLETE)
          .toList();

      // 정렬은 우선순위로 정렬해서 보여준다. (1이 선순위, 5가 가장 후순위) (7/2추가)
      // 우선순위가 같으면 만들어진 순으로 보여준다.
      incompleteQuests.sort((a, b) {
        int priorityCompare = a.priority.compareTo(b.priority);
        if (priorityCompare != 0) {
          return priorityCompare;
        }
        return a.questId.compareTo(b.questId);
      });

      // (7/30 추가) 퀘스트는 최대 2개까지 보여준다.
      quests = incompleteQuests.take(2).toList();
      
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 퀘스트 완료 / 취소
  Future<void> toggleQuestCompletionById(int questId, {bool syncWithServer = false, Function(bool)? onCompleted}) async {
    try {
      final idx = quests.indexWhere((q) => q.questId == questId);
      if (idx == -1) return;
      final old = quests[idx];
      final newStatus = old.completionStatus == CompletionStatus.COMPLETED
          ? CompletionStatus.INCOMPLETE
          : CompletionStatus.COMPLETED;

      // 1. 로컬 상태만 변경
      quests[idx] = old.copyWith(completionStatus: newStatus);
      notifyListeners();

      // 2. 서버에 상태 변경 요청
      final response = await _service.updateQuestStatus(questId, newStatus);

      // 3. 퀘스트 완료 시 콜백 호출 (isFirstCompletion 전달)
      if (newStatus == CompletionStatus.COMPLETED && onCompleted != null) {
        onCompleted(response.isFirstCompletion);
      }

      // 4. 서버 동기화는 옵션으로
      if (syncWithServer) {
        await fetchMainQuests();
      }
    } catch (e) {
      print('[체크 상태 변경 실패] $e');
      await fetchMainQuests();
    }
  }
}