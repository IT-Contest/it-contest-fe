import 'dart:async';
import 'package:flutter/material.dart';
import '../service/pomodoro_service.dart';

enum PomodoroMode { focus, rest }

class QuestPomodoroViewModel extends ChangeNotifier {
  final PomodoroService _pomodoroService = PomodoroService();
  
  PomodoroMode mode = PomodoroMode.focus;
  Timer? _timer;
  bool isRunning = false;
  bool restButtonEnabled = false;
  bool showFocusCompleteDialog = false;
  bool showCycleCompleteDialog = false;
  
  // 세션 추적
  int completedSessions = 0;
  int totalSessionsToday = 0;
  
  Duration focusTotal = const Duration(minutes: 25);  // 25분
  Duration restTotal = const Duration(minutes: 5);    // 5분
  //final Duration focusTotal = const Duration(seconds: 10);  // 테스트용 10초
  //final Duration restTotal = const Duration(seconds: 5);    // 테스트용 5초
  
  // 현재 모드에 따른 총 시간과 남은 시간
  Duration get total => mode == PomodoroMode.focus ? focusTotal : restTotal;
  Duration get remaining => _remaining;
  set remaining(Duration value) => _remaining = value;
  
  Duration _remaining;
  
  QuestPomodoroViewModel() : _remaining = const Duration(minutes: 25);

  // 새로운 메서드: 집중/휴식 시간 변경
  void updateFocusTime(int minutes) {
    focusTotal = Duration(minutes: minutes);
    if (mode == PomodoroMode.focus && !isRunning) {
      remaining = focusTotal;
    }
    notifyListeners();
  }

  void updateRestTime(int minutes) {
    restTotal = Duration(minutes: minutes);
    if (mode == PomodoroMode.rest && !isRunning) {
      remaining = restTotal;
    }
    notifyListeners();
  }

  void startFocus() {
    mode = PomodoroMode.focus;
    remaining = focusTotal;
    isRunning = true;
    restButtonEnabled = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remaining.inSeconds > 0) {
        remaining -= const Duration(seconds: 1);
        notifyListeners();
      } else {
        // 25분 집중 타이머 완료 시 휴식 모드로 전환하고 알림 표시
        stop();
        mode = PomodoroMode.rest;
        remaining = restTotal;
        restButtonEnabled = true;
        showFocusCompleteDialog = true;
        notifyListeners();
        return;
      }
    });
    notifyListeners();
  }

  void startRest() {
    mode = PomodoroMode.rest;
    remaining = restTotal;
    isRunning = true;
    restButtonEnabled = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remaining.inSeconds > 0) {
        remaining -= const Duration(seconds: 1);
        notifyListeners();
      } else {
        // 5분 휴식 타이머 완료 시 사이클 완료 처리
        stop();
        _completePomodoroSession();
        mode = PomodoroMode.focus;
        remaining = focusTotal;
        showCycleCompleteDialog = true;
        notifyListeners();
        return;
      }
    });
    notifyListeners();
  }

  // 뽀모도로 세션 완료 처리
  void _completePomodoroSession() async {
    completedSessions++;
    totalSessionsToday++;
    
    // 서버에 완료 데이터 전송
    final success = await _pomodoroService.completePomodoro(
      sessionCount: 1,
      totalMinutes: focusTotal.inMinutes + restTotal.inMinutes,
    );
    
    if (success) {
      print('✅ [PomodoroViewModel] Session completed and saved to server');
    } else {
      print('❌ [PomodoroViewModel] Failed to save session to server');
    }
  }

  void stop() {
    isRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  void resetTimer() {
    isRunning = false;
    _timer?.cancel();
    mode = PomodoroMode.focus;
    remaining = focusTotal;
    restButtonEnabled = false;
    showFocusCompleteDialog = false;
    showCycleCompleteDialog = false;
    // 세션 카운터는 리셋하지 않음 (일일 누적 유지)
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
} 