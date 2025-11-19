// features/mainpage/viewmodel/main_page_view_model.dart
import 'package:flutter/material.dart';
import '../../quest/model/quest_item_response.dart';
import '../model/mainpage_user_response.dart';
import '../service/mainpage_service.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

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
  //bool get shouldShowOnboardingCard => true;

  Future<void> loadMainQuests() async {
    try {
      final result = await MainpageService().fetchMainQuests();

      // 예시: result에 user와 quests 둘 다 있다고 가정
      _quests = result;
      _questCount = _quests.length;

      if (_questCount > 0 && !_isOnboardingClosed) {
        _isOnboardingClosed = true;
      }

      notifyListeners(); // 꼭 호출!
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
      print('🔄 [MainPageViewModel] 사용자 정보 로딩 시작...');
      final result = await MainpageService().fetchMainUserProfile();
      print('📊 [MainPageViewModel] 받은 사용자 정보: exp=${result.exp}, gold=${result.gold}, level=${result.level}');
      _user = result;
      notifyListeners();
      print('✅ [MainPageViewModel] 사용자 정보 업데이트 완료');
    } catch (e) {
      print('[유저 정보 불러오기 실패] $e');
    }
  }

  // ✅ 사용자 정보 새로고침 함수 (퀘스트 완료 후 호출용)
  Future<void> refreshUserInfo() async {
    await loadUserInfo();
  }

  // ✅ 전체 데이터 새로고침 함수
  Future<void> refreshAllData() async {
    await Future.wait([
      loadUserInfo(),
      loadMainQuests(),
    ]);
  }
}

class ProfilePageWidget extends StatelessWidget {
  const ProfilePageWidget({super.key});

  Future<void> _kakaoUnlink(BuildContext context) async {
    try {
      await UserApi.instance.unlink();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카카오 연결 끊기 성공!')),
      );
      // 필요하다면 로그아웃/초기화면 이동 등 추가
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카카오 연결 끊기 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... 기존 코드 ...
      body: Column(
        children: [
          // ... 기존 프로필 UI ...
          ElevatedButton(
            onPressed: () => _kakaoUnlink(context),
            child: const Text('회원 탈퇴(카카오 연결 끊기)'),
          ),
        ],
      ),
    );
  }
}
