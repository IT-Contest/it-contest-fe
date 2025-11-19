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
    final int serverLevel = json['level'] ?? 0;
    
    // ✅ 서버에서 보낸 레벨이 있으면 우선 사용, 없으면 계산
    final levelInfo = serverLevel > 0 
        ? {'level': serverLevel, 'percent': _calculateExpPercent(exp, serverLevel)}
        : _calculateLevelAndPercent(exp);
    
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
      level: levelInfo['level'] as int,
      expPercent: levelInfo['percent'] as int,
      dailyCount: json['dailyCount'] ?? 0,
      weeklyCount: json['weeklyCount'] ?? 0,
      monthlyCount: json['monthlyCount'] ?? 0,
      yearlyCount: json['yearlyCount'] ?? 0,
      quests: questsList,
    );
  }

  // ✅ 엑셀 데이터에 따른 완전한 레벨 시스템 계산 함수
  static Map<String, int> _calculateLevelAndPercent(int currentExp) {
    // 엑셀 데이터 - 레벨별 누적 경험치 테이블 (레벨 0~100)
    final List<int> levelExpTable = [
      0, 100, 110, 140, 190, 260, 350, 460, 590, 740, 910,
      1100, 1310, 1540, 1790, 2060, 2350, 2660, 2990, 3340, 3710,
      4100, 4510, 4940, 5390, 5860, 6350, 6860, 7390, 7940, 8510,
      9100, 9710, 10340, 10990, 11660, 12350, 13060, 13790, 14540, 15310,
      16100, 16910, 17740, 18590, 19460, 20350, 21260, 22190, 23140, 24110,
      25100, 26110, 27140, 28190, 29260, 30350, 31460, 32590, 33740, 34910,
      36100, 37310, 38540, 39790, 41060, 42350, 43660, 44990, 46340, 47710,
      49100, 50510, 51940, 53390, 54860, 56350, 57860, 59390, 60940, 62510,
      64100, 65710, 67340, 68990, 70660, 72350, 74060, 75790, 77540, 79310,
      81100, 82910, 84740, 86590, 88460, 90350, 92260, 94190, 96140, 98110,
      100110 // Level 100+
    ];

    // 엑셀 데이터 - 다음 레벨까지 필요한 경험치 테이블
    final List<int> nextLevelExpTable = [
      100, 10, 30, 50, 70, 90, 110, 130, 150, 170, 190,
      210, 230, 250, 270, 290, 310, 330, 350, 370, 390,
      410, 430, 450, 470, 490, 510, 530, 550, 570, 590,
      610, 630, 650, 670, 690, 710, 730, 750, 770, 790,
      810, 830, 850, 870, 890, 910, 930, 950, 970, 990,
      1010, 1030, 1050, 1070, 1090, 1110, 1130, 1150, 1170, 1190,
      1210, 1230, 1250, 1270, 1290, 1310, 1330, 1350, 1370, 1390,
      1410, 1430, 1450, 1470, 1490, 1510, 1530, 1550, 1570, 1590,
      1610, 1630, 1650, 1670, 1690, 1710, 1730, 1750, 1770, 1790,
      1810, 1830, 1850, 1870, 1890, 1910, 1930, 1950, 1970, 1990,
      2000 // Level 100+
    ];

    int level = 0;
    
    // 현재 레벨 찾기 - 누적 경험치 기준
    for (int i = levelExpTable.length - 1; i >= 0; i--) {
      if (currentExp >= levelExpTable[i]) {
        level = i;
        break;
      }
    }

    // 최대 레벨 체크
    if (level >= 100) {
      return {'level': 100, 'percent': 100};
    }

    // 경험치 퍼센트 계산
    int percent = 0;
    if (level < nextLevelExpTable.length && level < levelExpTable.length) {
      int currentLevelExp = levelExpTable[level];
      int expInCurrentLevel = currentExp - currentLevelExp;
      int expNeededForNextLevel = nextLevelExpTable[level];
      
      if (expNeededForNextLevel > 0) {
        percent = ((expInCurrentLevel / expNeededForNextLevel) * 100).round().clamp(0, 100);
      }
    }

    return {'level': level, 'percent': percent};
  }

  // ✅ 서버에서 제공된 레벨 기준으로 경험치 퍼센트만 계산
  static int _calculateExpPercent(int currentExp, int currentLevel) {
    if (currentLevel <= 0) return 0;
    
    // 엑셀 데이터와 동일한 테이블 사용
    final List<int> nextLevelExpTable = [
      100, 10, 30, 50, 70, 90, 110, 130, 150, 170, 190,
      210, 230, 250, 270, 290, 310, 330, 350, 370, 390,
      410, 430, 450, 470, 490, 510, 530, 550, 570, 590,
      610, 630, 650, 670, 690, 710, 730, 750, 770, 790,
      810, 830, 850, 870, 890, 910, 930, 950, 970, 990,
      1010, 1030, 1050, 1070, 1090, 1110, 1130, 1150, 1170, 1190,
      1210, 1230, 1250, 1270, 1290, 1310, 1330, 1350, 1370, 1390,
      1410, 1430, 1450, 1470, 1490, 1510, 1530, 1550, 1570, 1590,
      1610, 1630, 1650, 1670, 1690, 1710, 1730, 1750, 1770, 1790,
      1810, 1830, 1850, 1870, 1890, 1910, 1930, 1950, 1970, 1990,
      2000 // Level 100+
    ];

    // 레벨별 누적 경험치 테이블
    final List<int> levelExpTable = [
      0, 100, 110, 140, 190, 260, 350, 460, 590, 740, 910,
      1100, 1310, 1540, 1790, 2060, 2350, 2660, 2990, 3340, 3710,
      4100, 4510, 4940, 5390, 5860, 6350, 6860, 7390, 7940, 8510,
      9100, 9710, 10340, 10990, 11660, 12350, 13060, 13790, 14540, 15310,
      16100, 16910, 17740, 18590, 19460, 20350, 21260, 22190, 23140, 24110,
      25100, 26110, 27140, 28190, 29260, 30350, 31460, 32590, 33740, 34910,
      36100, 37310, 38540, 39790, 41060, 42350, 43660, 44990, 46340, 47710,
      49100, 50510, 51940, 53390, 54860, 56350, 57860, 59390, 60940, 62510,
      64100, 65710, 67340, 68990, 70660, 72350, 74060, 75790, 77540, 79310,
      81100, 82910, 84740, 86590, 88460, 90350, 92260, 94190, 96140, 98110,
      100110 // Level 100+
    ];

    if (currentLevel >= nextLevelExpTable.length || currentLevel >= levelExpTable.length) {
      return 100; // 최대 레벨 도달
    }

    int currentLevelExp = currentLevel < levelExpTable.length ? levelExpTable[currentLevel] : 0;
    int expInCurrentLevel = currentExp - currentLevelExp;
    int expNeededForNextLevel = nextLevelExpTable[currentLevel];
    
    if (expNeededForNextLevel > 0) {
      return ((expInCurrentLevel / expNeededForNextLevel) * 100).round().clamp(0, 100);
    }
    
    return 0;
  }
}
