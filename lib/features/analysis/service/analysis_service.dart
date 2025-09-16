import 'package:dio/dio.dart';
import 'package:it_contest_fe/core/network/dio_client.dart';
import 'package:it_contest_fe/core/storage/token_storage.dart';
import '../model/analysis_models.dart';

class AnalysisService {
  
  // 분석 데이터 조회 (시간범위와 데이터 타입에 따라)
  Future<AnalysisData> fetchAnalysisData({
    required AnalysisTimeframe timeframe,
    required AnalysisDataType dataType,
  }) async {
    final token = await TokenStorage().getAccessToken();
    
    try {
      if (dataType == AnalysisDataType.quest) {
        return await _fetchQuestAnalysisData(timeframe, token);
      } else {
        return await _fetchPomodoroAnalysisData(timeframe, token);
      }
    } catch (e) {
      rethrow;
    }
  }

  // 퀘스트 분석 데이터 조회
  Future<AnalysisData> _fetchQuestAnalysisData(AnalysisTimeframe timeframe, String? token) async {
    final endpoint = '/quests/analysis/${timeframe.key}';
    final queryParams = _getDateRangeForTimeframe(timeframe);
    
    final response = await DioClient().dio.get(
      endpoint,
      queryParameters: queryParams,
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );

    final List<dynamic> resultList = response.data['result'] ?? [];
    final allQuestResponses = resultList.map((json) => QuestAnalysisResponse.fromJson(json)).toList();
    
    // 시간범위에 따른 데이터 개수 조정
    int dataCount;
    switch (timeframe) {
      case AnalysisTimeframe.daily:
        dataCount = 7; // 최근 7일
        break;
      case AnalysisTimeframe.weekly:
        dataCount = 5; // 최근 5주
        break;
      case AnalysisTimeframe.monthly:
        dataCount = 12; // 12개월
        break;
      case AnalysisTimeframe.yearly:
        dataCount = 5; // 5년 (기본값)
        break;
    }
    
    final questResponses = allQuestResponses.length > dataCount 
        ? allQuestResponses.sublist(allQuestResponses.length - dataCount) 
        : allQuestResponses;
    
    return AnalysisData.fromQuestResponse(questResponses, timeframe);
  }

  // 뽀모도로 분석 데이터 조회
  Future<AnalysisData> _fetchPomodoroAnalysisData(AnalysisTimeframe timeframe, String? token) async {
    final endpoint = '/pomodoros/analysis/${timeframe.key}';
    final queryParams = _getDateRangeForTimeframe(timeframe);
    
    try {
      final response = await DioClient().dio.get(
        endpoint,
        queryParameters: queryParams,
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );

      final List<dynamic> resultList = response.data['result'] ?? [];
      final allPomodoroResponses = resultList.map((json) => PomodoroAnalysisResponse.fromJson(json)).toList();
      
      // 시간범위에 따른 데이터 개수 조정
      int dataCount;
      switch (timeframe) {
        case AnalysisTimeframe.daily:
          dataCount = 7; // 최근 7일
          break;
        case AnalysisTimeframe.weekly:
          dataCount = 5; // 최근 5주
          break;
        case AnalysisTimeframe.monthly:
          dataCount = 12; // 12개월
          break;
        case AnalysisTimeframe.yearly:
          dataCount = 5; // 5년
          break;
      }
      
      final pomodoroResponses = allPomodoroResponses.length > dataCount 
          ? allPomodoroResponses.sublist(allPomodoroResponses.length - dataCount) 
          : allPomodoroResponses;
      
      return AnalysisData.fromPomodoroResponse(pomodoroResponses, timeframe);
    } catch (e) {
      print('❌ [AnalysisService] Pomodoro API Error: $e');
      rethrow;
    }
  }

