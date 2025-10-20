import 'package:flutter/material.dart';
import 'package:it_contest_fe/core/storage/token_storage.dart';
import 'package:it_contest_fe/features/auth/service/guest_login_service.dart';
import 'package:it_contest_fe/features/auth/service/kakao_login_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  Future<UserTokenResponse?> loginWithKakao() async {
    try {
      print('카카오 로그인 API 호출');
      _isLoading = true;
      notifyListeners();

      final response = await _kakaoLoginService.loginWithKakaoAndServer();
      if (response != null) {
        print('카카오 로그인 성공: ${response.accessToken}');
        await TokenStorage().saveTokens(
          response.accessToken,
          response.refreshToken,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isNewUser', response.isNewUser);
        print('🟣 isNewUser 저장됨: ${response.isNewUser}');
      }
      return response;
    } catch (e) {
      print('카카오 로그인 실패: ${e.toString()}');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}