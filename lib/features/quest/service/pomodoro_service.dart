import 'package:dio/dio.dart';
import 'package:it_contest_fe/core/network/dio_client.dart';
import 'package:it_contest_fe/core/storage/token_storage.dart';

class PomodoroService {
  
  // 뽀모도로 세션 완료 기록
  Future<bool> completePomodoro({
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

      return response.statusCode == 200;
    } catch (e) {
      print('❌ [PomodoroService] Complete Pomodoro Error: $e');
      return false;
    }
  }
}