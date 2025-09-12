import 'package:it_contest_fe/core/network/dio_client.dart';
import 'package:it_contest_fe/features/quest/model/quest_create_request.dart';
import 'package:dio/dio.dart';
import 'package:it_contest_fe/core/storage/token_storage.dart';
import '../model/completion_status.dart';
import '../model/quest_item_response.dart';
import '../model/quest_status_change_response.dart';

class QuestService {

  // 퀘스트 생성하기
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
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e, stack) {
      print('[퀘스트 생성 실패] ${e.toString()}');
      print(stack);
      return false;
    }
  }

  // 퀘스트 리스트 불러오기
  Future<List<QuestItemResponse>> fetchQuestList() async {
    try {
      final token = await TokenStorage().getAccessToken();
      final response = await DioClient().dio.get(
        '/quests/quest-list',
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );

      final List<dynamic> result = response.data['result'];
      return result.map((e) => QuestItemResponse.fromJson(e)).toList();
    } catch (e, stack) {
      print('[퀘스트 조회 실패] ${e.toString()}');
      print(stack);
      rethrow; // ViewModel에서 catch 하도록 위임
    }
  }

  // 퀘스트 완료 상태 관리
  Future<List<QuestStatusChangeResponse>> changeQuestStatus(List<int> questIds, String completionStatus) async {
    try {
      final token = await TokenStorage().getAccessToken();
      final response = await DioClient().dio.patch(
        '/quests/change',
        data: {
          'questIds': questIds,
          'completionStatus': completionStatus, // "COMPLETED" or "INCOMPLETE"
        },
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );
      final List<dynamic> result = response.data['result'];
      return result.map((e) => QuestStatusChangeResponse.fromJson(e)).toList();
    } catch (e, stack) {
      print('[퀘스트 상태 변경 실패] ${e.toString()}');
      print(stack);
      rethrow;
    }
  }

  Future<QuestStatusChangeResponse> updateQuestStatus(int questId, CompletionStatus newStatus) async {
    try {
      final updatedList = await changeQuestStatus(
        [questId],
        newStatus == CompletionStatus.COMPLETED ? 'COMPLETED' : 'INCOMPLETE',
      );
      return updatedList.first;
    } catch (e) {
      rethrow;
    }
  }

  // 퀘스트 수정 API
  Future<bool> updateQuest(int questId, Map<String, dynamic> updateData) async {
    try {
      final token = await TokenStorage().getAccessToken();
      final response = await DioClient().dio.put(
        '/quests/$questId',
        data: updateData,
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );
      print('[퀘스트 수정 응답] ${response.statusCode}: ${response.data}');
      return response.statusCode == 200;
    } catch (e, stack) {
      print('[퀘스트 수정 실패] ${e.toString()}');
      print(stack);
      return false;
    }
  }

  // 퀘스트 삭제 API
  Future<bool> deleteQuest(int questId) async {
    try {
      final token = await TokenStorage().getAccessToken();
      final response = await DioClient().dio.delete(
        '/quests/$questId',
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );
      print('[퀘스트 삭제 응답] ${response.statusCode}: ${response.data}');
      return response.statusCode == 200;
    } catch (e, stack) {
      print('[퀘스트 삭제 실패] ${e.toString()}');
      print(stack);
      return false;
    }
  }
}