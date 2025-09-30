import 'package:flutter/material.dart';
import '../viewmodel/quest_party_create_viewmodel.dart';

class PartyUpdateRequest {
  final String partyTitle;
  final String questName;
  final int priority;
  final String questType; // "DAILY", "WEEKLY", "MONTHLY", "YEARLY"
  final String completionStatus; // "INCOMPLETE" or "COMPLETED"
  final String startDate; // "yyyy-MM-dd"
  final String dueDate;   // "yyyy-MM-dd"
  final String startTime; // "HH:mm"
  final String endTime;   // "HH:mm"
  final List<String> hashtags;

  // ✅ 보상 필드 추가
  final int expReward;
  final int goldReward;

  PartyUpdateRequest({
    required this.partyTitle,
    required this.questName,
    required this.priority,
    required this.questType,
    required this.completionStatus,
    required this.startDate,
    required this.dueDate,
    required this.startTime,
    required this.endTime,
    required this.hashtags,
    required this.expReward,
    required this.goldReward,
  });

  /// 직렬화 (PATCH 요청 body)
  Map<String, dynamic> toJson() => {
    "partyTitle": partyTitle,
    "questName": questName,
    "priority": priority,
    "questType": questType,
    "completionStatus": completionStatus,
    "startDate": startDate,
    "dueDate": dueDate,
    "startTime": startTime,
    "endTime": endTime,
    "hashtags": hashtags,
    "expReward": expReward,
    "goldReward": goldReward,
  };

  /// ViewModel에서 쉽게 생성할 수 있도록 헬퍼 생성자
  factory PartyUpdateRequest.fromViewModel(QuestPartyCreateViewModel vm) {
    // ✅ 온보딩 여부에 따라 보상 계산
    final isOnboarding = vm.questName.toLowerCase().contains("온보딩") ||
        vm.questName.toLowerCase().contains("onboarding");

    final exp = isOnboarding ? 100 : 10;
    final gold = isOnboarding ? 50 : 5;

    return PartyUpdateRequest(
      partyTitle: vm.partyTitle,
      questName: vm.questName,
      priority: vm.priority,
      questType: vm.period ?? "DAILY",
      completionStatus: vm.completionStatus.name,
      startDate: vm.startDate!.toIso8601String().split("T").first,
      dueDate: vm.dueDate!.toIso8601String().split("T").first,
      startTime: _formatTime(vm.startTime),
      endTime: _formatTime(vm.endTime),
      hashtags: vm.categories,
      expReward: exp,
      goldReward: gold,
    );
  }

  static String _formatTime(TimeOfDay? time) {
    if (time == null) return "";
    final hour = time.hour.toString().padLeft(2, "0");
    final minute = time.minute.toString().padLeft(2, "0");
    return "$hour:$minute:00"; // 서버에서 HH:mm:ss 포맷 기대할 수 있어서 수정
  }
}
