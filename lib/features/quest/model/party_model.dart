class PartyCreateRequest {
  final String content;
  final String questTitle; // questId 대신 제목
  final int priority;
  final String questType;
  final String completionStatus;
  final String startDate; // yyyy-MM-dd
  final String dueDate;   // yyyy-MM-dd
  final String startTime; // HH:mm:ss
  final String endTime;   // HH:mm:ss
  final List<String> hashtags;

  PartyCreateRequest({
    required this.content,
    required this.questTitle,
    required this.priority,
    required this.questType,
    required this.completionStatus,
    required this.startDate,
    required this.dueDate,
    required this.startTime,
    required this.endTime,
    required this.hashtags,
  });

  Map<String, dynamic> toJson() {
    return {
      "content": content,
      "questTitle": questTitle,
      "priority": priority,
      "questType": questType,
      "completionStatus": completionStatus,
      "startDate": startDate,
      "dueDate": dueDate,
      "startTime": startTime,
      "endTime": endTime,
      "hashtags": hashtags,
    };
  }
}