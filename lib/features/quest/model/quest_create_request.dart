class QuestCreateRequest {
  final String content;
  final int priority;
  final String questType;
  final String completionStatus;
  final String startTime;
  final String endTime;
  final String startDate;
  final String dueDate;
  final List<String> hashtags;

  QuestCreateRequest({
    required this.content,
    required this.priority,
    required this.questType,
    required this.completionStatus,
    required this.startTime,
    required this.endTime,
    required this.startDate,
    required this.dueDate,
    required this.hashtags,
  });

  Map<String, dynamic> toJson() => {
    'content': content,
    'priority': priority,
    'questType': questType,
    'completionStatus': completionStatus,
    'startTime': startTime,
    'endTime': endTime,
    'startDate': startDate,
    'dueDate': dueDate,
    'hashtags': hashtags,
  };
}