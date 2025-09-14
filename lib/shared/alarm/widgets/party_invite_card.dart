import 'package:flutter/material.dart';
import 'notification_card.dart';

class PartyInviteCard extends StatelessWidget {
  const PartyInviteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return NotificationCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "파티에 참가해보세요!",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7958FF),
                  ),
                ),
              ),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundImage: AssetImage("assets/images/simpson.jpg"),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      // 버튼 클릭 동작 (TODO: 원하는 동작 연결)
                    },
                    child: Image.asset(
                      "assets/icons/more_btn.png",
                      height: 36,
                      width: 36,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "애라님이 파티에 초대했어요!\n계획을 완료하면 총 0,000exp를 받을 수 있어요!",
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          const Text(
            "초대장 만료시간 : 09분 58초",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
