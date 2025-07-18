
import 'completion_status.dart';

class QuestStatusChangeResponse {
  final int questId;
  final String title;
  final CompletionStatus completionStatus;

  QuestStatusChangeResponse({
    required this.questId,
    required this.title,
    required this.completionStatus,
  });

  factory QuestStatusChangeResponse.fromJson(Map<String, dynamic> json) {
    return QuestStatusChangeResponse(
      questId: json['questId'],
      title: json['title'],
      completionStatus: json['completionStatus'] == 'COMPLETED'
          ? CompletionStatus.COMPLETED
          : CompletionStatus.INCOMPLETE,
    );
  }
}
