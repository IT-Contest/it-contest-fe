import 'package:it_contest_fe/core/network/dio_client.dart';
import 'package:it_contest_fe/features/quest/model/quest_create_request.dart';
import 'package:dio/dio.dart';
import 'package:it_contest_fe/core/storage/token_storage.dart';
import '../model/completion_status.dart';
import '../model/quest_item_response.dart';
import '../model/quest_status_change_response.dart';

class QuestService {

  // 퀘스트 생성하기 (기본 - bool 반환)
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

  // 퀘스트 생성하기 (EXP 정보 포함)
  Future<Map<String, dynamic>?> createQuestWithReward(QuestCreateRequest request) async {
    try {
      final token = await TokenStorage().getAccessToken();
      final response = await DioClient().dio.post(
        '/quests',
        data: request.toJson(),
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        print('[퀘스트 생성 응답] ${response.data}');
        
        // 백엔드 응답에서 실제 EXP 정보 추출
        final responseData = response.data;
        
        if (responseData is Map && responseData['result'] != null) {
          final data = responseData['result'];
          return {
            'success': true,
            'rewardExp': data['rewardExp'] ?? 10,
            'userExp': data['userExp'] ?? 0,
            'userLevel': data['userLevel'] ?? 1,
            'message': responseData['message'] ?? '', 
          };
        }
        
        // fallback
        return {
          'success': true,
          'rewardExp': 10,
          'userExp': 0,
          'userLevel': 1,
        };
      }
      
      return {'success': false};
    } catch (e, stack) {
      print('[퀘스트 생성 실패] ${e.toString()}');
      print(stack);
      return {'success': false};
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

  // 퀘스트 완료 상태 관리 (보상값 포함)
  Future<List<QuestStatusChangeResponse>> changeQuestStatus(List<int> questIds, String completionStatus, {int? expReward, int? goldReward}) async {
    try {
      final token = await TokenStorage().getAccessToken();
      
      final data = {
        'questIds': questIds,
        'completionStatus': completionStatus, // "COMPLETED" or "INCOMPLETE"
      };
      
      // 보상값이 제공되면 추가
      if (expReward != null) {
        data['expReward'] = expReward;
      }
      if (goldReward != null) {
        data['goldReward'] = goldReward;
      }
      
      print('📤 [퀘스트 상태 변경 요청] data: $data');
      
      final response = await DioClient().dio.patch(
        '/quests/change',
        data: data,
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );
      
      print('📥 [퀘스트 상태 변경 응답] ${response.statusCode}: ${response.data}');
      final List<dynamic> result = response.data['result'];
      return result.map((e) => QuestStatusChangeResponse.fromJson(e)).toList();
    } catch (e, stack) {
      print('[퀘스트 상태 변경 실패] ${e.toString()}');
      print(stack);
      rethrow;
    }
  }

  Future<QuestStatusChangeResponse> updateQuestStatus(int questId, CompletionStatus newStatus, {String? questTitle}) async {
    try {
      // 올바른 보상값 계산
      int? expReward;
      int? goldReward;
      
      if (newStatus == CompletionStatus.COMPLETED && questTitle != null) {
        if (questTitle.toLowerCase().contains('온보딩') || questTitle.toLowerCase().contains('onboarding')) {
          expReward = 100;
          goldReward = 50;
        } else {
          expReward = 10;
          goldReward = 5;
        }
      }
      
      final updatedList = await changeQuestStatus(
        [questId],
        newStatus == CompletionStatus.COMPLETED ? 'COMPLETED' : 'INCOMPLETE',
        expReward: expReward,
        goldReward: goldReward,
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


  // 모든 퀘스트의 보상을 올바른 값으로 업데이트
  Future<bool> updateAllQuestRewards() async {
    try {
      final quests = await fetchQuestList();
      bool allSuccess = true;

      for (final quest in quests) {
        // 개인/파티 퀘스트 이름 통합 처리
        final questLabel = (quest.questName ?? quest.title ?? '').toLowerCase();

        // 올바른 보상값 계산
        final correctExpReward = (questLabel.contains('온보딩') || questLabel.contains('onboarding'))
            ? 100
            : 10;
        final correctGoldReward = (questLabel.contains('온보딩') || questLabel.contains('onboarding'))
            ? 50
            : 5;

        // 현재 보상과 다르면 업데이트
        if (quest.expReward != correctExpReward || quest.goldReward != correctGoldReward) {
          final updateData = {
            'expReward': correctExpReward,
            'goldReward': correctGoldReward,
          };

          final success = await updateQuest(quest.questId, updateData);
          if (!success) {
            allSuccess = false;
            print('[퀘스트 보상 업데이트 실패] questId: ${quest.questId}');
          } else {
            print('[퀘스트 보상 업데이트 성공] questId: ${quest.questId}, exp: $correctExpReward, gold: $correctGoldReward');
          }
        }
      }

      return allSuccess;
    } catch (e, stack) {
      print('[퀘스트 보상 일괄 업데이트 실패] ${e.toString()}');
      print(stack);
      return false;
    }
  }
}