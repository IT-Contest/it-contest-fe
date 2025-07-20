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

  QuestItemResponse({
    required this.questId,
    required this.title,
    required this.expReward,
    required this.goldReward,
    required this.priority,
    this.partyName,
    required this.completionStatus,
    required this.questType, 
  });

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
  };
}
