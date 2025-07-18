import 'package:flutter/material.dart';
import '../model/friend_info.dart';
import '../service/friend_service.dart';

class FriendViewModel extends ChangeNotifier {
  final FriendService _friendService = FriendService(); // ✅ 서비스 주입

  List<FriendInfo> _friends = [];

  List<FriendInfo> get friends => _friends;

  Future<void> fetchFriends() async {
    try {
      _friends = await _friendService.fetchFriends(); // ✅ API 호출은 서비스에 위임
      notifyListeners();
    } catch (e) {
      print('친구 목록 불러오기 실패: $e');
    }
  }
}