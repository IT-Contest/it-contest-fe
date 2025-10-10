import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:it_contest_fe/features/quest/service/quest_service.dart';
import '../../../core/network/dio_client.dart';
import '../model/completion_status.dart';
import '../model/party_model.dart';
import '../model/party_status_change_response.dart';
import '../model/party_update_request.dart';
import '../model/quest_status_change_response.dart';

class PartyService {
  final Dio _dio = DioClient().dio;
  final QuestService _questService = QuestService();

  // 파티 생성 (EXP 정보 포함)
  Future<Map<String, dynamic>?> createPartyQuestWithReward(
      PartyCreateRequest request, String accessToken) async {
    try {
      print("📤 headers = {Authorization: Bearer $accessToken}");

      final response = await _dio.post(
        "/quests/party/create",
        data: request.toJson(),
        options: Options(
          headers: {"Authorization": "Bearer $accessToken"},
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('[파티 생성 응답] ${response.data}');
        final data = response.data["result"]; // ✅ 여기 맞음

        return {
          'success': true,
          'partyId': data["partyId"],
          'rewardExp': data['rewardExp'] ?? 0,
          'userExp': data['userExp'] ?? 0,
          'userLevel': data['userLevel'] ?? 1,
        };
      }
      return {'success': false};
    } catch (e) {
      print("❌ createPartyQuest error: $e");
      return {'success': false};
    }
  }

  // 파티 생성 (기존 - questId만 반환)
  Future<int?> createPartyQuest(PartyCreateRequest request, String accessToken) async {
    final result = await createPartyQuestWithReward(request, accessToken);
    return result?['questId'];
  }

  // 파티원 초대
  Future<void> inviteFriends(int partyId, List<int> friendIds, String accessToken) async {
    try {
      final body = {
        "friendIds": friendIds,
      };
      print("📤 inviteFriends body = $body");

      final response = await _dio.post(
        "/quests/party/$partyId/invite",
        data: body, // Map을 그대로 넘기면 Dio가 알아서 JSON 직렬화
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
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
        // print("✅ 내 파티 리스트 조회 성공: $result");
        return List<Map<String, dynamic>>.from(result);
      } else {
        // print("⚠️ 내 파티 리스트 조회 실패: ${response.statusCode}");
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

  // 파티 퀘스트 상태 변경
  Future<PartyStatusChangeResponse> changePartyQuestStatus(
      int partyId,
      CompletionStatus newStatus,
      String accessToken,
      ) async {
    try {
      final body = jsonEncode({
        "partyIds": [partyId],
        "completionStatus": newStatus == CompletionStatus.COMPLETED
            ? "COMPLETED"
            : "INCOMPLETE",
      });

      print("📤 PATCH /quests/party/change body=$body");

      final response = await _dio.patch(
        "/quests/party/change",
        data: body,
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ 파티 상태 변경 성공: ${response.data}");

        // result[0] -> PartyStatusChangeResponse
        return PartyStatusChangeResponse.fromJson(response.data['result'][0]);
      } else {
        throw Exception(
            "⚠️ 파티 상태 변경 실패: ${response.statusCode} ${response.data}");
      }
    } catch (e) {
      print("❌ changePartyQuestStatus error: $e");
      rethrow;
    }
  }

  // 파티 초대 수락/거절
  Future<void> respondToInvitation(
      int partyId,
      String status,
      String accessToken,
      ) async {
    try {
      final body = {
        "partyId": partyId,
        "responseStatus": status,
      };

      final response = await _dio.post(
        "/quests/party/party-response",
        data: body,
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("응답 실패: ${response.data}");
      }
    } catch (e) {
      rethrow;
    }
  }

  // 초대 받은 파티 조회
  Future<List<Map<String, dynamic>>> fetchInvitedParties(String accessToken) async {
    try {
      final response = await DioClient().dio.get(
        "/quests/party/party-list",
        options: Options(
          headers: {"Authorization": "Bearer $accessToken"},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> result = response.data['result'];
        return List<Map<String, dynamic>>.from(result);
      } else {
        // 여기서도 그냥 빈 리스트 반환 → 에러 대신 "초대장 없음"으로 처리
        return [];
      }
    } catch (e) {
      print("❌ inviteParties error: $e");
      rethrow;
    }
  }

}
