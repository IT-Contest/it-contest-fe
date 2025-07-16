
// 로그인 성공 시 백엔드에서 응답받은 JSON 데이터를 Dart 객체로 변환하기 위한 모델

class UserTokenResponse {
  final String accessToken;
  final String refreshToken;
  final bool isNewUser;

  UserTokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.isNewUser,
  });

  factory UserTokenResponse.fromJson(Map<String, dynamic> json) {
    return UserTokenResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      isNewUser: json['newUser'] ?? false,
    );
  }
}