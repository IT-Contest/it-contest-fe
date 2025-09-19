import 'package:flutter/material.dart';
import 'package:it_contest_fe/features/mainpage/service/mainpage_service.dart';
import 'package:it_contest_fe/features/mainpage/model/mainpage_user_response.dart';

class PartyPushMessage extends StatefulWidget {
  final String inviterName;
  final String questTitle;
  final int expReward;
  final Duration remainingTime;

  const PartyPushMessage({
    super.key,
    required this.inviterName,
    required this.questTitle,
    required this.expReward,
    required this.remainingTime,
  });

  @override
  State<PartyPushMessage> createState() => _PartyPushMessageState();
}

class _PartyPushMessageState extends State<PartyPushMessage> {
  MainpageUserResponse? userProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final profile = await MainpageService().fetchMainUserProfile();
    if (mounted) {
      setState(() {
        userProfile = profile;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 좌측 로고
          Image.asset(
            "assets/images/logo.png",
            width: 36,
            height: 36,
          ),
          const SizedBox(width: 12),

          // 중앙 텍스트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "QuestPlanner · now",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "파티에 참가해보세요! 🚀",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${widget.inviterName}님이 파티에 참가하도록 초대했어요!\n"
                      "계획을 완료하면 ${widget.expReward} exp를 받을 수 있어요!",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "초대장 만료시간 : ${widget.remainingTime.inMinutes.toString().padLeft(2, '0')}분 "
                      "${(widget.remainingTime.inSeconds % 60).toString().padLeft(2, '0')}초",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // 우측 프로필 + 더보기 버튼
          if (!isLoading && userProfile != null)
            Column(
              children: [
                ClipOval(
                  child: Image.network(
                    userProfile!.profileImageUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/logo_3d.png', // 기본 프로필
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Image.asset(
                  "assets/icons/more_btn.png",
                  width: 20,
                  height: 20,
                )
              ],
            ),
        ],
      ),
    );
  }
}
