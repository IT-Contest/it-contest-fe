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
        print('📲 카카오톡 설치됨 → 카카오톡 로그인 시도');
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        print('🌐 카카오톡 미설치 → 카카오계정 웹 로그인 시도');
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      print('✅ 로그인 성공: accessToken = ${token.accessToken}');

      // 서버에 카카오 accessToken 전달
      final response = await _dio.post(
        '/auth/login/kakao',
        data: {'accessToken': token.accessToken},
      );
      final tokenResponse = UserTokenResponse.fromJson(response.data);

      await FcmTokenApi(_dio).registerToken(tokenResponse.accessToken);

      // ✅ 사용자 정보 요청 추가 (선택)
      final user = await UserApi.instance.me();
      print('🙋 사용자 정보: ${user.kakaoAccount?.profile?.nickname}');

      return tokenResponse;
    } catch (e, stack) {
      print('❌ 로그인 실패: $e');
      print('🔍 StackTrace:\n$stack');
      return null;
    }
  }
}