import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:dio/dio.dart';
import 'package:it_contest_fe/core/network/dio_client.dart';
import '../../../core/fcm/fcm_token_api.dart';
import '../model/user_token_response.dart';

class AppleLoginService {
  final Dio _dio = DioClient().dio;

  Future<UserTokenResponse?> loginWithAppleAndServer() async {
    try {
      // 1. Sign in with Apple
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // 2. 사용자 이름 조합 (애플은 첫 로그인 시에만 제공)
      String? fullName;
      if (credential.givenName != null || credential.familyName != null) {
        final givenName = credential.givenName ?? '';
        final familyName = credential.familyName ?? '';
        fullName = '$familyName$givenName'.trim();
        if (fullName.isEmpty) fullName = null;
      }

      // 3. 서버에 identityToken과 이름 전달
      final requestData = {
        'identityToken': credential.identityToken,
        if (fullName != null) 'name': fullName,
      };

      final response = await _dio.post(
        '/auth/login/apple',
        data: requestData,
      );

      final tokenResponse = UserTokenResponse.fromJson(response.data);

      // 4. FCM 토큰 등록
      await FcmTokenApi(_dio).registerToken(tokenResponse.accessToken);

      return tokenResponse;
    } on DioException catch (e, stack) {
      print('❌ 애플 로그인 실패 (DioException)');
      print('🔴 Error Type: ${e.type}');
      print('🔴 Error Message: ${e.message}');
      print('🔴 Status Code: ${e.response?.statusCode}');
      print('🔴 Response Data: ${e.response?.data}');
      print('🔴 Request URL: ${e.requestOptions.uri}');
      print('🔴 Request Body: ${e.requestOptions.data}');

      // 에러 타입별 설명
      if (e.type == DioExceptionType.connectionTimeout) {
        print('⚠️ 서버 연결 시간 초과 (Connection Timeout)');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        print('⚠️ 서버 응답 시간 초과 (Receive Timeout)');
      } else if (e.type == DioExceptionType.connectionError) {
        print('⚠️ 서버 연결 실패 (Connection Error) - 서버가 꺼져있거나 네트워크 문제');
      } else if (e.type == DioExceptionType.badResponse) {
        print('⚠️ 잘못된 응답 (Bad Response) - 서버 에러');
      }

      print('🔍 StackTrace:\n$stack');
      return null;
    } catch (e, stack) {
      print('❌ 애플 로그인 실패: $e');
      print('🔍 StackTrace:\n$stack');
      return null;
    }
  }
}
