class MainpageUserResponse {
  final String nickname;
  final int exp;
  final int gold;
  final String profileImageUrl;
  final int level;
  final int expPercent;

  MainpageUserResponse({
    required this.nickname,
    required this.exp,
    required this.gold,
    required this.profileImageUrl,
    required this.level,
    required this.expPercent,
  });

  factory MainpageUserResponse.fromJson(Map<String, dynamic> json) {
    final int exp = json['exp'] ?? 0;
    final int level = exp ~/ 5000;
    final int percent = ((exp % 5000) / 5000 * 100).round().clamp(0, 100);

    return MainpageUserResponse(
      nickname: json['nickname'] ?? '',
      exp: exp,
      gold: json['gold'] ?? 0,
      profileImageUrl: json['profileImageUrl'] ?? '',
      level: level,
      expPercent: percent,
    );
  }
}
