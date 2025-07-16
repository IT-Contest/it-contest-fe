import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';

class KakaoLoginService {
  Future<String> loginWithKakao() async {
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

      // ✅ 사용자 정보 요청 추가!
      final user = await UserApi.instance.me();
      print('🙋 사용자 정보: ${user.kakaoAccount?.profile?.nickname}');

      return token.accessToken;
    } catch (e, stack) {
      print('❌ 로그인 실패: $e');
      print('🔍 StackTrace:\n$stack');
      rethrow;
    }
  }
}