
import 'completion_status.dart';

class PartyStatusChangeResponse {
  final int partyId;
  final String title;
  final CompletionStatus completionStatus;
  final bool isFirstCompletion;

  PartyStatusChangeResponse({
    required this.partyId,
    required this.title,
    required this.completionStatus,
    required this.isFirstCompletion,
  });

  factory PartyStatusChangeResponse.fromJson(Map<String, dynamic> json) {
    final isFirstCompletion = json['isFirstCompletion'] ?? false;
    return PartyStatusChangeResponse(
      partyId: json['partyId'],
      title: json['title'],
      completionStatus: json['completionStatus'] == 'COMPLETED'
          ? CompletionStatus.COMPLETED
          : CompletionStatus.INCOMPLETE,
      isFirstCompletion: isFirstCompletion,
    );
  }
}
