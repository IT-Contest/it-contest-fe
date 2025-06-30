class AuthService {
  Future<bool> login(String email, String password) async {
    // TODO: 실제 API 통신 구현
    await Future.delayed(const Duration(seconds: 1));
    return email == 'test@test.com' && password == 'password123';
  }
}
