import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:dio/dio.dart';
import 'package:it_contest_fe/core/network/dio_client.dart';
import '../../../core/fcm/fcm_token_api.dart';
import '../model/user_token_response.dart';

class KakaoLoginService {
  final Dio _dio = DioClient().dio;

  Future<UserTokenResponse?> loginWithKakaoAndServer() async {
    try {
      OAuthToken token;

      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      // 서버에 카카오 accessToken 전달
      final response = await _dio.post(
        '/auth/login/kakao',
        data: {'accessToken': token.accessToken},
      );
      final tokenResponse = UserTokenResponse.fromJson(response.data);

      await FcmTokenApi(_dio).registerToken(tokenResponse.accessToken);

      return tokenResponse;
    } catch (e, stack) {
      print('❌ 카카오 로그인 실패: $e');
      return null;
    }
  }
}