import 'package:dio/dio.dart';
import 'package:it_contest_fe/core/network/dio_client.dart';
import 'package:it_contest_fe/core/storage/token_storage.dart';

class PomodoroService {
  
  // 뽀모도로 세션 완료 기록 (EXP 정보 포함)
  Future<Map<String, dynamic>?> completePomodoroWithReward({
    required int sessionCount,
    required int totalMinutes,
    String? questId,
  }) async {
    final token = await TokenStorage().getAccessToken();
    
    try {
      final requestData = {
        'sessionCount': sessionCount,
        'totalMinutes': totalMinutes,
        if (questId != null) 'questId': questId,
        'completedAt': DateTime.now().toIso8601String(),
      };

      final response = await DioClient().dio.post(
        '/pomodoro/complete',
        data: requestData,
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );

      if (response.statusCode == 200) {
        print('[뽀모도로 완료 응답] ${response.data}');
        
        // ✅ result로 수정
        final result = response.data['result'];
        if (result == null) {
          print('❌ [PomodoroService] result가 null임');
          return {'success': false};
        }
        
        return {
          'success': true,
          'rewardExp': result['rewardExp'] ?? 5,
          'userExp': result['userExp'] ?? 0,
          'userLevel': result['userLevel'] ?? 1,
          'earnedExp': result['earnedExp'] ?? 5,
          'earnedGold': result['earnedGold'] ?? 5,
        };
      }
      
      return {'success': false};
    } catch (e) {
      print('❌ [PomodoroService] Complete Pomodoro Error: $e');
      return {'success': false};
    }
  }

  // 뽀모도로 세션 완료 기록 (기존 - bool 반환)
  Future<bool> completePomodoro({
    required int sessionCount,
    required int totalMinutes,
    String? questId,
  }) async {
    final result = await completePomodoroWithReward(
      sessionCount: sessionCount,
      totalMinutes: totalMinutes,
      questId: questId,
    );
    return result?['success'] == true;
  }
}
