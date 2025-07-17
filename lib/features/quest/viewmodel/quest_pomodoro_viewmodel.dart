import 'dart:async';
import 'package:flutter/material.dart';

enum PomodoroMode { focus, rest }

class QuestPomodoroViewModel extends ChangeNotifier {
  PomodoroMode mode = PomodoroMode.focus;
  Duration remaining = const Duration(minutes: 30);
  Timer? _timer;
  bool isRunning = false;
  bool restButtonEnabled = false;

  void startFocus() {
    mode = PomodoroMode.focus;
    remaining = const Duration(minutes: 30);
    isRunning = true;
    restButtonEnabled = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remaining.inMinutes == 5 && remaining.inSeconds % 60 == 0) {
        stop();
        restButtonEnabled = true;
        notifyListeners();
        return;
      }
      if (remaining.inSeconds > 0) {
        remaining -= const Duration(seconds: 1);
        notifyListeners();
      } else {
        stop();
      }
    });
    notifyListeners();
  }

  void startRest() {
    mode = PomodoroMode.rest;
    remaining = const Duration(minutes: 5);
    isRunning = true;
    restButtonEnabled = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remaining.inSeconds > 0) {
        remaining -= const Duration(seconds: 1);
        notifyListeners();
      } else {
        stop();
      }
    });
    notifyListeners();
  }

  void stop() {
    isRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
} 