  // 시간 범위에 따른 날짜 범위 계산
  Map<String, String> _getDateRangeForTimeframe(AnalysisTimeframe timeframe) {
    final now = DateTime.now();
    DateTime fromDate;
    DateTime toDate = now;

    switch (timeframe) {
      case AnalysisTimeframe.daily:
        fromDate = now.subtract(const Duration(days: 6)); // 7일간 (오늘 포함)
        toDate = now; // 오늘까지 확실히 포함
        break;
      case AnalysisTimeframe.weekly:
        fromDate = now.subtract(Duration(days: 28)); // 4주 전부터 현재 주까지 5주
        break;
      case AnalysisTimeframe.monthly:
        fromDate = DateTime(now.year - 1, now.month, now.day); // 12개월간
        break;
      case AnalysisTimeframe.yearly:
        fromDate = DateTime(now.year - 4, now.month, now.day); // 4년 전부터 현재 연도까지 5년
        break;
    }

    return {
      'from': fromDate.toIso8601String().split('T')[0],
      'to': toDate.toIso8601String().split('T')[0],
    };
  }

  // 리더보드 데이터 조회
  Future<List<LeaderboardUser>> fetchLeaderboard() async {
    final token = await TokenStorage().getAccessToken();
    
    try {
      final response = await DioClient().dio.get(
        '/analysis/leaderboard',
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );

      final List<dynamic> result = response.data['result'];
      return result.map((e) => LeaderboardUser.fromJson(e)).toList();
    } catch (e) {
      // 403 오류 등 권한 문제 시 빈 리스트 반환 (조용히 처리)
      return [];
    }
  }

  // AI 코칭 요청
  Future<CoachingResult> requestAiCoaching({
    required AnalysisTimeframe timeframe,
    required AnalysisDataType dataType,
  }) async {
    final token = await TokenStorage().getAccessToken();
    
    try {
      final request = CoachingRequest(
        analysisType: timeframe.key,
        questOrPomodoro: dataType.key,
      );

      final response = await DioClient().dio.post(
        '/coaching/analyze',
        data: request.toJson(),
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
          receiveTimeout: const Duration(seconds: 30), // AI 분석을 위해 30초로 확장
        ),
      );

      final coachingResponse = CoachingResponse.fromJson(response.data['result']);
      print('🔍 [AI 코칭] API 응답: ${response.data}');
      print('🔍 [AI 코칭] canAnalyze: ${coachingResponse.canAnalyze}, message: ${coachingResponse.message}');
      
      if (coachingResponse.canAnalyze && coachingResponse.coachingContent != null) {
        // 코칭 내용이 있으면 저장
        await _saveCoachingRecord(
          coachingResponse.coachingContent!,
          timeframe.key,
          dataType.key,
          token,
        );
        
        return CoachingResult.fromSuccess(coachingResponse.coachingContent!);
      } else {
        return CoachingResult.fromError(coachingResponse.message ?? '일일 분석 제한에 도달했습니다.');
      }
    } catch (e) {
      print('❌ [AnalysisService] Coaching API Error: $e');
      return CoachingResult.fromError('AI 코칭 요청 중 오류가 발생했습니다.');
    }
  }

  // 코칭 기록 저장
  Future<void> _saveCoachingRecord(String content, String analysisType, String questOrPomodoro, String? token) async {
    try {
      await DioClient().dio.post(
        '/coaching/save',
        data: {
          'coachingContent': content,
          'analysisType': analysisType,
          'questOrPomodoro': questOrPomodoro,
        },
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );
    } catch (e) {
    }
  }

  // 코칭 히스토리 조회
  Future<List<CoachingHistoryItem>> fetchCoachingHistory({int page = 0, int size = 10}) async {
    final token = await TokenStorage().getAccessToken();
    
    try {
      final response = await DioClient().dio.get(
        '/coaching/records',
        queryParameters: {
          'page': page,
          'size': size,
        },
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );

      final List<dynamic> result = response.data['result'] ?? [];
      return result.map((json) {
        return CoachingHistoryItem(
          date: json['createdAt']?.toString().split('T')[0].replaceAll('-', '.') ?? '',
          type: '${json['analysisType']} ${json['questOrPomodoro']}',
          content: json['coachingContent'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('❌ [AnalysisService] Coaching History API Error: $e');
      return [];
    }
  }

}