import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';

class FcmTokenApi {
  final Dio _dio;

  FcmTokenApi(this._dio);

  Future<void> registerToken(String accessToken) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      print("📌 서버에 FCM 토큰 등록: $fcmToken");
      await _dio.post(
        '/users/fcm-token',
        data: {'token': fcmToken},
        options: Options(headers: {
          "Authorization": "Bearer $accessToken",
        }),
      );
    }
  }
}
