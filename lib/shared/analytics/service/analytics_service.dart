import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> logQuestCompleted(String questId, String reward) async {
    await _analytics.logEvent(
      name: "quest_completed",
      parameters: {
        "quest_id": questId,
        "reward": reward,
      },
    );
  }

  static Future<void> logFriendInvited(String method) async {
    await _analytics.logEvent(
      name: "friend_invited",
      parameters: {
        "method": method,
      },
    );
  }
}
