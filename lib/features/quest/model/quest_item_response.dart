import 'completion_status.dart';

class QuestItemResponse {
  final int questId;
  final String title;
  final int expReward;
  final int goldReward;
  final int priority;
  final String? partyName;
  CompletionStatus completionStatus;
  final String questType;
  final List<String> hashtags;
  final String? startDate;
  final String? dueDate;
  final String? startTime;
  final String? endTime;

  QuestItemResponse({
    required this.questId,
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

  // copyWith 메서드 추가
  QuestItemResponse copyWith({
    int? questId,
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
    return QuestItemResponse(
      questId: json['questId'],
      title: json['title'],
      expReward: json['expReward'],
      goldReward: json['goldReward'],
      priority: json['priority'],
      partyName: json['partyName'],
      completionStatus: json['completionStatus'] == 'COMPLETED'
          ? CompletionStatus.COMPLETED
          : CompletionStatus.INCOMPLETE,
      questType: json['questType'],
      hashtags: (json['hashtags'] as List<dynamic>?)?.cast<String>() ?? [],
      startDate: json['startDate'],
      dueDate: json['dueDate'],
      startTime: json['startTime'],
      endTime: json['endTime'],
    );
  }

  Map<String, dynamic> toJson() => {
    'questId': questId,
    'title': title,
    'expReward': expReward,
    'goldReward': goldReward,
    'priority': priority,
    'partyName': partyName,
    'completionStatus': completionStatus.name,
    'questType': questType,
    'hashtags': hashtags,
    'startDate': startDate,
    'dueDate': dueDate,
    'startTime': startTime,
    'endTime': endTime,
  };
}
