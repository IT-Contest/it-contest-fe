import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;


  // 파티 퀘스트 생성
  static Future<void> logPartyQuestCreated() async {
    await _analytics.logEvent(
      name: "party_quest_created",
      parameters: {
        "source": "QuestPartyCreateScreen",
        "timestamp": DateTime.now().toIso8601String(),
      },
    );
  }

  // 파티 퀘스트 참가
  static Future<void> logPartyQuestJoinClicked() async {
    await _analytics.logEvent(
      name: "party_quest_join_button_clicked",
      parameters: {
        "source": "PartyAndFriendsSection",
        "timestamp": DateTime.now().toIso8601String(),
      },
    );
  }

  // 새 퀘스트 추가 버튼 클릭 추적
  static Future<void> logQuestAddClicked() async {
    await _analytics.logEvent(
      name: "quest_add_button_clicked",
      parameters: {
        "source": "QuestAddSection",
        "timestamp": DateTime.now().toIso8601String(),
      },
    );
  }


  // 친구 초대
  static Future<void> logFriendInvited(String method) async {
    await _analytics.logEvent(
      name: "friend_invited",
      parameters: {
        "method": method,
      },
    );
  }

  // AI 코칭 받기 버튼 클릭
  static Future<void> logAiCoachingClicked() async {
    await _analytics.logEvent(
      name: "ai_coaching_clicked",
      parameters: {
        "source": "AnalysisView",
        "timestamp": DateTime.now().toIso8601String(),
      },
    );
  }

// 코칭 기록 보기 버튼 클릭
  static Future<void> logCoachingHistoryClicked() async {
    await _analytics.logEvent(
      name: "coaching_history_clicked",
      parameters: {
        "source": "AnalysisView",
        "timestamp": DateTime.now().toIso8601String(),
      },
    );
  }

  // 분석 탭 내 '새 퀘스트 추가' 버튼 클릭
  static Future<void> logQuestAddFromAnalysis() async {
    await _analytics.logEvent(
      name: "quest_add_from_analysis_clicked",
      parameters: {
        "source": "AnalysisView",
        "timestamp": DateTime.now().toIso8601String(),
      },
    );
  }

  // 뽀모도로 사이클 완료 팝업 표시 추적
  static Future<void> logPomodoroCycleCompleted() async {
    await _analytics.logEvent(
      name: "pomodoro_cycle_completed_popup_shown",
      parameters: {
        "source": "QuestPomodoroSection",
        "timestamp": DateTime.now().toIso8601String(),
      },
    );
  }

}