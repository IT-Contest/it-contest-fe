import 'package:flutter/material.dart';
import '../viewmodel/quest_party_create_viewmodel.dart';

class PartyUpdateRequest {
  final String content;
  final int priority;
  final String questType; // "DAILY", "WEEKLY", "MONTHLY", "YEARLY"
  final String completionStatus; // "INCOMPLETE" or "COMPLETED"
  final String startDate; // "yyyy-MM-dd"
  final String dueDate;   // "yyyy-MM-dd"
  final String startTime; // "HH:mm"
  final String endTime;   // "HH:mm"
  final List<String> hashtags;

  PartyUpdateRequest({
    required this.content,
    required this.priority,
    required this.questType,
    required this.completionStatus,
    required this.startDate,
    required this.dueDate,
    required this.startTime,
    required this.endTime,
    required this.hashtags,
  });

  /// 직렬화 (PATCH 요청 body)
  Map<String, dynamic> toJson() => {
    "content": content,
    "priority": priority,
    "questType": questType,
    "completionStatus": completionStatus,
    "startDate": startDate,
    "dueDate": dueDate,
    "startTime": startTime,
    "endTime": endTime,
    "hashtags": hashtags,
  };

  /// ViewModel에서 쉽게 생성할 수 있도록 헬퍼 생성자
  factory PartyUpdateRequest.fromViewModel(QuestPartyCreateViewModel vm) {
    return PartyUpdateRequest(
      content: vm.content,
      priority: vm.priority,
      questType: vm.period ?? "DAILY", // ex) "DAILY"
      completionStatus: "INCOMPLETE", // ex) "INCOMPLETE"
      startDate: vm.startDate!.toIso8601String().split("T").first,
      dueDate: vm.dueDate!.toIso8601String().split("T").first,
      startTime: _formatTime(vm.startTime),
      endTime: _formatTime(vm.endTime),
      hashtags: vm.categories,
    );
  }

  static String _formatTime(TimeOfDay? time) {
    if (time == null) return "";
    final hour = time.hour.toString().padLeft(2, "0");
    final minute = time.minute.toString().padLeft(2, "0");
    return "$hour:$minute";
  }
}
