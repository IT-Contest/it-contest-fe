import 'package:flutter/material.dart';
import 'package:it_contest_fe/core/storage/token_storage.dart';
import 'package:it_contest_fe/features/auth/service/guest_login_service.dart';
import 'package:it_contest_fe/features/auth/service/kakao_login_service.dart';
import '../model/user_token_response.dart';

class LoginViewModel extends ChangeNotifier {
  final GuestLoginService _guestLoginService = GuestLoginService();
  final KakaoLoginService _kakaoLoginService = KakaoLoginService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<UserTokenResponse?> loginAsGuest() async {
    try {
      print('게스트 로그인 API 호출');
      _isLoading = true;
      notifyListeners();

      final response = await _guestLoginService.loginAsGuest();
      print('게스트 로그인 성공: ${response.accessToken}');
      return response;
    } catch (e) {
      print('게스트 로그인 실패: ${e.toString()}');
      debugPrint('Login failed: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> loginWithKakao() async {
    try {
      print('카카오 로그인 API 호출');
      final accessToken = await _kakaoLoginService.loginWithKakao();
      print('카카오 로그인 성공: $accessToken');
      // TODO: 서버에 accessToken 전달 및 토큰 저장 로직 추가
      return accessToken;
    } catch (e) {
      print('카카오 로그인 실패: ${e.toString()}');
      return null;
    }
  }
}