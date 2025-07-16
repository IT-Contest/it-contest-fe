import 'package:it_contest_fe/core/network/dio_client.dart';
import 'package:it_contest_fe/features/quest/model/quest_create_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:it_contest_fe/core/storage/token_storage.dart';

class QuestService {
  Future<bool> createQuest(QuestCreateRequest request) async {
    try {
      final token = await TokenStorage().getAccessToken();
      final response = await DioClient().dio.post(
        '/quests',
        data: request.toJson(),
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );
      print('[응답 상태 코드] ${response.statusCode}');
      print('[응답 바디] ${response.data}');
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e, stack) {
      print('[퀘스트 생성 실패] ${e.toString()}');
      print(stack);
      return false;
    }
  }
}