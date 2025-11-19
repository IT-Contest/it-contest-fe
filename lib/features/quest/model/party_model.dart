class PartyCreateRequest {
  final String partyTitle;
  final String questName; // questId 대신 제목
  final int priority;
  final String questType;
  final String completionStatus;
  final String startDate; // yyyy-MM-dd
  final String dueDate;   // yyyy-MM-dd
  final String startTime; // HH:mm:ss
  final String endTime;   // HH:mm:ss
  final List<String> hashtags;

  final int expReward;   // ✅ 추가
  final int goldReward;  // ✅ 추가

  PartyCreateRequest({
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
    required this.expReward,   // ✅ 추가
    required this.goldReward,  // ✅ 추가
  });

  Map<String, dynamic> toJson() {
    return {
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
      "expReward": expReward,   // ✅ 추가
      "goldReward": goldReward, // ✅ 추가
    };
  }
}
