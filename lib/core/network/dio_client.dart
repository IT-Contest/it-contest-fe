// core/network/dio_client.dart
import 'package:dio/dio.dart';


class DioClient {
  final Dio _dio = Dio(BaseOptions(

    baseUrl: 'https://ssuchaehwa.duckdns.org',
    // baseUrl: 'http://192.168.0.40:8080', // 개발용
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    contentType: 'application/json',
  ));

  Dio get dio => _dio;
}