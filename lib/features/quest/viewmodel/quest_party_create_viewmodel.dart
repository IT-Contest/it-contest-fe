import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:it_contest_fe/features/quest/model/party_model.dart';
import 'package:it_contest_fe/features/quest/model/party_update_request.dart';
import 'package:it_contest_fe/features/quest/model/completion_status.dart'; // ✅ enum
import 'package:it_contest_fe/features/quest/service/party_service.dart';
import 'package:it_contest_fe/shared/widgets/quest_creation_modal.dart';
import '../../../shared/party/party_access_denied_modal.dart';
import '../../friends/model/friend_info.dart';
import '../model/quest_item_response.dart';

class QuestPartyCreateViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  // 입력값 상태
  String partyTitle = '';   // 파티명
  String questName = '';    // 퀘스트 내용
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
    return partyTitle.isNotEmpty &&
        questName.isNotEmpty &&
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
    partyTitle = quest.partyTitle ?? '';
    questName = quest.questName ?? '';
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

  // ✅ Setter 메서드
  void setQuestTitle(String value) {
    partyTitle = value;
    notifyListeners();
  }

  void setContent(String value) {
    questName = value;
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

  /// ✅ 보상 계산 로직 (개인 퀘스트와 동일하게 적용)
  Map<String, int> _calculateRewards(String questName) {
    if (questName.toLowerCase().contains('온보딩') ||
        questName.toLowerCase().contains('onboarding')) {
      return {
        'exp': 100,
        'gold': 50,
      };
    }
    return {
      'exp': 10,
      'gold': 5,
    };
  }

  /// ✅ 파티 생성 처리
  Future<bool> handleCreate(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    final partyService = PartyService();

    try {
      final accessToken = await _storage.read(key: "accessToken");
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("로그인 토큰이 없습니다. 다시 로그인 해주세요.");
      }

      // ✅ 보상 계산
      final rewards = _calculateRewards(questName);

      final request = PartyCreateRequest(
        partyTitle: partyTitle,
        questName: questName,
        priority: priority,
        questType: _mapPeriodToQuestType(period),
        completionStatus: completionStatus.name,
        startDate: startDate?.toIso8601String().split("T")[0] ?? "",
        dueDate: dueDate?.toIso8601String().split("T")[0] ?? "",
        startTime: _formatTime(startTime),
        endTime: _formatTime(endTime),
        hashtags: categories,
        expReward: rewards['exp']!,
        goldReward: rewards['gold']!,
      );

      final response = await partyService.createPartyQuestWithReward(request, accessToken);

      if (response != null && response['success'] == true) {
        final partyId = response['partyId'];

        if (partyId != null && invitedFriends.isNotEmpty) {
          final friendIds = invitedFriends.map((f) => (f as FriendInfo).userId).toList();
          await partyService.inviteFriends(partyId, friendIds, accessToken);
        }

        return true; // 성공
      } else {
        return false; // 실패
      }
    } catch (e) {
      errorMessage = "파티 생성 실패: $e";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage!)),
      );
      return false;
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

      final rewards = _calculateRewards(questName);

      final updateRequest = PartyUpdateRequest(
        partyTitle: partyTitle,
        questName: questName,
        priority: priority,
        questType: _mapPeriodToQuestType(period),
        completionStatus: completionStatus.name,
        startDate: startDate?.toIso8601String().split("T")[0] ?? "",
        dueDate: dueDate?.toIso8601String().split("T")[0] ?? "",
        startTime: _formatTime(startTime),
        endTime: _formatTime(endTime),
        hashtags: categories,
        expReward: rewards['exp']!,
        goldReward: rewards['gold']!,
      );

      final success = await partyService.updatePartyQuest(
        partyId,
        updateRequest,
        accessToken,
      );

      if (!success) {
        throw Exception("파티 수정 실패");
      }

      return true;
    } on DioException catch (e) {
      final data = e.response?.data;
      final statusCode = data?['statusCode'];
      final message = data?['message'] ?? '';

      debugPrint('❌ handleUpdate DioException: $data');

      // ✅ 파티장이 아닐 경우 (PARTY_4004)
      if (statusCode == 'PARTY_4004') {
        PartyAccessDeniedModal.show(
          context,
          message: '파티퀘스트는 파티장만 수정 가능합니다.',
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('수정 실패: $message')),
        );
      }

      return false;
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
  Future<bool> handleDelete(int partyId, BuildContext context) async {
    final partyService = PartyService();
    final accessToken = await _storage.read(key: "accessToken");

    if (accessToken == null || accessToken.isEmpty) {
      errorMessage = "로그인 토큰이 없습니다. 다시 로그인 해주세요.";
      return false;
    }

    try {
      return await partyService.deletePartyQuest(partyId, accessToken);
    } on DioException catch (e) {
      final data = e.response?.data;

      final statusCode = data?['statusCode'];
      final message = data?['message'] ?? '';

      // "PARTY_4004"이면 접근 권한 없음 → 모달 띄우기
      if (statusCode == 'PARTY_4004') {
        PartyAccessDeniedModal.show(
          context,
          message: '파티퀘스트는 파티장만 삭제 가능합니다.',
        );
      } else {
        // 그 외 오류는 일반적인 SnackBar로 처리
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $message')),
        );
      }
      return false;
    } catch (e) {
      debugPrint('파티 삭제 예외: $e');
      return false;
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

  String _formatTime(TimeOfDay? time) {
    if (time == null) return "";
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute:00";
  }
}
