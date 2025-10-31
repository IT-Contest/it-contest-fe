// features/auth/service/guest_login_service.dart
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import 'package:it_contest_fe/core/storage/token_storage.dart';
import '../../../core/fcm/fcm_token_api.dart';
import '../model/user_token_response.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class GuestLoginService {
  final Dio _dio;

  GuestLoginService() : _dio = DioClient().dio;

  Future<UserTokenResponse> loginAsGuest() async {
    try {
      // deviceId 생성
      String deviceId = 'unknown';
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id ?? 'unknown';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown';
      } else {
        deviceId = DateTime.now().millisecondsSinceEpoch.toString(); // fallback
      }

      final response = await _dio.post(
        '/auth/login/guest',
        data: {'deviceId': deviceId},
      );
      final tokenResponse = UserTokenResponse.fromJson(response.data);

      // 토큰 저장
      await TokenStorage().saveTokens(
        tokenResponse.accessToken,
        tokenResponse.refreshToken,
      );

      await FcmTokenApi(_dio).registerToken(tokenResponse.accessToken);

      return tokenResponse;
    } catch (e) {
      rethrow;
    }
  }
}