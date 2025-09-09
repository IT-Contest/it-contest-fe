import '../../../features/quest/model/quest_item_response.dart';

class MainpageUserResponse {
  final String nickname;
  final int exp;
  final int gold;
  final String profileImageUrl;
  final int level;
  final int expPercent;

  // ✅ 퀘스트 카운트 추가
  final int dailyCount;
  final int weeklyCount;
  final int monthlyCount;
  final int yearlyCount;
  
  // ✅ 퀘스트 목록 추가
  final List<QuestItemResponse> quests;

  MainpageUserResponse({
    required this.nickname,
    required this.exp,
    required this.gold,
    required this.profileImageUrl,
    required this.level,
    required this.expPercent,
    required this.dailyCount,
    required this.weeklyCount,
    required this.monthlyCount,
    required this.yearlyCount,
    required this.quests,
  });

  factory MainpageUserResponse.fromJson(Map<String, dynamic> json) {
    final int exp = json['exp'] ?? 0;
    final int level = exp ~/ 5000;
    // ✅ 총 경험치 기준을 50000으로 잡고 비율 계산
    final int percent = (exp / 50000 * 100).round().clamp(0, 100);

    // ✅ 퀘스트 목록 파싱
    final List<dynamic> questsJson = json['quests'] ?? [];
    final List<QuestItemResponse> questsList = questsJson
        .map((questJson) => QuestItemResponse.fromJson(questJson))
        .toList();

    return MainpageUserResponse(
      nickname: json['nickname'] ?? '',
      exp: exp,
      gold: json['gold'] ?? 0,
      profileImageUrl: json['profileImageUrl'] ?? '',
      level: level,
      expPercent: percent,
      dailyCount: json['dailyCount'] ?? 0,
      weeklyCount: json['weeklyCount'] ?? 0,
      monthlyCount: json['monthlyCount'] ?? 0,
      yearlyCount: json['yearlyCount'] ?? 0,
      quests: questsList,
    );
  }
}
