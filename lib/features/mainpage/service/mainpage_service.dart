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
    print('📡 [MainpageService] API 호출 시작: /quests/mainpage');
    final token = await TokenStorage().getAccessToken();
    final response = await DioClient().dio.get(
      '/quests/mainpage',
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );

    print('📥 [MainpageService] API 응답: ${response.data}');
    final result = response.data['result'];
    final userResponse = MainpageUserResponse.fromJson(result);
    print('✅ [MainpageService] 파싱된 사용자 정보: exp=${userResponse.exp}, gold=${userResponse.gold}, level=${userResponse.level}');
    return userResponse;
  }

  // 친추 초대 api
  Future<String> createFriendInvite() async {
    final token = await TokenStorage().getAccessToken();
    final response = await DioClient().dio.post(
      '/quests/invite',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final result = response.data['result'];
    return result['inviteLink']; // inviteLink 대신 UUID만 받음
  }


  // 친구 초대 수락 api (EXP 정보 포함)
  Future<Map<String, dynamic>?> acceptFriendInvite(String inviteToken) async {
    try {
      final token = await TokenStorage().getAccessToken();
      final response = await DioClient().dio.post(
        '/quests/invite/accept',
        queryParameters: {'token': inviteToken},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        print('[친구 초대 수락 응답] ${response.data}');
        final data = response.data['data'];
        
        return {
          'success': true,
          'rewardExp': data['rewardExp'] ?? 5,
          'userExp': data['userExp'] ?? 0,
          'userLevel': data['userLevel'] ?? 1,
          'message': data['message'] ?? '친구 초대를 수락했습니다.',
        };
      }
      
      return {'success': false};
    } catch (e) {
      print('[친구 초대 수락 실패] $e');
      return {'success': false};
    }
  }
}
