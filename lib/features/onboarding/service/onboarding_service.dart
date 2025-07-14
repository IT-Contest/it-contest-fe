import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  Future<void> markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
  }
}