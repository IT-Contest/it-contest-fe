import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:it_contest_fe/features/quest/service/quest_service.dart';
import '../../../core/network/dio_client.dart';
import '../model/completion_status.dart';
import '../model/party_model.dart';
import '../model/party_update_request.dart';
import '../model/quest_status_change_response.dart';

class PartyService {
  final Dio _dio = DioClient().dio;
  final QuestService _questService = QuestService();

  // 파티 생성
  Future<int?> createPartyQuest(PartyCreateRequest request, String accessToken) async {
    try {

      print("📤 headers = {Authorization: Bearer $accessToken}");

      final response = await _dio.post(
        "/quests/party/create",
        data: request.toJson(),
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken", // ✅ 토큰 추가
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ BaseResponse는 "result" 키 사용
        return response.data["result"]["questId"];
      }
      return null;
    } catch (e) {
      print("❌ createPartyQuest error: $e");
      return null;
    }
  }

  // 파티원 초대
  Future<void> inviteFriends(int partyId, List<int> friendIds, String accessToken) async {
    try {
      final body = jsonEncode({
        "friendIds": friendIds, // ✅ key로 감싸서 보내야 함
      });
      print("📤 inviteFriends body = $body");

      final response = await _dio.post(
        "/quests/party/$partyId/invite",
        data: body,
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ 친구 초대 성공: ${response.data}");
      } else {
        print("⚠️ 친구 초대 실패: ${response.statusCode} ${response.data}");
      }
    } catch (e) {
      print("❌ inviteFriends error: $e");
    }
  }

  // 파티 조회
  Future<List<Map<String, dynamic>>> fetchMyParties(String accessToken) async {
    try {
      final response = await _dio.get(
        "/quests/party/list",
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> result = response.data['result'];
        print("✅ 내 파티 리스트 조회 성공: $result");
        return List<Map<String, dynamic>>.from(result);
      } else {
        print("⚠️ 내 파티 리스트 조회 실패: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ fetchMyParties error: $e");
      return [];
    }
  }

  Future<QuestStatusChangeResponse> updatePartyQuestStatus(
      int partyId,
      CompletionStatus newStatus,
      ) async {
    try {
      final updatedList = await _questService.changeQuestStatus(
        [partyId],
        newStatus == CompletionStatus.COMPLETED ? 'COMPLETED' : 'INCOMPLETE',
      );
      return updatedList.first;
    } catch (e) {
      rethrow;
    }
  }

  // ✅ 파티 수정
  Future<bool> updatePartyQuest(
      int partyId,
      PartyUpdateRequest request,
      String accessToken,
      ) async {
    try {
      print("📤 PATCH /quests/party/$partyId");
      print("📤 body = ${request.toJson()}");

      final response = await _dio.patch(
        "/quests/party/$partyId",
        data: jsonEncode(request.toJson()), // ✅ JSON 직렬화
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        print("✅ 파티 수정 성공: ${response.data}");
        return true;
      } else {
        print("⚠️ 파티 수정 실패: ${response.statusCode} ${response.data}");
        return false;
      }
    } catch (e) {
      print("❌ updatePartyQuest error: $e");
      return false;
    }
  }

  // 파티 삭제
  Future<bool> deletePartyQuest(int partyId, String accessToken) async {
    try {
      final response = await _dio.delete(
        "/quests/party/$partyId",
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        print("✅ 파티 삭제 성공: ${response.data}");
        return true;
      } else {
        print("⚠️ 파티 삭제 실패: ${response.statusCode} ${response.data}");
        return false;
      }
    } catch (e) {
      print("❌ deletePartyQuest error: $e");
      return false;
    }
  }
}
