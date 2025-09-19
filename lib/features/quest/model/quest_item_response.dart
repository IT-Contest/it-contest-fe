import 'completion_status.dart';

class QuestItemResponse {
  final int questId; // 퀘스트 ID (개인/파티 공용)
  final int? partyId; // 파티 ID (없으면 null)
  final String title; // ✅ 퀘스트명
  final String? partyName; // ✅ 파티명
  final int expReward;
  final int goldReward;
  final int priority;
  CompletionStatus completionStatus;
  final String questType;
  final List<String> hashtags;
  final String? startDate;
  final String? dueDate;
  final String? startTime;
  final String? endTime;

  QuestItemResponse({
    required this.questId,
    this.partyId,
    required this.title,
    required this.expReward,
    required this.goldReward,
    required this.priority,
    this.partyName,
    required this.completionStatus,
    required this.questType,
    required this.hashtags,
    this.startDate,
    this.dueDate,
    this.startTime,
    this.endTime,
  });

  QuestItemResponse copyWith({
    int? questId,
    int? partyId,
    String? title,
    int? expReward,
    int? goldReward,
    int? priority,
    String? partyName,
    CompletionStatus? completionStatus,
    String? questType,
    List<String>? hashtags,
    String? startDate,
    String? dueDate,
    String? startTime,
    String? endTime,
  }) {
    return QuestItemResponse(
      questId: questId ?? this.questId,
      partyId: partyId ?? this.partyId,
      title: title ?? this.title,
      expReward: expReward ?? this.expReward,
      goldReward: goldReward ?? this.goldReward,
      priority: priority ?? this.priority,
      partyName: partyName ?? this.partyName,
      completionStatus: completionStatus ?? this.completionStatus,
      questType: questType ?? this.questType,
      hashtags: hashtags ?? this.hashtags,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  factory QuestItemResponse.fromJson(Map<String, dynamic> json) {
    final questId = json['questId'] ?? json['partyId'] ?? 0;
    final status = json['completionStatus'] ?? json['status'] ?? 'INCOMPLETE';

    return QuestItemResponse(
      questId: questId,
      partyId: json['partyId'],
      title: json['questTitle'] ?? json['title'] ?? '', // ✅ questTitle → 퀘스트명
      partyName: json['title'], // ✅ 파티명(title)을 별도로 저장
      expReward: json['expReward'] ?? 0,
      goldReward: json['goldReward'] ?? 0,
      priority: json['priority'] ?? 1,
      completionStatus: _parseCompletionStatus(status),
      questType: json['questType'] ?? 'DAILY',
      hashtags: (json['hashtags'] as List<dynamic>?)?.cast<String>() ?? [],
      startDate: json['startDate'],
      dueDate: json['dueDate'],
      startTime: json['startTime'],
      endTime: json['endTime'],
    );
  }

  Map<String, dynamic> toJson() => {
    'questId': questId,
    'partyId': partyId,
    'title': title,
    'partyName': partyName,
    'expReward': expReward,
    'goldReward': goldReward,
    'priority': priority,
    'completionStatus': completionStatus.name,
    'questType': questType,
    'hashtags': hashtags,
    'startDate': startDate,
    'dueDate': dueDate,
    'startTime': startTime,
    'endTime': endTime,
  };

  //CompletionStatus 안전하게 파싱
  static CompletionStatus _parseCompletionStatus(String? value) {
    switch (value) {
      case 'COMPLETED':
        return CompletionStatus.COMPLETED;
      case 'IN_PROGRESS':
        return CompletionStatus.IN_PROGRESS;
      case 'INCOMPLETE':
      default:
        return CompletionStatus.INCOMPLETE;
    }
  }
}