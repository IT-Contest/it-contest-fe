import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../service/mainpage_service.dart';

class InviteViewModel extends ChangeNotifier {
  String? inviteLink;

  Future<void> fetchInviteLink() async {
    inviteLink = await MainpageService().createFriendInvite();
    notifyListeners();
  }

  void copyLink(BuildContext context) {
    if (inviteLink == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('초대 링크가 아직 생성되지 않았습니다.')),
      );
      return;
    }
    Clipboard.setData(ClipboardData(text: inviteLink!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('초대 링크가 복사되었습니다!')),
    );
  }

  Future<void> shareToKakao(BuildContext context) async {
    if (inviteLink == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('초대 링크가 아직 생성되지 않았습니다.')),
      );
      return;
    }

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
