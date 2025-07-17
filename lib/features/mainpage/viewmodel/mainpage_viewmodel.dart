// features/mainpage/viewmodel/main_page_view_model.dart
import 'package:flutter/material.dart';

class MainPageViewModel extends ChangeNotifier {
  bool _hasAlarm = false;

  bool get hasAlarm => _hasAlarm;

  void setAlarm(bool value) {
    _hasAlarm = value;
    notifyListeners(); // View에 알림
  }

  void toggleAlarm() {
    _hasAlarm = !_hasAlarm;
    notifyListeners();
  }
}
