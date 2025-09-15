import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class InviteViewModel extends ChangeNotifier {
  final String inviteCode;

  InviteViewModel({required this.inviteCode});

  // 도메인 기반 링크로 변경
  String get inviteLink =>
      'http://192.168.45.148:8080/invite.html?code=$inviteCode';

  void copyLink(BuildContext context) {
    Clipboard.setData(ClipboardData(text: inviteLink));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('초대 링크가 복사되었습니다!')),
    );
  }

  Future<void> shareToKakao(BuildContext context) async {
    final String message = '''
[퀘스트플래너 초대]

친구가 당신을 퀘스트클럽에 초대했어요!
함께 파티 퀘스트를 도전하고 보상을 받아보세요.

✅ 초대 링크:
$inviteLink
''';

    await Share.share(message);
  }
}
