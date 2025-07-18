class FriendInfo {
  final int userId;
  final String nickname;
  final int level;
  final int expPercent;
  final int totalExp;
  final int gold;
  final String profileImageUrl;

  FriendInfo({
    required this.userId,
    required this.nickname,
    required this.level,
    required this.expPercent,
    required this.totalExp,
    required this.gold,
    required this.profileImageUrl,
  });

  factory FriendInfo.fromJson(Map<String, dynamic> json) {
    final exp = json['exp'] ?? 0;
    final level = exp ~/ 5000;
    final percent = ((exp % 5000) / 5000 * 100).round().clamp(0, 100);

    return FriendInfo(
      userId: json['userId'],
      nickname: json['nickname'] ?? '',
      level: json['level'] ?? 0, // ✅ 서버에서 온 level 값 사용
      expPercent: percent,
      totalExp: exp,
      gold: json['gold'] ?? 0,
      profileImageUrl: json['profileImageUrl'] ?? '',
    );
  }
}