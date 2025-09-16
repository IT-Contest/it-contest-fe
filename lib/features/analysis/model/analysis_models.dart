// 분석 관련 모델들
class LeaderboardUser {
  final int rank;
  final String name;
  final int exp;
  final String avatarUrl;

  LeaderboardUser({
    required this.rank,
    required this.name,
    required this.exp,
    required this.avatarUrl,
  });

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      rank: json['rank'] ?? 0,
      name: json['name'] ?? '',
      exp: json['exp'] ?? 0,
      avatarUrl: json['avatarUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'name': name,
      'exp': exp,
      'avatarUrl': avatarUrl,
    };
  }
}

class CoachingHistoryItem {
  final String date;
  final String type;
  final String content;
  final bool isExpanded;

  CoachingHistoryItem({
    required this.date,
    required this.type,
    required this.content,
    this.isExpanded = false,
  });

  factory CoachingHistoryItem.fromJson(Map<String, dynamic> json) {
    return CoachingHistoryItem(
      date: json['date'] ?? '',
      type: json['type'] ?? '',
      content: json['content'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'type': type,
      'content': content,
    };
  }

  CoachingHistoryItem copyWith({
    String? date,
    String? type,
    String? content,
    bool? isExpanded,
  }) {
    return CoachingHistoryItem(
      date: date ?? this.date,
      type: type ?? this.type,
      content: content ?? this.content,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

// API 응답을 위한 기본 모델들
class QuestAnalysisResponse {
  final String date;
  final int completedCount;
  final int totalCount;

  QuestAnalysisResponse({
    required this.date,
    required this.completedCount,
    required this.totalCount,
  });

  factory QuestAnalysisResponse.fromJson(Map<String, dynamic> json) {
    // API 응답 구조에 따라 다르게 파싱
    String dateValue = '';
    int completed = 0;
    int total = 0;
    
    if (json.containsKey('week')) {
      // 주간 데이터 형식: {week: "2025-W36", completed: 0, total: 0}
      dateValue = json['week'] ?? '';
      completed = json['completed'] ?? 0;
      total = json['total'] ?? 0;
    } else if (json.containsKey('date')) {
      // 일일 데이터 형식: {date: "2025-01-01", completed: 0, total: 0}
      dateValue = json['date'] ?? '';
      completed = json['completed'] ?? 0;
      total = json['total'] ?? 0;
    } else if (json.containsKey('month')) {
      // 월간 데이터 형식: {month: "2025-01", completed: 0, total: 0}
      dateValue = json['month'] ?? '';
      completed = json['completed'] ?? 0;
      total = json['total'] ?? 0;
    } else if (json.containsKey('year')) {
      // 연간 데이터 형식: {year: "2025", completed: 0, total: 0}
      dateValue = json['year'] ?? '';
      completed = json['completed'] ?? 0;
      total = json['total'] ?? 0;
    }
    
    return QuestAnalysisResponse(
      date: dateValue,
      completedCount: completed,
      totalCount: total,
    );
  }
}

class PomodoroAnalysisResponse {
  final String date;
  final int completedSessions;
  final int totalSessions;

  PomodoroAnalysisResponse({
    required this.date,
    required this.completedSessions,
    required this.totalSessions,
  });

  factory PomodoroAnalysisResponse.fromJson(Map<String, dynamic> json) {
    // API 응답 구조에 따라 다르게 파싱
    String dateValue = '';
    int completed = 0;
    int total = 0;
    
    if (json.containsKey('week')) {
      // 주간 데이터 형식: {week: "2025-W36", completed: 0, total: 0}
      dateValue = json['week'] ?? '';
      completed = json['completed'] ?? 0;
      total = json['total'] ?? 0;
    } else if (json.containsKey('date')) {
      // 일일 데이터 형식
      dateValue = json['date'] ?? '';
      completed = json['completedSessions'] ?? 0;
      total = json['totalSessions'] ?? 0;
    } else if (json.containsKey('month')) {
      // 월간 데이터 형식
      dateValue = json['month'] ?? '';
      completed = json['completed'] ?? 0;
      total = json['total'] ?? 0;
    } else if (json.containsKey('year')) {
      // 연간 데이터 형식
      dateValue = json['year'] ?? '';
      completed = json['completed'] ?? 0;
      total = json['total'] ?? 0;
    }
    
    return PomodoroAnalysisResponse(
      date: dateValue,
      completedSessions: completed,
      totalSessions: total,
    );
  }
}

class CoachingRequest {
  final String analysisType; // "daily", "weekly", "monthly", "yearly"
  final String questOrPomodoro; // "quest", "pomodoro"

  CoachingRequest({
    required this.analysisType,
    required this.questOrPomodoro,
  });

  Map<String, dynamic> toJson() {
    return {
      'analysisType': analysisType,
      'questOrPomodoro': questOrPomodoro,
    };
  }
}

class CoachingResponse {
  final bool canAnalyze;
  final String? coachingContent;
  final String? message;

  CoachingResponse({
    required this.canAnalyze,
    this.coachingContent,
    this.message,
  });

  factory CoachingResponse.fromJson(Map<String, dynamic> json) {
    return CoachingResponse(
      canAnalyze: json['canAnalyze'] ?? false,
      coachingContent: json['coachingContent'],
      message: json['message'],
    );
  }
}

class CoachingResult {
  final bool success;
  final String? coachingContent;
  final String? errorMessage;

  CoachingResult({
    required this.success,
    this.coachingContent,
    this.errorMessage,
  });

  static CoachingResult fromSuccess(String content) {
    return CoachingResult(
      success: true,
      coachingContent: content,
    );
  }

  static CoachingResult fromError(String message) {
    return CoachingResult(
      success: false,
      errorMessage: message,
    );
  }
}

class AnalysisData {
  final List<double> chartData;
  final List<String> chartLabels;
  final int completedQuests;
  final int completedPomodoros;
  final String currentDateStamp;

  AnalysisData({
    required this.chartData,
    required this.chartLabels,
    required this.completedQuests,
    required this.completedPomodoros,
    required this.currentDateStamp,
  });

  factory AnalysisData.fromQuestResponse(List<QuestAnalysisResponse> responses, AnalysisTimeframe timeframe) {
    final chartData = responses.map((r) => r.completedCount.toDouble()).toList();
    final chartLabels = responses.map((r) => _formatDateLabelByTimeframe(r.date, timeframe)).toList();
    final totalCompleted = responses.fold(0, (sum, r) => sum + r.completedCount);
    
    return AnalysisData(
      chartData: chartData,
      chartLabels: chartLabels,
      completedQuests: totalCompleted,
      completedPomodoros: 0,
      currentDateStamp: _formatCurrentDate(),
    );
  }

  factory AnalysisData.fromPomodoroResponse(List<PomodoroAnalysisResponse> responses, AnalysisTimeframe timeframe) {
    final chartData = responses.map((r) => r.completedSessions.toDouble()).toList();
    final chartLabels = responses.map((r) => _formatDateLabelByTimeframe(r.date, timeframe)).toList();
    final totalCompleted = responses.fold(0, (sum, r) => sum + r.completedSessions);
    
    return AnalysisData(
      chartData: chartData,
      chartLabels: chartLabels,
      completedQuests: 0,
      completedPomodoros: totalCompleted,
      currentDateStamp: _formatCurrentDate(),
    );
  }

  static String _formatCurrentDate() {
    final now = DateTime.now();
    return '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';
  }

  static String _formatDateLabelByTimeframe(String dateStr, AnalysisTimeframe timeframe) {
    try {
      switch (timeframe) {
        case AnalysisTimeframe.daily:
          final date = DateTime.parse(dateStr);
          return '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        case AnalysisTimeframe.weekly:
          // "2025-W36" 형식을 "9월 1주차" 형식으로 변환
          if (dateStr.contains('-W')) {
            final parts = dateStr.split('-W');
            final year = int.parse(parts[0]);
            final weekNum = int.parse(parts[1]);
            
            // ISO 주차에서 해당 주의 첫날(월요일) 계산
            final jan4 = DateTime(year, 1, 4);
            final firstMondayOfYear = jan4.subtract(Duration(days: jan4.weekday - 1));
            final targetMonday = firstMondayOfYear.add(Duration(days: (weekNum - 1) * 7));
            
            // 해당 주가 속한 월
            final month = targetMonday.month;
            
            // 해당 월의 첫 번째 주 찾기 (월의 1일이 포함된 주)
            final firstDayOfMonth = DateTime(targetMonday.year, month, 1);
            final firstMondayOfMonth = firstDayOfMonth.weekday == 1 
                ? firstDayOfMonth
                : firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday - 1));
            
            // 해당 월에서 몇 번째 주인지 계산
            final daysDiff = targetMonday.difference(firstMondayOfMonth).inDays;
            final weekOfMonth = (daysDiff / 7).floor() + 1;
            
            return '$month월 ${weekOfMonth}주차';
          }
          return dateStr;
        case AnalysisTimeframe.monthly:
          // "2025-01" 형식을 "1월"로 변환
          if (dateStr.contains('-') && dateStr.length >= 7) {
            final parts = dateStr.split('-');
            final month = int.parse(parts[1]); // "01" -> 1
            return '$month월';
          }
          return dateStr;
        case AnalysisTimeframe.yearly:
          return dateStr; // "2025" 그대로 사용
      }
    } catch (e) {
      return dateStr;
    }
  }

  static String _formatDateLabel(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  // 주어진 날짜의 연도 기준 주차 번호를 계산하는 헬퍼 함수
  static int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceStart = date.difference(firstDayOfYear).inDays;
    return (daysSinceStart / 7).floor() + 1;
  }
}

enum AnalysisTimeframe {
  daily,
  weekly,
  monthly,
  yearly,
}

enum AnalysisDataType {
  quest,
  pomodoro,
}

extension AnalysisTimeframeExtension on AnalysisTimeframe {
  String get displayName {
    switch (this) {
      case AnalysisTimeframe.daily:
        return '일일';
      case AnalysisTimeframe.weekly:
        return '주간';
      case AnalysisTimeframe.monthly:
        return '월간';
      case AnalysisTimeframe.yearly:
        return '연간';
    }
  }

  String get key {
    switch (this) {
      case AnalysisTimeframe.daily:
        return 'daily';
      case AnalysisTimeframe.weekly:
        return 'weekly';
      case AnalysisTimeframe.monthly:
        return 'monthly';
      case AnalysisTimeframe.yearly:
        return 'yearly';
    }
  }
}

extension AnalysisDataTypeExtension on AnalysisDataType {
  String get displayName {
    switch (this) {
      case AnalysisDataType.quest:
        return '퀘스트';
      case AnalysisDataType.pomodoro:
        return '뽀모도로';
    }
  }

  String get key {
    switch (this) {
      case AnalysisDataType.quest:
        return 'quest';
      case AnalysisDataType.pomodoro:
        return 'pomodoro';
    }
  }
}