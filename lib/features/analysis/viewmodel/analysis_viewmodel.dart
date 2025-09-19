import 'package:flutter/material.dart';
import '../model/analysis_models.dart';
import '../service/analysis_service.dart';

class AnalysisViewModel extends ChangeNotifier {
  final AnalysisService _analysisService = AnalysisService();

  // 현재 선택된 시간 범위와 데이터 타입
  AnalysisTimeframe _selectedTimeframe = AnalysisTimeframe.daily;
  AnalysisDataType _selectedDataType = AnalysisDataType.quest;

  // 데이터 상태
  AnalysisData? _analysisData;
  List<LeaderboardUser> _leaderboard = [];
  List<CoachingHistoryItem> _coachingHistory = [];
  bool _showCoachingHistory = false;
  
  // 로딩 상태
  bool _isLoadingAnalysis = false;
  bool _isLoadingLeaderboard = false;
  bool _isLoadingCoachingHistory = false;
  bool _isRequestingCoaching = false;
  String? _lastCoachingDate;

  // Getters
  AnalysisTimeframe get selectedTimeframe => _selectedTimeframe;
  AnalysisDataType get selectedDataType => _selectedDataType;
  AnalysisData? get analysisData => _analysisData;
  List<LeaderboardUser> get leaderboard => _leaderboard;
  List<CoachingHistoryItem> get coachingHistory => _coachingHistory;
  bool get showCoachingHistory => _showCoachingHistory;
  bool get isLoadingAnalysis => _isLoadingAnalysis;
  bool get isLoadingLeaderboard => _isLoadingLeaderboard;
  bool get isLoadingCoachingHistory => _isLoadingCoachingHistory;
  bool get isRequestingCoaching => _isRequestingCoaching;

  // 편의용 getters
  String get currentDateStamp => _analysisData?.currentDateStamp ?? '';
  List<double> get chartData => _analysisData?.chartData ?? [];
  List<String> get chartLabels => _analysisData?.chartLabels ?? [];
  int get completedQuests => _analysisData?.completedQuests ?? 0;
  int get completedPomodoros => _analysisData?.completedPomodoros ?? 0;

  // 오늘 AI 코칭 사용 가능 여부 확인
  bool get canRequestCoachingToday {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return _lastCoachingDate != today;
  }

  // 초기 데이터 로드
  Future<void> initializeData() async {
    await loadAnalysisData();
    await loadLeaderboard();
    await loadCoachingHistory();
  }

  // 시간 범위 선택
  Future<void> selectTimeframe(AnalysisTimeframe timeframe) async {
    if (_selectedTimeframe == timeframe) return;
    
    _selectedTimeframe = timeframe;
    notifyListeners();
    
    await loadAnalysisData();
  }

  // 데이터 타입 선택
  Future<void> selectDataType(AnalysisDataType dataType) async {
    if (_selectedDataType == dataType) return;
    
    _selectedDataType = dataType;
    notifyListeners();
    
    await loadAnalysisData();
  }

  // 분석 데이터 로드
  Future<void> loadAnalysisData() async {
    
    _isLoadingAnalysis = true;
    notifyListeners();

    try {
      _analysisData = await _analysisService.fetchAnalysisData(
        timeframe: _selectedTimeframe,
        dataType: _selectedDataType,
      );
    } finally {
      _isLoadingAnalysis = false;
      notifyListeners();
    }
  }

  // 리더보드 데이터 로드 (API 미구현으로 더미 데이터 사용)
  Future<void> loadLeaderboard() async {
    _isLoadingLeaderboard = true;
    notifyListeners();

    // 더미 데이터로 친구 카드 UI 구성
    _leaderboard = [
      LeaderboardUser(
        rank: 1,
        name: '애라',
        exp: 4500,
        avatarUrl: 'https://example.com/avatar1.png',
      ),
      LeaderboardUser(
        rank: 2,
        name: '애라',
        exp: 4500,
        avatarUrl: 'https://example.com/avatar2.png',
      ),
      LeaderboardUser(
        rank: 3,
        name: '애라',
        exp: 4500,
        avatarUrl: 'https://example.com/avatar3.png',
      ),
      LeaderboardUser(
        rank: 4,
        name: '민지',
        exp: 3200,
        avatarUrl: 'https://example.com/avatar4.png',
      ),
      LeaderboardUser(
        rank: 5,
        name: '준호',
        exp: 2800,
        avatarUrl: 'https://example.com/avatar5.png',
      ),
    ];
    
    _isLoadingLeaderboard = false;
    notifyListeners();
  }

  // 코칭 히스토리 로드
  Future<void> loadCoachingHistory() async {
    // 이미 로딩 중이면 중복 요청 방지
    if (_isLoadingCoachingHistory) return;
    
    _isLoadingCoachingHistory = true;
    notifyListeners();

    try {
      final fetchedHistory = await _analysisService.fetchCoachingHistory();
      
      // 중복 제거: 날짜와 내용이 같은 아이템 제거
      final uniqueHistory = <CoachingHistoryItem>[];
      final seenKeys = <String>{};
      
      for (final item in fetchedHistory) {
        final key = '${item.date}_${item.type}_${item.content.hashCode}';
        if (!seenKeys.contains(key)) {
          seenKeys.add(key);
          uniqueHistory.add(item);
        }
      }
      
      _coachingHistory = uniqueHistory;
      
      // 오늘 이미 코칭을 받았는지 확인
      final today = DateTime.now().toIso8601String().split('T')[0];
      final todayFormatted = today.replaceAll('-', '.');
      
      final hasCoachingToday = _coachingHistory.any((item) => item.date == todayFormatted);
      if (hasCoachingToday) {
        _lastCoachingDate = today;
      }
    } catch (e) {
      debugPrint('Failed to load coaching history: $e');
    } finally {
      _isLoadingCoachingHistory = false;
      notifyListeners();
    }
  }

  // AI 코칭 요청
  Future<CoachingResult> requestAiCoaching() async {
    // 오늘 이미 사용했는지 확인
    if (!canRequestCoachingToday) {
      return CoachingResult.fromError('daily_limit_reached');
    }

    _isRequestingCoaching = true;
    notifyListeners();

    try {
      final result = await _analysisService.requestAiCoaching(
        timeframe: _selectedTimeframe,
        dataType: _selectedDataType,
      );
      
      if (result.success && result.coachingContent != null) {
        // 오늘 날짜를 저장하여 일일 사용 제한 적용
        _lastCoachingDate = DateTime.now().toIso8601String().split('T')[0];
        
        // 서버에서 최신 코칭 히스토리를 다시 로드 (중복 방지)
        await loadCoachingHistory();
        
        // 코칭 히스토리 보기 상태로 변경
        _showCoachingHistory = true;
      }
      
      return result;
    } catch (e) {
      debugPrint('Failed to request AI coaching: $e');
      return CoachingResult.fromError('AI 코칭 요청 중 오류가 발생했습니다.');
    } finally {
      _isRequestingCoaching = false;
      notifyListeners();
    }
  }

  // 코칭 히스토리 표시/숨기기 토글
  void toggleCoachingHistory() {
    _showCoachingHistory = !_showCoachingHistory;
    notifyListeners();
  }

  // 코칭 히스토리 아이템 확장/축소 토글
  void toggleCoachingItemExpansion(int index) {
    if (index < 0 || index >= _coachingHistory.length) return;
    
    final item = _coachingHistory[index];
    _coachingHistory[index] = item.copyWith(isExpanded: !item.isExpanded);
    notifyListeners();
  }

  // 데이터 새로고침
  Future<void> refreshData() async {
    await initializeData();
  }
}