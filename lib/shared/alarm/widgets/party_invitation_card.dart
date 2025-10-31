import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:it_contest_fe/features/quest/service/party_service.dart';

class PartyInvitationCard extends StatefulWidget {
  final Map<String, dynamic> partyData; // PartyListResponse 기반 데이터

  const PartyInvitationCard({super.key, required this.partyData});

  @override
  State<PartyInvitationCard> createState() => _PartyInvitationCardState();
}

class _PartyInvitationCardState extends State<PartyInvitationCard> {
  bool isProcessing = false;

  Future<void> _respondToInvitation(bool accept) async {
    final token = await const FlutterSecureStorage().read(key: "accessToken");
    if (token == null) return;

    setState(() => isProcessing = true);

    try {
      // ✅ PartyService에 respondToInvitation API 호출
      await PartyService().respondToInvitation(
        widget.partyData['partyId'],
        accept ? "ACCEPTED" : "DECLINED",
        token,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(accept ? "파티에 참여했습니다!" : "파티 초대를 거절했습니다."),
          backgroundColor: accept ? Colors.green : Colors.red,
        ),
      );

      // ✅ 초대장 닫기 or 목록 새로고침 트리거
      Navigator.of(context).maybePop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("오류 발생: $e")),
      );
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final party = widget.partyData;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        border: Border.all(
          color: Colors.grey.shade600,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 헤더
          Row(
            children: [
            Container(
            width: 28, // 테두리 포함 전체 크기
            height: 28,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF6C4EFF), // primary/600
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 19.06, // 로고 사이즈 (테두리 안쪽에 여유 있게)
                height: 12,
                fit: BoxFit.contain,
              ),
            ),
          ),
              const SizedBox(width: 8),
              const Text(
                "QuestPlanner",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              ClipOval(
                child: party['inviterProfileUrl'] != null
                    ? Image.network(
                  party['inviterProfileUrl'],
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                )
                    : const Icon(Icons.person, size: 32),
              ),
              // const SizedBox(width: 8),
              // Image.asset('assets/icons/more_btn.png', width: 20, height: 20),
            ],
          ),
          const SizedBox(height: 12),

          /// 본문
          const Text(
            "초대장이 도착했어요!",
            style: TextStyle(
              color: Color(0xFF6C63FF),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "${party['inviterNickname']}님이 초대하신 파티에 참여하시겠어요?\n",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                TextSpan(text: "파티명: ${party['partyName'] ?? ''}\n"),
                TextSpan(text: "퀘스트명: ${party['questName'] ?? ''}\n"),
              ],
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            "완료 시 ${party['expReward'] ?? 0}exp 지급",
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 12),

          /// 버튼 영역
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed:
                  isProcessing ? null : () => _respondToInvitation(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8F73FF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    "수락하기",
                    style: TextStyle(
                      color: Colors.white, // ✅ Gray/50 적용
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed:
                  isProcessing ? null : () => _respondToInvitation(false),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF8F73FF)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                      "거절하기",
                    style: TextStyle(
                      color: Color(0xFF6C4EFF), // ✅ Gray/50 적용
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
