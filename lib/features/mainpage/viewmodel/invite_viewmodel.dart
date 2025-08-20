import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class InviteViewModel extends ChangeNotifier {
  final String inviteCode;

  InviteViewModel({required this.inviteCode});

  String get inviteLink =>
      'https://play.google.com/store/apps/details?id=com.yourcompany.yourapp&inviterCode=$inviteCode';


  void copyLink(BuildContext context) {
    // 클립보드 복사
    Clipboard.setData(ClipboardData(text: inviteLink));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('초대 링크가 복사되었습니다!')),
    );
  }

  Future<void> shareToKakao(BuildContext context) async {
    final String message = '''
[퀘스트클럽 초대]

친구가 당신을 퀘스트클럽에 초대했어요!
함께 파티 퀘스트를 도전하고 보상을 받아보세요.

✅ 초대 링크:
$inviteLink
''';

    await Share.share(message); // ✅ 공유 실행 (카카오톡 포함 앱 목록 뜸)
  }
}
