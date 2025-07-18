// lib/features/friends/service/friend_service.dart
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_storage.dart';
import '../model/friend_info.dart';

class FriendService {
  Future<List<FriendInfo>> fetchFriends() async {
    final token = await TokenStorage().getAccessToken();
    final response = await DioClient().dio.get(
      '/quests/friend-list',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final List<dynamic> result = response.data['result'];
    return result.map((e) => FriendInfo.fromJson(e)).toList();
  }
}
