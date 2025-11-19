import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:it_contest_fe/core/network/dio_client.dart';
import 'package:it_contest_fe/core/storage/token_storage.dart';

class OnboardingCompletionResponse {
  final int userId;
  final int exp;
  final int level;
  final bool onboardingCompleted;
  final int rewardExp;

  OnboardingCompletionResponse({
    required this.userId,
    required this.exp,
    required this.level,
    required this.onboardingCompleted,
    required this.rewardExp,
  });

  factory OnboardingCompletionResponse.fromJson(Map<String, dynamic> json) {
    return OnboardingCompletionResponse(
      userId: json['userId'],
      exp: json['exp'],
      level: json['level'],
      onboardingCompleted: json['onboardingCompleted'],
      rewardExp: json['rewardExp'],
    );
  }
}

class OnboardingService {
  final Dio _dio = DioClient().dio;

  Future<void> markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
  }

  Future<OnboardingCompletionResponse?> completeOnboarding() async {
    try {
      final token = await TokenStorage().getAccessToken();
      
      final response = await _dio.post(
        '/users/onboarding/complete',
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );

      if (response.statusCode == 200) {
        final responseData = OnboardingCompletionResponse.fromJson(response.data['data']);
        await markOnboardingCompleted();
        return responseData;
      }
      
      return null;
    } catch (e, stack) {
      print('[온보딩 완료 API 실패] ${e.toString()}');
      print(stack);
      return null;
    }
  }
}