import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';

class FcmTokenApi {
  final Dio _dio;

  FcmTokenApi(this._dio);

  Future<void> registerToken(String accessToken) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await _dio.post(
          '/users/fcm-token',
          data: {'token': fcmToken},
          options: Options(headers: {
            "Authorization": "Bearer $accessToken",
          }),
        );
      }
    } catch (e) {
      // 시뮬레이터에서는 FCM 토큰을 가져올 수 없음 - 무시
      print("⚠️ FCM 토큰 등록 실패 (시뮬레이터에서는 정상): $e");
    }
  }
}
