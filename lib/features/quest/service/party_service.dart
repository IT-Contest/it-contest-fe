import 'dart:convert';

import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../model/party_model.dart';

class PartyService {
  final Dio _dio = DioClient().dio;

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
}
