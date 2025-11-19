
import 'completion_status.dart';

class QuestStatusChangeResponse {
  final int questId;
  final String title;
  final CompletionStatus completionStatus;
  final bool isFirstCompletion;

  QuestStatusChangeResponse({
    required this.questId,
    required this.title,
    required this.completionStatus,
    required this.isFirstCompletion,
  });

  factory QuestStatusChangeResponse.fromJson(Map<String, dynamic> json) {
    final isFirstCompletion = json['isFirstCompletion'] ?? false;
    return QuestStatusChangeResponse(
      questId: json['questId'],
      title: json['title'],
      completionStatus: json['completionStatus'] == 'COMPLETED'
          ? CompletionStatus.COMPLETED
          : CompletionStatus.INCOMPLETE,
      isFirstCompletion: isFirstCompletion,
    );
  }
}
