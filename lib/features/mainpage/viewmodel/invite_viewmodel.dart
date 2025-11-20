import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../service/mainpage_service.dart';

class InviteViewModel extends ChangeNotifier {
  String? inviteLink; // 서버에서 받은 초대 링크 (전체 URL)

  Future<void> fetchInviteLink() async {
    inviteLink = await MainpageService().createFriendInvite();
    notifyListeners();
  }

  // 초대 메시지 생성
  String get inviteMessage {
    return '''
[퀘스트플래너 초대]

친구가 당신을 퀘스트플래너에 초대했어요!
함께 파티 퀘스트를 도전하고 보상을 받아보세요.

✅ 초대 링크:
$inviteLink
''';
  }

  void copyLink(BuildContext context) {
    if (inviteLink == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('초대 링크가 아직 생성되지 않았습니다.')),
      );
      return;
    }
    Clipboard.setData(ClipboardData(text: inviteMessage));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('초대 링크가 복사되었습니다!')),
    );
  }

  Future<void> shareToKakao(BuildContext context) async {
    print('shareToKakao 호출됨');
    print('inviteLink: $inviteLink');

    if (inviteLink == null) {
      print('초대 링크가 null입니다');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('초대 링크가 아직 생성되지 않았습니다.')),
      );
      return;
    }

    try {
      print('공유 메시지: $inviteMessage');

      // iOS에서 Share 위치 지정
      final box = context.findRenderObject() as RenderBox?;
      final sharePositionOrigin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null;

      await Share.share(
        inviteMessage,
        sharePositionOrigin: sharePositionOrigin,
      );
      print('공유 성공');
    } catch (e) {
      print('공유 실패: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('공유하기 실패: $e')),
        );
      }
    }
  }
}
