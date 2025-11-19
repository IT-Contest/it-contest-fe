import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/terms_model.dart';
import '../../../core/network/dio_client.dart';

class TermsService {
  final Dio _dio = DioClient().dio;
  final _storage = const FlutterSecureStorage();

  Future<List<Term>> getTerms() async {
    final res = await _dio.get("/users/terms");
    final List terms = res.data['result'];
    final baseUrl = _dio.options.baseUrl; // 여기서 baseUrl 가져옴

    return terms.map((t) {
      return Term(
        id: t['id'],
        title: t['title'],
        url: baseUrl + t['content'], // 절대경로로 변환
        required: t['required'],
      );
    }).toList();
  }

  Future<void> agreeTerms(List<int> termIds) async {
    final accessToken = await _storage.read(key: "accessToken"); // ✅ 불러오기
    if (accessToken == null) {
      throw Exception("로그인 토큰이 없습니다. 다시 로그인해주세요.");
    }

    final res = await _dio.post(
      "/users/terms/agree",
      data: {"termIds": termIds},
      options: Options(headers: {
        "Authorization": "Bearer $accessToken", // ✅ 토큰 넣기
      }),
    );

    if (res.statusCode != 200) {
      throw Exception("약관 동의 실패");
    }
  }

  Future<bool> checkRequiredTerms() async {
    final accessToken = await _storage.read(key: "accessToken");
    if (accessToken == null) {
      throw Exception("로그인 토큰이 없습니다.");
    }

    final res = await _dio.get(
      "/users/terms/check",
      options: Options(headers: {
        "Authorization": "Bearer $accessToken",
      }),
    );

    return res.data['result'] as bool;
  }

}