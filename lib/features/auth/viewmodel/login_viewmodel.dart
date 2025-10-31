import 'package:flutter/material.dart';
import 'package:it_contest_fe/core/storage/token_storage.dart';
import 'package:it_contest_fe/features/auth/service/guest_login_service.dart';
import 'package:it_contest_fe/features/auth/service/kakao_login_service.dart';
import 'package:it_contest_fe/features/auth/service/apple_login_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_token_response.dart';

class LoginViewModel extends ChangeNotifier {
  final GuestLoginService _guestLoginService = GuestLoginService();
  final KakaoLoginService _kakaoLoginService = KakaoLoginService();
  final AppleLoginService _appleLoginService = AppleLoginService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<UserTokenResponse?> loginAsGuest() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _guestLoginService.loginAsGuest();
      return response;
    } catch (e) {
      print('게스트 로그인 실패: ${e.toString()}');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserTokenResponse?> loginWithKakao() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _kakaoLoginService.loginWithKakaoAndServer();
      if (response != null) {
        await TokenStorage().saveTokens(
          response.accessToken,
          response.refreshToken,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isNewUser', response.isNewUser);
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

  Future<UserTokenResponse?> loginWithApple() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _appleLoginService.loginWithAppleAndServer();
      if (response != null) {
        await TokenStorage().saveTokens(
          response.accessToken,
          response.refreshToken,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isNewUser', response.isNewUser);
      }
      return response;
    } catch (e) {
      print('애플 로그인 실패: ${e.toString()}');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}