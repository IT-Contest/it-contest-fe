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

  // 초기 데이터 로드
  Future<void> initializeData() async {
    await Future.wait([
      loadAnalysisData(),
      loadLeaderboard(),
      loadCoachingHistory(),
    ]);
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

  // 리더보드 데이터 로드 (API 미구현으로 비활성화)
  Future<void> loadLeaderboard() async {
    _isLoadingLeaderboard = true;
    notifyListeners();

    // 리더보드 API가 구현되지 않았으므로 빈 리스트로 설정
    _leaderboard = [];
    
    _isLoadingLeaderboard = false;
    notifyListeners();
  }

  // 코칭 히스토리 로드
  Future<void> loadCoachingHistory() async {
    _isLoadingCoachingHistory = true;
    notifyListeners();

    try {
      _coachingHistory = await _analysisService.fetchCoachingHistory();
    } catch (e) {
      debugPrint('Failed to load coaching history: $e');
    } finally {
      _isLoadingCoachingHistory = false;
      notifyListeners();
    }
  }

  // AI 코칭 요청
  Future<CoachingResult> requestAiCoaching() async {
    _isRequestingCoaching = true;
    notifyListeners();

    try {
      final result = await _analysisService.requestAiCoaching(
        timeframe: _selectedTimeframe,
        dataType: _selectedDataType,
      );
      
      if (result.success && result.coachingContent != null) {
        // 새로운 코칭 아이템을 히스토리 맨 앞에 추가
        final newCoachingItem = CoachingHistoryItem(
          date: DateTime.now().toIso8601String().split('T')[0].replaceAll('-', '.'),
          type: '${_selectedTimeframe.displayName} ${_selectedDataType.displayName}',
          content: result.coachingContent!,
        );
        _coachingHistory.insert(0, newCoachingItem);
        
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