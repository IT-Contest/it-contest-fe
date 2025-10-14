import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../../../shared/party/party_access_denied_modal.dart';
import '../../analysis/viewmodel/analysis_viewmodel.dart';
import '../model/quest_item_response.dart';
import '../model/completion_status.dart';
import '../service/quest_service.dart';
import '../service/party_service.dart';

class QuestTabViewModel extends ChangeNotifier {
  final QuestService _service = QuestService();
  final PartyService _partyService = PartyService();

  // 개인 퀘스트
  List<QuestItemResponse> allQuests = [];
  List<QuestItemResponse> filteredQuests = [];

  // 파티 퀘스트
  List<QuestItemResponse> allPartyQuests = []; // 전체 원본
  List<QuestItemResponse> partyQuests = [];    // 필터링된 결과

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
    filteredQuests =
        allQuests.where((q) => q.questType == selectedPeriod).toList();
    notifyListeners();
  }

  void filterPartyQuests() {
    partyQuests =
        allPartyQuests.where((q) => q.questType == selectedPeriod).toList();
    notifyListeners();
  }

  void changePeriod(String period) {
    selectedPeriod = period;
    filterQuests();
    filterPartyQuests(); // 파티 퀘스트도 필터링 적용
  }

  // 파티 퀘스트 불러오기
  Future<void> loadPartyQuests(String accessToken) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _partyService.fetchMyParties(accessToken);

      allPartyQuests = response
          .map((json) => QuestItemResponse.fromJson(json))
          .toList();

      partyQuests = List.from(allPartyQuests);

      errorMessage = null;
    } catch (e) {
      errorMessage = '파티 퀘스트 조회 실패: $e';
      allPartyQuests = [];
      partyQuests = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleQuest(int questId,
      {Function(bool)? onCompleted, BuildContext? context}) async {
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

        final filteredIdx =
        filteredQuests.indexWhere((q) => q.questId == questId);
        if (filteredIdx != -1) {
          filteredQuests[filteredIdx] = updatedQuest;
        }

        notifyListeners();

        if (onCompleted != null) {
          onCompleted(newStatus == CompletionStatus.COMPLETED);
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
        Function(CompletionStatus)? onStatusChanged,
        BuildContext? context,
      }) async {
    final idx = allPartyQuests.indexWhere((q) => q.questId == partyId);
    if (idx == -1) return;

    final quest = allPartyQuests[idx];
    final newStatus = quest.completionStatus == CompletionStatus.COMPLETED
        ? CompletionStatus.IN_PROGRESS
        : CompletionStatus.COMPLETED;

    try {
      final token = await const FlutterSecureStorage().read(key: "accessToken");
      if (token == null) throw Exception("No access token found");

      final response = await _partyService.changePartyQuestStatus(
        partyId,
        newStatus,
        token,
      );

      final updatedQuest = quest.copyWith(completionStatus: newStatus);
      allPartyQuests[idx] = updatedQuest;
      filterPartyQuests();
      notifyListeners();

      if (onStatusChanged != null) {
        onStatusChanged(newStatus);
      }

      if (context != null) {
        try {
          final analysisViewModel = context.read<AnalysisViewModel>();
          analysisViewModel.loadAnalysisData();
        } catch (_) {}
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final statusCode = data?['statusCode'];
      final message = data?['message'] ?? '';

      debugPrint("❌ togglePartyQuestCompletion DioException: $data");

      // ✅ 파티장만 완료/취소 가능
      if (statusCode == 'PARTY_4004' && context != null) {
        PartyAccessDeniedModal.show(
          context,
          message: '파티퀘스트는 파티장만 완료 혹은 취소 가능합니다.',
        );
      } else if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('상태 변경 실패: $message')),
        );
      }
    } catch (e) {
      print("❌ togglePartyQuestCompletion error: $e");
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

  Future<void> loadInitialData() async {
    // 개인 퀘스트 불러오기
    await loadQuests(force: true);

    // 파티 퀘스트 불러오기
    final token = await const FlutterSecureStorage().read(key: "accessToken");
    if (token != null) {
      await loadPartyQuests(token);
    }
  }

}