import 'completion_status.dart';

class QuestItemResponse {
  final int questId;            // 퀘스트 ID (개인/파티 공용)
  final int? partyId;           // 파티 ID (없으면 null)
  final String? title;          // ✅ 개인 퀘스트 전용 title
  final String? partyTitle;     // 파티명
  final String? questName;      // ✅ 파티 퀘스트 전용 questName
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

  // 파티 전용 필드
  final String? expiresAt;
  final String? invitationStatus;
  final List<dynamic>? members;

  QuestItemResponse({
    required this.questId,
    this.partyId,
    this.title,                  // ✅ 개인 전용
    this.partyTitle,
    this.questName,              // ✅ 파티 전용
    required this.expReward,
    required this.goldReward,
    required this.priority,
    required this.completionStatus,
    required this.questType,
    required this.hashtags,
    this.startDate,
    this.dueDate,
    this.startTime,
    this.endTime,
    this.expiresAt,
    this.invitationStatus,
    this.members,
  });

  QuestItemResponse copyWith({
    int? questId,
    int? partyId,
    String? title,
    String? partyTitle,
    String? questName,
    int? expReward,
    int? goldReward,
    int? priority,
    CompletionStatus? completionStatus,
    String? questType,
    List<String>? hashtags,
    String? startDate,
    String? dueDate,
    String? startTime,
    String? endTime,
    String? expiresAt,
    String? invitationStatus,
    List<dynamic>? members,
  }) {
    return QuestItemResponse(
      questId: questId ?? this.questId,
      partyId: partyId ?? this.partyId,
      title: title ?? this.title,
      partyTitle: partyTitle ?? this.partyTitle,
      questName: questName ?? this.questName,
      expReward: expReward ?? this.expReward,
      goldReward: goldReward ?? this.goldReward,
      priority: priority ?? this.priority,
      completionStatus: completionStatus ?? this.completionStatus,
      questType: questType ?? this.questType,
      hashtags: hashtags ?? this.hashtags,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      expiresAt: expiresAt ?? this.expiresAt,
      invitationStatus: invitationStatus ?? this.invitationStatus,
      members: members ?? this.members,
    );
  }

  factory QuestItemResponse.fromJson(Map<String, dynamic> json) {
    final questId = json['questId'] ?? json['partyId'] ?? 0;
    final status = json['completionStatus'] ?? json['status'] ?? 'INCOMPLETE';

    return QuestItemResponse(
      questId: questId,
      partyId: json['partyId'],
      // ✅ 개인 퀘스트: title / questTitle
      title: json['title'] ?? json['questTitle'],
      // ✅ 파티 퀘스트: questName
      questName: json['questName'],
      partyTitle: json['partyTitle'],
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
      // 파티 전용
      expiresAt: json['expiresAt'],
      invitationStatus: json['invitationStatus'],
      members: json['members'],
    );
  }

  Map<String, dynamic> toJson() => {
    'questId': questId,
    'partyId': partyId,
    'title': title,
    'partyTitle': partyTitle,
    'questName': questName, // ✅ 분리된 questName
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
    'expiresAt': expiresAt,
    'invitationStatus': invitationStatus,
    'members': members,
  };

  // CompletionStatus 안전하게 파싱
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