import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 🔑 토큰 저장소
import 'package:it_contest_fe/features/quest/model/party_model.dart';
import 'package:it_contest_fe/features/quest/service/party_service.dart';
import 'package:it_contest_fe/shared/widgets/quest_creation_modal.dart';

class QuestPartyCreateViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  // 입력값 상태
  String title = '';        // 퀘스트명 (questTitle)
  String content = '';      // 파티 내용
  int priority = 0;
  String? period;
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

  // setter
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

  void setInvitedFriends(List<dynamic> friends) {
    invitedFriends = friends;
    notifyListeners();
  }

  // ✅ 파티 생성 처리
  Future<void> handleCreate(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    final partyService = PartyService();

    try {
      // 🔑 SecureStorage에서 accessToken 불러오기
      final accessToken = await _storage.read(key: "accessToken");

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("로그인 토큰이 없습니다. 다시 로그인 해주세요.");
      }

      final request = PartyCreateRequest(
        content: content,
        questTitle: title,
        priority: priority,
        questType: _mapPeriodToQuestType(period),
        completionStatus: "INCOMPLETE",
        startDate: startDate?.toIso8601String().split("T")[0] ?? "",
        dueDate: dueDate?.toIso8601String().split("T")[0] ?? "",
        startTime: startTime != null
            ? "${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}:00"
            : "",
        endTime: endTime != null
            ? "${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}:00"
            : "",
        hashtags: categories,
      );

      final questId = await partyService.createPartyQuest(request, accessToken);
      print("📤 questId(before) = $questId");
      print("📤 invitedFriends(before) = $invitedFriends");
      if (questId != null && invitedFriends.isNotEmpty) {
        final friendIds = invitedFriends.map((f) => f.userId as int).toList();
        await partyService.inviteFriends(questId, friendIds, accessToken);
        print("📤 invitedFriends = $invitedFriends");
        print("📤 questId = $questId");
      }
      print("📤 questId(after) = $questId");
      print("📤 invitedFriends(after) = $invitedFriends");
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

}
