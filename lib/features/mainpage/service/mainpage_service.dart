import 'package:dio/dio.dart';
import 'package:it_contest_fe/core/network/dio_client.dart';
import 'package:it_contest_fe/core/storage/token_storage.dart';
import '../../quest/model/quest_item_response.dart';
import '../model/mainpage_user_response.dart';

class MainpageService {
  Future<List<QuestItemResponse>> fetchMainQuests() async {
    final token = await TokenStorage().getAccessToken();
    final response = await DioClient().dio.get(
      '/quests/quest-list',  // 원래 엔드포인트로 복원
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );

    final List<dynamic> result = response.data['result'];
    return result.map((e) => QuestItemResponse.fromJson(e)).toList();
  }

  Future<MainpageUserResponse> fetchMainUserProfile() async {
    final token = await TokenStorage().getAccessToken();
    final response = await DioClient().dio.get(
      '/quests/mainpage',
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );

    final result = response.data['result'];
    return MainpageUserResponse.fromJson(result);
  }
}
