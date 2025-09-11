import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/network/dio_client.dart';


class AuthService {
  final DioClient _dioClient = DioClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // 로그아웃
  Future<void> logout() async {
    final accessToken = await _storage.read(key: "accessToken");

    if (accessToken == null) {
      throw Exception("저장된 AccessToken이 없습니다.");
    }

    await _dioClient.dio.post(
      "/auth/logout",
      options: Options(
        headers: {
          "Authorization": "Bearer $accessToken",
        },
      ),
    );

    // 로컬 저장소에서 토큰 삭제
    await _storage.delete(key: "accessToken");
    await _storage.delete(key: "refreshToken");
  }

  // 회원 탈퇴
  Future<void> withdraw() async {
    final accessToken = await _storage.read(key: "accessToken");
    if (accessToken == null) throw Exception("저장된 AccessToken이 없습니다.");

    await _dioClient.dio.delete(
      "/auth/withdraw",
      options: Options(headers: {"Authorization": "Bearer $accessToken"}),
    );

    // 탈퇴 성공 후 토큰 삭제
    await _storage.delete(key: "accessToken");
    await _storage.delete(key: "refreshToken");
  }
}