class Friend {
  final int userId;
  final String nickname;
  final int level;
  final int exp;
  final int gold;
  final String profileImageUrl;

  Friend({
    required this.userId,
    required this.nickname,
    required this.level,
    required this.exp,
    required this.gold,
    required this.profileImageUrl,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      userId: json['userId'],
      nickname: json['nickname'],
      level: json['level'],
      exp: json['exp'],
      gold: json['gold'],
      profileImageUrl: json['profileImageUrl'],
    );
  }
}