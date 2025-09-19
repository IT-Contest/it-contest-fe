import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:it_contest_fe/features/quest/model/party_model.dart';
import 'package:it_contest_fe/features/quest/model/party_update_request.dart';
import 'package:it_contest_fe/features/quest/model/completion_status.dart'; // ✅ enum
import 'package:it_contest_fe/features/quest/service/party_service.dart';
import 'package:it_contest_fe/shared/widgets/quest_creation_modal.dart';
import '../model/quest_item_response.dart';

class QuestPartyCreateViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  // 입력값 상태
  String title = '';        // 퀘스트명
  String content = '';      // 파티 내용
  int priority = 0;
  String? period;
  CompletionStatus completionStatus = CompletionStatus.INCOMPLETE; // ✅ enum
  List<String> categories = [];
  DateTime? startDate;
  DateTime? dueDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  List<dynamic> invitedFriends = [];

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool get isFormValid {
    return title.isNotEmpty &&
        content.isNotEmpty &&
        priority > 0 &&
        period != null &&
        categories.isNotEmpty &&
        startDate != null &&
        dueDate != null &&
        startTime != null &&
        endTime != null;
  }

  /// 초기화 (수정 모드)
  void initializeFromQuest(QuestItemResponse quest) {
    content = quest.partyName ?? '';
    title = quest.title;
    priority = quest.priority;
    period = quest.questType;
    completionStatus = quest.completionStatus ?? CompletionStatus.INCOMPLETE;
    categories = List<String>.from(quest.hashtags);

    if (quest.startDate != null) {
      startDate = DateTime.tryParse(quest.startDate!);
    }
    if (quest.dueDate != null) {
      dueDate = DateTime.tryParse(quest.dueDate!);
    }
    if (quest.startTime != null) {
      final parts = quest.startTime!.split(':');
      startTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    if (quest.endTime != null) {
      final parts = quest.endTime!.split(':');
      endTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    notifyListeners();
  }

  // ✅ Setter 메서드 전부 복원
  void setQuestTitle(String value) {
    title = value;
    notifyListeners();
  }

  void setContent(String value) {
    content = value;
    notifyListeners();
  }

  void setPriority(int value) {
    priority = value;
    notifyListeners();
  }

  void setPeriod(String? value) {
    period = value;
    notifyListeners();
  }

  void setCategories(List<String> value) {
    categories = value;
    notifyListeners();
  }

  void setStartDate(DateTime date) {
    startDate = date;
    notifyListeners();
  }

  void setDueDate(DateTime date) {
    dueDate = date;
    notifyListeners();
  }

  void setStartTime(TimeOfDay time) {
    startTime = time;
    notifyListeners();
  }

  void setEndTime(TimeOfDay time) {
    endTime = time;
    notifyListeners();
  }

  void setCompletionStatus(CompletionStatus status) {
    completionStatus = status;
    notifyListeners();
  }

  void setInvitedFriends(List<dynamic> friends) {
    invitedFriends = friends;
    notifyListeners();
  }

  /// ✅ 파티 생성 처리
  Future<void> handleCreate(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    final partyService = PartyService();

    try {
      final accessToken = await _storage.read(key: "accessToken");
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("로그인 토큰이 없습니다. 다시 로그인 해주세요.");
      }

      final request = PartyCreateRequest(
        content: content,
        questTitle: title,
        priority: priority,
        questType: _mapPeriodToQuestType(period),
        completionStatus: completionStatus.name, // ✅ enum → String 변환
        startDate: startDate?.toIso8601String().split("T")[0] ?? "",
        dueDate: dueDate?.toIso8601String().split("T")[0] ?? "",
        startTime: _formatTime(startTime),
        endTime: _formatTime(endTime),
        hashtags: categories,
      );

      final questId = await partyService.createPartyQuest(request, accessToken);

      if (questId != null && invitedFriends.isNotEmpty) {
        final friendIds = invitedFriends.map((f) => f.userId as int).toList();
        await partyService.inviteFriends(questId, friendIds, accessToken);
      }

      QuestCreationModal.show(
        context,
        onClose: () => Navigator.pushReplacementNamed(context, '/main'),
      );
    } catch (e) {
      errorMessage = "파티 생성 실패: $e";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage!)),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ 파티 수정 처리
  Future<bool> handleUpdate(int partyId, BuildContext context) async {
    isLoading = true;
    notifyListeners();

    final partyService = PartyService();

    try {
      final accessToken = await _storage.read(key: "accessToken");
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("로그인 토큰이 없습니다. 다시 로그인 해주세요.");
      }

      final updateRequest = PartyUpdateRequest(
        content: content,
        priority: priority,
        questType: _mapPeriodToQuestType(period),
        completionStatus: completionStatus.name, // ✅ enum → String 변환
        startDate: startDate?.toIso8601String().split("T")[0] ?? "",
        dueDate: dueDate?.toIso8601String().split("T")[0] ?? "",
        startTime: _formatTime(startTime),
        endTime: _formatTime(endTime),
        hashtags: categories,
      );

      final success = await partyService.updatePartyQuest(partyId, updateRequest, accessToken);

      if (!success) {
        throw Exception("파티 수정 실패");
      }

      return true;
    } catch (e) {
      errorMessage = "파티 수정 실패: $e";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage!)),
      );
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 파티 삭제
  Future<bool> handleDelete(int partyId) async {
    final partyService = PartyService();
    final accessToken = await _storage.read(key: "accessToken");

    if (accessToken == null || accessToken.isEmpty) {
      errorMessage = "로그인 토큰이 없습니다. 다시 로그인 해주세요.";
      return false;
    }

    return await partyService.deletePartyQuest(partyId, accessToken);
  }


  String _mapPeriodToQuestType(String? period) {
    switch (period) {
      case "일일":
        return "DAILY";
      case "주간":
        return "WEEKLY";
      case "월간":
        return "MONTHLY";
      case "연간":
        return "YEARLY";
      default:
        return "DAILY";
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return "";
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute:00";
  }
}
