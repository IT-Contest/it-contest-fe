// features/mainpage/viewmodel/main_page_view_model.dart
import 'package:flutter/material.dart';
import '../../quest/model/quest_item_response.dart';
import '../model/mainpage_user_response.dart';
import '../service/mainpage_service.dart';

class MainPageViewModel extends ChangeNotifier {
  bool _hasAlarm = false;
  bool get hasAlarm => _hasAlarm;

  void toggleAlarm() {
    _hasAlarm = !_hasAlarm;
    notifyListeners();
  }

  bool _isOnboardingClosed = false;
  bool get isOnboardingClosed => _isOnboardingClosed;

  void closeOnboardingCard() {
    _isOnboardingClosed = true;
    notifyListeners();
  }

  int _questCount = 0;
  int get questCount => _questCount;

  List<QuestItemResponse> _quests = [];
  List<QuestItemResponse> get quests => _quests;

  bool get shouldShowOnboardingCard =>
      !_isOnboardingClosed && _questCount == 0;

  Future<void> loadMainQuests() async {
    try {
      final result = await MainpageService().fetchMainQuests();
      _quests = result;
      _questCount = result.length;

      if (_questCount > 0 && !_isOnboardingClosed) {
        _isOnboardingClosed = true;
      }

      notifyListeners();
    } catch (e) {
      print('[퀘스트 불러오기 실패] $e');
    }
  }

  // ✅ 사용자 정보 저장 필드 추가
  MainpageUserResponse? _user;
  MainpageUserResponse? get user => _user;

  // ✅ 사용자 정보 불러오는 함수 추가
  Future<void> loadUserInfo() async {
    try {
      final result = await MainpageService().fetchMainUserProfile();
      _user = result;
      notifyListeners();
    } catch (e) {
      print('[유저 정보 불러오기 실패] $e');
    }
  }
}
