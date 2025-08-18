import 'dart:async';
import 'package:flutter/material.dart';

enum PomodoroMode { focus, rest }

class QuestPomodoroViewModel extends ChangeNotifier {
  PomodoroMode mode = PomodoroMode.focus;
  Timer? _timer;
  bool isRunning = false;
  bool restButtonEnabled = false;
  bool showFocusCompleteDialog = false;
  bool showCycleCompleteDialog = false;
  
  final Duration focusTotal = const Duration(minutes: 25);  // 25분
  final Duration restTotal = const Duration(minutes: 5);    // 5분
  //final Duration focusTotal = const Duration(seconds: 10);  // 테스트용 10초
  //final Duration restTotal = const Duration(seconds: 5);    // 테스트용 5초
  
  // 현재 모드에 따른 총 시간과 남은 시간
  Duration get total => mode == PomodoroMode.focus ? focusTotal : restTotal;
  Duration get remaining => _remaining;
  set remaining(Duration value) => _remaining = value;
  
  Duration _remaining;
  
  QuestPomodoroViewModel() : _remaining = const Duration(minutes: 25);

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
        // 5분 휴식 타이머 완료 시 사이클 완료 알림 표시
        stop();
        mode = PomodoroMode.focus;
        remaining = focusTotal;
        showCycleCompleteDialog = true;
        notifyListeners();
        return;
      }
    });
    notifyListeners();
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
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
} 