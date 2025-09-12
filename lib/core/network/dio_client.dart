// core/network/dio_client.dart
import 'package:dio/dio.dart';

class DioClient {
  final Dio _dio = Dio(BaseOptions(
    // baseUrl: 'https://ssuchaehwa.duckdns.org',
    baseUrl: 'http://192.168.0.40:8080',
    connectTimeout: const Duration(seconds:  10),
    receiveTimeout: const Duration(seconds: 10),
    contentType: 'application/json',
  ));

  Dio get dio => _dio;
}